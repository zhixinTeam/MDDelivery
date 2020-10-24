{*******************************************************************************
  作者: dmzn@163.com 2015-04-21
  描述: 网络版语音合成驱动单元
*******************************************************************************}
unit UMgrVoiceNet;

{.$DEFINE DEBUG}
interface

uses
  Windows, Classes, SysUtils, SyncObjs, IdComponent, IdTCPConnection, IdGlobal,
  IdTCPClient, IdSocketHandle, NativeXml, UWaitItem, ULibFun, UMemDataPool,
  USysLoger;

const
  cVoice_CMD_Head       = $FD;         //帧头
  cVoice_CMD_Play       = $01;         //播放
  cVoice_CMD_Stop       = $02;         //停止
  cVoice_CMD_Pause      = $03;         //暂停
  cVoice_CMD_Resume     = $04;         //继续
  cVoice_CMD_QStatus    = $21;         //查询
  cVoice_CMD_StandBy    = $22;         //待命
  cVoice_CMD_Wakeup     = $FF;         //唤醒

  cVoice_Code_GB2312    = $00;
  cVoice_Code_GBK       = $01;
  cVoice_Code_BIG5      = $02;
  cVoice_Code_Unicode   = $03;         //编码

  cVoice_FrameInterval  = 10;          //帧间隔
  cVoice_Status_Busy    = $4E;         //播音状态
  cVoice_Status_Idle    = $4F;         //空闲状态

  cVoice_Content_Len    = 4096;        //文本长度
  cVoice_Content_Keep   = 60 * 1000;   //停留超时

type
  TVoiceWord = record
   FH: Byte;
   FL: Byte;
  end;

  PVoiceDataItem = ^TVoiceDataItem;
  TVoiceDataItem = record
    FHead     : Byte;                  //帧头
    FLength   : TVoiceWord;            //数据长度
    FCommand  : Byte;                  //命令字
    FParam    : Byte;                  //命令参数
    FContent  : array[0..cVoice_Content_Len-1] of Char;
  end;

  PVoiceContentParam = ^TVoiceContentParam;
  TVoiceContentParam = record
    FID       : string;                //内容标识
    FObject   : string;                //对象标识
    FSleep    : Integer;               //对象间隔
    FText     : string;                //播发内容
    FPeerLong : Integer;               //单字时长
    FTimes    : Integer;               //重发次数
    FInterval : Integer;               //重发间隔
    FRepeat   : Integer;               //单次重复
    FReInterval: Integer;              //单次间隔
  end;

  PVoiceResource = ^TVoiceResource;
  TVoiceResource = record
    FKey      : string;                //待处理
    FValue    : string;                //处理内容
  end;

  PVoiceContentNormal = ^TVoiceContentNormal;
  TVoiceContentNormal = record
    FText     : string;                //待播发文本
    FCard     : string;                //执行语音卡
    FContent  : string;                //执行内容标识
    FAddTime  : Int64;                 //内容添加时间
  end;

  PVoiceCardHost = ^TVoiceCardHost;
  TVoiceCardHost = record
    FID       : string;                //卡标识
    FName     : string;                //卡名称
    FHost     : string;                //卡地址
    FPort     : Integer;               //卡端口
    FEnable   : Boolean;               //是否启用
    FDefUsed  : Boolean;               //默认可用
    FContent  : TList;                 //播发内容
    FResource : TList;                 //资源内容

    FVoiceData: TVoiceDataItem;        //语音数据
    FVoiceLast: Cardinal;              //上次播发
    FVoiceTime: Byte;                  //播发次数
    FVoiceKeep: Integer;               //保持时间
    FParam    : PVoiceContentParam;    //播发参数
  end;

