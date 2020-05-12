{*******************************************************************************
  作者: dmzn@163.com 2012-03-31
  描述: 称重查询
*******************************************************************************}
unit UFramePoundQueryKS;

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
  TfFramePoundQueryKS = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    EditCus: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N3: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    CheckDelete: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    N4: TMenuItem;
    N5: TMenuItem;
    EditPID: TcxButtonEdit;
    dxLayout1Item9: TdxLayoutItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N6: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
  private
    FNum1,Fnum2,FNum3: Double;
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
    function GetVal(const nRow: Integer; const nField: string): string;
    //获取指定字段
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ShellAPI, ULibFun, UMgrControl, UDataModule, USysBusiness, UFormDateFilter,
  UFormBase, UFormWait, USysConst, USysDB;

class function TfFramePoundQueryKS.FrameID: integer;
begin
  Result := cFI_FramePoundQueryKS;
end;

procedure TfFramePoundQueryKS.OnCreateFrame;
var
  nStr : string;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);

  nStr := 'Select * From %s ';
  nStr := Format(nStr, [sTable_KSKD]);
  FDM.QueryTemp(nStr);
  with FDM.SqlTemp do
  begin
    if (RecordCount < 1) then
    begin
      FNum1 := 0;
      FNum2 := 0;
      FNum3 := 0;
    end
    else
    begin
      FNum1 := FieldByName('P_Num1').AsFloat;
      FNum2 := FieldByName('P_Num2').AsFloat;
      FNum3 := FieldByName('P_Num3').AsFloat;
    end;
  end;
  cxView1.OptionsSelection.MultiSelect := True;
end;

procedure TfFramePoundQueryKS.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 获取nRow行nField字段的内容
function TfFramePoundQueryKS.GetVal(const nRow: Integer;
 const nField: string): string;
var nVal: Variant;
begin
  nVal := cxView1.ViewData.Rows[nRow].Values[
            cxView1.GetColumnByFieldName(nField).Index];
  //xxxxx

  if VarIsNull(nVal) then
       Result := ''
  else Result := nVal;
end;

function TfFramePoundQueryKS.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  //启用备份数据库

  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  if FNum1 > 0 then
  begin
    Result := ' Select pl.*,' +
              ' (P_MValue-P_PValue) As P_NetWeight,'+
              ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = pl.P_MID) = ''Y'' then ' +
              ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then P_PValue+'+Floattostr(FNum2)+
              ' else (P_MValue-'+Floattostr(FNum3)+') end) '+
              ' else (P_MValue-isnull(P_KZValue,0)) end P_MValueEx,  '+
              ' case When isnull(P_KZValue,0) = 0 then ''否'' else ''是'' end IsKZ, '+
              ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = pl.P_MID) = ''Y'' then ' +
              ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then '+Floattostr(FNum2)+
              ' else (P_MValue-P_PValue-'+Floattostr(FNum3)+') end) '+
              ' else (P_MValue-P_PValue-isnull(P_KZValue,0)) end P_NetWeightEx,  '+
              ' ABS((P_MValue-P_PValue)-P_LimValue) As P_Wucha, '+
              ' (Select D_KD from P_OrderDtl where D_ID = pl.P_Order) as D_KD, '+
              ' (Select D_SerialNo from P_OrderDtl where D_ID = pl.P_Order) as D_SerialNo From $PL pl';
  end
  else
  begin
    Result := ' Select pl.*,(P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeightEx,' +
              ' (P_MValue-P_PValue) As P_NetWeight,'+
              ' (P_MValue - isnull(P_KZValue,0)) as P_MValueEx, ' +
              ' case When isnull(P_KZValue,0) = 0 then ''否'' else ''是'' end IsKZ, '+
              ' ABS((P_MValue-P_PValue)-P_LimValue) As P_Wucha, '+
              ' (Select D_KD from P_OrderDtl where D_ID = pl.P_Order) as D_KD, '+
              ' (Select D_SerialNo from P_OrderDtl where D_ID = pl.P_Order) as D_SerialNo From $PL pl';  
  end;
  //xxxxx

  if FJBWhere = '' then
  begin
    Result := Result + ' Where (P_PDate >=''$S'' and P_PDate<''$E'') ' +
              ' and (isnull(P_IsKS,''N'') = ''Y'') and (P_Type = ''P'') ';
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ') and (isnull(P_IsKS,''N'') = ''Y'') and (P_Type = ''P'') ';
  end;

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$PL', sTable_PoundBak)])
  else Result := MacroValue(Result, [MI('$PL', sTable_PoundLog)]);

  Result := MacroValue(Result, [MI('$S', Date2Str(FStart)),
            MI('$E', Date2Str(FEnd+1))]);
  //xxxxx

  if nWhere <> '' then
    Result := Result + ' And (' + nWhere + ')';
  //xxxxx
