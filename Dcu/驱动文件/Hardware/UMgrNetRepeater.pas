{*******************************************************************************
  作者: dmzn@163.com 2016-06-25
  描述: RJ45 - COM232 转发器通讯单元
*******************************************************************************}
unit UMgrNetRepeater;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, CPortTypes, IdGlobal, IdTCPClient,
  UWaitItem;

const
  cNR_Port_Num      = 4;
  cNR_Port_1        = $01;    //232 - 1
  cNR_Port_2        = $02;    //232 - 2
  cNR_Port_3        = $04;    //232 - 3
  cNR_Port_4        = $08;    //232 - 4

  cNR_CMD_SetParam  = $01;    //设置232
  cNR_CMD_GetParam  = $02;    //读取参数
  cNR_CMD_SetIP     = $03;    //设置地址
  cNR_CMD_SendData  = $10;    //发送数据
  cNR_CMD_RecvData  = $11;    //接收数据
                   
  cNR_Pack_Head     = $FF;    //协议头
  cNR_Pack_MaxData  = 200;    //数据上限

type
  PNRDataItem = ^TNRDataItem;
  TNRDataItem = record
    FHead: Byte;
    FLen: Byte;
    FPort: Byte;
    FCmd: Byte;
    FData: array[0..cNR_Pack_MaxData - 1] of Byte;
    FVerify: Byte;
  end;

  TNRRepeaterPort = record
    FEnable: Boolean;        //启用标识
    FPortID: Byte;           //端口编号
    FPortName: string;       //端口名称
    FGroup: string;          //端口分组

    FBaudRate: TBaudRate;    //波特率
    FDataBits: TDataBits;    //数据位
    FStopBits: TStopBits;    //停止位
    FParity: TParityBits;    //校验位
  end;

  PNRRepeaterHost = ^TNRRepeaterHost;
  TNRRepeaterHost = record
    FEnable: Boolean;        //启用标识
    FID: string;             //主机标识
    FHost: string;           //主机地址
    FPort: Integer;          //通讯端口
    FCOMPorts: array[0..cNR_Port_Num-1] of TNRRepeaterPort;

    FClient: TIdTCPClient;   //通讯链路
    FSendBuf: TList;         //待发送
    FSending: TList;         //发送缓存
    FRecvBuf: TNRDataItem;   //接收缓存
  end;

type
  TNRThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  TNetRepeaterManager = class;
  TNetRepeaterThread = class(TThread)
  private
    FOwner: TNetRepeaterManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FThreadType: TNRThreadType;
    //线程模式
    FActiveHost: PNRRepeaterHost;
    //当前读头
  protected
    procedure Execute; override;
    procedure DoExecute;
    //执行线程
    procedure ScanActiveHost(const nActive: Boolean);
    //扫描可用
    procedure SendHostCommand(const nHost: PNRRepeaterHost);
    function SendData(const nHost: PNRRepeaterHost; var nData: TIdBytes;
      const nRecvLen: Integer): string;
    //发送数据
  public
    constructor Create(AOwner: TNetRepeaterManager; AType: TNRThreadType);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启停通道
  end;

  TNetRepeaterManager = class(TObject)
  private
    FRetry: Byte;
    //重试次数
    FHosts: TList;
    //转发器
    FHostIndex: Integer;
    FHostActive: Integer;
    //读头索引
    FDataItem: Integer;
    //数据标识
    FReaders: array[0..1] of TNetRepeaterThread;
    //连接对象
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearCommandList(nList: TList; nFree: Boolean);
    procedure ClearHost(const nFree: Boolean);
    //清理数据
    procedure CloseHostConn(const nHost: PNRRepeaterHost);
    //关闭主机
    procedure RegisterDataType;
    //注册数据
    procedure WakeupReaders;
    //唤醒线程
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure StartRepeater;
    procedure StopRepeater;
    //启停检测器
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure SendData(const nHost: string; const nPort,nCmd: Byte;
      const nData: string = '');
    //发送数据
  end;

var
  gNetRepeaterManager: TNetRepeaterManager = nil;
  //全局使用

implementation

uses
  ULibFun, UMemDataPool, USysLoger;

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TNetRepeaterManager, '数据转发器', nEvent);
end;

