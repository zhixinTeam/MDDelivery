{*******************************************************************************
  作者: 2019-8-8
  描述: ModBusTCP 读写计数器
*******************************************************************************}
unit UMultiModBus_JS;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdTCPClient, IdGlobal,
  UWaitItem, USysLoger,IdModbusClient, ULibFun;

const   
  cMultiJS_Truck           = 8;         //车牌长度
  cMultiJS_DaiNum          = 5;         //袋数长度
  cMultiJS_Delay           = 9;         //最大延迟
  cMultiJS_Tunnel          = 8;        	//最大道数
  cMultiJS_CmdInterval     = 20;        //命令间隔
  cMultiJS_FreshInterval   = 1200;      //刷新频率
  cMultiJS_SaveInterval    = 20 * 1000; //保存频率
  cModusJS_MaxThread       = 10;
  cHYReader_Wait_Short     = 150;
  cHYReader_Wait_Long      = 2 * 1000;
  cHYReader_CommandRetry   = 3;          //错误后尝试
type
  TMultiJSAction = (faControl, faPasuse, faQuery, faClear);
  //动作: 启动,暂停,查询,清除

  PJSTunnel = ^TJSTunnel;
  TJSTunnel = record
    FEnable       : Boolean;                      //是否启用
    FID           : string;                       //通道标识
    FName         : string;
    FGroupEx      : string;
    FHost         : string;
    FTruck: array[0..cMultiJS_Truck - 1] of Char; //车牌号
    FDaiNum: Word;                                //需装袋数
    FHasDone: Word;                               //已装袋数
    FIsRun: Boolean;                              //运行标记
    FLastBill: string;                            //扳道相关
    FLastSaveDai: Word;                           //上次保存
    FLastActive    : Cardinal;                    //上次活动
    FLocked        : Boolean;                     //是否锁定
    FTcpClient    : TIdModBusClient;
    FOptions      : TStrings;                     //附加参数
    FReadDai      : string;                       //读已装袋数地址
    FWriteDai     : string;                       //设定袋数地址
    FWriteStart   : string;                       //掉袋允许地址
    FStartValue   : string;                       //掉袋允许值
    FWriteClear   : string;                       //清零地址
  end;

  PJSDataItem = ^TJSDataItem;
  TJSDataItem = record
    FAction : TMultiJSAction;           //执行动作
    FTunnel : TJSTunnel;                //通道数据
    FTimes  : Integer;                  //发送次数
  end;

  TJSThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  TModbusJSManager = class;
  TJSReader = class(TThread)
  private
    FOwner: TModbusJSManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FThreadType: TJSThreadType;
    //线程模式
    FLastSave: Cardinal;
    //上次保存
    FActiveHost: Integer;
    //当前读头
    FActiveTunnel: PJSTunnel;
  protected
    procedure DoExecute;
    procedure Execute; override;
    //执行线程
    procedure ScanActiveReader(const nActive: Boolean);
    //扫描可用
    function ApplyRespondDataEx(const nReader: PJSTunnel) : Boolean;
    //更新袋数
    procedure SyncNowTunnel;
    //同步通道
    function SendJSCommand(const nReader: PJSTunnel): Boolean;
    //发送指令
  public
    constructor Create(AOwner: TModbusJSManager; AType: TJSThreadType);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  //----------------------------------------------------------------------------
  TModusJSEvent = procedure (const nTunnel: PJSTunnel) of object;
  //事件
  TModusJSProc = procedure (const nTunnel: PJSTunnel);
  //动作
  TModusJSGetTruck = function (const nTruck,nBill: string): string;
  //获取车牌

  TModbusJSManager = class(TObject)
  private
    FEnable: Boolean;
    //是否启用
    FMonitorCount: Integer;
    FThreadCount: Integer;
    //线程
    FReaderIndex: Integer;
    FReaderActive: Integer;
    //读头索引
    FCardLength: Integer;
    FCardPrefix: TStrings;
    //卡号标识
    FBuffData: TList;
    //数据缓冲
    FSyncLock: TCriticalSection;
    //同步锁定
    FThreads: array[0..cModusJS_MaxThread-1] of TJSReader;
    //读卡对象
    FChangeSync: TModusJSEvent;
    FChangeSyncProc: TModusJSProc;
    FSaveDataProc: TModusJSProc;
    FSaveDataEvent: TModusJSEvent;
    FGetTruck: TModusJSGetTruck;
    //事件定义
  protected
    procedure ClearBuffer(const nFree: Boolean);
    function GetTunnel(const nID: string; var nTunnel: PJSTunnel): Boolean;
    //检索通道
  public
    FHostList: TList;
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //载入配置
    procedure StartReader;
    procedure StopReader;
    //启停读头
    function AddJS(const nTunnel,nTruck,nBill:string; nDaiNum: Integer;
      const nDelJS: Boolean = False): Boolean;
    //添加计数
    function PauseJS(const nTunnel: string; const nOC: Boolean=True): Boolean;
    //暂停技术
    function DelJS(const nTunnel: string; const nBuf: TList = nil): Boolean;
    //删除计数
    function IsJSRun(const nTunnel: string): Boolean;
    //计数中
    function GetJSDai(const nBill: string): Integer;
    //已装袋数
    function GetJSStatus(const nList: TStrings): Boolean;
    //计数状态
    property ChangeSync: TModusJSEvent read FChangeSync write FChangeSync;
    property ChangeSyncProc: TModusJSProc read FChangeSyncProc write FChangeSyncProc;
    property SaveDataProc: TModusJSProc read FSaveDataProc write FSaveDataProc;
    property SaveDataEvent: TModusJSEvent read FSaveDataEvent write FSaveDataEvent;
    property GetTruckProc: TModusJSGetTruck read FGetTruck write FGetTruck;
    //属性相关
  end;

