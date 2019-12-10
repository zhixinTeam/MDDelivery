
unit UMgrLBCModusTcp;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdComponent, IdTCPConnection,
  IdTCPClient,IdModbusClient, IdUDPServer, IdGlobal, IdSocketHandle, USysLoger, UWaitItem,
  ULibFun;

type
  TLBStatus = (bsInit, bsNew, bsStart, bsProcess,bsDone, bsClose);
  //状态: 初始化;新添加;开始;装车中;完成;关闭

  PLBTunnel = ^TLBTunnel;
  TLBTunnel = record
    FID           : string;            //通道标识
    FName         : string;
    FHost         : string;
    FBill         : string;            //交货单据
    FValue        : Single;            //待装量
    FValMax       : Single;            //最大数据:地磅出现的最大数值
    FValTunnel    : Single;            //通道数据:当前地磅数据
    FValUpdate    : Cardinal;          //通道更新:通道数据的更新时间
    FWeightMax    : Single;            //定值,装车中允许的最大量
    FStatusNow    : TLBStatus;         //当前状态
    FStatusNew    : TLBStatus;         //新状态
    FWeightDone   : Boolean;           //装车完成:完成装车量

    //TimeOut
    FTOProceFresh : Integer;           //装车进度刷新
    FInitFresh    : Cardinal;          //进度刷新计时
    FValFresh     : Single;            //进度刷新数据

    FTcpClient    : TIdModBusClient;
    FOptions      : TStrings;          //附加参数
    FStartEx      : Boolean;           //启动链板秤
    FStartValue   : Single;            
  end;

  TLBStatusChange = procedure (const nTunnel: PLBTunnel);
  TLBStatusChangeEvent = procedure (const nTunnel: PLBTunnel) of object;
  //事件定义

  TReaderHelperEx = class;
  TReaderConnector = class(TThread)
  private
    FSecond1,FSecond2 : Integer;
    FErr1,FErr2 : string;
    FOwner: TReaderHelperEx;
    //拥有者
    FBuffer: TList;
    //发送缓冲
    FWaiter: TWaitObject;
    //等待对象
    //FClient: TIdTCPClient;
    //网络对象
    FActive: PLBTunnel;
  protected
    procedure DoBasisWeight;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TReaderHelperEx);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TReaderHelperEx = class(TObject)
  private
    FPrinter: TReaderConnector;
    //打印对象
    FBuffData: TList;
    //临时缓冲
    FSyncLock: TCriticalSection;
    //同步锁
    FChangeProc: TLBStatusChange;
    FchangeEvent: TLBStatusChangeEvent;
  protected
    procedure InitTunnelData(const nTunnel: PLBTunnel; nSimpleOnly: Boolean);
    //初始化
    function FindTunnel(const nTunnel: string; nLoged: Boolean): Integer;
    //检索通道
    procedure DoChangeEvent(const nTunnel: PLBTunnel; nNewStatus: TLBStatus);
    //响应事件
  public
    FHostList: TList;
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartPrinter;
    procedure StopPrinter;
    //启停读取
    procedure StartWeight(const nTunnel,nBill: string; const nValue: Single);
    procedure StopWeight(const nTunnel: string);
    //起停称重
    procedure SetValueZero(const nTunnel: string);
    //累积量2清零
    procedure GetStartValue(const nTunnel: string;var StartValue:Single);
    procedure SetLBCStop(const nTunnel: string);
    //链板秤停止指令(由于使用现场控制，故不调用此函数)
    property OnStatusChange: TLBStatusChange read FChangeProc write FChangeProc;
    property OnStatusEvent: TLBStatusChangeEvent read FchangeEvent write FchangeEvent;
    //属性相关
  end;

var
  gModBusClient: TReaderHelperEx = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TReaderHelperEx, '链板秤服务', nEvent);
end;

constructor TReaderHelperEx.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
  FHostList := TList.Create;
end;

destructor TReaderHelperEx.Destroy;
begin
  StopPrinter;
  FBuffData.Free;
  FSyncLock.Free;
  inherited;
end;

procedure TReaderHelperEx.StartPrinter;
begin
  if not Assigned(FPrinter) then
    FPrinter := TReaderConnector.Create(Self);
  FPrinter.WakupMe;
end;

procedure TReaderHelperEx.StopPrinter;
begin
  if Assigned(FPrinter) then
    FPrinter.StopMe;
  FPrinter := nil;
end;

