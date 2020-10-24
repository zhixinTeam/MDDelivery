{*******************************************************************************
  作者: dmzn@163.com 2018-11-22
  描述:  深圳天腾实业(TTCE)发卡机/吞卡机驱动单元

  备注:
  *.发卡机支持K720、K730、K750,驱动基于K7x0协议开发.
*******************************************************************************}
unit UMgrTTCEDispenser;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdTCPClient, IdGlobal,
  CPort, CPortTypes, UWaitItem, USysLoger, ULibFun;

const
  cDispenser_MaxThread      = 10;                  //最大扫描线程数
  cDispenser_Wait_Short     = 1500;
  cDispenser_Wait_Long      = 3 * 1000;            //等待时长
  cDispenser_Wait_Timeout   = 12 * 1000;           //等待应答超时

  cTTCE_Frame_MaxSize       = 300;                 //命令包最大字节数
  cTTCE_Frame_DataMax       = cTTCE_Frame_MaxSize - 7; //命令包最大负载
  cTTCE_Frame_SendInterval  = 300;                 //数据包发送间隔
  
type
  PDispenserK7Send = ^TDispenserK7Send;
  TDispenserK7Send = packed record
    FSTX   : Byte;                                 //块起始符
    FADDH  : Byte;                                 //地址H
    FADDL  : Byte;                                 //地址L
    FLen   : Word;                                 //发送的数据包长
    FData  : array [0..cTTCE_Frame_DataMax-1] of Char;//发送的数据包
    FETX   : Byte;                                 //块结束符
    FBCC   : Byte;                                 //异或校验
  end;

  PDispenserK7Recv = ^TDispenserK7Recv;
  TDispenserK7Recv = packed record
    FSTX   : Byte;                                 //块起始符
    FADDH  : Byte;                                 //地址H
    FADDL  : Byte;                                 //地址L
    FLen   : Word;                                 //返回数据包长
    FRes   : Char;                                 //执行结果: P/N
    FData  : array [0..cTTCE_Frame_DataMax-1] of Char;//返回的数据包
    FETX   : Byte;                                 //块结束符
    FBCC   : Byte;                                 //异或校验
  end;

  TDispenserType = (dtSender, dtReceiver);
  //设备类型: 发卡机,吞卡机
  TDispenserConnType = (ctTCP, ctCOM);
  //链路类型: 网络,串口

  PDispenserItem = ^TDispenserItem;
  TDispenserItem = record
    FEnable       : Boolean;                       //是否启用
    FID           : string;                        //设备标识
    FType         : TDispenserType;                //设备类型
    FAddH         : Byte;
    FAddL         : Byte;                          //多机通讯地址:高低位
    FTimeout      : Integer;                       //超时收卡

    FConn         : TDispenserConnType;            //链路
    FHost         : string;                        //地址
    FPort         : Integer;                       //端口
    FClient       : TIdTCPClient;                  //通信链路

    FCOMPort      : TComPort;                      //读写对象
    FCOMBuff      : string;                        //通讯缓冲
    FCOMData      : string;                        //通讯数据
                                                   
    FLastSend     : Int64;                         //上次发送
    FLastStatus   : string;                        //最后主机状态
    FStatusKeep   : Int64;                         //最后状态时间
    FNowCard      : string;                        //当前读卡位卡号
    FLastCMD      : string;                        //需要执行的指令
                                                             
    FLastActive   : Int64;                         //上次活动
    FLocked       : Boolean;                       //是否锁定
    FOptions      : TStrings;                      //可选项
  end;

  TDispenserThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  TDispenserManager = class;
  TDispenserThread = class(TThread)
  private
    FOwner: TDispenserManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FActiveDispenser: PDispenserItem;
    //当前读头
    FThreadType: TDispenserThreadType;
    //线程模式
  protected
    procedure DoExecute;
    procedure Execute; override;
    //执行线程
    procedure ScanActiveDispenser(const nActive: Boolean);
    //扫描可用
    procedure InitSendData(const nData: PDispenserK7Send; const nCMD: string = '');
    //初始化数据
    function SendData2Bytes(const nData: PDispenserK7Send): TIdBytes;
    //转为发送缓冲
    function SendWithResponse(const nSend: PDispenserK7Send;
      const nRecv: PDispenserK7Recv): Boolean;
    //应答模式发送数据
    function SendToDispenser(const nSend: PDispenserK7Send): Boolean;
    //将数据发送到设备
    function ReadCOMData(nLen: Integer): Boolean;
    //从串口读取数据
    function PrepareCard(const nDispenser: PDispenserItem): Boolean;
    //准备卡片: 将卡片发到读卡位置
    function QueryStatuse: string;
    function HasStatus(const nALL: string; const nStatus: Integer): Boolean;
    //查询设备状态
    function SendCardToReadPosition: Boolean;
    //将卡片发到读卡位
    function GetCardSerial: string;
    function ParseCardNO(const nCard: string; const nHex: Boolean): string;
    //读取卡号
    function SendCardOut: Boolean;
    //将卡片发到取卡位
    function RecoveryCard: Boolean;
    //将卡片收到回收箱
    function ResetDispenser: Boolean;
    //重置设置
    procedure WriteRecvError(const nRecv: PDispenserK7Recv);
    //记录错误日志
  public
    constructor Create(AOwner: TDispenserManager; AType: TDispenserThreadType);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TDispenserProc = procedure (const nDispenser: PDispenserItem);
  TDispenserEvent = procedure (const nDispenser: PDispenserItem) of object;

  TDispenserManager = class(TObject)
  private
    FEnable: Boolean;
    //是否启用
    FMonitorCount: Integer;
    FThreadCount: Integer;
    //扫描线程
    FDispenserIndex: Integer;
    FDispenserActive: Integer;
    //设备索引
    FDispensers: TList;
    //设备列表
    FSyncLock: TCriticalSection;
    //同步锁定
    FThreads: array[0..cDispenser_MaxThread-1] of TDispenserThread;
    //读卡对象
    FOnProc: TDispenserProc;
    FOnEvent: TDispenserEvent;
    //事件定义
  protected
    procedure ClearDispensers(const nFree: Boolean);
    //清理资源
    procedure CloseDispenser(const nDispenser: PDispenserItem);
    //关闭设备
    function SyncCardNo(const nDispenser: PDispenserItem; const nSet: Boolean;
      const nCard: string = ''): string;
    //同步读写卡号
    function SyncCommand(const nDispenser: PDispenserItem; const nSet: Boolean;
      const nCMD: string = ''): string;
    //同步读写指令
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //载入配置
    procedure StartDispensers;
    procedure StopDispensers;
    //启停设备
    function FindDispenser(const nID: string): PDispenserItem;
    //检索设备
    function GetCardNo(const nID:string; var nHint: string;
      const nWaitFor: Boolean = True;
      const nTimeout: Integer = cDispenser_Wait_Timeout): string;
    //获得卡号
    function SendCardOut(const nID: string; var nHint: string):Boolean;
    //发卡
    function RecoveryCard(const nID: string; var nHint: string):Boolean;
    //回收卡
    property OnCardProc: TDispenserProc read FOnProc write FOnProc;
    property OnCardEvent: TDispenserEvent read FOnEvent write FOnEvent;
    //属性相关
  end;