var
  gModbusJSManager: TModbusJSManager = nil;
  //全局使用
  
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TModbusJSManager, '多道计数器管理器', nEvent);
end;

constructor TModbusJSManager.Create;
var nIdx: Integer;
begin
  FEnable := False;
  FThreadCount := 1;
  FMonitorCount := 1;  

  for nIdx:=Low(FThreads) to High(FThreads) do
    FThreads[nIdx] := nil;
  //xxxxx

  FCardLength := 0;
  FCardPrefix := TStringList.Create;
  
  FHostList := TList.Create;
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TModbusJSManager.Destroy;
begin
  StopReader;
  ClearBuffer(True);

  FCardPrefix.Free;
  FSyncLock.Free;
  inherited;
end;

procedure TModbusJSManager.ClearBuffer(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FBuffData.Count - 1 downto 0 do
  begin
    Dispose(PJSDataItem(FBuffData[nIdx]));
    FBuffData.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FBuffData);
  //xxxxx
end;

procedure TModbusJSManager.StartReader;
var nIdx,nNum,i,nCount: Integer;
    nType: TJSThreadType;
begin
  if not FEnable then Exit;
  FReaderIndex := 0;
  FReaderActive := 0;

  nCount := FHostList.Count;

  for i := 0 to nCount -1 do
  begin
    PJSTunnel(FHostList[i]).FTcpClient      := TIdModBusClient.Create;
    PJSTunnel(FHostList[i]).FTcpClient.Host := PJSTunnel(FHostList[i]).FHost;
    PJSTunnel(FHostList[i]).FTcpClient.Port := 502;
    PJSTunnel(FHostList[i]).FTcpClient.ReuseSocket := rsOSDependent;
    PJSTunnel(FHostList[i]).FTcpClient.ReadTimeout := 5 * 1000;
    PJSTunnel(FHostList[i]).FTcpClient.ConnectTimeout := 5 * 1000;
  end;

  nNum := 0;
  //init
  
  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if (nNum >= FThreadCount) or (nNum > FHostList.Count) then Exit;
    //线程不能超过预定值,或不多余

    if nNum < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FThreads[nIdx]) then
      FThreads[nIdx] := TJSReader.Create(Self, nType);
    Inc(nNum);
  end;
end;

procedure TModbusJSManager.StopReader;
var nIdx,i: Integer;
begin
  for nIdx:=Low(FThreads) to High(FThreads) do
   if Assigned(FThreads[nIdx]) then
    FThreads[nIdx].Terminate;
  //设置退出标记

  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if Assigned(FThreads[nIdx]) then
      FThreads[nIdx].StopMe;
    FThreads[nIdx] := nil;
  end;

  for i := FHostList.Count -1 downto 0  do
  begin
    if Assigned(PJsTunnel(FHostList[i]).FTcpClient) then
    begin
      PJsTunnel(FHostList[i]).FTcpClient := nil;
    end;
  end;
