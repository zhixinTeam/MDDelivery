{*******************************************************************************
  作者: dmzn@163.com 2012-09-07
  描述: 喷码机(驱动)管理器
*******************************************************************************}
unit UMgrCodePrinter;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UWaitItem, IdComponent, IdGlobal,
  IdTCPConnection, IdTCPClient, NativeXml, ULibFun, USysLoger;

const
  cCP_KeepOnLine = 3 * 1000;     //在线保持时间
  //CP=code printer

type
  GZWM = record
    fname: string;
    fValue: string;
end;

TarrGZWM = array of GZWM;
  
type
  PCodePrinter = ^TCodePrinter;
  TCodePrinter = record
    FID        : string;            //标识
    FIP        : string;            //地址
    FPort      : Integer;           //端口
    FTunnel    : string;            //通道

    FDriver    : string;            //驱动
    FEnable    : Boolean;           //启用
    FResponse  : Boolean;           //带应答
    FOnline    : Boolean;           //在线
    FLastOn    : Int64;             //上次在线
    FOptions   : TStrings;          //附加选项
  end;

  TCodePrinterManager = class;
  //define manager object
  
  TCodePrinterBase = class(TObject)
  protected
    FPrinter: PCodePrinter;
    //喷码机
    FClient: TIdTCPClient;
    //客户端
    FFlagLock: Boolean;
    //锁定标记
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; virtual; abstract;
    //打印编码
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    class function DriverName: string; virtual; abstract;
    //驱动名称
    function Print(const nPrinter: PCodePrinter; const nCode: string;
     var nHint: string): Boolean;
    //打印编码
    function IsOnline(const nPrinter: PCodePrinter): Boolean;
    //是否在线
    procedure LockMe;
    procedure UnlockMe;
    function IsLocked: Boolean;
    //驱动状态
  end;

  TCodePrinterMonitor = class(TThread)
  private
    FOwner: TCodePrinterManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TCodePrinterManager);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TCodePrinterDriverClass = class of TCodePrinterBase;
  //the driver class define

  TCodePrinterManager = class(TObject)
  private
    FDriverClass: array of TCodePrinterDriverClass;
    FDrivers: array of TCodePrinterBase;
    //驱动列表
    FPrinters: TList;
    //喷码机列表
    FMonIdx: Integer;
    FMonitor: array[0..1]of TCodePrinterMonitor;
    //监控线程
    FTunnelCode: TStrings;
    //通道喷码
    FSyncLock: TCriticalSection;
    //同步对象
    FEnablePrinter: Boolean;
    FEnableJSQ: Boolean;
    //系统开关
  protected
    procedure ClearDrivers;
    procedure ClearPrinters(const nFree: Boolean);
    //释放资源
    function GetPrinter(const nTunnel: string): PCodePrinter;
    //检索喷码机
  public
    gValue:TarrGZWM;
    gValueEx:TarrGZWM;
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //载入配置
    procedure StartMon;
    procedure StopMon;
    //起停监控
    procedure RegDriver(const nDriver: TCodePrinterDriverClass);
    //注册驱动
    function LockDriver(const nName: string): TCodePrinterBase;
    procedure UnlockDriver(const nDriver: TCodePrinterBase);
    //获取驱动
    function PrintCode(const nTunnel,nCode: string; var nHint: string): Boolean;
    //打印编码
    function IsPrinterOnline(const nTunnel: string): Boolean;
    //是否在线
    function IsPrinterEnable(const nTunnel: string): Boolean;
    procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
    //起停喷码机
    property EnablePrinter: Boolean read FEnablePrinter;
    //属性相关
  end;

var
  gCodePrinterManager: TCodePrinterManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCodePrinterManager, '喷码机管理器', nEvent);
end;

