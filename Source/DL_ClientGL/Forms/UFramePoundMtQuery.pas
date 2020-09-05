{*******************************************************************************
  作者: juner11212436@163.com 2017-08-20
  描述: 码头抓斗秤称重查询
*******************************************************************************}
unit UFramePoundMtQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxCheckBox, cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFramePoundMtQuery = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    Check1: TcxCheckBox;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Check1Click(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班查询
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure AfterInitFormData; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ShellAPI, ULibFun, UMgrControl, UDataModule, USysBusiness, UFormDateFilter,
  UFormBase, UFormWait, USysConst, USysDB, USysPopedom;

class function TfFramePoundMtQuery.FrameID: integer;
begin
  Result := cFI_FramePoundMtQuery;
end;

procedure TfFramePoundMtQuery.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now+1) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePoundMtQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFramePoundMtQuery.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select pl.* From $PL pl';
  //xxxxx

  if FJBWhere = '' then
  begin
    Result := Result + ' Where (G_WeightTime >=''$S'' and G_WeightTime<''$E'') ';
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if Check1.Checked then
       Result := MacroValue(Result, [MI('$PL', sTable_GrabBak)])
  else Result := MacroValue(Result, [MI('$PL', sTable_Grab)]);

  Result := MacroValue(Result, [MI('$S', Date2Str(FStart)),
            MI('$E', Date2Str(FEnd+1))]);
  //xxxxx

  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  //xxxxx
end;

procedure TfFramePoundMtQuery.AfterInitFormData;
begin
  FJBWhere := '';
end;

//Desc: 日期筛选
procedure TfFramePoundMtQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFramePoundMtQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'G_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'G_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 删除榜单
procedure TfFramePoundMtQuery.BtnDelClick(Sender: TObject);
var nIdx: Integer;
    nStr,nID,nP: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('Rec_ID').AsString;
  nStr := Format('确定要删除流水号为[ %s ]的抓斗秤称重记录吗?', [nID]);
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := Format('Select * From %s Where 1<>1', [sTable_Grab]);
  //only for fields
  nP := '';

  with FDM.QueryTemp(nStr) do
  begin
    for nIdx:=0 to FieldCount - 1 do
    if (Fields[nIdx].DataType <> ftAutoInc) and
       (Pos('P_Del', Fields[nIdx].FieldName) < 1) then
      nP := nP + Fields[nIdx].FieldName + ',';
    //所有字段,不包括删除
    System.Delete(nP, Length(nP), 1);
  end;

  FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into $PB($FL,P_DelMan,P_DelDate) ' +
            'Select $FL,''$User'',$Now From $PL Where Rec_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$PB', sTable_GrabBak),
            MI('$FL', nP), MI('$User', gSysParam.FUserID),
            MI('$Now', sField_SQLServer_Now),
            MI('$PL', sTable_Grab), MI('$ID', nID)]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Delete From %s Where Rec_ID=''%s''';
    nStr := Format(nStr, [sTable_Grab, nID]);
    FDM.ExecuteSQL(nStr);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('删除完毕', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除失败', sError);
  end;
end;

procedure TfFramePoundMtQuery.Check1Click(Sender: TObject);
begin
  BtnRefresh.Click;
end;

initialization
  gControlManager.RegCtrl(TfFramePoundMtQuery, TfFramePoundMtQuery.FrameID);
end.
