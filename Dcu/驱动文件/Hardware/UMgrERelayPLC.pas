{*******************************************************************************
  作者: dmzn@163.com 2019-04-24
  描述: 基于PLC的继电器控制器

  备注:
  *.设计标准:
    1,24路开关量输入。
    2,16路开合继电器输出。
    3,一路485输出。
    4,TCP Server模式通讯。
  *.通讯协议格式：
    起始帧---|---功能码---|---数据长度---|---数据---|---校验位
     3字节	     1字节	       1字节	      N*1字节     1字节
    校验算法：对"起始帧->数据N最后一个字节"进行异或得到的值。
*******************************************************************************}
unit UMgrERelayPLC;

{$DEFINE Debug}
interface

uses
  Windows, Classes, SysUtils, NativeXml, IdTCPConnection, IdTCPClient, IdGlobal,
  IdStack, SyncObjs, UWaitItem, ULibFun, USysLoger;

const
  cERelay_AddrNum          = 64;        //通道个数
  cERelay_Null             = $FF;       //空

  cERelay_FrameBegin       = Char($FF) + Char($FF) + Char($FF); //起始帧
  cERelay_QueryStatus      = $01;       //状态查询(in)
  cERelay_RelaysOC         = $02;       //通道开合(open close)
  cERelay_DataForward      = $03;       //485数据转发
  cERelay_SweetHeart       = $04;       //链路心跳

  cERelay_SignIn_On        = $01;       //输入有信号
  cERelay_SignIn_Off       = $00;       //输入无信号
  cERelay_SignOut_Close    = $00;       //输出:关闭
  cERelay_SignOut_Open     = $01;       //输出:打开
  cERelay_SignOut_Ignore   = $02;       //输出:不变

type
  TERelayAddress = array[0..cERelay_AddrNum-1] of Byte;
  //in-out address,8x8

  PERelayHost = ^TERelayHost;
  TERelayHost = record
    FEnable        : Boolean;           //是否启用
    FID            : string;            //主机标识
    FName          : string;            //主机名称
    FHost          : string;            //主机IP
    FPort          : Integer;           //主机端口
    FInNum         : Integer;           //输入通道
    FInSignalOn    : Byte;
    FInSignalOff   : Byte;              //输入信号
    FOutNum        : Integer;           //输出通道
    FOutSignalOn   : Byte;
    FOutSignalOff  : Byte;              //输出信号

    FLastActive    : Cardinal;          //上次活动
    FStatusIn      : TERelayAddress;    //输入状态
    FStatusOut     : TERelayAddress;    //输出状态
    FStatusLast    : Cardinal;          //状态更新
    FSweetHeart    : Cardinal;          //最后心跳

    FLocked        : Boolean;           //是否锁定
    FClient        : TIdTCPClient;      //通信链路
    FReadBuf       : TIdBytes;          //接收缓冲
    FGuangShan     : Integer;           //默认光栅信号
  end;
  TERelayHosts = array of TERelayHost;

  PERelayTunnel = ^TERelayTunnel;
  TERelayTunnel = record
    FEnable        : Boolean;           //是否启用
    FID            : string;            //通道标识
    FName          : string;            //通道名称
    FHost          : Integer;           //主机索引
    
    FIn            : TERelayAddress;    //输入地址
    FOut           : TERelayAddress;    //输出地址
    FAutoOFF       : Integer;           //自动关闭
    FLastOn        : Cardinal;          //上次打开
    FScreen        : Integer;           //显示屏号
  end;
  TERelayTunnels = array of TERelayTunnel;

  PERelayTunnelCommand = ^TERelayTunnelCommand;
  TERelayTunnelCommand = record
    FUsed          : Boolean;           //使用标记
    FLastUse       : Cardinal;          //最后使用
      
    FHostID        : string;            //主机标识
    FTunnel        : Integer;           //通道索引
    FCommand       : Byte;              //操作命令
    FParam         : Byte;              //扩展参数
    FResponse      : Boolean;           //需要应答
    FData          : TIdBytes;          //命令数据
  end;
  TERelayTunnelCommands = array of TERelayTunnelCommand;

  TERelayThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  TERelayManager = class;
  TERelayThread = class(TThread)
  private
    FOwner: TERelayManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FActiveHost: Integer;
    //当前读头
    FThreadType: TERelayThreadType;
    //线程模式
  protected
   procedure Execute; override;
    procedure DoExecute;
    //执行线程
    procedure ScanActiveHost(const nActive: Boolean);
    //扫描可用
  public
    constructor Create(AOwner: TERelayManager; AType: TERelayThreadType);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启停通道
  end;

  TERelayManager = class(TObject)
  private
    FHosts: TERelayHosts;
    FTunnels: TERelayTunnels;
    //通道列表
    FMonitorCount: Integer;
    FThreadCount: Integer;
    FReaders: array of TERelayThread;
    //连接对象
    FCommands: TERelayTunnelCommands;
    //命令列表
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearHost(const nFree: Boolean);
    //清理数据
    procedure CloseHostConn(const nHost: Integer);
    //关闭主机
    procedure WakeupReaders;
    //唤醒线程
    function MakeNewCommand(const nCmd,nParam: Byte;
      const nHost: string; const nTunnel: Integer;
      const nLock: Boolean = False; const nResponse: Boolean = True): Integer;
    //构建命令
    function SendCommand(const nHost: Integer; const nCmd: PERelayTunnelCommand;
      var nRecv: TIdBytes): Boolean;
    //发送指令
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure StartService;
    procedure StopService;
    //启停服务
    procedure LoadConfig(const nFile: string);
    //读取配置
    function FindTunnel(const nTunnel: string): Integer;
    //检索通道
    function OpenTunnel(const nTunnel: string): Boolean;
    function CloseTunnel(const nTunnel: string): Boolean;
    function TunnelOC(const nTunnel: string; nOC: Boolean): string;
    //开合通道
    function IsTunnelOK(const nTunnel: string): Boolean;
    function IsTunnelOKEx(const nTunnel: string): Boolean;
    function QueryStatus(const nHost: string; var nIn,nOut: TERelayAddress): Boolean;
    //查询状态
    procedure ShowText(const nTunnel,nText: string; nScreen: Integer = -1);
    //显示内容
    property Hosts: TERelayHosts read FHosts;
    property Tunnels: TERelayTunnels read FTunnels;
    //属性相关
  end;

