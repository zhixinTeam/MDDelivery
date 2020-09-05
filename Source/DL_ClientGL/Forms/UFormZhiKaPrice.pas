{*******************************************************************************
  作者: dmzn@163.com 2010-3-16
  描述: 纸卡调价
*******************************************************************************}
unit UFormZhiKaPrice;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls, cxMaskEdit, cxDropDownEdit, cxCalendar,
  cxLabel;

type
  TfFormZKPrice = class(TfFormNormal)
    EditStock: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditNew: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item6: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    Check3: TcxCheckBox;
    cxLabel1: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    EditStart: TcxDateEdit;
    dxLayout1Item10: TdxLayoutItem;
    EditEnd: TcxDateEdit;
    dxLayout1Item11: TdxLayoutItem;
    cxLabel2: TcxLabel;
    dxLayout1Item12: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure Check3PropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FZKList: TStrings;
    //纸卡列表
    FMainZK,FMainStock: string;
    //主纸卡号,品种
    procedure InitFormData;
    //载入数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormBase, UMgrControl, USysDB, USysConst, USysBusiness,
  UFormWait, UDataModule;

class function TfFormZKPrice.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormZKPrice.Create(Application) do
  begin
    Caption := '纸卡调价';
    FZKList.Text := nP.FParamB;
    InitFormData;
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZKPrice.FormID: integer;
begin
  Result := cFI_FormAdjustPrice;
end;

procedure TfFormZKPrice.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FZKList := TStringList.Create;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    Check1.Checked := nIni.ReadBool(Name, 'AutoUnfreeze', True);
    Check2.Checked := nIni.ReadBool(Name, 'NewPriceType', False);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZKPrice.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    nIni.WriteBool(Name, 'AutoUnfreeze', Check1.Checked);
    nIni.WriteBool(Name, 'NewPriceType', Check2.Checked);
  finally
    nIni.Free;
  end;

  FZKList.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormZKPrice.InitFormData;
var nIdx: Integer; 
    nStock: string;
    nList: TStrings;
    nMin,nMax,nVal: Double;
begin
  nList := TStringList.Create;
  try
    Check3.Enabled := False;
    EditStart.Date := Date();
    EditEnd.Date := Date() + 1;

    FMainZK := '';
    FMainStock := '';

    nMin := MaxInt;
    nMax := 0;
    nStock := '';

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //明细记录号;单价;纸卡;品种名称
      if not IsNumber(nList[1], True) then Continue;

      nVal := StrToFloat(nList[1]);
      if nVal < nMin then nMin := nVal;
      if nVal > nMax then nMax := nVal;

      if nStock = '' then nStock := nList[4];
      if FMainStock = '' then FMainStock := nList[3];

      if FMainZK = '' then FMainZK := nList[2] else
      if FMainZK <> nList[2] then FMainZK := sFlag_No;
    end;

    ActiveControl := EditNew;
    EditStock.Text := nStock;

    {$IFDEF ChangeBillWhenPriceAdjust}
    Check3.Enabled := (FMainZK <> '') and (FMainZK <> sFlag_No);
    {$ENDIF}
    
    if nMin = nMax then
         EditPrice.Text := Format('%.2f 元/吨', [nMax])
    else EditPrice.Text := Format('%.2f - %.2f 元/吨', [nMin, nMax]);
  finally
    nList.Free;
  end;
end;

procedure TfFormZKPrice.Check3PropertiesEditValueChanged(Sender: TObject);
begin
  EditStart.Enabled := Check3.Checked;
  EditEnd.Enabled := Check3.Checked;
end;

procedure TfFormZKPrice.BtnOKClick(Sender: TObject);
var nStr,nStatus: string;
    nVal,nVal2: Double;
    nIdx: Integer;
    nList: TStrings;
