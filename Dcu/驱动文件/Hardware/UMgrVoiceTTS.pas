{*******************************************************************************
  作者: dmzn@163.com 2019-10-24
  描述: 基于windows tts的语音合成驱动
*******************************************************************************}
unit UMgrVoiceTTS;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, ActiveX, ComObj, Variants, SpeechLib_TLB,
  NativeXml, UWaitItem, ULibFun, UMemDataPool, USysLoger;

const
  cVoice_FrameInterval  = 10;          //帧间隔
  cVoice_Status_Busy    = $4E;         //播音状态
  cVoice_Status_Idle    = $4F;         //空闲状态

  cVoice_Content_Len    = 4096;        //文本长度
  cVoice_Content_Keep   = 60 * 1000;   //停留超时

type
  PVoiceContentParam = ^TVoiceContentParam;
  TVoiceContentParam = record
    FID       : string;                //内容标识
    FObject   : string;                //对象标识
    FSleep    : Integer;               //对象间隔
    FText     : string;                //播发内容
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
    FContent  : string;                //执行内容标识
    FAddTime  : Int64;                 //内容添加时间
  end;

  PVoiceConfig = ^TVoiceConfig;
  TVoiceConfig = record
    FEnable   : Boolean;               //是否启用
    FShowLog  : Boolean;               //显示日志
    FVoiceName: string;                //语音库名
    FContent  : TList;                 //播发内容
    FResource : TList;                 //资源内容

    FVoiceData: string;                //语音数据
    FVoiceLast: Cardinal;              //上次播发
    FVoiceTime: Byte;                  //播发次数
    FParam    : PVoiceContentParam;    //播发参数
  end;

type
  TVoiceManager = class;
  TVoiceConnector = class(TThread)
  private
    FOwner: TVoiceManager;
    //拥有者
    FTTSVoicer: ISpeechVoice;
    //播放对象
    FWaiter: TWaitObject;
    //等待对象
    FListA: TStrings;
    //字符列表
  protected
    procedure Execute; override;
    //执行线程
    procedure SetTTSVoice(const nName: string);
    //设置语音库
    function MakeVoiceData: Boolean;
    procedure SendVoiceData;
    //发送数据
  public
    constructor Create(AOwner: TVoiceManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TVoiceManager = class(TObject)
  private
    FConfig: TVoiceConfig;
    //配置信息
    FBuffer: TList;
    //数据缓冲
    FIDContent: Word;
    //数据标识
    FVoicer: TVoiceConnector;
    //语音对象
    FSyncLock: TCriticalSection;
    //同步锁
  protected
    procedure ClearDataList(const nList: TList; const nFree: Boolean = False);
    //清理缓冲
    procedure RegisterDataType;
    //注册数据
    function FindContentParam(const nID: string): PVoiceContentParam;
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
    procedure PlayVoice(const nText: string; const nContent: string = '');
    //播放语音
  end;

var
  gTTSVoiceManager: TVoiceManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TVoiceManager, 'TTS Voice Manager', nEvent);
end;

procedure OnNew(const nFlag: string; const nType: Word; var nData: Pointer);
var nItem: PVoiceContentNormal;
begin
  if nFlag = 'TTSContent' then
  begin
    New(nItem);
    nData := nItem;
  end;
end;

procedure OnFree(const nFlag: string; const nType: Word; const nData: Pointer);
var nItem: PVoiceContentNormal;
begin
  if nFlag = 'TTSContent' then
  begin
    nItem := nData;
    Dispose(nItem);
  end;
end;

procedure TVoiceManager.RegisterDataType;
begin
  if not Assigned(gMemDataManager) then
    raise Exception.Create('NetVoiceManager Needs MemDataManager Support.');
  //xxxxx

  with gMemDataManager do
    FIDContent := RegDataType('TTSContent', 'TTSVoiceManager', OnNew, OnFree, 2);
  //xxxxx
end;

//------------------------------------------------------------------------------
constructor TVoiceManager.Create;
begin
  RegisterDataType;
  with FConfig do
  begin
    FVoiceTime := MAXBYTE;
    //标记不发送
    FVoiceLast := 0;
    //标记未发送

    FResource := nil;
    FContent := TList.Create;
  end;

  FBuffer := TList.Create;
  FSyncLock := TCriticalSection.Create;
end;

destructor TVoiceManager.Destroy;
begin
  StopVoice;
  ClearDataList(FBuffer, True);
  ClearDataList(FConfig.FContent, True);
  ClearDataList(FConfig.FResource, True);

  FSyncLock.Free;
  inherited;
end;