//Desc: 载入nFile配置文件
procedure TReaderHelperEx.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp, nTmp1: TXmlNode;
    nHost: PLBTunnel;
    nIdx: Integer;
    nStr: string;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
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
          FID    := nTmp.NodeByName('id').ValueAsString;
          FName  := nTmp.NodeByName('name').ValueAsString;;
          FHost  := nTmp.NodeByName('ip').ValueAsString;

          nTmp1 := nTmp.FindNode('options');
          if Assigned(nTmp1) then
          begin
            FOptions := TStringList.Create;
            SplitStr(nTmp1.ValueAsString, FOptions, 0, ';');
          end else FOptions := nil;

          if Assigned(FOptions) then
          begin
            nStr := FOptions.Values['ProceFresh'];
            if IsNumber(nStr, False) then
              FTOProceFresh := StrToInt(nStr) * 1000
            else FTOProceFresh := 1 * 1000;
          end;
        end;
        InitTunnelData(nHost, False);
        nHost.FStatusNow := bsInit;
        DoChangeEvent(nHost, bsInit);
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TReaderConnector.Create(AOwner: TReaderHelperEx);
var
  i, nCount: integer;
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  nCount := FOwner.FHostList.Count;

  for i := 0 to nCount -1 do
  begin
    PLBTunnel(FOwner.FHostList[i]).FTcpClient                := TIdModBusClient.Create;
    PLBTunnel(FOwner.FHostList[i]).FTcpClient.Host           := PLBTunnel(FOwner.FHostList[i]).FHost;
    PLBTunnel(FOwner.FHostList[i]).FTcpClient.Port           := 502;
    PLBTunnel(FOwner.FHostList[i]).FTcpClient.ReuseSocket    := rsOSDependent;
    PLBTunnel(FOwner.FHostList[i]).FTcpClient.ConnectTimeout := 3000;
    PLBTunnel(FOwner.FHostList[i]).FTcpClient.ReadTimeout    := 3000;
  end;
  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;
end;

destructor TReaderConnector.Destroy;
var
  i: Integer;
begin
  for i := 0 to FOwner.FHostList.Count -1 do
  begin
    PLBTunnel(FOwner.FHostList[i]).FTcpClient := nil;
  end;

  FBuffer.Free;

  FWaiter.Free;
  inherited;
end;

procedure TReaderConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TReaderConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TReaderConnector.Execute;
var
  nItv : Int64;
  nVal : Single;
  nIdx, i: Integer;
  nL: Boolean;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncLock.Enter;
    try
      for nIdx := FOwner.FHostList.Count - 1 downto 0 do
      begin
        FActive := FOwner.FHostList[nIdx];
        if (FActive.FBill = '') or (FActive.FValue <= 0) then Continue; //无业务
        nVal := 0;
        try
          if  Assigned(FActive.FTcpClient) then
            nL := FActive.FTcpClient.ReadSingle(1877,nVal);
        except
          on E: Exception do
          begin
            FActive.FStartEx := False;
            if nIdx = 0 then
            begin
              if FErr1 <> E.Message then
              begin
                FErr1 := E.Message;
                WriteLog(Format('Reader:[ %s ] Msg: %s', [FActive.FTcpClient.Host, E.Message]));
                FSecond1 := 120;
              end
              else
              begin
                if FSecond1 > 0 then
                  FSecond1 := FSecond1 - 1 ;
              end;
              if FSecond1 = 0 then
              begin
                WriteLog(Format('Reader:[ %s ] Msg: %s', [FActive.FTcpClient.Host, E.Message]));
                FSecond1 := 120;
              end;
            end
            else
            begin
              if FErr2 <> E.Message then
              begin
                FErr2 := E.Message;
                WriteLog(Format('Reader:[ %s ] Msg: %s', [FActive.FTcpClient.Host, E.Message]));
                FSecond2 := 120;
              end
              else
              begin
                if FSecond2 > 0 then
                  FSecond2 := FSecond2 - 1 ;
              end;
              if FSecond2 = 0 then
              begin
                WriteLog(Format('Reader:[ %s ] Msg: %s', [FActive.FTcpClient.Host, E.Message]));
                FSecond2 := 120;
              end;
            end;
            Sleep(500);
          end;
        end;

        if (nL) and (nVal > 0) then
        begin
          FActive.FValTunnel := nVal * 0.001-FActive.FStartValue*0.001;
          if FActive.FValTunnel > FActive.FValMax then
            FActive.FValMax := FActive.FValTunnel;
        end;
        if FActive.FValFresh <> FActive.FValTunnel then
        begin
          nItv := GetTickCountDiff(FActive.FInitFresh);
          if nItv >= FActive.FTOProceFresh then
          begin
            if (FActive.FValFresh = 0) and (FActive.FValTunnel > 0) then
                 FOwner.DoChangeEvent(FActive, bsStart)
            else
            begin
              FOwner.DoChangeEvent(FActive, bsProcess);
            end;

            FActive.FValFresh := FActive.FValTunnel;
            //刷新仪表数值
            FActive.FInitFresh := GetTickCount;
          end;
        end;
        DoBasisWeight;
        if Terminated then Break;
      end;
    finally
      FOwner.FSyncLock.Leave;
    end;
  except
    on E:Exception do
    begin
      WriteLog('zyww::'+E.Message);
    end;
  end;
end;

procedure TReaderHelperEx.StartWeight(const nTunnel, nBill: string;
  const nValue: Single);
var nIdx: Integer;
    nPT: PLBTunnel;
    nStartValue:Single;
begin
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FHostList[nIdx];
    if nPT.FBill <> nBill then
    begin
      SetValueZero(nPT.FID);
      nStartValue:=0;
      GetStartValue(nPT.FID,nStartValue);
      InitTunnelData(nPT, False);
      nPT.FBill := nBill;
      nPT.FValue := nValue;
      nPT.FWeightMax := nValue;
      nPT.FStartEx   := True;
      nPT.FStartValue:= nStartValue;
      DoChangeEvent(nPT, bsNew);
    end;
  finally
    FSyncLock.Leave;
  end;
