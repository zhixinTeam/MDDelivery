{*******************************************************************************
  作者：dmzn@163.com 2014-5-28
  描述：车辆检测控制器通讯单元
*******************************************************************************}
unit UMgrTruckProbe;

{.$DEFINE DEBUG}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, IdTCPConnection, IdTCPClient, IdGlobal,
  NativeXml, UWaitItem, UMemDataPool, USysLoger, ULibFun;

const
  cProber_NullASCII           = $30;       //ASCII空字节
  cProber_Flag_Begin          = $F0;       //开始标识
  
  cProber_Frame_QueryIO       = $10;       //状态查询(in out)
  cProber_Frame_RelaysOC      = $20;       //通道开合(open close)
  cProber_Frame_DataForward   = $30;       //485数据转发
  cProber_Frame_IP            = $50;       //设置IP
  cProber_Frame_MAC           = $60;       //设置MAC

  cProber_Query_All           = $00;       //查询全部
  cProber_Query_In            = $01;       //查询输入
  cProber_Query_Out           = $02;       //查询输出
  cProber_Query_Interval      = 1600;      //查询间隔

  cProber_Len_Frame           = $14;       //普通帧长
  cProber_Len_FrameData       = 16;        //普通定长数据
  cProber_Len_485Data         = 100;       //485转发数据

type
  TProberIOAddress = array[0..7] of Byte;
  //in-out address

  TProberFrameData = array [0..cProber_Len_FrameData - 1] of Byte;
  TProber485Data   = array [0..cProber_Len_485Data - 1] of Byte;

  PProberFrameHeader = ^TProberFrameHeader;
  TProberFrameHeader = record
    FBegin  : Byte;                //起始帧
    FLength : Byte;                //帧长度
    FType   : Byte;                //帧类型
    FExtend : Byte;                //帧扩展
  end;

  PProberFrameControl = ^TProberFrameControl;
  TProberFrameControl = record
    FHeader : TProberFrameHeader;   //帧头
    FData   : TProberFrameData;     //数据
    FVerify : Byte;                //校验位
  end;

  PProberFrameDataForward = ^TProberFrameDataForward;
  TProberFrameDataForward = record
    FHeader : TProberFrameHeader;   //帧头
    FData   : TProber485Data;       //数据
    FVerify : Byte;                //校验位
  end;  

  PProberHost = ^TProberHost;
  TProberHost = record
    FID      : string;               //标识
    FName    : string;               //名称
    FHost    : string;               //IP
    FPort    : Integer;              //端口
    FStatusI : TProberIOAddress;     //输入状态
    FStatusO : TProberIOAddress;     //输出状态
    FStatusIEx : TProberIOAddress;     //输入状态
    FStatusOEx : TProberIOAddress;     //输出状态
    FStatusL : Int64;                //状态时间

    FInSignalOn: Byte;
    FInSignalOff: Byte;              //输入信号
    FOutSignalOn: Byte;
    FOutSignalOff: Byte;             //输出信号

    FClient : TIdTCPClient;          //通信链路
    FLocked : Boolean;               //是否锁定
    FLastActive: Int64;              //上次活动
    FEnable  : Boolean;              //是否启用
  end;  

  PProberTunnel = ^TProberTunnel;
  TProberTunnel = record
    FID      : string;               //标识
    FName    : string;               //名称
    FHost    : PProberHost;          //所在主机
    FIn      : TProberIOAddress;     //输入地址

    FOut     : TProberIOAddress;     //输出地址
    FAutoOFF : Integer;              //自动关闭
    FLastOn  : Int64;                //上次打开
    FScreen  : Integer;              //显示屏号
    FEnable  : Boolean;              //是否启用
  end;

  PProberTunnelCommand = ^TProberTunnelCommand;
  TProberTunnelCommand = record
    FTunnel  : PProberTunnel;
    FCommand : Integer;
    FData    : Pointer;
  end;

  TProberHosts = array of TProberHost;
  //array of host
  TProberTunnels = array of TProberTunnel;
  //array of tunnel

const
  cSize_Prober_IOAddr   = SizeOf(TProberIOAddress);
  cSize_Prober_Control  = SizeOf(TProberFrameControl);
  cSize_Prober_Display  = SizeOf(TProberFrameDataForward);