begin
  if not (IsNumber(EditNew.Text, True) and ((StrToFloat(EditNew.Text) > 0) or
     Check2.Checked)) then
  begin
    EditNew.SetFocus;
    ShowMsg('请输入正确的单价', sHint); Exit;
  end;

  if Check3.Checked and (EditStart.Date >= EditEnd.Date) then
  begin
    EditStart.SetFocus;
    ShowMsg('开始应小于结束时间', sHint); Exit;
  end;

  nStr := '注意: 该操作不可以撤销,请您慎重!' + #13#10#13#10 +
          '价格调整后,新单价会立刻生效,要继续吗?  ';
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  nList := nil;
  FDM.ADOConn.BeginTrans;
  try
    if FZKList.Count > 20 then
      ShowWaitForm(Self, '调价中,请稍候');
    nList := TStringList.Create;

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //明细记录号;单价;纸卡;品种名称

      nVal := StrToFloat(EditNew.Text);
      if Check2.Checked then
        nVal := StrToFloat(nList[1]) + nVal;
      nVal := Float2Float(nVal, cPrecision, True);

      nStr := 'Update %s Set D_Price=%.2f,D_PPrice=%s ' +
              'Where R_ID=%s And D_TPrice<>''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nVal, nList[1], nList[0], sFlag_No]);
      FDM.ExecuteSQL(nStr);

      nStr := '骨料品种[ %s ]单价调整[ %s -> %.2f ]';
      nStr := Format(nStr, [nList[4], nList[1], nVal]);
      if Check3.Checked then
        nStr := nStr + ',并更新已发货单据.';
      FDM.WriteSysLog(sFlag_ZhiKaItem, nList[2], nStr, False);

      if not Check1.Checked then Continue;
      {$IFDEF NoShowPriceChange}
      nStatus := 'Null';
      {$ELSE}
      nStatus := '''' + sFlag_TJOver + '''';
      {$ENDIF}
      
      nStr := 'Update %s Set Z_TJStatus=%s, Z_Date=%s  Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nStatus, FDM.SQLServerNow, nList[2]]);
      FDM.ExecuteSQL(nStr);
    end;

    //--------------------------------------------------------------------------
    if Check3.Checked then
    begin
      nStr := 'Select D_Price,Z_Customer From %s ' +
              ' Left Join %s On D_ZID=Z_ID ' +
              'Where D_ZID=''%s'' And D_StockNo=''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, sTable_ZhiKa, FMainZK, FMainStock]);

      with FDM.QueryTemp(nStr) do
      if RecordCount > 0 then
      begin
        nVal := Fields[0].AsFloat;
        nStatus := Fields[1].AsString;

        nStr := 'Update %s Set L_Price=%.2f Where (' +
          '(Case When L_OutFact Is Null Then L_Date Else L_OutFact End)>=''%s'' And ' +
          '(Case When L_OutFact Is Null Then L_Date Else L_OutFact End)<=''%s''' +
          ') And L_ZhiKa=''%s'' And L_StockNo=''%s''';
        nStr := Format(nStr, [sTable_Bill, nVal, DateTime2Str(EditStart.Date),
                DateTime2Str(EditEnd.Date), FMainZK, FMainStock]);
        //xxxxx
        
        FDM.ExecuteSQL(nStr);
        //更新已开提货单价格

        nStr := 'Select Sum(L_Price*L_Value) From $Bill ' +
                'Where L_CusID=''$Cus'' And L_OutFact Is Not Null ' +
                'Union All ' +
                'Select Sum(L_Price*L_Value) From $Bill ' +
                'Where L_CusID=''$Cus'' And L_OutFact Is Null';
        nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$Cus', nStatus)]);

        with FDM.QueryTemp(nStr) do
        begin
          First;
          nVal := Fields[0].AsFloat;

          Next;
          nVal2 := Fields[0].AsFloat;

          nStr := 'Update %s Set A_OutMoney=%.2f,A_FreezeMoney=%.2f ' +
                  'Where A_CID=''%s''';
          nStr := Format(nStr, [sTable_CusAccount, nVal, nVal2, nStatus]);
          
          FDM.ExecuteSQL(nStr);
          //更新出金和冻结金
        end;
      end;
    end;

    FDM.ADOConn.CommitTrans;
    nIdx := MaxInt;
  except
    nIdx := -1;
    FDM.ADOConn.RollbackTrans;
    ShowMsg('调价失败', sError);
  end;

  nList.Free;
  if FZKList.Count > 20 then CloseWaitForm;
  if nIdx = MaxInt then ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZKPrice, TfFormZKPrice.FormID);
end.