//------------------------------------------------------------------------------
constructor TCodePrinterMonitor.Create(AOwner: TCodePrinterManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2 * 1000;
end;

destructor TCodePrinterMonitor.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TCodePrinterMonitor.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TCodePrinterMonitor.Execute;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  while not Terminated do
  with FOwner do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FSyncLock.Enter;
    try
      if FMonIdx >= FPrinters.Count then
        FMonIdx := 0;
      //xxxxx
    finally
      FSyncLock.Leave;
    end;

    while True do
    begin
      FSyncLock.Enter;
      try
        nPrinter := nil;
        if FMonIdx >= FPrinters.Count then Break;
        
        nPrinter := FPrinters[FMonIdx];
        Inc(FMonIdx);

        if not nPrinter.FEnable then Continue;
        if GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine then Continue;
      finally
        FSyncLock.Leave;
      end;

      if not Assigned(nPrinter) then Break;
      nDriver := LockDriver(nPrinter.FDriver);
      try
        nDriver.IsOnline(nPrinter);
      finally
        UnlockDriver(nDriver);
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterManager.Create;
begin
  FEnablePrinter := False;
  FEnableJSQ := False;

  FPrinters := TList.Create;
  FTunnelCode := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  //广州文墨
  SetLength(gValue,38);
  gValue[0].fname := '0';
  gValue[0].fValue:= '708898A8C88870000000000000000000';
  gValue[1].fname := '1';
  gValue[1].fValue:= '20602020202070000000000000000000';
  gValue[2].fname := '2';
  gValue[2].fValue:= '708808304080F8000000000000000000';
  gValue[3].fname := '3';
  gValue[3].fValue:= 'F8102010088870000000000000000000';
  gValue[4].fname := '4';
  gValue[4].fValue:= '10305090F81010000000000000000000';
  gValue[5].fname := '5';
  gValue[5].fValue:= 'F880F008088870000000000000000000';
  gValue[6].fname := '6';
  gValue[6].fValue:= '304080F0888870000000000000000000';
  gValue[7].fname := '7';
  gValue[7].fValue:= 'F8081020404040000000000000000000';
  gValue[8].fname := '8';
  gValue[8].fValue:= '70888870888870000000000000000000';
  gValue[9].fname := '9';
  gValue[9].fValue:= '70888878081060000000000000000000';
  gValue[10].fname := 'A';
  gValue[10].fValue:= '70888888F88888000000000000000000';
  gValue[11].fname := 'B';
  gValue[11].fValue:= 'F08888F08888F0000000000000000000';
  gValue[12].fname := 'C';
  gValue[12].fValue:= '70888080808870000000000000000000';
  gValue[13].fname := 'D';
  gValue[13].fValue:= 'F08888888888F0000000000000000000';
  gValue[14].fname := 'E';
  gValue[14].fValue:= 'F88080F08080F8000000000000000000';
  gValue[15].fname := 'F';
  gValue[15].fValue:= 'F88080F0808080000000000000000000';
  gValue[16].fname := 'G';
  gValue[16].fValue:= '70888098888878000000000000000000';
  gValue[17].fname := 'H';
  gValue[17].fValue:= '888888F8888888000000000000000000';
  gValue[18].fname := 'I';
  gValue[18].fValue:= 'F82020202020F8000000000000000000';
  gValue[19].fname := 'J';
  gValue[19].fValue:= '38101010109060000000000000000000';
  gValue[20].fname := 'K';
  gValue[20].fValue:= '8890A0C0A09088000000000000000000';
  gValue[21].fname := 'L';
  gValue[21].fValue:= '808080808080F8000000000000000000';
  gValue[22].fname := 'M';
  gValue[22].fValue:= '88D8A8A8888888000000000000000000';
  gValue[23].fname := 'N';
  gValue[23].fValue:= '8888C8A8988888000000000000000000';
  gValue[24].fname := 'O';
  gValue[24].fValue:= '70888888888870000000000000000000';
  gValue[25].fname := 'P';
  gValue[25].fValue:= 'F08888F0808080000000000000000000';
  gValue[26].fname := 'Q';
  gValue[26].fValue:= '70888888A89068000000000000000000';
  gValue[27].fname := 'R';
  gValue[27].fValue:= 'F08888F0A09088000000000000000000';
  gValue[28].fname := 'S';
  gValue[28].fValue:= '70888070088870000000000000000000';
  gValue[29].fname := 'T';
  gValue[29].fValue:= 'F8202020202020000000000000000000';
  gValue[30].fname := 'U';
  gValue[30].fValue:= '88888888888870000000000000000000';
  gValue[31].fname := 'V';
  gValue[31].fValue:= '88888888885020000000000000000000';
  gValue[32].fname := 'W';
  gValue[32].fValue:= '888888A8A8A850000000000000000000';
  gValue[33].fname := 'X';
  gValue[33].fValue:= '88885020508888000000000000000000';
  gValue[34].fname := 'Y';
  gValue[34].fValue:= '88888850202020000000000000000000';
  gValue[35].fname := 'Z';
  gValue[35].fValue:= 'F80810204080F8000000000000000000';
  gValue[36].fname := '_';
  gValue[36].fValue:= '000000000000FF000000000000000000';
  gValue[37].fname := '-';
  gValue[37].fValue:= '0000007F000000000000000000000000';

  //广州文墨二行
  SetLength(gValueEx,38);
  gValueEx[0].fname := '0';
  gValueEx[0].fValue:= '708898A8C8887000';
  gValueEx[1].fname := '1';
  gValueEx[1].fValue:= '2060202020207000';
  gValueEx[2].fname := '2';
  gValueEx[2].fValue:= '708808304080F800';
  gValueEx[3].fname := '3';
  gValueEx[3].fValue:= 'F810201008887000';
  gValueEx[4].fname := '4';
  gValueEx[4].fValue:= '10305090F8101000';
  gValueEx[5].fname := '5';
  gValueEx[5].fValue:= 'F880F00808887000';
  gValueEx[6].fname := '6';
  gValueEx[6].fValue:= '304080F088887000';
  gValueEx[7].fname := '7';
  gValueEx[7].fValue:= 'F808102040404000';
  gValueEx[8].fname := '8';
  gValueEx[8].fValue:= '7088887088887000';
  gValueEx[9].fname := '9';
  gValueEx[9].fValue:= '7088887808106000';
  gValueEx[10].fname := 'A';
  gValueEx[10].fValue:= '70888888F8888800';
  gValueEx[11].fname := 'B';
  gValueEx[11].fValue:= 'F08888F08888F000';
  gValueEx[12].fname := 'C';
  gValueEx[12].fValue:= '7088808080887000';
  gValueEx[13].fname := 'D';
  gValueEx[13].fValue:= 'F08888888888F000';
  gValueEx[14].fname := 'E';
  gValueEx[14].fValue:= 'F88080F08080F800';
  gValueEx[15].fname := 'F';
  gValueEx[15].fValue:= 'F88080F080808000';
  gValueEx[16].fname := 'G';
  gValueEx[16].fValue:= '7088809888887800';
  gValueEx[17].fname := 'H';
  gValueEx[17].fValue:= '888888F888888800';
  gValueEx[18].fname := 'I';
  gValueEx[18].fValue:= 'F82020202020F800';
  gValueEx[19].fname := 'J';
  gValueEx[19].fValue:= '3810101010906000';
  gValueEx[20].fname := 'K';
  gValueEx[20].fValue:= '8890A0C0A0908800';
  gValueEx[21].fname := 'L';
  gValueEx[21].fValue:= '808080808080F800';
  gValueEx[22].fname := 'M';
  gValueEx[22].fValue:= '88D8A8A888888800';
  gValueEx[23].fname := 'N';
  gValueEx[23].fValue:= '8888C8A898888800';
  gValueEx[24].fname := 'O';
  gValueEx[24].fValue:= '7088888888887000';
  gValueEx[25].fname := 'P';
  gValueEx[25].fValue:= 'F08888F080808000';
  gValueEx[26].fname := 'Q';
  gValueEx[26].fValue:= '70888888A8906800';
  gValueEx[27].fname := 'R';
  gValueEx[27].fValue:= 'F08888F0A0908800';
  gValueEx[28].fname := 'S';
  gValueEx[28].fValue:= '7088807008887000';
  gValueEx[29].fname := 'T';
  gValueEx[29].fValue:= 'F820202020202000';
  gValueEx[30].fname := 'U';
  gValueEx[30].fValue:= '8888888888887000';
  gValueEx[31].fname := 'V';
  gValueEx[31].fValue:= '8888888888502000';
  gValueEx[32].fname := 'W';
  gValueEx[32].fValue:= '888888A8A8A85000';
  gValueEx[33].fname := 'X';
  gValueEx[33].fValue:= '8888502050888800';
  gValueEx[34].fname := 'Y';
  gValueEx[34].fValue:= '8888885020202000';
  gValueEx[35].fname := 'Z';
  gValueEx[35].fValue:= 'F80810204080F800';
  gValueEx[36].fname := '_';
  gValueEx[36].fValue:= '000000000000FF00';
  gValueEx[37].fname := '-';
  gValueEx[37].fValue:= '0000007F00000000';
end;

destructor TCodePrinterManager.Destroy;
begin
  StopMon;
  ClearDrivers;
  ClearPrinters(True);

  FTunnelCode.Free;
  FSyncLock.Free;

  SetLength(gValue, 0);
  inherited;
end;

procedure TCodePrinterManager.ClearPrinters(const nFree: Boolean);
var nIdx: Integer;
    nPrinter: PCodePrinter;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FPrinters.Count - 1 downto 0 do
    begin
      nPrinter := FPrinters[nIdx];
      if Assigned(nPrinter.FOptions) then
        FreeAndNil(nPrinter.FOptions);
      Dispose(nPrinter);
    end;
    //xxxxx

    if nFree then
         FPrinters.Free
    else FPrinters.Clear;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TCodePrinterManager.ClearDrivers;
var nIdx: Integer;
begin
  for nIdx:=Low(FDrivers) to High(FDrivers) do
    FDrivers[nIdx].Free;
  SetLength(FDrivers, 0);
end;

procedure TCodePrinterManager.StartMon;
var nIdx: Integer;
begin
  if FEnablePrinter then
  begin
    if FPrinters.Count > 0 then
         FMonIdx := 0
    else Exit;

    for nIdx:=Low(FMonitor) to High(FMonitor) do
    begin
      FMonitor[nIdx] := nil;
      Exit; //关闭喷码机在线监测

      if nIdx >= FPrinters.Count then Break;
      //探测线程不超过喷码机个数

      if not Assigned(FMonitor[nIdx]) then
        FMonitor[nIdx] := TCodePrinterMonitor.Create(Self);
      //xxxxx
    end;
  end;
end;

procedure TCodePrinterManager.StopMon;
var nIdx: Integer;
begin
  for nIdx:=Low(FMonitor) to High(FMonitor) do
   if Assigned(FMonitor[nIdx]) then
   begin
     FMonitor[nIdx].StopMe;
     FMonitor[nIdx] := nil;
   end;
end;

procedure TCodePrinterManager.RegDriver(const nDriver: TCodePrinterDriverClass);
var nIdx: Integer;
begin
  for nIdx:=Low(FDriverClass) to High(FDriverClass) do
   if FDriverClass[nIdx].DriverName = nDriver.DriverName then Exit;
  //driver exists

  nIdx := Length(FDriverClass);
  SetLength(FDriverClass, nIdx + 1);
  FDriverClass[nIdx] := nDriver;
end;

//Date: 2012-9-7
//Parm: 驱动名称
//Desc: 锁定nName驱动对象
function TCodePrinterManager.LockDriver(const nName: string): TCodePrinterBase;
var nIdx,nInt: Integer;
begin
  Result := nil;
  FSyncLock.Enter;
  try
    for nIdx:=Low(FDrivers) to High(FDrivers) do
    if (not FDrivers[nIdx].IsLocked) and
       (CompareText(FDrivers[nIdx].DriverName, nName) = 0) then
    begin
      Result := FDrivers[nIdx];
      Exit;
    end;

    for nIdx:=Low(FDriverClass) to High(FDriverClass) do
    if CompareText(FDriverClass[nIdx].DriverName, nName) = 0 then
    begin
      nInt := Length(FDrivers);
      SetLength(FDrivers, nInt + 1);

      Result := FDriverClass[nIdx].Create;
      FDrivers[nInt] := Result;
      Exit;
    end;

    WriteLog(Format('无法锁定名称为[ %s ]喷码机驱动.', [nName]));
  finally
    if Assigned(Result) then
      Result.LockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: 驱动对象
//Desc: 对nDriver解锁
procedure TCodePrinterManager.UnlockDriver(const nDriver: TCodePrinterBase);
begin
  if Assigned(nDriver) then
  begin
    FSyncLock.Enter;
    nDriver.UnlockMe;
    FSyncLock.Leave;
  end;
end;

//Date: 2012-9-7
//Parm: 通道
//Desc: 检索nTunnel通道上的喷码机
function TCodePrinterManager.GetPrinter(const nTunnel: string): PCodePrinter;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPrinters.Count - 1 downto 0 do
  begin
    Result := FPrinters[nIdx];
    if CompareText(Result.FTunnel, nTunnel) = 0 then
         Break
    else Result := nil;
  end;
end;

//Date: 2012-9-7
//Parm: 通道
//Desc: 判断nTunnel的喷码机是否在线
function TCodePrinterManager.IsPrinterOnline(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    WriteLog(Format('通道[ %s ]没有配置喷码机.', [nTunnel]));
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
      Result := nDriver.IsOnline(nPrinter);
    //xxxxx
  finally
    UnlockDriver(nDriver);
  end;
end;

//Date: 2013-07-23
//Parm: 通道号
//Desc: 查询nTunnel通道上的喷码机状态
function TCodePrinterManager.IsPrinterEnable(const nTunnel: string): Boolean;
var nPrinter: PCodePrinter;
begin
  Result := False;

  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      Result := nPrinter.FEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 通道;起停标识
//Desc: 起停nTunnel通道上的喷码机
procedure TCodePrinterManager.PrinterEnable(const nTunnel: string;
  const nEnable: Boolean);
var nPrinter: PCodePrinter;
begin
  if FEnablePrinter then
  begin
    nPrinter := GetPrinter(nTunnel);
    if Assigned(nPrinter) then
      nPrinter.FEnable := nEnable;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 通道;编码
//Desc: 在nTunnel通道的喷码机上打印nCode
function TCodePrinterManager.PrintCode(const nTunnel, nCode: string;
  var nHint: string): Boolean;
var nPrinter: PCodePrinter;
    nDriver: TCodePrinterBase;
begin
  if not FEnablePrinter then
  begin
    Result := True;
    Exit;
  end;

  if Length(nCode) < 1 then
  begin
    Result := True;
    Exit;
  end;
  //无喷码内容
  
  Result := False;
  nPrinter := GetPrinter(nTunnel);

  if not Assigned(nPrinter) then
  begin
    nHint := Format('通道[ %s ]没有配置喷码机.', [nTunnel]);
    Exit;
  end;
  
  nDriver := nil;
  try
    nDriver := LockDriver(nPrinter.FDriver);
    if Assigned(nDriver) then
         Result := nDriver.Print(nPrinter, nCode, nHint)
    else nHint := Format('加载名称为[ %s ]的喷码机失败.', [nPrinter.FDriver]);
  finally
    UnlockDriver(nDriver);
  end;

  if Result then
    FTunnelCode.Values[nTunnel] := nCode;
  //保存上次有效喷码
end;

//Desc: 读取nFile喷码机配置文件
procedure TCodePrinterManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nResponse: Boolean;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nPrinter: PCodePrinter;
begin
  nXML := TNativeXml.Create;
  try
    ClearPrinters(False);
    nXML.LoadFromFile(nFile);

    nResponse := False;
    nTmp := nXML.Root.FindNode('config');

    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('enableprinter').ValueAsInteger;
      FEnablePrinter := nIdx = 1;

      nIdx := nTmp.NodeByName('enablejsq').ValueAsInteger;
      FEnableJSQ := nIdx = 1;

      nNode := nTmp.FindNode('response');
      if Assigned(nNode) then
        nResponse := nNode.ValueAsInteger = 1;
      //全局配置: 是否带应答反馈
    end;

    nTmp := nXML.Root.FindNode('printers');
    if Assigned(nTmp) then
    begin
      for nIdx:=0 to nTmp.NodeCount - 1 do
      begin
        New(nPrinter);
        FPrinters.Add(nPrinter);

        nNode := nTmp.Nodes[nIdx];
        with nPrinter^ do
        begin
          FID := nNode.AttributeByName['id'];
          FIP := nNode.NodeByName('ip').ValueAsString;
          FPort := nNode.NodeByName('port').ValueAsInteger;

          FTunnel := nNode.NodeByName('tunnel').ValueAsString;
          FDriver := nNode.NodeByName('driver').ValueAsString;
          FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;

          FResponse := nResponse;
          if Assigned(nNode.FindNode('response')) then
            FResponse := nNode.NodeByName('response').ValueAsInteger = 1;
          //xxxxx

          if Assigned(nNode.FindNode('options')) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nNode.FindNode('options').ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

          FOnline := False;
          FLastOn := 0;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TCodePrinterBase.Create;
begin
  FFlagLock := False;
  FClient := TIdTCPClient.Create;
  FClient.ConnectTimeout := 5 * 1000;
  FClient.ReadTimeout := 3 * 1000;
end;

destructor TCodePrinterBase.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;
  inherited;
end;

procedure TCodePrinterBase.LockMe;
begin
  FFlagLock := True;
end;

procedure TCodePrinterBase.UnlockMe;
begin
  FFlagLock := False;
end;

function TCodePrinterBase.IsLocked: Boolean;
begin
  Result := FFlagLock;
end;

//Desc: 判断nPrinter是否在线
function TCodePrinterBase.IsOnline(const nPrinter: PCodePrinter): Boolean;
begin
  if (not nPrinter.FEnable) or
     (GetTickCount - nPrinter.FLastOn < cCP_KeepOnLine) then
  begin
    Result := True;
    Exit;
  end else Result := False;

  try
    if (FClient.Host <> nPrinter.FIP) or (FClient.Port <> nPrinter.FPort) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx

      FClient.Host := nPrinter.FIP;
      FClient.Port := nPrinter.FPort;
    end;

    if not FClient.Connected then
      FClient.Connect;
    Result := FClient.Connected;

    nPrinter.FOnline := Result;
    if Result then
      nPrinter.FLastOn := GetTickCount;
    //xxxxx
  except
    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date: 2012-9-7
//Parm: 喷码机;编码
//Desc: 向nPrinter发送nCode编码.
function TCodePrinterBase.Print(const nPrinter: PCodePrinter;
  const nCode: string; var nHint: string): Boolean;
begin
  if not nPrinter.FEnable then
  begin
    Result := True;
    Exit;
  end else Result := False;

  if not IsOnline(nPrinter) then
  begin
    nHint := Format('喷码机[ %s ]网络通讯异常.', [nPrinter.FID]);
    Exit;
  end;

  try
    try
      if Assigned(FClient.IOHandler) then
      begin
        FClient.IOHandler.InputBuffer.Clear;
        FClient.IOHandler.WriteBufferClear;
      end;

      if not FClient.Connected then
        FClient.Connect;

      FPrinter := nPrinter;
      Result := PrintCode(nCode, nHint);
    except
      on E:Exception do
      begin
        WriteLog(E.Message);
        nHint := Format('向喷码机[ %s ]发送内容失败.', [nPrinter.FID]);

        FClient.Disconnect;
        if Assigned(FClient.IOHandler) then
          FClient.IOHandler.InputBuffer.Clear;
        //xxxxx
      end;
    end;
  finally
    FClient.Disconnect;
  end;
end;

//------------------------------------------------------------------------------
type
  TByteWord = record
    FH: Byte;
    FL: Byte;
  end;

function CalCRC16(data, crc, genpoly: Word): Word;
var i: Word;
begin
  data := data shl 8;                       // 移到高字节
  for i:=7 downto 0 do
  begin
    if ((data xor crc) and $8000) <> 0 then //只测试最高位
         crc := (crc shl 1) xor genpoly     // 最高位为1，移位和异或处理
    else crc := crc shl 1;                  // 否则只移位（乘2）
    data := data shl 1;                     // 处理下一位
  end;

  Result := crc;
end;

function CRC16(const nStr: string; const nStart,nEnd: Integer): Word;
var nIdx: Integer;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  for nIdx:=nStart to nEnd do
  begin
    Result := CalCRC16(Ord(nStr[nIdx]), Result, $1021);
  end;
end;

function ModbusCRC(const nData: string): Word;
const
  cPoly = $A001; //多项式：A001(1010 0000 0000 0001)
var i,nIdx,nLen: Integer;
    nNoZero: Boolean;
begin
  Result := $FFFF;
  nLen := Length(nData);

  for nIdx:=1 to nLen do
  begin
    Result := Ord(nData[nIdx]) xor Result;
    for i:=1 to 8 do
    begin
      nNoZero := Result and $0001 <> 0;
      Result := Result shr 1;

      if nNoZero then
        Result := Result xor cPoly;
      //xxxxx
    end;
  end;
end;

function strtoascii(const inputAnsi:string): integer;
//字符串转换为ascii值,转换值是一个各单独值相加后的结果
var
  Ansitemp,i,OutPutAnsi :integer;
begin
  OutPutAnsi:=0;
  For i:=0 To Length(inputAnsi) Do
    begin
      Ansitemp := ord(inputAnsi[i]);
      outputansi := OutPutAnsi+Ansitemp;
    end;
  Result:= OutPutAnsi;
end;

function CRC12(const Lenth: integer; const RXBUFFER: TByteArray): Integer;
var
  crc12out : Integer;
  i,j : Integer;
begin
  Result := 0;
  crc12out :=0;

	for j:=0 to Lenth-1 do
  begin
	   for i:=0 to 7 do
     begin
	  	if (Ord(RXBUFFER[j]) and ($80 shr i)) <> 0 then
         crc12out := crc12out or $1;
	  	if(crc12out>=$1000) then
        crc12out := crc12out xor $180d;
      crc12out :=	crc12out shl 1;
     end;
	 end;
	 for i :=0 to 11 do
	 begin
	 	if(crc12out>=$1000) then
      crc12out := crc12out xor $180d;
	  crc12out :=	crc12out shl 1;
	 end;
   crc12out := crc12out shr 1;
   Result := crc12out;
end;

//------------------------------------------------------------------------------
type
  TPrinterZero = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterZero.DriverName: string;
begin
  Result := 'zero';
end;

//Desc: 打印编码
function TPrinterZero.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
begin
  //protocol: 55 7F len order datas crc16 AA
  nData := Char($55) + Char($7F) + Char(Length(nCode) + 1);
  nData := nData + Char($54) + Char($01);
  nData := nData + nCode;

  nCrc := TByteWord(CRC16(nData, 5, Length(nData)));
  nData := nData + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, 9, False);
    nStr := BytesToString(nBuf,Indy8BitEncoding);

    nData :=  Char($55) + Char($FF) + Char($02)+ Char($54)+ Char($4F);
    nData :=  nData + Char($4B)+ Char($5D) + Char($E4) + Char($AA);

    if nstr <> nData then
    begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterJY = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterJY.DriverName: string;
begin
  Result := 'JY';
end;

function TPrinterJY.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin

  //久易喷码机
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  // 1B 41 29 为开头数据
  // 27 表示喷码的字的个数 （27表示为1个） 计数的方式为16进制
  // 20 表示通道的编码      （20为通道1）  计数的方式为16进制
  // 40 37 表示喷码数据的开始
  // ***  喷码的数据        传送的方式为ASCII码
  // 40 39 表示喷码数据的结尾
  // 0D   表示整体传送的结尾

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;


//-----------------------------------------------------------------------
type
  TPrinterWSD = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSD.DriverName: string;
begin
  Result := 'WSD';
end;

function TPrinterWSD.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin
  //威士德喷码机
  //1B 41 29 2A 20 40 37 32 33 34 35 40 39 0D

  //1B 41 29 起始位
  //2A 表示该条指令后面的字节长度+20（蓝色与红色字的长度），计数的方式为16进制
  //20  表示通道的编码（20为通道1，21为通道2，以此类推）  计数的方式为16进制
  //40 37 表示喷码数据的开始
  //40 39 表示喷码数据的结尾
  //0D   表示整体传送的结尾

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 32 + 6);
  nData := nData+Char(2 + 31 )+Char($40)+Char($37);
  nData := nData+nCode;
  nData := nData+Char($40)+Char($39)+Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterSGB = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSGB.DriverName: string;