type
  TProberThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  TProberManager = class;
  TProberThread = class(TThread)
  private
    FOwner: TProberManager;
    //拥有者
    FBuffer: TList;
    //待发送数据
    FWaiter: TWaitObject;
    //等待对象
    FThreadType: TProberThreadType;
    //线程模式
    FActiveHost: PProberHost;
    //当前读头
    FQueryFrame: TProberFrameControl;
    //状态查询
  protected
    procedure Execute; override;
    procedure DoExecute;
    //执行线程
    procedure ScanActiveHost(const nActive: Boolean);
    //扫描可用
    procedure SendHostCommand(const nHost: PProberHost);
    function SendData(const nHost: PProberHost; var nData: TIdBytes;
      const nRecvLen: Integer): string;
    //发送数据
  public
    constructor Create(AOwner: TProberManager; AType: TProberThreadType);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启停通道
  end;

  TProberManager = class(TObject)
  private
    FRetry: Byte;
    //重试次数
    FCommand: TList;
    //命令列表
    FHosts: TList;
    FTunnels: TProberTunnels;
    //通道列表
    FHostIndex: Integer;
    FHostActive: Integer;
    //读头索引
    FIDCommand: Integer;
    FIDControl: Integer;
    FIDForward: Integer;
    //数据标识
    FMonitorCount: Integer;
    FThreadCount: Integer;
    FReaders: array of TProberThread;
    //连接对象
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearCommandList(nList: TList; nFree: Boolean);
    procedure ClearHost(const nFree: Boolean);
    //清理数据
    procedure CloseHostConn(const nHost: PProberHost);
    //关闭主机
    procedure RegisterDataType;
    //注册数据
    procedure WakeupReaders;
    //唤醒线程
    function SendData(const nHost: PProberHost; var nData: TIdBytes;
  const nRecvLen: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure StartProber;
    procedure StopProber;
    //启停检测器
    procedure LoadConfig(const nFile: string);
    //读取配置
    function OpenTunnel(const nTunnel: string): Boolean;
    function CloseTunnel(const nTunnel: string): Boolean;
    function TunnelOC(const nTunnel: string; nOC: Boolean): string;
    //开合通道
    procedure ShowTxt(const nTunnel,nTxt: string; nNo: Integer = -1);
    //显示内容
    function GetTunnel(const nTunnel: string): PProberTunnel;
    procedure EnableTunnel(const nTunnel: string; const nEnabled: Boolean);
    function QueryStatus(const nHost: PProberHost;
      var nIn,nOut: TProberIOAddress): string;
    function IsTunnelOK(const nTunnel: string): Boolean;
    //查询状态
    function IsTunnelOKEx(const nTunnel: string): Boolean;
    property Hosts: TList read FHosts;
    property RetryOnError: Byte read FRetry write FRetry;
    //属性相关
  end;

var
  gProberManager: TProberManager = nil;
  //全局使用

function ProberVerifyData(var nData: TIdBytes; const nDataLen: Integer;
  const nLast: Boolean): Byte;
procedure ProberStr2Data(const nStr: string; var nData: TProberFrameData);
//入口函数

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TProberManager, '车辆检测控制', nEvent);
end;

//Desc: 对nData做异或校验
function ProberVerifyData(var nData: TIdBytes; const nDataLen: Integer;
  const nLast: Boolean): Byte;
var nIdx,nLen: Integer;
begin
  Result := 0;
  if nDataLen < 1 then Exit;

  nLen := nDataLen - 2;
  //末位不参与计算
  Result := nData[0];

  for nIdx:=1 to nLen do
    Result := Result xor nData[nIdx];
  //xxxxx

  if nLast then
    nData[nDataLen - 1] := Result;
  //附加到末尾
end;

//Date: 2014-05-30
//Parm: 字符串;数据
//Desc: 将nStr填充到nData中
procedure ProberStr2Data(const nStr: string; var nData: TProberFrameData);
var nIdx,nLen: Integer;
begin
  nLen := Length(nStr);
  if nLen > cProber_Len_FrameData then
    nLen := cProber_Len_FrameData;
  //长度矫正

  for nIdx:=1 to nLen do
    nData[nIdx-1] := Ord(nStr[nIdx]);
  //xxxxx
end;

//Date: 2012-4-13
//Parm: 字符
//Desc: 获取nTxt的内码
function ConvertStr(const nTxt: WideString; var nBuf: array of Byte): Integer;
var nStr: string;
    nIdx: Integer;
begin
  Result := 0;
  for nIdx:=1 to Length(nTxt) do
  begin
    nStr := nTxt[nIdx];
    nBuf[Result] := Ord(nStr[1]);
    Inc(Result);

    if Length(nStr) = 2 then
    begin
      nBuf[Result] := Ord(nStr[2]);
      Inc(Result);
    end;

    if Result >= cProber_Len_485Data then Break;
  end;
end;

//Date：2014-5-13
//Parm：地址结构;地址字符串,类似: 1,2,3
//Desc：将nStr拆开,放入nAddr结构中
procedure SplitAddr(var nAddr: TProberIOAddress; const nStr: string);
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
      else nAddr[nIdx] := cProber_NullASCII;
    end;
  finally
    nList.Free;
  end;
