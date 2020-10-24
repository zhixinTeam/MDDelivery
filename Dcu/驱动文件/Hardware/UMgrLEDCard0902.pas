{*******************************************************************************
  作者: dmzn@ylsoft.com 2011-03-13
  描述: LED控制卡管理
*******************************************************************************}
unit UMgrLEDCard;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, Forms, Graphics, NativeXml, UWaitItem, ULibFun,
  UMgrQueue, USysLoger, JclUnicode;

const
  //重发次数
  cSend_TryNum                      = 3;

  //临时内容文件
  cSend_HeadFile                    = 'head.txt';
  cSend_HeadFileRTF                 = 'head.rtf';
  cSend_FootFile                    = 'foot.txt';

  //双绘制时文件编号起始
  cSend_DoublePaintBase             = 100;
  cSend_DoublePaintFile             = 'LEDRes.txt';

  //控制器通讯模式
  SEND_MODE_SERIALPORT              = 0;
  SEND_MODE_NETWORK                 = 2;
  SEND_MODE_SAVEFILE                = 5;
  
  //用户发送信息命令表
  SEND_CMD_PARAMETER                = $A1FF; //加载屏参数。
  SEND_CMD_SCREENSCAN               = $A1FE; //设置扫描方式。
  SEND_CMD_SENDALLPROGRAM           = $A1F0; //发送所有节目信息。
  SEND_CMD_POWERON                  = $A2FF; //强制开机
  SEND_CMD_POWEROFF                 = $A2FE; //强制关机
  SEND_CMD_TIMERPOWERONOFF          = $A2FD; //定时开关机
  SEND_CMD_CANCEL_TIMERPOWERONOFF   = $A2FC; //取消定时开关机
  SEND_CMD_RESIVETIME               = $A2FB; //校正时间。
  SEND_CMD_ADJUSTLIGHT              = $A2FA; //亮度调整。

  //通讯错误返回代码值
  RETURN_NOERROR                    = 0;
  RETURN_ERROR_NO_USB_DISK          = $F5;
  RETURN_ERROR_NOSUPPORT_USB        = $F6;
  RETURN_ERROR_AERETYPE             = $F7;
  RETURN_ERROR_RA_SCREENNO          = $F8;
  RETURN_ERROR_NOFIND_AREAFILE      = $F9;
  RETURN_ERROR_NOFIND_AREA          = $FA;
  RETURN_ERROR_NOFIND_PROGRAM       = $FB;
  RETURN_ERROR_NOFIND_SCREENNO      = $FC;
  RETURN_ERROR_NOW_SENDING          = $FD;
  RETURN_ERROR_OTHER                = $FF;

  //控制器类型
  CONTROLLER_TYPE_4M1               = $0142;
  CONTROLLER_TYPE_4M                = $0042;
  CONTROLLER_TYPE_5M1               = $0052;
  CONTROLLER_TYPE_5M2               = $0252;
  CONTROLLER_TYPE_5M3               = $0352;
  CONTROLLER_TYPE_5M4               = $0452;

  CONTROLLER_BX_5E1                 = $0154;
  CONTROLLER_BX_5E2                 = $0254;
  CONTROLLER_BX_5E3                 = $0354; //动态区域卡

  {************************* 以下定义用于动态区域卡 ***************************}
  RUN_MODE_CYCLE_SHOW               = 0;
  //动态区数据循环显示；
  RUN_MODE_SHOW_LAST_PAGE           = 1;
  //动态区数据显示完成后静止显示最后一页数据；
  RUN_MODE_SHOW_CYCLE_WAITOUT_NOSHOW = 2;
  //动态区数据循环显示，超过设定时间后数据仍未更新时不再显示；
  RUN_MODE_SHOW_ORDERPLAYED_NOSHOW  = 4;
  //动态区数据顺序显示，显示完最后一页后就不再显示

  //返回状态代码定义
  RETURN_ERROR_NOFIND_DYNAMIC_AREA  = $E1;
  RETURN_ERROR_NOFIND_DYNAMIC_AREA_FILE_ORD = $E2;
  RETURN_ERROR_NOFIND_DYNAMIC_AREA_PAGE_ORD = $E3;
  RETURN_ERROR_NOSUPPORT_FILETYPE   = $E4;

type
  TCardCode = record
    FCode: Word;
    FDesc: string;
  end;

const
  cCardEffects: array[0..39] of TCardCode = (
             (FCode: $00; FDesc:'随机显示'),
             (FCode: $01; FDesc:'静态'),
             (FCode: $02; FDesc:'快速打出'),
             (FCode: $03; FDesc:'向左移动'),
             (FCode: $04; FDesc:'向左连移'),
             (FCode: $05; FDesc:'向上移动'),
             (FCode: $06; FDesc:'向上连移'),
             (FCode: $07; FDesc:'闪烁'),
             (FCode: $08; FDesc:'飘雪'),
             (FCode: $09; FDesc:'冒泡'),
             (FCode: $0A; FDesc:'中间移出'),
             (FCode: $0B; FDesc:'左右移入'),
             (FCode: $0C; FDesc:'左右交叉移入'),
             (FCode: $0D; FDesc:'上下交叉移入'),
             (FCode: $0E; FDesc:'画卷闭合'),
             (FCode: $0F; FDesc:'画卷打开'),
             (FCode: $10; FDesc:'向左拉伸'),
             (FCode: $11; FDesc:'向右拉伸'),
             (FCode: $12; FDesc:'向上拉伸'),
             (FCode: $13; FDesc:'向下拉伸'),
             (FCode: $14; FDesc:'向左镭射'),
             (FCode: $15; FDesc:'向右镭射'),
             (FCode: $16; FDesc:'向上镭射'),
             (FCode: $17; FDesc:'向下镭射'),
             (FCode: $18; FDesc:'左右交叉拉幕'),
             (FCode: $19; FDesc:'上下交叉拉幕'),
             (FCode: $1A; FDesc:'分散左拉'),
             (FCode: $1B; FDesc:'水平百页'),
             (FCode: $1D; FDesc:'向左拉幕'),
             (FCode: $1E; FDesc:'向右拉幕'),
             (FCode: $1F; FDesc:'向上拉幕'),
             (FCode: $20; FDesc:'向下拉幕'),
             (FCode: $21; FDesc:'左右闭合'),
             (FCode: $22; FDesc:'左右对开'),
             (FCode: $23; FDesc:'上下闭合'),
             (FCode: $24; FDesc:'上下对开'),
             (FCode: $25; FDesc:'向右连移'),
             (FCode: $26; FDesc:'向右连移'),
             (FCode: $27; FDesc:'向下移动'),
             (FCode: $28; FDesc:'向下连移'));
  //系统支持的特效

