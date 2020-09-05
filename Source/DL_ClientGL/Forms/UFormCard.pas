{*******************************************************************************
  作者: dmzn@163.com 2012-4-5
  描述: 关联磁卡
*******************************************************************************}
unit UFormCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, ExtCtrls;

type
  TfFormCard = class(TfFormNormal)
    EditBill: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item5: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    ComPort1: TComPort;
    Timer1: TTimer;
    procedure BtnOKClick(Sender: TObject);
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCardKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FBuffer: string;
    //接收缓冲
    FParam: PFormCommandParam;
    procedure InitFormData;
    procedure ActionComPort(const nStop: Boolean);
    function WriteICCard(): Boolean;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UMgrMHReader, USysBusiness, USmallFunc,
  USysConst, USysDB, UDataModule;

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

class function TfFormCard.FormID: integer;
begin
  Result := cFI_FormMakeCard;
end;

class function TfFormCard.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;
  if not Assigned(nParam) then Exit;

  with TfFormCard.Create(Application) do
  try
    FParam := nParam;
    if FParam.FCommand = cCmd_GetData then
    begin
      dxLayout1Item3.Visible := False;
      dxLayout1Item4.Visible := False;
      dxLayout1Item5.Visible := False; 
    end else
    begin
      if FParam.FParamC=sFlag_Provide then
           dxLayout1Item3.Caption := '采购单号'
      else dxLayout1Item3.Caption := '交货单号';
    end;

    InitFormData;
    ActionComPort(False);
    FParam.FParamA := ShowModal;

    if FParam.FCommand = cCmd_GetData then
      FParam.FParamB := EditCard.Text;
    FParam.FCommand := cCmd_ModalResult;
  finally
    Free;
  end;
end;

procedure TfFormCard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ActionComPort(True);
end;

procedure TfFormCard.InitFormData;
begin
  ActiveControl := EditCard;
  EditTruck.Text := FParam.FParamB;
  EditBill.Text := AdjustListStrFormat(FParam.FParamA, '''', False, ',', False);
end;

//Desc: 串口操作
procedure TfFormCard.ActionComPort(const nStop: Boolean);
var nInt: Integer;
    nIni: TIniFile;
begin
  {$IFDEF UseMHICCard}
  if not Assigned(gMHReaderManager) then
  begin
    gMHReaderManager := TMHReaderManager.Create;
    gMHReaderManager.LoadConfig(gPath + 'Readers_35LT.XML');
  end;

  if not nStop then
  begin
    EditCard.Text := '请将IC卡放至读卡器';
  end;

  Timer1.Enabled := not nStop;
  Exit;
  {$ENDIF}

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

procedure TfFormCard.ComPort1RxChar(Sender: TObject; Count: Integer);
var nStr: string;
    nIdx,nLen: Integer;
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
    EditCard.Text := ParseCardNO(nStr, True); 

    FBuffer := '';
    Exit;
  end;
end;

procedure TfFormCard.EditCardKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    BtnOK.Click;
  end else OnCtrlKeyPress(Sender, Key);
end;

procedure TfFormCard.Timer1Timer(Sender: TObject);
var nStr: string;
begin
  nStr := gMHReaderManager.ReadCardID('0101');
  if nStr <> '' then
  begin
    Timer1.Enabled := False;
    EditCard.Text := nStr;
  end;
end;

//Date: 2019-03-13
//Desc: 按格式写IC卡(红滇水骨料用)
function TfFormCard.WriteICCard(): Boolean;
var nStr,nData: string;
begin
  nStr := 'Select L_Truck,L_Value,L_StockNo,T_TruckLong,T_TruckWidth,' +
          'D_Sign From %s ' +
          ' Left Join %s On T_Truck=L_Truck ' +
          ' Left Join %s On D_Name=''%s'' And D_ParamB=L_StockNo ' +
          'Where L_ID=''%s''';
  //xxxxx

  nStr := Format(nStr, [sTable_Bill, sTable_Truck, sTable_SysDict,
          sFlag_StockItem, EditBill.Text]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      ShowMsg('交货单已丢失', sHint);
      Exit;
    end;

    nData := StrWithWidth(FieldByName('L_Truck').AsString, 12, 1, #32, True);
    //12位存放车牌

    nStr := Format('%.2f', [FieldByName('L_Value').AsFloat]);
    nStr := StringReplace(nStr, '.', '', [rfReplaceAll]);//去小数点
    nData := nData + StrWithWidth(nStr, 4, 2, '0', True);
    //4位存放装车量

    nStr := IntToStr(FieldByName('T_TruckLong').AsInteger);
    nData := nData + #32#32 + StrWithWidth(nStr, 6, 2, '0', True);
    //8位存放车长

    nStr := IntToStr(FieldByName('T_TruckWidth').AsInteger);
    nData := nData + StrWithWidth(nStr, 4, 2, '0', True);
    //4位存放车宽

    nStr := FieldByName('D_Sign').AsString;
    nData := nData + StrWithWidth(nStr, 2, 2, '0', True) + #32#32;
    //4位存放仓位
  end;

  Result := gMHReaderManager.WriteCardData(nData, '0101');
  //写卡
end;

//Desc: 保存磁卡
procedure TfFormCard.BtnOKClick(Sender: TObject);
var nRet: Boolean;
begin
  EditCard.Text := Trim(EditCard.Text);
  if EditCard.Text = '' then
  begin
    ActiveControl := EditCard;
    EditCard.SelectAll;

    ShowMsg('请输入有效卡号', sHint);
    Exit;
  end;

  if FParam.FCommand = cCmd_GetData then
  begin
    ModalResult := mrOk;
    Exit;
  end;

  {$IFDEF UseMHICCard}
  if WriteICCard() then //write ic
  begin
    ShowMsg('写卡成功', sHint);
  end else
  begin
    ShowMsg('写卡失败', sHint);
    Exit;
  end; 
  {$ENDIF}

  if FParam.FParamC = sFlag_Provide then
       nRet := SaveOrderCard(EditBill.Text, EditCard.Text)
  else
  if FParam.FParamC = sFlag_DuanDao then
       nRet := SaveDDCard(EditBill.Text, EditCard.Text)
  else
    nRet := SaveBillCard(EditBill.Text, EditCard.Text);

  if nRet then
    ModalResult := mrOk;
  //done
end;

initialization
  gControlManager.RegCtrl(TfFormCard, TfFormCard.FormID);
end.
