{*******************************************************************************
  ����: dmzn@163.com 2010-3-17
  ����: ���ۻؿ�
*******************************************************************************}
unit UFormPayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxButtonEdit, cxMCListBox,
  cxLabel, cxMemo, cxTextEdit, cxMaskEdit, cxDropDownEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormPayment = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    dxLayout1Item3: TdxLayoutItem;
    EditType: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDesc: TcxMemo;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Item6: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    ListInfo: TcxMCListBox;
    dxLayout1Item8: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditSalesMan: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    EditName: TcxComboBox;
    dxGroup3: TdxLayoutGroup;
    dxLayout1Item12: TdxLayoutItem;
    EditIn: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditOut: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item15: TdxLayoutItem;
    cxLabel3: TcxLabel;
    dxLayout1Group4: TdxLayoutGroup;
    EditPrice1: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditStockName1: TcxComboBox;
    dxLayout1Item17: TdxLayoutItem;
    EditPrice2: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    EditStockName2: TcxComboBox;
    dxLayout1Item18: TdxLayoutItem;
    EditPrice3: TcxTextEdit;
    dxLayout1Item19: TdxLayoutItem;
    EditStockName3: TcxComboBox;
    dxLayout1Item20: TdxLayoutItem;
    EditAcceptNum: TcxTextEdit;
    dxLayout1Item21: TdxLayoutItem;
    EditPayingMan: TcxTextEdit;
    dxLayout1Item23: TdxLayoutItem;
    EditPayingUnit: TcxComboBox;
    dxLayout1Item24: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
    procedure EditMoneyExit(Sender: TObject);
    procedure EditPayingUnitKeyPress(Sender: TObject; var Key: Char);
    procedure EditNamePropertiesChange(Sender: TObject);
  protected
    { Private declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure InitFormData(const nID: string);
    //��������
    procedure ClearCustomerInfo;
    function LoadCustomerInfo(const nID: string): Boolean;
    //����ͻ�
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule, 
  USysDB, USysConst, USysBusiness, Dialogs;

type
  TCommonInfo = record
    FCusID: string;
    FCusName: string;
    FSaleMan: string;
  end;

var
  gInfo: TCommonInfo;
  //ȫ��ʹ��

//------------------------------------------------------------------------------
class function TfFormPayment.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin 
  Result := nil;
  if not WorkPCHasPopedom then Exit;
  nP := nParam;

  with TfFormPayment.Create(Application) do
  try
    Caption := '�������';
    if Assigned(nP) then
    begin
      InitFormData(nP.FParamA);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
    end else
    begin
      InitFormData('');
      ShowModal;
    end;
    EditPayingUnit.Properties.IncrementalSearch := False;
  finally
    Free;
  end;
end;

class function TfFormPayment.FormID: integer;
begin
  Result := cFI_FormPayment;
end;

procedure TfFormPayment.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormPayment.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormPayment.InitFormData(const nID: string);
var
  nStr : string;
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  LoadSaleMan(EditSalesMan.Properties.Items);

  LoadSysDictPayType(EditType.Properties.Items);
 // EditType.ItemIndex := 0;
  
  if nID <> '' then
  begin
    ActiveControl := EditType;
    LoadCustomerInfo(nID);
  end else ActiveControl := EditID;

  if EditStockName1.Properties.Items.Count < 1 then
  begin
    nStr := ' Select D_Value From %s where D_Name = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, 'StockItem']);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockName1.Properties.Items.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  end;

  if EditStockName2.Properties.Items.Count < 1 then
  begin
    nStr := ' Select D_Value From %s where D_Name = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, 'StockItem']);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockName2.Properties.Items.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  end;

  if EditStockName3.Properties.Items.Count < 1 then
  begin
    nStr := ' Select D_Value From %s where D_Name = ''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, 'StockItem']);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockName3.Properties.Items.Add(FieldByName('D_Value').AsString);
        Next;
      end;
    end;
  end;
end;

//Desc: �����ͻ���Ϣ
procedure TfFormPayment.ClearCustomerInfo;
begin
  ListInfo.Clear;
  EditIn.Text := '0';
  EditOut.Text := '0';

  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;
end;

//Desc: ����nID�ͻ�����Ϣ
function TfFormPayment.LoadCustomerInfo(const nID: string): Boolean;
var nStr: string;
    nDS: TDataSet;
begin
  ClearCustomerInfo;
  nDS := USysBusiness.LoadCustomerInfo(nID, ListInfo, nStr);
  
  Result := Assigned(nDS);
  BtnOK.Enabled := Result;

  if not Result then
  begin
    ShowMsg(nStr, sHint); Exit;
  end;

  with nDS,gInfo do       
  begin
    FCusID := nID;
    FCusName := FieldByName('C_Name').AsString;
    FSaleMan := FieldByName('C_SaleMan').AsString;
  end;

  EditID.Text := nID;
  SetCtrlData(EditSalesMan, gInfo.FSaleMan);

  if GetStringsItemIndex(EditName.Properties.Items, nID) < 0 then
  begin
    nStr := Format('%s=%s.%s', [nID, nID, gInfo.FCusName]);
    InsertStringsItem(EditName.Properties.Items, nStr);
  end;
  SetCtrlData(EditName, nID);

  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, nID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    EditIn.Text := Format('%.2f', [FieldByName('A_InMoney').AsFloat]);
    EditOut.Text := Format('%.2f', [FieldByName('A_OutMoney').AsFloat]);
  end;

  ActiveControl := EditType;
end;

procedure TfFormPayment.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormPayment.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormPayment.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('����д��Ч���', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

//Desc: ѡ��ͻ�
procedure TfFormPayment.EditNameKeyPress(Sender: TObject; var Key: Char);
var nStr: string;
    nP: TFormCommandParam;
begin
  if Key = #13 then
  begin
    Key := #0;
    nP.FParamA := GetCtrlData(EditName);
    
    if nP.FParamA = '' then
      nP.FParamA := EditName.Text;
    //xxxxx

    CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    SetCtrlData(EditSalesMan, nP.FParamD);
    SetCtrlData(EditName, nP.FParamB);
    
    if EditName.ItemIndex < 0 then
    begin
      nStr := Format('%s=%s.%s', [nP.FParamB, nP.FParamB, nP.FParamC]);
      InsertStringsItem(EditName.Properties.Items, nStr);
      SetCtrlData(EditName, nP.FParamB);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfFormPayment.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditName then
  begin
    Result := EditName.ItemIndex > -1;
    nHint := '��ѡ����Ч�Ŀͻ�';
  end else

  if Sender = EditType then
  begin
    Result := Trim(EditType.Text) <> '';
    nHint := '����д���ʽ';
  end else

//  if Sender = EditPrice1 then
//  begin
//    Result := StrToFloatDef(Trim(EditPrice1.Text),0) > 0;
//    nHint := '����д�۸���Ϣ';
//  end else

//  if Sender = EditStockName1 then
//  begin
//    Result :=  Trim(EditStockName1.Text) <> '';
//    nHint := '����дƷ����Ϣ';
//  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True) and
              (Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <> 0);
    nHint := '����д��Ч�Ľ��';
  end;
end;

procedure TfFormPayment.BtnOKClick(Sender: TObject);
var
  nP: TFormCommandParam;
  nPriceStock, nStr, nID : string;
begin
  if not IsDataValid then Exit;

  nPriceStock := EditStockName1.Text;  //+':'+EditPrice1.Text;
  if Trim(EditStockName2.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName2.Text; // +':'+EditPrice2.Text;
  end;
  if Trim(EditStockName3.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName3.Text;// +':'+EditPrice3.Text;
  end;
  if not SaveCustomerPayment(gInfo.FCusID, gInfo.FCusName,
     GetCtrlData(EditSalesMan), sFlag_MoneyHuiKuan, EditType.Text, EditDesc.Text,
     StrToFloat(EditMoney.Text),StrToFloatDef(EditPrice1.Text,0),nPriceStock,EditAcceptNum.Text,
     EditPayingUnit.Text,EditPayingMan.Text, True) then
  begin
    ShowMsg('�ؿ����ʧ��', sError); Exit;
  end;

  nStr := ' Select Top 1 R_ID From %s Where M_CusID = ''%s'' Order By R_ID Desc ';
  nStr := Format(nStr, [sTable_InOutMoney, gInfo.FCusID]);
  with FDM.QueryTemp(nStr) do
  begin
    nID := Fields[0].AsString; 
  end;

  //���潻����λ��Ϣ
  nStr := ' Select Count(*) From %s Where P_PayingUnit=''%s'' and P_CustID = ''%s'' ';
  nStr := Format(nStr, [sTable_PayingUnit, Trim(EditPayingUnit.Text),gInfo.FCusID]);

  with FDM.QueryTemp(nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(P_PayingUnit, P_PY, P_CustID,P_SaleID) Values(''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr, [sTable_PayingUnit, Trim(EditPayingUnit.Text),
      GetPinYinOfStr(Trim(EditPayingUnit.Text)),gInfo.FCusID,GetCtrlData(EditSalesMan)]);
    FDM.ExecuteSQL(nStr);
  end;
  //�س�Ҳ�����վ�
  nP.FCommand := cCmd_AddData;
  nP.FParamA  := EditPayingUnit.Text;
  if Trim(EditAcceptNum.Text) <> '' then
    nP.FParamB  := EditType.Text +'('+Trim(EditAcceptNum.Text)+')'
  else
    nP.FParamB  := EditType.Text;
  nP.FParamC  := EditMoney.Text;
  nP.FParamD  := EditPayingMan.Text;
  nP.FParamE  := EditDesc.Text;
  nP.FParamF  := nPriceStock;
  nP.FParamG  := nID;
  CreateBaseFormItem(cFI_FormShouJu, '', @nP);

  //У��ֽ������
  CheckZhiKaXTMoney;

  ModalResult := mrOk;
  ShowMsg('�ؿ�����ɹ�', sHint);
end;
//------------------------------------------------------------------------------
function SmallTOBig(small: real): string;
var
  SmallMonth, BigMonth: string;
  wei1, qianwei1: string[2];
  qianwei, dianweizhi, qian: integer;
  fs_bj: boolean;
begin
  if small < 0 then
    fs_bj := True
  else
    fs_bj := False;
  small      := abs(small);
  {------- �޸Ĳ�����ֵ����ȷ -------}
  {С������λ�ã���Ҫ�Ļ�Ҳ���ԸĶ�-2ֵ}
  qianwei    := -2;
  {ת���ɻ�����ʽ����Ҫ�Ļ�С�����Ӷ༸����}
  Smallmonth := formatfloat('0.00', small);
  {---------------------------------}
  dianweizhi := pos('.', Smallmonth);{С�����λ��}
  {ѭ��Сд���ҵ�ÿһλ����Сд���ұ�λ�õ����}
  for qian := length(Smallmonth) downto 1 do
  begin
    {��������Ĳ���С����ͼ���}
    if qian <> dianweizhi then
    begin
      {λ���ϵ���ת���ɴ�д}
      case StrToInt(Smallmonth[qian]) of
        1: wei1 := 'Ҽ';
        2: wei1 := '��';
        3: wei1 := '��';
        4: wei1 := '��';
        5: wei1 := '��';
        6: wei1 := '½';
        7: wei1 := '��';
        8: wei1 := '��';
        9: wei1 := '��';
        0: wei1 := '��';
      end;
      {�жϴ�дλ�ã����Լ�������real���͵����ֵ}
      case qianwei of
        -3: qianwei1 := '��';
        -2: qianwei1 := '��';
        -1: qianwei1 := '��';
        0: qianwei1  := 'Ԫ';
        1: qianwei1  := 'ʰ';
        2: qianwei1  := '��';
        3: qianwei1  := 'Ǫ';
        4: qianwei1  := '��';
        5: qianwei1  := 'ʰ';
        6: qianwei1  := '��';
        7: qianwei1  := 'Ǫ';
        8: qianwei1  := '��';
        9: qianwei1  := 'ʰ';
        10: qianwei1 := '��';
        11: qianwei1 := 'Ǫ';
      end;
      inc(qianwei);
      BigMonth := wei1 + qianwei1 + BigMonth;{��ϳɴ�д���}
    end;
  end;

  BigMonth := StringReplace(BigMonth, '��ʰ', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '���', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '��Ǫ', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '������', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '���', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '���', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '��Ԫ', 'Ԫ', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);
  BigMonth := BigMonth + '��';
  BigMonth := StringReplace(BigMonth, '����', '��', [rfReplaceAll]);

  if BigMonth = 'Ԫ��' then
    BigMonth := '��Ԫ��';
  if copy(BigMonth, 1, 2) = 'Ԫ' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if copy(BigMonth, 1, 2) = '��' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if fs_bj = True then
    SmallTOBig := '- ' + BigMonth
  else
    SmallTOBig := BigMonth;
end;

procedure TfFormPayment.EditMoneyExit(Sender: TObject);
var
  nStr: string;
begin
  inherited;
  nStr := SmallTOBig(StrToFloat(EditMoney.Text));
  ShowMessage(nStr);
  ActiveControl := EditAcceptNum;
end;

procedure TfFormPayment.EditPayingUnitKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditPayingUnit.Text;
    CreateBaseFormItem(cFI_FormGetPayingUnit, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditPayingUnit.Text := nP.FParamB;
    EditPayingUnit.SelectAll;
  end;
end;

procedure TfFormPayment.EditNamePropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditName.ItemIndex > -1 then
  begin
    EditPayingUnit.Properties.Items.Clear;
    EditPayingUnit.Clear;
    
    nStr := ' Select distinct P_PayingUnit From %s Where P_CustID = ''%s'' ';
    nStr := Format(nStr, [sTable_PayingUnit, GetCtrlData(EditName)]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditPayingUnit.Properties.Items.Add(FieldByName('P_PayingUnit').AsString);
        Next;
      end;
    end;
    if EditPayingUnit.Properties.Items.Count = 1 then
    begin
      EditPayingUnit.ItemIndex := 0;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPayment, TfFormPayment.FormID);
end.