begin
  Result := 'SGB';
end;

function TPrinterSGB.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //仕贵宝喷码机
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  //1B 41 2C 22 channel(start 31) 0D;
  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 38);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  nData := Char($1B) + Char($41) + Char($2C) +Char($22);
  nData := nData + Char(2 + 31) + Char($0D);
  
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterWZP = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWZP.DriverName: string;
begin
  Result := 'WZP';
end;

function TPrinterWZP.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //未知喷码机
  //23 30 31 11 41 datas 0D 0A
  nData := Char($23) + Char($30) + Char($31) + Char($11) + Char($41);
  nData := nData + nCode + Char($0D) + Char($0A);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);
  end;

  Result := True;
end;

//-----------------------------------------------------------------------
type
  TPrinterDWA = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterDWA.DriverName: string;
begin
  Result := 'DWA';
end;

function TPrinterDWA.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
  nBuf: TIdBytes;
begin

  //大微A类喷码机
  //1B 41 len(start 34) channel(start 32) 40 37 datas 40 39 0D
  // 1B 41 29 为开头数据
  // 23 表示喷码的字的个数 （23表示为1个） 计数的方式为16进制
  // 20 表示通道的编码      （20为通道0）  计数的方式为16进制
  // 40 37 表示喷码数据的开始
  // ***  喷码的数据        传送的方式为ASCII码
  // 40 39 表示喷码数据的结尾
  // 0D   表示整体传送的结尾

  nData := Char($1B) + Char($41) + Char($29)+ Char(Length(nCode) + 34);
  nData := nData + Char(2 + 31) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39)+ Char($0D);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, Length(nData), False);

    nStr := BytesToString(nBuf, Indy8BitEncoding);
    if nStr <> nData then
    begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
