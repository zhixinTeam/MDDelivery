{*******************************************************************************
  作者: dmzn@163.com 2010-11-22
  描述: 多道计数器管理

  备注:
  *.本单元实现了TCP模式的一机多装车道的计数管理器.
*******************************************************************************}
unit UMultiJS_Reply;

{$DEFINE DEBUG}

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, UMgrSync, UWaitItem, ULibFun,
  USysLoger, IdGlobal, IdTCPConnection, IdTCPClient, UMemDataPool;

const   
  cMultiJS_Truck           = 8;         //车牌长度
  cMultiJS_DaiNum          = 5;         //袋数长度
  cMultiJS_Delay           = 9;         //最大延迟
  cMultiJS_Tunnel          = 8;        	//最大道数
  cMultiJS_CmdInterval     = 20;        //命令间隔
  cMultiJS_FreshInterval   = 1200;      //刷新频率
  cMultiJS_SaveInterval    = 20 * 1000; //保存频率

  cFrame_Control           = $05;       //控制帧
  cFrame_Pasuse            = $06;       //暂停帧
  cFrame_Query             = $12;       //查询帧
  cFrame_Clear             = $27;       //清理帧

  cMultiJSData             = 'MultiJSData';
type
  TMultiJSManager = class;
  TMultJSItem = class;

  PMultiJSTunnel = ^TMultiJSTunnel;
  TMultiJSTunnel = record
    FID: string;
    FName: string;    
    //通道标识
    FTunnel: Word;
    //车道编号
    FDelay: Word;
    //延迟时间
    FGroup: string;
    //通道分组
    FReader: string;
    //读头地址
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    //车牌号
    FDaiNum: Word;
    //需装袋数
    FHasDone: Word;
    //已装袋数
    FIsRun: Boolean;
    //运行标记
    FUseBanDao: Boolean;
    FBanDaoNum: Integer;
    //扳道相关
    FLastBill: string;
    FLastSaveDai: Word;
    //上次保存
    FExtData: Pointer;
    //附加数据
  end;

  PMultiJSHost= ^TMultiJSHost;
  TMultiJSHost = record
    FName: string;
    FHostIP: string;
    FHostPort: Integer;
    //主机信息
    F485Addr: Byte;
    //链路地址
    FTunnelNum: Byte;
    //有效道数
    FTunnel: TList;
    //车道数据
    FReader: TMultJSItem;
    //操作线程
  end;

  TMultiJSPeerSendControl = record
    FAddr: Byte;
    FDelay: Byte;
    FTruck: array[0..cMultiJS_Truck - 1] of Char;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataSend = ^TMultiJSDataSend;
  TMultiJSDataSend = record
    FHeader : array[0..1] of Byte;    //帧头
    FAddr   : Byte;                   //485地址
    FType   : Byte;                   //控制,查询
    FData   : TMultiJSPeerSendControl;//有效数据
    FCRC    : Byte;
    FEnd    : Byte;                   //结束帧
  end;

  TMultiJSPeerRecv = record
    FAddr: Byte;
    FDai: array[0..cMultiJS_DaiNum - 1] of Char;
  end;

  PMultiJSDataRecv = ^TMultiJSDataRecv;
  TMultiJSDataRecv = record
    FHeader : array[0..1] of Char;    //帧头
    FAddr   : Byte;                   //485地址
    FType   : Byte;                   //控制,查询
    FData   : array[0..cMultiJS_Tunnel - 1] of TMultiJSPeerRecv;
    FCRC    : Byte;
    FEnd    : Byte;                   //结束帧
  end;

  TMultiJSAction = (faControl, faPasuse, faQuery, faClear);
  //帧动作: 控制,暂停,查询,清除

  TMultiJSDataOwner = (soIgnore, soCaller, soThread);
  //数据管理: 忽略,呼叫方,服务线程 

  PMultiJSDataItem = ^TMultiJSDataItem;
  TMultiJSDataItem = record
    FEnable : Boolean;                  //是否启用
    FAction : TMultiJSAction;           //执行动作
    FOwner: TMultiJSDataOwner;          //释放方式

    FDataStr: string;                   //字符数据
    FDataBool: Boolean;                 //布尔数据
    FTunnel: TMultiJSTunnel;            //通道数据

    FResultStr : string;                //字符返回
    FResultBool: Boolean;               //布尔返回
    FWaiter: TWaitObject;               //等待对象
  end;

  TMultJSItem = class(TThread)
  private
    FOwner: TMultiJSManager;
    //拥有者
    FHost: PMultiJSHost;
    //计数器
    FClient: TIdTCPClient;
    //客户端
    FTmpList: TList;
    FBuffer: TList;
    //发送缓冲
    FRecv: TMultiJSDataRecv;
    //接收缓冲
    FNowTunnel: PMultiJSTunnel;
    //当前通道
    FWaiter: TWaitObject;
    //等待对象
    FLastSave: Cardinal;
    //上次保存
  protected
    procedure Execute; override;
    //线程体
    procedure ClearBuffer(const nList: TList; const nFree: Boolean = False);
    //清空缓冲
    procedure DeleteMultiJSDataItem(const nData: PMultiJSDataItem;
              nList: TList; const nLock: Boolean = True);
    //删除指令          
    procedure DeleteFromBuffer(nAddr: Byte; nList: TList);
    //删除指令
    procedure AddQueryFrame(const nList: TList);
    //查询指令
    procedure SendDataFrame(const nItem: PMultiJSDataItem);
    //发送数据
    procedure ApplyRespondData;
    //更新袋数
    function GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
    //检索通道
    procedure SyncNowTunnel;
    //同步通道
  public
    constructor Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //停止线程
  end;

  TMultiJSEvent = procedure (const nTunnel: PMultiJSTunnel) of object;
  //事件
  TMultiJSProc = procedure (const nTunnel: PMultiJSTunnel);
  //动作
  TMultiJSGetTruck = function (const nTruck,nBill: string): string;
  //获取车牌

  TMultiJSManager = class(TObject)
  private
    FEnableQuery: Boolean;
    //计数查询
    FEnableCount: Boolean;
    //开启计数
    FEnableChain: Boolean;
    //开启连锁
    FHosts: TList;
    //主机列表
    FFileName: string;
    //配置文件
    FLogCtrlFrame: Boolean;
    //记录控制帧
    FIDMultiJSData: Integer;
    //线程数据
    FSyncLock: TCriticalSection;
    //同步锁定
    FChangeThread: TMultiJSEvent;
    FChangeThreadProc: TMultiJSProc;
    FChangeSync: TMultiJSEvent;
    FChangeSyncProc: TMultiJSProc;
    FSaveDataProc: TMultiJSProc;
    FSaveDataEvent: TMultiJSEvent;
    FGetTruck: TMultiJSGetTruck;
    //事件相关
  protected
    procedure DisposeHost(const nHost: PMultiJSHost);
    procedure ClearHost(const nFree: Boolean);
    //清理数据
    function GetTunnel(const nID: string; var nHost: PMultiJSHost;
      var nTunnel: PMultiJSTunnel): Boolean;
    //检索通道   
    procedure RegisterDataType;
    //注册数据
    function NewMultiJSData(const nInterval: Integer): PMultiJSDataItem;
    //新建数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadFile(const nFile: string);
    //读取配置
    procedure StartJS;
    procedure StopJS;
    //启停计数
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
    property Hosts: TList read FHosts;
    property FileName: string read FFileName;
    property QueryEnable: Boolean read FEnableQuery write FEnableQuery;
    property CountEnable: Boolean read FEnableCount write FEnableCount;
    property ChainEnable: Boolean read FEnableChain write FEnableChain;
    property ChangeSync: TMultiJSEvent read FChangeSync write FChangeSync;
    property ChangeSyncProc: TMultiJSProc read FChangeSyncProc write FChangeSyncProc;
    property ChangeThread: TMultiJSEvent read FChangeThread write FChangeThread;
    property ChangeThreadProc: TMultiJSProc read FChangeThreadProc write FChangeThreadProc;
    property SaveDataProc: TMultiJSProc read FSaveDataProc write FSaveDataProc;
    property SaveDataEvent: TMultiJSEvent read FSaveDataEvent write FSaveDataEvent;
    property GetTruckProc: TMultiJSGetTruck read FGetTruck write FGetTruck;
    property LogControlFrame: Boolean read FLogCtrlFrame write FLogCtrlFrame;
    //属性相关
  end;

