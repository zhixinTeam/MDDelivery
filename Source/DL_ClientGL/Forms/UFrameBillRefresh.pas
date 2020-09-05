{*******************************************************************************
  作者: dmzn@163.com 2009-6-22
  描述: 开提货单
*******************************************************************************}
unit UFrameBillRefresh;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox, ExtCtrls;

const
  WM_FrameTHActive   = WM_User + $0038;

type
  TfFrameBillRefresh = class(TfFrameNormal)
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    Timer1: TTimer;
    EditLID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCard: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxTextEdit5: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EditLIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure WMFrameTHActive(var nMsg: TMessage); message WM_FrameTHActive;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameBillRefresh.FrameID: integer;
begin
  Result := cFI_FrameBillRefresh;
end;

procedure TfFrameBillRefresh.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
  N12.Enabled := BtnEdit.Enabled;
  N14.Enabled := BtnEdit.Enabled;
  cxView1.OptionsSelection.MultiSelect := True;

  FStart := StrToDateTime(FormatDateTime('yyyy-MM-dd '+'00:00:00', Now));
end;

procedure TfFrameBillRefresh.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBillRefresh.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  {$IFDEF UseSelectDateTime}
  EditDate.Text := Format('%s 至 %s', [DateTime2Str(FStart), DateTime2Str(FEnd)]);
  {$ELSE}
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  {$ENDIF}

  {$IFDEF UseFreight}
  Result := ' Select distinct *,L_Value*L_Freight as TotalFreight,(L_MValue-L_PValue) as L_ValueEx,'+
            ' (L_MValue-L_PValue)*L_Price as L_Money From $Bill ';
  {$ELSE}
  Result := ' Select distinct * From $Bill ';
  {$ENDIF}
  //提货单

  {$IFDEF AlwaysUseDate}
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'' )';
    nStr := ' And ';
  {$ENDIF}

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  {$IFDEF UseSelectDateTime}
  Result := MacroValue(Result, [
            MI('$ST', DateTime2Str(FStart)), MI('$End', DateTime2Str(FEnd + 1))]);
  {$ELSE}
  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  {$ENDIF}
  Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBillRefresh.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBillRefresh.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: 执行查询
procedure TfFrameBillRefresh.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
end;

//Desc: 未开始提货的提货单
procedure TfFrameBillRefresh.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: 日期筛选
procedure TfFrameBillRefresh.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  {$IFDEF UseSelectDateTime}
  if ShowDateFilterForm(FStart, FEnd, True) then InitFormData('');
  {$ELSE}
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
  {$ENDIF}
  Timer1.Enabled := False;
end;

//Desc: 查询删除
procedure TfFrameBillRefresh.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBillRefresh.BtnAddClick(Sender: TObject);
begin
  //今日记录
  FStart := StrToDateTime(FormatDateTime('yyyy-MM-dd '+'00:00:00', Now));
  FEnd   := Now;
  InitFormData(FWhere);
  Timer1.Enabled := True;
end;

//Desc: 删除
procedure TfFrameBillRefresh.BtnDelClick(Sender: TObject);
var nStr, nID: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  with nP do
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    nStr := Format('请填写删除[ %s ]单据的原因', [nStr]);

    FCommand := cCmd_EditData;
    FParamA := nStr;
    FParamB := 320;
    FParamD := 2;

    nStr := SQLQuery.FieldByName('R_ID').AsString;
    FParamC := 'Update %s Set L_Memo=''$Memo'' Where R_ID=%s';
    FParamC := Format(FParamC, [sTable_Bill, nStr]);

    CreateBaseFormItem(cFI_FormMemo, '', @nP);
    if (FCommand <> cCmd_ModalResult) or (FParamA <> mrOK) then Exit;
  end;

  nID := SQLQuery.FieldByName('L_ID').AsString;

  if DeleteBill(nID) then
  begin
    GetCustomerValidMoney(SQLQuery.FieldByName('L_CusID').AsString);
    InitFormData(FWhere);
    ShowMsg('提货单已删除', sHint);
  end;
end;

//Desc: 打印提货单
procedure TfFrameBillRefresh.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBillRefresh.PMenu1Popup(Sender: TObject);
begin
end;

//Desc: 修改未进厂车牌号
procedure TfFrameBillRefresh.N5Click(Sender: TObject);
begin
end;

//Desc: 修改封签号
procedure TfFrameBillRefresh.N7Click(Sender: TObject);
begin
end;

//Desc: 调拨提货单
procedure TfFrameBillRefresh.BtnEditClick(Sender: TObject);
begin
  inherited;
  //本月记录
  FStart := StrToDateTime(FormatDateTime('yyyy-MM-01 '+'00:00:00', Now));
  FEnd   := Now;
  InitFormData(FWhere);
  Timer1.Enabled := True;  
end;

procedure TfFrameBillRefresh.Timer1Timer(Sender: TObject);
begin
  inherited;
  BtnRefreshClick(nil);
end;

procedure TfFrameBillRefresh.WMFrameTHActive(var nMsg: TMessage);
begin
  case nMsg.WParam of
    1:
    begin
      Timer1.Enabled := False;
    end;
    2:
    begin
      Timer1.Enabled := True;
    end;
  end;
end;

procedure TfFrameBillRefresh.EditLIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //定时关闭
  Timer1.Enabled := False;

  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCard then
  begin
    EditCard.Text := Trim(EditCard.Text);
    if EditCard.Text = '' then Exit;

    FUseDate := Length(EditCard.Text) <= 3;
    FWhere := Format('L_Truck like ''%%%s%%''', [EditCard.Text]);
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBillRefresh, TfFrameBillRefresh.FrameID);
end.