type
  TPrinterWSDP011C = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWSDP011C.DriverName: string;
begin
  Result := 'WSDP011C';
end;

//Desc: 打印编码
function TPrinterWSDP011C.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData,nDataVerify: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
begin
  //protocol: 55 len order datas ModbusCRC AA
  nData := Char($55) + Char($00) + Char(Length(nCode) + 17);
  nData := nData + Char($53) + Char($4E);
  nData := nData + Char($03) + Char($00) + Char($00) + Char($01);

  nDataVerify := Char($01) + Char($00) + Char($01) + Char($00) + Char(Length(nCode));
  nDataVerify := nDataVerify + nCode;

  nCrc := TByteWord(ModbusCRC(nDataVerify));
  nDataVerify := nDataVerify + Char(nCrc.FH) + Char(nCrc.FL) + Char($AA);

  nData := nData + nDataVerify;

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  if FPrinter.FResponse then
  begin
    SetLength(nBuf, 0);
    FClient.Socket.ReadBytes(nBuf, 12, False);
    nStr := BytesToString(nBuf,Indy8BitEncoding);

    nData :=  Char($55) + Char($00) + Char($0C)+ Char($4F)+ Char($4B);
    nData :=  nData + Char($03)+ Char($00) + Char($00) + Char($01);
    nData :=  nData + Char($FF)+ Char($FF) + Char($AA);
    if nstr <> nData then
    begin
      nHint := '喷码机应答错误!';
      Result := False;
      Exit;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