end;

procedure TModbusJSManager.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nRoot,nNode, nTmp, nTmp1,nTmp2: TXmlNode;
    nHost: PJSTunnel;
    nIdx: Integer;
    nStr: string;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);

    nRoot := nXML.Root.NodeByName('config');
    if Assigned(nRoot) then
    begin
      nNode := nRoot.FindNode('enable');
      if Assigned(nNode) then
        Self.FEnable := nNode.ValueAsString <> 'N';

      nNode := nRoot.NodeByName('thread');
      if Assigned(nNode) then
           FThreadCount := nNode.ValueAsInteger
      else FThreadCount := 2;

      if (FThreadCount < 1) or (FThreadCount > 5) then
        raise Exception.Create('ERelay Reader Thread-Num Need Between 1-5.');
      //xxxxx

      nNode := nRoot.NodeByName('monitor');
      if Assigned(nNode) then
           FMonitorCount := nNode.ValueAsInteger
      else FMonitorCount := 1;

      if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
        raise Exception.Create(Format(
          'ERelay Reader Monitor-Num Need Between 1-%d.', [FThreadCount]));
      //xxxxx
    end;
    nNode := nXML.Root.NodeByName('items');
    if Assigned(nNode) then
    begin
      for nIdx:=0 to nNode.NodeCount - 1 do
      begin
        New(nHost);
        FHostList.add(nhost);
        nTmp := nNode.Nodes[nIdx];
        with nHost^ do
        begin
          nTmp2 := nTmp.NodeByName('enable');
          if Assigned(nTmp2) then
            FEnable     := nTmp2.ValueAsString <> 'N';

          nTmp2 := nTmp.FindNode('group');
          if Assigned(nTmp2) then
               FGroupEx := nTmp2.ValueAsString
          else FGroupEx := '';

          FID         := nTmp.NodeByName('id').ValueAsString;
          FName       := nTmp.NodeByName('name').ValueAsString;;
          FHost       := nTmp.NodeByName('ip').ValueAsString;

          FReadDai    := nTmp.NodeByName('ReadDai').ValueAsString;
          FWriteDai   := nTmp.NodeByName('WriteDai').ValueAsString;;
          FWriteStart := nTmp.NodeByName('WriteStart').ValueAsString;
          FStartValue := nTmp.NodeByName('StartValue').ValueAsString;;
          FWriteClear := nTmp.NodeByName('WriteClear').ValueAsString;
          FIsRun      := False;

          FLastActive := GetTickCount;
          FLocked     := False;

          nTmp1 := nTmp.FindNode('options');
          if Assigned(nTmp1) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nTmp1.ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

//          if Assigned(FOptions) then
//          begin
//            nStr := FOptions.Values['ProceFresh'];
//            if IsNumber(nStr, False) then
//              FTOProceFresh := StrToInt(nStr) * 1000
//            else FTOProceFresh := 1 * 1000;
//          end;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TJSReader.Create(AOwner: TModbusJSManager;
  AType: TJSThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cHYReader_Wait_Short;
end;

destructor TJSReader.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TJSReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TJSReader.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveTunnel := nil;
    try
      DoExecute;
    finally
      if Assigned(FActiveTunnel) then
      begin
        FOwner.FSyncLock.Enter;
        FActiveTunnel.FLocked := False;
        FOwner.FSyncLock.Leave;
      end;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end;
end;

//Date: 2015-12-06
//Parm: 活动&不活动读头
//Desc: 扫描nActive读头,若可用存入FActiveReader.
procedure TJSReader.ScanActiveReader(const nActive: Boolean);
var nIdx: Integer;
    nReader: PJSTunnel;
begin
  if nActive then //扫描活动读头
  with FOwner do
  begin
    if FReaderActive = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FReaderActive >= FHostList.Count then
      begin
        FReaderActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nReader := FHostList.Items[FReaderActive];
      Inc(FReaderActive);

      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive > 0 then 
      begin
        FActiveTunnel := nReader;
        FActiveTunnel.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //扫描不活动读头
  begin
    if FReaderIndex = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FReaderIndex >= FHostList.Count then
      begin
        FReaderIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nReader := FHostList.Items[FReaderIndex];
      Inc(FReaderIndex);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive = 0 then
      begin
        FActiveTunnel := nReader;
        FActiveTunnel.FLocked := True;
        Break;
      end;
      
    end;
  end;
