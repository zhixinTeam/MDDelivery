{*******************************************************************************
  作者: dmzn@163.com 2010-3-17
  描述: 销售回款
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
    procedure BtnOKClick(Sender: TObject);
    procedure EditMoneyExit(Sender: TObject);
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
  USysDB, USysConst, USysBusiness, Dialogs;

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
class function TfFormPayment.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin 
  Result := nil;
  if not WorkPCHasPopedom then Exit;
  nP := nParam;

  with TfFormPayment.Create(Application) do
  try
    Caption := '货款回收';
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

  LoadSysDictItem(sFlag_PaymentItem2, EditType.Properties.Items);
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

//Desc: 清理客户信息
procedure TfFormPayment.ClearCustomerInfo;
begin
  ListInfo.Clear;
  EditIn.Text := '0';
  EditOut.Text := '0';

  if not EditID.Focused then EditID.Clear;
  if not EditName.Focused then EditName.ItemIndex := -1;
end;

//Desc: 载入nID客户的信息
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
    ShowMsg('请填写有效编号', sHint);
  end else LoadCustomerInfo(EditID.Text);
end;

//Desc: 选择客户
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

procedure TfFormPayment.BtnOKClick(Sender: TObject);
var
  nP: TFormCommandParam;
  nPriceStock : string;
begin
  if not IsDataValid then Exit;

  nPriceStock := EditStockName1.Text +':'+EditPrice1.Text;
  if Trim(EditStockName2.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName2.Text +':'+EditPrice2.Text;
  end;
  if Trim(EditStockName3.Text) <> '' then
  begin
    nPriceStock := nPriceStock +' '+ EditStockName3.Text +':'+EditPrice3.Text;
  end;
  if not SaveCustomerPayment(gInfo.FCusID, gInfo.FCusName,
     GetCtrlData(EditSalesMan), sFlag_MoneyHuiKuan, EditType.Text, EditDesc.Text,
     StrToFloat(EditMoney.Text),StrToFloatDef(EditPrice1.Text,0),nPriceStock, True) then
  begin
    ShowMsg('回款操作失败', sError); Exit;
  end;

  if StrToFloat(EditMoney.Text) > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    nP.FParamA := gInfo.FCusName;
    nP.FParamB := '销售回款或预付款';
    nP.FParamC := EditMoney.Text;
    CreateBaseFormItem(cFI_FormShouJu, '', @nP);
  end;
  //校正纸卡限提
  CheckZhiKaXTMoney;

  ModalResult := mrOk;
  ShowMsg('回款操作成功', sHint);
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
  {------- 修改参数令值更精确 -------}
  {小数点后的位置，需要的话也可以改动-2值}
  qianwei    := -2;
  {转换成货币形式，需要的话小数点后加多几个零}
  Smallmonth := formatfloat('0.00', small);
  {---------------------------------}
  dianweizhi := pos('.', Smallmonth);{小数点的位置}
  {循环小写货币的每一位，从小写的右边位置到左边}
  for qian := length(Smallmonth) downto 1 do
  begin
    {如果读到的不是小数点就继续}
    if qian <> dianweizhi then
    begin
      {位置上的数转换成大写}
      case StrToInt(Smallmonth[qian]) of
        1: wei1 := '壹';
        2: wei1 := '贰';
        3: wei1 := '叁';
        4: wei1 := '肆';
        5: wei1 := '伍';
        6: wei1 := '陆';
        7: wei1 := '柒';
        8: wei1 := '捌';
        9: wei1 := '玖';
        0: wei1 := '零';
      end;
      {判断大写位置，可以继续增大到real类型的最大值}
      case qianwei of
        -3: qianwei1 := '厘';
        -2: qianwei1 := '分';
        -1: qianwei1 := '角';
        0: qianwei1  := '元';
        1: qianwei1  := '拾';
        2: qianwei1  := '佰';
        3: qianwei1  := '仟';
        4: qianwei1  := '万';
        5: qianwei1  := '拾';
        6: qianwei1  := '佰';
        7: qianwei1  := '仟';
        8: qianwei1  := '亿';
        9: qianwei1  := '拾';
        10: qianwei1 := '佰';
        11: qianwei1 := '仟';
      end;
      inc(qianwei);
      BigMonth := wei1 + qianwei1 + BigMonth;{组合成大写金额}
    end;
  end;

  BigMonth := StringReplace(BigMonth, '零拾', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零佰', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零仟', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零亿', '亿', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零万', '万', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零元', '元', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '亿万', '亿', [rfReplaceAll]);
  BigMonth := BigMonth + '整';
  BigMonth := StringReplace(BigMonth, '分整', '分', [rfReplaceAll]);

  if BigMonth = '元整' then
    BigMonth := '零元整';
  if copy(BigMonth, 1, 2) = '元' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if copy(BigMonth, 1, 2) = '零' then
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
end;

initialization
  gControlManager.RegCtrl(TfFormPayment, TfFormPayment.FormID);
end.