type
  TPrinterHYPM = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterHYPM.DriverName: string;
begin
  Result := 'HYPM';
end;

//Desc: 打印编码
function TPrinterHYPM.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData,nDataClear: string;
    nCrc: TByteWord;
    nBuf: TIdBytes;
    crc:  string;
    Finstructions : TByteArray;
    i, nLength,nTmp,k,nTmp1 : Integer;
    str,sYY,nValue: string;
//16进制字符串转换成字符串
function HexStrToStr(const S:string):string;
var
t:Integer;
ts:string;
M,Code:Integer;
begin
t:=1;
Result:='';
while t<=Length(S) do
begin   //xlh 2006.10.21
    while (t<=Length(S)) and (not (S[t] in ['0'..'9','A'..'F','a'..'f'])) do
      inc(t);
    if (t+1>Length(S))or(not (S[t+1] in ['0'..'9','A'..'F','a'..'f'])) then
      ts:='$'+S[t]
    else
      ts:='$'+S[t]+S[t+1];
    Val(ts,M,Code);
    if Code=0 then
      Result:=Result+Chr(M);
    inc(t,2);
end;
end;
begin
  Finstructions[0]:=$02;

  str     := Trim(nCode);
  nLength := Length(str);
  Finstructions[1]:=(6+nlength);
  Finstructions[2]:=$01;
  Finstructions[3]:=$00;
  Finstructions[4]:=$00;
  Finstructions[5]:=$00;
  Finstructions[6]:=$00;
  Finstructions[7]:=$02;
  for i:=0 to nLength - 1 do
  begin
    nTmp := strtoascii(str[i+1]);
    k:=8+i;
    Finstructions[k] := nTmp  ;
  end;
  nData := Char($FE) + Char($FE);
  for i := 0 to (nLength + 8)-1 do
  nData := nData + Char(Finstructions[i]) ;
  crc := IntToHex(CRC12(8+nlength,Finstructions),4);
  nData := nData + HexStrToStr(Copy(crc,1,2))+HexStrToStr(Copy(crc,3,2)) +Char($FA)+Char($FA);

  nDataClear := Char($FE)+Char($FE)+Char($FF)+Char($FF)+Char($FA)+Char($FA);
  FClient.Socket.Write(nDataClear, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

//  if FPrinter.FResponse then
//  begin
//    SetLength(nBuf, 0);
//    FClient.Socket.ReadBytes(nBuf, 12, False);
//    nStr := BytesToString(nBuf,Indy8BitEncoding);
//
//    nData :=  Char($55) + Char($00) + Char($0C)+ Char($4F)+ Char($4B);
//    nData :=  nData + Char($03)+ Char($00) + Char($00) + Char($01);
//    nData :=  nData + Char($FF)+ Char($FF) + Char($AA);
//    if nstr <> nData then
//    begin
//      nHint := '喷码机应答错误!';
//      Result := False;
//      Exit;
//    end;
//  end;

  Result := True;
end;

//广州文墨喷码一行显示----------------------
type
  TPrinterWMPM = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterWMPM.DriverName: string;
begin
  Result := 'WMPM';
end;

//Desc: 打印编码
function TPrinterWMPM.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
    nCrc,nCrcTmp: Word;
    nBuf: TIdBytes;
    crc:  Integer;
    Finstructions : TByteArray;
    i, nLength,nTmp,k,nTmp1 : Integer;
    str,sYY,nValue: string;
    nDataTmp:string;
  function strtoascii(const inputAnsi:string): integer;
  //字符串转换为ascii值,转换值是一个各单独值相加后的结果
  var
    Ansitemp,i,OutPutAnsi :integer;
  begin
    OutPutAnsi:=0;
    For i:=0 To Length(inputAnsi) Do
      begin
        Ansitemp := ord(inputAnsi[i]);
        outputansi := OutPutAnsi+Ansitemp;
      end;
    Result:= OutPutAnsi;
  end;
begin
  str := nCode;
  nDataTmp:='';
  for i:=1 to Length(str) do
  begin
    for k:=0 to High(gCodePrinterManager.gValue)  do
    begin
      if gCodePrinterManager.gValue[k].fname = str[i] then
      begin
        nDataTmp := nDataTmp + gCodePrinterManager.gValue[k].fValue;
        Break;
      end;

    end;
  end;
  nCrc := $46 xor $31;
  for i:=1 to Length(nDataTmp) do
  begin
    nCrcTmp:=strtoascii(nDataTmp[i]);
    nCrc := nCrc xor nCrcTmp;
  end;
  nData := Char($24)+ Char($46)+Char($31)+ndataTmp+char($2A)+IntToHex(nCrc,2)+Char($0D)+Char($0A);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  Result := True;
end;

//广州文墨喷码二行显示,#号分隔,#号前是第一行，#后是第二行----------------------
type
  TPrinterWMPMEx = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;


{ TPrinterWMPMEx }

class function TPrinterWMPMEx.DriverName: string;
begin
  Result := 'WMPM2';
end;

function TPrinterWMPMEx.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nStr,nData: string;
    nCrc,nCrcTmp: Word;
    nBuf: TIdBytes;
    crc:  Integer;
    Finstructions : TByteArray;
    i, nLength,nTmp,k, k2, nTmp1 : Integer;
    sYY,nValue,str1,str2: string;
    nDataTmp:string;
  function strtoascii(const inputAnsi:string): integer;
  //字符串转换为ascii值,转换值是一个各单独值相加后的结果
  var
    Ansitemp,i,OutPutAnsi :integer;
  begin
    OutPutAnsi:=0;
    For i:=0 To Length(inputAnsi) Do
      begin
        Ansitemp := ord(inputAnsi[i]);
        outputansi := OutPutAnsi+Ansitemp;
      end;
    Result:= OutPutAnsi;
  end;
begin
  str1:= Copy(nCode,1,Pos('#',nCode)-1);
  str2:= Copy(nCode,Pos('#',nCode)+1,MaxInt);

  nDataTmp:='';
  if Length(str1) >= Length(str2) then
  begin
    for i:=1 to Length(str1) do
    begin
      for k:=0 to High(gCodePrinterManager.gValueEx)  do
      begin
        if gCodePrinterManager.gValueEx[k].fname = str1[i] then
        begin
          nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k].fValue;
          Break;
        end;
      end;

      if i <= Length(str2) then
      begin
        for k2:=0 to High(gCodePrinterManager.gValueEx)  do
        begin
          if gCodePrinterManager.gValueEx[k2].fname = str2[i] then
          begin
            nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k2].fValue;
            Break;
          end;
        end;
      end
      else
      begin
        nDataTmp := nDataTmp + '0000000000000000';
      end;
    end;
  end
  else
  begin
    for i:=1 to Length(str2) do
    begin
      if i <= Length(str1) then
      begin
        for k:=0 to High(gCodePrinterManager.gValueEx)  do
        begin
          if gCodePrinterManager.gValueEx[k].fname = str1[i] then
          begin
            nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k].fValue;
            Break;
          end;
        end;
      end
      else
      begin
        nDataTmp := nDataTmp + '0000000000000000';
      end;

      for k2:=0 to High(gCodePrinterManager.gValueEx)  do
      begin
        if gCodePrinterManager.gValueEx[k2].fname = str2[i] then
        begin
          nDataTmp := nDataTmp + gCodePrinterManager.gValueEx[k2].fValue;
          Break;
        end;
      end;
    end;
  end;
  nCrc := $46 xor $31;
  for i:=1 to Length(nDataTmp) do
  begin
    nCrcTmp:=strtoascii(nDataTmp[i]);
    nCrc := nCrc xor nCrcTmp;
  end;
  nData := Char($24)+ Char($46)+Char($31)+ndataTmp+char($2A)+IntToHex(nCrc,2)+Char($0D)+Char($0A);

  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(100);
  FClient.Socket.Write(nData, Indy8BitEncoding);
  Sleep(200);

  Result := True;
