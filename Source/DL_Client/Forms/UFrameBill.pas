{*******************************************************************************
  作者: dmzn@163.com 2009-6-22
  描述: 开提货单
*******************************************************************************}
unit UFrameBill;

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
  cxCheckBox;

type
  TfFrameBill = class(TfFrameNormal)
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
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
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
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter;

//------------------------------------------------------------------------------
class function TfFrameBill.FrameID: integer;
begin
  Result := cFI_FrameBill;
end;

procedure TfFrameBill.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
  N12.Enabled := BtnEdit.Enabled;
  N14.Enabled := BtnEdit.Enabled;
  cxView1.OptionsSelection.MultiSelect := True;
end;

procedure TfFrameBill.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: 数据查询SQL
function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  {$IFDEF UseSelectDateTime}
  EditDate.Text := Format('%s 至 %s', [DateTime2Str(FStart), DateTime2Str(FEnd)]);
  {$ELSE}
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  {$ENDIF}

  {$IFDEF UseFreight}
  Result := 'Select distinct *,L_Value*L_Freight as TotalFreight From $Bill ';
  {$ELSE}
  Result := 'Select distinct * From $Bill ';
  {$ENDIF}
  //提货单

  {$IFDEF AlwaysUseDate}
  if CheckDelete.Checked then
    Result := Result + 'Where (L_DelDate>=''$ST'' and L_DelDate <''$End'')'
  else
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
  nStr := ' And ';
  {$ELSE}
  if (nWhere = '') or FUseDate then
  begin
    if CheckDelete.Checked then
      Result := Result + 'Where (L_DelDate>=''$ST'' and L_DelDate <''$End'')'
    else
      Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';
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

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$Bill', sTable_BillBak)])
  else Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBill.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: 执行查询
procedure TfFrameBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
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

//Desc: 未开始提货的提货单
procedure TfFrameBill.N4Click(Sender: TObject);
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
procedure TfFrameBill.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  {$IFDEF UseSelectDateTime}
  if ShowDateFilterForm(FStart, FEnd, True) then InitFormData('');
  {$ELSE}
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
  {$ENDIF}
end;

//Desc: 查询删除
procedure TfFrameBill.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: 开提货单
procedure TfFrameBill.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormBill, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 删除
procedure TfFrameBill.BtnDelClick(Sender: TObject);
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

//  try
//    SaveWebOrderDelMsg(nID,sFlag_Sale);
//  except
//    ShowMsg('插入微信端消息推送失败.',sHint);
//    Exit;
//  end;
  //插入删除推送
end;

//Desc: 打印提货单
procedure TfFrameBill.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBill.PMenu1Popup(Sender: TObject);
begin
  N3.Enabled := gPopedomManager.HasPopedom(PopedomItem, sPopedom_Edit);
  //销售调拨

  {$IFDEF DYGL}
  N10.Visible := True;
  N11.Visible := True;
  //打印预提单和过路费
  {$ENDIF}
end;

