{*******************************************************************************
  作者: dmzn@163.com 2014-06-11
  描述: 磅站通道管理器
*******************************************************************************}
unit UMgrPoundTunnels;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, CPort, CPortTypes, IdComponent,
  IdTCPConnection, IdTCPClient, IdUDPServer, IdGlobal, IdSocketHandle, NativeXml, ULibFun,
  UWaitItem, USysLoger;

const
  cPTMaxCameraTunnel = 13;
  //支持的摄像机通道数

  cPTWait_Short = 320;
  cPTWait_Long  = 2 * 1000; //网络通讯时刷新频度

type
  TPoundTunnelManager = class;
  TPoundTunnelConnector = class;

  PPTPortItem = ^TPTPortItem;
  PPTCameraItem = ^TPTCameraItem;
  PPTTunnelItem = ^TPTTunnelItem;

  TOnTunnelDataEvent = procedure (const nValue: Double) of object;
  TOnTunnelDataEventEx = procedure (const nValue: Double;
    const nPort: PPTPortItem) of object;
  //事件定义
  
  TPTTunnelItem = record
    FID: string;                     //标识
    FName: string;                   //名称
    FPort: PPTPortItem;              //通讯端口
    FProber: string;                 //控制器
    FReader: string;                 //磁卡读头
    FUserInput: Boolean;             //手工输入
    FAutoWeight: Boolean;            //自动称重

    FFactoryID: string;              //工厂标识
    FCardInterval: Integer;          //读卡间隔
    FSampleNum: Integer;             //采样个数
    FSampleFloat: Integer;           //采样浮动
    FOptions: TStrings;              //附加参数

    FCamera: PPTCameraItem;          //摄像机
    FCameraTunnels: array[0..cPTMaxCameraTunnel-1] of Byte;
                                     //摄像通道                                     
    FOnData: TOnTunnelDataEvent;
    FOnDataEx:TOnTunnelDataEventEx;  //接收事件
    FOldEventTunnel: PPTTunnelItem;  //原接收通道
  end;

  TPTCameraItem = record
    FID: string;                     //标识
    FType: string;                   //类型
    FHost: string;                   //主机地址
    FPort: Integer;                  //端口
    FUser: string;                   //用户名
    FPwd: string;                    //密码
    FPicSize: Integer;               //图像大小
    FPicQuality: Integer;            //图像质量
  end;

  TPTConnType = (ctTCP, ctUDP, ctCOM, ctUser);
  //链路类型: 网络,串口,手动输入
         
  TPTPortItem = record
    FID: string;                     //标识
    FName: string;                   //名称
    FType: string;                   //类型
    FConn: TPTConnType;              //链路
    FPort: string;                   //端口
    FRate: TBaudRate;                //波特率
    FDatabit: TDataBits;             //数据位
    FStopbit: TStopBits;             //起停位
    FParitybit: TParityBits;         //校验位
    FParityCheck: Boolean;           //启用校验
    FCharBegin: Char;                //起始标记
    FCharEnd: Char;                  //结束标记
    FPackLen: Integer;               //数据包长
    FSplitTag: string;               //分段标识
    FSplitPos: Integer;              //有效段
    FInvalidBegin: Integer;          //截首长度
    FInvalidEnd: Integer;            //截尾长度
    FDataMirror: Boolean;            //镜像数据
    FDataByteHex: Boolean;           //16进制值
    FDataEnlarge: Single;            //放大倍数
    FDataPrecision: Integer;         //数据精度
    FMaxValue: Double;               //磅站上限
    FMaxValid: Double;               //上限取值
    FMinValue: Double;               //磅站下限

    FHostIP: string;
    FHostPort: Integer;              //网络链路
    FHostNetCheck: Integer;          //网络检测
    FHostLastActive: Cardinal;       //网络活动
    FClient: TIdTCPClient;           //套接字
    FClientActive: Boolean;          //链路启用

    FCOMPort: TComPort;              //读写对象
    FCOMBuff: string;                //通讯缓冲
    FCOMData: string;                //通讯数据
    FCOMValue: Double;               //有效值
    FCOMDataEx: string;              //原始数据
    
    FEventTunnel: PPTTunnelItem;     //接收通道
    FOptions: TStrings;              //附加参数
  end;

  TPoundTunnelConnector = class(TThread)
  private
    FOwner: TPoundTunnelManager;
    //拥有者
    FActiveClient: TIdTCPClient;
    FActivePort: PPTPortItem;
    FActiveTunnel: PPTTunnelItem;
    //当前通道
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure Execute; override;
    //执行线程
    function ReadPound: Boolean;
    //读取数据
    procedure DoSyncEvent;
    //处理事件
  public
    constructor Create(AOwner: TPoundTunnelManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TPoundParseWeight = function (const nPort: PPTPortItem): Boolean;
  //自定义数据解析

  TPoundTunnelManager = class(TObject)
  private
    FPorts: TList;
    //端口列表
    FCameras: TList;
    //摄像机
    FTunnels: TList;
    //通道列表
    FStrList: TStrings;
    //字符列表
    FUDPServerUser: Integer;
    FUDPServer: TIdUDPServer;
    //UDP链路
    FSyncLock: TCriticalSection;
    //同步锁定
    FConnector: TPoundTunnelConnector;
    //套接字链路
    FOnTunnelData: TOnTunnelDataEventEx;
    //数据触发事件
    FOnUserParseWeight: TPoundParseWeight;
    //自定义解析
  protected
    procedure ClearList(const nFree: Boolean);
    //清理资源
    function ParseWeight(const nPort: PPTPortItem): Boolean;
    procedure OnComData(Sender: TObject; Count: Integer);
    //读取数据
    procedure DoUDPRead(AThread: TIdUDPListenerThread;
      AData: TIdBytes; ABinding: TIdSocketHandle);
    //UDP链路
    procedure DisconnectClient(const nClient: TIdTCPClient);
    //关闭链路
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    function ActivePort(const nTunnel: string; const nEvent: TOnTunnelDataEvent;
      const nOpenPort: Boolean = False;
      const nEventEx: TOnTunnelDataEventEx = nil): Boolean;
    procedure ClosePort(const nTunnel: string);
    //起停端口
    procedure SetData(const nTunnel: string; const nValue: Double);
    //手动数据
    function GetPort(const nID: string): PPTPortItem;
    function GetCamera(const nID: string): PPTCameraItem;
    function GetTunnel(const nID: string): PPTTunnelItem;
    //检索数据
    property Tunnels: TList read FTunnels;
    property OnUserParseWeight: TPoundParseWeight read FOnUserParseWeight
      write FOnUserParseWeight;
    property OnData: TOnTunnelDataEventEx read FOnTunnelData write FOnTunnelData;
    //属性相关
  end;

var
  gPoundTunnelManager: TPoundTunnelManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TPoundTunnelManager, '磅站通道管理', nEvent);