var
  gERelayManagerPLC: TERelayManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TERelayManager, 'PLC检测控制器', nEvent);
end;

constructor TERelayThread.Create(AOwner: TERelayManager;
  AType: TERelayThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;

  FWaiter := TWaitObject.Create();
  FWaiter.Interval := 2 * 1000;
end;

destructor TERelayThread.Destroy;
begin
  FreeAndNil(FWaiter);
  inherited;
end;

procedure TERelayThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TERelayThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TERelayThread.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveHost := -1;
    try
      Doexecute;
    finally
      if FActiveHost > -1 then
      try
        FOwner.FSyncLock.Enter;
        FOwner.FHosts[FActiveHost].FLocked := False;
      finally
        FOwner.FSyncLock.Leave;
      end;
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2019-04-28
//Parm: 活动&不活动读头
//Desc: 扫描nActive读头,若可用存入FActiveReader.
procedure TERelayThread.ScanActiveHost(const nActive: Boolean);
var i,nIdx: Integer;
begin
  with FOwner do
  begin
    for nIdx:=Low(FCommands) to High(FCommands) do
    begin
      if not FCommands[nIdx].FUsed then Continue;
      //invalid command

      for i:=Low(FHosts) to High(FHosts) do
      if (FHosts[i].FEnable) and (not FHosts[i].FLocked) and 
         (FHosts[i].FID = FCommands[nIdx].FHostID) then
      begin
        if (nActive and (FHosts[i].FLastActive > 0)) or
           ((not nActive) and (FHosts[i].FLastActive = 0)) then
        begin
          FActiveHost := i;
          FHosts[i].FLocked := True;
          Break;
        end;
      end;

      if FActiveHost > -1 then Break;
      //find valid host
    end;
  end;
end;

procedure TERelayThread.DoExecute;
var nIdx: Integer;
    nBool: Boolean;
    nRecv: TIdBytes;
    nCmd: TERelayTunnelCommand;

    //Desc: 检索当前主机的指令
    function GetHostCommand: Boolean;
    var i: Integer;
    begin
      with FOwner do
      try
        Result := False;
        //default
        FSyncLock.Enter;
        
        for i:=Low(FCommands) to High(FCommands) do
         with FCommands[i] do
          if FUsed and (FHostID = FHosts[FActiveHost].FID) then
          begin
            FUsed := False;
            nCmd := FCommands[i];

            Result := True;
            Break;
          end;
      finally
        FSyncLock.Leave;
      end;
    end;
begin
  with FOwner do
  try
    FSyncLock.Enter;
    //lock

    for nIdx:=Low(FTunnels) to High(FTunnels) do
    with FTunnels[nIdx] do
    begin
      if (FLastOn > 0) and (GetTickCountDiff(FLastOn) >= FAutoOFF) then
      begin
        FLastOn := 0;
        TunnelOC(FID, False); //通道自动关闭
      end; 

      if GetTickCountDiff(FHosts[FHost].FSweetHeart) >= 2 * 1000 then
      begin
        FHosts[FHost].FSweetHeart := GetTickCount;
        MakeNewCommand(cERelay_SweetHeart, 0, FHosts[FHost].FID,
          nIdx, False, False);
        //补发心跳
      end;
    end;

    if FThreadType = ttAll then
    begin
      ScanActiveHost(False);
      //优先扫描不活动读头

      if FActiveHost < 0 then
        ScanActiveHost(True);
      //辅助扫描活动项
    end else

    if FThreadType = ttActive then
    begin
      ScanActiveHost(True);
      //优先扫描活动读头
    end;
  finally
    FSyncLock.Leave;
  end;

  if Terminated or (FActiveHost < 0) then Exit;
  //invalid host

  while True do
  begin
    if not GetHostCommand then Break;
    //command is empty
    nBool := FOwner.SendCommand(FActiveHost, @nCmd, nRecv);
    
    if nBool then
    with FOwner do
    try
      FSyncLock.Enter;
      FHosts[FActiveHost].FSweetHeart := GetTickCount();
      //任意指令成功后,视为心跳
    finally
      FSyncLock.Leave;
    end;   

    with FOwner.FTunnels[nCmd.FTunnel] do
    begin
      if nBool and (FAutoOFF > 0) and (nCmd.FCommand = cERelay_RelaysOC) and
         (nCmd.FParam = cERelay_SignOut_Open) then
      begin
        FLastOn := GetTickCount;
        //通道输出端最后打开时间
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TERelayManager.Create;
begin
  FThreadCount := 2;
  FMonitorCount := 1;
  SetLength(FHosts, 0);
  SetLength(FTunnels, 0);

  SetLength(FReaders, 0);
  SetLength(FCommands, 0);
  FSyncLock := TCriticalSection.Create;
end;

destructor TERelayManager.Destroy;
begin
  StopService();
  ClearHost(True);
  
  FSyncLock.Free;
  inherited;
end;

procedure TERelayManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=Low(FHosts) to High(FHosts) do
    FreeAndNil(FHosts[nIdx].FClient);
  SetLength(FHosts, 0);
end;

//Desc: 关闭主机链路
procedure TERelayManager.CloseHostConn(const nHost: Integer);
begin
  with FHosts[nHost]  do
  begin
    if Assigned(FClient) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //xxxxx
    end;
  end;
end;

//Desc: 启动
procedure TERelayManager.StartService;
var nIdx,nInt: Integer;
    nType: TERelayThreadType;
begin
  nInt := 0;
  for nIdx:=Low(FHosts) to High(FHosts) do
   if FHosts[nIdx].FEnable then Inc(nInt);
  //count enable host
  
  if nInt < 1 then Exit;
  StopService;
  SetLength(FReaders, FThreadCount);

  for nIdx:=Low(FReaders) to High(FReaders) do
    FReaders[nIdx] := nil;
  //xxxxx

  for nIdx:=Low(FReaders) to High(FReaders) do
  begin
    if nIdx >= nInt then Exit;
    //线程不超过启用主机数

    if nIdx < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    FReaders[nIdx] := TERelayThread.Create(Self, nType);
    //xxxxx
  end;
end;

//Desc: 停止
procedure TERelayManager.StopService;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Terminate;
  //设置退出标记

  for nIdx:=Low(FReaders) to High(FReaders) do
  begin
    if Assigned(FReaders[nIdx]) then
      FReaders[nIdx].StopMe;
    FReaders[nIdx] := nil;
  end;

  FSyncLock.Enter;
  try
    SetLength(FCommands, 0);
    //clear cmd

    for nIdx:=Low(FHosts) to High(FHosts) do
      CloseHostConn(nIdx);
    //关闭链路
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 唤醒全部线程
procedure TERelayManager.WakeupReaders;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Wakeup;
  //xxxxx
end;

//Date: 2019-04-25
//Parm: 通道标识
//Desc: 检索nTunnel位置索引
function TERelayManager.FindTunnel(const nTunnel: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=Low(FTunnels) to High(FTunnels) do
  if CompareText(nTunnel, FTunnels[nIdx].FID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2019-04-25
//Parm: 命令;参数;主机;通道;锁定;应答
//Desc: 构建命令项,合并相同命令
function TERelayManager.MakeNewCommand(const nCmd,nParam: Byte;
  const nHost: string; const nTunnel: Integer;
  const nLock,nResponse: Boolean): Integer;
var nIdx: Integer;
    nInit: TERelayTunnelCommand;
begin
  Result := -1;
  if nLock then FSyncLock.Enter;
  try
    for nIdx:=Low(FCommands) to High(FCommands) do
    with FCommands[nIdx] do
    begin
      if FUsed and (GetTickCountDiff(FLastUse) > 10 * 1000) then
        FUsed := False;
      //command keep time

      if FUsed then
      begin
        if (nTunnel = FTunnel) and (nCmd = FCommand) and (nParam = FParam) then
        begin
          Result := nIdx;
          Break;
        end; //same tunnel,same command
      end else
      begin
        if Result < 0 then
          Result := nIdx;
        //xxxxx
      end;
    end;

    if Result < 0 then
    begin
      Result := Length(FCommands);
      SetLength(FCommands, Result + 1);
    end; //new command

    FillChar(nInit, SizeOf(nInit), #0);
    FCommands[Result] := nInit;
    //init

    with FCommands[Result] do
    begin
      FUsed    := True;
      FLastUse := GetTickCount;

      FHostID  := nHost;
      FTunnel  := nTunnel;
      FCommand := nCmd;
      FParam   := nParam;
      FResponse := nResponse;
    end;
  finally
    if nLock then FSyncLock.Leave;
  end;
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

//Date: 2019-04-27
//Parm: 数据;偏移
//Desc: 对nData做异或校验
function VerifyData(var nData: TIdBytes; const nOffset: Integer = 0): Byte;
var nIdx,nHigh: Integer;
begin
  nHigh := High(nData);
  if nHigh < 0 then
  begin
    Result := 0;
    Exit;
  end;

  if nOffset < 0 then
    nHigh := nHigh + nOffset;
  //xxxxx
  
  Result := nData[0];
  for nIdx:=1 to nHigh do
    Result := Result xor nData[nIdx];
  //xxxxx
end;

//Date: 2019-04-26
//Parm: 主机;命令;结果
//Desc: 向nHost发送nCommand命令
function TERelayManager.SendCommand(const nHost: Integer;
  const nCmd: PERelayTunnelCommand; var nRecv: TIdBytes): Boolean;
var nIdx,nInt,nLen,nNum: Integer;
    nSendBuf: Boolean;
    nBuf: TIdBytes;
begin
  Result := False;
  with FHosts[nHost] do
  try
    nBuf := ToBytes(cERelay_FrameBegin, Indy8BitEncoding);    //起始帧
    AppendByte(nBuf, nCmd.FCommand);                          //功能码
    AppendByte(nBuf, Length(nCmd.FData));                     //数据长度
    AppendBytes(nBuf, nCmd.FData);                            //数据
    AppendByte(nBuf, VerifyData(nBuf));                       //校验位

    {$IFDEF Debug}
    LogHex(nBuf, '发送: ');
    {$ENDIF}

    nSendBuf := True;
    nNum := 1;
    //init
    
    while nNum < 3 do
    try
      Inc(nNum);
      if not FClient.Connected then
      begin
        FClient.Connect;
        FLastActive := GetTickCount;
        //可连接,则活动

        FClient.IOHandler.ReadTimeout := 5 * 1000;
        //reset timeout
      end;

      if nSendBuf then
      begin
        FClient.IOHandler.Write(nBuf);
        //send data

        if nCmd.FResponse then
          FClient.IOHandler.ReadBytes(FReadBuf, Length(cERelay_FrameBegin));
        //read frame begin
      end;

      while True do
      begin
        FClient.IOHandler.CheckForDataOnSource(10);
        //fill the output buffer with a timeout

        if FClient.IOHandler.InputBufferIsEmpty then
             Break
        else FClient.IOHandler.InputBuffer.ExtractToBytes(FReadBuf);
      end;

      nSendBuf := False;
      //读写正常则不用重发
      
      {$IFDEF Debug}
      LogHex(FReadBuf, '原始: ');
      {$ENDIF}

      nLen := Length(FReadBuf);
      if nLen < 1 then
      begin
        if not nCmd.FResponse then
        begin
          Result := True;
          Break;
        end; //无需应答且无数据

        Continue;
      end;

      //------------------------------------------------------------------------
      if nLen > 100 then
      begin
        FReadBuf := ToBytes(FReadBuf, 100, nLen - 100);
        {$IFDEF Debug}
        LogHex(FReadBuf, '保留: ');
        {$ENDIF}

        nLen := Length(FReadBuf);
        WriteLog('缓冲超长,已截断.');
      end;

      nIdx := nLen - 6;
      //最小包起始位: 起始帧3 + 功能码1 + 数据长1 + 校验1

      while nIdx >= 0 do
      begin
        if (FReadBuf[nIdx] = $FF) and (FReadBuf[nIdx+1] = $FF) and
           (FReadBuf[nIdx+2] = $FF) then //帧头
        begin
          nInt := FReadBuf[nIdx+4] + 6; //整包数据边界
          if nIdx + nInt > nLen then //数据不完整
          begin
            Dec(nIdx);
            Continue;
          end;

          nRecv := ToBytes(FReadBuf, nInt, nIdx);
          if nRecv[High(nRecv)] <> VerifyData(nRecv, -1) then //校验失败
          begin
            Dec(nIdx);
            Continue;
          end;

          nInt := nInt + nIdx;
          if nLen = nInt then
               SetLength(FReadBuf, 0)
          else FReadBuf := ToBytes(FReadBuf, nLen - nInt, nInt);

          Result := nRecv[3] = nCmd.FCommand;
          //应答匹配
          Break;
        end else Dec(nIdx);
      end;

      {$IFDEF Debug}
      LogHex(nRecv, '协议: ');
      LogHex(FReadBuf, '缓冲: ');
      {$ENDIF}

      if not nCmd.FResponse then
        Result := True;
      if Result then Break;
    except
      on nErr: Exception do
      begin
        nSendBuf := True;
        CloseHostConn(nHost);
        //断开重连

        if nNum >= 3 then
          raise;
        //xxxxx
      end;
    end;
  except
    on nErr: Exception do
    begin
      if nErr is EIdSocketError then
        FLastActive := 0;
      //连接错误,置为不活动
      
      WriteLog(Format('向主机[ %s:%s,%d ]发送数据失败,描述: %s', [FID,
        FClient.Host, FClient.Port, nErr.Message]));
      //xxxxx
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2019-04-25
//Parm: 通道标识
//Desc: 打开nTunnel通道
function TERelayManager.OpenTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, True);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2019-04-25
//Parm: 通道标识
//Desc: 关闭nTunnel通道
function TERelayManager.CloseTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, False);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2019-04-25
//Parm: 通道标识
//Desc: 开关nTunnel通道
function TERelayManager.TunnelOC(const nTunnel: string; nOC: Boolean): string;
var nIdx,nInt,nT,nCmd: Integer;
begin
  Result := '';
  if (Length(FReaders) < 1) or (not Assigned(FReaders[0])) then Exit;
  nT := FindTunnel(nTunnel);

  if nT < 0 then
  begin
    Result := '通道[ %s ]编号无效.';
    Result := Format(Result, [nTunnel]); Exit;
  end;

  with FTunnels[nT] do
  begin
    if not (FEnable and FHosts[FHost].FEnable ) then Exit;
    //不启用,不发送

    nInt := 0;
    for nIdx:=Low(FOut) to High(FOut) do
      if FOut[nIdx] <> cERelay_Null then Inc(nInt);
    //xxxxx

    if nInt < 1 then Exit;
    //无输出地址,表示不使用输出控制

    FSyncLock.Enter;
    try
      if nOC then
           nInt := FHosts[FHost].FOutSignalOn
      else nInt := FHosts[FHost].FOutSignalOff;

      nCmd := MakeNewCommand(cERelay_RelaysOC, nInt, FHosts[FHost].FID, nT);
      with FCommands[nCmd] do
      begin
        SetLength(FData, FHosts[FHost].FOutNum);
        for nIdx:=Low(FData) to High(FData) do
          FData[nIdx] := cERelay_SignOut_Ignore;
        //default

        for nIdx:=Low(FOut) to High(FOut) do
        begin
          if FOut[nIdx] = cERelay_Null then Continue;
          //invalid address

          nInt := FOut[nIdx] - 1;
          //address base from 1
          if (nInt < 0) or (nInt >= FHosts[FHost].FOutNum) then Continue;

          if nOC then
               FData[nInt] := FHosts[FHost].FOutSignalOn
          else FData[nInt] := FHosts[FHost].FOutSignalOff;
        end;
      end;
    finally
      FSyncLock.Leave;
    end;

    WakeupReaders;
    //唤醒并执行
  end;
end;

//Date: 2019-04-27
//Parm: 地址组;开始索引;状态字节
//Desc: 将nStatus拆分至nAddr中
procedure SpitStatus(var nAddr: TERelayAddress; const nStart: Integer;
  const nStatus: Byte);
var nIdx: Integer;
begin
  for nIdx:=0 to 7 do
  begin
    nAddr[nStart+nIdx] := GetNumberBit(nStatus, nIdx+1, Bit_8);
  end;
end;

//Date: 2019-04-26
//Parm: 主机编号;IO状态
//Desc: 查询nHost的输入输出状态
function TERelayManager.QueryStatus(const nHost: string; var nIn,
  nOut: TERelayAddress): Boolean;
var nIdx,nInt,nInI,nOutI: Integer;
    nInit: Cardinal;
    nLockMe: Boolean;
    nRecv: TIdBytes;
    nCmd: TERelayTunnelCommand;
    nInStr:string;
begin
  Result := False;
  nInt := -1;
  //init

  for nIdx:=Low(FHosts) to High(FHosts) do
  if CompareText(nHost, FHosts[nIdx].FID) = 0 then
  begin
    nInt := nIdx;
    Break;
  end;

  if nInt < 0 then
  begin
    WriteLog(Format('主机[ %s ]不存在.', [nHost]));
    Exit;
  end;

  if not FHosts[nInt].FEnable then
  begin
    WriteLog(Format('主机[ %s ]已停用.', [nHost]));
    Exit;
  end;

  nLockMe := False;
  nInit := GetTickCount();
  
  with FHosts[nInt] do
  try
    while True do
    try
      FSyncLock.Enter;
      if FLocked then
      begin
        if GetTickCountDiff(nInit) > 5 * 1000 then
        begin
          WriteLog(Format('等待主机[ %s ]解锁超时.', [nHost]));
          Exit;
        end;

        Sleep(20);
        //其它调用锁定,则等待
      end else
      begin
        nLockMe := True;
        FLocked := True; //本次调用锁定
        Break;
      end;
    finally
      FSyncLock.Leave;
    end;

    if FGuangShan = 1 then
    begin
      for nIdx:=Low(FStatusIn) to High(FStatusIn) do
        FStatusIn[nIdx] := cERelay_SignIn_Off;
    end;
      //default fill
    if GetTickCountDiff(FStatusLast) > 800 then //状态短时间内可复用 1200
    begin
      nCmd.FCommand := cERelay_QueryStatus;
      SetLength(nCmd.FData, 0);
      if not SendCommand(nInt, @nCmd, nRecv) then Exit;

      FStatusLast := GetTickCount;
      nInI := 0;
      nOutI := 0;
      //to parse status data
      if FGuangShan <> 1 then
      begin
        for nIdx:=Low(FStatusIn) to High(FStatusIn) do
          FStatusIn[nIdx] := cERelay_Null;
      end;
      //default fill

      for nIdx:=Low(FStatusOut) to High(FStatusOut) do
        FStatusOut[nIdx] := cERelay_Null;
      //default fill

      for nIdx:=5 to High(nRecv)-1 do
      begin
        if nInI < FInNum then //前几个字节是输入状态
        begin
          SpitStatus(FStatusIn, nInI, nRecv[nIdx]);
          Inc(nInI, 8);
        end else

        if nOutI < FOutNum then //后几个字节是输出状态
        begin
          SpitStatus(FStatusOut, nOutI, nRecv[nIdx]);
          Inc(nOutI, 8);
        end;
      end;
    end;

    Result := True;
    nInStr := '';
    for nIdx:=Low(FStatusIn) to High(FStatusIn) do
    begin
      nInStr := nInStr + ByteToHex(FStatusIn[nIdx]); 
    end;
    WriteLog('主机:'+nHost+'光栅状态:'+nInStr);
    nIn  := FStatusIn;
    nOut := FStatusOut;
  finally
    if nLockMe then
    begin
      FSyncLock.Enter;
      FLocked := False;
      FSyncLock.Leave;
    end;
  end;
end;

//Date: 2019-04-26
//Parm: 通道标识
//Desc: 判断nTunnel状态是否正常
function TERelayManager.IsTunnelOK(const nTunnel: string): Boolean;
var nIdx,nInt,nT: Integer;
    nIn,nOut: TERelayAddress;
begin
  Result := True;
  if Trim(nTunnel) = '' then Exit; //空通道默认正常

  nT := FindTunnel(nTunnel);
  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]无效.',  [nTunnel]));
    Result := False;
    Exit;
  end;

  with FTunnels[nT] do
  begin
    if not (FEnable and FHosts[FHost].FEnable) then Exit; //未启用
    nInt := 0;

    for nIdx:=Low(FIn) to High(FIn) do
     if FIn[nIdx] <> cERelay_Null then Inc(nInt);
    if nInt < 1 then Exit; //无输入地址,标识不使用输入监测

    Result := QueryStatus(FHosts[FHost].FID, nIn, nOut);
    if not Result then Exit;

    for nIdx:=Low(FIn) to High(FIn) do
    begin
      if FIn[nIdx] = cERelay_Null then Continue;
      //invalid addr

      nInt := FIn[nIdx] - 1;
      //address base from 1
      if (nInt < 0) or (nInt >= FHosts[FHost].FInNum) then Continue;

      if nIn[nInt] = FHosts[FHost].FInSignalOff then
      begin
        Result := False;
        Exit;
      end; //某路输入无信号,认为车辆未停妥
    end;
  end;
end;

//Date: 2019-04-26
//Parm: 文本
//Desc: 获取nTxt的内码
function ConvertStr(const nTxt: WideString; var nBuf: TIdBytes): Integer;
var nStr: string;
    nIdx,nLen: Integer;
begin
  Result := 0;
  SetLength(nBuf, 0);
  nLen := Length(nTxt);
  
  for nIdx:=1 to nLen do
  begin
    nStr := nTxt[nIdx];
    AppendByte(nBuf, Ord(nStr[1]));
    Inc(Result);

    if Length(nStr) = 2 then
    begin
      AppendByte(nBuf, Ord(nStr[2]));
      Inc(Result);
    end;
  end;
end;

//Date: 2019-04-26
//Parm: 通道;内容;屏号
//Desc: 在nTunnel显示nText内容
procedure TERelayManager.ShowText(const nTunnel, nText: string;
  nScreen: Integer);
var nT,nCmd: Integer;
begin
  if (Length(FReaders) < 1) or (not Assigned(FReaders[0])) then Exit;
  nT := FindTunnel(nTunnel);

  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]编号无效.', [nTunnel]));
    Exit;
  end;

  with FTunnels[nT] do
  begin
    if not (FEnable and FHosts[FHost].FEnable ) then Exit;
    //不启用,不发送

    FSyncLock.Enter;
    try
      nCmd := MakeNewCommand(cERelay_DataForward, 0, FHosts[FHost].FID, nT);
      if nScreen < 0 then nScreen := FScreen;
      
      ConvertStr(Char(nScreen) + nText + #13,
        FCommands[nCmd].FData);
      //xxxxx
    finally
      FSyncLock.Leave;
    end;

    WakeupReaders;
    //唤醒并执行
  end;
