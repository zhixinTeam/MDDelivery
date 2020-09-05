{*******************************************************************************
  作者: dmzn@163.com 2017-01-03
  描述: 厂内零售业务制卡
*******************************************************************************}
unit UFormBillSalePlan;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, CPort, CPortTypes, UFormNormal, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  ComCtrls, cxListView, cxTextEdit, dxLayoutControl, StdCtrls;

type
  TfFormBillSalePlan = class(TfFormNormal)
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    ListTruck: TcxListView;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FParam: PFormCommandParam;
    procedure InitFormData;
    procedure LoadPlanList;
    procedure ActionComPort(const nStop: Boolean);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormWait, USysBusiness, USmallFunc,
  USysConst, USysDB;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;

var
  gReaderItem: TReaderItem;
  gSalePlan: TSalePlanItems;
  //全局使用

class function TfFormBillSalePlan.FormID: integer;
begin
  Result := cFI_Form_HT_SalePlan;
end;

class function TfFormBillSalePlan.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  with TfFormBillSalePlan.Create(Application) do
  try
    FParam := nParam;
    InitFormData;
    ActionComPort(False);

    FParam.FCommand := cCmd_ModalResult;
    FParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

procedure TfFormBillSalePlan.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

//------------------------------------------------------------------------------
procedure TfFormBillSalePlan.InitFormData;
begin
  ShowWaitForm(Application.MainForm, '读取计划', True);
  try
    if LoadSalePlan(FParam.FParamC, gSalePlan) then
      LoadPlanList;
    //xxxxx
  finally
    CloseWaitForm;
  end;

  ActiveControl := EditCard;
end;

procedure TfFormBillSalePlan.LoadPlanList;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_StockNo From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FParam.FParamB]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      nStr := Fields[0].AsString;
      for nIdx:=Low(gSalePlan) to High(gSalePlan) do
       with gSalePlan[nIdx] do
       {.$IFNDEF DEBUG}
        if FStockID = nStr then
       {.$ENDIF}
          FSelected := True;
      //xxxxx
      
      Next;
    end;
  end;

  for nIdx:=Low(gSalePlan) to High(gSalePlan) do
  with gSalePlan[nIdx] do
  begin
    if not FSelected then Continue;
    with ListTruck.Items.Add do
    begin
      Caption := FStockName;
      SubItems.Add(FTruck);
      SubItems.Add(FloatToStr(FValue));
      Data := Pointer(nIdx);
    end;
  end;
end;

//Desc: 串口操作
procedure TfFormBillSalePlan.ActionComPort(const nStop: Boolean);
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

    if ComPort1.Port <> '' then
      ComPort1.Open;
    EditCard.Properties.ReadOnly := ComPort1.Connected;
  end;
end;

procedure TfFormBillSalePlan.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nKey: Char;
    nIdx,nLen: Integer;
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
    EditCard.Text := ParseCardNO(nStr, True); 

    FBuffer := '';
    nKey := #13;
    EditCardKeyPress(nil, nKey);
    Exit;
  end;
end;

procedure TfFormBillSalePlan.EditCardKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
begin
  if Key <> #13 then
  begin
    OnCtrlKeyPress(Sender, Key);
    Exit;
  end;

  Key := #0;
  nStr := 'Select L_Truck, L_PValue From %s Where L_Card=''%s''';
  nStr := Format(nStr, [sTable_Bill, EditCard.Text]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg('该磁卡没有提货单', sHint);
      Exit;
    end;

    if FloatRelation(Fields[1].AsFloat, 0, rtLE) then
    begin
      ShowMsg('请先称重', sHint);
      Exit;
    end;  

    EditTruck.Text := Fields[0].AsString;
  end;
end;

//Desc: 保存磁卡
procedure TfFormBillSalePlan.BtnOKClick(Sender: TObject);
var nIdx: Integer;
begin
  EditCard.Text := Trim(EditCard.Text);
  if (EditCard.Text = '') and (ListTruck.ItemIndex < 0) then
  begin
    ActiveControl := EditCard;
    EditCard.SelectAll;

    ShowMsg('请输入有效卡号', sHint);
    Exit;
  end;

  if EditCard.Text <> '' then
  begin
    FParam.FParamB := EditCard.Text;
    FParam.FParamD := EditTruck.Text;
    FParam.FParamC := 0;
  end else
  begin
    FParam.FParamB := '';
    nIdx := Integer(ListTruck.Items[ListTruck.ItemIndex].Data);
    FParam.FParamC := Integer(@gSalePlan[nIdx]);
  end;

  ModalResult := mrOk;
  //done
end;

initialization
  gControlManager.RegCtrl(TfFormBillSalePlan, TfFormBillSalePlan.FormID);
end.
