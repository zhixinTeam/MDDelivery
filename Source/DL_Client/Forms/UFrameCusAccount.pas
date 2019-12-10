{*******************************************************************************
  作者: dmzn@163.com 2009-09-04
  描述: 客户账户查询
*******************************************************************************}
unit UFrameCusAccount;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameCusAccount = class(TfFrameNormal)
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    EditID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    procedure N3Click(Sender: TObject);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, USysBusiness,
  UFormInputbox, Dialogs;

class function TfFrameCusAccount.FrameID: integer;
begin
  Result := cFI_FrameCusAccountQuery;
end;

function TfFrameCusAccount.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select ca.*,cus.*,S_Name as C_SaleName,' +
            '(A_InitMoney + A_InMoney-A_OutMoney-A_Compensation-A_FreezeMoney) As A_YuE ' +
            'From $CA ca ' +
            ' Left Join $Cus cus On cus.C_ID=ca.A_CID ' +
            ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ';
  //xxxxx

  if nWhere = '' then
       Result := Result + 'Where IsNull(C_XuNi, '''')<>''$Yes'''
  else Result := Result + 'Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$CA', sTable_CusAccount),
            MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
            MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: 执行查询  
procedure TfFrameCusAccount.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := Format('C_ID like ''%%%s%%''', [EditID.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'C_PY like ''%%%s%%'' Or C_Name like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end
end;

//------------------------------------------------------------------------------
procedure TfFrameCusAccount.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N4.Visible := True;
  {$ELSE}
  N4.Visible := False;
  {$ENDIF}
  N6.Enabled := gSysParam.FIsAdmin;
end;

//Desc: 快捷菜单
procedure TfFrameCusAccount.N3Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('C_XuNi=''%s''', [sFlag_Yes]);
   20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameCusAccount.N4Click(Sender: TObject);
var nStr: string;
    nVal,nCredit: Double;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('A_CID').AsString;
    nVal := GetCustomerValidMoney(nStr, False, @nCredit);

    nStr := '客户当前可用金额如下:' + #13#10#13#10 +
            '*.客户名称: %s ' + #13#10 +
            '*.资金余额: %.2f 元' + #13#10 +
            '*.信用金额: %.2f 元' + #13#10;
    nStr := Format(nStr, [SQLQuery.FieldByName('C_Name').AsString, nVal, nCredit]);
    ShowDlg(nStr, sHint);
  end;
end;

//Desc: 校正客户资金
procedure TfFrameCusAccount.N6Click(Sender: TObject);
var nStr,nCID: string;
    nVal: Double;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;
  
  //校正出金
  nStr := ' update Sys_CustomerAccount set A_OutMoney = L_Money From( ' +
    ' Select Sum(L_Money) L_Money, L_CusID from ( ' +
    ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID from S_Bill ' +
    ' where L_OutFact Is not Null ) t Group by L_CusID) b where A_CID = b.L_CusID ';
  FDM.ExecuteSQL(nStr);

  //校正冻结资金
  nStr := ' update Sys_CustomerAccount set A_FreezeMoney = L_Money From( ' +
    ' Select Sum(L_Money) L_Money, L_CusID from ( ' +
    ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID from S_Bill ' +
    ' where L_OutFact Is  Null ) t Group by L_CusID) b where A_CID = b.L_CusID ';
  FDM.ExecuteSQL(nStr);

  //校正冻结资金
  nStr := ' update Sys_CustomerAccount set A_FreezeMoney = 0  where ' +
    ' A_CID  not in (select L_CusID from S_Bill    ' +
    ' where L_OutFact Is Null Group by L_CusID ) ';
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('校正完毕', sHint);

//  if cxView1.DataController.GetSelectedCount < 1 then Exit;
//  nCID := SQLQuery.FieldByName('A_CID').AsString;
//
//  nStr := 'Select Sum(L_Money) from (' +
//          '  select L_Value * L_Price as L_Money from %s' +
//          '  where L_OutFact Is not Null And L_CusID = ''%s'') t';
//  nStr := Format(nStr, [sTable_Bill, nCID]);
//
//  with FDM.QuerySQL(nStr) do
//  begin
//    nVal := Float2Float(Fields[0].AsFloat, cPrecision, True);
//    nStr := 'Update %s Set A_OutMoney=%.2f Where A_CID=''%s''';
//    nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
//    FDM.ExecuteSQL(nStr);
//  end;
//
//  nStr := 'Select Sum(L_Money) from (' +
//          '  select L_Value * L_Price as L_Money from %s' +
//          '  where L_OutFact Is Null And L_CusID = ''%s'') t';
//  nStr := Format(nStr, [sTable_Bill, nCID]);
//
//  with FDM.QuerySQL(nStr) do
//  begin
//    nVal := Float2Float(Fields[0].AsFloat, cPrecision, True);
//    nStr := 'Update %s Set A_FreezeMoney=%.2f Where A_CID=''%s''';
//    nStr := Format(nStr, [sTable_CusAccount, nVal, nCID]);
//    FDM.ExecuteSQL(nStr);
//  end;
//
//  InitFormData(FWhere);
//  ShowMsg('校正完毕', sHint);
end;

procedure TfFrameCusAccount.N7Click(Sender: TObject);
var
  nCID, nStr: string;
  nMoney: Double;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;
  nCID := SQLQuery.FieldByName('A_CID').AsString;

  if not ShowInputBox('请输入客户起初金额:', '提示', nStr) then Exit;
  nStr := Trim(nStr);

  if nStr = '' then
  begin
    showmessage('请输入起初金额.');
    Exit;
  end;

  if not IsNumber(nStr, True) then
  begin
    showmessage('请输入有效的起初金额.');
    Exit;
  end;

  nMoney := StrToFloat(nStr);

  nStr := 'update %s set A_InitMoney=%.2f where A_CID=''%s''';
  nStr := Format(nStr,[sTable_CusAccount,nMoney,nCID]);
  FDM.ExecuteSQL(nStr);

  nStr := '修改客户['+nCID+']起初金额为:'+floattostr(nMoney);
  FDM.WriteSysLog(sFlag_CommonItem, nCID, nStr);

  InitFormData(FWhere);
  ShowMsg('修改成功.', sHint);
end;

procedure TfFrameCusAccount.N8Click(Sender: TObject);
var
  nCID, nStr: string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then Exit;
  nCID := SQLQuery.FieldByName('A_CID').AsString;
  
  nStr := ' update %s set A_CreditLimit = 0 where A_CID=''%s''';
  nStr := Format(nStr,[sTable_CusAccount,nCID]);
  FDM.ExecuteSQL(nStr);

  nStr := '清除客户['+nCID+']信用金额为:'+floattostr(0);
  FDM.WriteSysLog(sFlag_CommonItem, nCID, nStr);

  CheckZhiKaXTMoney;
  InitFormData(FWhere);
  ShowMsg('修改成功.', sHint);
end;

procedure TfFrameCusAccount.N9Click(Sender: TObject);
begin
  inherited;
  CheckZhiKaXTMoney;
  ShowMsg('校正完毕', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFrameCusAccount, TfFrameCusAccount.FrameID);
end.