type
  TCardFont = record
    FFontName: string;      //字体
    FFontSize: Integer;     //大小
    FFontBold: Boolean;     //加粗

    FSpeed: Integer;        //运行
    FKeep: Integer;         //停留
    FEffect: Integer;       //特效
  end;

  TDrawDataStyle = (dsColDisp, dsRowDisp);
  //数据域绘制方法:
  //1.列方式显示: 车辆以列方式排列,突出先后顺序.
  //2.行方式显示: 每车一行,突出车辆附加信息.

  PCardItem = ^TCardItem;
  TCardItem = record
    FType: Integer;         //类型(4m,4m1)
    FID: string;            //标识
    FName: string;          //名称
    FGroup: string;         //分组
    FDoublePaint: Boolean;  //双绘制,小语种翻译
    FEnabled: Boolean;      //是否启用

    FIP: string;            //IP
    FPort: Integer;         //端口
    FWidth: Integer;        //宽度
    FHeight: Integer;       //高度
    FDataOE: Integer;       //OE设定

    FHeadEnable: Boolean;
    FHeadRect: TRect;
    FHeadText: string;
    FHeadFont: TCardFont;   //表头

    FDataEnable: Boolean;
    FStatusEnable: Boolean;
    FDrawStyle: TDrawDataStyle;
    FColWidth: array of Integer;
    FRowNum: Integer;
    FRowHeight: Integer;
    FPicNum: Integer;
    FDataRect: TRect;
    FDataFont: TCardFont;
    FDataTunnels: string;   //有效通道
    FDataTunnelsEx: string; //有效通道2
    FDataItemNum: Integer;  //明细数量
    FFontHeadSAdjust: Integer;
    FFontHeadLAdjust: Integer;
    FFontDataLAdjust: Integer; //数据

    FFootEnable: Boolean;
    FFootRect: TRect;
    FFootText: string;
    FFootDefault: string;
    FFootDefaultOnly: Boolean;
    FFootFormat: string;
    FFootFont: TCardFont;   //表尾
  end;

  TCardManager = class;
  TCardSendThread = class(TThread)
  private
    FOwner: TCardManager;
    //拥有者
    FFileOpt: TStrings;
    FFileUTF: TWideStringList;
    //文件对象
    FWaiter: TWaitObject;
    //等待对象
    FNowItem: PCardItem;
    //当前对象
    FQueueLast: Int64;
    //队列变动
    FDLLHandle: THandle;
    //驱动库
  protected
    procedure Execute; override;
    //执行线程
    procedure DrawQueue(const nFileBase: Integer);
    //绘制队列
    function SendDynamicData: Boolean;
    function SendQueueData: Boolean;
    //发送队列
    procedure BuildFootFormatText;
    //构建表尾
    function GetUTFResource(const nStr: WideString): WideString;
    //UTF资源
    function GetBMPFile(const nGroup: string; nID: Integer): string;
    //图片文件名
  public
    constructor Create(AOwner: TCardManager);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TCardManager = class(TObject)
  private
    FCards: TList;
    //卡列表     
    FFileName: string;
    //存储文件
    FTempDir: string;
    //临时目录
    FSender: TCardSendThread;
    //发送线程
  protected
    procedure ClearList(const nFree: Boolean);
    //清理资源
    procedure SetFileName(const nFile: string);
    //设置文件
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure StartSender;
    procedure StopSender;
    //启停发送
    function GetErrorDesc(const nErr: Integer): string;
    //错误描述
    property Cards: TList read FCards;
    property TempDir: string read FTempDir write FTempDir;
    property FileName: string read FFileName write SetFileName;
    //属性相关
  end;

var
  gCardManager: TCardManager = nil;
  //全局使用

implementation

const
  cDLL        = 'BX_IV.dll';

function InitDLLResource(nHandle: Integer): integer; stdcall; external cDLL;
procedure FreeDLLResource; stdcall; external cDLL;
//初始化释放
function AddScreen(nControlType, nScreenNo, nWidth, nHeight, nScreenType,
  nPixelMode: Integer; nDataDA, nDataOE: Integer; nRowOrder, nFreqPar: Integer;
  pCom: PChar; nBaud: Integer;
  pSocketIP: PChar; nSocketPort: Integer;
  pFileName: PChar): integer; stdcall; stdcall; external cDLL;
//添加、设置显示屏
function AddScreenProgram(nScreenNo, nProgramType: Integer; nPlayLength: Integer;
  nStartYear, nStartMonth, nStartDay, nEndYear, nEndMonth, nEndDay: Integer;
  nMonPlay, nTuesPlay, nWedPlay, nThursPlay, bFriPlay, nSatPlay,
  nSunPlay: integer; nStartHour, nStartMinute, nEndHour,
  nEndMinute: Integer): Integer; stdcall; external cDLL;
//向指定显示屏添加节目
function AddScreenProgramBmpTextArea(nScreenNo, nProgramOrd: Integer;
  nX, nY, nWidth, nHeight: integer): Integer; stdcall; external cDLL;
//向指定显示屏指定节目添加图文区域
function AddScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd,
  nAreaOrd: Integer; pFileName: PChar; nShowSingle: Integer;
  pFontName: PChar; nFontSize, nBold, nFontColor: Integer; nStunt, nRunSpeed,
  nShowTime: Integer): Integer; stdcall; external cDLL;