end;

constructor TPoundTunnelManager.Create;
begin
  FConnector := nil;
  FOnTunnelData := nil;
  FUDPServer := nil;
  FUDPServerUser := 0;

  FPorts := TList.Create;
  FCameras := TList.Create;

  FTunnels := TList.Create;
  FStrList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TPoundTunnelManager.Destroy;
begin
  if Assigned(FConnector) then
    FConnector.StopMe;
  //xxxxx

  if Assigned(FUDPServer) then
  begin
    FUDPServer.Active := False;
    FreeAndNil(FUDPServer);
  end;
  
  ClearList(True);
  FStrList.Free;
  FSyncLock.Free;
  inherited;
end;

//Date: 2014-06-12
//Parm: 是否释放
//Desc: 清理列表资源
procedure TPoundTunnelManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
    nPort: PPTPortItem;
    nTunnel: PPTTunnelItem;
begin
  for nIdx:=FPorts.Count - 1 downto 0 do
  begin
    nPort := FPorts[nIdx];
    if Assigned(nPort.FCOMPort) then
    begin
      nPort.FCOMPort.Close;
      nPort.FCOMPort.Free;
    end;

    if Assigned(nPort.FClient) then
    begin
      nPort.FClient.Disconnect;
      nPort.FClient.Free;
    end;

    FreeAndNil(nPort.FOptions);
    Dispose(nPort);
    FPorts.Delete(nIdx);
  end;

  for nIdx:=FCameras.Count - 1 downto 0 do
  begin
    Dispose(PPTCameraItem(FCameras[nIdx]));
    FCameras.Delete(nIdx);
  end;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  begin
    nTunnel := FTunnels[nIdx];
    FreeAndNil(nTunnel.FOptions);
    
    Dispose(nTunnel);
    FTunnels.Delete(nIdx);
  end;

  if nFree then
  begin
    FPorts.Free;
    FCameras.Free;
    FTunnels.Free;
  end;