//Desc: 修改未进厂车牌号
procedure TfFrameBill.N5Click(Sender: TObject);
var nStr,nTruck: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    {$IFDEF ForceMemo}
    with nP do
    begin
      nStr := SQLQuery.FieldByName('L_ID').AsString;
      nStr := Format('请填写修改[ %s ]单据车牌号的原因', [nStr]);

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
    {$ENDIF}

    nStr := SQLQuery.FieldByName('L_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('请输入新的车牌号码:', '修改', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //无效或一致

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      nStr := 'Update %s Set T_Truck = ''%s'' Where T_Truck = ''%s''';
      nStr := Format(nStr, [sTable_Truck,nTruck,SQLQuery.FieldByName('L_Truck').AsString]);
      FDM.ExecuteSQL(nStr);

      nStr := '修改车牌号[ %s -> %s ].';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_Truck').AsString, nTruck]);
      FDM.WriteSysLog(sFlag_BillItem, SQLQuery.FieldByName('L_ID').AsString, nStr, False);

      InitFormData(FWhere);
      ShowMsg('车牌号修改成功', sHint);
    end;
  end;
end;

//Desc: 修改封签号
procedure TfFrameBill.N7Click(Sender: TObject);
var nStr,nID,nSeal,nSave: string;
    nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    {$IFDEF ForceMemo}
    with nP do
    begin
      nStr := SQLQuery.FieldByName('L_ID').AsString;
      nStr := Format('请填写修改[ %s ]单据封签号的原因', [nStr]);

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
    {$ENDIF}

    {$IFDEF BatchInHYOfBill}
    nSave := 'L_HYDan';
    {$ELSE}
    nSave := 'L_Seal';
    {$ENDIF}

    nStr := SQLQuery.FieldByName(nSave).AsString;
    nSeal := nStr;
    if not ShowInputBox('请输入新的封签编号:', '修改', nSeal, 100) then Exit;

    if (nSeal = '') or (nStr = nSeal) then Exit;
    //无效或一致
    nID := SQLQuery.FieldByName('L_ID').AsString;

    nStr := '确定要将交货单[ %s ]的封签号该为[ %s ]吗?';
    nStr := Format(nStr, [nID, nSeal]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Update %s Set %s=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nSave, nSeal, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := '修改封签号[ %s -> %s ].';
    nStr := Format(nStr, [SQLQuery.FieldByName(nSave).AsString, nSeal]);
    FDM.WriteSysLog(sFlag_BillItem, nID, nStr, False);

    InitFormData(FWhere);
    ShowMsg('封签号修改成功', sHint);
  end;
end;

//Desc: 调拨提货单
procedure TfFrameBill.N3Click(Sender: TObject);
var nStr,nTmp,nOldZhiKa: string;
    nP,nPMemo: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_AddData;
    CreateBaseFormItem(cFI_FormGetZhika, PopedomItem, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

    nStr      := SQLQuery.FieldByName('L_ZhiKa').AsString;
    nOldZhiKa := SQLQuery.FieldByName('L_ZhiKa').AsString;
    if nStr = nP.FParamB then
    begin
      ShowMsg('相同纸卡不能调拨', sHint);
      Exit;
    end;

    nStr := 'Select C_ID,C_Name From %s,%s ' +
            'Where Z_ID=''%s'' And Z_Customer=C_ID';
    nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, nP.FParamB]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('纸卡信息无效', sHint);
        Exit;
      end;

      nStr := '系统将执行提货调拨操作,明细如下: ' + #13#10#13#10 +
              '※.从客户: %s.%s' + #13#10 +
              '※.到客户: %s.%s' + #13#10 +
              '※.品  种: %s.%s' + #13#10 +
              '※.调拨量: %.2f吨' + #13#10#13#10 +
              '确定要执行请点击"是".';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_CusID').AsString,
              SQLQuery.FieldByName('L_CusName').AsString,
              FieldByName('C_ID').AsString,
              FieldByName('C_Name').AsString,
              SQLQuery.FieldByName('L_StockNo').AsString,
              SQLQuery.FieldByName('L_StockName').AsString,
              SQLQuery.FieldByName('L_Value').AsFloat]);
      if not QueryDlg(nStr, sAsk) then Exit;

      {$IFDEF ForceMemo}
      with nPMemo do
      begin
        nStr := SQLQuery.FieldByName('L_ID').AsString;
        nStr := Format('请填写调拨[ %s ]单据的原因', [nStr]);

        FCommand := cCmd_EditData;
        FParamA := nStr;
        FParamB := 320;
        FParamD := 2;

        nStr := SQLQuery.FieldByName('R_ID').AsString;
        FParamC := 'Update %s Set L_Memo=''$Memo'' Where R_ID=%s';
        FParamC := Format(FParamC, [sTable_Bill, nStr]);

        CreateBaseFormItem(cFI_FormMemo, '', @nPMemo);
        if (FCommand <> cCmd_ModalResult) or (FParamA <> mrOK) then Exit;
      end;
      {$ENDIF}

      nStr := SQLQuery.FieldByName('L_ID').AsString;
      if BillSaleAdjust(nStr, nP.FParamB) then
      begin
        nTmp := '执行提货调拨操作,明细:提货单[ %s ]纸卡[ %s ]销售调拨给纸卡[ %s ].'+
                '从客户: %s.%s.到客户: %s.%s.品  种: %s.%s.调拨量: %.2f吨.';
        nTmp := Format(nTmp, [nStr, nOldZhiKa, nP.FParamB,
                SQLQuery.FieldByName('L_CusID').AsString,
                SQLQuery.FieldByName('L_CusName').AsString,
                FieldByName('C_ID').AsString,
                FieldByName('C_Name').AsString,
                SQLQuery.FieldByName('L_StockNo').AsString,
                SQLQuery.FieldByName('L_StockName').AsString,
                SQLQuery.FieldByName('L_Value').AsFloat]);

        FDM.WriteSysLog(sFlag_BillItem, nStr, nTmp, False);
        InitFormData(FWhere);
        ShowMsg('调拨成功', sHint);
      end;
    end;
  end;