end;

procedure TJSReader.DoExecute;
begin
  FOwner.FSyncLock.Enter;
  try
    if FThreadType = ttAll then
    begin
      ScanActiveReader(False);
      //优先扫描不活动读头

      if not Assigned(FActiveTunnel) then
        ScanActiveReader(True);
      //辅助扫描活动项
    end else

    if FThreadType = ttActive then //只扫活动线程
    begin
      ScanActiveReader(True);
      //优先扫描活动读头

      if Assigned(FActiveTunnel) then
      begin
        FWaiter.Interval := cHYReader_Wait_Short;
        //有活动读头,加速
      end else
      begin
        FWaiter.Interval := cHYReader_Wait_Long;
        //无活动读头,降速
        ScanActiveReader(False);
        //辅助扫描不活动项
      end;
    end;
  finally
    FOwner.FSyncLock.Leave;
  end;

  if Assigned(FActiveTunnel) and (not Terminated) then
  try
    if SendJSCommand(FActiveTunnel) or ApplyRespondDataEx(FActiveTunnel) then
    begin
      if FThreadType = ttActive then
        FWaiter.Interval := cHYReader_Wait_Short;
      FActiveTunnel.FLastActive := GetTickCount;
    end else
    begin
      FActiveTunnel.FLastActive := 0;
    end;
  except
    on E:Exception do
    begin
      FActiveTunnel.FLastActive := 0;

      WriteLog(Format('ModbusIP:[ %s ] Msg: %s', [FActiveTunnel.FHost, E.Message]));
      //focus reconnect
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015-02-08
//Parm: 字符串信息;字符数组
//Desc: 字符串转数组
function Str2Buf(const nStr: string; var nBuf: TIdBytes): Integer;
var nIdx: Integer;
begin
  Result := Length(nStr);;
  SetLength(nBuf, Result);

  for nIdx:=1 to Result do
    nBuf[nIdx-1] := Ord(nStr[nIdx]);
  //xxxxx
end;

//Date: 2015-07-08
//Parm: 目标字符串;原始字符数组
//Desc: 数组转字符串
function Buf2Str(const nBuf: TIdBytes): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBuf);
  SetLength(Result, nLen);

  for nIdx:=1 to nLen do
    Result[nIdx] := Char(nBuf[nIdx-1]);
  //xxxxx
end;

//Date: 2015-12-06
//Parm: 二进制串
//Desc: 格式化nBin为十六进制串
function HexStr(const nBin: string): string;
var nIdx,nLen: Integer;
begin
  nLen := Length(nBin);
  SetLength(Result, nLen * 2);

  for nIdx:=1 to nLen do
    StrPCopy(@Result[2*nIdx-1], IntToHex(Ord(nBin[nIdx]), 2));
  //xxxxx
end;

function TJSReader.ApplyRespondDataEx(const nReader: PJSTunnel) : Boolean;
var
  i: Integer;
  nStr: string;
  nPH: PJSTunnel;
  nBool,nBool1: Boolean;
  nInt : Word;