var
  gDispenserManager: TDispenserManager = nil;
  //全局使用

implementation

const
  cFrameSize_Send     = SizeOf(TDispenserK7Send);
  cFrameSize_Recv     = SizeOf(TDispenserK7Recv);   //帧大小

  cTTCE_K7_STX        = $02;                        //块起始符
  cTTCE_K7_ETX        = $03;                        //块结束符
  cTTCE_K7_EOT        = $04;                        //取消命令
  cTTCE_K7_ENQ        = $05;                        //执行命令请求
  cTTCE_K7_ACK        = $06;                        //肯定应答
  cTTCE_K7_NAK        = $15;                        //否定应答

  cTTCE_K7_Success    = 'P';                        //命令执行成功
  cTTCE_K7_Failure    = 'N';                        //命令执行失败

  cTTCE_K7_PosNew     = $01;                        //新卡已准备好
  cTTCE_K7_PosRead    = $02;                        //卡片在读卡位
  cTTCE_K7_PosOut     = $03;                        //卡片在出卡口
  cTTCE_K7_NewError   = $11;                        //准备卡失败
  cTTCE_K7_KXNoCard   = $12;                        //卡箱卡片为空
  cTTCE_K7_TDNoCard   = $13;                        //通道卡片为空
  cTTCE_K7_CardJam    = $14;                        //卡片阻塞(卡箱满)

  cCMD_RecoveryCard   = 'RC';                       //回收卡片
  cCMD_CardOut        = 'CO';                       //发卡到出卡口

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TDispenserManager, '自助卡机管理器', nEvent);
end;

procedure LogHex(const nData: TIdBytes; const nPrefix: string = '');
var nStr: string;
    nIdx: Integer;
begin
  nStr := '';
  for nIdx:=Low(nData) to High(nData) do
    nStr := nStr + IntToHex(nData[nIdx], 2) + ' ';
  WriteLog(nPrefix + nStr);
end;

//------------------------------------------------------------------------------
constructor TDispenserManager.Create;
var nIdx: Integer;
begin
  FEnable := False;
  for nIdx:=Low(FThreads) to High(FThreads) do
    FThreads[nIdx] := nil;
  //xxxxx

  FDispensers := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TDispenserManager.Destroy;
begin
  StopDispensers;
  ClearDispensers(True);

  FSyncLock.Free;
  inherited;
end;

//Date: 2018-11-23
//Parm: 释放列表
//Desc: 清理设备列表
procedure TDispenserManager.ClearDispensers(const nFree: Boolean);
var nIdx: Integer;
    nItem: PDispenserItem;
begin
  for nIdx:=FDispensers.Count - 1 downto 0 do
  begin
    nItem := FDispensers[nIdx];
    if Assigned(nItem.FCOMPort) then
    begin
      nItem.FCOMPort.Close;
      FreeAndNil(nItem.FCOMPort);
    end;

    if Assigned(nItem.FClient) then
    begin
      nItem.FClient.Disconnect;
      FreeAndNil(nItem.FClient);
    end;

    FreeAndNil(nItem.FOptions);
    Dispose(nItem);
    FDispensers.Delete(nIdx);
  end;

  if nFree then
    FDispensers.Free;
  //xxxxx
end;

//Date: 2018-11-23
//Parm: 设备
//Desc: 关闭nDispenser的连接
procedure TDispenserManager.CloseDispenser(const nDispenser: PDispenserItem);
begin
  if Assigned(nDispenser) then
  begin
    if Assigned(nDispenser.FClient) then
    begin
      nDispenser.FClient.Disconnect;
      if Assigned(nDispenser.FClient.IOHandler) then
        nDispenser.FClient.IOHandler.InputBuffer.Clear;
      //xxxxx
    end;

    if Assigned(nDispenser.FCOMPort) then
    begin
      nDispenser.FCOMPort.Connected := False;
      //disconn comport
    end;
  end;
end;

//Date: 2018-11-23
//Desc: 启动设备
procedure TDispenserManager.StartDispensers;
var nIdx,nInt,nNum: Integer;
    nType: TDispenserThreadType;
begin
  if not FEnable then Exit;
  FDispenserIndex := 0;
  FDispenserActive := 0;
  
  nInt := 0;
  for nIdx:=FDispensers.Count-1 downto 0 do
   if PDispenserItem(FDispensers[nIdx]).FEnable then
    Inc(nInt);
  //统计有效设备个数

  nNum := 0;
  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if (nNum >= FThreadCount) or (nNum >= nInt) then Exit;
    //线程不能超过预定值,或不多于设备个数

    if nNum < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FThreads[nIdx]) then
      FThreads[nIdx] := TDispenserThread.Create(Self, nType);
    Inc(nNum);
  end;
end;