//向指定显示屏指定节目指定区域添加文件
function DeleteScreen(nScreenNo: Integer): Integer; stdcall; external cDLL;
//删除指定显示屏
function DeleteScreenProgram(nScreenNo,
  nProgramOrd: Integer): Integer; stdcall; external cDLL;
//删除指定显示屏指定节目
function DeleteScreenProgramArea(nScreenNo, nProgramOrd,
  nAreaOrd: Integer): Integer; stdcall; external cDLL;
//删除指定显示屏指定节目的指定区域
function DeleteScreenProgramAreaBmpTextFile(nScreenNo, nProgramOrd, nAreaOrd,
  nFileOrd: Integer): Integer; stdcall; external cDLL;
//删除指定显示屏指定节目指定图文区域的指定文件
function SendScreenInfo(nScreenNo, nSendMode, nSendCmd,
  nOtherParam1: Integer): Integer; stdcall; external cDLL;
//发送相应命令到显示屏

{*************************** 以下定义用于动态区域卡 ***************************}
const
  cDLLDyn     = 'BX_Dyn.dll';

function DynAddScreen(nControlType, nScreenNo, nSendMode, nWidth, nHeight,
  nScreenType, nPixelMode: Integer;
  pCom: PChar; nBaud: Integer; pSocketIP: PChar; nSocketPort: Integer;
  pCommandDataFile: pChar): integer; stdcall; external cDLLDyn name 'AddScreen';
//向动态库中添加显示屏信息
function AddScreenDynamicArea(nScreenNo, nDYAreaID: Integer; nRunMode: Integer;
  nTimeOut, nAllProRelate: Integer; pProRelateList: PChar;
  nPlayPriority: Integer; nAreaX, nAreaY, nAreaWidth, nAreaHeight: Integer;
  nAreaFMode, nAreaFLine, nAreaFColor, nAreaFStunt, nAreaFRunSpeed,
  nAreaFMoveStep: Integer): Integer; stdcall; external cDLLDyn;
//向动态库中指定显示屏添加动态区域
function AddScreenDynamicAreaFile(nScreenNo, nDYAreaID: Integer;
  pFileName: PChar; nShowSingle: integer; pFontName: PChar;
  nFontSize, nBold, nFontColor: Integer;
  nStunt, nRunSpeed, nShowTime: Integer): Integer; stdcall; external cDLLDyn;
//向动态库中指定显示屏的指定动态区域添加信息文件
function DynDeleteScreen(nScreenNo: Integer): Integer; stdcall;
  external cDLLDyn name 'DeleteScreen';
//删除动态库中指定显示屏的所有信息
function DeleteScreenDynamicAreaFile(nScreenNo, nDYAreaID,
  nFileOrd: Integer): Integer; stdcall; external cDLLDyn;
//删除动态库中指定显示屏指定的动态区域指定文件信息
function SendDynamicAreaInfoCommand(nScreenNo,
  nDYAreaID: Integer): Integer; stdcall; external cDLLDyn;
//发送动态库中指定显示屏指定的动态区域信息到显示屏
function SendDeleteDynamicAreasCommand(nScreenNo, nDelAllDYArea: Integer;
  pDYAreaIDList: PChar): Integer; stdcall; external cDLLDyn;
//删除动态库中指定显示屏指定的动态区域信息
function SendUpdateDynamicAreaPageInfoCommand(nScreenNo, nDYAreaID, nFileOrd,
  nPageOrd: Integer): Integer; stdcall; external cDLLDyn;
//向动态库中指定显示屏指定的动态区域单独更新指定的数据页信息
function SendDeleteDynamicAreaPageCommand(nScreenNo, nDYAreaID: Integer;
  pDYAreaPageOrdList: PChar): Integer; stdcall; external cDLLDyn;
//删除动态库中指定显示屏的指定动态区域指定的数据页信息

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TCardManager, 'LED显示管理器', nEvent);
end;