begin
  Result := False;
  nBool := GetTickCountDiff(FLastSave) >= cMultiJS_SaveInterval;
  if nBool then
    FLastSave := GetTickCount;
  //reset save time
  FOwner.FSyncLock.Enter;
  nInt:=0;
  nBool1 := False;
  try
    try
      if (Assigned(nReader.FTcpClient)) and (nReader.FLastBill <> '') then
      begin
        nBool1 := nReader.FTcpClient.ReadHoldingRegister(StrToInt(nReader.FReadDai),nInt);
      end;
      if (nBooL1)  then
      begin
        if nInt <= 0 then
        begin
          nReader.FIsRun := False;
          if nReader.FGroupEx <> '' then
          begin
            nStr := nReader.FGroupEx;
            for i:=0 to FOwner.FHostList.Count - 1 do
            begin
              nPH := FOwner.FHostList[i];

              if (CompareText(nStr, nPH.FGroupEx) = 0)  then
                nPH.FIsRun := False;
              //撤销同一分组的运行标记
            end;
          end;
          FOwner.DelJS(nReader.FID);
        end
        else
        begin
          if nReader.FHasDone <= nInt then
          begin
            try
              if nInt >= (nReader.FDaiNum - 3) then
              begin
                nReader.FIsRun := False;

                if nReader.FGroupEx <> '' then
                begin
                  nStr := nReader.FGroupEx;
                  for i:=0 to FOwner.FHostList.Count - 1 do
                  begin
                    nPH := FOwner.FHostList[i];

                    if (CompareText(nStr, nPH.FGroupEx) = 0)  then
                      nPH.FIsRun := False;
                    //撤销同一分组的运行标记
                  end;
                end;
                FOwner.DelJS(nReader.FID);
                nReader.FLastBill := '';
              end
              else nReader.FIsRun := True;

              nReader.FHasDone := nInt;
              //now dai num
            finally
              //
            end;

            if Assigned(FOwner.FChangeSync) or Assigned(FOwner.FChangeSyncProc) then
            begin
              Synchronize(SyncNowTunnel);
            end;
          end;
        end;

        if nBool1 then
        begin
          if Assigned(FOwner.FSaveDataEvent) then
            FOwner.FSaveDataEvent(nReader);
          //xxxxx

          if Assigned(FOwner.FSaveDataProc) then
            FOwner.FSaveDataProc(nReader);
          //xxxxx

          nReader.FLastSaveDai := nReader.FHasDone;
          //enable query means enable auto_save
        end;
        Result := True;
      end;
    except
      WriteLog('计数器 ['+nReader.FHost+'] 服务连接失败.');
    end;
  finally
    FOwner.FSyncLock.Leave;
  end;
end;

procedure TJSReader.SyncNowTunnel;
begin
  if Assigned(FOwner.FChangeSync) then
    FOwner.FChangeSync(FActiveTunnel);
  //xxxxx

  if Assigned(FOwner.FChangeSyncProc) then
    FOwner.FChangeSyncProc(FActiveTunnel);
  //xxxxx
end;


function TModbusJSManager.AddJS(const nTunnel, nTruck, nBill: string;
  nDaiNum: Integer; const nDelJS: Boolean): Boolean;
var nStr: string;
    nPT: PJSTunnel;
    nItem: PJSDataItem;
    nCmd : PJSDataItem;
    nIdx : Integer;
begin
  Result := False;

  if nDelJS then
    if not DelJS(nTunnel) then Exit;
  //停止计数

  Sleep(cMultiJS_CmdInterval);
  FSyncLock.Enter;
  try
    if not (GetTunnel(nTunnel,  nPT) ) then Exit;
    //通道无效

    if Assigned(FGetTruck) then
         nStr := FGetTruck(nTruck, Trim(nBill))
    else nStr := nTruck;

    nStr := Copy(nStr, 1, cMultiJS_Truck);
    nStr := nStr + StringOfChar(' ', cMultiJS_Truck - Length(nStr));
    StrPCopy(@nPT.FTruck[0], nStr);

    nPT.FHasDone := 0;
    nPT.FLastSaveDai := 0;
    nPT.FLastBill := nBill;

    nPT.FDaiNum := nDaiNum;
    nPT.FIsRun  := nPT.FGroupEx <> '';

    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nCmd := FBuffData[nIdx];
      if (CompareText(nPT.FID, nCmd.FTunnel.FID) = 0) and
         (nCmd.FAction = faControl) then
      begin
        PJSDataItem(FBuffData[nIdx]).FTunnel := nPT^;
        PJSDataItem(FBuffData[nIdx]).FTimes  := 0;
        Exit;
      end;
    end;

    New(nItem);
    FBuffData.Add(nItem);

    nItem.FAction  := faControl;
    nItem.FTunnel  := nPT^;
    nItem.FTimes   := 0;
  finally
    FSyncLock.Leave;
  end;
end;

function TModbusJSManager.DelJS(const nTunnel: string;
  const nBuf: TList): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nList: TList;
    nPT,nPH: PJSTunnel;
    nItem: PJSDataItem;
    nCmd : PJSDataItem;