//Date: 2018-11-23
//Desc: 停止设备
procedure TDispenserManager.StopDispensers;
var nIdx: Integer;
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

  FSyncLock.Enter;
  try
    for nIdx:=FDispensers.Count - 1 downto 0 do
      CloseDispenser(FDispensers[nIdx]);
    //关闭设备
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2018-11-26
//Parm: 设备;设置 or 读取;卡号
//Desc: 同步操作当前设备的卡号
function TDispenserManager.SyncCardNo(const nDispenser: PDispenserItem;
  const nSet: Boolean; const nCard: string): string;
begin
  FSyncLock.Enter;
  try
    if nSet then
         nDispenser.FNowCard := nCard
    else Result := nDispenser.FNowCard;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2018-11-27
//Parm: 设备;设置 or 读取;指令
//Desc: 同步操作当前设备的指令
function TDispenserManager.SyncCommand(const nDispenser: PDispenserItem;
  const nSet: Boolean; const nCMD: string): string;
begin
  FSyncLock.Enter;
  try
    if nSet then
         nDispenser.FLastCMD := nCMD
    else Result := nDispenser.FLastCMD;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2018-11-27
//Parm: 设备号
//Desc: 检索设备号为nID的设备
function TDispenserManager.FindDispenser(const nID: string): PDispenserItem;
var nIdx: Integer;
begin
  Result := nil;
  //init
  
  for nIdx:=FDispensers.Count-1 downto 0 do
  if CompareText(PDispenserItem(FDispensers[nIdx]).FID, nID) = 0 then
  begin
    Result := FDispensers[nIdx];
    Break;
  end;
end;

//Date: 2018-11-26
//Parm: 设备号;提示;是否等待;超时时间
//Desc: 读取nID当前的卡号
function TDispenserManager.GetCardNo(const nID: string; var nHint: string;
  const nWaitFor: Boolean; const nTimeout: Integer): string;
var nInit: Int64;
    nDispenser: PDispenserItem;
begin
  Result := '';
  nHint := '';
  nDispenser := FindDispenser(nID);

  if not Assigned(nDispenser) then
  begin
    nHint := Format('标识为[ %s ]的设备不存在.', [nID]);
    WriteLog(nHint);
    Exit;
  end;

  if not nWaitFor then
  begin
    Result := SyncCardNo(nDispenser, False);
    Exit;
  end;

  nInit := GetTickCount();
  while GetTickCountDiff(nInit) <= nTimeout do
  begin
    Result := SyncCardNo(nDispenser, False);
    if Result = '' then
         Sleep(1)
    else Break;
  end;

  if Result = '' then
  begin
    nHint := Format('读取设备[ %s ]的卡号超时.', [nID]);
    WriteLog(nHint);
  end;
end;

//Date: 2018-11-27
//Parm: 设备号;提示;超时
//Desc: 回收表示为nID的卡片
function TDispenserManager.RecoveryCard(const nID: string; var nHint: string): Boolean;
var nDispenser: PDispenserItem;
begin
  Result := False;
  nHint := '';
  nDispenser := FindDispenser(nID);

  if not Assigned(nDispenser) then
  begin
    nHint := Format('标识为[ %s ]的设备不存在.', [nID]);
    WriteLog(nHint);
    Exit;
  end;

  SyncCommand(nDispenser, True, cCMD_RecoveryCard);
  //设置指令
  Result := True;
end;

function TDispenserManager.SendCardOut(const nID: string; var nHint: string): Boolean;
var nDispenser: PDispenserItem;
begin
  Result := False;
  nHint := '';
  nDispenser := FindDispenser(nID);

  if not Assigned(nDispenser) then
  begin
    nHint := Format('标识为[ %s ]的设备不存在.', [nID]);
    WriteLog(nHint);
    Exit;
  end;

  SyncCommand(nDispenser, True, cCMD_CardOut);
  //设置指令
  Result := True;
end;

//Date: 2018-11-23
//Parm: 配置文件
//Desc: 载入nFile配置
procedure TDispenserManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;
    nDispenser: PDispenserItem;
    nRoot,nNode,nTmp: TXmlNode;
