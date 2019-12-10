{*******************************************************************************
  作者: dmzn@163.com 2010-3-17
  描述: 销售回款
*******************************************************************************}
unit UFormKPPayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxButtonEdit, cxMCListBox,
  cxLabel, cxMemo, cxTextEdit, cxMaskEdit, cxDropDownEdit, dxLayoutControl,
  StdCtrls;

type
  TfFormKPPayment = class(TfFormNormal)
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
  protected
    { Private declarations }
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
    procedure InitFormData(const nID: string);
    //载入数据
    procedure ClearCustomerInfo;
    function LoadCustomerInfo(const nID: string): Boolean;
    //载入客户
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
  USysDB, USysConst, USysBusiness;

type
  TCommonInfo = record
    FCusID: string;
    FCusName: string;
    FSaleMan: string;
  end;

var
  gInfo: TCommonInfo;
  //全局使用

//------------------------------------------------------------------------------
class function TfFormKPPayment.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin 
  Result := nil;
  if not WorkPCHasPopedom then Exit;
  nP := nParam;

  with TfFormKPPayment.Create(Application) do
  try
    Caption := '临时回款';
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
  finally
    Free;
  end;
end;

class function TfFormKPPayment.FormID: integer;
begin
  Result := cFI_FormKPPayment;
end;

procedure TfFormKPPayment.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormKPPayment.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
end;

//------------------------------------------------------------------------------
procedure TfFormKPPayment.InitFormData(const nID: string);
var
  nStr : string;
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  LoadSaleMan(EditSalesMan.Properties.Items);

  LoadSysDictItem(sFlag_PaymentItem2, EditType.Properties.Items);
//  EditType.ItemIndex := 0;
  
  if nID <> '' then
  begin
    ActiveControl := EditMoney;
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

//Desc: 清理客户信息
procedure TfFormKPPayment.ClearCustomerInfo;
begin
  ListInfo.Clear;
  EditIn.Text := '0';
  EditOut.Text := '0';

  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;
end;

//Desc: 载入nID客户的信息
function TfFormKPPayment.LoadCustomerInfo(const nID: string): Boolean;
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

  ActiveControl := EditMoney;
end;

procedure TfFormKPPayment.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormKPPayment.EditNamePropertiesEditValueChanged(Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

procedure TfFormKPPayment.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    ClearCustomerInfo;
    ShowMsg('请填写有效编号', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

//Desc: 选择客户
procedure TfFormKPPayment.EditNameKeyPress(Sender: TObject; var Key: Char);
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
function TfFormKPPayment.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditName then
  begin
    Result := EditName.ItemIndex > -1;
    nHint := '请选择有效的客户';
  end else

  if Sender = EditType then
  begin
    Result := Trim(EditType.Text) <> '';
    nHint := '请填写付款方式';
  end else

  if Sender = EditPrice1 then
  begin
    Result := StrToFloatDef(Trim(EditPrice1.Text),0) > 0;
    nHint := '请填写价格信息';
  end else

  if Sender = EditStockName1 then
  begin
    Result :=  Trim(EditStockName1.Text) <> '';
    nHint := '请填写品种信息';
  end else

  if Sender = EditMoney then
  begin
    Result := IsNumber(EditMoney.Text, True) and
              (Float2PInt(StrToFloat(EditMoney.Text), cPrecision) <> 0);
    nHint := '请填写有效的金额';
  end;
end;

procedure TfFormKPPayment.BtnOKClick(Sender: TObject);
var nP: TFormCommandParam;
  nStr: string;
  nSumMoney, nUsedMoney: Double;
  nPriceStock : string;
begin
  if not IsDataValid then Exit;
  
  nSumMoney := 0;
  nUsedMoney:= 0;
  
  nStr := ' Select D_Value From %s Where D_Name = ''%s'' and  D_Memo = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam,'NoRuZhangMoney']);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nSumMoney := FieldByName('D_Value').AsFloat;
  end;

  nStr := ' Select Sum(M_Money) as M_Money From %s Where M_CusID = ''%s'' and M_RuZhang = ''N'' ';
  nStr := Format(nStr, [sTable_InOutMoney, gInfo.FCusID]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nUsedMoney := FieldByName('M_Money').AsFloat;
  end;

  if nSumMoney > 0 then
  begin
    if nUsedMoney + StrToFloat(EditMoney.Text) > nSumMoney then
    begin
      ShowMsg('客户未入账金额已超过最大额度:'+FloatToStr(nSumMoney),sHint);
      Exit;
    end;
  end;

  nPriceStock := EditStockName1.Text +':'+EditPrice1.Text;
  if Trim(EditStockName2.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName2.Text +':'+EditPrice2.Text;
  end;
  if Trim(EditStockName3.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName3.Text +':'+EditPrice3.Text;
  end;
  
  if not SaveCustomerKPPayment(gInfo.FCusID, gInfo.FCusName,
     GetCtrlData(EditSalesMan), sFlag_MoneyHuiKuan, EditType.Text, EditDesc.Text,
     StrToFloat(EditMoney.Text),StrToFloatDef(EditPrice1.Text,0),nPriceStock, True) then
  begin
    ShowMsg('临时回款操作失败', sError); Exit;
  end;

  if StrToFloat(EditMoney.Text) > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    nP.FParamA := gInfo.FCusName;
    nP.FParamB := '临时回款或预付款';
    nP.FParamC := EditMoney.Text;
    CreateBaseFormItem(cFI_FormShouJu, '', @nP);
  end;
  //校正纸卡限提
  CheckZhiKaXTMoney;
  
  ModalResult := mrOk;
  ShowMsg('临时回款操作成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormKPPayment, TfFormKPPayment.FormID);
end.
