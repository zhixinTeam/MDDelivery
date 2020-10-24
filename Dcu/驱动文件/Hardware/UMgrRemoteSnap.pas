{*******************************************************************************
  作者: dmzn@163.com 2017-10-20
  描述: 远程抓拍及LED显示服务
*******************************************************************************}
unit UMgrRemoteSnap;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdComponent, IdTCPConnection,
  IdTCPClient, IdUDPServer, IdGlobal, IdSocketHandle, USysLoger, UWaitItem,
  ULibFun, UBase64;

type
  PHKDataBase = ^THKDataBase;
  THKDataBase = record
    FCommand   : Byte;     //命令字
    FDataLen   : Word;     //数据长
  end;

  PHKPlaySnap = ^THKPlaySnap;
  THKPlaySnap = record
    FBase      : THKDataBase;
    FContent   : string;
  end;

  PHKDisplay = ^THKDisplay;
  THKDisplay = record
    FBase      : THKDataBase;
    FCard      : string;
    FText      : string;
    FColor     : Integer;
  end;

const
  cHKCmd_Display  = $17;  //显示内容
  cHKCmd_Snap     = $25;  //抓拍
  cSizeHKBase     = SizeOf(THKDataBase);
  
type
  THKSnapItem = record
    FID        : string;
    FName      : string;
    FHost      : string;
    FPort      : Integer;
    FEnable    : Boolean;
  end;

  THKSnapItems = array of THKSnapItem;

  THKSnapHelper = class;
  THKSnapConnector = class(TThread)
  private
    FOwner: THKSnapHelper;
    //拥有者
    FListA: TStrings;
    //字符列表
    FBuffer: TList;
    //发送缓冲
    FWaiter: TWaitObject;
    //等待对象
    FClient: TIdTCPClient;
    //网络对象
  protected
    procedure DoExuecte(const nHost: THKSnapItem);
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: THKSnapHelper);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  THKSnapHelper = class(TObject)
  private
    FHosts: THKSnapItems;
    FSnaper: THKSnapConnector;
    //链路对象
    FBuffData: TList;
    //临时缓冲
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    procedure ClearBuffer(const nList: TList);
    //清理缓冲
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartSnap;
    procedure StopSnap;
    //启停读取
    procedure Display(const nCard,nText: string; const nColor: Integer = 2);
    //LED显示
  end;

var
  gHKSnapHelper: THKSnapHelper = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THKSnapHelper, '远程抓拍服务', nEvent);
end;

constructor THKSnapHelper.Create;
begin
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor THKSnapHelper.Destroy;
begin
  StopSnap;
  ClearBuffer(FBuffData);
  FBuffData.Free;

  FSyncLock.Free;
  inherited;
end;

procedure THKSnapHelper.ClearBuffer(const nList: TList);
var nIdx: Integer;
    nBase: PHKDataBase;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    nBase := nList[nIdx];

    case nBase.FCommand of
     cHKCmd_Display : Dispose(PHKDisplay(nBase));
    end;

    nList.Delete(nIdx);
  end;
end;

procedure THKSnapHelper.StartSnap;
begin
  if not Assigned(FSnaper) then
    FSnaper := THKSnapConnector.Create(Self);
  FSnaper.WakupMe;
end;

procedure THKSnapHelper.StopSnap;
begin
  if Assigned(FSnaper) then
    FSnaper.StopMe;
  FSnaper := nil;
end;

//Date: 2017-10-19
//Parm: 卡标识;内容;颜色
//Desc: 在nCard上显示颜色为nColor的nText内容
procedure THKSnapHelper.Display(const nCard,nText: string;
 const nColor: Integer);
var nPtr: PHKDisplay;
begin
  FSyncLock.Enter;
  try
    ClearBuffer(FBuffData);
    //clear

    New(nPtr);
    FBuffData.Add(nPtr);

    nPtr.FBase.FCommand := cHKCmd_Display;
    nPtr.FCard := nCard;
    nPtr.FText := nText;
    nPtr.FColor := nColor;

    if Assigned(FSnaper) then
      FSnaper.WakupMe;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 载入nFile配置文件
