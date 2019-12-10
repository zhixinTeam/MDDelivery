{*******************************************************************************
  作者: dmzn@163.com 2017-07-02
  描述: 袋装拼单卡
*******************************************************************************}
unit UFormBillPD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,UFormWait,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxDropDownEdit, cxMaskEdit,
  cxButtonEdit, cxTextEdit, dxLayoutControl, cxMemo, UBusinessPacker,
  cxCalendar, StdCtrls;

type
  TfFormBillPD = class(TfFormNormal)
    dxLayout1Item4: TdxLayoutItem;
    EditLID: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditZhiKa: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditCusID: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditCusName: TcxTextEdit;
    EditSID: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    EditNCusID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditNCusName: TcxTextEdit;
    dxlytmNCusName: TdxLayoutItem;
    EditZName: TcxTextEdit;
    dxLayout1Item11: TdxLayoutItem;
    EditProject: TcxTextEdit;
    dxLayout1Item12: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditMoney: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    EditStockName: TcxComboBox;
    dxLayout1Item15: TdxLayoutItem;
    EditPDNum: TcxTextEdit;
    dxLayout1Item16: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditZhiKaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FOldZK: string;
    //旧纸卡
    FXHSpot, FCard: string;
    procedure InitFormData(const nCard: string);
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = ''; const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UMgrControl, USysDB, USysConst, USysBusiness,
  UDataModule;

class function TfFormBillPD.CreateForm(const nPopedom: string; const nParam: Pointer): TWinControl;
var
  nP: PFormCommandParam;