type
  TNetVoiceManager = class;
  TNetVoiceConnector = class(TThread)
  private
    FOwner: TNetVoiceManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FClient: TIdTCPClient;
    //网络对象
    FListA: TStrings;
    //字符列表
  protected
    procedure Execute; override;
    procedure Doexecute;
    //执行线程
    procedure DisconnectClient;
    //清理链路
    function IsCardBusy(const nCard: PVoiceCardHost): Boolean;
    //状态判定
    function MakeCardData(const nCard: PVoiceCardHost): Boolean;
    procedure SendVoiceData(const nCard: PVoiceCardHost);
    //发送数据
  public
    constructor Create(AOwner: TNetVoiceManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TNetVoiceManager = class(TObject)
  private
    FCards: TList;
    //语音卡列表
    FBuffer: TList;
    //数据缓冲
    FIDContent: Word;
    //数据标识
    FVoicer: TNetVoiceConnector;
    //语音对象
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    procedure ClearDataList(const nList: TList; const nFree: Boolean = False);
    //清理缓冲
    procedure RegisterDataType;
    //注册数据
    function FindContentParam(const nCard: PVoiceCardHost;
      const nID: string): PVoiceContentParam;
    function FindCardHost(const nID: string): PVoiceCardHost;
    //检索数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartVoice;
    procedure StopVoice;
    //启停读取
    procedure PlayVoice(const nText: string; const nCard: string = '';
      const nContent: string = '');
    //播放语音
  end;

var
  gNetVoiceHelper: TNetVoiceManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TNetVoiceManager, '网络语音合成', nEvent);
end;

function Word2Voice(const nWord: Word): TVoiceWord;
var nByte: Byte;
begin
  Result := TVoiceWord(nWord);
  nByte := Result.FH;

  Result.FH := Result.FL;
  Result.FL := nByte;
end;

function Voice2Word(const nVoice: TVoiceWord): Word;
var nVW: TVoiceWord;
begin
  nVW.FH := nVoice.FL;
  nVW.FL := nVoice.FH;
  Result := Word(nVW); 
end;

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nItem: PVoiceContentNormal;
begin
  if nFlag = 'NVContent' then
  begin
    New(nItem);
    nData := nItem;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
var nItem: PVoiceContentNormal;
begin
  if nFlag = 'NVContent' then
  begin
    nItem := nData;
    Dispose(nItem);
  end;
end;