//Desc: 对nData做异或校验
function RepeaterVerify(var nData: TIdBytes; const nDataLen: Integer; 
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

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nP: PNRDataItem;
begin
  New(nP);
  nData := nP;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
begin
  Dispose(PNRDataItem(nData));
end;

//Desc: 注册数据类型
procedure TNetRepeaterManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('NetRepeater Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
  begin
    FDataItem := RegDataType('NRDataItem', 'NetRepeater', OnNew, OnFree, 1);
  end;
end;

//------------------------------------------------------------------------------
constructor TNetRepeaterManager.Create;
begin
  FRetry := 2;
  FHosts := TList.Create;
  FSyncLock := TCriticalSection.Create;

  RegisterDataType;
  //由内存管理数据
end;

destructor TNetRepeaterManager.Destroy;
begin
  StopRepeater;
  ClearHost(True);
  FSyncLock.Free;
  
  gMemDataManager.UnregType(FDataItem);
  inherited;
end;

//Desc: 清理命令
procedure TNetRepeaterManager.ClearCommandList(nList: TList; nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    gMemDataManager.UnLockData(nList[nIdx]);
    nList.Delete(nIdx);
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

//Desc: 清理主机
procedure TNetRepeaterManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
    nItem: PNRRepeaterHost;
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

//Desc: 启动
procedure TNetRepeaterManager.StartRepeater;
var nIdx,nInt: Integer;
    nType: TNRThreadType;
begin
  nInt := 0;
  for nIdx:=FHosts.Count - 1 downto 0 do
   if PNRRepeaterHost(FHosts[nIdx]).FEnable then
    Inc(nInt);
  //count enable host
                            
  if nInt < 1 then Exit;
  FHostIndex := 0;
  FHostActive := 0;

  for nIdx:=Low(FReaders) to High(FReaders) do
  begin
    if nIdx >= nInt then Exit;
    //线程不超过启用主机数

    if nIdx = 0 then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FReaders[nIdx]) then
      FReaders[nIdx] := TNetRepeaterThread.Create(Self, nType);
    //xxxxx
  end;
end;

//Desc: 停止
procedure TNetRepeaterManager.StopRepeater;
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

//Desc: 关闭主机链路
procedure TNetRepeaterManager.CloseHostConn(const nHost: PNRRepeaterHost);
begin
  if Assigned(nHost) and Assigned(nHost.FClient) then
  begin
    nHost.FClient.Disconnect;
    if Assigned(nHost.FClient.IOHandler) then
      nHost.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Desc: 唤醒全部线程
procedure TNetRepeaterManager.WakeupReaders;
var nIdx: Integer;
begin
  for nIdx:=Low(FReaders) to High(FReaders) do
   if Assigned(FReaders[nIdx]) then
    FReaders[nIdx].Wakeup;
  //xxxxx
end;

//Date: 2016-06-25
//Parm: 主机;端口;命令;数据
//Desc: 将nCmd.nData发送至nHost.nPort
procedure TNetRepeaterManager.SendData(const nHost: string; const nPort,
  nCmd: Byte; const nData: string);
var nIdx: Integer;
    nPData: PNRDataItem;
    nPHost: PNRRepeaterHost;
begin
  nIdx := Length(nData);
  if nIdx > cNR_Pack_MaxData then
    raise Exception.Create(Format('Data is too long(%d>%d).', [nIdx, cNR_Pack_MaxData]));
  //xxxxx

  nPHost := nil;
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    nPHost := FHosts[nIdx];
    if CompareText(nHost, nPHost.FID) = 0 then
         Break
    else nPHost := nil;
  end;

  if not Assigned(nPHost) then
    raise Exception.Create(Format('Host "%s" is invalid.', [nHost]));
  //xxxxx

  FSyncLock.Enter;
  try
    nPData := gMemDataManager.LockData(FDataItem);
    nPHost.FSendBuf.Add(nPData);

    nPData.FHead := cNR_Pack_Head;
    nPData.FPort := nPort;
    nPData.FCmd := nCmd;

    nIdx := Length(nData);
    //BytesToRaw(nData, nPData.FData, nIdx);
    nPData.FLen := nPData.FLen + 3;

    WakeupReaders;
    //wake up thread
  finally
    FSyncLock.Leave;
  end;   
end;

procedure TNetRepeaterManager.LoadConfig(const nFile: string);
begin

end;

//------------------------------------------------------------------------------
constructor TNetRepeaterThread.Create(AOwner: TNetRepeaterManager;
  AType: TNRThreadType);
begin

end;

destructor TNetRepeaterThread.Destroy;
begin

  inherited;
end;

procedure TNetRepeaterThread.DoExecute;
begin

end;

procedure TNetRepeaterThread.Execute;
begin
  inherited;

end;

procedure TNetRepeaterThread.ScanActiveHost(const nActive: Boolean);
begin

end;

function TNetRepeaterThread.SendData(const nHost: PNRRepeaterHost;
  var nData: TIdBytes; const nRecvLen: Integer): string;
begin

end;

procedure TNetRepeaterThread.SendHostCommand(const nHost: PNRRepeaterHost);
begin

end;

procedure TNetRepeaterThread.StopMe;
begin

end;

procedure TNetRepeaterThread.Wakeup;
begin

end;

initialization
  gNetRepeaterManager := nil;
finalization
  FreeAndNil(gNetRepeaterManager);
end.
