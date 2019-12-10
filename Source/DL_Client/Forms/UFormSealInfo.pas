unit UFormSealInfo;

{$I Link.Inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, CPort, CPortTypes,
  dxLayoutcxEditAdapters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, dxSkinsCore, dxSkinsDefaultPainters;

type
  TfFormSealInfo = class(TfFormNormal)
    ComPort1: TComPort;
    EditCard: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditLID: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    EditSeal1: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditSeal2: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditSeal3: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    procedure ActionComPort(const nStop: Boolean);
    procedure GetBillInfo(const nCardNo: string); //获取交货单信息
    procedure ShowFormData;  //显示数据
    procedure ClearFormData; //清空数据
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  fFormSealInfo: TfFormSealInfo;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysGrid,
  UFormCtrl, USysDB, UBusinessConst, USysConst ,USysLoger, USmallFunc, USysBusiness;

type
  TReaderType = (ptT800, pt8142);
  //表头类型

  TReaderItem = record
    FType: TReaderType;
    FPort: string;
    FBaud: string;
    FDataBit: Integer;
    FStopBit: Integer;
    FCheckMode: Integer;
  end;
var
  gReaderItem: TReaderItem;
  //全局使用
  gBills: TLadingBillItems;

class function TfFormSealInfo.FormID: integer;
begin
  Result := cFI_FormSealInfo;
end;

class function TfFormSealInfo.CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl;
begin
  Result:=nil;
  with TfFormSealInfo.Create(Application) do
  begin
    Caption := '铅封信息录入';
    ActionComPort(False);
    BtnOK.Enabled:=False;
    ShowModal;
    Free;
  end;
end;

procedure TfFormSealInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ActionComPort(True);
end;

procedure TfFormSealInfo.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  if nStop then
  begin
    ComPort1.Close;
    Exit;
  end;

  with ComPort1 do
  begin
    with Timeouts do
    begin
      ReadTotalConstant := 100;
      ReadTotalMultiplier := 10;
    end;

    nIni := TIniFile.Create(gPath + 'Reader.Ini');
    with gReaderItem do
    try
      nInt := nIni.ReadInteger('Param', 'Type', 1);
      FType := TReaderType(nInt - 1);

      FPort := nIni.ReadString('Param', 'Port', '');
      FBaud := nIni.ReadString('Param', 'Rate', '4800');
      FDataBit := nIni.ReadInteger('Param', 'DataBit', 8);
      FStopBit := nIni.ReadInteger('Param', 'StopBit', 0);
      FCheckMode := nIni.ReadInteger('Param', 'CheckMode', 0);

      Port := FPort;
      BaudRate := StrToBaudRate(FBaud);

      case FDataBit of
       5: DataBits := dbFive;
       6: DataBits := dbSix;
       7: DataBits :=  dbSeven else DataBits := dbEight;
      end;

      case FStopBit of
       2: StopBits := sbTwoStopBits;
       15: StopBits := sbOne5StopBits
       else StopBits := sbOneStopBit;
      end;
    finally
      nIni.Free;
    end;

    if ComPort1.Port <> '' then
      ComPort1.Open;
    //xxxxx
  end;
end;


procedure TfFormSealInfo.ComPort1RxChar(Sender: TObject;
  Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
    nCard:string;
begin
  ComPort1.ReadStr(nStr, Count);
  FBuffer := FBuffer + nStr;

  nLen := Length(FBuffer);
  if nLen < 7 then Exit;

  for nIdx:=1 to nLen do
  begin
    if (FBuffer[nIdx] <> #$AA) or (nLen - nIdx < 6) then Continue;
    if (FBuffer[nIdx+1] <> #$FF) or (FBuffer[nIdx+2] <> #$00) then Continue;

    nStr := Copy(FBuffer, nIdx+3, 4);
    nCard:= ParseCardNO(nStr, True);
    if nCard <> EditCard.Text then
    begin
      EditCard.Text := nCard;
      GetBillInfo(Trim(EditCard.Text));
    end;
    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormSealInfo.GetBillInfo(const nCardNo: string);
var nStr,nHint: string;
    nIdx,nInt: Integer;
    nFID :string;
begin
  nFID:='';
  if GetLadingBills(nCardNo, sFlag_TruckFH, gBills) then
  begin
    nInt := 0 ;
    nHint := '';

    for nIdx:=Low(gBills) to High(gBills) do
    with gBills[nIdx] do
    begin
      FSelected := (FNextStatus = sFlag_TruckBFM) or (FNextStatus = sFlag_TruckOut);
      if FSelected then
      begin
        Inc(nInt);
        Continue;
      end;

      nStr := '※.单号:[ %s ] 状态:[ %-6s -> %-6s ]   ';
      if nIdx < High(gBills) then nStr := nStr + #13#10;

      nStr := Format(nStr, [FID,
              TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
      nHint := nHint + nStr;
    end;

    if (nHint <> '') and (nInt = 0) then
    begin
      nHint := '该车辆当前不能录入铅封,详情如下: ' + #13#10#13#10 + nHint;
      ShowDlg(nHint, sHint);
      EditCard.Text := '';
      Exit;
    end;

    ShowFormData;

  end else
  begin
    nHint := '无相关数据';
    ShowDlg(nHint, sHint);
    EditCard.Text := '';
  end;
end;

procedure TfFormSealInfo.ShowFormData;
var nStr,nHYDan,nID: string;
    nPrefixLen : Integer;
begin
  with gBills[0] do
  begin
    EditLID.Text:= gBills[0].FID;
    EditCustomer.Text:= FCusName;
    EditTruck.Text:= gBills[0].FTruck;
    EditStockName.Text:= gBills[0].FStockName;
    nID:= gBills[0].FID;
  end;

  nStr := 'Select L_Seal1,L_Seal2,L_Seal3,L_HYDan,L_Seal From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, EditLID.Text]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      EditSeal1.Text := Fields[0].AsString;
      EditSeal2.Text := Fields[1].AsString;
      EditSeal3.Text := Fields[2].AsString;
      {$IFDEF BatchInHYOfBill}
      nHYDan := Fields[3].AsString;
      {$ELSE}
      nHYDan := Fields[4].AsString;
      {$ENDIF}
    end;
  end;
  if (EditSeal1.Text = '') and (Trim(nHYDan) <> '') then
  begin
    nStr := 'Select B_Prefix,B_IDLen From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase,sFlag_BusGroup, sFlag_BillNo]);
    //xxxxx
    with FDM.QueryTemp(nStr) do
    if RecordCount>0 then
    begin
      nPrefixLen := Length(Fields[0].AsString);
    end else begin
      nPrefixLen := 0;
    end;
    System.Delete(nID, 1, nPrefixLen + 6);
    EditSeal1.Text := nHYDan + nID;
  end;
  BtnOK.Enabled:=True;
end;

procedure TfFormSealInfo.ClearFormData;
var i:Integer;
begin
  for i:= 0 to ComponentCount-1 do
  begin
    if Components[i] is TcxTextEdit then
      (Components[i] as TcxTextEdit).Text:='';
    if Components[i] is TcxComboBox then
      (Components[i] as TcxComboBox).Text:='';
  end;
end;

procedure TfFormSealInfo.BtnOKClick(Sender: TObject);
var nStr : string ;
    nCount, nInt: Integer;
begin
  if EditCard.Text = '' then
  begin
    ShowMsg('请输入磁卡号', sHint);
    Exit;
  end;

  nCount := 1;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SealCount]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
      nCount := Fields[0].AsInteger;
  end;

  nInt := 0;
  if Trim(EditSeal1.Text) <> '' then
   Inc(nInt);
  if Trim(EditSeal2.Text) <> '' then
   Inc(nInt);
  if Trim(EditSeal3.Text) <> '' then
   Inc(nInt);

  if nInt < nCount then
  begin
    ShowMsg('至少需要录入' + IntToStr(nCount) + '个铅封', sHint);
    Exit;
  end;

  nStr := '确定保存吗?';
  if not QueryDlg(nStr, sAsk) then Exit;

  nStr := 'Update %s Set L_Seal1 = ''%s'',L_Seal2 = ''%s'',L_Seal3 = ''%s'' Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, Trim(EditSeal1.Text),
                                     Trim(EditSeal2.Text),
                                     Trim(EditSeal3.Text), gBills[0].FID]);
  FDM.ExecuteSQL(nStr);

  ShowMsg('铅封信息录入成功', sHint);
  ClearFormData;
  ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormSealInfo, TfFormSealInfo.FormID);

end.
