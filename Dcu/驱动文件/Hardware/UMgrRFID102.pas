{*******************************************************************************
  作者: dmzn@163.com 2014-10-24
  描述: 深圳市中科华益科技有限公司 RFID102读取器驱动
*******************************************************************************}
unit UMgrRFID102;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, NativeXml, IdTCPClient, IdGlobal,
  UWaitItem, USysLoger, ULibFun, UMgrRFID102_Head;

const
  cHYReader_Wait_Short     = 150;
  cHYReader_Wait_Long      = 2 * 1000;
  cHYReader_MaxThread      = 10;
  
  cHYReader_ConnectRelay   = Char($03);  //闭合继电器
  cHYReader_DisConnRelay   = Char($00);  //断开继电器
  cHYReader_CommandRetry   = 3;          //错误后尝试
  cHYReader_Sleep_Short    = 10;         //SOCKET间隔

type
  PHYReaderSetRelay = ^THYReaderSetRelay;
  THYReaderSetRelay = record
    FCommand : TRFIDReaderCmd; //读头指令
    FReader  : string;         //读头标识
    FTimes   : Integer;        //发送次数
  end;

  THYReaderVType = (rt900, rt02n);
  //虚拟读头类型: 900m,02n

  PHYReaderItem = ^THYReaderItem;
  THYReaderItem = record
    FID     : string;          //读头标识
    FHost   : string;          //地址
    FPort   : Integer;         //端口

    FCard   : string;          //卡号
    FTunnel : string;          //通道号
    FEnable : Boolean;         //是否启用
    FLocked : Boolean;         //是否锁定
    FCardLast: Cardinal;       //有卡时间
    FLastActive: Cardinal;     //上次活动

    FVirtual: Boolean;         //虚拟读头
    FVReader: string;          //读头标识
    FVReaders: TDynamicStrArray;//多头虚拟
    FVMultiInterval: Integer;  //多头间隔           
    FVRGroup: string;          //读头分组
    FVType  : THYReaderVType;  //虚拟类型

    FKeepOnce: Integer;        //单次保持
    FKeepPeer: Boolean;        //保持模式
    FKeepLast: Cardinal;       //上次活动

    FRelayConn: Boolean;       //是否吸合
    FConnLast: Cardinal;       //上次吸合
    FConnKeep: Integer;        //吸合保持
    FClient : TIdTCPClient;    //通信链路

    FCardLen: Integer;         //卡号长度
    FCardPre: TStrings;        //前缀控制
    FOptions: TStrings;        //附加选项
  end;

  THYReaderThreadType = (ttAll, ttActive);
  //线程模式: 全能;只读活动

  THYReaderManager = class;
  THYRFIDReader = class(TThread)
  private
    FOwner: THYReaderManager;
    //拥有者
    FEPCList: TStrings;
    //电子标签
    FWaiter: TWaitObject;
    //等待对象
    FActiveReader: PHYReaderItem;
    //当前读头
    FThreadType: THYReaderThreadType;
    //线程模式
    FSendItem,FRecvItem: TRFIDReaderCmd;
    //发送&返回指令
  protected
    procedure DoExecute;
    procedure Execute; override;
    //执行线程
    procedure ScanActiveReader(const nActive: Boolean);
    //扫描可用
    function ReadCard(const nReader: PHYReaderItem): Boolean;
    //读卡片
    function IsCardValid(var nCard: string; const nReader: PHYReaderItem): Boolean;
    //校验卡号
    function SendReaderCommand(const nReader: PHYReaderItem): Boolean;
    //发送指令
  public
    constructor Create(AOwner: THYReaderManager; AType: THYReaderThreadType);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  //----------------------------------------------------------------------------
  THYReaderProc = procedure (const nItem: PHYReaderItem);
  THYReaderEvent = procedure (const nItem: PHYReaderItem) of Object;

  THYReaderManager = class(TObject)
  private
    FEnable: Boolean;
    //是否启用
    FMonitorCount: Integer;
    FThreadCount: Integer;
    //读卡线程
    FReaderIndex: Integer;
    FReaderActive: Integer;
    //读头索引
    FReaders: TList;
    //读头列表
    FCardLength: Integer;
    FCardPrefix: TStrings;
    //卡号标识
    FBuffData: TList;
    //数据缓冲
    FSyncLock: TCriticalSection;
    //同步锁定
    FThreads: array[0..cHYReader_MaxThread-1] of THYRFIDReader;
    //读卡对象
    FOnProc: THYReaderProc;
    FOnEvent: THYReaderEvent;
    //事件定义
  protected
    procedure ClearBuffer(const nFree: Boolean);
    procedure ClearReaders(const nFree: Boolean);
    //清理资源
    procedure CloseReader(const nReader: PHYReaderItem);
    //关闭读头
    function FindReader(const nReader: string): Integer;
    //检索读头
    procedure ConnRelay(const nReader: string; const nActive: Boolean);
    //开合继电器
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //载入配置
    procedure StartReader;
    procedure StopReader;
    //启停读头
    procedure OpenDoor(const nReader: string);
    //打开道闸
    function GetLastCard(const nReader: string): string;
    //获取卡号
    property Readers: TList read FReaders;
    property OnCardProc: THYReaderProc read FOnProc write FOnProc;
    property OnCardEvent: THYReaderEvent read FOnEvent write FOnEvent;
    //属性相关
  end;