begin
  Result := nil;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  nP.FCommand := cCmd_GetData;
  CreateBaseFormItem(cFI_FormMakeCard, nPopedom, nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then
    Exit;

  with TfFormBillPD.Create(Application) do
  try
    Caption := '袋装 - 拼单';
    InitFormData(nP.FParamB);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBillPD.FormID: integer;
begin
  Result := cFI_FormDaiPD;
end;

procedure TfFormBillPD.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormBillPD.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormBillPD.InitFormData(const nCard: string);
var
  nStr: string;
begin
  dxGroup1.AlignVert := avTop;
  dxGroup2.AlignVert := avClient;
  ActiveControl := EditZhiKa;

  nStr := 'Select * from %s Where L_Card=''%s''';
  nStr := Format(nStr, [sTable_Bill, nCard]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      BtnOK.Enabled := False;
      ShowMsg('该磁卡没有关联提货单', sHint);
      Exit;
    end;

    FOldZK           := FieldByName('L_ZhiKa').AsString;
    FXHSpot          := FieldByName('L_XHSpot').AsString;
    FCard            := FieldByName('L_Card').AsString;
    EditLID.Text     := FieldByName('L_ID').AsString;
    EditCusID.Text   := FieldByName('L_CusID').AsString;
    EditCusName.Text := FieldByName('L_CusName').AsString;
    EditSID.Text     := FieldByName('L_StockNo').AsString;
    EditSName.Text   := FieldByName('L_StockName').AsString;
    EditTruck.Text   := FieldByName('L_Truck').AsString;
    EditValue.Text   := Format('%.2f 吨', [FieldByName('L_Value').AsFloat]);
  end;
end;

procedure TfFormBillPD.EditZhiKaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  nStr: string;
  nFix: Boolean;
  nMoney: Double;
  nP: TFormCommandParam;
begin
  Visible := False;
  try
    Application.ProcessMessages;
    CreateBaseFormItem(cFI_FormGetZhika, PopedomItem, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then
      Exit;
  finally
    Visible := True;
  end;

  nStr := nP.FParamB;
  if nStr = FOldZK then
  begin
    ShowMsg('拼单时不能使用相同纸卡', sHint);
    Exit;
  end
  else
    EditZhiKa.Text := nStr;

  nStr := 'Select z.*,C_Name From %s z ' + ' Left Join %s cus on cus.C_ID=z.Z_Customer ' + 'Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, EditZhiKa.Text]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg('纸卡已无效', sHint);
      Exit;
    end;

    EditZName.Text := FieldByName('Z_Name').AsString;
    EditProject.Text := FieldByName('Z_Project').AsString;
    EditNCusID.Text := FieldByName('Z_Customer').AsString;
    EditNCusName.Text := FieldByName('C_Name').AsString;

    nMoney := GetZhikaValidMoney(EditZhiKa.Text, nFix);
    EditMoney.Text := Format('%.2f 元', [nMoney]);

    EditStockName.Clear;
    nStr := ' Select D_StockNo, D_StockName, D_Type From %s Where D_ZID=''%s'' ';
    nStr := Format(nStr, [sTable_ZhiKaDtl, Trim(EditZhiKa.Text)]);

    with FDM.QueryTemp(nStr) do
    begin
      if RecordCount < 1 then
      begin
        ShowMsg('纸卡上没有可发货品种', sHint);
        Exit;
      end;
      First;
      while not Eof do
      begin
        if UpperCase(Trim(FieldByName('D_Type').AsString)) = 'D' then
        begin
          EditStockName.Properties.Items.Add(FieldByName('D_StockNo').AsString+';'
            +FieldByName('D_StockName').AsString);
        end;
        Next;
      end;
    end;

    ActiveControl := BtnOK;
  end;
end;

//Date: 2017-07-03
//Parm: 纸卡号
//Desc: 判断nZhiKa上是否有nStock品种
function GetZKPrice(const nZhiKa,nStockNo: string): Double;
var
  nStr: string;
begin
  Result := 0;
  nStr := 'Select D_Price From %s Where D_ZID=''%s'' and D_StockNo=''%s'' ';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZhiKa, nStockNo]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      Result := FieldByName('D_Price').AsFloat; 
    end;
    //xxxxx
  end;
end;

procedure TfFormBillPD.BtnOKClick(Sender: TObject);
var
  nStr: string;
  nList,nTmp: TStrings;
  FStockNO, FStockName: string;
  FNewLID:string;
begin
  if EditZhiKa.Text = '' then
  begin
    ShowMsg('请选择拼单纸卡', sHint);
    Exit;
  end;
  EditStockName.Text    := Trim(EditStockName.Text);
  if EditStockName.Text = '' then
  begin
    ShowMsg('请选择拼单水泥名称', sHint);
    Exit;
  end;
  if StrToFloatDef(EditPDNum.Text,0) <= 0  then
  begin
    ShowMsg('请输入拼单数量', sHint);
    Exit;
  end;

  FStockNO   := Copy(EditStockName.Text,1,Pos(';',EditStockName.Text)-1);
  FStockName := Copy(EditStockName.Text,Pos(';',EditStockName.Text)+1, MaxInt);


  nStr := 'Select count(*) From %s Where isnull(L_HdOrderId,'''') <> '''' ';
  nStr := Format(nStr, [sTable_Bill]);

  with FDM.QueryTemp(nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      ShowMsg('该提货单已有拼单记录', sHint);
      Exit;
    end;
  end;
    
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    with nTmp do
    begin
      Values['Type']      := 'D';
      Values['StockNO']   := FStockNO;
      Values['StockName'] := FStockName;
      Values['Seal']      := '';
      Values['Price']     := FloatToStr(GetZKPrice(EditZhiKa.Text,FStockNO));
      Values['Value']     := EditPDNum.Text;
      Values['PrintGLF']  := sFlag_No;
      Values['PrintHY']   := sFlag_Yes;
      Values['IsPlan']    := sFlag_No;

      nList.Add(PackerEncodeStr(nTmp.Text));
      //new bill
    end;

    with nList do
    begin
      Values['Bills']   := PackerEncodeStr(nList.Text);
      Values['ZhiKa']   := Trim(EditZhiKa.Text);
      Values['Truck']   := '888888';
      Values['Ident']   := '';
      Values['SJName']  := '';
      Values['L_XHSpot']:= FXHSpot;
      Values['Lading']  := 'T';
      Values['IsVIP']   := 'C';
      Values['BuDan']   := sFlag_No;
      Values['Card']    := '';
    end;

    BtnOK.Enabled := False;
    try
      ShowWaitForm(Self, '正在保存', True);
      FNewLID :=  SaveBill(PackerEncodeStr(nList.Text));
    finally
      BtnOK.Enabled := True;
      CloseWaitForm;
    end;
  finally
    nTmp.Free;
    nList.Free;
  end;
  if FNewLID = '' then Exit;
  
  nStr := ' Update %s Set  L_Truck = ''%s'',L_Card = ''%s''  Where L_ID = ''%s'' ';
  nStr := Format(nStr, [sTable_Bill, EditTruck.Text, FCard, FNewLID]);
  FDM.ExecuteSQL(nStr);

  nStr := ' Update %s Set  T_Truck = ''%s''   Where T_Truck = ''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, EditTruck.Text, '888888']);
  FDM.ExecuteSQL(nStr);

  nStr := ' Update %s Set L_HdOrderId = ''%s'' Where L_ID = ''%s'' ';
  nStr := Format(nStr, [sTable_Bill, EditZhiKa.Text, EditLID.Text]);
  FDM.ExecuteSQL(nStr);
  
  ShowMsg('拼单成功', sHint);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormBillPD, TfFormBillPD.FormID);

end.