//Date: 2015-04-23
//Parm: 列表;是否释放
//Desc: 清理nList列表
procedure TVoiceManager.ClearDataList(const nList: TList; const nFree: Boolean);
var nIdx: Integer;
begin
  if Assigned(nList) then
  begin
    for nIdx:=nList.Count - 1 downto 0 do
    begin
      if nList = FBuffer then
      begin
        gMemDataManager.UnLockData(nList[nIdx]);
        //unlock
      end else

      if nList = FConfig.FContent then
      begin
        Dispose(PVoiceContentParam(FConfig.FContent[nIdx]));
        //free
      end else

      if nList = FConfig.FResource then
      begin
        Dispose(PVoiceResource(FConfig.FResource[nIdx]));
        //free
      end;
    end;

    if nFree then
         nList.Free
    else nList.Clear;
  end;
end;

procedure TVoiceManager.StartVoice;
begin
  if not FConfig.FEnable then Exit;
  //no use

  if not Assigned(FVoicer) then
    FVoicer := TVoiceConnector.Create(Self);
  FVoicer.WakupMe;
end;

procedure TVoiceManager.StopVoice;
begin
  if Assigned(FVoicer) then
    FVoicer.StopMe;
  FVoicer := nil;

  FConfig.FVoiceTime := MAXBYTE;
  ClearDataList(FBuffer);
  //清理待发送缓冲
end;

//Date: 2015-04-23
//Parm: 语音卡;内容标识
//Desc: 在nCard中检索标识为nID的内容配置
function TVoiceManager.FindContentParam(const nID: string): PVoiceContentParam;
var nIdx: Integer;
begin
  if FConfig.FContent.Count > 0 then
       Result := FConfig.FContent[0]
  else Result := nil;

  for nIdx:=FConfig.FContent.Count - 1 downto 0 do
  if CompareText(nID, PVoiceContentParam(FConfig.FContent[nIdx]).FID) = 0 then
  begin
    Result := FConfig.FContent[nIdx];
    Break;
  end;
end;

//Date: 2015-04-23
//Parm: 文本;内容配置标识
//Desc: 播发使用nContent参数处理的nText,写入缓冲等待处理
procedure TVoiceManager.PlayVoice(const nText,nContent: string);
var nTxt: string;
    nIdx: Integer;
    nData: PVoiceContentNormal;