end;

procedure TfFramePoundQueryKS.AfterInitFormData;
begin
  FJBWhere := '';
end;

//Desc: 日期筛选
procedure TfFramePoundQueryKS.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFramePoundQueryKS.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditPID then
  begin
    EditPID.Text := Trim(EditPID.Text);
    if EditPID.Text = '' then Exit;

    if Length(EditPID.Text) <= 3 then
    begin
      FWhere := 'P_ID like ''%%%s%%''';
      FWhere := Format(FWhere, [EditPID.Text]);
    end else
    begin
      FWhere := '';
      FJBWhere := 'P_ID like ''%%%s%%''';
      FJBWhere := Format(FJBWhere, [EditPID.Text]);
    end;
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'P_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'P_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFramePoundQueryKS.CheckDeleteClick(Sender: TObject);
begin
  BtnRefresh.Click;
end;

//------------------------------------------------------------------------------
//Desc: 权限控制
procedure TfFramePoundQueryKS.PMenu1Popup(Sender: TObject);
begin
  N3.Enabled := BtnPrint.Enabled and (not CheckDelete.Checked);
end;

//Desc: 打印磅单
procedure TfFramePoundQueryKS.N3Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    if SQLQuery.FieldByName('P_PValue').AsFloat = 0 then
    begin
      ShowMsg('请先称量皮重', sHint); Exit;
    end;

    nStr := SQLQuery.FieldByName('P_ID').AsString;
    PrintPoundReportKS(nStr, False);
  end
end;