procedure THKSnapHelper.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode: TXmlNode;
    nIdx,nNum: Integer;
begin
  SetLength(FHosts, 0);
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    //load config

    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      if CompareText(nNode.Name, 'item') <> 0 then Continue;
      //not valid item

      nNum := Length(FHosts);
      SetLength(FHosts, nNum + 1);

      with FHosts[nNum] do
      begin
        FID    := nNode.NodeByName('id').ValueAsString;
        FName  := nNode.NodeByName('name').ValueAsString;
        FHost  := nNode.NodeByName('ip').ValueAsString;
        FPort  := nNode.NodeByName('port').ValueAsInteger;
        FEnable := nNode.NodeByName('enable').ValueAsInteger = 1;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor THKSnapConnector.Create(AOwner: THKSnapHelper);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  
  FBuffer := TList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 2000;

  FClient := TIdTCPClient.Create;
  FClient.ReadTimeout := 5 * 1000;
  FClient.ConnectTimeout := 5 * 1000;
end;

destructor THKSnapConnector.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FOwner.ClearBuffer(FBuffer);
  FBuffer.Free;

  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure THKSnapConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure THKSnapConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure THKSnapConnector.Execute;
var nIdx: Integer;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FOwner.FSyncLock.Enter;
    try
      for nIdx:=0 to FOwner.FBuffData.Count - 1 do
        FBuffer.Add(FOwner.FBuffData[nIdx]);
      FOwner.FBuffData.Clear;
    finally
      FOwner.FSyncLock.Leave;
    end;

    if FBuffer.Count > 0 then
    try
      for nIdx:=Low(FOwner.FHosts) to High(FOwner.FHosts) do
       if FOwner.FHosts[nIdx].FEnable then
        DoExuecte(FOwner.FHosts[nIdx]);
      //send voice command
    finally
      FOwner.ClearBuffer(FBuffer);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure THKSnapConnector.DoExuecte(const nHost: THKSnapItem);
var nIdx: Integer;
    nBuf,nTmp: TIdBytes;
    nPBase: PHKDataBase;
begin
  try
    if FClient.Connected and ((FClient.Host <> nHost.FHost) or (
       FClient.Port <> nHost.FPort)) then
    begin
      FClient.Disconnect;
      if Assigned(FClient.IOHandler) then
        FClient.IOHandler.InputBuffer.Clear;
      //try to swtich connection
    end;

    if not FClient.Connected then
    begin
      FClient.Host := nHost.FHost;
      FClient.Port := nHost.FPort;
      FClient.Connect;
    end;

    for nIdx:=FBuffer.Count - 1 downto 0 do
    begin
      nPBase := FBuffer[nIdx];

      if nPBase.FCommand = cHKCmd_Display then
      begin
        with FListA,PHKDisplay(nPBase)^ do
        begin
          Clear;
          Values['Card'] := FCard;
          Values['Text'] := FText;
          Values['Color'] := IntToStr(FColor);
        end;

        SetLength(nTmp, 0);
        nTmp := ToBytes(EncodeBase64(FListA.Text));
        nPBase.FDataLen := Length(nTmp);

        nBuf := RawToBytes(nPBase^, cSizeHKBase);
        AppendBytes(nBuf, nTmp);
        FClient.Socket.Write(nBuf);
      end;
    end;
  except
    WriteLog(Format('向主机[ %s ]发送抓拍指令失败.', [nHost.FHost]));
    //loged

    FClient.Disconnect;
    if Assigned(FClient.IOHandler) then
      FClient.IOHandler.InputBuffer.Clear;
    //close connection
  end;
end;

initialization
  gHKSnapHelper := THKSnapHelper.Create;
finalization
  FreeAndNil(gHKSnapHelper);
end.