end;

procedure TfFrameBill.N10Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillLoadReport(nStr, False);
  end;
end;

procedure TfFrameBill.N11Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillFYDReport(nStr, False);
  end;
end;

procedure TfFrameBill.cxView1DblClick(Sender: TObject);
var nStr: string;
    nP: TFormCommandParam;
begin
  if (not CheckDelete.Checked) or
     (cxView1.DataController.GetSelectedCount < 1) then Exit;
  //只修改删除记录的备注信息

  with nP do
  begin
    FCommand := cCmd_EditData;
    FParamA := SQLQuery.FieldByName('L_Memo').AsString;
    FParamB := 320;
    FParamD := 2;

    nStr := SQLQuery.FieldByName('R_ID').AsString;
    FParamC := 'Update %s Set L_Memo=''$Memo'' Where R_ID=%s';
    FParamC := Format(nP.FParamC, [sTable_BillBak, nStr]);

    CreateBaseFormItem(cFI_FormMemo, '', @nP);
    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
      InitFormData(FWhere);
    //display
  end;
end;

procedure TfFrameBill.N12Click(Sender: TObject);
var
  nStr, nID, nValue, nCusID: string;
  nDblValue,nMoney: Double;
  nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nID := SQLQuery.FieldByName('L_ID').AsString;
    nCusID := SQLQuery.FieldByName('L_CusId').AsString;
    
    nStr := '确定要对交货单[ %s ]进行回单操作吗?';
    nStr := Format(nStr, [nID]);
    if not QueryDlg(nStr, sAsk) then Exit;
    
    {$IFDEF ForceMemo}
    with nP do
    begin
      nStr := Format('请填写单据[ %s ]回单的原因', [nID]);

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
    {$ENDIF}

    if not ShowInputBox('请输入回单吨数,注意：回单实际吨数:',
                        '修改', nValue, 100) then Exit;

    if not IsNumber(nValue, True) then
    begin
      ShowMessage('请输入正确的回单吨数');
      Exit;
    end;
    //无效

    nDblValue := strtofloat(nValue) - SQLQuery.FieldByName('L_Value').asfloat;
    nMoney := nDblValue * SQLQuery.FieldByName('L_Price').asfloat;
    nValue := FloatToStr(nDblValue);

    FDM.ADOConn.BeginTrans;
    try
      nStr := 'insert into S_Bill(L_Value,L_MValue,L_ID,L_ZhiKa,L_Project,'+
              'L_Area,L_CusID,L_CusName,L_CusPY,L_SaleMan,L_Type,L_StockNo,'+
              'L_StockName,L_Price,L_Truck,L_Status,L_NextStatus,L_InTime,'+
              'L_InMan,L_PValue,L_PDate,L_PMan,L_MDate,L_MMan,L_LadeTime,'+
              'L_LadeMan,L_LadeLine,L_LineName,L_DaiTotal,L_DaiNormal,'+
              'L_DaiBuCha,L_OutFact,L_OutMan,L_Lading,L_IsVIP,L_HYDan,'+
              'L_PrintHY,L_EmptyOut,L_Man,L_Date,L_CusType) select '+nValue+
              ' as L_Value,L_PValue+'+nValue+' as L_MValue,'+
              'L_ID,L_ZhiKa,L_Project,L_Area,L_CusID,L_CusName,L_CusPY,'+
              'L_SaleMan,L_Type,L_StockNo,L_StockName,'+
              'L_Price,L_Truck,L_Status,L_NextStatus,L_InTime,L_InMan,L_PValue,'+
              'L_PDate,L_PMan,L_MDate,L_MMan,L_LadeTime,L_LadeMan,L_LadeLine,'+
              'L_LineName,L_DaiTotal,L_DaiNormal,L_DaiBuCha,L_OutFact,L_OutMan,'+
              'L_Lading,L_IsVIP,L_HYDan,L_PrintHY,L_EmptyOut,L_Man,L_Date,'+
              'L_CusType from S_Bill where L_ID=''%s''';
      nStr := Format(nStr,[nID]);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s set A_OutMoney=A_OutMoney+%s where A_CID=''%s''';
      nStr := Format(nStr,[sTable_CusAccount ,FloatToStr(nMoney) ,nCusID]);
      FDM.ExecuteSQL(nStr);
 
      nStr := '单据['+nID+']进行回单操作.';
      FDM.WriteSysLog(sFlag_BillItem, nID, nStr, False);

      FDM.ADOConn.CommitTrans;
    except
      FDM.ADOConn.RollbackTrans;
      ShowMessage('回单操作失败.');
      Exit;
    end;

    InitFormData(FWhere);
    ShowMsg('回单成功', sHint);
  end;
end;

procedure TfFrameBill.N13Click(Sender: TObject);
var
  nStr : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    FDM.ADOConn.BeginTrans;
    try
      nStr := ' update S_Bill set L_Area= C_Area From ( ' +
        ' SELECT C_Area,Z_ID FROM S_ZhiKa lEFT JOIN S_Contract oN Z_CID=C_ID ' +
        ' Where C_Area <> '''')B  where L_Area='''' AND L_ZhiKa=Z_ID ';
      FDM.ExecuteSQL(nStr);

      FDM.ADOConn.CommitTrans;
    except
      FDM.ADOConn.RollbackTrans;
      ShowMessage('同步所属区域失败.');
      Exit;
    end;

    InitFormData(FWhere);
    ShowMsg('同步所属区域成功', sHint);
  end;
end;

procedure TfFrameBill.N14Click(Sender: TObject);
var
  i : Integer;
  nValue: Double;
  nStr,nLID:   string;
begin
  inherited;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要使用老提单的记录', sHint);
    Exit;
  end;
  if not QueryDlg('确定要对选中的所有记录使用老提单资金嘛？', sAsk) then Exit;
  with cxView1.Controller do
  begin
    for i:=0 to SelectedRowCount-1   do
    begin
      SelectedRows[i].Focused:=True;
      if (Trim(SQLQuery.FieldByName('L_OutFact').AsString) = '') then
      begin
        if SelectedRowCount = 1 then
        begin
          ShowMsg('提货单未出厂,不允许使用老提单资金', sHint);
          Exit;
        end
        else
          Continue;
      end;
      if SQLQuery.FieldByName('L_Price').AsFloat <= 0 then
      begin
        if SelectedRowCount = 1 then
        begin
          ShowMsg('提货单已使用老提单资金', sHint);
          Exit;
        end
        else
          Continue;
      end;
      nLID := SQLQuery.FieldByName('L_ID').AsString;
      nStr := ' update %s set L_Pricebak=L_Price where L_ID = ''%s'' ';
      nStr := Format(nStr, [sTable_Bill, nLID]);

      FDM.ExecuteSQL(nStr);

      nStr := ' update %s set L_Price =0  where L_ID = ''%s'' ';
      nStr := Format(nStr, [sTable_Bill, nLID]);

      FDM.ExecuteSQL(nStr);
    end;

  end;
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
      //使用老提货单校正资金
      CheckAllCusMoney;
      InitFormData(FWhere);
      ShowMsg('使用老提货单资金成功！', sHint);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBill, TfFrameBill.FrameID);
end.