//Desc: 时间段查询
procedure TfFramePoundQueryKS.N2Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    case TComponent(Sender).Tag of
     10: FJBWhere := 'P_PDate>=''$S'' And P_PDate<''$E''';
     20: FJBWhere := 'P_MDate>=''$S'' And P_MDate<''$E''';
     30: FJBWhere := '(P_PDate>=''$S'' And P_PDate<''$E'') Or ' +
                     '(P_MDate>=''$S'' And P_MDate<''$E'')';
     //xxxxx
    end;

    FJBWhere := MacroValue(FJBWhere, [MI('$S', DateTime2Str(FTimeS)),
                MI('$E', DateTime2Str(FTimeE))]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: 删除榜单
procedure TfFramePoundQueryKS.BtnDelClick(Sender: TObject);
var nIdx: Integer;
    nStr,nID,nP: string;
    nParm: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('P_ID').AsString;
  with nParm do
  begin
    FCommand := cCmd_EditData;
    FParamA := Format('请填写删除[ %s ]磅单的原因', [nID]);
    FParamB := 320;
    FParamD := 2;

    nStr := SQLQuery.FieldByName('R_ID').AsString;
    FParamC := 'Update %s Set P_Memo=''$Memo'' Where R_ID=%s';
    FParamC := Format(FParamC, [sTable_PoundLog, nStr]);

    CreateBaseFormItem(cFI_FormMemo, '', @nParm);
    if (FCommand <> cCmd_ModalResult) or (FParamA <> mrOK) then Exit;
  end;

  nStr := Format('Select * From %s Where 1<>1', [sTable_PoundLog]);
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
            'Select $FL,''$User'',$Now From $PL Where P_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$PB', sTable_PoundBak),
            MI('$FL', nP), MI('$User', gSysParam.FUserID),
            MI('$Now', sField_SQLServer_Now),
            MI('$PL', sTable_PoundLog), MI('$ID', nID)]);
    FDM.ExecuteSQL(nStr);
    
    nStr := 'Delete From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nID]);
    FDM.ExecuteSQL(nStr);

    FDM.ADOConn.CommitTrans;
    InitFormData(FWhere);
    ShowMsg('删除完毕', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除失败', sError);
  end;
end;

//Desc: 查看抓拍
procedure TfFramePoundQueryKS.N4Click(Sender: TObject);
var nStr,nID,nDir: string;
    nPic: TPicture;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要查看的记录', sHint);
    Exit;
  end;

  nID := SQLQuery.FieldByName('P_ID').AsString;
  nDir := gSysParam.FPicPath + nID + '\';

  if DirectoryExists(nDir) then
  begin
    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    Exit;
  end else ForceDirectories(nDir);

  nPic := nil;
  nStr := 'Select * From %s Where P_ID=''%s''';
  nStr := Format(nStr, [sTable_Picture, nID]);

  ShowWaitForm(ParentForm, '读取图片', True);
  try
    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('本次称重无抓拍', sHint);
        Exit;
      end;

      nPic := TPicture.Create;
      First;

      While not eof do
      begin
        nStr := nDir + Format('%s_%s.jpg', [FieldByName('P_ID').AsString,
                FieldByName('R_ID').AsString]);
        //xxxxx

        FDM.LoadDBImage(FDM.SqlTemp, 'P_Picture', nPic);
        nPic.SaveToFile(nStr);
        Next;
      end;
    end;

    ShellExecute(GetDesktopWindow, 'open', PChar(nDir), nil, nil, SW_SHOWNORMAL);
    //open dir
  finally
    nPic.Free;
    CloseWaitForm;
    FDM.SqlTemp.Close;
  end;
end;

procedure TfFramePoundQueryKS.N6Click(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nList := TStringList.Create;
  try
    for nIdx := 0 to cxView1.DataController.RowCount - 1  do
    begin

      nStr := GetVal(nIdx,'P_ID');
      if nStr = '' then
        Continue;

      if GetVal(nIdx,'P_PValue') = '' then
      begin
        ShowMsg(nStr + '未一次过磅,无法批量打印', sHint); Exit;
      end;

      nList.Add(nStr);
    end;

    nStr := AdjustListStrFormat2(nList, '''', True, ',', False);
    PrintPoundReportKS(nStr, False, True);
  finally
    nList.Free;
  end;
end;

procedure TfFramePoundQueryKS.cxView1DblClick(Sender: TObject);
var nStr: string;
    nP: TFormCommandParam;
begin
  if (not CheckDelete.Checked) or
     (cxView1.DataController.GetSelectedCount < 1) then Exit;
  //只修改删除记录的备注信息

  with nP do
  begin
    FCommand := cCmd_EditData;
    FParamA := SQLQuery.FieldByName('P_Memo').AsString;
    FParamB := 320;
    FParamD := 2;

    nStr := SQLQuery.FieldByName('R_ID').AsString;
    FParamC := 'Update %s Set P_Memo=''$Memo'' Where R_ID=%s';
    FParamC := Format(nP.FParamC, [sTable_PoundBak, nStr]);

    CreateBaseFormItem(cFI_FormMemo, '', @nP);
    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
      InitFormData(FWhere);
    //display
  end;
end;

procedure TfFramePoundQueryKS.N10Click(Sender: TObject);
var
  nID   : string;
  nList : TStrings;
  nP: TFormCommandParam;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要磅房二次扣重的记录', sHint);
    Exit;
  end;
  if (Trim(SQLQuery.FieldByName('P_TYPE').AsString) <> 'P') then
  begin
    ShowMsg('不是采购业务', sHint);
    Exit;
  end;
  
  nID := SQLQuery.FieldByName('P_ID').AsString;

  nList := TStringList.Create;
  try
    nList.Add(nID);

    nP.FCommand := cCmd_EditData;
    nP.FParamA := nList.Text;
    CreateBaseFormItem(cFI_FormPoundTwoKZ, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;

  finally
    nList.Free;
  end;
end;

procedure TfFramePoundQueryKS.N11Click(Sender: TObject);
var
  i : Integer;
  nValue: Double;
  nStr,nLID:   string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要审核的记录', sHint);
    Exit;
  end;
  if not QueryDlg('确定要对选中的所有记录进行审核嘛？', sAsk) then Exit;
  with cxView1.Controller do
  begin
    for i := 0 to SelectedRowCount - 1   do
    begin
      SelectedRows[i].Focused := True;
      if (Trim(SQLQuery.FieldByName('P_TYPE').AsString) <> 'P') then
      begin
        if SelectedRowCount = 1 then
        begin
          ShowMsg('不是采购订单,无需审核', sHint);
          Exit;
        end
        else
          Continue;
      end;

      nLID := SQLQuery.FieldByName('R_ID').AsString;
      nStr := 'Update %s Set P_TwoState=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_PoundLog, sFlag_Yes, nLID]);

      FDM.ExecuteSQL(nStr);
    end;
  end;
  ShowMsg('审核成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFramePoundQueryKS, TfFramePoundQueryKS.FrameID);
end.