end;

{$IFDEF DEBUG}
procedure LogHex(const nData: TIdBytes; const nPrefix: string = '');
var nStr: string;
    nIdx: Integer;
begin
  nStr := '';
  for nIdx:=Low(nData) to High(nData) do
    nStr := nStr + IntToHex(nData[nIdx], 1) + ' ';
  WriteLog(nPrefix + nStr);
end;
{$ENDIF}

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nCtr: PProberFrameControl;
    nCmd: PProberTunnelCommand;
    nFrw: PProberFrameDataForward;
begin
  if nFlag = 'ProberCTR' then
  begin
    New(nCtr);
    nData := nCtr;
  end else

  if nFlag = 'ProberCMD' then
  begin
    New(nCmd);
    nData := nCmd;
  end else

  if nFlag = 'ProberFwd' then
  begin
    New(nFrw);
    nData := nFrw;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
begin
  if nFlag = 'ProberCTR' then
  begin
    Dispose(PProberFrameControl(nData));
  end else

  if nFlag = 'ProberCMD' then
  begin
    Dispose(PProberTunnelCommand(nData));
  end else

  if nFlag = 'ProberFwd' then
  begin
    Dispose(PProberFrameDataForward(nData));
  end;
end;

//------------------------------------------------------------------------------
constructor TProberManager.Create;
begin
  FRetry := 2;
  FThreadCount := 2;
  FMonitorCount := 1;
  
  FHosts := TList.Create;
  FCommand := TList.Create;
  FSyncLock := TCriticalSection.Create;

  RegisterDataType;
  //由内存管理数据
end;

destructor TProberManager.Destroy;
begin
  StopProber;
  ClearCommandList(FCommand, True);
  ClearHost(True);

  FSyncLock.Free;
  inherited;
end;