begin
  nTxt := Trim(nText);
  if (not FConfig.FEnable) or (nTxt = '') then Exit;
  //invalid text

  if not Assigned(FVoicer) then
    raise Exception.Create('Voice Service Should Start First.');
  //xxxxx

  FSyncLock.Enter;
  try
    for nIdx:=FBuffer.Count-1 downto 0 do
    begin
      nData := FBuffer[nIdx];
      if (nData.FContent = nContent) and (nData.FText = nTxt) then
      begin
        nData.FAddTime := GetTickCount;
        Exit;
      end; //合并相同内容
    end;

    nData := gMemDataManager.LockData(FIDContent);
    FBuffer.Add(nData);

    nData.FText := nTxt;
    nData.FContent := nContent;
    nData.FAddTime := GetTickCount;
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2015-04-23
//Parm: 配置文件
//Desc: 读取nFile配置文件
procedure TVoiceManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;
    nRoot,nNode: TXmlNode;
    nRes: PVoiceResource;
    nParam: PVoiceContentParam;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nRoot := nXML.Root.NodeByNameR('config');
    with nRoot,FConfig do
    begin
      FEnable := NodeByNameR('enable').ValueAsString <> 'N';
      FVoiceName := Trim(NodeByNameR('voicename').ValueAsString);

      nNode := NodeByName('showlog');
      if Assigned(nNode) then
           FShowLog := nNode.ValueAsString <> 'N'
      else FShowLog := True;
    end;

    nRoot := nXML.Root.NodeByNameR('contents');
    for nIdx:=0 to nRoot.NodeCount - 1 do
    with nRoot.Nodes[nIdx] do
    begin
      New(nParam);
      FConfig.FContent.Add(nParam);

      with nParam^ do
      begin
        FID       := AttributeByName['id'];
        FObject   := NodeByName('object').ValueAsString;
        FSleep    := NodeByName('sleep').ValueAsInteger;
        FText     := NodeByName('text').ValueAsString;

        FTimes    := NodeByName('times').ValueAsInteger;
        FInterval := NodeByName('interval').ValueAsInteger;
        FRepeat   := NodeByName('repeat').ValueAsInteger;
        FReInterval := NodeByName('reinterval').ValueAsInteger;
      end;
    end;

    nRoot := nXML.Root.NodeByName('resource');
    if Assigned(nRoot) then
    begin
      FConfig.FResource := TList.Create;
      //resource

      for nIdx:=nRoot.NodeCount - 1 downto 0 do
      with nRoot.Nodes[nIdx] do
      begin
        New(nRes);
        FConfig.FResource.Add(nRes);

        nRes.FKey   := AttributeByName['key'];
        nRes.FValue := AttributeByName['value'];
      end;
    end else FConfig.FResource := nil;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TVoiceConnector.Create(AOwner: TVoiceManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FTTSVoicer := nil;
  FListA := TStringList.Create;
  
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;
end;

destructor TVoiceConnector.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure TVoiceConnector.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TVoiceConnector.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TVoiceConnector.Execute;
begin
  CoInitialize(nil);
  try
    FTTSVoicer := CoSpVoice.Create;
    SetTTSVoice(FOwner.FConfig.FVoiceName);
    //init voice

    while True do
    begin
      FWaiter.EnterWait;
      if Terminated then Break;

      FOwner.FSyncLock.Enter;
      try
        if not MakeVoiceData then Continue;
        //no data
      finally
        FOwner.FSyncLock.Leave;
      end;

      SendVoiceData;
      //发送数据
    end;

    FTTSVoicer := nil;
    //free object
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;

  CoUninitialize();
end;

//Date: 2019-10-31
//Parm: 语音库名称
//Desc: 设置当前语音库为nName
procedure TVoiceConnector.SetTTSVoice(const nName: string);
var nStr: string;
    nIdx: Integer;
    nSOToken: ISpeechObjectToken;
    nSOTokens: ISpeechObjectTokens;
begin
  nSOTokens := FTTSVoicer.GetVoices('', '');
  for nIdx := 0 to nSOTokens.Count - 1 do
  begin
    nSOToken := nSOTokens.Item(nIdx);
    nStr := nSOToken.GetDescription(0);
    WriteLog(Format('VoiceName %d: %s', [nIdx, nStr]));

    if (nName <> '') and (Pos(nName, nStr) > 0) then
      FTTSVoicer.Voice := nSOToken;
    //set voice
  end;
end;

//Desc: 将发送缓冲数据合并到语音卡缓冲
function TVoiceConnector.MakeVoiceData: Boolean;
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
        WriteLog('播放语音内容超时.');
        DisposeBufferItem;
        Continue;
      end;

      nParm := FindContentParam(nTxt.FContent);
      if not Assigned(nParm) then
      begin
        nStr := Format('语音内容标识[ %s ]不存在.', [nTxt.FContent]);
        WriteLog(nStr);

        DisposeBufferItem;
        Continue;
      end;

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
          else nStr := nStr + FListA[i] + Format('<silence msec="%d"/>', [nParm.FSleep]);
        end;

        nStr := StringReplace(nParm.FText, nParm.FObject, nStr,
                                           [rfReplaceAll, rfIgnoreCase]);
        //text real content
      end else nStr := nTxt.FText;

      for i:=FConfig.FResource.Count - 1 downto 0 do
      begin
        nRes := FConfig.FResource[i];
        nStr := StringReplace(nStr, nRes.FKey, nRes.FValue,
                                    [rfReplaceAll, rfIgnoreCase]);
        //resource replace
      end;

      for i:=2 to nParm.FRepeat do
        nStr := nStr + Format('<silence msec="%d"/>', [nParm.FReInterval]) + nStr;
      //xxxxx

      with FConfig do
      begin
        FVoiceData := nStr;
        FParam := nParm;
        FVoiceLast := 0;
        FVoiceTime := 0;
      end;

      DisposeBufferItem;
      //处理完毕,释放
      Result := True;
      Exit;
    end;
  end;
end;

//Date: 2015-04-23
//Desc: 发送缓冲区数据
procedure TVoiceConnector.SendVoiceData;
begin
  with FOwner do
  begin
    if FConfig.FVoiceTime = MAXBYTE then Exit;
    //不发送标记
    if FConfig.FVoiceTime >= FConfig.FParam.FTimes then Exit;
    //发送次数完成
    if GetTickCountDiff(FConfig.FVoiceLast) < FConfig.FParam.FInterval * 1000 then Exit;
    //发送间隔未到

    try
      FTTSVoicer.Speak(FConfig.FVoiceData, SVSFDefault or SVSFIsXML);
      //voice

      if FConfig.FShowLog then
        WriteLog(FConfig.FVoiceData);
      //loged
    finally
      FConfig.FVoiceLast := GetTickCount;
      FConfig.FVoiceTime := FConfig.FVoiceTime + 1;
      //计数君
    end;
  end;
end;

initialization
  gTTSVoiceManager := nil;
finalization
  FreeAndNil(gTTSVoiceManager);
end.