end;

//  祁连山 仕贵宝喷码机
type
  TPrinterSLPM = class(TCodePrinterBase)
  protected
    function PrintCode(const nCode: string;
     var nHint: string): Boolean; override;
  public
    class function DriverName: string; override;
  end;

class function TPrinterSLPM.DriverName: string;
begin
  Result := 'SLPM';
end;

//Desc: 打印编码
function TPrinterSLPM.PrintCode(const nCode: string;
  var nHint: string): Boolean;
var nData: string;
    nBuf: TIdBytes;
begin
  //仕贵宝喷码机
  //1B 41 len(start 38) channel(start 31) 40 37 datas 40 39 0D
  //1B 41 2C 22 channel(start 31) 0D;
//  if nAddr='' then nAddr:= '01';

//  if nAddr='01' then
  nData := Char($1B) + Char($41);
//  else if nAddr='02' then  nData := Char($1B) + Char($42)
//  else if nAddr='11' then  nData := Char($1B) + Char($51)
//  else if nAddr='12' then  nData := Char($1B) + Char($52)
//  else if nAddr='21' then  nData := Char($1B) + Char($61)
//  else if nAddr='22' then  nData := Char($1B) + Char($62);

  nData := nData + Char($29) + Char(Length(nCode) + 38);
  nData := nData + Char(20) + Char($40) + Char($37);
  nData := nData + nCode + Char($40) + Char($39) + Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  Sleep(800);
  //for delay

  nData := Char($1B) + Char($41) + Char($2C) +Char($22);
  nData := nData + Char(32) + Char($0D);
  FClient.Socket.Write(nData, Indy8BitEncoding);

  //SetLength(nBuf, 0);
  //FClient.Socket.ReadBytes(nBuf, Length(nData), False);

  Result := True;
end;

initialization
  gCodePrinterManager := TCodePrinterManager.Create;
  gCodePrinterManager.RegDriver(TPrinterZero);
  gCodePrinterManager.RegDriver(TPrinterJY);
  gCodePrinterManager.RegDriver(TPrinterWSD);
  gCodePrinterManager.RegDriver(TPrinterSGB);
  gCodePrinterManager.RegDriver(TPrinterWZP);
  gCodePrinterManager.RegDriver(TPrinterDWA);
  gCodePrinterManager.RegDriver(TPrinterWSDP011C);
  gCodePrinterManager.RegDriver(TPrinterHYPM);
  gCodePrinterManager.RegDriver(TPrinterWMPM);
  gCodePrinterManager.RegDriver(TPrinterWMPMEx);
  gCodePrinterManager.RegDriver(TPrinterSLPM);
finalization
  FreeAndNil(gCodePrinterManager);
end.