//Desc: 清理命令
procedure TProberManager.ClearCommandList(nList: TList; nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gMemDataManager.UnLockData(PProberTunnelCommand(nList[nIdx]).FData);
    gMemDataManager.UnLockData(nList[nIdx]);
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

//Desc: 清理主机
procedure TProberManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
    nItem: PProberHost;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    nItem := FHosts[nIdx];
    nItem.FClient.Free;
    nItem.FClient := nil;
    
    Dispose(nItem);
    FHosts.Delete(nIdx);
  end;

  if nFree then
    FHosts.Free;
  //xxxxx
end;

//Desc: 注册数据类型
procedure TProberManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('ProberManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
  begin
    FIDCommand := RegDataType('ProberCMD', 'TunnelCommand', OnNew, OnFree, 2);
    FIDControl := RegDataType('ProberCTR', 'FrameControl', OnNew, OnFree, 2);
    FIDForward := RegDataType('ProberFwd', 'DataForward', OnNew, OnFree, 1); 
  end;
end;

//Desc: 启动
procedure TProberManager.StartProber;
var nIdx,nInt: Integer;
    nType: TProberThreadType;
begin
  nInt := 0;
  for nIdx:=FHosts.Count - 1 downto 0 do
   if PProberHost(FHosts[nIdx]).FEnable then
    Inc(nInt);
  //count enable host
                            
  if nInt < 1 then Exit;
  FHostIndex := 0;
  FHostActive := 0;

  StopProber;
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

    FReaders[nIdx] := TProberThread.Create(Self, nType);
    //xxxxx
  end;
end;

//Desc: 停止
procedure TProberManager.StopProber;
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
    for nIdx:=FHosts.Count - 1 downto 0 do
      CloseHostConn(FHosts[nIdx]);
    //关闭链路
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 唤醒全部线程
procedure TProberManager.WakeupReaders;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Wakeup;
  //xxxxx
end;

//Desc: 关闭主机链路
procedure TProberManager.CloseHostConn(const nHost: PProberHost);
begin
  if Assigned(nHost) and Assigned(nHost.FClient) then
  begin
    nHost.FClient.Disconnect;
    if Assigned(nHost.FClient.IOHandler) then
      nHost.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Desc: 载入nFile配置文件
procedure TProberManager.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nHost: PProberHost;
    nRoot,nNode,nTmp: TXmlNode;
    i,nIdx,nNum: Integer;
begin
  ClearHost(False);
  SetLength(FTunnels, 0);

  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    nRoot := nXML.Root.FindNode('config');
    if Assigned(nRoot) then
    begin
      nNode := nRoot.FindNode('thread');
      if Assigned(nNode) then
           FThreadCount := nNode.ValueAsInteger
      else FThreadCount := 2;

      if (FThreadCount < 1) or (FThreadCount > 5) then
        raise Exception.Create('TruckProbe Reader Thread-Num Need Between 1-5.');
      //xxxxx

      nNode := nRoot.FindNode('monitor');
      if Assigned(nNode) then
           FMonitorCount := nNode.ValueAsInteger
      else FMonitorCount := 1;

      if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
        raise Exception.Create(Format(
          'TruckProbe Reader Monitor-Num Need Between 1-%d.', [FThreadCount]));
      //xxxxx
    end;

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nRoot := nXML.Root.Nodes[nIdx];
      //prober node

      if CompareText(nRoot.Name, 'prober') <> 0 then Continue;
      //not prober node

      New(nHost);
      FHosts.Add(nHost);

      with nHost^,nRoot do
      begin
        FID    := AttributeByName['id'];
        FName  := AttributeByName['name'];
        FHost  := NodeByName('ip').ValueAsString;
        FPort  := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsInteger = 1;

        FStatusL := 0;
        //最后一次查询状态时间,超时系统会不认可当前状态

        FLocked := False;
        FLastActive := GetTickCount;
        //活动状态

        nTmp := nRoot.FindNode('signal_in');
        if Assigned(nTmp) then
        begin
          FInSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FInSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FInSignalOn := $00;
          FInSignalOff := $01;
        end;

        nTmp := nRoot.FindNode('signal_out');
        if Assigned(nTmp) then
        begin
          FOutSignalOn := StrToInt(nTmp.AttributeByName['on']);
          FOutSignalOff := StrToInt(nTmp.AttributeByName['off']);
        end else
        begin
          FOutSignalOn := $01;
          FOutSignalOff := $02;
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
        nNum := Length(FTunnels);
        SetLength(FTunnels, nNum + 1);

        with FTunnels[nNum],nNode do
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

//------------------------------------------------------------------------------
//Date：2014-5-14
//Parm：通道号
//Desc：获取nTunnel的通道数据
function TProberManager.GetTunnel(const nTunnel: string): PProberTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=Low(FTunnels) to High(FTunnels) do
  if CompareText(nTunnel, FTunnels[nIdx].FID) = 0 then
  begin
    Result := @FTunnels[nIdx];
    Break;
  end;
end;

//Date：2014-5-13
//Parm：通道号;True=Open,False=Close
//Desc：对nTunnel执行开合操作,若有错误则返回
function TProberManager.TunnelOC(const nTunnel: string; nOC: Boolean): string;
var i,j,nIdx: Integer;
    nPTunnel: PProberTunnel;
    nCmd: PProberTunnelCommand;
    nData: PProberFrameControl;
begin
  Result := '';
  if (Length(FReaders) < 1) or (not Assigned(FReaders[0])) then Exit;
  nPTunnel := GetTunnel(nTunnel);

  if not Assigned(nPTunnel) then
  begin
    Result := '通道[ %s ]编号无效.';
    Result := Format(Result, [nTunnel]); Exit;
  end;

  if not (nPTunnel.FEnable and nPTunnel.FHost.FEnable ) then Exit;
  //不启用,不发送

  i := 0;
  for nIdx:=Low(nPTunnel.FOut) to High(nPTunnel.FOut) do
    if nPTunnel.FOut[nIdx] <> cProber_NullASCII then Inc(i);
  //xxxxx

  if i < 1 then Exit;
  //无输出地址,表示不使用输出控制

  FSyncLock.Enter;
  try
    nCmd := gMemDataManager.LockData(FIDCommand);
    FCommand.Add(nCmd);
    nCmd.FTunnel := nPTunnel;
    nCmd.FCommand := cProber_Frame_RelaysOC;

    nData := gMemDataManager.LockData(FIDControl);
    nCmd.FData := nData;
    FillChar(nData^, cSize_Prober_Control, cProber_NullASCII);

    with nData.FHeader do
    begin
      FBegin := cProber_Flag_Begin;
      FLength := cProber_Len_Frame;
      FType := cProber_Frame_RelaysOC;

      if nOC then
           FExtend := nPTunnel.FHost.FOutSignalOn
      else FExtend := nPTunnel.FHost.FOutSignalOff;
    end;

    j := 0;
    for i:=Low(nPTunnel.FOut) to High(nPTunnel.FOut) do
    begin
      if nPTunnel.FOut[i] = cProber_NullASCII then Continue;
      //invalid out address

      nData.FData[j] := nPTunnel.FOut[i];
      Inc(j);
    end;

    WakeupReaders;
    //wake up thread
  finally
    FSyncLock.Leave;
  end;
end;

//Date：2014-5-13
//Parm：通道号
//Desc：对nTunnel执行吸合操作
function TProberManager.OpenTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, False);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date：2014-5-13
//Parm：通道号
//Desc：对nTunnel执行断开操作
function TProberManager.CloseTunnel(const nTunnel: string): Boolean;
var nStr: string;
begin
  nStr := TunnelOC(nTunnel, True);
  Result := nStr = '';

  if not Result then
    WriteLog(nStr);
  //xxxxxx
end;

//Date: 2014-07-03
//Parm: 通道号;启用
//Desc: 是否启用nTunnel通道
procedure TProberManager.EnableTunnel(const nTunnel: string;
  const nEnabled: Boolean);
var nPT: PProberTunnel;
begin
  nPT := GetTunnel(nTunnel);
  if Assigned(nPT) then
    nPT.FEnable := nEnabled;
  //xxxxx
end;

//Date：2014-5-14
//Parm：主机;查询类型;输入输出结果
//Desc：查询nHost的输入输出状态,存入nIn nOut.
function TProberManager.QueryStatus(const nHost: PProberHost;
  var nIn, nOut: TProberIOAddress): string;
var nIdx: Integer;
    nPH: PProberHost;
begin
  for nIdx:=Low(TProberIOAddress) to High(TProberIOAddress) do
  begin
    nIn[nIdx]  := nHost.FInSignalOn;
    nOut[nIdx] := nHost.FInSignalOn;
  end;

  FSyncLock.Enter;
  try
    for nIdx:=FHosts.Count - 1 downto 0 do
    begin
      nPH := FHosts[nIdx];
      //xxxxx

      if GetTickCount - nPH.FStatusL >= 2 * cProber_Query_Interval then
      begin
        Result := Format('车辆检测器[ %s ]状态查询超时.', [nHost.FName]);
        Exit;
      end;

      nIn := nPH.FStatusI;
      nOut := nPH.FStatusO;
      Result := ''; Exit;
    end;
  finally
    FSyncLock.Leave;
  end;

  Result := Format('车辆检测器[ %s ]已无效.', [nHost.FID]);
end;

//Date：2014-5-14
//Parm：通道号
//Desc：查询nTunnel的输入是否全部为无信号
function TProberManager.IsTunnelOK(const nTunnel: string): Boolean;
var nIdx,nNum: Integer;
    nPT: PProberTunnel;
begin
  if Trim(nTunnel) = '' then
  begin
    Result := True;
    Exit;
  end; //空通道默认正常

  Result := False;
  nPT := GetTunnel(nTunnel);

  if not Assigned(nPT) then
  begin
    WriteLog(Format('通道[ %s ]无效.',  [nTunnel]));
    Exit;
  end;

  if not (nPT.FEnable and nPT.FHost.FEnable) then
  begin
    Result := True;
    Exit;
  end;

  nNum := 0;
  for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
   if nPT.FIn[nIdx] <> cProber_NullASCII then Inc(nNum);
  //xxxxx

  if nNum < 1 then //无输入地址,标识不使用输入监测
  begin
    Result := True;
    Exit;
  end;

  FSyncLock.Enter;
  try
    if GetTickCount - nPT.FHost.FStatusL >= 2 * cProber_Query_Interval then
    begin
      WriteLog(Format('车辆检测器[ %s ]状态查询超时.', [nPT.FHost.FName]));
      Exit;
    end;

    for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
    begin
      if nPT.FIn[nIdx] = cProber_NullASCII then Continue;
      //invalid addr

      if nPT.FHost.FStatusI[nPT.FIn[nIdx] - 1] <> nPT.FHost.FInSignalOff then Exit;
      //某路输入有信号,认为车辆未停妥
    end;

    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2018-02-24
//Parm: 通道号;显示文本;屏号
//Desc: 在nTunnel通道的显示屏上显示nTxt文本
procedure TProberManager.ShowTxt(const nTunnel, nTxt: string; nNo: Integer);
var nPTunnel: PProberTunnel;
    nCmd: PProberTunnelCommand;
    nData: PProberFrameDataForward;
begin
  if Trim(nTunnel) = '' then
       nPTunnel := nil
  else nPTunnel := GetTunnel(nTunnel);

  if not Assigned(nPTunnel) then
  begin
    WriteLog(Format('通道[ %s ]无效.',  [nTunnel]));
    Exit;
  end;

  if nNo < 0 then
    nNo := nPTunnel.FScreen;
  if nNo < 0 then Exit;

  FSyncLock.Enter;
  try
    nCmd := gMemDataManager.LockData(FIDCommand);
    FCommand.Add(nCmd);
    nCmd.FTunnel := nPTunnel;
    nCmd.FCommand := cProber_Frame_DataForward;

    nData := gMemDataManager.LockData(FIDForward);
    nCmd.FData := nData;
    FillChar(nData^, cSize_Prober_Display, cProber_NullASCII);

    with nData.FHeader do
    begin
      FBegin := cProber_Flag_Begin;
      FLength := ConvertStr(Char($40) + Char(nNo) + nTxt + #13, nData.FData) + 4;
      FType := cProber_Frame_DataForward;
    end;

    WakeupReaders;
    //wake up thread
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
constructor TProberThread.Create(AOwner: TProberManager; AType: TProberThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;

  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cProber_Query_Interval;
end;

destructor TProberThread.Destroy;
begin
  FOwner.ClearCommandList(FBuffer, True);
  FWaiter.Free;
  inherited;
end;

procedure TProberThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TProberThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TProberThread.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveHost := nil;
    try
      Doexecute;
    finally
      with FOwner do
      try
        FSyncLock.Enter;
        //lock

        if Assigned(FActiveHost) then
          FActiveHost.FLocked := False;
        //xxxxx

        if FThreadType = ttActive then
        begin
          if FCommand.Count > 0 then
               FWaiter.Interval := 0
          else FWaiter.Interval := cProber_Query_Interval;
        end; //线程加速
      finally
        FSyncLock.Leave;
      end;

      if FBuffer.Count > 0 then
        FOwner.ClearCommandList(FBuffer, False);
      //clear buffer
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Date: 2015-12-06
//Parm: 活动&不活动读头
//Desc: 扫描nActive读头,若可用存入FActiveReader.
procedure TProberThread.ScanActiveHost(const nActive: Boolean);
var nIdx: Integer;
    nHost: PProberHost;
begin
  if nActive then //扫描活动读头
  with FOwner do
  begin
    if FHostActive = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FHostActive >= FHosts.Count then
      begin
        FHostActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nHost := FHosts[FHostActive];
      Inc(FHostActive);
      if nHost.FLocked or (not nHost.FEnable) then Continue;

      if nHost.FLastActive > 0 then
      begin
        FActiveHost := nHost;
        FActiveHost.FLocked := True;
        Break;
      end;
    end;
  end else

  with FOwner do //扫描不活动读头
  begin
    if FHostIndex = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FHostIndex >= FHosts.Count then
      begin
        FHostIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nHost := FHosts[FHostIndex];
      Inc(FHostIndex);
      if nHost.FLocked or (not nHost.FEnable) then Continue;

      if nHost.FLastActive = 0 then
      begin
        FActiveHost := nHost;
        FActiveHost.FLocked := True;
        Break;
      end;
    end;
  end;
end;

procedure TProberThread.DoExecute;
var nIdx: Integer;
    nCmd: PProberTunnelCommand;
begin
  with FOwner do
  try
    FSyncLock.Enter;
    //lock

    if FThreadType = ttAll then
    begin
      ScanActiveHost(False);
      //优先扫描不活动读头

      if not Assigned(FActiveHost) then
        ScanActiveHost(True);
      //辅助扫描活动项
    end else

    if FThreadType = ttActive then //只扫活动线程
    begin
      ScanActiveHost(True);
      //优先扫描活动读头

      if not Assigned(FActiveHost) then
        ScanActiveHost(False);
      //辅助扫描不活动项
    end;

    if Terminated or (not Assigned(FActiveHost)) then Exit;
    //invalid host

    for nIdx:=Low(FTunnels) to High(FTunnels) do
    with FTunnels[nIdx] do
    begin
      if FHost <> FActiveHost then Continue;
      //not match

      if (FLastOn > 0) and (GetTickCount - FLastOn >= FAutoOFF) then
      begin
        FLastOn := 0;
        TunnelOC(FTunnels[nIdx].FID, True);
      end;
    end; //auto off tunnel-out

    nIdx := 0;
    while nIdx < FCommand.Count do
    begin
      nCmd := FCommand[nIdx];
      if nCmd.FTunnel.FHost = FActiveHost then
      begin
        FBuffer.Add(nCmd);
        FCommand.Delete(nIdx);
      end else Inc(nIdx);
    end;
  finally
    FSyncLock.Leave;
  end;

  with FOwner do
  try
    SendHostCommand(FActiveHost);
    FActiveHost.FLastActive := GetTickCount;
  except
    on E:Exception do
    begin
      FActiveHost.FLastActive := 0;
      //置为不活动

      WriteLog(Format('Host:[ %s:%d ] Msg: %s', [FActiveHost.FHost,
        FActiveHost.FPort, E.Message]));
      //xxxxx

      CloseHostConn(FActiveHost);
      //force reconn
    end;
  end;
end;

procedure TProberThread.SendHostCommand(const nHost: PProberHost);
var nStr: string;
    nIdx,nSize: Integer;
    nBuf: TIdBytes;
    nCmd: PProberTunnelCommand;
begin
  if not nHost.FClient.Connected then
    nHost.FClient.Connect;
  //xxxxx

  if GetTickCount - nHost.FStatusL >= cProber_Query_Interval - 500 then
  begin
    FillChar(FQueryFrame, cSize_Prober_Control, cProber_NullASCII);
    //init

    with FQueryFrame.FHeader do
    begin
      FBegin  := cProber_Flag_Begin;
      FLength := cProber_Len_Frame;
      FType   := cProber_Frame_QueryIO;
      FExtend := cProber_Query_All;
    end;

    nBuf := RawToBytes(FQueryFrame, cSize_Prober_Control);
    nStr := SendData(nHost, nBuf, cSize_Prober_Control);
    //查询状态

    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    with FQueryFrame do
    try
      FOwner.FSyncLock.Enter;
      BytesToRaw(nBuf, FQueryFrame, cSize_Prober_Control);

      if FQueryFrame.FHeader.FType = cProber_Frame_QueryIO then
      begin
        Move(FData[0], nHost.FStatusI[0], cSize_Prober_IOAddr);
        Move(FData[cSize_Prober_IOAddr], nHost.FStatusO[0], cSize_Prober_IOAddr);
      end;

      nHost.FStatusL := GetTickCount;
      //更新时间
    finally
      FOwner.FSyncLock.Leave;
    end;
  end;

  nSize := 0; //init
  for nIdx:=FBuffer.Count - 1 downto 0 do
  begin
    nCmd := FBuffer[nIdx];
    if nCmd.FTunnel.FHost <> nHost then Continue;

    if nCmd.FCommand = cProber_Frame_DataForward then
    begin
      nSize := PProberFrameDataForward(nCmd.FData).FHeader.FLength + 1;
      nBuf := RawToBytes(PProberFrameDataForward(nCmd.FData)^, nSize);
      nSize := cSize_Prober_Control;
    end else
    begin
      if (nCmd.FTunnel.FLastOn > 0) and
         (PProberFrameControl(nCmd.FData).FHeader.FExtend =
                              nCmd.FTunnel.FHost.FOutSignalOn) then
      begin
        Continue;
        //启用自动关闭,禁用手动关闭指令
      end;

      nSize := cSize_Prober_Control;
      nBuf := RawToBytes(PProberFrameControl(nCmd.FData)^, nSize);
    end;

    nStr := SendData(nHost, nBuf, nSize);
    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    if (nCmd.FTunnel.FAutoOFF > 0) and
       (nCmd.FCommand = cProber_Frame_RelaysOC) then
    begin
      if PProberFrameControl(nCmd.FData).FHeader.FExtend =
                             nCmd.FTunnel.FHost.FOutSignalOff then
        nCmd.FTunnel.FLastOn := GetTickCount;
      //通道输出端最后打开时间
    end;
  end;
end;

//Date：2014-5-13
//Parm：主机;发送数据[in],应答数据[out];待接收长度
//Desc：向nHost发送nData数据,并接收应答
function TProberThread.SendData(const nHost: PProberHost; var nData: TIdBytes;
  const nRecvLen: Integer): string;
var nBuf: TIdBytes;
    nIdx,nLen: Integer;
begin
  Result := '';
  nLen := Length(nData);
  ProberVerifyData(nData, nLen, True);
  //添加异或校验

  SetLength(nBuf, nLen);
  CopyTIdBytes(nData, 0, nBuf, 0, nLen);
  //备份待发送内容

  nIdx := 0;
  while nIdx < FOwner.FRetry do
  try
    {$IFDEF DEBUG}
    LogHex(nBuf, '--> ');
    {$ENDIF}

    Inc(nIdx);
    nHost.FClient.IOHandler.Write(nBuf);
    //send data

    Sleep(120);
    //wait for

    if nRecvLen < 1 then Exit;
    //no data to receive

    SetLength(nData, 0);
    nHost.FClient.IOHandler.ReadBytes(nData, nRecvLen, False);
    //read respond

    {$IFDEF DEBUG}
    LogHex(nData, '<-- ');
    {$ENDIF}

    nLen := Length(nData);
    if (nLen = nRecvLen) and
       (nData[nLen-1] = ProberVerifyData(nData, nLen, False)) then Exit;
    //校验通过

    if nIdx = FOwner.FRetry then
    begin
      Result := '未从[ %s:%s.%d ]收到能通过校验的应答数据.';
      Result := Format(Result, [nHost.FName, nHost.FHost, nHost.FPort]);
    end;
  except
    on E: Exception do
    begin
      FOwner.CloseHostConn(nHost);
      //断开重连

      Inc(nIdx);
      if nIdx >= FOwner.FRetry then
        raise;
      //xxxxx
    end;
  end;
end;

//Date：2014-5-14
//Parm：通道号
//Desc：查询nTunnel的输入是否全部为无信号
function TProberManager.IsTunnelOKEx(const nTunnel: string): Boolean;
var nIdx,nNum: Integer;
    nPT: PProberTunnel;
    nStr: string;
    nBuf: TIdBytes;
    nQueryFrame: TProberFrameControl;
    nStatusI: TProberIOAddress;
begin
  if Trim(nTunnel) = '' then
  begin
    Result := True;
    Exit;
  end; //空通道默认正常

  Result := False;
  nPT := GetTunnel(nTunnel);

  if not Assigned(nPT) then
  begin
    WriteLog(Format('通道[ %s ]无效.',  [nTunnel]));
    Exit;
  end;

  if not (nPT.FEnable and nPT.FHost.FEnable) then
  begin
    Result := True;
    Exit;
  end;

  nNum := 0;
  for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
   if nPT.FIn[nIdx] <> cProber_NullASCII then Inc(nNum);
  //xxxxx

  if nNum < 1 then //无输入地址,标识不使用输入监测
  begin
    Result := True;
    Exit;
  end;

  FSyncLock.Enter;
  try
    try
      for nIdx:=Low(nStatusI) to High(nStatusI) do
      begin
        nStatusI[nIdx] := nPT.FHost.FInSignalOn;
        //init
      end;

      nPT.FHost.FClient.Disconnect;
      if not nPT.FHost.FClient.Connected then
        nPT.FHost.FClient.Connect;

      FillChar(nQueryFrame, cSize_Prober_Control, cProber_NullASCII);
      //init

      with nQueryFrame.FHeader do
      begin
        FBegin  := cProber_Flag_Begin;
        FLength := cProber_Len_Frame;
        FType   := cProber_Frame_QueryIO;
        FExtend := cProber_Query_All;
      end;

      nBuf := RawToBytes(nQueryFrame, cSize_Prober_Control);
      nStr := SendData(nPT.FHost, nBuf, cSize_Prober_Control);
      //查询状态
    except
      nStr := Format('通道[ %s ]状态查询失败.',  [nTunnel]);
    end;
    if nStr <> '' then
    begin
      WriteLog(nStr);
      Exit;
    end;

    with nQueryFrame do
    begin
      BytesToRaw(nBuf, nQueryFrame, cSize_Prober_Control);

      if nQueryFrame.FHeader.FType = cProber_Frame_QueryIO then
      begin
        Move(FData[0], nStatusI[0], cSize_Prober_IOAddr);
      end;

      nPT.FHost.FStatusL := GetTickCount;
      //更新时间
    end;

    nStr := '';
    for nIdx:=Low(nStatusI) to High(nStatusI) do
    begin
      nStr := nStr + IntToStr(nStatusI[nIdx]);
    end;
    WriteLog(nTunnel+'当前状态:'+ nStr);

    for nIdx:=Low(nPT.FIn) to High(nPT.FIn) do
    begin
      if nPT.FIn[nIdx] = cProber_NullASCII then Continue;
      //invalid addr

      if nStatusI[nPT.FIn[nIdx] - 1] <> nPT.FHost.FInSignalOff then Exit;
      //某路输入有信号,认为车辆未停妥
    end;

    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

function TProberManager.SendData(const nHost: PProberHost; var nData: TIdBytes;
  const nRecvLen: Integer): string;
var nBuf: TIdBytes;
    nIdx,nLen: Integer;
begin
  Result := '';
  nLen := Length(nData);
  ProberVerifyData(nData, nLen, True);
  //添加异或校验

  SetLength(nBuf, nLen);
  CopyTIdBytes(nData, 0, nBuf, 0, nLen);
  //备份待发送内容

  nIdx := 0;
  while nIdx < 2 do
  try
    {$IFDEF DEBUG}
    LogHex(nBuf);
    {$ENDIF}

    Inc(nIdx);
    nHost.FClient.IOHandler.Write(nBuf);
    //send data

    Sleep(120);
    //wait for

    if nRecvLen < 1 then Exit;
    //no data to receive

    nHost.FClient.IOHandler.ReadBytes(nData, nRecvLen, False);
    //read respond

    {$IFDEF DEBUG}
    LogHex(nData);
    {$ENDIF}

    nLen := Length(nData);
    if (nLen = nRecvLen) and
       (nData[nLen-1] = ProberVerifyData(nData, nLen, False)) then Exit;
    //校验通过

    if nIdx = 2 then
    begin
      Result := '未从[ %s:%s.%d ]收到能通过校验的应答数据.';
      Result := Format(Result, [nHost.FName, nHost.FHost, nHost.FPort]);
    end;
  except
    on E: Exception do
    begin

      Inc(nIdx);
      if nIdx >= 2 then
        raise;
      //xxxxx
    end;
  end;
end;

initialization
  gProberManager := nil;
finalization
  FreeAndNil(gProberManager);
end.
