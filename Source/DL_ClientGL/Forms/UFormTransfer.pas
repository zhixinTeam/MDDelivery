{*******************************************************************************
作者: fendou116688@163.com 2016/2/26
描述: 短倒业务办理磁卡
*******************************************************************************}
unit UFormTransfer;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxButtonEdit,
  dxLayoutcxEditAdapters, dxSkinsCore, dxSkinsDefaultPainters, cxCheckBox;

type
  TfFormTransfer = class(TfFormNormal)
    EditMate: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditSrcAddr: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDstAddr: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditDC: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    EditDR: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    chkNeiDao: TcxCheckBox;
    dxLayout1Item11: TdxLayoutItem;
    CheckBox1: TcxCheckBox;
    dxLayout1Item10: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure EditDCPropertiesChange(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  UMgrControl, UDataModule, UFormBase, UFormCtrl, UBusinessPacker,
  USysDB, USysConst, UAdjustForm, USysBusiness;

type
  TMateItem = record
    FID   : string;
    FName : string;
  end;

var
  gMateItems: array of TMateItem;
  //品种列表

class function TfFormTransfer.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else New(nP);

  with TfFormTransfer.Create(Application) do
  try
    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTransfer.FormID: integer;
begin
  Result := cFI_FormTransBase;
end;

procedure TfFormTransfer.BtnOKClick(Sender: TObject);
var nIdx: Integer;
    nList: TStrings;
    nStr, nStock, nStockName: string;
begin
  if EditMID.ItemIndex >=0 then
  begin
    nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
    nStock := gMateItems[nIdx].FID;
    nStockName := gMateItems[nIdx].FName;
  end  else
  begin
    nStock := Trim(EditMID.Text);
    nStockName := Trim(EditMate.Text);
  end;  

  nList := TStringList.Create;
  try
    with nList do
    begin
      Values['Truck'] := Trim(EditTruck.Text);
      Values['SrcAddr'] := Trim(EditSrcAddr.Text);
      Values['DestAddr']  := Trim(EditDstAddr.Text);
      Values['StockNo'] := nStock;
      Values['StockName'] := nStockName;
      if CheckBox1.Checked then
        Values['CType'] := 'G'
      else
        Values['CType'] := 'L';

      if chkneidao.Checked then
        Values['NeiDao'] := 'Y'
      else
        Values['NeiDao'] := 'N';
    end;

    nStr := SaveDDBases(PackerEncodeStr(nList.Text));
    //call mit bus
    if nStr = '' then Exit;


    SetDDCard(nStr, EditTruck.Text, True);
    //办理磁卡

    ModalResult := mrOk;
  finally
    FreeAndNil(nList);
  end;
end;

procedure TfFormTransfer.InitFormData;
var nStr: string;
    nInt, nIdx: Integer;
begin
  nStr := 'Select M_ID,M_Name From %s';
  nStr := Format(nStr, [sTable_Materails]);

  EditMID.Properties.Items.Clear;
  SetLength(gMateItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gMateItems, RecordCount);

    nInt := 0;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with gMateItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditMID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;

    EditMID.ItemIndex := nInt;
    EditMate.Text := gMateItems[nInt].FName;
  end;

 { nStr := 'P_ID=Select P_ID,P_Name From %s';
  nStr := Format(nStr, [sTable_Provider]);
  FDM.FillStringsData(EditDC.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDC, False);

  FDM.FillStringsData(EditDR.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDR, False); }
end;  

procedure TfFormTransfer.EditMIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditMID.Focused) or (EditMID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
  EditMate.Text := gMateItems[nIdx].FName;
end;

procedure TfFormTransfer.EditDCPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditDC then
    EditSrcAddr.Text := nStr
  else if Sender = EditDR then
    EditDstAddr.Text := nStr;
  //xxxxx
end;

procedure TfFormTransfer.EditTruckKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormTransfer, TfFormTransfer.FormID);
end.