var
  gHYReaderManager: THYReaderManager = nil;
  //全局使用
  
implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(THYReaderManager, '华益读卡器', nEvent);
end;

constructor THYReaderManager.Create;
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
  
  FReaders := TList.Create;
  FBuffData := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor THYReaderManager.Destroy;
begin
  StopReader;
  ClearReaders(True);
  ClearBuffer(True);

  FCardPrefix.Free;
  FSyncLock.Free;
  inherited;
end;

procedure THYReaderManager.ClearBuffer(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FBuffData.Count - 1 downto 0 do
  begin
    Dispose(PHYReaderSetRelay(FBuffData[nIdx]));
    FBuffData.Delete(nIdx);
  end;

  if nFree then
    FreeAndNil(FBuffData);
  //xxxxx
end;

procedure THYReaderManager.ClearReaders(const nFree: Boolean);
var nIdx: Integer;
    nItem: PHYReaderItem;
begin
  for nIdx:=FReaders.Count - 1 downto 0 do
  begin
    nItem := FReaders[nIdx];
    nItem.FClient.Free;
    nItem.FClient := nil;

    FreeAndNil(nItem.FCardPre);
    FreeAndNil(nItem.FOptions);
       
    Dispose(nItem);
    FReaders.Delete(nIdx);
  end;

  if nFree then
    FReaders.Free;
  //xxxxx
end;

procedure THYReaderManager.StartReader;
var nIdx,nNum: Integer;
    nType: THYReaderThreadType;
begin
  if not FEnable then Exit;
  FReaderIndex := 0;
  FReaderActive := 0;

  nNum := 0;
  //init
  
  for nIdx:=Low(FThreads) to High(FThreads) do
  begin
    if (nNum >= FThreadCount) or
       (nNum > FReaders.Count) then Exit;
    //线程不能超过预定值,或不多余读头个数

    if nNum < FMonitorCount then
         nType := ttAll
    else nType := ttActive;

    if not Assigned(FThreads[nIdx]) then
      FThreads[nIdx] := THYRFIDReader.Create(Self, nType);
    Inc(nNum);
  end;
end;

procedure THYReaderManager.CloseReader(const nReader: PHYReaderItem);
begin
  if Assigned(nReader) and Assigned(nReader.FClient) then
  begin 
    nReader.FClient.Disconnect;
    if Assigned(nReader.FClient.IOHandler) then
      nReader.FClient.IOHandler.InputBuffer.Clear;
    //xxxxx
  end;
end;

procedure THYReaderManager.StopReader;
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
    for nIdx:=FReaders.Count - 1 downto 0 do
      CloseReader(FReaders[nIdx]);
    //关闭读头
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2016-11-24
//Parm: 读头标识
//Desc: 检索nReader的索引
function THYReaderManager.FindReader(const nReader: string): Integer;
var nIdx: Integer;
begin
  Result := -1;

  for nIdx:=FReaders.Count-1 downto 0 do
  if CompareText(PHYReaderItem(FReaders[nIdx]).FID, nReader) = 0 then
  begin
    Result := nIdx;
    Exit;
  end;
end;

//Date: 2016-11-23
//Parm: 读头;开合继电器
//Desc: 对nReader读头执行继电器开合操作
procedure THYReaderManager.ConnRelay(const nReader: string;
 const nActive: Boolean);
var nStr: string;
    nIdx: Integer;
    nCmd: PHYReaderSetRelay;
begin
  FSyncLock.Enter;
  try
    nIdx := FindReader(nReader);
    if nIdx < 0 then
    begin
      nStr := Format('reader %s not exits.', [nReader]);
      raise Exception.Create(nStr);
    end;

    if not PHYReaderItem(FReaders[nIdx]).FEnable then Exit;
    //invalid reader

    if nActive then
         nStr := cHYReader_ConnectRelay
    else nStr := cHYReader_DisConnRelay;

    for nIdx:=FBuffData.Count - 1 downto 0 do
    begin
      nCmd := FBuffData[nIdx];
      if (CompareText(nReader, nCmd.FReader) = 0) and
         (nCmd.FCommand.FData = nStr) then Exit;
      //same reader,same command
    end;

    New(nCmd);
    FBuffData.Add(nCmd);

    with nCmd.FCommand do
    begin
      FCmd := tCmd_Reader_SetReLay;
      FAddr:= Chr($00);
      FData:= nStr;
    end;

    nCmd.FTimes := 0;
    nCmd.FReader := nReader; 
  finally
    FSyncLock.Leave;
  end;
end;

//Desc: 对nReader读头执行抬杆操作
procedure THYReaderManager.OpenDoor(const nReader: string);
begin
  ConnRelay(nReader, True);
end;

//Date: 2018-04-16
//Parm: 读头标识
//Desc: 获取nReader读头20秒以内的有效卡号
function THYReaderManager.GetLastCard(const nReader: string): string;
var nIdx: Integer;
    nItem: PHYReaderItem;
begin
  FSyncLock.Enter;
  try
    Result := '';
    nIdx := FindReader(nReader);
    if nIdx < 0 then Exit;

    nItem := FReaders[nIdx];
    if GetTickCountDiff(nItem.FCardLast) <= 20 * 1000 then
      Result := nItem.FCard;
    //valid card
  finally
    FSyncLock.Leave;
  end;
end;

procedure THYReaderManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx,nKeep: Integer;
    nXML: TNativeXml;  
    nReader: PHYReaderItem;
    nRoot,nNode,nTmp: TXmlNode;

    //Desc: 拆分多读头标识
    procedure SplitMultiReaders(nNames: string);
    var i,nPos: Integer;
    begin
      nPos := Pos(',', nNames);
      if nPos < 2 then
      begin
        SetLength(nReader.FVReaders, 1);
        nReader.FVReaders[0] := nNames;
        Exit;
      end;

      i := Length(nNames);
      if Copy(nNames, i, 1) <> ',' then
        nNames := nNames + ',';
      //xxxxx

      nPos := Pos(',', nNames);
      while nPos > 0 do
      begin
        nStr := Trim(Copy(nNames, 1, nPos - 1));
        if nStr <> '' then
        begin
          i := Length(nReader.FVReaders);
          SetLength(nReader.FVReaders, i + 1);
          nReader.FVReaders[i] := nStr;
        end;

        System.Delete(nNames, 1, nPos);
        nPos := Pos(',', nNames);
      end;
    end;
begin
  FEnable := False;
  if not FileExists(nFile) then Exit;

  nXML := nil;
  try
    nXML := TNativeXml.Create;
    nXML.LoadFromFile(nFile);
    nRoot := nXML.Root.FindNode('config');

    if not Assigned(nRoot) then
      raise Exception.Create('Invalid RFID102 Config File.');
    //xxxxx

    nNode := nRoot.FindNode('enable');
    if Assigned(nNode) then
      Self.FEnable := nNode.ValueAsString <> 'N';
    //xxxxx

    nNode := nRoot.FindNode('cardlen');
    if Assigned(nNode) then
         FCardLength := nNode.ValueAsInteger
    else FCardLength := 0;

    nNode := nRoot.FindNode('cardprefix');
    if Assigned(nNode) then
         SplitStr(UpperCase(nNode.ValueAsString), FCardPrefix, 0, ',')
    else FCardPrefix.Clear;

    nNode := nRoot.FindNode('thread');
    if Assigned(nNode) then
         FThreadCount := nNode.ValueAsInteger
    else FThreadCount := 1;

    if (FThreadCount < 1) or (FThreadCount > cHYReader_MaxThread) then
      raise Exception.Create('RFID102 Reader Thread-Num Need Between 1-10.');
    //xxxxx

    nNode := nRoot.FindNode('monitor');
    if Assigned(nNode) then
         FMonitorCount := nNode.ValueAsInteger
    else FMonitorCount := 1;

    if (FMonitorCount < 1) or (FMonitorCount > FThreadCount) then
      raise Exception.Create(Format(
        'RFID102 Reader Monitor-Num Need Between 1-%d.', [FThreadCount]));
    //xxxxx

    nNode := nRoot.FindNode('connkeep');
    if Assigned(nNode) then
         nKeep := nNode.ValueAsInteger
    else nKeep := 3000;

    //--------------------------------------------------------------------------
    nRoot := nXML.Root.FindNode('readers');
    if not Assigned(nRoot) then Exit;
    ClearReaders(False);

    for nIdx:=0 to nRoot.NodeCount - 1 do
    begin
      nNode := nRoot.Nodes[nIdx];
      if CompareText(nNode.Name, 'reader') <> 0 then Continue;

      New(nReader);
      FReaders.Add(nReader);

      with nNode,nReader^ do
      begin
        FLocked := False;
        FKeepLast := 0;
        FLastActive := GetTickCount;

        FCard := '';
        FCardLast := 0;
        //card
        
        FConnLast := 0;
        FRelayConn := True;
        //默认吸合时,会发送断开指令

        FID := AttributeByName['id'];
        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsString <> 'N';

        nTmp := FindNode('tunnel');
        if Assigned(nTmp) then
          FTunnel := nTmp.ValueAsString;
        //通道号

        nTmp := FindNode('virtual');
        if Assigned(nTmp) then
        begin
          FVirtual := nTmp.ValueAsString = 'Y';
          FVReader := nTmp.AttributeByName['reader'];
          FVRGroup := nTmp.AttributeByName['group'];

          if nTmp.AttributeByName['type'] = '900' then
               FVType := rt900
          else FVType := rt02n;

          SplitMultiReaders(FVReader);
          //虚拟多读卡器时,拆分数组
          
          nStr := nTmp.AttributeByName['interval'];
          if (nStr <> '') and IsNumber(nStr, False) then
               FVMultiInterval := StrToInt(nStr)
          else FVMultiInterval := 0;
        end else
        begin
          FVirtual := False;
          //默认不虚拟
        end;

        nTmp := FindNode('keeponce');
        if Assigned(nTmp) then
        begin
          FKeepOnce := nTmp.ValueAsInteger;
          FKeepPeer := nTmp.AttributeByName['keeppeer'] = 'Y';
        end else
        begin
          FKeepOnce := 0;
          //默认不合并
        end;

        FClient := TIdTCPClient.Create;
        with FClient do
        begin
          Host := FHost;
          Port := FPort;
          ReadTimeout := 3 * 1000;
          ConnectTimeout := 3 * 1000;   
        end;

        nTmp := FindNode('cardlen');
        if Assigned(nTmp) then
             FCardLen := nTmp.ValueAsInteger
        else FCardLen := 0;

        nTmp := FindNode('cardprefix');
        if Assigned(nTmp) then
        begin
          FCardPre := TStringList.Create;
          SplitStr(UpperCase(nTmp.ValueAsString), FCardPre, 0, ',');
        end else FCardPre := nil;

        nTmp := FindNode('connkeep');
        if Assigned(nTmp) then
             FConnKeep := nTmp.ValueAsInteger
        else FConnKeep := nKeep;

        nTmp := FindNode('options');
        if Assigned(nTmp) then
        begin
          FOptions := TStringList.Create;
          SplitStr(nTmp.ValueAsString, FOptions, 0, ';');
        end else FOptions := nil;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor THYRFIDReader.Create(AOwner: THYReaderManager;
  AType: THYReaderThreadType);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FThreadType := AType;
  FEPCList:=TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := cHYReader_Wait_Short;
end;

destructor THYRFIDReader.Destroy;
begin
  FreeAndNil(FEPCList);
  FWaiter.Free;
  inherited;
end;

procedure THYRFIDReader.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure THYRFIDReader.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    FActiveReader := nil;
    try
      DoExecute;
    finally
      if Assigned(FActiveReader) then
      begin
        FOwner.FSyncLock.Enter;
        FActiveReader.FLocked := False;
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
procedure THYRFIDReader.ScanActiveReader(const nActive: Boolean);
var nIdx: Integer;
    nReader: PHYReaderItem;
begin
  if nActive then //扫描活动读头
  with FOwner do
  begin
    if FReaderActive = 0 then
         nIdx := 1
    else nIdx := 0; //从0开始为完整一轮

    while True do
    begin
      if FReaderActive >= FReaders.Count then
      begin
        FReaderActive := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nReader := FReaders[FReaderActive];
      Inc(FReaderActive);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive > 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
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
      if FReaderIndex >= FReaders.Count then
      begin
        FReaderIndex := 0;
        Inc(nIdx);

        if nIdx >= 2 then Break;
        //扫描一轮,无效退出
      end;

      nReader := FReaders[FReaderIndex];
      Inc(FReaderIndex);
      if nReader.FLocked or (not nReader.FEnable) then Continue;

      if nReader.FLastActive = 0 then 
      begin
        FActiveReader := nReader;
        FActiveReader.FLocked := True;
        Break;
      end;
    end;
  end;
end;

procedure THYRFIDReader.DoExecute;
begin
  FOwner.FSyncLock.Enter;
  try
    if FThreadType = ttAll then
    begin
      ScanActiveReader(False);
      //优先扫描不活动读头

      if not Assigned(FActiveReader) then
        ScanActiveReader(True);
      //辅助扫描活动项
    end else

    if FThreadType = ttActive then //只扫活动线程
    begin
      ScanActiveReader(True);
      //优先扫描活动读头

      if Assigned(FActiveReader) then
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

  if Assigned(FActiveReader) and (not Terminated) then
  try
    if SendReaderCommand(FActiveReader) or ReadCard(FActiveReader) then
    begin
      if FThreadType = ttActive then
        FWaiter.Interval := cHYReader_Wait_Short;
      FActiveReader.FLastActive := GetTickCount;
    end else
    begin
      if (FActiveReader.FLastActive > 0) and
         (GetTickCountDiff(FActiveReader.FLastActive) >= 5 * 1000) then
        FActiveReader.FLastActive := 0;
      //无卡片时,自动转为不活动
    end;
  except
    on E:Exception do
    begin
      FActiveReader.FLastActive := 0;
      //置为不活动

      WriteLog(Format('Reader:[ %s:%d ] Msg: %s', [FActiveReader.FHost,
        FActiveReader.FPort, E.Message]));
      //xxxxx

      FOwner.CloseReader(FActiveReader);
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

//Date: 2015-06-19
//Parm: 原始数据(16进制);校验起始索引;校验终止索引；初始CRC；多项式
//Desc: 中科华益电子标签CRC16校验算法
function Crc16Calc(const nData: string; const nStart,nEnd: Integer;
  nCrcValue: Word=$FFFF; nGenPoly: Word=$8408): Word;
var nIdx,nInt: Integer;
    nCrcTmp: Word;
begin
  Result := 0;
  if (nStart > nEnd) or (nEnd < 1) then Exit;

  nCrcTmp := nCrcValue;
  for nIdx:=nStart to nEnd do
  begin
    nCrcTmp := nCrcTmp xor Ord(nData[nIdx]);

    for nInt:=0 to 7 do
    if (nCrcTmp and $0001)<>0 then
         nCrcTmp := (nCrcTmp shr 1) xor nGenPoly
    else nCrcTmp := nCrcTmp shr 1;
  end;

  Result := nCrcTmp;
end;

//Date: 2015-07-08
//Parm: 待发送数据
//Desc: 华益通信协议封装
function PackSendData(const nData:PRFIDReaderCmd): string;
var nCRC: Word;
begin
  Result := Char(4 + Length(nData.FData)) + nData.FAddr +
            Char(Ord(nData.FCmd)) + nData.FData;
  //len addr cmd data

  nCRC := Crc16Calc(Result, 1, Length(Result));
  Result := Result + Chr(nCRC mod 256) + Chr(nCRC div 256);
end;

//Date: 2015-07-08
//Parm: 目标结构;待解析
//Desc: 华益通信协议解析
function UnPackRecvData(const nItem:PRFIDReaderCmd; const nData: string): Boolean;
var nInt,nLen: Integer;
    nCRC: Word;
begin
  Result := False;
  nInt := Length(nData);
  if nInt < 1 then Exit;

  nLen := Ord(nData[1]);
  if nLen >= nInt then Exit;
  //数据未接收完全

  nCRC := Crc16Calc(nData, 1, nLen - 1);
  if (Ord(nData[nLen]) <> (nCRC mod 256)) or
     (Ord(nData[nLen+1]) <> (nCRC div 256)) then Exit;
  //crc error

  with nItem^ do
  begin
    FLen     := Char(nLen);
    FAddr    := nData[2];
    FCmd     := TReadCmdType(Ord(nData[3]));
    FStatus  := nData[4];

    FData    := Copy(nData, 5, nLen-5);
    FLSB     := nData[nLen];
    FMSB     := nData[nLen+1];

    Result   := FCmd <> tCmd_Err_Cmd;
    //correct command
  end;
end;

//Date: 2015-12-07
//Parm: 卡号
//Desc: 验证nCard是否有效
function THYRFIDReader.IsCardValid(var nCard: string;
  const nReader: PHYReaderItem): Boolean;
var nIdx: Integer;
begin
  Result := False;
  nCard := UpperCase(Trim(nCard));

  nIdx := Length(nCard);
  if nIdx < 1 then Exit;

  if (nReader.FCardLen > 0) or Assigned(nReader.FCardPre) then
  begin
    if (nReader.FCardLen > 0) and (nIdx < nReader.FCardLen) then Exit;
    //length verify
    Result := True;

    if Assigned(nReader.FCardPre) then
    begin
      Result := nReader.FCardPre.Count = 0;
      if Result then Exit;

      for nIdx:=nReader.FCardPre.Count - 1 downto 0 do
      if Pos(nReader.FCardPre[nIdx], nCard) = 1 then
      begin
        Result := True;
        Break;
      end;
    end;

    Exit;
    //读头私有配置优先
  end;

  with FOwner do
  begin
    if (FCardLength > 0) and (nIdx < FCardLength) then Exit;
    //leng verify

    Result := FCardPrefix.Count = 0;
    if Result then Exit;

    for nIdx:=FCardPrefix.Count - 1 downto 0 do
    if Pos(FCardPrefix[nIdx], nCard) = 1 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function THYRFIDReader.ReadCard(const nReader: PHYReaderItem): Boolean;
var nEPC: string;
    nBuf,nRecv: TIdBytes;
    nStart,nLen: Integer;
    nInt,nIdx: Integer;
begin  
  if not nReader.FClient.Connected then
    nReader.FClient.Connect;
  Result := False;

  with FSendItem do
  begin
    FCmd  := tCmd_G2_Seek;
    FAddr := Chr($FF);
    FData := '';
  end;

  Str2Buf(PackSendData(@FSendItem), nBuf);
  nReader.FClient.IOHandler.Write(nBuf);
  Sleep(cHYReader_Sleep_Short);
  //send data

  nReader.FClient.IOHandler.ReadBytes(nRecv, 1, False);
  if Length(nRecv) < 1 then Exit;
  //get data length first

  nInt := nRecv[0];
  nReader.FClient.IOHandler.ReadBytes(nRecv, nInt, True);
  if not UnPackRecvData(@FRecvItem, Buf2Str(nRecv)) then Exit;

  if FRecvItem.FCmd <> FSendItem.FCmd then Exit;
  //not sample cmd

  if (FRecvItem.FStatus <> #01) and (FRecvItem.FStatus <> #02) and
     (FRecvItem.FStatus <> #03) and (FRecvItem.FStatus <> #04) then Exit;
  //xxxxx

  FEPCList.Clear;
  nStart:=1;
  nInt := Ord(FRecvItem.FData[1]);

  for nIdx:=0 to nInt-1 do
  begin
    nLen := Ord(FRecvItem.FData[nStart+1]);
    nEPC := HexStr(Copy(FRecvItem.FData, nStart+2, nLen));
    nStart := nStart + nLen + 1;

    if IsCardValid(nEPC, nReader) then
      FEPCList.Add(nEPC);
    //xxxxx
  end;
    
  if (not Terminated) and (FEPCList.Count > 0) then
  begin
    Result := True;
    //read success
    
    if nReader.FKeepOnce > 0 then
    begin
      if Pos(FEPCList[0], nReader.FCard) > 0 then
      begin
        if GetTickCountDiff(nReader.FKeepLast) < nReader.FKeepOnce then
        begin
          if not nReader.FKeepPeer then
            nReader.FKeepLast := GetTickCount;
          Exit;
        end;
      end;

      nReader.FKeepLast := GetTickCount;
      //同卡号连刷压缩
    end;

    FOwner.FSyncLock.Enter;
    try
      nReader.FCardLast := GetTickCount;
      nReader.FCard := CombinStr(FEPCList, ',', False);
      //multi card
    finally
      FOwner.FSyncLock.Leave;
    end;
    
    if Assigned(FOwner.FOnProc) then
      FOwner.FOnProc(nReader);
    //xxxxx

    if Assigned(FOwner.FOnEvent) then
      FOwner.FOnEvent(nReader);
    //xxxxx
  end;
end;

//Date: 2016-11-23
//Parm: 读头
//Desc: 执行nReader上的指令
function THYRFIDReader.SendReaderCommand(const nReader: PHYReaderItem): Boolean;
var nIdx: Integer;
    nBuf: TIdBytes;
    nCmd,nTmp: PHYReaderSetRelay;
begin
  Result := False;
  if (nReader.FRelayConn) and 
     (GetTickCountDiff(nReader.FConnLast) > nReader.FConnKeep) then
  begin
    nReader.FConnLast := 0;
    nReader.FRelayConn := False;
    FOwner.ConnRelay(nReader.FID, False);
  end; //disconn relay

  with FOwner do
  try
    FSyncLock.Enter;
    //lock sync

    nIdx := 0;
    nCmd := nil;

    while nIdx < FBuffData.Count do
    begin
      nTmp := FBuffData[nIdx];
      if CompareText(nTmp.FReader, nReader.FID) <> 0 then
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

  if not nReader.FClient.Connected then
    nReader.FClient.Connect;
  //make sure connect

  Str2Buf(PackSendData(@nCmd.FCommand), nBuf);
  nReader.FClient.IOHandler.Write(nBuf);
  //send data

  Sleep(cHYReader_Sleep_Short);
  nReader.FClient.IOHandler.ReadBytes(nBuf, 1, False);
  //get data length first
  
  if Length(nBuf) > 0 then
  begin
    nIdx := nBuf[0];
    nReader.FClient.IOHandler.ReadBytes(nBuf, nIdx, True);
  end;

  if nCmd.FCommand.FData = cHYReader_ConnectRelay then
  begin
    nReader.FRelayConn := True;
    nReader.FConnLast := GetTickCount;
    //to disconn next time
  end;

  nCmd.FTimes := cHYReader_CommandRetry;
  //send success,to dispose
  Result := True;
end;

initialization
  gHYReaderManager := nil;
finalization
  FreeAndNil(gHYReaderManager);
end.