constructor TCardSendThread.Create(AOwner: TCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FFileOpt := TStringList.Create;
  FFileUTF := TWideStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 5 * 1000;

  FQueueLast := 0;
  FDLLHandle := InitDLLResource(Application.Handle);
end;

destructor TCardSendThread.Destroy;
begin
  FWaiter.Free;
  FFileOpt.Free;
  FFileUTF.Free;

  FreeDLLResource;
  inherited;
end;

//Desc: 停止(外部调用)
procedure TCardSendThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

//Date: 2012-4-18
//Parm: 分组标识;标识
//Desc: 创建nGroup.nID位图文件名
function TCardSendThread.GetBMPFile(const nGroup: string; nID: Integer): string;
begin
  Result := Format('%s%s%d.bmp', [FOwner.FTempDir, nGroup, nId]);
end;

//Date: 2014-05-20
//Parm: 待翻译内容
//Desc: 返回nStr对应的UTF翻译资源
function TCardSendThread.GetUTFResource(const nStr: WideString): WideString;
var nSA: string;
    nRes,nWS: WideString;
    nIdx,nLen: Integer;
begin
  Result := FFileUTF.Values[nStr];
  if Result <> '' then Exit;

  nWS := '';
  nLen := Length(nStr);

  for nIdx:=1 to nLen do
  begin
    nSA := nStr[nIdx];
    if Windows.IsDBCSLeadByte(Byte(nSA[1])) then //双字节
    begin
      nWS := nWS + nSA; 
      if nIdx < nLen then Continue;
    end;

    if nWS = '' then
    begin
      Result := Result + nSA;
      //非汉字直接拼接
    end else
    begin
      nRes := FFileUTF.Values[nWS];
      //有对应翻译

      if nRes = '' then
           Result := Result + nWS
      else Result := Result + nRes;
      nWS := '';
    end;
  end;

  if Result <> nStr then Exit;
  //翻译成功

  Result := '';
  for nIdx:=1 to nLen do
  begin
    nRes := FFileUTF.Values[nStr[nIdx]];
    if nRes = '' then
         Result := Result + nStr[nIdx]
    else Result := Result + nRes;
  end;
end;

procedure TCardSendThread.Execute;
var nStr: string;
    nInit: Int64;
    nIdx,nNum: Integer;
begin
  FFileUTF.Clear;
  nStr := ExtractFilePath(FOwner.FFileName) + cSend_DoublePaintFile;
  
  if FileExists(nStr) then
    FFileUTF.LoadFromFile(nStr);
  //载入UTF资源配置文件

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Break;

    if FQueueLast = gTruckQueueManager.LineChanged then Continue;
    //队列没有变动
    nInit := gTruckQueueManager.LineChanged;
    //保存变动时间

    for nIdx:=0 to FOwner.FCards.Count - 1 do
      PCardItem(FOwner.FCards[nIdx]).FPicNum := 0;
    //init picture number

    for nIdx:=0 to FOwner.FCards.Count - 1 do
    begin
      gTruckQueueManager.SyncLock.Enter;
      try
        FNowItem := FOwner.FCards[nIdx];
        if not FNowItem.FEnabled then Continue;
        //ignor

        if FNowItem.FPicNum < 1 then
        begin
          DrawQueue(0);
          //draw normal picture
          nNum := FNowItem.FPicNum;

          if FNowItem.FDoublePaint and (nNum > 0) then
          try
            FNowItem.FPicNum := 0;
            DrawQueue(cSend_DoublePaintBase);
            //draw double picture
          finally
            FNowItem.FPicNum := nNum;
          end;
        end;

        if FNowItem.FFootEnable then
          BuildFootFormatText;
        //build footer text
      finally
        gTruckQueueManager.SyncLock.Leave;
      end;

      if not SendQueueData then
        WriteLog('大屏[ ' + FNowItem.FName + ' ]发送异常.');
      //loged
    end;

    FQueueLast := nInit;
    //记录变动时间
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: 构建表尾待显示内容
procedure TCardSendThread.BuildFootFormatText;
var nStr: string;
begin
  with FNowItem^ do
  begin
    if FFootDefaultOnly then
    begin
      FFootFormat := FFootDefault;
    end else
    begin
      nStr := gTruckQueueManager.GetVoiceTruck('、', False);
      if nStr = '' then
           FFootFormat := FFootDefault
      else FFootFormat := FFootText;
    end;

    FFootFormat := StringReplace(FFootFormat, 'dt', Date2Str(Now),
                   [rfReplaceAll, rfIgnoreCase]);
    //date item

    FFootFormat := StringReplace(FFootFormat, 'tm', Time2Str(Now),
                   [rfReplaceAll, rfIgnoreCase]);
    //time item

    FFootFormat := StringReplace(FFootFormat, 'tk', nStr,
                   [rfReplaceAll, rfIgnoreCase]);
    //truck item
  end;
end;

//Desc: 按当前卡配置绘制队列
procedure TCardSendThread.DrawQueue(const nFileBase: Integer);
var nStr: string;
    nWStr: WideString;
    nBmp: TBitmap;
    nCard: PCardItem;
    nLine: PLineItem;
    nTruck: PTruckItem;
    i,nI,nIdx,nCur: Integer;
    nL,nT: Integer;

    //Desc: 在当前参数的中间位置绘制nText字符
    procedure MidDrawText(const nText: string; nSAdjust,nLAdjust: Integer);
    var nML,nMT: Integer;
    begin
      with nBmp,FNowItem^ do
      begin
        with Canvas do
        begin
          if nFileBase <> cSend_DoublePaintBase then
            nSAdjust := 0;
          //双绘时调整字体

          Font.Name := FDataFont.FFontName;
          Font.Size := FDataFont.FFontSize + nSAdjust;
          Font.Color := clRed;

          if FDataFont.FFontBold then
               Font.Style := Font.Style + [fsBold]
          else Font.Style := Font.Style - [fsBold];
        end;

        if nFileBase = cSend_DoublePaintBase then
        begin
          nWStr := GetUTFResource(nText);
          nML := Canvas.TextWidth(nWStr);
          nML := nL + Trunc((FColWidth[nI] - nML) / 2) + nLAdjust;

          nMT := Canvas.TextHeight(nWStr);
          nMT := nT + Trunc((FRowHeight - nMT) / 2);

          SetBkMode(Handle, Windows.TRANSPARENT);
          TextOutW(Canvas.Handle, nML, nMT, PWideChar(nWStr), Length(nWStr));

          Inc(nT, FRowHeight);
          Exit;
        end; //双屏翻译

        nML := Canvas.TextWidth(nText);
        nML := nL + Trunc((FColWidth[nI] - nML) / 2);

        nMT := Canvas.TextHeight(nText);
        nMT := nT + Trunc((FRowHeight - nMT) / 2);

        SetBkMode(Handle, Windows.TRANSPARENT);
        Canvas.TextOut(nML, nMT, nText);
        Inc(nT, FRowHeight);
      end;
    end;

    //Date: 2018-10-09
    //Parm: 待显示内容;第几列;若超长截取尾部
    //Desc: 在当前列的中间位置绘制nText字符
    procedure MidDrawText2(nText: WideString; const nCol: Integer;
      const nCutEnd: Boolean = True);
    var j,nML,nMT: Integer;
    begin
      with nBmp,FNowItem^ do
      begin
        j := Length(FColWidth);
        if j<= nCol then
        begin
          nStr := '无法在[ %d ]列表格显示[ %d ]列数据.';
          WriteLog(Format(nStr, [j, nCol]));
          Exit;
        end;

        with Canvas do
        begin
          Font.Name := FDataFont.FFontName;
          Font.Size := FDataFont.FFontSize;
          Font.Color := clRed;

          if FDataFont.FFontBold then
               Font.Style := Font.Style + [fsBold]
          else Font.Style := Font.Style - [fsBold];
        end;

        nL := 1;
        for j:=0 to nCol-1 do
          nL := nL + FColWidth[j];
        //累加左边界

        nML := Canvas.TextWidth(nText);
        while nML > FColWidth[nCol] do //超长则截取
        begin
          if nCutEnd then
               nText := Copy(nText, 1, Length(nText) - 1)
          else nText := Copy(nText, 2, Length(nText) - 1);

          nML := Canvas.TextWidth(nText);
        end;

        nML := nL + Trunc((FColWidth[nCol] - nML) / 2); 
        nMT := Canvas.TextHeight(nText);
        nMT := nT + Trunc((FRowHeight - nMT) / 2);

        SetBkMode(Handle, Windows.TRANSPARENT);
        Canvas.TextOut(nML, nMT, nText);
      end;
    end;
begin
  nBmp := nil;
  {$IFDEF DEBUG}
  WriteLog('开始绘制:' + FNowItem.FName);
  {$ENDIF}

  if not FNowItem.FDataEnable then
    Exit;
  //不使用数据区

  with FNowItem^, gTruckQueueManager do
  try
    nCur := 0;
    nIdx := 0;

    while nIdx < Lines.Count do
    begin
      nLine := Lines[nIdx];

      if (not nLine.FIsValid) or ((Length(FDataTunnels) > 0) and
         (Pos(nLine.FLineID, FDataTunnels) < 1)) then
      begin
        if (Length(FDataTunnelsEx) > 0) and (Pos(FDataTunnelsEx, nLine.FLineID) > 0) then
        begin
          //
        end
        else
        begin
          Inc(nIdx); Continue;
        end;
      end;

      if not Assigned(nBmp) then
      begin
        Inc(FPicNum);
        nBmp := TBitmap.Create;

        with nBmp do
        begin
          PixelFormat := pf1bit;
          Width := FDataRect.Right - FDataRect.Left;
          Height := FDataRect.Bottom - FDataRect.Top;

          Canvas.Brush.Color := clBlack;
          Canvas.FillRect(Rect(0, 0, Width, Height));

          Canvas.Pen.Color := clRed;
          Canvas.Pen.Width := 1;
          Canvas.Rectangle(Rect(1, 1, Width-1, Height-1));

          Canvas.Pen.Color := clRed;
          Canvas.Pen.Width := 1;

          Canvas.Lock;
          //锁定,开始绘制
          nL := 1;
          
          for i:=Low(FColWidth) to High(FColWidth)-1 do
          begin
            Inc(nL, FColWidth[i]);
            Canvas.MoveTo(nL, 1);
            Canvas.LineTo(nL, Height-1);
          end; //竖线

          nT := 1;
          for i:=1 to FRowNum-1 do
          begin
            Inc(nT, FRowHeight);
            Canvas.MoveTo(1, nT);
            Canvas.LineTo(Width-1, nT);
          end; //横线

          nL := 1;
          nT := 1;
          nI := Low(FColWidth);
          //每屏起始位置

          if FDrawStyle = dsRowDisp then
            nI := 0;
          //行显时,nI为已绘制的行数
        end; 
      end;

      //------------------------------------------------------------------------
      with nBmp do
      if FDrawStyle = dsColDisp then //列显示模式: 绘制队列
      begin
        nLine := Lines[nIdx];
        MidDrawText(nLine.FName, FFontHeadSAdjust, FFontHeadLAdjust);

        if FStatusEnable then
        begin
          if nLine.FIsValid then
               nStr := '启用'
          else nStr := '停用';
          MidDrawText(nStr, FFontHeadSAdjust, FFontHeadLAdjust);
        end;

        if nLine.FTrucks.Count < 1 then
          Inc(nIdx);
        //no truck,next line

        for i:=nCur to nLine.FTrucks.Count-1 do
        begin
          if (FStatusEnable and (i-nCur >= FRowNum-2)) or
             ((not FStatusEnable) and (i-nCur >= FRowNum-1)) then
          begin
            nCur := i;
            Break;
          end;
          //row is enough to fill truck

          nTruck := nLine.FTrucks[i];
          MidDrawText(nTruck.FTruck, 0, FFontDataLAdjust);

          if (i = nLine.FTrucks.Count - 1) or
             ((FDataItemNum > 0) and (FDataItemNum <= i+1)) then
          begin
            Inc(nIdx);
            nCur := 0;
            Break;
          end; //next line
        end;

        Inc(nL, FColWidth[nI]);
        nT := 1;
        Inc(nI);

        if nI >= Length(FColWidth) then
        begin
          nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
          if FileExists(nStr) then
            DeleteFile(nStr);
          Sleep(500); //wait io

          SaveToFile(nStr);
          Canvas.Unlock;
          //绘制完毕,解锁
          
          Sleep(500); //wait io
          FreeAndNil(nBmp);
        end;
      end;

      //------------------------------------------------------------------------
      with nBmp do
      if FDrawStyle = dsRowDisp then //行显示模式: 绘制细节
      begin
        if nLine.FTrucks.Count < 1 then
          Inc(nIdx);
        //no truck,next line

        for i:=nCur to nLine.FTrucks.Count-1 do
        begin
          if i-nCur >= FRowNum then
          begin
            nCur := i;
            Break;
          end;
          //row isn't enough to fill truck

          if nI >= FRowNum then
            Break;
          //page is full

          nTruck := nLine.FTrucks[i];
          MidDrawText2(nTruck.FTruck, 0);
          MidDrawText2(nTruck.FStockName, 1, False);
          MidDrawText2(nTruck.FCusName, 2);

          Inc(nI); //row counter
          nT := nT + FRowHeight;

          if (i = nLine.FTrucks.Count - 1) or
             ((FDataItemNum > 0) and (FDataItemNum <= i+1)) then
          begin
            Inc(nIdx);
            nCur := 0;
            Break;
          end; //next line
        end;

        if nI >= FRowNum then
        begin
          nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
          if FileExists(nStr) then
            DeleteFile(nStr);
          Sleep(500); //wait io

          SaveToFile(nStr);
          Canvas.Unlock;
          //绘制完毕,解锁

          Sleep(500); //wait io
          FreeAndNil(nBmp);
        end;
      end;
    end; 

    //------------------------------------------------------------------------
    if Assigned(nBmp) then
    begin
      nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
      if FileExists(nStr) then
        DeleteFile(nStr);
      Sleep(500); //wait io

      nBmp.SaveToFile(nStr);
      nBmp.Canvas.Unlock;
      Sleep(500); //wait io
    end;

    for nIdx:=0 to FOwner.Cards.Count - 1 do
    begin
      nCard := FOwner.FCards[nIdx];
      if (nCard <> FNowItem) and (nCard.FGroup = FNowItem.FGroup) then
        nCard.FPicNum := FNowItem.FPicNum;
      //共享已绘制图片
    end;
  finally
    nBmp.Free;
  end;
end;

//Desc: 发送绘制好的队列
function TCardSendThread.SendQueueData: Boolean;
var nStr: string;
    nRes,nIdx,nArea: Integer;
begin
  Result := False;
  //default is failure

  with FNowItem^,FOwner do
  try
    case FType of
     CONTROLLER_BX_5E1, CONTROLLER_BX_5E2, CONTROLLER_BX_5E3:
      begin
        Result := SendDynamicData;
        Exit;
      end;
    end;

    try
      nRes := DeleteScreen(1);
      if (nRes<>RETURN_NOERROR) and (nRes<>RETURN_ERROR_NOFIND_SCREENNO) then
      begin
        WriteLog(Format('DeleteScreen:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    except
      //ignor any error
    end;

    nRes := AddScreen(FType, 1, FWidth, FHeight, 1, 2, 0, FDataOE, 0, 0,
            'COM1', 9600, PChar(FIP), FPort, nil);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreen:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nRes := AddScreenProgram(1, 0, 0, 65535, 11, 26, 2011, 11, 26, 1, 1, 1,
            1, 1, 1, 1, 0, 0, 23, 59);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreenProgram:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nArea := 0;
    //first area

    //--------------------------------------------------------------------------
    if FHeadEnable then
    begin
      with FHeadRect do
       nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                                           Right-Left, Bottom-Top);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nStr := FTempDir + cSend_HeadFileRTF;
      //default head file
    
      if (not FDoublePaint) or (not FileExists(nStr)) then
      begin
        nStr := FTempDir + cSend_HeadFile;
        //normal txt file
      
        if not FileExists(nStr) then
        begin
          FFileOpt.Text := FHeadText;
          FFileOpt.SaveToFile(nStr);
          Sleep(1000); //wait I/O
        end;
      end; 

      with FHeadFont do
      begin
        if FFontBold then
             nIdx := 1
        else nIdx := 0;

        nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                PChar(nStr), 1,
                PChar(FFontName), FFontSize, nIdx, 1, FEffect, FSpeed, FKeep);
        //xxxxx
      end;

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    if FDataEnable and (FPicNum > 0) then
    begin
      with FDataRect do
        nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                Right-Left, Bottom-Top);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end else Inc(nArea);

      for nIdx:=1 to FPicNum do
      begin
        with FDataFont do
        begin
          nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                  PChar(GetBMPFile(FGroup, nIdx)), 0,
                  PChar(FFontName), FFontSize, 0, 1, FEffect, FSpeed, FKeep);
        end;

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;

        if not FDoublePaint then continue;
        //no double paint picture

        nStr := GetBMPFile(FGroup, nIdx + cSend_DoublePaintBase);
        if not FileExists(nStr) then continue;

        with FDataFont do
        begin
          nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                  PChar(nStr), 0,
                  PChar(FFontName), FFontSize, 0, 1, FEffect, FSpeed, FKeep);
        end;

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;
      end;
    end;

    //--------------------------------------------------------------------------
    if FFootEnable then
    begin
      with FFootRect do
        nRes := AddScreenProgramBmpTextArea(1, 0, Left, Top,
                Right-Left, Bottom-Top);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramBmpTextArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end else Inc(nArea);

      FFileOpt.Text := FFootFormat;
      FFileOpt.SaveToFile(FTempDir + cSend_FootFile);
      Sleep(1000); //wait I/O

      with FFootFont do
      begin
        if FFontBold then
             nIdx := 1
        else nIdx := 0;

        nRes := AddScreenProgramAreaBmpTextFile(1, 0, nArea,
                PChar(FTempDir + cSend_FootFile), 1,
                PChar(FFontName), FFontSize, nIdx, 1, FEffect, FSpeed, FKeep);
      end;

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenProgramAreaBmpTextFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    nRes := SendScreenInfo(1, SEND_MODE_NETWORK, SEND_CMD_SENDALLPROGRAM, 0);
    Result := nRes = RETURN_NOERROR;

    if not Result then
      WriteLog(Format('SendScreenInfo:%s', [GetErrorDesc(nRes)]));
    //xxxxx

    {$IFDEF DEBUG}
    WriteLog('屏幕:' + FNowItem.FName + '数据发送完毕.');
    {$ENDIF}                                          
  except
    On E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//Desc: 向动态区域控制卡发送数据
