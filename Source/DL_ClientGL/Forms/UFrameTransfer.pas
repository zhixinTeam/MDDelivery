{*******************************************************************************
  作者: fendou116688@163.com 2016-06-02
  描述: 开短倒单
*******************************************************************************}
unit UFrameTransfer;

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
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter;

type
  TfFrameTransfer = class(TfFrameNormal)
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    N2: TMenuItem;
    N1: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
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
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, UFormInputbox,
  UFormDateFilter, USysPopedom, USysConst, USysDB, USysBusiness;

//------------------------------------------------------------------------------
class function TfFrameTransfer.FrameID: integer;
begin
  Result := cFI_FrameTransBase;
end;

procedure TfFrameTransfer.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameTransfer.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameTransfer.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select * From $DD ';

  if (nWhere = '') or FUseDate then
  begin
    if CheckDelete.Checked then
         Result := Result + 'Where (B_DelDate>=''$ST'' and B_DelDate <''$End'')'
    else Result := Result + 'Where (B_Date>=''$ST'' and B_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$DD', sTable_TransBaseBak)])
  else Result := MacroValue(Result, [MI('$DD', sTable_TransBase)]);
end;

procedure TfFrameTransfer.AfterInitFormData;
begin
  FUseDate := True;
end;

//Desc: 执行查询
procedure TfFrameTransfer.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'B_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('B_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 日期筛选
procedure TfFrameTransfer.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: 查询删除
procedure TfFrameTransfer.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameTransfer.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormTransBase, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameTransfer.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := '确定要删除编号为[ %s ]的单据吗?';
  nStr := Format(nStr, [SQLQuery.FieldByName('B_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  if DeleteDDBase(SQLQuery.FieldByName('B_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('短倒基础单已删除', sHint);
  end;
end;

//注销磁卡
procedure TfFrameTransfer.N1Click(Sender: TObject);
begin
  inherited;
  //
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    LogoutDDCard(SQLQuery.FieldByName('B_Card').AsString);
    InitFormData(FWhere);
  end;
end;

//办理磁卡
procedure TfFrameTransfer.N2Click(Sender: TObject);
begin
  inherited;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    {$IFDEF TransferRFID}
    nP.FParamA := Trim(SQLQuery.FieldByName('B_Truck').AsString);
    CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    if SaveDDCard(SQLQuery.FieldByName('B_ID').AsString, 'H' + nP.FParamB) then
      ShowMsg('办理磁卡成功', sHint);
    {$ELSE}
    if SetDDCard(SQLQuery.FieldByName('B_ID').AsString,
      SQLQuery.FieldByName('B_Truck').AsString, True) then
      ShowMsg('办理磁卡成功', sHint);
    //办理磁卡
    {$ENDIF}

    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameTransfer, TfFrameTransfer.FrameID);
end.
