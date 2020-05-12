{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFormPayingUnit;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormPayingUnit = class(TfFormNormal)
    EditPayingUnit: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditSalesMan: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    EditName: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditSalesManPropertiesChange(Sender: TObject);
    procedure EditNamePropertiesEditValueChanged(Sender: TObject);
  protected
    { Protected declarations }
    FName: string;
    procedure LoadFormData(const nID: string);
    procedure InitFormData(const nID: string);
    //载入数据
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst,
  USysBusiness, UAdjustForm, DB, cxMCListBox;

type
  TCommonInfo = record
    FCusID: string;
    FCusName: string;
    FSaleMan: string;
  end;

var
  gInfo: TCommonInfo;
  //全局使用

class function TfFormPayingUnit.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormPayingUnit.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '交款单位 - 添加';
      FName := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '交款单位 - 修改';
      FName := nP.FParamA;
    end;

    LoadFormData(FName);
    InitFormData('');
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPayingUnit.FormID: integer;
begin
  Result := cFI_FormPayingUnit;
end;

procedure TfFormPayingUnit.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_PayingUnit, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      Exit;
    end;
    
  end;
end;

//Desc: 保存
procedure TfFormPayingUnit.BtnOKClick(Sender: TObject);
var nStr,nName,nPinYin,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  //保存交货单位信息
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

  ModalResult := mrOk;
  ShowMsg('交款单位保存成功', sHint);
end;

procedure TfFormPayingUnit.InitFormData(const nID: string);
var
  nStr : string;
begin
  FillChar(gInfo, SizeOf(gInfo), #0);
  LoadSaleMan(EditSalesMan.Properties.Items);
end;

procedure TfFormPayingUnit.EditSalesManPropertiesChange(Sender: TObject);
var nStr: string;
begin
  if EditSalesMan.ItemIndex > -1 then
  begin
    nStr := Format('C_SaleMan=''%s''', [GetCtrlData(EditSalesMan)]);
    LoadCustomer(EditName.Properties.Items, nStr);
  end;
end;

procedure TfFormPayingUnit.EditNamePropertiesEditValueChanged(
  Sender: TObject);
begin
  if (EditName.ItemIndex > -1) and EditName.Focused then
    LoadCustomerInfo(GetCtrlData(EditName));
  //xxxxx
end;

function TfFormPayingUnit.LoadCustomerInfo(const nID: string): Boolean;
var nStr: string;
begin
  try
    nStr := 'Select cus.*,S_Name as C_SaleName From $Cus cus ' +
            ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ' +
            'Where C_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer), MI('$ID', nID),
            MI('$SM', sTable_Salesman)]);
    //xxxxx
    with FDM.QueryTemp(nStr),gInfo do
    begin
      FCusID := nID;
      FCusName := FieldByName('C_Name').AsString;
      FSaleMan := FieldByName('C_SaleMan').AsString;
    end;
    
    SetCtrlData(EditSalesMan, gInfo.FSaleMan);

    if GetStringsItemIndex(EditName.Properties.Items, nID) < 0 then
    begin
      nStr := Format('%s=%s.%s', [nID, nID, gInfo.FCusName]);
      InsertStringsItem(EditName.Properties.Items, nStr);
    end;
      SetCtrlData(EditName, nID);

  finally
    ActiveControl := EditPayingUnit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPayingUnit, TfFormPayingUnit.FormID);
end.
