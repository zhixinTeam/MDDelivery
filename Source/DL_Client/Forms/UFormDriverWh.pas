{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFormDriverWh;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormDriverWh = class(TfFormNormal)
    EditName: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditPinYin: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditIDCard: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditTruckNo: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditNameKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
    FName: string;
    procedure LoadFormData(const nID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst, USysBusiness;

class function TfFormDriverWh.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormDriverWh.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '司机信息 - 添加';
      FName := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '司机信息 - 修改';
      FName := nP.FParamA;
    end;

    LoadFormData(FName);
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormDriverWh.FormID: integer;
begin
  Result := cFI_FormDriverWh;
end;

procedure TfFormDriverWh.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_DriverWh, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      Exit;
    end;

    EditName.Text    := FieldByName('D_Name').AsString;
    EditPinYin.Text  := FieldByName('D_PinYin').AsString;
    EditIDCard.Text  := FieldByName('D_IDCard').AsString;
    EditTruckNo.Text := FieldByName('D_Truck').AsString;
  end;
end;

//Desc: 保存
procedure TfFormDriverWh.BtnOKClick(Sender: TObject);
var nStr,nName,nPinYin,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  nName := UpperCase(Trim(EditName.Text));
  if nName = '' then
  begin
    ActiveControl := EditName;
    ShowMsg('请输入司机姓名', sHint);
    Exit;
  end;

  nPinYin := UpperCase(Trim(EditPinYin.Text));
  if nPinYin = '' then
  begin
    ActiveControl := EditPinYin;
    ShowMsg('请输入姓名全拼', sHint);
    Exit;
  end;

  EditIDCard.Text := Trim(EditIDCard.Text);
  if not ((Length(EditIDCard.Text) = 18) and
  (UpperCase(Copy(EditIDCard.Text, 18, 1))=GetIDCardNumCheckCode(Copy(EditIDCard.Text, 1, 17)))) then
  begin
    ActiveControl := EditIDCard;
    ShowMsg('输入的身份证号非法,请重新输入', sHint);
    Exit;
  end;
  
  if FName = '' then
  begin
    nStr := ' select D_Name from %s where D_Name=''%s''';
    nStr := Format(nStr,[sTable_DriverWh, nName]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount>0 then
      begin
        ActiveControl := EditName;
        ShowMsg('已存在此司机姓名', sHint);
        Exit;
      end;
    end;
  end;
  
  if FName = '' then
       nStr := ''
  else nStr := SF('R_ID', FName, sfVal);

  nStr := MakeSQLByStr([SF('D_Name', nName),
                        SF('D_PinYin', nPinYin),
                        SF('D_PY', GetPinYinOfStr(nName)),
                        SF('D_IDCard', EditIDCard.Text),
                        SF('D_Truck',  EditTruckNo.Text)
          ], sTable_DriverWh, nStr, FName = '');
  FDM.ExecuteSQL(nStr);

  if FName = '' then
        nEvent := '添加[ %s ]司机信息.'
  else  nEvent := '修改[ %s ]司机信息.';
  nEvent := Format(nEvent, [nName]);
  FDM.WriteSysLog(sFlag_CommonItem, nName, nEvent);


  ModalResult := mrOk;
  ShowMsg('司机信息保存成功', sHint);
end;

procedure TfFormDriverWh.EditNameKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditName    then ActiveControl := EditPinYin else
    if Sender = EditPinYin  then ActiveControl := EditIDCard else
    if Sender = EditIDCard  then ActiveControl := EditTruckNo else
    if Sender = EditTruckNo then ActiveControl := BtnOK;

    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormDriverWh, TfFormDriverWh.FormID);
end.
