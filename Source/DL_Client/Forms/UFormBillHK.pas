{*******************************************************************************
  作者: dmzn@163.com 2017-07-02
  描述: 散装预合卡
*******************************************************************************}
unit UFormBillHK;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxDropDownEdit, cxMemo,
  cxButtonEdit, cxLabel, cxTextEdit, cxMaskEdit, cxCalendar,
  dxLayoutControl, StdCtrls;

type
  TfFormBillHK = class(TfFormNormal)
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
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditZhiKaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FOldZK: string;
    //旧纸卡
    procedure InitFormData(const nCard: string);
    //初始化界面
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UMgrControl, USysDB, USysConst,
  USysBusiness, UDataModule;

class function TfFormBillHK.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  nP.FCommand := cCmd_GetData;
  CreateBaseFormItem(cFI_FormMakeCard, nPopedom, nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  with TfFormBillHK.Create(Application) do
  try
    Caption := '散装 - 合卡';
    InitFormData(nP.FParamB);

    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBillHK.FormID: integer;
begin
  Result := cFI_FormSanPreHK;
end;

procedure TfFormBillHK.FormCreate(Sender: TObject);
begin
  LoadFormConfig(Self);
end;

procedure TfFormBillHK.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveFormConfig(Self);
end;

procedure TfFormBillHK.InitFormData(const nCard: string);
var nStr: string;
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
    EditLID.Text     := FieldByName('L_ID').AsString;
    EditCusID.Text   := FieldByName('L_CusID').AsString;
    EditCusName.Text := FieldByName('L_CusName').AsString;
    EditSID.Text     := FieldByName('L_StockNo').AsString;
    EditSName.Text   := FieldByName('L_StockName').AsString;
    EditTruck.Text   := FieldByName('L_Truck').AsString;
    EditValue.Text   := Format('%.2f 吨', [FieldByName('L_Value').AsFloat]);
  end;
end;

procedure TfFormBillHK.EditZhiKaPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nStr: string;
    nFix: Boolean;
    nMoney: Double;  
    nP: TFormCommandParam;
begin
  Visible := False;
  try
    Application.ProcessMessages;
    CreateBaseFormItem(cFI_FormGetZhika, PopedomItem, @nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  finally
    Visible := True;
  end;

  nStr := nP.FParamB;
  if nStr = FOldZK then
  begin
    ShowMsg('合卡时不能使用相同纸卡', sHint);
    Exit;
  end else EditZhiKa.Text := nStr;

  nStr := 'Select z.*,C_Name From %s z ' +
          ' Left Join %s cus on cus.C_ID=z.Z_Customer ' +
          'Where Z_ID=''%s''';
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
    ActiveControl := BtnOK;
  end;
end;

//Date: 2017-07-03
//Parm: 物料号;纸卡号
//Desc: 判断nZhiKa上是否有nStock品种
function HasStock(const nStock,nZhiKa: string): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_StockNo From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZhiKa]);

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
      if Fields[0].AsString = nStock then
      begin
        Result := True;
        Break;
      end;

      Next;
    end;

    if not Result then
      ShowMsg('纸卡上没有同品种水泥', sHint);
    //xxxxx
  end;
end;

procedure TfFormBillHK.BtnOKClick(Sender: TObject);
var nStr: string;
begin
  if EditZhiKa.Text = '' then
  begin
    ShowMsg('请选择待合卡纸卡', sHint);
    Exit;
  end;

  nStr := 'Select count(*) From %s Where H_Bill=''%s''';
  nStr := Format(nStr, [sTable_BillHK, EditLID.Text]);

  with FDM.QueryTemp(nStr) do
  if Fields[0].AsInteger > 0 then
  begin
    ShowMsg('该提货单已有合卡记录', sHint);
    Exit;
  end;

  if not HasStock(EditSID.Text, EditZhiKa.Text) then Exit;
  nStr := MakeSQLByStr([SF('H_Bill', EditLID.Text),
          SF('H_ZhiKa', EditZhiKa.Text),
          SF('H_Man', gSysParam.FUserID),
          SF('H_Date', sField_SQLServer_Now, sfVal)
          ], sTable_BillHK, '', True);
  //xxxxx

  FDM.ExecuteSQL(nStr);
  ShowMsg('预合卡成功', sHint);
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormBillHK, TfFormBillHK.FormID);
end.