begin
  FSyncLock.Enter;
  try
    Result := False;
    //default

    if not (GetTunnel(nTunnel, nPT)) then Exit;
    //通道数据无效

    if Assigned(nBuf) then
    begin
      nList := nBuf;
    end;

    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nCmd := FBuffData[nIdx];
      if (CompareText(nPT.FID, nCmd.FTunnel.FID) = 0) and
         (nCmd.FAction = faClear) then
      begin
        PJSDataItem(FBuffData[nIdx]).FTunnel := nPT^;
        PJSDataItem(FBuffData[nIdx]).FTimes  := 0;
        Exit;
      end;
    end;

    New(nItem);
    FBuffData.Add(nItem);

    nItem.FAction := faClear;
    nItem.FTunnel := nPT^;
    nItem.FTimes  := 0;
    nPT.FIsRun    := False;
    Result        := True;

  if not Result then Exit;
  
  if nPT.FGroupEx = '' then
  begin
    nPT.FIsRun := False;
    //运行标记
    Exit;
  end;

  nStr := nPT.FGroupEx;
  for i:=0 to FHostList.Count - 1 do
  begin
    nPH := FHostList[i];

    if (CompareText(nStr, nPH.FGroupEx) = 0)  then
      nPH.FIsRun := False;
    //撤销同一分组的运行标记
  end;
  finally
    FSyncLock.Leave;
  end;
end;

function TModbusJSManager.GetJSDai(const nBill: string): Integer;
var i,nIdx: Integer;
    nPTunnel: PJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := 0;
    //default
    for nIdx:=FHostList.Count-1 downto 0 do
    begin
      nPTunnel := PJSTunnel(FHostList[nIdx]);
      if CompareText(nBill, PJSTunnel(FHostList[nIdx]).FLastBill) = 0 then
      begin
        Result  := nPTunnel.FHasDone;
        Break;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

function TModbusJSManager.GetJSStatus(const nList: TStrings): Boolean;
var i,nIdx: Integer;
    nPTunnel: PJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := True;
    nList.Clear;

    for nIdx:=0 to FHostList.Count - 1 do
    begin
      nPTunnel                   := PJSTunnel(FHostList[nIdx]);
      if Trim(nPTunnel.FLastBill) <> '' then
        nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone)
      else
        nList.Values[nPTunnel.FID] := '0';
    end;
  finally
    FSyncLock.Leave;
  end;
end;

function TModbusJSManager.PauseJS(const nTunnel: string;
  const nOC: Boolean): Boolean;
var
    nPT: PJSTunnel;
    nItem: PJSDataItem;
    nCmd : PJSDataItem;
    nIdx : Integer;
begin
  FSyncLock.Enter;
  try
    Result := False;
    if not (GetTunnel(nTunnel, nPT)) then Exit;
    //通道无效
    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nCmd := FBuffData[nIdx];
      if (CompareText(nPT.FID, nCmd.FTunnel.FID) = 0) and
         (nCmd.FAction = faPasuse) then
      begin
        PJSDataItem(FBuffData[nIdx]).FTunnel := nPT^;
        PJSDataItem(FBuffData[nIdx]).FTimes  := 0;
        Exit;
      end;
    end;
    new(nItem);
    FBuffData.Add(nItem);
    nItem.FAction := faPasuse;
    nItem.FTunnel := nPT^;
    nItem.FTimes  := 0;
  finally
    FSyncLock.Leave;
  end;
end;

function TModbusJSManager.GetTunnel(const nID: string;
  var nTunnel: PJSTunnel): Boolean;
var i,nIdx: Integer;
    nPTunnel: PJSTunnel;
begin
  Result := False;
  nTunnel := nil;

  for nIdx:=FHostList.Count-1 downto 0 do
  begin
    nPTunnel := PJSTunnel(FHostList[nIdx]);
    if (CompareText(nID, nPTunnel.FID) = 0)
      and (nPTunnel.FEnable) then
    begin
      nTunnel := nPTunnel;
      Result  := True;
      Break;
    end;
  end;
end;

function TJSReader.SendJSCommand(const nReader: PJSTunnel): Boolean;
var nIdx: Integer;
    nCmd,nTmp: PJSDataItem;
    nBool1,nBool2: Boolean;