function TCardSendThread.SendDynamicData: Boolean;
var nStr: string;
    nRes,nIdx,nArea,nTag: Integer;
begin
  Result := False;
  //default is failure

  with FNowItem^,FOwner do
  try
    try
      nRes := DynDeleteScreen(1);
      if (nRes<>RETURN_NOERROR) and (nRes<>RETURN_ERROR_NOFIND_SCREENNO) then
      begin
        WriteLog(Format('DeleteScreen:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    except
      //ignor any error
    end;

    nRes := DynAddScreen(FType, 1, SEND_MODE_NETWORK, FWidth, FHeight, 1, 2, 
            'COM1', 9600, PChar(FIP), FPort, nil);
    if nRes <> RETURN_NOERROR then
    begin
      WriteLog(Format('AddScreen:%s', [GetErrorDesc(nRes)]));
      Exit;
    end;

    nArea := 0;
    //first area

    //--------------------------------------------------------------------------
    if FHeadEnable then
    with FHeadRect,FHeadFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nStr := FTempDir + cSend_HeadFileRTF;
      //default head file

      if (not FDoublePaint) or (not FileExists(nStr)) then
      begin
        nStr := FTempDir + cSend_HeadFile;
        //normal txt file

        if not FileExists(nStr) then
        begin
          FFileOpt.Text := FHeadText;
          FFileOpt.SaveToFile(nStr);
          Sleep(1000); //wait I/O
        end;
      end;

      if FFontBold then
           nTag := 1
      else nTag := 0;

      nRes := AddScreenDynamicAreaFile(1, nArea, PChar(nStr),
              1, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      Inc(nArea);
      //next area
    end;

    //--------------------------------------------------------------------------
    if FDataEnable and (FPicNum > 0) then
    with FDataRect,FDataFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      if FFontBold then
           nTag := 1
      else nTag := 0;

      for nIdx:=1 to FPicNum do
      begin
        nRes := AddScreenDynamicAreaFile(1, nArea, PChar(GetBMPFile(FGroup, nIdx)),
                0, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
        //xxxxx

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;

        if not FDoublePaint then continue;
        //no double paint picture

        nStr := GetBMPFile(FGroup, nIdx + cSend_DoublePaintBase);
        if not FileExists(nStr) then continue;

        nRes := AddScreenDynamicAreaFile(1, nArea, PChar(nStr),
                0, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
        //xxxxx

        if nRes <> RETURN_NOERROR then
        begin
          WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
          Exit;
        end;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      Inc(nArea);
      //next area
    end;

    //--------------------------------------------------------------------------
    if FFootEnable then
    with FFootRect, FFootFont do
    begin
      nRes := AddScreenDynamicArea(1, nArea, RUN_MODE_CYCLE_SHOW, 3600*24, 0, nil,
              0, Left, Top, Right-Left, Bottom-Top, 255, 0, 255, 1, 0, 1);
      //xxxxx
      
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicArea:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      FFileOpt.Text := FFootFormat;
      FFileOpt.SaveToFile(FTempDir + cSend_FootFile);
      Sleep(1000); //wait I/O

      if FFontBold then
           nTag := 1
      else nTag := 0;

      nRes := AddScreenDynamicAreaFile(1, nArea, PChar(FTempDir+cSend_FootFile),
              1, PChar(FFontName), FFontSize, nTag, clRed, FEffect, FSpeed, FKeep);
      //xxxxx

      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('AddScreenDynamicAreaFile:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;

      nRes := SendDynamicAreaInfoCommand(1, nArea);
      if nRes <> RETURN_NOERROR then
      begin
        WriteLog(Format('SendDynamicAreaInfoCommand:%s', [GetErrorDesc(nRes)]));
        Exit;
      end;
    end;

    {$IFDEF DEBUG}
    WriteLog('屏幕:' + FNowItem.FName + '数据发送完毕.');
    {$ENDIF}
    Result := True;                                          
  except
    On E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TCardManager.Create;
begin
  FFileName := '';
  FCards := TList.Create;
end;

destructor TCardManager.Destroy;
begin
  StopSender;
  ClearList(True);
  inherited;
end;

procedure TCardManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FCards.Count - 1 downto 0 do
  begin
    Dispose(PCardItem(FCards[nIdx]));
    FCards.Delete(nIdx);
  end;

  if nFree then FreeAndNil(FCards);
end;

procedure TCardManager.StartSender;
begin
  if not Assigned(FSender) then
    FSender := TCardSendThread.Create(Self);
  FSender.FWaiter.Wakeup;
end;

procedure TCardManager.StopSender;
begin
  if Assigned(FSender) then
    FSender.StopMe;
  FSender := nil;
end;

//------------------------------------------------------------------------------
function TCardManager.GetErrorDesc(const nErr: Integer): string;
begin
  Result := Format('未定义的错误(Code: %d).', [nErr]);

  case nErr of
   RETURN_ERROR_NO_USB_DISK:
    Result := '找不到usb设备路径';
   RETURN_ERROR_NOSUPPORT_USB:
    Result := '不支持USB模式';
   RETURN_ERROR_AERETYPE:
    Result := '区域类型错误,在添加、删除图文区域文件时区域类型出错返回此类型错误.';
   RETURN_ERROR_RA_SCREENNO:
    Result := '已经有该显示屏信息,如要重新设定请先DeleteScreen删除该显示屏再添加.';
   RETURN_ERROR_NOFIND_AREAFILE:
    Result := '没有找到有效的区域文件';
   RETURN_ERROR_NOFIND_AREA:
    Result := '没有找到有效的显示区域,可以使用AddScreenProgram添加区域信息.';
   RETURN_ERROR_NOFIND_PROGRAM:
    Result := '没有找到有效的显示屏节目.可以使用AddScreenProgram函数添加指定节目.';
   RETURN_ERROR_NOFIND_SCREENNO:
    Result := '系统内没有查找到该显示屏,可以使用AddScreen函数添加显示屏.';
   RETURN_ERROR_NOW_SENDING:
    Result := '系统内正在向该显示屏通讯,请稍后再通讯.';
   RETURN_ERROR_OTHER:
    Result := '其它错误.';
   RETURN_NOERROR:
    Result := '操作成功';

   //dynamic area card
   RETURN_ERROR_NOFIND_DYNAMIC_AREA:
    Result := '没有找到有效的动态区域';
   RETURN_ERROR_NOFIND_DYNAMIC_AREA_FILE_ORD:
    Result := '在指定的动态区域没有找到指定的文件序号';
   RETURN_ERROR_NOFIND_DYNAMIC_AREA_PAGE_ORD:
    Result := '在指定的动态区域没有找到指定的页序号';
   RETURN_ERROR_NOSUPPORT_FILETYPE: Result := '不支持该文件类型';
  end;
end;

//Desc: 读取nNode的字体配置
procedure ReadCardFont(var nFont: TCardFont; const nNode: TXmlNode);
begin
  with nFont do
  begin
    FFontName := nNode.NodeByName('fontname').ValueAsString;
    FFontSize := nNode.NodeByName('fontsize').ValueAsInteger;
    FFontBold := nNode.NodeByName('fontbold').ValueAsInteger > 0;

    FSpeed := nNode.NodeByName('fontspeed').ValueAsInteger;
    FKeep := nNode.NodeByName('fontkeep').ValueAsInteger;
    FEffect := nNode.NodeByName('fonteffect').ValueAsInteger;
  end;
end;

//Desc: 读取nFile
procedure TCardManager.SetFileName(const nFile: string);
var nStr: string;
    i,nIdx: Integer;
    nItem: TCardItem;
    nCard: PCardItem;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  FFileName := nFile;
  nXML := TNativeXml.Create;
  try
    ClearList(False);
    nXML.LoadFromFile(nFile);
    
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    with nItem do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      FID := nNode.AttributeByName['ID'];
      FName := nNode.AttributeByName['Name'];
      FGroup := nNode.AttributeByName['Group'];

      nNode := nXML.Root.Nodes[nIdx].FindNode('param');
      if not Assigned(nNode) then Continue;

      FType := CONTROLLER_TYPE_4M;
      nStr := nNode.NodeByName('type').ValueAsString;

      if CompareText('4m1', nStr) = 0 then
           FType := CONTROLLER_TYPE_4M1 else
      if CompareText('5m1', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M1 else
      if CompareText('5m2', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M2 else
      if CompareText('5m3', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M3 else
      if CompareText('5m4', nStr) = 0 then
           FType := CONTROLLER_TYPE_5M4 else
      if CompareText('5e1', nStr) = 0 then
           FType := CONTROLLER_BX_5E1 else
      if CompareText('5e2', nStr) = 0 then
           FType := CONTROLLER_BX_5E2 else
      if CompareText('5e3', nStr) = 0 then
           FType := CONTROLLER_BX_5E3;
      //for card type

      FIP := nNode.NodeByName('ip').ValueAsString;
      FPort := nNode.NodeByName('port').ValueAsInteger;
      FWidth := nNode.NodeByName('width').ValueAsInteger;
      FHeight := nNode.NodeByName('height').ValueAsInteger;
      FDataOE := nNode.NodeByName('data_oe').ValueAsInteger;

      nTmp := nNode.FindNode('data_tunnels');
      if Assigned(nTmp) then
           FDataTunnels := nTmp.ValueAsString
      else FDataTunnels := '';

      nTmp := nNode.FindNode('data_tunnelsEx');
      if Assigned(nTmp) then
           FDataTunnelsEx := nTmp.ValueAsString
      else FDataTunnelsEx := '';

      nTmp := nNode.FindNode('double_paint');
      if Assigned(nTmp) then
           FDoublePaint := nTmp.ValueAsString = '1'
      else FDoublePaint := False;

      nTmp := nNode.FindNode('enable');
      if Assigned(nTmp) then
           FEnabled := nTmp.ValueAsString <> 'N'
      else FEnabled := True;

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('head_area');
      if not Assigned(nNode) then Continue;
      FHeadEnable := nNode.AttributeByName['use_head'] <> 'N';

      with FHeadRect,nNode.NodeByName('rect') do
      begin
        Left := StrToInt(AttributeByName['L']);
        Top := StrToInt(AttributeByName['T']);
        Right := Left + StrToInt(AttributeByName['W']);
        Bottom := Top + StrToInt(AttributeByName['H']);
      end;

      FHeadText := nNode.NodeByName('text').ValueAsString;
      ReadCardFont(FHeadFont, nNode);

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('data_area');
      if not Assigned(nNode) then Continue;
      FDataEnable := nNode.AttributeByName['use_data'] <> 'N';
      FStatusEnable := nNode.AttributeByName['use_status'] <> 'N';

      nStr := nNode.AttributeByName['drawstyle'];
      if CompareText(nStr, 'detail') = 0 then
           FDrawStyle := dsRowDisp
      else FDrawStyle := dsColDisp;

      FRowNum := nNode.NodeByName('rownum').ValueAsInteger;
      FRowHeight := nNode.NodeByName('rowheight').ValueAsInteger;

      with nNode.FindNode('colwidth') do
      begin
        SetLength(FColWidth, NodeCount);
        for i:=0 to NodeCount - 1 do
          FColWidth[i] := Nodes[i].ValueAsInteger;
        //width value
      end;

      with FDataRect,nNode.NodeByName('rect') do
      begin
        Left := StrToInt(AttributeByName['L']);
        Top := StrToInt(AttributeByName['T']);
        Right := Left + StrToInt(AttributeByName['W']);
        Bottom := Top + StrToInt(AttributeByName['H']);
      end;

      ReadCardFont(FDataFont, nNode);
      //font node

      nTmp := nNode.FindNode('itemnum');
      if Assigned(nTmp) then
           FDataItemNum := nTmp.ValueAsInteger
      else FDataItemNum := 0;

      nTmp := nNode.FindNode('font_head_size_adjust');
      if Assigned(nTmp) then
           FFontHeadSAdjust := nTmp.ValueAsInteger
      else FFontHeadSAdjust := 0;

      nTmp := nNode.FindNode('font_head_left_adjust');
      if Assigned(nTmp) then
           FFontHeadLAdjust := nTmp.ValueAsInteger
      else FFontHeadLAdjust := 0;

      nTmp := nNode.FindNode('font_data_left_adjust');
      if Assigned(nTmp) then
           FFontDataLAdjust := nTmp.ValueAsInteger
      else FFontDataLAdjust := 0;

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('foot_area');
      FFootEnable := Assigned(nNode);

      if FFootEnable then
      begin
        FFootEnable := nNode.AttributeByName['use_foot'] <> 'N';
        //xxxxx

        with FFootRect,nNode.NodeByName('rect') do
        begin
          Left := StrToInt(AttributeByName['L']);
          Top := StrToInt(AttributeByName['T']);
          Right := Left + StrToInt(AttributeByName['W']);
          Bottom := Top + StrToInt(AttributeByName['H']);
        end;

        nTmp := nNode.NodeByName('default');
        FFootDefault := nTmp.ValueAsString;
        FFootDefaultOnly := nTmp.AttributeByName['useonly'] = 'Y'; 

        FFootText := nNode.NodeByName('text').ValueAsString;
        ReadCardFont(FFootFont, nNode);
      end;

      New(nCard);
      FCards.Add(nCard);
      nCard^ := nItem;
    end;
  finally
    nXML.Free;
  end;
end;

initialization
  gCardManager := TCardManager.Create;
finalization
  FreeAndNil(gCardManager);
end.


