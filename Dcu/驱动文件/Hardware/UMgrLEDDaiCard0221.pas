{*******************************************************************************
  作者: dmzn@ylsoft.com 2011-03-13
  描述: LED袋装控制卡管理
*******************************************************************************}
unit UMgrLEDDaiCard;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, Forms, Graphics, NativeXml, UWaitItem, ULibFun,
  USysLoger, JclUnicode,UMgrDBConn,UMgrParam;

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

  PCardItemEx = ^TCardItemEx;
  TCardItemEx = record
    FZID: string;
    FZName: string;
    FDataType:string;       //数据类型
    FStockNo1:string;
    FStockName1:string;
    FStockNo2:string;
    FStockName2:string;
    FMemo:string;
  end;

  PCardEx = ^TCardEx;
  TCardEx = record
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
    FRowNum: Integer;       //行数
    FRowHeight:Integer;     //行高
    FColNum: Integer;       //列数
    FColWidth: array of Integer;
    FList: TList;
    FDataFont: TCardFont;
    FPicNum:Integer;
  end;

  TDaiCardManager = class;
  TCardSendThread = class(TThread)
  private
    FOwner: TDaiCardManager;
    //拥有者
    FFileOpt: TStrings;
    FFileUTF: TWideStringList;
    //文件对象
    FWaiter: TWaitObject;
    //等待对象
    FNowItem: PCardEx;
    //当前对象
    FDLLHandle: THandle;
    //驱动库
    FNumSaleInfo: Integer;
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
  protected
    procedure Execute; override;
    //执行线程
    procedure DrawQueue(const nFileBase: Integer);
    //绘制队列
    procedure GetLineInfo;

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
    constructor Create(AOwner: TDaiCardManager);
    destructor Destroy; override;
    //创建释放
    procedure StopMe;
    //停止线程
  end;

  TDaiCardManager = class(TObject)
  private
    FLines: TList;
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
    property Lines: TList read FLines;
    property TempDir: string read FTempDir write FTempDir;
    property FileName: string read FFileName write SetFileName;
    //属性相关
  end;

var
  gDaiCardManager: TDaiCardManager = nil;
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
  gSysLoger.AddLog(TDaiCardManager, 'LED显示管理器', nEvent);
end;