begin
  Result := False;

  with FOwner do
  try
    FSyncLock.Enter;
    //lock sync

    nIdx := 0;
    nCmd := nil;
    
    while nIdx < FBuffData.Count do
    begin
      nTmp := FBuffData[nIdx];
      if CompareText(nTmp.FTunnel.FID, nReader.FID) <> 0 then
      begin
        Inc(nIdx);
        Continue;
      end;

      if nTmp.FTimes < cHYReader_CommandRetry then
      begin
        nCmd := nTmp;
        Inc(nCmd.FTimes);
        Break;
      end else
      begin
        Dispose(nTmp);
        FBuffData.Delete(nIdx);
      end;
    end; 

    if not Assigned(nCmd) then Exit;
    //no command on reader
  finally
    FSyncLock.Leave;
  end;

  case nCmd.FAction of
    faControl :
    begin
      nCmd.FTunnel.FTcpClient.WriteRegister(StrToInt(nCmd.FTunnel.FWriteClear), 1);
      //总袋数设定
      nBool1 := nCmd.FTunnel.FTcpClient.WriteRegister(StrToInt(nCmd.FTunnel.FWriteDai), nCmd.FTunnel.FDaiNum);

      //掉袋电源允许
      nBool2 := nCmd.FTunnel.FTcpClient.WriteRegister(StrToInt(nCmd.FTunnel.FWriteStart), StrToInt(nCmd.FTunnel.FStartValue));

      if nBool1 and nBool2 then
      begin
        nCmd.FTimes := cHYReader_CommandRetry;
        WriteLog('通道'+nCmd.FTunnel.FID+'设置袋数:'+ IntToStr(nCmd.FTunnel.FDaiNum) +'成功！');
      end
      else
      begin
        Inc(nCmd.FTimes);
        WriteLog('通道'+nCmd.FTunnel.FID+'设置袋数:'+ IntToStr(nCmd.FTunnel.FDaiNum) +'失败！');
      end;
    end;
    faPasuse :
    begin
      //掉袋电源不允许
      nBool2 := nCmd.FTunnel.FTcpClient.WriteRegister(StrToInt(nCmd.FTunnel.FWriteStart), 0);
      if nBool2 then
      begin
        nCmd.FTimes := cHYReader_CommandRetry;
        WriteLog('通道'+nCmd.FTunnel.FID+'对地址:'+ nCmd.FTunnel.FWriteStart +'暂停成功！');
      end
      else
      begin
        Inc(nCmd.FTimes);
        WriteLog('通道'+nCmd.FTunnel.FID+'对地址:'+ nCmd.FTunnel.FWriteStart +'暂停失败！');
      end;
    end;
    faQuery :
    begin
      //  
    end;
    faClear :
    begin
      //总袋数清零
      nBool2 := nCmd.FTunnel.FTcpClient.WriteRegister(StrToInt(nCmd.FTunnel.FWriteClear), 1);
      if nBool2 then
      begin
        nCmd.FTunnel.FIsRun := False;
        nCmd.FTimes := cHYReader_CommandRetry;
        WriteLog('通道'+nCmd.FTunnel.FID+'对地址:'+ nCmd.FTunnel.FWriteClear +'清零成功！');
      end
      else
      begin
        Inc(nCmd.FTimes);
        WriteLog('通道'+nCmd.FTunnel.FID+'对地址:'+ nCmd.FTunnel.FWriteClear +'清零失败！');
      end;
    end;       
  end;
  Result := True;
end;

function TModbusJSManager.IsJSRun(const nTunnel: string): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nPT,nPH: PJSTunnel;
begin
  FSyncLock.Enter;
  try
    if GetTunnel(nTunnel, nPT) then
         Result := nPT.FIsRun
    else Result := False;

    if Result or (not Assigned(nPT)) then Exit;
    //run,or no tunnel

    if nPT.FGroupEx = '' then
      Exit; //no group    
    nStr := nPT.FGroupEx;

    for i:=0 to FHostList.Count - 1 do
    begin
      nPH := FHostList[i];

      if (CompareText(nStr, nPH.FGroupEx) = 0) then
      begin
        Result := nPH.FIsRun;
        if Result then
          Exit;
        //run tunnel exists
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gModbusJSManager := nil;
finalization
  FreeAndNil(gModbusJSManager);
end.