procedure TNetVoiceManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('NetVoiceManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
    FIDContent := RegDataType('NVContent', 'NetVoiceManager', OnNew, OnFree, 2);
  //xxxxx
end;

//------------------------------------------------------------------------------
constructor TNetVoiceManager.Create;
begin
  RegisterDataType;
  //do first
  
  FCards := TList.Create;
  FBuffer := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TNetVoiceManager.Destroy;
begin
  StopVoice;
  ClearDataList(FBuffer, True);
  
  ClearDataList(FCards, True);
  FSyncLock.Free;
  inherited;
end;

//Date: 2015-04-23
//Parm: 列表;是否释放
//Desc: 清理nList列表
procedure TNetVoiceManager.ClearDataList(const nList: TList;
 const nFree: Boolean);
var i,nIdx: Integer;
    nCard: PVoiceCardHost;
begin
  for nIdx:=nList.Count - 1 downto 0 do
  begin
    if nList = FCards then
    begin
      nCard := nList[nIdx];
      //card host

      if Assigned(nCard.FContent) then
      begin
        for i:=nCard.FContent.Count - 1 downto 0 do
          Dispose(PVoiceContentParam(nCard.FContent[i]));
        nCard.FContent.Free;
      end;

      if Assigned(nCard.FResource) then
      begin
        for i:=nCard.FResource.Count - 1 downto 0 do
          Dispose(PVoiceResource(nCard.FResource[i]));
        nCard.FResource.Free;
      end;

      Dispose(nCard);
      nList.Delete(nIdx);
    end else

    if nList = FBuffer then
    begin
      gMemDataManager.UnLockData(nList[nIdx]);
      nList.Delete(nIdx);
    end;
  end;

  if nFree then
    nList.Free;
  //xxxxx
end;

procedure TNetVoiceManager.StartVoice;
begin
  if FCards.Count < 1 then
    raise Exception.Create('Voice Card List Is Null.');
  //xxxxx

  if not Assigned(FVoicer) then
    FVoicer := TNetVoiceConnector.Create(Self);
  FVoicer.WakupMe;
end;

procedure TNetVoiceManager.StopVoice;
var nIdx: Integer;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;

  ClearDataList(FBuffer);
  //清理待发送缓冲

  for nIdx:=FCards.Count - 1 downto 0 do
    PVoiceCardHost(FCards[nIdx]).FVoiceTime := MAXBYTE;
  //关闭发送标记
end;

//Date: 2015-04-23
//Parm: 语音卡标识
//Desc: 检索标识为nID的语音卡
function TNetVoiceManager.FindCardHost(const nID: string): PVoiceCardHost;
var nIdx,nLen: Integer;
    nDef: PVoiceCardHost;
begin
  Result := nil;
  nDef := nil;
  nLen := FCards.Count - 1;

  for nIdx:=0 to nLen do
  begin
    if CompareText(nID, PVoiceCardHost(FCards[nIdx]).FID) = 0 then
    begin
      Result := FCards[nIdx];
      Break;
    end;

    if (not Assigned(nDef)) and PVoiceCardHost(FCards[nIdx]).FDefUsed then
      nDef := FCards[nIdx];
    //xxxxx
  end;

  if not Assigned(Result) then
    Result := nDef;
  //first default card
end;

//Date: 2015-04-23
//Parm: 语音卡;内容标识
//Desc: 在nCard中检索标识为nID的内容配置
function TNetVoiceManager.FindContentParam(const nCard: PVoiceCardHost;
  const nID: string): PVoiceContentParam;
var nIdx: Integer;
begin
  if nCard.FContent.Count > 0 then
       Result := nCard.FContent[0]
  else Result := nil;

  for nIdx:=nCard.FContent.Count - 1 downto 0 do
  if CompareText(nID, PVoiceContentParam(nCard.FContent[nIdx]).FID) = 0 then
  begin
    Result := nCard.FContent[nIdx];
    Break;
  end;
end;

//Date: 2016-12-09
//Parm: 文本
//Desc: 按宽字节计算nText中有效内容的长度
function CalTextLength(const nText: string): Integer;
var nStr: string;
    nWStr: WideString;
    nIdx,nLen: Integer;
begin
  Result := 0;
  nWStr := nText;
  nLen := Length(nWStr);

  for nIdx:=1 to nLen do
  begin
    nStr := nWStr[nIdx];
    if IsDBCSLeadByte(byte(nStr[1])) or //double byte
       (nStr[1] in ['a'..'z', 'A'..'Z', '0'..'9']) then //single byte
      Inc(Result);
    //xxxxx
  end;
end;

//Date: 2015-04-23
//Parm: 文本;语音卡标识;内容配置标识
//Desc: 在nCard播发使用nContent参数处理的nText,写入缓冲等待处理
procedure TNetVoiceManager.PlayVoice(const nText, nCard, nContent: string);
var nIdx: Integer;
    nData: PVoiceContentNormal;
begin
  if not Assigned(FVoicer) then
    raise Exception.Create('Voice Service Should Start First.');
  //xxxxx

  if CalTextLength(nText) < 1 then Exit;
  //invalid text

  FSyncLock.Enter;
  try
    if not Assigned(FindCardHost(nCard)) then
    begin
      WriteLog(Format('语音卡[ %s ]不存在.', [nCard]));
      Exit;
    end;

    for nIdx:=FBuffer.Count-1 downto 0 do
    begin
      nData := FBuffer[nIdx];
      if (nData.FCard = nCard) and
         (nData.FContent = nContent) and (nData.FText = nText) then
      begin
        nData.FAddTime := GetTickCount;
        Exit;
      end; //合并相同内容
    end;

    nData := gMemDataManager.LockData(FIDContent);
    FBuffer.Add(nData);

    nData.FText := nText;
    nData.FCard := nCard;
    nData.FContent := nContent;
    nData.FAddTime := GetTickCount;

    {$IFDEF DEBUG}
    WriteLog('Add: ' + nText);
    {$ENDIF}
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-04-23
//Parm: 配置文件
//Desc: 读取nFile配置文件
procedure TNetVoiceManager.LoadConfig(const nFile: string);
var i,nIdx: Integer;
    nXML: TNativeXml;
    nRoot,nNode,nTmp,nTnd: TXmlNode;
    
    nCard: PVoiceCardHost;
    nParam: PVoiceContentParam;
    nRes: PVoiceResource;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    begin
      nRoot := nXML.Root.Nodes[nIdx];
      New(nCard);
      FCards.Add(nCard);

      nCard.FVoiceTime := MAXBYTE;
      //标记不发送
      nCard.FVoiceKeep := 0;
      //标记不保持
      nCard.FVoiceLast := 0;
      //标记未发送

      with nRoot,nCard^ do
      begin
        FID     := AttributeByName['id'];
        FName   := AttributeByName['name'];
        FHost   := NodeByName('ip').ValueAsString;
        FPort   := NodeByName('port').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsInteger = 1;

        nTmp := NodeByName('default');
        if Assigned(nTmp) then
             FDefUsed := nTmp.ValueAsString <> 'n'
        else FDefUsed := True;
      end;

      nNode := nRoot.NodeByName('contents');
      if Assigned(nNode) then
      begin
        nCard.FContent := TList.Create;
        //contents

        for i:=0 to nNode.NodeCount - 1 do
        begin
          nTmp := nNode.Nodes[i];
          New(nParam);
          nCard.FContent.Add(nParam);

          with nTmp,nParam^ do
          begin
            FID       := AttributeByName['id'];
            FObject   := NodeByName('object').ValueAsString;
            FSleep    := NodeByName('sleep').ValueAsInteger;
            FText     := NodeByName('text').ValueAsString;

            nTnd := NodeByName('peerword');
            if Assigned(nTnd) then
                 FPeerLong := nTnd.ValueAsInteger
            else FPeerLong := 220;

            FTimes    := NodeByName('times').ValueAsInteger;
            FInterval := NodeByName('interval').ValueAsInteger;
            FRepeat   := NodeByName('repeat').ValueAsInteger;
            FReInterval := NodeByName('reinterval').ValueAsInteger;
          end;
        end;
      end else nCard.FContent := nil;

      nNode := nRoot.NodeByName('resource');
      if Assigned(nNode) then
      begin
        nCard.FResource := TList.Create;
        //resource

        for i:=nNode.NodeCount - 1 downto 0 do
        begin
          nTmp := nNode.Nodes[i];
          New(nRes);
          nCard.FResource.Add(nRes);

          nRes.FKey   := nTmp.AttributeByName['key'];
          nRes.FValue := nTmp.AttributeByName['value'];
        end;
      end else nCard.FResource := nil;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TNetVoiceConnector.Create(AOwner: TNetVoiceManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;

  FClient := TIdTCPClient.Create(nil);
  FClient.ReadTimeout := 3 * 1000;
  FClient.ConnectTimeout := 3 * 1000;
end;

destructor TNetVoiceConnector.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure TNetVoiceConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TNetVoiceConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Desc: 断开套接字
procedure TNetVoiceConnector.DisconnectClient;
begin
  FClient.Disconnect;
  if Assigned(FClient.IOHandler) then
    FClient.IOHandler.InputBuffer.Clear;
  //try to swtich connection
end;

procedure TNetVoiceConnector.Execute;
begin
  while True do
  try
    FWaiter.EnterWait;
    if Terminated then
    begin
      DisconnectClient;
      Exit;
    end;

    Doexecute;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TNetVoiceConnector.Doexecute;
var nStr: string;
    nIdx: Integer;
    nCard: PVoiceCardHost;
begin
  with FOwner do
  begin
    nCard := nil;
    //init

    for nIdx:=FCards.Count - 1 downto 0 do
    try
      if Terminated then Exit;
      nCard := FCards[nIdx];

      FSyncLock.Enter;
      try
        MakeCardData(nCard);
      finally
        FSyncLock.Leave;
      end;

      SendVoiceData(nCard);
      //发送数据
    except
      on E: Exception do
      begin
        if Assigned(nCard) then
        begin
          nCard.FVoiceTime := nCard.FVoiceTime + 1;
          //发送累计

          nStr := 'Card:[ %s:%d ] Msg: %s';
          nStr := Format(nStr, [nCard.FHost, nCard.FPort, E.Message]);
          WriteLog(nStr);
        end;

        DisconnectClient;
        //断开链路
      end;
    end;
  end;
end;

//Date: 2016-11-25
//Parm: 语音卡
//Desc: 测试nCard是否处于繁忙状态
function TNetVoiceConnector.IsCardBusy(const nCard: PVoiceCardHost): Boolean;
var nBuf: TIdBytes;
    nData: TVoiceDataItem;
begin
  Result := GetTickCountDiff(nCard.FVoiceLast) < nCard.FVoiceKeep;
  if Result then Exit; //keep short time
  if (not FClient.Connected) or (FClient.Host <> nCard.FHost) then Exit;

  with nData do
  begin
    FHead := cVoice_CMD_Head;
    FLength := Word2Voice(1);
    FCommand := cVoice_CMD_QStatus;
  end;

  SetLength(nBuf, 0);
  nBuf := RawToBytes(nData, Voice2Word(nData.FLength) + 3);
  //数据缓冲

  FClient.IOHandler.Write(nBuf);
  Sleep(cVoice_FrameInterval);
  //发送并等待  

  FClient.IOHandler.ReadBytes(nBuf, 1, False);
  Result := (Length(nBuf) > 0) and (nBuf[0] <> cVoice_Status_Idle);
end;

//Desc: 将发送缓冲数据合并到语音卡缓冲
function TNetVoiceConnector.MakeCardData(const nCard: PVoiceCardHost): Boolean;
var nStr: string;
    i,nIdx,nLen: Integer;
    nRes: PVoiceResource;
    nParm: PVoiceContentParam;
    nTxt: PVoiceContentNormal;

    //Desc: 释放缓存项
    procedure DisposeBufferItem;
    begin
      gMemDataManager.UnLockData(FOwner.FBuffer[nIdx]);
      FOwner.FBuffer.Delete(nIdx);
    end;
begin
  with FOwner do
  begin
    Result := False;
    nIdx := 0;
    
    while nIdx < FBuffer.Count do
    begin
      nTxt := FBuffer[nIdx];
      if GetTickCountDiff(nTxt.FAddTime) > cVoice_Content_Keep then
      begin
        nStr := '语音卡[ %s ]内容超时.';
        nStr := Format(nStr, [nTxt.FCard]);
        WriteLog(nStr);

        DisposeBufferItem;
        Continue;
      end;

      if FindCardHost(nTxt.FCard) <> nCard then
      begin
        Inc(nIdx);
        Continue;
      end; //非本卡播放

      if not nCard.FEnable then
      begin
        nStr := '语音卡[ %s ]已停用.';;
        nStr := Format(nStr, [nCard.FID]);
        WriteLog(nStr);

        DisposeBufferItem;
        Continue;
      end;

      nParm := FindContentParam(nCard, nTxt.FContent);
      if not Assigned(nParm) then
      begin
        nStr := '语音卡[ %s:%s ]内容标识不存在.';;
        nStr := Format(nStr, [nCard.FID, nTxt.FContent]);
        WriteLog(nStr);

        DisposeBufferItem;
        Continue;
      end;

      if IsCardBusy(nCard) then Exit;
      //忙时不处理

      //------------------------------------------------------------------------
      SplitStr(nTxt.FText, FListA, 0, #9, False);
      //拆分: YA001 #9 YA002

      for i:=FListA.Count - 1 downto 0 do
      begin
        FListA[i] := Trim(FListA[i]);
        if FListA[i] = '' then
          FListA.Delete(i);
        //清理空行
      end;

      if (FListA.Count > 1) or (nTxt.FText[1] = #9) then
      begin
        nStr := '';
        nLen := FListA.Count - 1;

        for i:=0 to nLen do
        if Trim(FListA[i]) <> '' then
        begin
          if nIdx = nLen then
               nStr := nStr + FListA[i]
          else nStr := nStr + FListA[i] + Format('[p%d]', [nParm.FSleep]);
        end;

        nStr := StringReplace(nParm.FText, nParm.FObject, nStr,
                                           [rfReplaceAll, rfIgnoreCase]);
        //text real content
      end else nStr := nTxt.FText;

      for i:=nCard.FResource.Count - 1 downto 0 do
      begin
        nRes := nCard.FResource[i];
        nStr := StringReplace(nStr, nRes.FKey, nRes.FValue,
                                    [rfReplaceAll, rfIgnoreCase]);
        //resource replace
      end;

      for i:=2 to nParm.FRepeat do
        nStr := nStr + Format('[p%d]', [nParm.FReInterval]) + nStr;
      //xxxxx

      //------------------------------------------------------------------------
      with nCard.FVoiceData do
      begin
        FHead := cVoice_CMD_Head;
        FCommand := cVoice_CMD_Play;
        FParam := cVoice_Code_GB2312;

        nLen := cVoice_Content_Len - 7;
        //避免内容超长                
        if Length(nStr) > nLen then
          nStr := Copy(nStr, 1, nLen);
        nStr := '[m3]' + nStr + '[d]';
        
        StrPCopy(@FContent[0], nStr);
        FLength := Word2Voice(Length(nStr) + 2);

        with nCard^ do
        begin
          FParam := nParm;
          FVoiceLast := 0;
          FVoiceTime := 0;

          FVoiceKeep := CalTextLength(nStr) * nParm.FPeerLong;
          //计算播放内容的时长
        end;
      end;

      {$IFDEF DEBUG}
      WriteLog('Get: ' + nTxt.FText);
      {$ENDIF}

      DisposeBufferItem;
      //处理完毕,释放
      Result := True;
      Exit;
    end;
  end;
end;

//Date: 2015-04-23
//Parm: 语音卡
//Desc: 向nCard发送缓冲区数据
procedure TNetVoiceConnector.SendVoiceData(const nCard: PVoiceCardHost);
var nBuf: TIdBytes;
begin
  if nCard.FVoiceTime = MAXBYTE then Exit;
  //不发送标记
  if nCard.FVoiceTime >= nCard.FParam.FTimes then Exit;
  //发送次数完成
  if GetTickCountDiff(nCard.FVoiceLast) < nCard.FParam.FInterval * 1000 then Exit;
  //发送间隔未到

  if FClient.Host <> nCard.FHost then
  begin
    DisconnectClient;
    FClient.Host := nCard.FHost;
    FClient.Port := nCard.FPort;
  end;

  if not FClient.Connected then
    FClient.Connect;
  //xxxxx

  SetLength(nBuf, 0);
  nBuf := RawToBytes(nCard.FVoiceData, Voice2Word(nCard.FVoiceData.FLength) + 3);
  //数据缓冲

  FClient.IOHandler.Write(nBuf);
  Sleep(cVoice_FrameInterval);
  //发送并等待

  nCard.FVoiceLast := GetTickCount;
  nCard.FVoiceTime := nCard.FVoiceTime + 1;
  //计数君
end;

initialization
  gNetVoiceHelper := nil;
finalization
  FreeAndNil(gNetVoiceHelper);
end.