constructor TCardSendThread.Create(AOwner: TDaiCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FOwner := AOwner;

  FFileOpt := TStringList.Create;
  FFileUTF := TWideStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 30 * 1000;

  FDLLHandle := InitDLLResource(Application.Handle);

  FSyncLock := TCrossProcWaitObject.Create('');
  //process sync
end;

destructor TCardSendThread.Destroy;
begin
  FWaiter.Free;
  FFileOpt.Free;
  FFileUTF.Free;

  FreeDLLResource;

  FSyncLock.Free;
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
  
  FNumSaleInfo   := 0;
  
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Break;

    Inc(FNumSaleInfo);

    if FNumSaleInfo >= 4 then
      FNumSaleInfo := 0;

    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    for nIdx:=0 to FOwner.FLines.Count - 1 do
      PCardEx(FOwner.FLines[nIdx]).FPicNum := 0;
    //init picture number
    
    try
      if  FNumSaleInfo = 1 then
      begin
        for nIdx:=0 to FOwner.FLines.Count - 1 do
        begin
          FNowItem := FOwner.FLines[nIdx];
          if not FNowItem.FEnabled then Continue;
          //ignor
          if FNowItem.FPicNum < 1 then
          begin
            GetLineInfo;

            DrawQueue(0);
//            draw normal picture
//            nNum := FNowItem.FPicNum;
//
//            if FNowItem.FDoublePaint and (nNum > 0) then
//            try
//              FNowItem.FPicNum := 0;
//              DrawQueue(cSend_DoublePaintBase);
//              draw double picture
//            finally
//              FNowItem.FPicNum := nNum;
//            end;
          end;

//          if not SendQueueData then
//            WriteLog('大屏[ ' + FNowItem.FName + ' ]发送异常.');
          //loged
        end;
      end;
    finally
      FSyncLock.SyncLockLeave();
    end;
  except
    on E: Exception do
    begin
      WriteLog('异常内容:'+E.Message);
    end;
  end;
end;

//Desc: 构建表尾待显示内容
procedure TCardSendThread.BuildFootFormatText;
begin

end;

//Desc: 按当前卡配置绘制队列
procedure TCardSendThread.DrawQueue(const nFileBase: Integer);
var
  nBMap: TBitmap;
  FDataRect: TRect;
  nL,nT,i,k,nIk:Integer;
  nI,nIdx,nCur: Integer;
  nlineEx:PCardItemEx;
  nStr: string;
  procedure MidDrawText2(nText: WideString; const nCol: Integer;
    const nCutEnd: Boolean = True);
  var j,nML,nMT: Integer;
  begin
    with nBMap, FNowItem^ do
    begin
      j := Length(FColWidth);
      if j<= nCol then
      begin
        Exit;
      end;

      with Canvas do
      begin
        Font.Name := '宋体';
        Font.Size := 18;
        Font.Color := clRed;
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
      Inc(nT, FRowHeight);
    end;
  end;
begin
  nBMap := nil;
//  {$IFDEF DEBUG}
  WriteLog('开始绘制:' + FNowItem.FName);
//  {$ENDIF}

  if not Assigned(nBMap) then
  begin
    nBMap := TBitmap.Create;
  end;
  try
      with nBMap, FNowItem^ do
      begin
        with FDataRect do
        begin
          Left   := 0;
          Top    := 0;
          Right  := Left + FWidth;
          Bottom := Top + FHeight;
        end;

        Width  := FDataRect.Right - FDataRect.Left;
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
        nCur := 0;

        for k := 0 to FList.count-1 do
        begin
          nI := 0;
          nT := 1;
          nlineEx := FList[k];
          for i:= nCur to 3  do
          begin
            if i-nCur >= FRowNum then
            begin
              nCur := i;
              Break;
            end;

            if nI >= FRowNum then
              Break;
            if i=0 then
              MidDrawText2(PCardItemEx(FList[k]).FZName, k)
            else if i=1 then
              MidDrawText2(PCardItemEx(FList[k]).FStockName1,k)
            else if i=2 then
              MidDrawText2(PCardItemEx(FList[k]).FMemo, k)
            else if i=3 then
              MidDrawText2(PCardItemEx(FList[k]).FStockName2, k);

            Inc(nI); //row counter
          end;
        end;

        if Assigned(nBMap) then
        begin
          nStr := GetBMPFile(FGroup, FPicNum + nFileBase);
          if FileExists(nStr) then
            DeleteFile(nStr);
          Sleep(500); //wait io
          nBMap.SaveToFile(nStr);
          nBMap.Canvas.Unlock;
          Sleep(500); //wait io
        end;

//        for nIdx:=0 to FOwner.FLines.Count - 1 do
//        begin
//          nLine := FOwner.FLines[nIdx];
//          if (nLine <> FNowItem) and (nLine.FGroup = FNowItem.FGroup) then
//            nLine.FPicNum := FNowItem.FPicNum;
//          //共享已绘制图片
//        end;
      end;
  finally
    nBMap.Free;
  end;
end;

//Desc: 发送绘制好的队列
function TCardSendThread.SendQueueData: Boolean;
var nStr: string;
    nRes,nIdx,nArea: Integer;
    FDataRect: TRect;
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
    FDataRect: TRect;
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
constructor TDaiCardManager.Create;
begin
  FFileName := '';
  FLines := TList.Create;
end;

destructor TDaiCardManager.Destroy;
begin
  StopSender;
  ClearList(True);
  inherited;
end;

procedure TDaiCardManager.ClearList(const nFree: Boolean);
var nIdx: Integer;
begin
  for nIdx:=FLines.Count - 1 downto 0 do
  begin
    Dispose(PCardEx(FLines[nIdx]));
    FLines.Delete(nIdx);
  end;

  if nFree then FreeAndNil(FLines);
end;

procedure TDaiCardManager.StartSender;
begin
  if not Assigned(FSender) then
    FSender := TCardSendThread.Create(Self);
  FSender.FWaiter.Wakeup;
end;

procedure TDaiCardManager.StopSender;
begin
  if Assigned(FSender) then
    FSender.StopMe;
  FSender := nil;
end;

//------------------------------------------------------------------------------
function TDaiCardManager.GetErrorDesc(const nErr: Integer): string;
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
procedure TDaiCardManager.SetFileName(const nFile: string);
var nStr: string;
    i,nIdx,k: Integer;
    nItem: TCardEx;
    nCard: PCardEx;
    nItemDt: TCardItemEx;
    nCardDt: PCardItemEx;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  FFileName := nFile;
  FLines := TList.Create;
  nXML := TNativeXml.Create;
  try
    ClearList(False);
    nXML.LoadFromFile(nFile);
    
    for nIdx:=0 to nXML.Root.NodeCount - 1 do
    with nItem do
    begin
      FList := TList.Create;
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
      
      nTmp := nNode.FindNode('double_paint');
      if Assigned(nTmp) then
           FDoublePaint := nTmp.ValueAsString = '1'
      else FDoublePaint := False;

      nTmp := nNode.FindNode('enable');
      if Assigned(nTmp) then
           FEnabled := nTmp.ValueAsString <> 'N'
      else FEnabled := True;

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('data_area');
      if not Assigned(nNode) then Continue;

      FRowNum := nNode.NodeByName('rownum').ValueAsInteger;
      FRowHeight := nNode.NodeByName('rowheight').ValueAsInteger;
      FColNum := nNode.NodeByName('colnum').ValueAsInteger;

      with nNode.FindNode('colwidth') do
      begin
        SetLength(FColWidth, NodeCount);
        for i:=0 to NodeCount - 1 do
          FColWidth[i] := Nodes[i].ValueAsInteger;
        //width value
      end;
      ReadCardFont(FDataFont, nNode);

      //------------------------------------------------------------------------
      nNode := nXML.Root.Nodes[nIdx].FindNode('datalist');
      if not Assigned(nNode) then Continue;

      for k := 0 to nNode.NodeCount - 1 do
      with nItemDt do
      begin
        FDataType := nNode[k].NodeByName('datatype').ValueAsString;
         FZID      := nNode[k].NodeByName('tunnel').ValueAsString;

        New(nCardDt);
        FList.Add(nCardDt);
        nCardDt^ := nItemDt;
      end;

      New(nCard);
      FLines.Add(nCard);
      nCard^ := nItem;
    end;
  finally
    nXML.Free;
  end;
end;

procedure TCardSendThread.GetLineInfo;
var
  nIdx,k: Integer;
  nlineEx:PCardItemEx;
  nStr : string;
  nDBConn : PDBWorker;
begin
  try
    nDBConn := gDBConnManager.GetConnection(gParamManager.ActiveParam^.FDB.FID, nIdx);
    if not Assigned(nDBConn) then Exit;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;

    with FNowItem^ do
    begin
      Inc(FPicNum);
      for nIdx := 0 to FList.Count - 1 do
      begin
        nlineEx := FList[nIdx];

        with nlineEx^ do
        begin
          //通过数据库获取最新数据
          nStr := ' Select S_Line,S_StockNo,S_StockName,S_NextStockNo,S_NextStockName,'+
                  ' (select Z_Name from S_ZTLines where Z_ID=a.S_Line) as Z_Name From S_DaiTimeSet  a' +
                  ' Where S_Line = ''%s''  And (select CONVERT(varchar(12) , getdate(), 108))>=S_BeginDate '+
                  ' And (select CONVERT(varchar(12) , getdate(), 108)) < S_EndDate ';
          nStr := Format(nStr,[FZID]);
//          WriteLog(nStr);
          with gDBConnManager.WorkerQuery(nDBConn, nStr) do
          begin
            if recordcount>0 then
            begin
              FZName      := Fieldbyname('Z_Name').asstring;
              FStockNo1   := Fieldbyname('S_StockNo').asstring;
              FStockName1 := Fieldbyname('S_StockName').asstring;
              FStockNo2   := Fieldbyname('S_NextStockNo').asstring;
              FStockName2 := Fieldbyname('S_NextStockName').asstring;
            end;
          end;
          
          //通过数据库获取最新数据
          nStr := ' Select SUM(L_Value) as L_Value from S_Bill where L_OutFact is null and L_StockNo in '+
                  ' (select D_ParamB from Sys_Dict where  D_Name = ''StockItem'' and D_Memo=''D'' and D_ParamA in '+
                  ' (select D_ParamA from Sys_Dict where  D_Name = ''StockItem'' and D_Memo=''D'' and D_ParamB = ''%s''))';
          nStr := Format(nStr,[FStockNo1]);
//          WriteLog(nStr);
          with gDBConnManager.WorkerQuery(nDBConn, nStr) do
          begin
            if recordcount>0 then
            begin
              if FDataType = '1' then
                FMemo := '剩余量：'
              else
              if FDataType = '2' then
                FMemo := Fieldbyname('L_Value').asstring;
            end;
          end;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

initialization
  gDaiCardManager := TDaiCardManager.Create;
finalization
  FreeAndNil(gDaiCardManager);
end.