end;

//Date: 2016-11-26
//Parm: 套接字
//Desc: 管理nClient链路
procedure TPoundTunnelManager.DisconnectClient(const nClient: TIdTCPClient);
begin
  if Assigned(nClient) then
  begin
    nClient.Disconnect;
    if Assigned(nClient.IOHandler) then
      nClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

//Date：2014-6-18
//Parm：通道;地址字符串,类似: 1,2,3
//Desc：将nStr拆开,放入nTunnel.FCameraTunnels结构中
procedure SplitCameraTunnel(const nTunnel: PPTTunnelItem; const nStr: string);
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
      nTunnel.FCameraTunnels[nIdx] := MAXBYTE;
    //默认值

    SplitStr(nStr, nList, 0 , ',');
    if nList.Count < 1 then Exit;

    nIdx := nList.Count - 1;
    if nIdx > High(nTunnel.FCameraTunnels) then
      nIdx := High(nTunnel.FCameraTunnels);
    //检查边界

    while nIdx>=Low(nTunnel.FCameraTunnels) do
    begin
      nTunnel.FCameraTunnels[nIdx] := StrToInt(nList[nIdx]);
      Dec(nIdx);
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2014-06-12
//Parm: 配置文件
//Desc: 载入nFile配置
procedure TPoundTunnelManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
    nPort: PPTPortItem;
    nCamera: PPTCameraItem;
    nTunnel: PPTTunnelItem;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByNameR('ports');

    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nPort);
      FPorts.Add(nPort);
      FillChar(nPort^, SizeOf(TPTPortItem), #0);

      with nPort^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FType := NodeByNameR('type').ValueAsString;

        nTmp := NodeByName('conn');
        if Assigned(nTmp) then
             nStr := nTmp.ValueAsString
        else nStr := 'com';

        if CompareText('tcp', nStr) = 0 then nPort.FConn := ctTCP else
        if CompareText('udp', nStr) = 0 then nPort.FConn := ctUDP else
        if CompareText('user', nStr) = 0 then nPort.FConn := ctUser else
           nPort.FConn := ctCOM;
        //xxxxxx

        FPort := NodeByNameR('port').ValueAsString;
        FRate := StrToBaudRate(NodeByNameR('rate').ValueAsString);
        FDatabit := StrToDataBits(NodeByNameR('databit').ValueAsString);
        FStopbit := StrToStopBits(NodeByNameR('stopbit').ValueAsString);
        FParitybit := StrToParity(NodeByNameR('paritybit').ValueAsString);
        FParityCheck := NodeByNameR('paritycheck').ValueAsString = 'Y';

        FCharBegin := Char(StrToInt(NodeByNameR('charbegin').ValueAsString));
        FCharEnd := Char(StrToInt(NodeByNameR('charend').ValueAsString));
        FPackLen := NodeByNameR('packlen').ValueAsInteger;

        nTmp := NodeByName('invalidlen');
        if Assigned(nTmp) then //直接指定截取长度
        begin
          FInvalidBegin := 0;
          FInvalidEnd := nTmp.ValueAsInteger;
        end else
        begin
          FInvalidBegin := NodeByNameR('invalidbegin').ValueAsInteger;
          FInvalidEnd := NodeByNameR('invalidend').ValueAsInteger;
        end;

        FSplitTag := Char(StrToInt(NodeByNameR('splittag').ValueAsString));
        FSplitPos := NodeByNameR('splitpos').ValueAsInteger;
        FDataMirror := NodeByNameR('datamirror').ValueAsInteger = 1;
        FDataEnlarge := NodeByNameR('dataenlarge').ValueAsFloat;

        nTmp := NodeByName('databytehex');
        if Assigned(nTmp) then
             FDataByteHex := nTmp.ValueAsInteger = 1
        else FDataByteHex := False;

        nTmp := NodeByName('dataprecision');
        if Assigned(nTmp) then
             FDataPrecision := nTmp.ValueAsInteger
        else FDataPrecision := 100;

        nTmp := NodeByName('maxval');
        if Assigned(nTmp) and (nTmp.AttributeByName['enable'] = 'y') then
        begin
          FMaxValue := nTmp.ValueAsFloat;
          FMaxValid := StrToFloat(nTmp.AttributeByName['valid']);

          FMaxValue := Float2Float(FMaxValue, 100, False);
          FMaxValid := Float2Float(FMaxValid, 100, False);
        end else
        begin
          FMaxValue := 0;
          FMaxValid := 0;
        end;

        nTmp := NodeByName('minval');
        if Assigned(nTmp) and (nTmp.AttributeByName['enable'] = 'y') then
             FMinValue := Float2Float(nTmp.ValueAsFloat, 100, False)
        else FMinValue :=0;

        nTmp := NodeByName('hostip');
        if Assigned(nTmp) then
          FHostIP := nTmp.ValueAsString;
        //xxxxx

        nTmp := NodeByName('hostport');
        if Assigned(nTmp) then
          FHostPort := nTmp.ValueAsInteger;
        //xxxxx

        nTmp := NodeByName('hostcheck');
        if Assigned(nTmp) then
             FHostNetCheck := nTmp.ValueAsInteger
        else FHostNetCheck := 0;

        nTmp := NodeByName('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;
      end;

      nPort.FClient := nil;
      nPort.FClientActive := False;
      //默认无链路
      
      nPort.FCOMPort := nil;
      //默认不启用
      nPort.FEventTunnel := nil;
    end;

    nNode := nXML.Root.NodeByName('cameras');
    if Assigned(nNode) then
    begin
      for nIdx:=0 to nNode.NodeCount - 1 do
      with nNode.Nodes[nIdx] do
      begin
        New(nCamera);
        FCameras.Add(nCamera);
        FillChar(nCamera^, SizeOf(TPTCameraItem), #0);

        with nCamera^ do
        begin
          FID := AttributeByName['id'];
          FHost := NodeByNameR('host').ValueAsString;
          FPort := NodeByNameR('port').ValueAsInteger;
          FUser := NodeByNameR('user').ValueAsString;
          FPwd := NodeByNameR('password').ValueAsString;
          FPicSize := NodeByNameR('picsize').ValueAsInteger;
          FPicQuality := NodeByNameR('picquality').ValueAsInteger;
        end;

        nTmp := NodeByName('type');
        if Assigned(nTmp) then
             nCamera.FType := nTmp.ValueAsString
        else nCamera.FType := 'HKV';
      end;
    end;

    nNode := nXML.Root.NodeByNameR('tunnels');
    for nIdx:=0 to nNode.NodeCount - 1 do
    with nNode.Nodes[nIdx] do
    begin
      New(nTunnel);
      FTunnels.Add(nTunnel);
      FillChar(nTunnel^, SizeOf(TPTTunnelItem), #0);

      nStr := NodeByNameR('port').ValueAsString;
      nTunnel.FPort := GetPort(nStr);
      if not Assigned(nTunnel.FPort) then
        raise Exception.Create(Format('通道[ %s.Port ]无效.', [nTunnel.FName]));
      //xxxxxx

      with nTunnel^ do
      begin
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];
        FProber := NodeByNameR('prober').ValueAsString;
        FReader := NodeByNameR('reader').ValueAsString;
        FUserInput := NodeByNameR('userinput').ValueAsString = 'Y';

        FFactoryID := NodeByNameR('factory').ValueAsString;
        FCardInterval := NodeByNameR('cardInterval').ValueAsInteger;
        FSampleNum := NodeByNameR('sampleNum').ValueAsInteger;
        FSampleFloat := NodeByNameR('sampleFloat').ValueAsInteger;

        nTmp := NodeByName('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;

        nTmp := NodeByName('autoweight');
        if Assigned(nTmp) then
             FAutoWeight := nTmp.ValueAsString = 'Y'
        else FAutoWeight := False; //南方特例,尽量不要用

        nTmp := NodeByName('camera');
        if Assigned(nTmp) then
        begin
          nStr := nTmp.AttributeByName['id'];
          FCamera := GetCamera(nStr);
          SplitCameraTunnel(nTunnel, nTmp.ValueAsString);
        end else
        begin
          FCamera := nil;
          //no camera
        end;
      end;
    end;
  finally
    nXML.Free;
  end;   
end;

//------------------------------------------------------------------------------
//Desc: 检索标识为nID的端口
function TPoundTunnelManager.GetPort(const nID: string): PPTPortItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FPorts.Count - 1 downto 0 do
  if CompareText(nID, PPTPortItem(FPorts[nIdx]).FID) = 0 then
  begin
    Result := FPorts[nIdx];
    Exit;
  end;
end;

//Desc: 检索标识为nID的摄像机
function TPoundTunnelManager.GetCamera(const nID: string): PPTCameraItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FCameras.Count - 1 downto 0 do
  if CompareText(nID, PPTCameraItem(FCameras[nIdx]).FID) = 0 then
  begin
    Result := FCameras[nIdx];
    Exit;
  end;
end;

//Desc: 检索标识为nID的通道
function TPoundTunnelManager.GetTunnel(const nID: string): PPTTunnelItem;
var nIdx: Integer;
begin
  Result := nil;

  for nIdx:=FTunnels.Count - 1 downto 0 do
  if CompareText(nID, PPTTunnelItem(FTunnels[nIdx]).FID) = 0 then
  begin
    Result := FTunnels[nIdx];
    Exit;
  end;
end;

//Date: 2014-06-11
//Parm: 通道号;接收事件
//Desc: 开启nTunnel通道读写端口
function TPoundTunnelManager.ActivePort(const nTunnel: string;
  const nEvent: TOnTunnelDataEvent; const nOpenPort: Boolean;
  const nEventEx: TOnTunnelDataEventEx): Boolean;
var nPT: PPTTunnelItem;
begin
  Result := False;
  //xxxxx

  FSyncLock.Enter;
  try
    nPT := GetTunnel(nTunnel);
    if not Assigned(nPT) then Exit;

    nPT.FOnData := nEvent;
    nPT.FOnDataEx := nEventEx;
    
    nPT.FOldEventTunnel := nPT.FPort.FEventTunnel;
    nPT.FPort.FEventTunnel := nPT;
    
    if nPT.FPort.FConn = ctTCP then
    begin
      if not Assigned(nPT.FPort.FClient) then
      begin
        nPT.FPort.FClient := TIdTCPClient.Create;
        //new socket
        
        with nPT.FPort.FClient do
        begin
          Host := nPT.FPort.FHostIP;
          Port := nPT.fPort.FHostPort;
          
          ReadTimeout := 2 * 1000;
          ConnectTimeout := 2 * 1000;
        end;
      end;

      if not Assigned(FConnector) then
        FConnector := TPoundTunnelConnector.Create(Self);
      FConnector.WakupMe; //启动链接器
                                  
      nPT.FPort.FClientActive := True;
      //套接字链路
    end else

    if nPT.FPort.FConn = ctCOM then
    begin
      if not Assigned(nPT.FPort.FCOMPort) then
      begin
        nPT.FPort.FCOMPort := TComPort.Create(nil);
        with nPT.FPort.FCOMPort do
        begin
          Tag := FPorts.IndexOf(nPT.FPort);
          OnRxChar := OnComData;

          with Timeouts do
          begin
            ReadTotalConstant := 100;
            ReadTotalMultiplier := 10;
          end;

          with Parity do
          begin
            Bits := nPT.FPort.FParitybit;
            Check := nPT.FPort.FParityCheck;
          end;

          Port := nPT.FPort.FPort;
          BaudRate := nPT.FPort.FRate;
          DataBits := nPT.FPort.FDatabit;
          StopBits := nPT.FPort.FStopbit;
        end;
      end;

      try
        if nOpenPort then
          nPT.FPort.FCOMPort.Open;
        //开启端口
      except
        on E: Exception do
        begin
          WriteLog(E.Message);
        end;
      end;
    end else

    if nPT.FPort.FConn = ctUDP then
    begin
      try
        if not Assigned(FUDPServer) then
        begin
          FUDPServer := TIdUDPServer.Create;
          FUDPServer.DefaultPort := nPT.FPort.FHostPort;
          FUDPServer.OnUDPRead := DoUDPRead;
        end;

        if not FUDPServer.Active then
          FUDPServer.Active := True;
        Inc(FUDPServerUser); //增加链路计数        
      except
        on E: Exception do
        begin
          WriteLog(E.Message);
        end;
      end;
    end;
    
    Result := True;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014-06-11
//Parm: 通道号
//Desc: 关闭nTunnel通道读写端口
procedure TPoundTunnelManager.ClosePort(const nTunnel: string);
var nPT: PPTTunnelItem;
begin
  FSyncLock.Enter;
  try
    nPT := GetTunnel(nTunnel);
    if not Assigned(nPT) then Exit;

    nPT.FPort.FClientActive := False;
    nPT.FOnData := nil;

    if nPT.FPort.FEventTunnel = nPT then
    begin
      nPT.FPort.FEventTunnel := nPT.FOldEventTunnel;
      //还原接收通道

      if Assigned(nPT.FPort.FCOMPort) then
        nPT.FPort.FCOMPort.Close;
      //通道空闲则关闭

      DisconnectClient(nPT.FPort.FClient);
      //关闭链路

      if Assigned(FUDPServer) then
      begin
        if FUDPServerUser > 0 then Dec(FUDPServerUser);
        if FUDPServerUser < 1 then FUDPServer.Active := False;
      end; //关闭UDP
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2014-06-11
//Desc: 读取数据
procedure TPoundTunnelManager.OnComData(Sender: TObject; Count: Integer);
var nVal: Double;
    nPort: PPTPortItem;
begin
  with TComPort(Sender) do
  begin
    nPort := FPorts[Tag];
    ReadStr(nPort.FCOMBuff, Count);
  end;

  FSyncLock.Enter;
  try
    if not (Assigned(FOnTunnelData) or (Assigned(nPort.FEventTunnel) and
            Assigned(nPort.FEventTunnel.FOnData))) then Exit;
    //无接收事件

    nPort.FCOMData := nPort.FCOMData + nPort.FCOMBuff;
    //合并数据

    try
      if ParseWeight(nPort) then
      begin
        nVal := StrToFloat(nPort.FCOMData) * nPort.FDataEnlarge;
        nVal := Float2Float(nVal, nPort.FDataPrecision, False);

        nPort.FCOMValue := nVal;
        nPort.FCOMData := '';
        //clear data

        if Assigned(FOnTunnelData) then
          FOnTunnelData(nPort.FCOMValue, nPort);
        //xxxxx

        if Assigned(nPort.FEventTunnel) then
        begin
          if Assigned(nPort.FEventTunnel.FOnData) then
            nPort.FEventTunnel.FOnData(nPort.FCOMValue);
          //xxxxx


          if Assigned(nPort.FEventTunnel.FOnDataEx) then
            nPort.FEventTunnel.FOnDataEx(nPort.FCOMValue, nPort);
          //xxxxx
        end;
      end;
    except
      on E: Exception do
      begin
        WriteLog(E.Message);
      end;
    end;
  finally
    FSyncLock.Leave;
  end;

  if Length(nPort.FCOMData) >= 5 * nPort.FPackLen then
  begin
    System.Delete(nPort.FCOMData, 1, 4 * nPort.FPackLen);
    WriteLog('无效数据过多,已裁剪.')
  end;
end;

//Date: 2014-06-12
//Parm: 端口
//Desc: 解析nPort上的称重数据
function TPoundTunnelManager.ParseWeight(const nPort: PPTPortItem): Boolean;
var nStr: string;
    nVal: Double;
    i,nIdx,nPos,nEnd: Integer;
begin
  if Assigned(FOnUserParseWeight) then
  begin
    Result := FOnUserParseWeight(nPort);
    Exit;
  end;
  
  Result := False;
  if Length(nPort.FCOMData) < nPort.FPackLen then Exit;
  //数据不够整包长度

  nEnd := -1;
  for nIdx:=Length(nPort.FCOMData) downto 1 do
  begin
    if (nEnd < 1) and (nPort.FCOMData[nIdx] = nPort.FCharEnd) then
    begin
      nEnd := nIdx;
      Continue;
    end;

    if (nEnd < 1) or (nPort.FCOMData[nIdx] <> nPort.FCharBegin) then Continue;
    //无数据结束标记,或不是开始标记

    nPort.FCOMData := Copy(nPort.FCOMData, nIdx + 1, nEnd - nIdx - 1);
    //待处理表头包数据
    nPort.FCOMDataEx := nPort.FCOMData;

    if nPort.FSplitPos > 0 then
    begin
      SplitStr(nPort.FCOMData, FStrList, 0, nPort.FSplitTag);
      //拆分数据

      for nPos:=FStrList.Count - 1 downto 0 do
      begin
        FStrList[nPos] := Trim(FStrList[nPos]);
        if FStrList[nPos] = '' then FStrList.Delete(nPos);
      end; //整理数据

      if FStrList.Count < nPort.FSplitPos then
      begin
        nPort.FCOMData := '';
        Exit;
      end; //分段索引越界

      nPort.FCOMData := FStrList[nPort.FSplitPos - 1];
      //有效数据
    end;

    if nPort.FInvalidBegin > 0 then
      System.Delete(nPort.FCOMData, 1, nPort.FInvalidBegin);
    //首部无效数据

    if nPort.FInvalidEnd > 0 then
      System.Delete(nPort.FCOMData, Length(nPort.FCOMData)-nPort.FInvalidEnd+1,
                    nPort.FInvalidEnd);
    //尾部无效数据

    if nPort.FDataMirror then
      nPort.FCOMData := MirrorStr(nPort.FCOMData);
    //数据反转

    if nPort.FDataByteHex then
    begin
      nStr := '';
      for i:=1 to Length(nPort.FCOMData) do
        nStr := nStr + IntToHex(Ord(nPort.FCOMData[i]), 2);
      nPort.FCOMData := nStr;
    end; //每字节16进制拼接

    nPort.FCOMData := Trim(nPort.FCOMData);
    Result := IsNumber(nPort.FCOMData, True);

    if Result and (nPort.FMaxValue > 0) then
    begin
      nVal := StrToFloat(nPort.FCOMData);
      if FloatRelation(nVal, nPort.FMaxValue, rtGE, 1000) then
        nPort.FCOMData := FloatToStr(nPort.FMaxValid);
      //超重取有效值
    end;

    Exit;
    //end loop
  end;
end;

//------------------------------------------------------------------------------
constructor TPoundTunnelConnector.Create(AOwner: TPoundTunnelManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cPTWait_Short;
end;

destructor TPoundTunnelConnector.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TPoundTunnelConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TPoundTunnelConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TPoundTunnelConnector.Execute;
var nIdx: Integer;
    nTunnel: PPTTunnelItem;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    with FOwner do
    begin
      for nIdx:=FTunnels.Count - 1 downto 0 do
      begin
        nTunnel := FTunnels[nIdx];
        if not nTunnel.FPort.FClientActive then Continue;

        FActiveTunnel := nTunnel;
        FActivePort   := nTunnel.FPort;
        FActiveClient := nTunnel.FPort.FClient;

        ReadPound;
        //读取数据
      end;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(200);
    end;
  end; 
end;

//Desc: 读取磅重
function TPoundTunnelConnector.ReadPound: Boolean;
var nVal: Double;
    nBuf: TIdBytes;
begin
  Result := False;
  try
    if not FActiveClient.Connected then
    begin
      FActiveClient.Connect;
      FActivePort.FHostLastActive := GetTickCount();
    end;

    if (FActivePort.FHostNetCheck > 0) and (GetTickCountDiff
       (FActivePort.FHostLastActive) >= FActivePort.FHostNetCheck) then
    begin
      WriteLog(Format('地磅[ %s ]读数超时,尝试检测网络.', [FActiveTunnel.FID]));
      //xxxxx

      FActivePort.FHostLastActive := GetTickCount();
      nBuf := ToBytes(FActiveClient.IOHandler.ReadByte);
      //读取1个字节,若网络异常则重连
    end else
    begin
      SetLength(nBuf, 0);
      //init
    end;

    with FActiveClient do
    begin
      nVal := 0;
      while True do
      begin
        IOHandler.CheckForDataOnSource(10);
        //fill the output buffer with a timeout

        if IOHandler.InputBufferIsEmpty then Break;
        nVal := 10;
        IOHandler.InputBuffer.ExtractToBytes(nBuf);
      end;

      if nVal < 1 then Exit;
      FActivePort.FHostLastActive := GetTickCount;
      FActivePort.FCOMBuff := BytesToString(nBuf);
      FActivePort.FCOMData := FActivePort.FCOMData + FActivePort.FCOMBuff;
      //数据合并
    end;

    if not FOwner.ParseWeight(FActiveTunnel.FPort) then
    begin
      if Length(FActivePort.FCOMData) >= 5 * FActivePort.FPackLen then
      begin
        System.Delete(FActivePort.FCOMData, 1, 4 * FActivePort.FPackLen);
        WriteLog('无效数据过多,已裁剪.')
      end;

      Exit;
    end;

    nVal := StrToFloat(FActivePort.FCOMData) * FActivePort.FDataEnlarge;
    nVal := Float2Float(nVal, FActivePort.FDataPrecision, False);

    FActivePort.FCOMValue := nVal;
    FActivePort.FCOMData := '';
    //clear data

    if Assigned(FOwner.FOnTunnelData) then
      FOwner.FOnTunnelData(FActivePort.FCOMValue, FActivePort);
    //xxxxx

    if Assigned(FActivePort.FEventTunnel) and
       Assigned(FActivePort.FEventTunnel.FOnData) then
      Synchronize(DoSyncEvent);
    Result := True;
  except
    on nErr: Exception do
    begin
      WriteLog(Format('地磅[ %s ]读数失败,描述: %s', [FActiveTunnel.FID,
        nErr.Message]));
      //xxxxx

      FOwner.DisconnectClient(FActiveClient);
      //关闭链路
    end;
  end;
end;

//Desc: 处理主进程事件
procedure TPoundTunnelConnector.DoSyncEvent;
begin
  if Assigned(FActiveTunnel.FOnData) then
    FActiveTunnel.FOnData(FActivePort.FCOMValue);
  //do event

  if Assigned(FActiveTunnel.FOnDataEx) then
    FActiveTunnel.FOnDataEx(FActivePort.FCOMValue, FActivePort);
  //xxxxx
end;

//Date: 2019-03-09
//Desc: 处理UDP数据包,由外部数据
procedure TPoundTunnelManager.DoUDPRead(AThread: TIdUDPListenerThread;
  AData: TIdBytes; ABinding: TIdSocketHandle);
var nIdx: Integer;
    nVal: Double;
    nPort: PPTPortItem;
    nTunnel: PPTTunnelItem;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FTunnels.Count-1 downto 0 do
    begin
      nTunnel := FTunnels[nIdx];
      if (nTunnel.FPort.FConn <> ctUDP) or
         (nTunnel.FPort.FHostIP <> ABinding.PeerIP) then Continue;
      //match tunnel

      nPort := nTunnel.FPort;
      try
        if not (Assigned(FOnTunnelData) or (Assigned(nPort.FEventTunnel) and
                Assigned(nPort.FEventTunnel.FOnData))) then Exit;
        //无接收事件

        nPort.FCOMBuff := BytesToString(AData, Indy8BitEncoding);
        //udp data

        if ParseWeight(nPort) then
        begin
          nVal := StrToFloat(nPort.FCOMData) * nPort.FDataEnlarge;
          nVal := Float2Float(nVal, nPort.FDataPrecision, False);

          nPort.FCOMValue := nVal;
          nPort.FCOMData := '';
          //clear data

          if Assigned(FOnTunnelData) then
            FOnTunnelData(nPort.FCOMValue, nPort);
          //xxxxx

          if Assigned(nPort.FEventTunnel) then
          begin
            if Assigned(nPort.FEventTunnel.FOnData) then
              nPort.FEventTunnel.FOnData(nPort.FCOMValue);
            //xxxxx
                        
            if Assigned(nPort.FEventTunnel.FOnDataEx) then
              nPort.FEventTunnel.FOnDataEx(nPort.FCOMValue, nPort);
            //xxxxx
          end;
        end;
      except
        on E: Exception do
        begin
          WriteLog(E.Message);
        end;
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2019-07-16
//Parm: 通道;值
//Desc: 设置nTunnel的值
procedure TPoundTunnelManager.SetData(const nTunnel: string; const nValue: Double);
var nVal: Double;
    nPT: PPTTunnelItem;
begin
  FSyncLock.Enter;
  try
    nPT := GetTunnel(nTunnel);
    if Assigned(nPT) then
    try
      if not (Assigned(FOnTunnelData) or (Assigned(nPT.FPort.FEventTunnel) and
              Assigned(nPT.FPort.FEventTunnel.FOnData))) then Exit;
      //no event

      nVal := nValue * nPT.FPort.FDataEnlarge;
      nVal := Float2Float(nVal, nPT.FPort.FDataPrecision, False);
      //adjust precision

      nPT.FPort.FCOMValue := nVal;
      nPT.FPort.FCOMData := '';
      //clear data

      if Assigned(FOnTunnelData) then
        FOnTunnelData(nVal, nPT.FPort);
      //xxxxx

      if Assigned(nPT.FPort.FEventTunnel) then
      begin
        if Assigned(nPT.FPort.FEventTunnel.FOnData) then
           nPT.FPort.FEventTunnel.FOnData(nVal);
        //xxxxx
                
        if Assigned(nPT.FPort.FEventTunnel.FOnDataEx) then
           nPT.FPort.FEventTunnel.FOnDataEx(nVal, nPT.FPort);
        //xxxxx
      end;
    except
      on nErr: Exception do
      begin
        WriteLog('SetData Error: ' + nErr.Message);
      end;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

initialization
  gPoundTunnelManager := nil;
finalization
  FreeAndNil(gPoundTunnelManager);
end.