begin
  FEnable := False;
  if not FileExists(nFile) then Exit;

  nXML := nil;
  try
    nXML := TNativeXml.Create;
    nXML.LoadFromFile(nFile);

    nRoot := nXML.Root.NodeByName('config');
    if Assigned(nRoot) then
    begin
      nNode := nRoot.NodeByName('enable');
      if Assigned(nNode) then
        Self.FEnable := nNode.ValueAsString <> 'N';
      //xxxxx

      nNode := nRoot.NodeByName('thread');
      if Assigned(nNode) then
           FThreadCount := nNode.ValueAsInteger
      else FThreadCount := 1;

      if (FThreadCount < 1) or (FThreadCount > cDispenser_MaxThread) then
        raise Exception.Create(Format(
          'TTCE_Driver Thread-Num Need Between 1-%d.', [cDispenser_MaxThread]));
      //xxxxx

      nNode := nRoot.NodeByName('monitor');
      if Assigned(nNode) then
           FMonitorCount := nNode.ValueAsInteger
      else FMonitorCount := 1;

      if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
        raise Exception.Create(Format(
          'TTCE_Driver Monitor-Num Need Between 1-%d.', [FThreadCount]));
      //xxxxx
    end;

    //--------------------------------------------------------------------------
    nRoot := nXML.Root.NodeByName('dispensers');
    if not Assigned(nRoot) then Exit;
    ClearDispensers(False);

    for nIdx:=0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText(nNode.Name, 'dispenser') <> 0 then Continue;

      New(nDispenser);
      FDispensers.Add(nDispenser);

      with nNode,nDispenser^ do
      begin
        FLocked := False;
        FLastActive := GetTickCount;
        FNowCard := '';
        
        FLastSend := 0;
        FStatusKeep := 0;
        FLastStatus := DateTimeSerial;

        FID := AttributeByName['id']; 
        FEnable := NodeByNameR('enable').ValueAsString <> 'N';
        FHost := NodeByNameR('hostip').ValueAsString;
        FPort := NodeByNameR('hostport').ValueAsInteger;
        FTimeout := NodeByNameR('timeout').ValueAsInteger;

        nTmp := NodeByNameR('param');
        FAddH := StrToInt('$' + nTmp.AttributeByName['H']);
        FAddL := StrToInt('$' + nTmp.AttributeByName['L']);

        if CompareText(nTmp.AttributeByName['type'], 'receiver') = 0 then
             FType := dtReceiver
        else FType := dtSender;

        nTmp := NodeByName('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;

        //----------------------------------------------------------------------
        if CompareText('com', NodeByNameR('conn').ValueAsString) = 0 then
             FConn := ctCOM
        else FConn := ctTCP;
        
        if FConn = ctTCP then
        begin
          FCOMPort := nil;
          FClient := TIdTCPClient.Create;
          
          with FClient do
          begin
            Host := FHost;
            Port := FPort;
            ReadTimeout := 3 * 1000;
            ConnectTimeout := 3 * 1000;
          end;
        end else
        begin
          FClient := nil;
          FCOMPort := TComPort.Create(nil);
          FCOMPort.SyncMethod := smDisableEvents; //不使用事件,顺序读写
          
          with FCOMPort do
          begin
            with Timeouts do
            begin
              ReadTotalConstant := 100;
              ReadTotalMultiplier := 10;
            end;

            with Parity do
            begin
              Bits := StrToParity(NodeByNameR('paritybit').ValueAsString);
              Check := NodeByNameR('paritycheck').ValueAsString = 'Y';
            end;

            Port := NodeByNameR('comport').ValueAsString;
            BaudRate := StrToBaudRate(NodeByNameR('rate').ValueAsString);
            DataBits := StrToDataBits(NodeByNameR('databit').ValueAsString);
            StopBits := StrToStopBits(NodeByNameR('stopbit').ValueAsString);
          end;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TDispenserThread.Create(AOwner: TDispenserManager;
  AType: TDispenserThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cDispenser_Wait_Short;
end;

destructor TDispenserThread.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TDispenserThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TDispenserThread.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveDispenser := nil;
    try
      DoExecute;
    finally
      if Assigned(FActiveDispenser) then
      begin
        FOwner.FSyncLock.Enter;
        FActiveDispenser.FLocked := False;
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

procedure TDispenserThread.DoExecute;
begin
  FOwner.FSyncLock.Enter;
  try
    if FThreadType = ttAll then
    begin
      ScanActiveDispenser(False);
      //优先扫描不活动设备

      if not Assigned(FActiveDispenser) then
        ScanActiveDispenser(True);
      //辅助扫描活动设备
    end else

    if FThreadType = ttActive then //只扫活动线程
    begin
      ScanActiveDispenser(True);
      //优先扫描活动设备

      if Assigned(FActiveDispenser) then
      begin
        FWaiter.Interval := cDispenser_Wait_Short;
        //有活动设备,加速
      end else
      begin
        FWaiter.Interval := cDispenser_Wait_Long;
        //无活动设备,降速
        ScanActiveDispenser(False);
        //辅助扫描不活动设备
      end;
    end;
  finally
    FOwner.FSyncLock.Leave;
  end;

  if Assigned(FActiveDispenser) and (not Terminated) then
  try
    if PrepareCard(FActiveDispenser) then
    begin
      if FThreadType = ttActive then
        FWaiter.Interval := cDispenser_Wait_Short;
      FActiveDispenser.FLastActive := GetTickCount;
    end else
    begin
      if (FActiveDispenser.FLastActive > 0) and
         (GetTickCountDiff(FActiveDispenser.FLastActive) >= 5 * 1000) then
        FActiveDispenser.FLastActive := 0;
      //无需准备卡片时,自动转为不活动
    end;
  except
    on E:Exception do
    begin
      FActiveDispenser.FLastActive := 0;
      //置为不活动

      if FActiveDispenser.FConn = ctCOM then
       WriteLog(Format('Dispenser:[ %s:%s ] Msg: %s', [FActiveDispenser.FID,
        FActiveDispenser.FCOMPort.Port, E.Message]))
      else
       WriteLog(Format('Dispenser:[ %s:%d ] Msg: %s', [FActiveDispenser.FHost,
        FActiveDispenser.FPort, E.Message]));
      //xxxxx

      FOwner.CloseDispenser(FActiveDispenser);
      //focus reconnect
    end;
  end;
end;

//Date: 2018-11-23
//Parm: 活动&不活动项
//Desc: 扫描nActive项,若可用存入FActiveDispenser.
procedure TDispenserThread.ScanActiveDispenser(const nActive: Boolean);
var nIdx: Integer;
    nDispenser: PDispenserItem;
begin
  if nActive then //扫描活动项
  with FOwner do
  begin
    if FDispenserActive = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FDispenserActive >= FDispensers.Count then
      begin
        FDispenserActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nDispenser := FDispensers[FDispenserActive];
      Inc(FDispenserActive);
      if nDispenser.FLocked or (not nDispenser.FEnable) then Continue;

      if nDispenser.FLastActive > 0 then 
      begin
        FActiveDispenser := nDispenser;
        FActiveDispenser.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //扫描不活动项
  begin
    if FDispenserIndex = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FDispenserIndex >= FDispensers.Count then
      begin
        FDispenserIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nDispenser := FDispensers[FDispenserIndex];
      Inc(FDispenserIndex);
      if nDispenser.FLocked or (not nDispenser.FEnable) then Continue;

      if nDispenser.FLastActive = 0 then 
      begin
        FActiveDispenser := nDispenser;
        FActiveDispenser.FLocked := True;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2018-11-23
//Parm: 发卡机
//Desc: 将nDispenser中的卡片发至读卡位,为出卡做准备
function TDispenserThread.PrepareCard(const nDispenser: PDispenserItem): Boolean;
var nStr,nStatus: string;
begin
  Result := True;
  nStatus := QueryStatuse();

  if (not HasStatus(nStatus, cTTCE_K7_PosRead)) and
     (FActiveDispenser.FNowCard <> '') then
    FOwner.SyncCardNo(nDispenser, True, '');
  //卡不在读卡位,清空卡号

  if HasStatus(nStatus, cTTCE_K7_PosNew) then
  begin
    if SendCardToReadPosition() then //发到读卡位
     if GetCardSerial() = '' then    //读取卡号
      RecoveryCard();                //不成功则收卡
    //xxxxx
  end; //卡在传感器3位置,新卡就位

  if (HasStatus(nStatus, cTTCE_K7_PosRead)) and
     (FActiveDispenser.FNowCard = '') then
  begin
    if GetCardSerial() = '' then    //读取卡号
      RecoveryCard();               //不成功则收卡
    //xxxxx
  end; //卡在读卡位且卡号为空,重新读卡
  
  if (nDispenser.FStatusKeep > 0) and //某个状态保持时间过长
     (GetTickCountDiff(nDispenser.FStatusKeep) >= nDispenser.FTimeout * 1000) then
  begin
    if nDispenser.FLastStatus = '' then
    begin
      nDispenser.FStatusKeep := 0;
      nDispenser.FLastStatus := DateTimeSerial;
      ResetDispenser();           

      WriteLog(Format('主机[ %s ]无法获取状态,已重置.', [nDispenser.FID]));
      Exit;
    end;

    if HasStatus(nDispenser.FLastStatus, cTTCE_K7_NewError) then
    begin
      nDispenser.FStatusKeep := 0;
      nDispenser.FLastStatus := DateTimeSerial;
      ResetDispenser();

      WriteLog(Format('主机[ %s ]准备卡失败,已重置.', [nDispenser.FID]));
      Exit;
    end; //准备卡失败

    if HasStatus(nDispenser.FLastStatus, cTTCE_K7_PosOut) then
    begin
      RecoveryCard();
      WriteLog(Format('主机[ %s ]超时未取,已收回.', [nDispenser.FID]));
    end; //出卡处有卡

    if HasStatus(nDispenser.FLastStatus, cTTCE_K7_CardJam) then
    begin
      ResetDispenser();
      WriteLog(Format('主机[ %s ]卡片拥堵或卡箱满,尝试重置.', [nDispenser.FID]));
    end; //卡箱满,出卡拥堵
  end;

  if nStatus <> nDispenser.FLastStatus then Exit;
  //状态已变更
  nStr := FOwner.SyncCommand(FActiveDispenser, False);

  if nStr = cCMD_RecoveryCard then
  begin
    if HasStatus(nStatus, cTTCE_K7_PosRead) or
       HasStatus(nStatus, cTTCE_K7_PosOut) then
      RecoveryCard();
    //执行收卡

    if not (HasStatus(nDispenser.FLastStatus, cTTCE_K7_PosRead) or
            HasStatus(nDispenser.FLastStatus, cTTCE_K7_PosOut)) then
      FOwner.SyncCommand(FActiveDispenser, True, '');
    //xxxxx
  end else

  if nStr = cCMD_CardOut then
  begin
    if HasStatus(nStatus, cTTCE_K7_PosRead) then
      SendCardOut();
    //执行发卡

    if not HasStatus(nDispenser.FLastStatus, cTTCE_K7_PosRead) then
      FOwner.SyncCommand(FActiveDispenser, True, '');
    //xxxxx
  end else

  if nStr <> '' then
  begin
    FOwner.SyncCommand(FActiveDispenser, True, '');
    //不可识别的指令,直接清空
  end;
end;

//Date: 2018-11-23
//Parm: 发送帧;命令
//Desc: 依据FActiveDispenser初始化nData数据
procedure TDispenserThread.InitSendData(const nData: PDispenserK7Send;
  const nCMD: string);
var nIdx,nBase: Integer;
begin
  FillChar(nData^, cFrameSize_Send, #0);
  nData.FSTX := cTTCE_K7_STX;
  nData.FETX := cTTCE_K7_ETX;

  nData.FADDH := FActiveDispenser.FAddH;
  nData.FADDL := FActiveDispenser.FAddL;
  nData.FLen := Length(nCMD);

  if nData.FLen > cTTCE_Frame_DataMax then
   raise Exception.Create(Format(
    'Data Is Too Big Than %d.', [cTTCE_Frame_DataMax]));
  //xxxxx

  if nData.FLen > 0 then
  begin
    nBase := 1;
    for nIdx:=Low(nData.FData) to High(nData.FData) do
    begin
      nData.FData[nIdx] := nCMD[nBase];
      Inc(nBase);
      if nBase > nData.FLen then Break;
    end;
  end;
end;

//Date: 2018-11-23
//Parm: 缓冲;开始,结束位置
//Desc: 计算nBuf的BCC异或校验值
function CalBBC(const nBuf: TIdBytes; const nStart,nEnd: Integer): Byte;
var nIdx: Integer;
begin
  Result := 0;
  for nIdx:=nStart to nEnd do
    Result := Result xor nBuf[nIdx];
  //xxxxx
end;

//Date: 2018-11-23
//Parm: 发送帧
//Desc: 将nData转为发送缓冲,并计算校验值
function TDispenserThread.SendData2Bytes(const nData: PDispenserK7Send): TIdBytes;
var nLen: Integer;
begin
  nLen := cFrameSize_Send - (cTTCE_Frame_DataMax - nData.FLen);
  //有效数据 = 总数 - 无效

  Result := RawToBytes(nData^, nLen);
  Result[3] := nData.FLen div 256;
  Result[4] := nData.FLen mod 256; //数据长度: 高低位处理

  Result[nLen - 2] := nData.FETX;
  Result[nLen - 1] := CalBBC(Result, 0, nLen - 2);
end;

//Date: 2018-11-28
//Parm: 待读取的长度
//Desc: 从串口读取读取nLen长度的数据
function TDispenserThread.ReadCOMData(nLen: Integer): Boolean;
var nInit: Int64;
    nInt: Integer;
begin
  nInit := GetTickCount;
  while (nLen > 0) and (GetTickCountDiff(nInit) < cDispenser_Wait_Timeout) do
  begin
    FActiveDispenser.FCOMBuff := '';
    FActiveDispenser.FCOMPort.ReadStr(FActiveDispenser.FCOMBuff, nLen);
    nInt := Length(FActiveDispenser.FCOMBuff);

    if nInt > 0 then
    begin
      nLen := nLen - nInt;
      FActiveDispenser.FCOMData := FActiveDispenser.FCOMData +
                                   FActiveDispenser.FCOMBuff;
      //合并数据
    end;
  end;

  Result := nLen <= 0;
  if not Result then
   WriteLog(Format('主机[ %s,%s ]读取数据失败.', [FActiveDispenser.FID,
    FActiveDispenser.FCOMPort.Port]));
  //xxxxx
end;

//Date: 2018-11-29
//Parm: 接收数据
//Desc: 记录nRecv描述的错误日志
procedure TDispenserThread.WriteRecvError(const nRecv: PDispenserK7Recv);
var nStr,nCode: string;
    nIdx,nInt: Integer;
begin
  if nRecv.FRes = cTTCE_K7_Failure then
  begin
    nCode := '';
    nInt := nRecv.FLen - 3; //ERR_CD长度

    for nIdx:=2 to cTTCE_Frame_DataMax - 1 do
    begin
      if (nInt <= 0) or
         (nRecv.FData[nIdx] = Char(cTTCE_K7_ETX)) then Break;
      nCode := nCode + IntToHex(Ord(nRecv.FData[nIdx]), 2);

      Dec(nInt);
      if nInt > 0 then nCode := nCode + '-';
    end;

    nStr := '主机[ %s ]执行失败,描述: CM:%s PM:%s CODE:%s.';
    nStr := Format(nStr, [FActiveDispenser.FID,
            IntToHex(Ord(nRecv.FData[0]), 2),
            IntToHex(Ord(nRecv.FData[1]), 2), nCode]);
    WriteLog(nStr);
  end;
end;

//Date: 2018-11-23
//Parm: 发送帧;接收帧
//Desc: 发送nSend数据,接收后存入nRecv,应答模式
function TDispenserThread.SendWithResponse(const nSend: PDispenserK7Send;
  const nRecv: PDispenserK7Recv): Boolean;
var nStr: string;
    nBuf: TIdBytes;
    nItv: Int64;
    nIdx,nLen: Integer;
begin
  with FActiveDispenser.FClient,FActiveDispenser.FCOMPort do
  begin
    if FActiveDispenser.FConn = ctCOM then
    begin
      if not FActiveDispenser.FCOMPort.Connected then
        FActiveDispenser.FCOMPort.Connected := True;
      Result := False;
    end else
    begin
      if not FActiveDispenser.FClient.Connected then
        FActiveDispenser.FClient.Connect;
      Result := False;
    end;
    
    nItv := GetTickCountDiff(FActiveDispenser.FLastSend);
    nItv := cTTCE_Frame_SendInterval - nItv;
    if nItv > 0 then Sleep(nItv); //限制发送速度
    FActiveDispenser.FLastSend := GetTickCount();

    if FActiveDispenser.FConn = ctCOM then
    begin
      nBuf := SendData2Bytes(nSend);
      Write(@nBuf[0], Length(nBuf));

      FActiveDispenser.FCOMData := '';
      if not ReadCOMData(3) then Exit;
      nBuf := ToBytes(FActiveDispenser.FCOMData);
    end else
    begin
      Socket.Write(SendData2Bytes(nSend));
      SetLength(nBuf, 0);
      Socket.ReadBytes(nBuf, 3, False);
    end;

    if (nBuf[1] <> FActiveDispenser.FAddH) or
       (nBuf[2] <> FActiveDispenser.FAddL) then
    begin
      nStr := Format('主机[ %s ]应答地址错误.', [FActiveDispenser.FID]);
      WriteLog(nStr);
      Exit;
    end;

    case nBuf[0] of
     cTTCE_K7_EOT:
      nStr := Format('主机[ %s ]取消命令.', [FActiveDispenser.FID]);
     cTTCE_K7_NAK:
      nStr := Format('主机[ %s ]否定应答.', [FActiveDispenser.FID]);
     cTTCE_K7_ACK:
      nStr := ''
     else
      begin
        nStr := '主机[ %s ]应答不可识别,应答码:[ %d ].';
        nStr := Format(nStr, [FActiveDispenser.FID, nBuf[0]]);
      end;
    end;

    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    nBuf[0] := cTTCE_K7_ENQ;
    if FActiveDispenser.FConn = ctCOM then
    begin
      Write(@nBuf[0], 3);
      FActiveDispenser.FCOMData := '';
      
      if not ReadCOMData(5) then Exit;
      nBuf := ToBytes(FActiveDispenser.FCOMData, Indy8BitEncoding);
    end else
    begin
      Socket.Write(nBuf); //确认执行
      SetLength(nBuf, 0);
      Socket.ReadBytes(nBuf, 5, False);
    end; 

    if (nBuf[0] <> cTTCE_K7_STX) or (nBuf[1] <> FActiveDispenser.FAddH) or
       (nBuf[2] <> FActiveDispenser.FAddL) then
    begin
      nStr := '主机[ %s ]应答不可识别,应答码:[ %d,%d,%d ].';
      nStr := Format(nStr, [FActiveDispenser.FID, nBuf[0], nBuf[1], nBuf[2]]);
      
      WriteLog(nStr);
      Exit;
    end;

    nLen := nBuf[3] * 265 + nBuf[4]; //数据负载长度
    if FActiveDispenser.FConn = ctCOM then
    begin
      if not ReadCOMData(nLen + 2) then Exit;
      nBuf := ToBytes(FActiveDispenser.FCOMData, Indy8BitEncoding);
    end else
    begin
      Socket.ReadBytes(nBuf, nLen + 2, True);
    end;
    
    nIdx := Length(nBuf);
    Result := nBuf[nIdx-1] = CalBBC(nBuf, 0, nIdx-2);
    //通过验证
    
    if not Result then
    begin
      nStr := Format('主机[ %s ]应答校验失败.', [FActiveDispenser.FID]);
      WriteLog(nStr);
      Exit;
    end;

    if Assigned(nRecv) then
    begin
      BytesToRaw(nBuf, nRecv^, nIdx);
      nRecv.FLen := nLen;
      nRecv.FETX := nBuf[nIdx-2];
      nRecv.FBCC := nBuf[nIdx-1];

      WriteRecvError(nRecv);
      //记录错误日志
    end;

    FActiveDispenser.FLastSend := GetTickCount();
    //重新计算下次发送间隔
  end;
end;

//Date: 2018-11-24
//Parm: 发送帧;接收帧
//Desc: 发送nSend数据,无需应答
function TDispenserThread.SendToDispenser(const nSend: PDispenserK7Send): Boolean;
var nStr: string;
    nBuf: TIdBytes;
    nItv: Int64;
begin
  with FActiveDispenser.FClient,FActiveDispenser.FCOMPort do
  begin
    if FActiveDispenser.FConn = ctCOM then
    begin
      if not FActiveDispenser.FCOMPort.Connected then
        FActiveDispenser.FCOMPort.Connected := True;
      Result := False;
    end else
    begin
      if not FActiveDispenser.FClient.Connected then
        FActiveDispenser.FClient.Connect;
      Result := False;
    end;

    nItv := GetTickCountDiff(FActiveDispenser.FLastSend);
    nItv := cTTCE_Frame_SendInterval - nItv;
    if nItv > 0 then Sleep(nItv); //限制发送速度
    FActiveDispenser.FLastSend := GetTickCount();

    if FActiveDispenser.FConn = ctCOM then
    begin
      nBuf := SendData2Bytes(nSend);
      Write(@nBuf[0], Length(nBuf));

      FActiveDispenser.FCOMData := '';
      if not ReadCOMData(3) then Exit;
      nBuf := ToBytes(FActiveDispenser.FCOMData, Indy8BitEncoding);
    end else
    begin
      Socket.Write(SendData2Bytes(nSend));
      SetLength(nBuf, 0);
      Socket.ReadBytes(nBuf, 3, False);
    end;

    if (nBuf[1] <> FActiveDispenser.FAddH) or
       (nBuf[2] <> FActiveDispenser.FAddL) then
    begin
      nStr := Format('主机[ %s ]应答地址错误.', [FActiveDispenser.FID]);
      WriteLog(nStr);
      Exit;
    end;

    case nBuf[0] of
     cTTCE_K7_EOT:
      nStr := Format('主机[ %s ]取消命令.', [FActiveDispenser.FID]);
     cTTCE_K7_NAK:
      nStr := Format('主机[ %s ]否定应答.', [FActiveDispenser.FID]);
     cTTCE_K7_ACK:
      nStr := ''
     else
      begin
        nStr := '主机[ %s ]应答不可识别,应答码:[ %d ].';
        nStr := Format(nStr, [FActiveDispenser.FID, nBuf[0]]);
      end;
    end;

    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    nBuf[0] := cTTCE_K7_ENQ;
    if FActiveDispenser.FConn = ctCOM then
         Write(@nBuf[0], 3)
    else Socket.Write(nBuf); //确认执行

    FActiveDispenser.FLastSend := GetTickCount();
    //重新计算下次发送间隔
    Result := True;
  end;
end;

//Date: 2018-11-23
//Desc: 查询nDispenser的设备状态
function TDispenserThread.QueryStatuse: string;
var nSend: TDispenserK7Send;
    nRecv: TDispenserK7Recv;
begin
  Result := '';
  InitSendData(@nSend, Char($41) + Char($50));
  if not (SendWithResponse(@nSend, @nRecv) and (nRecv.FLen = 6)) then Exit;

  Result := Copy(nRecv.FData, 2, 4);
  //复制4位状态码

  if Length(Result) <> 4 then
    Result := '';
  //xxxxx

  if Result <> FActiveDispenser.FLastStatus then
  begin
    FActiveDispenser.FLastStatus := Result;
    FActiveDispenser.FStatusKeep := GetTickCount;
  end;
end;

//Date: 2018-11-27
//Parm: 全部状态;状态码
//Desc: 查询nAll中是否包含nStatus状态
function TDispenserThread.HasStatus(const nALL: string;
  const nStatus: Integer): Boolean;
begin
  Result := False;
  if nALL = '' then Exit;

  case nStatus of
   cTTCE_K7_PosNew    : Result :=(StrToInt(nALL[4]) and $04 = $04) or
                                 (StrToInt(nALL[4]) and $0F = $02);
   cTTCE_K7_PosRead   : Result := StrToInt(nALL[4]) and $03 = $03;
   cTTCE_K7_PosOut    : Result :=(StrToInt(nALL[4]) and $01 = $01) and
                                 (StrToInt(nALL[4]) and $02 <> $02);
   cTTCE_K7_NewError  : Result := StrToInt(nALL[1]) and $02 = $02;
   cTTCE_K7_KXNoCard  : Result := StrToInt(nALL[3]) and $01 = $01;
   cTTCE_K7_TDNoCard  : Result := StrToInt(nALL[4]) and $08 = $08;
   cTTCE_K7_CardJam   : Result :=(StrToInt(nALL[2]) and $01 = $01) and
                                 (StrToInt(nALL[3]) and $02 = $02);
  end;
end;

//Date: 2018-11-24
//Desc: 将卡片发到读卡位置
function TDispenserThread.SendCardToReadPosition: Boolean;
var nStr: string;
    nInit: Int64;
    nSend: TDispenserK7Send;
begin
  Result := False;
  InitSendData(@nSend, Char($46) + Char($43) + Char($37));
  if not SendToDispenser(@nSend) then Exit;

  nStr := '';
  nInit := GetTickCount();
  
  while GetTickCountDiff(nInit) < cDispenser_Wait_Timeout do
  begin
    nStr := QueryStatuse();
    if HasStatus(nStr, cTTCE_K7_PosRead) then //卡已发到读卡位
    begin
      Result := True;
      Exit;
    end;
  end;

  if nStr <> '' then
  begin
    WriteLog(Format('主机[ %s ]无法将卡发到读卡位,错误码: %s.',
      [FActiveDispenser.FID, nStr]));
    //xxxxx
  end;
end;

//Date: 2018-11-26
//Parm: 16位卡号数据
//Desc: 格式化nCard为标准卡号
function TDispenserThread.ParseCardNO(const nCard: string;
  const nHex: Boolean): string;
var nInt: Int64;
    nIdx: Integer;
begin
  if nHex then
  begin
    Result := '';
    for nIdx:=Length(nCard) downto 1 do
      Result := Result + IntToHex(Ord(nCard[nIdx]), 2);
    //xxxxx
  end else Result := nCard;

  try
    nInt := StrToInt64('$' + Result);
    Result := IntToStr(nInt);
    Result := StringOfChar('0', 12 - Length(Result)) + Result;
  except
    on nErr: Exception do
    begin
      Result := '';
      WriteLog(Format('主机[ %s ]无法解析卡号,描述: %s.',
        [FActiveDispenser.FID, nErr.Message]));
      //xxxxx
    end;
  end;
end;

//Date: 2018-11-26
//Desc: 读取卡号
function TDispenserThread.GetCardSerial: string;
var nIdx: Integer;
    nBool: Boolean;
    nSend: TDispenserK7Send;
    nRecv: TDispenserK7Recv;
begin
  Result := '';
  InitSendData(@nSend, Char($3C) + Char($30));

  for nIdx:=1 to 2 do
  begin
    nBool := SendWithResponse(@nSend, @nRecv) and
             (nRecv.FRes = cTTCE_K7_Success);
    //寻卡

    if nBool then
         Break
    else Sleep(cTTCE_Frame_SendInterval);
  end;

  if not nBool then Exit;
  InitSendData(@nSend, Char($3C) + Char($31));
  
  for nIdx:=1 to 2 do
  begin
    nBool := SendWithResponse(@nSend, @nRecv) and
             (nRecv.FRes = cTTCE_K7_Success);
    //读卡

    if nBool then
         Break
    else Sleep(cTTCE_Frame_SendInterval);
  end;

  if not nBool then Exit;
  Result:= Copy(nRecv.FData, 3, 4);
  //复制4位卡号
  Result := ParseCardNO(Result, True);
  //格式化卡号

  FOwner.SyncCardNo(FActiveDispenser, True, Result);
  if Assigned(FOwner.FOnProc) then FOwner.FOnProc(FActiveDispenser);
  if Assigned(FOwner.FOnEvent) then FOwner.FOnEvent(FActiveDispenser);
end;

//Date: 2018-11-24
//Desc: 将卡片发到取卡位置
function TDispenserThread.SendCardOut: Boolean;
var nStr: string;
    nInit: Int64;
    nSend: TDispenserK7Send;
begin
  Result := False;
  FOwner.SyncCardNo(FActiveDispenser, True, '');
  //置空卡号
  
  InitSendData(@nSend, Char($46) + Char($43) + Char($34));
  if not SendToDispenser(@nSend) then Exit;

  nStr := '';
  nInit := GetTickCount();
  
  while GetTickCountDiff(nInit) < cDispenser_Wait_Timeout do
  begin
    nStr := QueryStatuse();
    if HasStatus(nStr, cTTCE_K7_PosOut) then //卡已发到取卡位
    begin
      Result := True;
      Exit;
    end;
  end;

  if nStr <> '' then
  begin
    WriteLog(Format('主机[ %s ]无法将卡发到取卡位,错误码: %s.',
      [FActiveDispenser.FID, nStr]));
    //xxxxx
  end;
end;

//Date: 2018-11-24
//Desc: 将卡片收到回收箱
function TDispenserThread.RecoveryCard: Boolean;
var nStr: string;
    nInit: Int64;
    nSend: TDispenserK7Send;
begin
  Result := False;
  FOwner.SyncCardNo(FActiveDispenser, True, '');
  //置空卡号

  InitSendData(@nSend, Char($43) + Char($50));
  if not SendToDispenser(@nSend) then Exit;

  nStr := '';
  nInit := GetTickCount();

  while GetTickCountDiff(nInit) < cDispenser_Wait_Timeout do
  begin
    nStr := QueryStatuse();
    if HasStatus(nStr, cTTCE_K7_TDNoCard) or
       HasStatus(nStr, cTTCE_K7_PosNew) then //新卡已准备好,或通道无卡
    begin
      Result := True;
      Exit;
    end;
  end;

  if nStr <> '' then
  begin
    WriteLog(Format('主机[ %s ]无法将卡收到回收箱,错误码: %s.',
      [FActiveDispenser.FID, nStr]));
    //xxxxx
  end;
end;

//Date: 2018-11-24
//Desc: 重置设备
function TDispenserThread.ResetDispenser: Boolean;
var nStr: string;
    nInit: Int64;
    nSend: TDispenserK7Send;
begin
  Result := False;
  InitSendData(@nSend, Char($52) + Char($53));
  if not SendToDispenser(@nSend) then Exit;

  nStr := '';
  nInit := GetTickCount();
  
  while GetTickCountDiff(nInit) < cDispenser_Wait_Timeout do
  begin
    nStr := QueryStatuse();
    if HasStatus(nStr, cTTCE_K7_PosNew) or
       HasStatus(nStr, cTTCE_K7_KXNoCard) then //新卡已准备好,或卡箱无卡
    begin
      Result := True;
      if HasStatus(nStr, cTTCE_K7_KXNoCard) then
        WriteLog(Format('主机[ %s ]卡箱为空,错误码: %s.',
          [FActiveDispenser.FID, nStr]));
      Exit;
    end;
  end;

  if nStr <> '' then
  begin
    WriteLog(Format('主机[ %s ]无法重置,错误码: %s.',
      [FActiveDispenser.FID, nStr]));
    //xxxxx
  end;
end;

initialization
  gDispenserManager := nil;
finalization
  FreeAndNil(gDispenserManager);
end.
