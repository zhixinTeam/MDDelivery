{*******************************************************************************
  作者: dmzn@163.com 2017-07-02
  描述: 磅房无人值守时,散装预合卡
*******************************************************************************}
unit UFrameBillHK;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxCheckBox, cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameBillHK = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N2: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameBillHK.FrameID: integer;
begin
  Result := cFI_FrameSanPreHK;
end;

procedure TfFrameBillHK.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameBillHK.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBillHK.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select h.*,h.R_ID as H_ID,' +
            '(Select L_Value from $Bill where L_ID=h.H_HKBill) as H_HKValue,' +
            '(select L_Date from $Bill where L_ID=h.H_HKBill) as H_HKDate,' +
            'cus.C_Name as Z_CusName,sm.S_Name as Z_SMName,' +
            'b.*,z.* From $HK h ' +
            ' Left Join $ZK z on z.Z_ID=h.H_ZhiKa ' +
            ' Left Join $Cus cus on cus.C_ID=z.Z_Customer ' +
            ' Left Join $SM sm on sm.S_ID=z.Z_SaleMan ' +
            ' Left Join $Bill b on b.L_ID=h.H_Bill ';
  //xxxxx

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (H_Date>=''$ST'' and H_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [MI('$HK', sTable_BillHK),
            MI('$Bill', sTable_Bill), MI('$ZK', sTable_ZhiKa),
            MI('$Cus', sTable_Customer), MI('$SM', sTable_Salesman),
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

procedure TfFrameBillHK.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: 执行查询
procedure TfFrameBillHK.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'b.L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'b.L_CusPY like ''%%%s%%'' Or b.L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCard then
  begin
    EditCard.Text := Trim(EditCard.Text);
    if EditCard.Text = '' then Exit;

    FUseDate := Length(EditCard.Text) <= 3;
    FWhere := Format('b.L_Truck like ''%%%s%%''', [EditCard.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 未开始提货的提货单
procedure TfFrameBillHK.N1Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(b.L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'b.L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameBillHK.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBillHK.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormSanPreHK, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBillHK.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  if SQLQuery.FieldByName('H_HKValue').AsInteger > 0 then
  begin
    ShowMsg('不能删除已合卡记录', sHint); Exit;
  end;

  nStr := '确定要删除单据[ %s ]的合卡记录吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'Delete From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_BillHK, SQLQuery.FieldByName('H_ID').AsString]);
  FDM.ExecuteSQL(nStr);

  InitFormData(FWhere);
  ShowMsg('合卡记录已删除', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFrameBillHK, TfFrameBillHK.FrameID);
end.