end;

//Date: 2019-04-24
//Parm：地址结构;地址字符串,类似: 1,2,3
//Desc：将nStr拆开,放入nAddr结构中
procedure SplitAddr(var nAddr: TERelayAddress; const nStr: string);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    SplitStr(nStr, nList, 0 , ',');
    //拆分
    
    for nIdx:=Low(nAddr) to High(nAddr) do
    begin
      if nIdx < nList.Count then
           nAddr[nIdx] := StrToInt(nList[nIdx])
      else nAddr[nIdx] := cERelay_Null;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 载入nFile配置文件
procedure TERelayManager.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nRoot,nNode,nTmp: TXmlNode;
    i,nIdx,nHost,nTunnel: Integer;
begin
  ClearHost(False);
  SetLength(FTunnels, 0);
  
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    nRoot := nXML.Root.NodeByName('config');
    if Assigned(nRoot) then
    begin
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

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nRoot := nXML.Root.Nodes[nIdx];
      if CompareText(nRoot.Name, 'host') <> 0 then Continue;
      //not host node

      nHost := Length(FHosts);
      SetLength(FHosts, nHost + 1);

      with FHosts[nHost],nRoot do
      begin
        FID     := AttributeByName['id'];
        FName   := AttributeByName['name'];
        FHost   := NodeByNameR('ip').ValueAsString;
        FPort   := NodeByNameR('port').ValueAsInteger;
        FEnable := NodeByNameR('enable').ValueAsInteger = 1;

        nTmp    := nRoot.NodeByName('GuangShan');
        if Assigned(nTmp) then
             FGuangShan := nTmp.ValueAsInteger
        else FGuangShan := 0;

        FStatusLast := 0;
        FSweetHeart := 0;
        FLocked := False;
        FLastActive := GetTickCount;

        nTmp := nRoot.NodeByName('signal_in');
        if Assigned(nTmp) then
        begin
          FInNum := StrToInt(nTmp.AttributeByName['num']);
          if (FInNum > cERelay_AddrNum) or (FInNum mod 8 <> 0) then
          begin
            FInNum := 24;
            WriteLog(Format('主机[ %s ]输入配置异常.', [FID]));
          end;

          FInSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FInSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FInNum := 24;
          FInSignalOn := cERelay_SignIn_On;
          FInSignalOff := cERelay_SignIn_Off;
        end;

        nTmp := nRoot.NodeByName('signal_out');
        if Assigned(nTmp) then
        begin
          FOutNum := StrToInt(nTmp.AttributeByName['num']);
          if (FOutNum > cERelay_AddrNum) or (FOutNum mod 8 <> 0) then
          begin
            FInNum := 16;
            WriteLog(Format('主机[ %s ]输出配置异常.', [FID]));
          end;

          FOutSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FOutSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FOutNum := 16;
          FOutSignalOn := cERelay_SignOut_Open;
          FOutSignalOff := cERelay_SignOut_Close;
        end;
        
        if FEnable then
        begin
          FClient := TIdTCPClient.Create;
          //socket
          
          with FClient do
          begin
            Host := FHost;
            Port := FPort;
            ReadTimeout := 3 * 1000;
            ConnectTimeout := 3 * 1000;   
          end;
        end else FClient := nil;
      end;

      nRoot := nRoot.FindNode('tunnels');
      if not Assigned(nRoot) then Continue;

      for i:=0 to nRoot.NodeCount - 1 do
      begin
        nNode := nRoot.Nodes[i];
        nTunnel := Length(FTunnels);
        SetLength(FTunnels, nTunnel + 1);

        with FTunnels[nTunnel],nNode do
        begin
          FID    := AttributeByName['id'];
          FName  := AttributeByName['name'];
          FHost  := nHost;
          
          SplitAddr(FIn, NodeByName('in').ValueAsString);
          SplitAddr(FOut, NodeByName('out').ValueAsString);

          nTmp := nNode.FindNode('enable');
          FEnable := (not Assigned(nTmp)) or (nTmp.ValueAsString <> '0');
          FLastOn := 0;

          nTmp := nNode.FindNode('auto_off');           
          if Assigned(nTmp) then
               FAutoOFF := nTmp.ValueAsInteger
          else FAutoOFF := 0;

          nTmp := nNode.FindNode('screen_no');
          if Assigned(nTmp) then
               FScreen := nTmp.ValueAsInteger
          else FScreen := -1;
        end;
      end
    end;
  finally
    nXML.Free;
  end;