end;

procedure TReaderHelperEx.StopWeight(const nTunnel: string);
var nIdx: Integer;
begin
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    InitTunnelData(FHostList[nIdx], False);
    DoChangeEvent(FHostList[nIdx], bsClose);
  finally
    FSyncLock.Leave;
  end;
end;

function TReaderHelperEx.FindTunnel(const nTunnel: string;
  nLoged: Boolean): Integer;
var nIdx: Integer;
begin
  Result := -1;
  //default
  
  for nIdx:=FHostList.Count-1 downto 0 do
  if CompareText(nTunnel, PLBTunnel(FHostList[nIdx]).FID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;

  if (Result < 0) and nLoged then
    WriteLog(Format('通道[ %s ]不存在.', [nTunnel]));
end;

procedure TReaderHelperEx.InitTunnelData(const nTunnel: PLBTunnel;
  nSimpleOnly: Boolean);
var nIdx: Integer;
begin
  if not nSimpleOnly then
  begin
    nTunnel.FBill := '';
    nTunnel.FWeightDone := False;

    nTunnel.FValue      := 0;
    nTunnel.FValMax     := 0;
    nTunnel.FValTunnel  := 0;
    nTunnel.FValUpdate  := GetTickCount;
    nTunnel.FWeightMax  := 0;
    nTunnel.FValFresh   := 0;
    nTunnel.FInitFresh  := 0;
  end;
end;

procedure TReaderHelperEx.DoChangeEvent(const nTunnel: PLBTunnel;
  nNewStatus: TLBStatus);
begin
  try
    nTunnel.FStatusNew := nNewStatus;
    if Assigned(FChangeProc) then FChangeProc(nTunnel);
    if Assigned(FChangeEvent) then FchangeEvent(nTunnel);
  except
    on nErr: Exception do
    begin
      WriteLog(nErr.Message);
    end;
  end;

  nTunnel.FStatusNow := nNewStatus;
  //apply status
end;

procedure TReaderConnector.DoBasisWeight;
begin
  if  (not (FActive.FWeightDone)) and
   (FActive.FValTunnel >= FActive.FWeightMax) then //装车完成
  begin
    FActive.FWeightDone := True;
    FOwner.DoChangeEvent(FActive, bsDone);
    WriteLog(FActive.FBill+'装车量:'+FloatToStr(FActive.FValTunnel));
  end;
end;

procedure TReaderHelperEx.SetValueZero(const nTunnel: string);
var
  nT : Integer;
  nPT: PLBTunnel;
  nBL: Boolean;
begin
  Exit;
  
  nT := FindTunnel(nTunnel,False);
  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]编号无效.', [nTunnel]));
    Exit;
  end;

  nPT := FHostList[nT];
  with nPT.FTcpClient do
  begin
    FSyncLock.Enter;
    try
      nBL := WriteCoil(00328,StrToBool('1'));
      if not nBL then
      begin
        WriteLog(Format('通道[ %s ]累积量2清零失败.', [nTunnel]));
      end
      else
      begin
        WriteLog(Format('通道[ %s ]累积量2清零成功.', [nTunnel]));
      end;
    finally
      FSyncLock.Leave;
    end;
  end;
end;

procedure TReaderHelperEx.SetLBCStop(const nTunnel: string);
var
  nT : Integer;
  nPT: PLBTunnel;
  nBL: Boolean;
begin
  nT := FindTunnel(nTunnel,False);
  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]编号无效.', [nTunnel]));
    Exit;
  end;

  nPT := FHostList[nT];
  with nPT.FTcpClient do
  begin
    FSyncLock.Enter;
    try
      nBL := WriteCoil(00322,StrToBool('1'));
      if not nBL then
      begin
        WriteLog(Format('通道[ %s ]链板秤停止失败.', [nTunnel]));
      end
      else
      begin
        WriteLog(Format('通道[ %s ]链板秤停止成功.', [nTunnel]));
      end;
    finally
      FSyncLock.Leave;
    end;
  end;
end;

procedure TReaderHelperEx.GetStartValue(const nTunnel: string;
  var StartValue: Single);
var
  nT : Integer;
  nPT: PLBTunnel;
  nBL: Boolean;
begin
  nT := FindTunnel(nTunnel,False);
  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]编号无效.', [nTunnel]));
    Exit;
  end;

  nPT := FHostList[nT];
  with nPT.FTcpClient do
  begin
    FSyncLock.Enter;
    try
      nBL := ReadSingle(1877,StartValue);
      if not nBL then
      begin
        WriteLog(Format('通道[ %s ]读取起始值失败.', [nTunnel]));
      end
      else
      begin
        WriteLog(Format('通道[ %s ]读取起始值成功.', [nTunnel]));
      end;
    finally
      FSyncLock.Leave;
    end;
  end;
end;

initialization
  gModBusClient := nil;
finalization
  FreeAndNil(gModBusClient);
end.
