{*******************************************************************************
  ����: dmzn@163.com 2012-5-3
  ����: �û�������ѯ
*******************************************************************************}
unit UFormMain;
{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, ExtCtrls, CPort, StdCtrls, Buttons,
  UHotKeyManager, jpeg;

type
  TCardType = (ctTTCE,ctRFID);

  TfFormMain = class(TForm)
    LabelStock: TcxLabel;
    LabelNum: TcxLabel;
    LabelHint: TcxLabel;
    ComPort1: TComPort;
    TimerReadCard: TTimer;
    Panel1: TPanel;
    LabelTruck: TcxLabel;
    LabelDec: TcxLabel;
    LabelTon: TcxLabel;
    LabelBill: TcxLabel;
    LabelOrder: TcxLabel;
    imgPrint: TImage;
    PanelBottom: TPanel;
    PanelBCenter: TPanel;
    PanelBRight: TPanel;
    PanelBLeft: TPanel;
    imgCard: TImage;
    ImageSep: TImage;
    imgPurchaseCard: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure TimerReadCardTimer(Sender: TObject);
    procedure LabelTruckDblClick(Sender: TObject);
    procedure imgPrintClick(Sender: TObject);
    procedure imgCardClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //���ջ���
    FLastCard: string;
    FLastQuery: Int64;
    //�ϴβ�ѯ
    FTimeCounter: Integer;
    //��ʱ
    FHotKeyMgr: THotKeyManager;
    FHotKey: Cardinal;

    FHYDan,FStockName:string;
    FHyDanPrinterName,FDefaultPrinterName:string;
    Fbegin:TDateTime;
    procedure ActionComPort(const nStop: Boolean);
    //���ڴ���
    procedure DoHotKeyHotKeyPressed(HotKey: Cardinal; Index: Word);
    {*�ȼ�����*}
  public
    { Public declarations }
    FCursorShow:Boolean;
    FCardType:TCardType;
    procedure QueryCard(const nCard: string);
    //��ѯ����Ϣ
    procedure QueryPorderinfo(const nCard: string);
    function GetReportFileByStock(const nStock: string): string;
    function PrintHuaYanReport(const nHID: string;var nBatCode:string; const nAsk: Boolean; var nHint: string): Boolean;
    function GetUseFullbat(var nHyDan:string):Boolean;
    function GetNearCode(var nHyDan:string):string;
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, CPortTypes, USysLoger, USysDB, USmallFunc, UDataModule,
  UFormConn, uZXNewCard,USysConst,UClientWorker,UMITPacker,USysModule,USysBusiness,
  UDataReport,UFormInputbox,UFormBarcodePrint,uZXNewPurchaseCard,
  UFormBase,DateUtils;

type
  TReaderType = (ptT800, pt8142);
  //��ͷ����

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gPath: string;
  gReaderItem: TReaderItem;
  //ȫ��ʹ��

resourcestring
  sHint       = '��ʾ';
  sConfig     = 'Config.Ini';
  sForm       = 'FormInfo.Ini';
  sDB         = 'DBConn.Ini';

//------------------------------------------------------------------------------
//Desc: ��¼��־
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '����������', nEvent);
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
var
  nStr:string;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);

  gSysLoger := TSysLoger.Create(gPath + 'Logs\');
  gSysLoger.LogSync := False;
  ShowConnectDBSetupForm(ConnCallBack);
//  ShowCursor(False);

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����

  RunSystemObject;
  FLastQuery := 0;
  FLastCard := '';
  FTimeCounter := 0;
  try
    ActionComPort(False);
    //������ͷ
  except
  end;

  FHotKeyMgr := THotKeyManager.Create(Self);
  FHotKeyMgr.OnHotKeyPressed := DoHotKeyHotKeyPressed;

  FHotKey := TextToHotKey('Ctrl + Alt + D', False);
  FHotKeyMgr.AddHotKey(FHotKey);

  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  //imgPrint.Visible := False;
  imgPurchaseCard.Visible := False;
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    ActionComPort(True);
  except
  end;
  FHotKeyMgr.Free;
end;

procedure TfFormMain.LabelTruckDblClick(Sender: TObject);
var
  nStr: string;
begin
  ShowCursor(True);
  if ShowInputPWDBox('�������˳�����:', '�û�������ѯϵͳ', nStr) and (nStr = '6934') then
  begin
    Close;
  end
  else ShowCursor(False);
end;

//Desc: ���ڲ���
procedure TfFormMain.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    ComPort1.Open;
  end;
end;

procedure TfFormMain.TimerReadCardTimer(Sender: TObject);
begin
  if FTimeCounter <= 0 then
  begin
    TimerReadCard.Enabled := False;
    FHYDan := '';
    FStockName := '';
    LabelDec.Caption := '';
//    imgPrint.Visible := False;

    LabelBill.Caption := '��������:';
    LabelTruck.Caption := '���ƺ���:';
    LabelOrder.Caption := '���۶���:';
    LabelStock.Caption := 'Ʒ������:';
    LabelNum.Caption := '���ŵ���:';
    LabelTon.Caption := '�������:';
    LabelHint.Caption := '����ˢ��';
  end else
  begin
    LabelDec.Caption := IntToStr(FTimeCounter) + ' ';
  end;

  Dec(FTimeCounter);
end;

procedure TfFormMain.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    nCardno:string;
    nSql:string;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    FBuffer := '';
    WriteLog('ComPort1RxChar:'+ParseCardNO(nStr, True));
    FCardType := ctRFID;
    nCardno := ParseCardNO(nStr, True);
    nSql := 'select * from %s where c_card=''%s''';
    nSql := Format(nSql,[sTable_Card,nCardno]);
    with FDM.QuerySQL(nSql) do
    begin
      if RecordCount<=0 then
      begin
        LabelDec.Caption := '�ſ�����Ч';
        Exit;
      end;
      if FieldByName('c_used').AsString=sflag_sale then
      begin
        QueryCard(nCardno);
        Exit;
      end
      else if FieldByName('c_used').AsString=sFlag_Provide then begin
        QueryPorderinfo(nCardno);
        Exit;
      end
      else begin
        LabelDec.Caption := '�ſ�����Ч';
        Exit;
      end;
    end;
  end;
end;

//Date: 2012-5-3
//Parm: ����
//Desc: ��ѯnCard��Ϣ
procedure TfFormMain.QueryCard(const nCard: string);
var nVal: Double;
    nStr,nStock,nBill,nVip,nLine,nPoundQueue,nTruck: string;
    nDate: TDateTime;
    nBeginTotal:TDateTime;
begin
//  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
//  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  //close screen saver

  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    LabelDec.Caption := '�벻ҪƵ������';
    Exit;
  end;

  nBeginTotal := Now;
  try
    FTimeCounter := 10;
    TimerReadCard.Enabled := True;

    nStr := 'Select * From %s Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, nCard]);
    FBegin := Now;
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount < 1 then
      begin
        FTimeCounter := 1;
        LabelDec.Caption := '�ſ�����Ч';
        Exit;
      end;

      nVal := 0;
      First;

      while not Eof do
      begin
        if FieldByName('L_Value').AsFloat > nVal then
        begin
          nBill := FieldByName('L_ID').AsString;
          nVal := FieldByName('L_Value').AsFloat;
        end;

        Next;
      end;

      First;
      while not Eof do
      begin
        if FieldByName('L_ID').AsString = nBill then
          Break;
        Next;
      end;

      nBill  := FieldByName('L_ID').AsString;
      nVip   := FieldByName('L_IsVip').AsString;
      nTruck := FieldByName('L_Truck').AsString;
      nStock := FieldByName('L_StockNo').AsString;
      FHYDan := FieldByName('L_HYDan').AsString;
      FStockName := FieldByName('L_StockName').AsString;

      LabelBill.Caption := '��������: ' + FieldByName('L_ID').AsString;
      LabelOrder.Caption := '���۶���: ' + FieldByName('L_ZhiKa').AsString;
      LabelTruck.Caption := '���ƺ���: ' + FieldByName('L_Truck').AsString;
      LabelStock.Caption := 'Ʒ������: ' + FieldByName('L_StockName').AsString;
      LabelTon.Caption := '�������: ' + FieldByName('L_Value').AsString + '��';
    end;
    WriteLog('TfFormMain.QueryCard(nCard='''+nCard+''')��ѯ�����[nStr]-��ʱ��'+InttoStr(MilliSecondsBetween(Now, nBeginTotal))+'ms');
    //--------------------------------------------------------------------------
    nStr := 'Select Count(*) From %s ' +
            'Where Z_StockNo=''%s'' And Z_Valid=''%s'' And Z_VipLine=''%s''';
    nStr := Format(nStr, [sTable_ZTLines, nStock, sFlag_Yes,nVip]);
    FBegin := Now;
    with FDM.QuerySQL(nStr) do
    begin
      LabelNum.Caption := '���ŵ���: ' + Fields[0].AsString + '��';
    end;
    WriteLog('TfFormMain.QueryCard(nCard='''+nCard+''')��ѯ���ŵ���[+nStr+]-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    //--------------------------------------------------------------------------
    nStr := 'Select T_line,T_InTime,T_Valid From %s ZT ' +
             'Where T_HKBills like ''%%%s%%'' ';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);
    FBegin := Now;
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount < 1 then
      begin
        LabelHint.Caption := '���ĳ�������Ч.';
        Exit;
      end;

      if FieldByName('T_Valid').AsString <> sFlag_Yes then
      begin
        LabelHint.Caption := '���ѳ�ʱ����,�뵽������������������.';
        Exit;
      end;

      nDate := FieldByName('T_InTime').AsDateTime;
      //����ʱ��

      nLine := FieldByName('T_Line').AsString;
      //ͨ����
    end;
    WriteLog('TfFormMain.QueryCard(nCard='''+nCard+''')��ѯ����״̬['+nStr+']-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    if nLine <> '' then
    begin
      nStr := 'Select Z_Valid,Z_Name From %s Where Z_ID=''%s'' ';
      nStr := Format(nStr, [sTable_ZTLines, nLine]);

      with FDM.QuerySQL(nStr) do
      begin
        if FieldByName('Z_Valid').AsString = 'N' then
        begin
        LabelHint.Caption := '�����ڵ�ͨ���ѹرգ�����ϵ������Ա.';
        Exit;
        end else
        begin
        LabelHint.Caption := 'ϵͳ�����ĳ������볧,�뵽' + FieldByName('Z_Name').AsString + '���.';
        Exit;
        end;
      end;
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$PQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$PQ', sFlag_PoundQueue)]);

    with FDM.QuerySQL(nStr) do
    begin
      if FieldByName('D_Value').AsString = 'Y' then
      nPoundQueue := 'Y';
    end;

    nStr := 'Select D_Value From $DT Where D_Memo = ''$DQ''';
    nStr := MacroValue(nStr, [MI('$DT', sTable_SysDict),
            MI('$DQ', sFlag_DelayQueue)]);

    with FDM.QuerySQL(nStr) do
    begin
    if  FieldByName('D_Value').AsString = 'Y' then
      begin
        if nPoundQueue <> 'Y' then
        begin
          nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                  'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InFact<''$IT'' And T_Vip=''$VIP''';
        end else
        begin
          nStr := ' Select Count(*) From $TB left join S_PoundLog on S_PoundLog.P_Bill=S_ZTTrucks.T_Bill ' +
                  ' Where T_InQueue Is Null And ' +
                  ' T_Valid=''$Yes'' And T_StockNo=''$SN'' And P_PDate<''$IT'' And T_Vip=''$VIP''';
        end;
      end else
      begin
        nStr := 'Select Count(*) From $TB Where T_InQueue Is Null And ' +
                'T_Valid=''$Yes'' And T_StockNo=''$SN'' And T_InTime<''$IT'' And T_Vip=''$VIP''';
      end;

      nStr := MacroValue(nStr, [MI('$TB', sTable_ZTTrucks),
            MI('$Yes', sFlag_Yes), MI('$SN', nStock),
            MI('$IT', DateTime2Str(nDate)),MI('$VIP', nVip)]);
    end;
    //xxxxx
    FBegin := Now;
    with FDM.QuerySQL(nStr) do
    begin
      if Fields[0].AsInteger < 1 then
      begin
        nStr := '�����ŵ�����,���ע��������׼������.';
        LabelHint.Caption := nStr;
      end else
      begin
        nStr := '��ǰ�滹�С� %d �������ȴ�����';
        LabelHint.Caption := Format(nStr, [Fields[0].AsInteger]);
      end;
    end;
    WriteLog('TfFormMain.QueryCard(nCard='''+nCard+''')��ѯ��������-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    FLastQuery := GetTickCount;
    FLastCard := nCard;
    //�ѳɹ�����
  except
    on E: Exception do
    begin
      ShowMsg('��ѯʧ��', sHint);
      WriteLog(E.Message);
    end;
  end;
  WriteLog('TfFormMain.QueryCard(nCard='''+nCard+''')��ѯ�ſ���Ϣ-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  FDM.ADOConn.Connected := False;
end;


procedure TfFormMain.DoHotKeyHotKeyPressed(HotKey: Cardinal; Index: Word);
begin
  if (HotKey = FHotKey) then
  begin
    ShowCursor(True);
    FCursorShow := True;
  end;
end;

procedure TfFormMain.imgPrintClick(Sender: TObject);
var
  nP: TFormCommandParam;
  nHyDan,nStockname,nstockno:string;
  nShortFileName:string;
  nStr, nBatCode,nBat,nMsg:string;
  nIdx:Integer;
begin
  nShortFileName := '';
  CreateBaseFormItem(cFI_FormBarCodePrint, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    nHyDan := nP.FParamB;
    nStockname := nP.FParamC;
    nstockno := nP.FParamD;
    nShortFileName := gSysParam.FQCReportFR3Map.Values[nstockno];
    if nHyDan='' then
    begin
      ShowMsg('��ǰƷ�������ӡ���鵥��',sHint);
      Exit;
    end;

    if not Assigned(FDR) then
    begin
      FDR := TFDR.Create(Application);
    end;

    if PrintHuaYanReport(nP.FParamE,nHyDan, False,nMsg) then
    begin
      ShowMsg('��ӡ�ɹ��������·���ֽ��ȡ�����Ļ��鵥',sHint);
    end
    else begin
      if nMsg <> '' then
        ShowMsg(nMsg,sHint)
      else
        ShowMsg('��ӡʧ�ܣ�����ϵ��ƱԱ����',sHint);
    end;
  end;
end;

procedure TfFormMain.imgCardClick(Sender: TObject);
begin
  if Sender=imgCard then
  begin
    if not Assigned(fFormNewCard) then
    begin
      fFormNewCard := TfFormNewCard.Create(nil);
      fFormNewCard.SetControlsClear;
    end;
    fFormNewCard.BringToFront;
    fFormNewCard.Left := self.Left;
    fFormNewCard.Top := self.Top;
    fFormNewCard.Width := self.Width;
    fFormNewCard.Height := self.Height;
    fFormNewCard.Show;
  end
  else if Sender=imgPurchaseCard then
  begin
   if not Assigned(fFormNewPurchaseCard) then
    begin
      fFormNewPurchaseCard := TfFormNewPurchaseCard.Create(nil);
      fFormNewPurchaseCard.SetControlsClear;
    end;
    fFormNewPurchaseCard.BringToFront;
    fFormNewPurchaseCard.Left := self.Left;
    fFormNewPurchaseCard.Top := self.Top;
    fFormNewPurchaseCard.Width := self.Width;
    fFormNewPurchaseCard.Height := self.Height;
    fFormNewPurchaseCard.Show;
  end;
end;

procedure TfFormMain.FormResize(Sender: TObject);
var
  nIni:TIniFile;
  nFileName:string;
  nLeft,nTop,nWidth,nHeight:Integer;
  nItemHeigth:Integer;
begin
  nFileName := ExtractFilePath(ParamStr(0))+'Config.Ini';
  if not FileExists(nFileName) then
  begin
    Exit;
  end;
  nIni := TIniFile.Create(nFileName);
  try
    nLeft := nIni.ReadInteger('screen','left',0);
    nTop := nIni.ReadInteger('screen','top',0);
    nWidth := nIni.ReadInteger('screen','width',1024);
    nHeight := nIni.ReadInteger('screen','height',768);
    nItemHeigth := nHeight div 8;

    LabelTruck.Height := nItemHeigth;
    LabelDec.Height := nItemHeigth;
    LabelBill.Height := nItemHeigth;
    LabelOrder.Height := nItemHeigth;
    LabelTon.Height := nItemHeigth;
    LabelStock.Height := nItemHeigth;
    LabelNum.Height := nItemHeigth;
    LabelHint.Height := nItemHeigth;
    imgCard.Height := nItemHeigth;
    imgPurchaseCard.Height := nItemHeigth;
    imgPrint.Height := nItemHeigth;
    imgCard.Top := LabelHint.Top;
    imgPurchaseCard.Top := LabelHint.Top;
    imgPrint.Top := LabelHint.Top;

    Self.Left := nLeft;
    self.Top := nTop;
    self.Width := nWidth;
    self.Height := nHeight;

    imgPrint.Left := self.Width-imgprint.Width;
  finally
    nIni.Free;
  end;
end;

procedure TfFormMain.QueryPorderinfo(const nCard: string);
var
  nStr:string;
  nDate: TDateTime;
begin
  if (nCard = FLastCard) and (GetTickCount - FLastQuery < 8 * 1000) then
  begin
    LabelDec.Caption := '�벻ҪƵ������';
    Exit;
  end;

  {try
    FTimeCounter := 10;
    TimerReadCard.Enabled := True;

    nStr := 'select * from %s where o_card=''%s''';
    nStr := Format(nStr, [sTable_Order, nCard]);
    FBegin := Now;
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount < 1 then
      begin
        FTimeCounter := 1;
        LabelDec.Caption := '�ſ�����Ч';
        Exit;
      end;
      LabelBill.Caption := '��������: ' + FieldByName('o_id').AsString;
      LabelOrder.Caption := '�ɹ�����: ' + FieldByName('o_bid').AsString;
      LabelTruck.Caption := '���ƺ���: ' + FieldByName('o_Truck').AsString;
      LabelStock.Caption := 'Ʒ������: ' + FieldByName('o_StockName').AsString;
      LabelTon.Caption := '�������: ';
    end;
    WriteLog('TfFormMain.QueryPorderinfo(nCard='''+nCard+''')��ѯ�ɹ���['+nStr+']-��ʱ��'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    FLastQuery := GetTickCount;
    FLastCard := nCard;
  except
    on E: Exception do
    begin
      ShowMsg('��ѯʧ��', sHint);
      WriteLog(E.Message);
    end;
  end;}
end;

//Desc: ��ӡ��ʶΪnHID�Ļ��鵥
function TfFormMain.PrintHuaYanReport(const nHID: string; var nBatCode:string; const nAsk: Boolean; var nHint: string): Boolean;
var nStr,nSR, nHyDan: string;
  i:integer;
  nHYCount: Integer;
begin
  Result := False;
  
  nStr := ' Select D_Value From %s  ' +
          ' Where D_Name = ''%s'' and D_Memo = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam,sFlag_HYPrintCount]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nHYCount := Fields[0].AsInteger;
    end
    else
      nHYCount := 10;
  end;

  nStr := ' Select sb.L_HyPrintCount From %s sb ' +
          ' Where sb.L_ID = ''%s''';
  nStr := Format(nStr, [sTable_Bill, nHID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if Fields[0].AsInteger >= nHYCount then
      begin
        nStr  := '���鵥��ӡ�����Ѵ�����,����������ӡ��';
        nHint := nStr;
        ShowMsg(nStr, sHint);
        Exit;
      end;
    end;
  end;
  
  if nAsk then
  begin
    Result := True;
    nStr := '�Ƿ�Ҫ��ӡ���鵥?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := ' Select H_ID,H_No,H_Custom,H_CusName,H_SerialNo,H_Truck,H_BillDate, ' +
          ' H_EachTruck,H_ReportDate,H_Reporter, ' +
          ' CASE WHEN ((L_HDORDERID IS NULL) OR (L_HDORDERID = '''')) THEN L_VALUE ELSE ' +
          ' (SELECT SUM(ISNULL(L_VALUE,0)) FROM S_BILL WHERE L_HDORDERID = sb.L_HDORDERID) END AS H_Value, ' +
          ' sr.*,sb.*, C_Name, convert(varchar(100),(H_BillDate-4),23) as H_QYDate,'+
          ' (case when isnull(sb.L_HyPrintCount,0)>0 THEN ''��'' ELSE '''' END) AS IsBuDan From $HY hy ' +
          ' inner join $SB sb on hy.H_Reporter = sb.L_ID '+
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom ' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          ' Where H_Reporter=''$ID''';

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR),MI('$SB', sTable_Bill), MI('$ID', nHID)]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '���Ϊ %s �Ļ��鵥��¼����Ч!!';
    nStr := Format(nStr, [nHID]);
    nHint := nStr;
    ShowMsg(nStr, sHint); Exit;
  end;

  if Length(Trim(FDM.SqlTemp.FieldByName('R_28Zhe1').AsString)) <= 0 then
  begin
    nStr := '���Ϊ %s ��28�컯�鵥��¼������!';
    nStr := Format(nStr, [nHID]);
    nHint:= nStr;
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('L_StockName').AsString;
  nStr := GetReportFileByStock(nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr  := '�޷���ȷ���ر����ļ�';
    nHint := nStr;
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  //FDR.ShowReport;
  FDR.PrintReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := ' UPDate %s Set L_HyPrintCount = L_HyPrintCount + 1 Where L_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_Bill, nHID]);
    FDM.ExecuteSQL(nStr);
  end;
end;

function TfFormMain.GetReportFileByStock(const nStock: string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HYReportName, nStock]);
  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    Result := gPath + sReportDir + Fields[0].AsString;
  end;
end;

function TfFormMain.GetUseFullbat(var nHyDan:string): Boolean;
var
  nBatCode,nBat,nStr:string;
  nIdx:Integer;
begin
  Result := False;
  nBatCode := nHyDan;
  nStr := 'select * from %s where R_SerialNo=''%s''';
  nStr := Format(nStr,[sTable_StockRecord, nHyDan]);

  if fdm.QueryTemp(nStr).RecordCount>0 then Result := True;
end;

function TfFormMain.GetNearCode(var nHyDan: string): string;
var
  nBatCode,nBat:string;
  nIdx:Integer;
begin
  nBatCode := Copy(nHyDan,1,Length(nHyDan)-3);
  nIdx := StrToInt(Copy(nHyDan,Length(nHyDan)-2,3));
  Dec(nIdx);
  nBat := IntToStr(nIdx);
  while Length(nBat) < 3 do
    nBat := '0' + nBat;
  nBatCode := nBatCode + nBat;
  Result := nBatCode;
end;

end.