end;

function TERelayManager.IsTunnelOKEx(const nTunnel: string): Boolean;
var nIdx,nInt,nT: Integer;
    nIn,nOut: TERelayAddress;
begin
  Result := False;
  if Trim(nTunnel) = '' then
  begin
    Result := True;
    Exit; //空通道默认正常
  end;

  nT := FindTunnel(nTunnel);
  if nT < 0 then
  begin
    WriteLog(Format('通道[ %s ]无效.',  [nTunnel]));
    Result := False;
    Exit;
  end;

  with FTunnels[nT] do
  begin
    if not (FEnable and FHosts[FHost].FEnable) then Exit; //未启用
    nInt := 0;

    for nIdx:=Low(FIn) to High(FIn) do
     if FIn[nIdx] <> cERelay_Null then Inc(nInt);
    if nInt < 1 then Exit; //无输入地址,标识不使用输入监测

    Result := QueryStatus(FHosts[FHost].FID, nIn, nOut);
    if not Result then Exit;

    for nIdx:=Low(FIn) to High(FIn) do
    begin
      if FIn[nIdx] = cERelay_Null then Continue;
      //invalid addr

      nInt := FIn[nIdx] - 1;
      //address base from 1
      if (nInt < 0) or (nInt >= FHosts[FHost].FInNum) then Continue;

      if nIn[nInt] = FHosts[FHost].FInSignalOff then
      begin
        Result := False;
        Exit;
      end; //某路输入无信号,认为车辆未停妥
    end;
  end;
end;

initialization
  gERelayManagerPLC := nil;
finalization
  FreeAndNil(gERelayManagerPLC);
end.