var
  gMultiJSManager: TMultiJSManager = nil;
  //全局使用

implementation

const
  cSizeHost         = SizeOf(TMultiJSHost);
  cSizeTunnel       = SizeOf(TMultiJSTunnel);
  cSizeDataSend     = SizeOf(TMultiJSDataSend);
  cSizeDataRecv     = SizeOf(TMultiJSDataRecv);
  cSizePeerRecv     = SizeOf(TMultiJSPeerRecv);
                                             
//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMultiJSManager, '多道计数管理器', nEvent);
end;  

constructor TMultJSItem.Create(AOwner: TMultiJSManager; nHost: PMultiJSHost);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FHost := nHost;
  FLastSave := 0;
  
  FTmpList := TList.Create;
  FBuffer := TList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cMultiJS_FreshInterval;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor TMultJSItem.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  ClearBuffer(FBuffer, True);
  ClearBuffer(FTmpList, True);

  FWaiter.Free;
  inherited;
end;

procedure TMultJSItem.ClearBuffer(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=nList.Count - 1 downto 0 do
    DeleteMultiJSDataItem(PMultiJSDataItem(nList[nIdx]), nList);
  //删除数据  

  if nFree then
    nList.Free;
  //xxxx
end;

//Date: 2012-4-23
//Parm: 通道编号;列表
//Desc: 从nList中删除标识为nTunnel的数据
procedure TMultJSItem.DeleteFromBuffer(nAddr: Byte; nList: TList);
var nIdx: Integer;
    nData: PMultiJSDataItem;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nData := nList[nIdx];
    if nData.FTunnel.FTunnel = nAddr then
      DeleteMultiJSDataItem(nData, nList, False);
  end;
end;

procedure TMultJSItem.DeleteMultiJSDataItem(const nData: PMultiJSDataItem;
  nList: TList; const nLock: Boolean);
var nIdx: Integer;
begin
  if nLock then FOwner.FSyncLock.Enter;
  try
    gMemDataManager.UnLockData(nData);
    nIdx := nList.IndexOf(nData);

    if nIdx >= 0 then
      nList.Delete(nIdx);
    //xxxxx
  finally
    if nLock then FOwner.FSyncLock.Leave;
  end;
end;

//Desc: 释放线程
procedure TMultJSItem.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Desc: 唤醒线程
procedure TMultJSItem.Wakeup;
begin
  FWaiter.Wakeup;
end;

//Desc: 线程体
procedure TMultJSItem.Execute;
var nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    try
      if not FClient.Connected then
      begin
        FClient.Host := FHost.FHostIP;
        FClient.Port := FHost.FHostPort;
        FClient.Connect;
      end;
    except
      WriteLog(Format('连接计数器[ %s ]失败', [FHost.FHostIP]));
      FClient.Disconnect;
      Continue;
    end;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FBuffer.Count - 1 do
        FTmpList.Add(FBuffer[nIdx]);
      FBuffer.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    if (FTmpList.Count < 1) and FOwner.FEnableQuery then
      AddQueryFrame(FTmpList);
    //添加查询帧

    if FTmpList.Count > 0 then
    try
      FClient.Socket.InputBuffer.Clear;
      //清空缓冲

      for nIdx:=0 to FTmpList.Count - 1 do
      begin
        SendDataFrame(FTmpList[nIdx]);
        //发送数据帧

        if nIdx < FTmpList.Count - 1 then
          Sleep(cMultiJS_FreshInterval);
        //多帧发送时需延时
      end;
         
      ClearBuffer(FTmpList);
    except
      ClearBuffer(FTmpList);
      FClient.Disconnect;
      
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      raise;
    end;
  except
    On E:Exception do
    begin
      WriteLog(Format('Host:[ %s ] %s', [FHost.FHostIP, E.Message]));
    end;
  end;
end;

//Desc: 在nList中添加查询帧
procedure TMultJSItem.AddQueryFrame(const nList: TList);
var nItem: PMultiJSDataItem;
begin
  nItem := FOwner.NewMultiJSData(10 * 1000); //10s
  nList.Add(nItem);
  nItem.FAction := faQuery;
  nItem.FOwner  := soThread;
end;

function CalcCRC(const nData: string): Byte;
var nIdx: Integer;
begin
  Result := $00;

  for nIdx := 0 to Length(nData) do
    Result := Result xor Ord(nData[nIdx]);
end;  

//Desc: 发送数据
procedure TMultJSItem.SendDataFrame(const nItem: PMultiJSDataItem);
var nBuf: TIdBytes;
    nSize: Integer;
    nStr, nData: string;
    nSend: TMultiJSDataSend;
begin
  if not nItem.FEnable then Exit;
  nItem.FEnable := False;

  FillChar(nSend, cSizeDataSend, #0);
  with nSend do
  begin
    FHeader[0] := $0A;
    FHeader[1] := $55;
    FAddr := FHost.F485Addr;

    FType := cFrame_Query;
    FEnd := $0D;
  end;  

  case nItem.FAction of
  faControl :
  begin
    nSend.FType := cFrame_Control;
    //设置类型

    with nSend.FData do
    begin
      FAddr := nItem.FTunnel.FTunnel;
      FDelay := nItem.FTunnel.FDelay;
      StrCopy(FTruck, nItem.FTunnel.FTruck);

      nStr := IntToStr(nItem.FTunnel.FDaiNum);
      nStr := StringOfChar('0', cMultiJS_DaiNum - Length(nStr)) + nStr;
      StrPCopy(@FDai[0], nStr);
    end;

    nData := Char(nSend.FHeader[0]) + Char(nSend.FHeader[1]) +
             Char(nSend.FAddr) + Char(nSend.FType) + Char(nSend.FData.FAddr) +
             Char(nSend.FData.FDelay) + nSend.FData.FTruck + nSend.FData.FDai;

    nData := nData + Char(CalcCRC(nData)) + Char(nSend.FEnd);
    //计算CRC + End
    FClient.Socket.Write(nData, Indy8BitEncoding);
    //合成发送

    FClient.Socket.ReadBytes(nBuf, 10, False);
    nData := BytesToString(nBuf, Indy8BitEncoding);

    nItem.FResultStr := Copy(nData, 7, 3);
    if UpperCase(nItem.FResultStr) = 'YES' then
         nItem.FResultBool := True
    else nItem.FResultBool := False;

    if Assigned(nItem.FWaiter) then
      nItem.FWaiter.Wakeup();
    //xxxxx
  end;
  faPasuse :
  begin
    nSend.FType := cFrame_Pasuse;
    //设置类型

    with nSend.FData do
    begin
      FAddr := nItem.FTunnel.FTunnel;
    end;

    nData := Char(nSend.FHeader[0]) + Char(nSend.FHeader[1]) +
             Char(nSend.FAddr) + Char(nSend.FType) + Char(nSend.FData.FAddr);

    if nItem.FDataBool then
         nData := nData + Char($02)
    else nData := nData + Char($01);
    //暂停指令的起停位

    nData := nData + Char(CalcCRC(nData)) + Char(nSend.FEnd);
    //计算CRC + End
    FClient.Socket.Write(nData, Indy8BitEncoding);
    //合成发送

    FClient.Socket.ReadBytes(nBuf, 10, False);
    nData := BytesToString(nBuf, Indy8BitEncoding);

    nItem.FResultStr := Copy(nData, 7, 3);
    if UpperCase(nItem.FResultStr) = 'YES' then
         nItem.FResultBool := True
    else nItem.FResultBool := False;

    if Assigned(nItem.FWaiter) then
      nItem.FWaiter.Wakeup();
    //xxxxx
  end;
  faQuery :
  begin
    nSend.FType := cFrame_Query;
    //设置类型

    nData := Char(nSend.FHeader[0]) + Char(nSend.FHeader[1]) + 
             Char(nSend.FAddr) + Char(nSend.FType) + Char(nSend.FEnd);
    //合成发送
    FClient.Socket.Write(nData, Indy8BitEncoding);

    if FOwner.FLogCtrlFrame then
      WriteLog(nData);

    nSize := cSizeDataRecv - (cMultiJS_Tunnel - FHost.FTunnelNum) * cSizePeerRecv;
    FClient.Socket.ReadBytes(nBuf, nSize, False);
    BytesToRaw(nBuf, FRecv, nSize);

    if Assigned(nItem.FWaiter) then
      nItem.FWaiter.Wakeup();
    //xxxxx

    nItem.FResultBool := True;
    ApplyRespondData;
    //apply data
  end;
  faClear :
  begin
    nSend.FType := cFrame_Clear;
    //设置类型

    with nSend.FData do
    begin
      FAddr := nItem.FTunnel.FTunnel;
    end;

    nData := Char(nSend.FHeader[0]) + Char(nSend.FHeader[1]) +
             Char(nSend.FAddr) + Char(nSend.FType) + Char(nSend.FData.FAddr);

    nData := nData + Char(CalcCRC(nData)) + Char(nSend.FEnd);
    //计算CRC + End
    FClient.Socket.Write(nData, Indy8BitEncoding);
    //合成发送

    FClient.Socket.ReadBytes(nBuf, 10, False);
    nData := BytesToString(nBuf, Indy8BitEncoding);
    //读信息

    nItem.FResultStr := Copy(nData, 7, 3);
    if UpperCase(nItem.FResultStr) = 'YES' then
         nItem.FResultBool := True
    else nItem.FResultBool := False;

    if Assigned(nItem.FWaiter) then
      nItem.FWaiter.Wakeup();
    //xxxxx
  end;       
  end;
end;

//Desc: 同步当前通道
procedure TMultJSItem.SyncNowTunnel;
begin
  if Assigned(FOwner.FChangeSync) then
    FOwner.FChangeSync(FNowTunnel);
  //xxxxx

  if Assigned(FOwner.FChangeSyncProc) then
    FOwner.FChangeSyncProc(FNowTunnel);
  //xxxxx
end;

//Desc: 更新袋数变更情况
procedure TMultJSItem.ApplyRespondData;
var nBool: Boolean;
    nIdx,nInt: Integer;
    nTunnel: PMultiJSTunnel;
begin
  nBool := GetTickCountDiff(FLastSave) >= cMultiJS_SaveInterval;
  if nBool then
    FLastSave := GetTickCount;
  //reset save time

  for nIdx:=0 to FHost.FTunnelNum - 1 do
  begin
    nTunnel := GetTunnel(FRecv.FData[nIdx].FAddr);
    if not Assigned(nTunnel) then Continue;

    try
      if nTunnel.FUseBanDao then
      begin
        nInt := StrToInt(FRecv.FData[nIdx].FDai[0]);
        nTunnel.FBanDaoNum := nInt;
        FRecv.FData[nIdx].FDai[0] := '0';
      end;

      nInt := StrToInt(FRecv.FData[nIdx].FDai);
      //tunnel's num
      
      if nTunnel.FHasDone < nInt then
      begin
        FOwner.FSyncLock.Enter;
        try
          if nInt >= nTunnel.FDaiNum then
               nTunnel.FIsRun := False
          else nTunnel.FIsRun := True;
          
          nTunnel.FHasDone := nInt;
          //now dai num
        finally
          FOwner.FSyncLock.Leave;
        end;

        if Assigned(FOwner.FChangeThread) then
          FOwner.FChangeThread(nTunnel);
        //thread event

        if Assigned(FOwner.FChangeThreadProc) then
          FOwner.FChangeThreadProc(nTunnel);
        //thread proc

        if Assigned(FOwner.FChangeSync) or Assigned(FOwner.FChangeSyncProc) then
        begin
          FNowTunnel := nTunnel;
          Synchronize(SyncNowTunnel);
        end;
      end;

      if nBool and FOwner.FEnableQuery then
      begin
        if Assigned(FOwner.FSaveDataEvent) then
          FOwner.FSaveDataEvent(nTunnel);
        //xxxxx

        if Assigned(FOwner.FSaveDataProc) then
          FOwner.FSaveDataProc(nTunnel);
        //xxxxx

        nTunnel.FLastSaveDai := nTunnel.FHasDone;
        //enable query means enable auto_save
      end;
    except
      on E: Exception do
      begin
        WriteLog(Format('Host:[ %s.%s ] %s', [FHost.FHostIP, nTunnel.FID, E.Message]));
      end;
    end;
  end;
end;

//Date: 2012-4-23
//Parm: 通道号
//Desc: 检索nTunnel通道
function TMultJSItem.GetTunnel(const nTunnel: Byte): PMultiJSTunnel;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=0 to FHost.FTunnel.Count - 1 do
  if PMultiJSTunnel(FHost.FTunnel[nIdx]).FTunnel = nTunnel then
  begin
    Result := FHost.FTunnel[nIdx];
    Exit;
  end;
end;

//------------------------------------------------------------------------------
constructor TMultiJSManager.Create;
begin
  RegisterDataType;
  //do first

  FEnableQuery := False;
  FEnableCount := False;
  FEnableChain := True;
  FLogCtrlFrame := False;

  FHosts := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TMultiJSManager.Destroy;
begin
  StopJS;
  ClearHost(True);

  FSyncLock.Free;
  inherited;
end;


procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nItem: PMultiJSDataItem;
begin
  if nFlag = cMultiJSData then
  begin
    New(nItem);
    nData := nItem;
    nItem.FWaiter := nil;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
var nItem: PMultiJSDataItem;
begin
  if nFlag = cMultiJSData then
  begin
    nItem := nData;
    if Assigned(nItem.FWaiter) then
      FreeAndNil(nItem.FWaiter);
    Dispose(nItem);
  end;
end;

procedure TMultiJSManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('MultiJSManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
    FIDMultiJSData := RegDataType(cMultiJSData, 'MultiJSManager', OnNew, OnFree, 2);
  //xxxxx
end;

//Date: 2016-09-13
//Parm: 等待对象间隔
//Desc: 新建服务数据项
function TMultiJSManager.NewMultiJSData(const nInterval: Integer): PMultiJSDataItem;
begin
  Result := gMemDataManager.LockData(FIDMultiJSData);
  with Result^ do
  begin
    FEnable := True;
    FAction := faQuery;
    FOwner := soCaller;

    FDataStr := '';
    FDataBool := False;

    FResultStr  := '';
    FResultBool := False;
    
    if nInterval > 0 then
    begin
      if not Assigned(FWaiter) then
        FWaiter := TWaitObject.Create;
      FWaiter.Interval := nInterval;
    end;
  end;
end;

//Desc: 释放nData端口
procedure TMultiJSManager.DisposeHost(const nHost: PMultiJSHost);
var nIdx: Integer;
begin
  for nIdx:=nHost.FTunnel.Count - 1 downto 0 do
  begin
    Dispose(PMultiJSTunnel(nHost.FTunnel[nIdx]));
    nHost.FTunnel.Delete(nIdx);
  end;

  nHost.FTunnel.Free;
  Dispose(nHost);
end;

//Desc: 清理端口数据
procedure TMultiJSManager.ClearHost(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FHosts.Count - 1 downto 0 do
  begin
    DisposeHost(FHosts[nIdx]);
    FHosts.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FHosts);
  //xxxxx
end;

//Desc: 启动计数
procedure TMultiJSManager.StartJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  if FEnableCount then
  begin
    for nIdx:=0 to FHosts.Count - 1 do
    begin
      nHost := FHosts[nIdx];
      if Assigned(nHost.FReader) then Continue;

      nHost.FReader := TMultJSItem.Create(Self, nHost);
      //new reader
    end;
  end;
end;

//Desc: 停止计数
procedure TMultiJSManager.StopJS;
var nIdx: Integer;
    nHost: PMultiJSHost;
begin
  for nIdx:=0 to FHosts.Count - 1 do
  begin
    nHost := FHosts[nIdx];
    if Assigned(nHost.FReader) then
    begin
      nHost.FReader.StopMe;
      nHost.FReader := nil;
    end;
  end;
end;

//Desc: 读取计数配置
procedure TMultiJSManager.LoadFile(const nFile: string);
var i,nIdx: Integer;
    nNode,nTmp,nTN: TXmlNode;
    nXML: TNativeXml;
    nHost: PMultiJSHost;
    nTunnel: PMultiJSTunnel;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearHost(False);
    nXML.LoadFromFile(nFile);

    nTmp := nXML.Root.FindNode('config');
    if Assigned(nTmp) then
    begin
      nIdx := nTmp.NodeByName('query').ValueAsInteger;
      FEnableQuery := nIdx = 1;

      nIdx := nTmp.NodeByName('count').ValueAsInteger;
      FEnableCount := nIdx = 1;

      nNode := nTmp.NodeByName('chain');
      if Assigned(nNode) then
        FEnableChain := nNode.ValueAsInteger <> 0;
      //xxxxx
    end;

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nTmp := nXML.Root.Nodes[nIdx];
      if nTmp.Name <> 'item' then Continue;
      
      New(nHost);
      FHosts.Add(nHost);

      with nHost^ do
      begin
        FName := nTmp.AttributeByName['name'];
        nNode := nTmp.NodeByName('param');

        FHostIP := nNode.NodeByName('ip').ValueAsString;
        FHostPort := nNode.NodeByName('port').ValueAsInteger;
        F485Addr := nNode.NodeByName('addr').ValueAsInteger;

        FTunnelNum := nNode.NodeByName('linenum').ValueAsInteger;
        if FTunnelNum > cMultiJS_Tunnel then
          FTunnelNum := cMultiJS_Tunnel;
        //has max

        FTunnel := TList.Create;
        FReader := nil;
      end;

      nTmp := nTmp.NodeByName('lines');
      for i:=0 to nTmp.NodeCount - 1 do
      begin
        nNode := nTmp.Nodes[i];
        New(nTunnel);
        nHost.FTunnel.Add(nTunnel);

        FillChar(nTunnel^, cSizeTunnel, #0);
        //init
        
        with nTunnel^ do
        begin
          FID := nNode.NodeByName('id').ValueAsString;
          FName := nNode.NodeByName('name').ValueAsString;
          FTunnel := nNode.NodeByName('tunnel').ValueAsInteger;
          FDelay := nNode.NodeByName('delay').ValueAsInteger;

          nTN := nNode.FindNode('group');
          if Assigned(nTN) then
               FGroup := nTN.ValueAsString
          else FGroup := '';

          FExtData := nil;
          nTN := nNode.FindNode('switch');
          if Assigned(nTN) then
               FUseBanDao := nTN.ValueAsInteger = 1
          else FUseBanDao := False;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2012-4-23
//Parm: 通道标识
//Desc: 检索nID通道
function TMultiJSManager.GetTunnel(const nID: string; var nHost: PMultiJSHost;
  var nTunnel: PMultiJSTunnel): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  Result := False;
  nHost := nil;
  nTunnel := nil; 

  for i:=0 to FHosts.Count - 1 do
  begin
    nPHost := FHosts[i];
    for nIdx:=0 to nPHost.FTunnel.Count - 1 do
    begin
      nPTunnel := nPHost.FTunnel[nIdx];
      if CompareText(nID, nPTunnel.FID) = 0 then
      begin
        nHost := nPHost;
        nTunnel := nPTunnel;

        Result := True;
        Exit;
      end;
    end;
  end;
end;

//Date: 2012-4-23
//Parm: 通道标识;车牌;袋数
//Desc: 在nTunnel添加一个计数操作
function TMultiJSManager.AddJS(const nTunnel, nTruck, nBill: string;
  nDaiNum: Integer; const nDelJS: Boolean): Boolean;
var nStr: string;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nItem: PMultiJSDataItem;
begin
  Result := False;
  if not FEnableCount then Exit;

  if (not FEnableChain) or nDelJS then
    if not DelJS(nTunnel) then Exit;
  //停止计数

  Sleep(cMultiJS_CmdInterval);
  FSyncLock.Enter;
  try
    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //通道无效

    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nPH.FReader.FBuffer);
    //覆盖未执行命令

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
    nPT.FIsRun := nPT.FGroup <> '';

    nItem := NewMultiJSData(10 * 1000); //10s
    nPH.FReader.FBuffer.Add(nItem);

    nItem.FAction := faControl;
    nItem.FDataStr := nTunnel;
    nItem.FTunnel := nPT^;

    nPH.FReader.Wakeup;
    //线程即时
  finally
    FSyncLock.Leave;
  end;

  nItem.FWaiter.EnterWait;
  //wait for result

  if nItem.FWaiter.IsTimeout then
       Result := False
  else Result := nItem.FResultBool;

  nPH.FReader.DeleteMultiJSDataItem(nItem, nPH.FReader.FBuffer);

  {$IFDEF DEBUG}
  WriteLog('AddJS:::' + nItem.FResultStr);
  {$ENDIF}
end;

//Date: 2013-07-16
//Parm: 通道标识
//Desc: 暂停nTunnel通道
function TMultiJSManager.PauseJS(const nTunnel: string; const nOC: Boolean): Boolean;
var nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nItem: PMultiJSDataItem;
begin
  FSyncLock.Enter;
  try
    Result := False;
    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //通道无效

    nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nPH.FReader.FBuffer);
    //覆盖未执行命令

    nItem := NewMultiJSData(10 * 1000); //10s
    nPH.FReader.FBuffer.Add(nItem);

    nItem.FAction := faPasuse;
    nItem.FTunnel := nPT^;
    nItem.FDataBool := nOC;

    nPH.FReader.Wakeup;
    //线程即时
  finally
    FSyncLock.Leave;
  end;

  nItem.FWaiter.EnterWait;
  //wait for result

  if nItem.FWaiter.IsTimeout then
       Result := False
  else Result := nItem.FResultBool;

  nPH.FReader.DeleteMultiJSDataItem(nItem, nPH.FReader.FBuffer);
  {$IFDEF DEBUG}
  WriteLog('PauseJS:::' + nItem.FResultStr);
  {$ENDIF}
end;

//Date: 2012-4-23
//Parm: 通道号
//Desc: 停止nTunnel计数
function TMultiJSManager.DelJS(const nTunnel: string; const nBuf: TList): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nList: TList;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
    nItem: PMultiJSDataItem;
begin
  FSyncLock.Enter;
  try
    Result := False;
    //default

    if not (GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader)) then Exit;
    //通道数据无效

    if Assigned(nBuf) then
    begin
      nList := nBuf;
    end else
    begin
      nList := nPH.FReader.FBuffer;
      nPH.FReader.DeleteFromBuffer(nPT.FTunnel, nList);
      //覆盖未执行命令
    end;

    nItem := NewMultiJSData(10 * 1000); //10s
    nList.Add(nItem);

    nItem.FAction := faClear;
    nItem.FTunnel := nPT^;

    nPH.FReader.Wakeup;
    //线程即时
  finally
    FSyncLock.Leave;
  end;

  nItem.FWaiter.EnterWait;
  //wait for result

  if nItem.FWaiter.IsTimeout then
       Result := False
  else Result := nItem.FResultBool;

  nPH.FReader.DeleteMultiJSDataItem(nItem, nList);
  //清除数据

  {$IFDEF DEBUG}
  WriteLog('DelJS:::' + nItem.FResultStr);
  {$ENDIF}
  if not Result then Exit;
  
  if nPT.FGroup = '' then
  begin
    nPT.FIsRun := False;
    //运行标记
    Exit;
  end;

  nStr := nPT.FGroup;
  for i:=0 to FHosts.Count - 1 do
  begin
    nPH := FHosts[i];
    for nIdx:=0 to nPH.FTunnel.Count - 1 do
    begin
      nPT := nPH.FTunnel[nIdx];
      //xxxxx

      if (CompareText(nStr, nPT.FGroup) = 0) and Assigned(nPH.FReader) then
        nPT.FIsRun := False;
      //撤销同一分组的运行标记
    end;
  end;
end;

//Date: 2013-07-17
//Parm: 通道标识;锁定为查询;值
//Desc: 判断nTunnel是否计数完毕
function TMultiJSManager.IsJSRun(const nTunnel: string): Boolean;
var nStr: string;
    i,nIdx: Integer;
    nPH: PMultiJSHost;
    nPT: PMultiJSTunnel;
begin
  if not FEnableChain then
  begin
    Result := False;
    Exit;
  end; //不启用连锁,则不处理状态

  FSyncLock.Enter;
  try
    if GetTunnel(nTunnel, nPH, nPT) and Assigned(nPH.FReader) then
         Result := nPT.FIsRun
    else Result := False;

    if Result or (not Assigned(nPT)) then Exit;
    //run,or no tunnel

    if nPT.FGroup = '' then
      Exit; //no group    
    nStr := nPT.FGroup;

    for i:=0 to FHosts.Count - 1 do
    begin
      nPH := FHosts[i];
      for nIdx:=0 to nPH.FTunnel.Count - 1 do
      begin
        nPT := nPH.FTunnel[nIdx];
        if (CompareText(nStr, nPT.FGroup) = 0) and Assigned(nPH.FReader) then
        begin
          Result := nPT.FIsRun;
          if Result then
            Exit;
          //run tunnel exists
        end;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: 交货单
//Desc: 获取nBill交货单的已装袋数
function TMultiJSManager.GetJSDai(const nBill: string): Integer;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := 0;
    //default

    for i:=0 to FHosts.Count - 1 do
    begin
      nPHost := FHosts[i];
      for nIdx:=0 to nPHost.FTunnel.Count - 1 do
      begin
        nPTunnel := nPHost.FTunnel[nIdx];
        if CompareText(nBill, nPTunnel.FLastBill) <> 0 then Continue;

        Result := nPTunnel.FHasDone;
        Exit;
      end
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2013-07-22
//Parm: 结果列表(tunnel=dai)
//Desc: 获取各通道的计数结果
function TMultiJSManager.GetJSStatus(const nList: TStrings): Boolean;
var i,nIdx: Integer;
    nPHost: PMultiJSHost;
    nPTunnel: PMultiJSTunnel;
begin
  FSyncLock.Enter;
  try
    Result := True;
    nList.Clear;

    for i:=0 to FHosts.Count - 1 do
    begin
      nPHost := FHosts[i];
      for nIdx:=0 to nPHost.FTunnel.Count - 1 do
      begin
        nPTunnel := nPHost.FTunnel[nIdx];
        if FEnableChain then
        begin
          //if nPTunnel.FIsRun then
               nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone)
          //else nList.Values[nPTunnel.FID] := '0';
        end else
        begin
          nList.Values[nPTunnel.FID] := IntToStr(nPTunnel.FHasDone);
        end;
      end
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gMultiJSManager := nil;
finalization
  FreeAndNil(gMultiJSManager);
end.
