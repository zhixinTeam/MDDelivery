unit UFormPoundKZ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMemo;

type
  TFormPoundKZ = class(TfFormNormal)
    EditD_SerialNo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditKZ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditPoundKZ: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditJYJL: TcxMemo;
    dxLayout1Item8: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  protected
    { Private declarations }
    FListA: TStrings;

    nLID,nP_Order:string;
    nOldPoundKZ:string;

    procedure InitFormData(const nID: string);
    //载入数据
    procedure WriteOptionLog(const LID: string);
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

var
  FormPoundKZ: TFormPoundKZ;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule,
  USysPopedom, USysGrid, USysDB, USysConst, USysBusiness,uSuperObject;

var
  gParam: PFormCommandParam = nil;
  //全局使用
  
{ TFormPoundKZ }

class function TFormPoundKZ.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nModifyStr: string;
begin
  Result := nil;
  if Assigned(nParam) then
    gParam := nParam
  else Exit;
  
  nModifyStr :=gParam.FParamA;

  with TFormPoundKZ.Create(Application) do
  try
    Caption := '一次扣重';

    FListA.Text := nModifyStr;
    InitFormData('');
    
    gParam.FCommand := cCmd_ModalResult;
    gParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TFormPoundKZ.FormID: integer;
begin
  Result := cFI_FormPoundKZ;
end;

procedure TFormPoundKZ.FormCreate(Sender: TObject);
begin
  inherited;
  FListA    := TStringList.Create;
end;

procedure TFormPoundKZ.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ReleaseCtrlData(Self);
  FListA.Free;
end;

procedure TFormPoundKZ.InitFormData(const nID: string);
var
  i:Integer;
  nStr: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  ArrsM,ArrsN: TSuperArray;
begin
  nStr := 'select * From %s c, %s d where c.P_Order = d.D_ID  and c.P_ID = ''%s'' ';
  nStr := Format(nStr,[sTable_PoundLog,sTable_OrderDtl,FListA.Strings[0]]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    nLID                := FieldByName('P_ID').AsString;
    nP_Order            := FieldByName('P_Order').AsString;
    nOldPoundKZ         := FieldByName('P_KZValue').AsString;
    EditD_SerialNo.Text := FieldByName('D_SerialNo').AsString;
    EditTruck.Text      := FieldByName('P_Truck').AsString;
    EditKZ.Text         := FloatToStr(FieldByName('P_KZValueEx').AsFloat);
    EditPoundKZ.Text    := FloatToStr(FieldByName('P_KZValue').AsFloat);
    EditStockName.Text  := FieldByName('P_MName').AsString;
  end;

  nStr := 'select * From YCLquality_data where collector_num = ''%s''';  //
  nStr := Format(nStr,[EditD_SerialNo.Text]);

  EditJYJL.Clear;
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    nStr := FieldByName('property_data').AsString;

    if nStr <> '' then
    begin
      ArrsM := SO(nStr).AsArray;
      if ArrsM.Length = 0 then Exit;

      for i:=0 to ArrsM.Length - 1 do
      begin
        nStr := ArrsM[i].S['propertyName'];
        nStr := nStr+' : ' + ArrsM[i].S['assayValue'];

        EditJYJL.Text := EditJYJL.Text + nStr +#13#10+#13#10;
      end;
    end;
  end;
end;

procedure TFormPoundKZ.WriteOptionLog(const LID: string);
var nEvent: string;
begin
  nEvent := '';

  try
    if nOldPoundKZ <> EditPoundKZ.Text then
    begin
      nEvent := nEvent + '一次扣重由 [ %s ] --> [ %s ];';
      nEvent := Format(nEvent, [nOldPoundKZ, EditPoundKZ.Text]);
    end;

    if nEvent <> '' then
    begin
      nEvent := '原材料记录 [ %s ] 参数已被操作人[ %s ]修改:' + nEvent;
      nEvent := Format(nEvent, [LID,gSysParam.FUserID]);
    end;
    
    if nEvent <> '' then
    begin
      FDM.WriteSysLog(sFlag_BillItem, LID, nEvent);
    end;
  except
  end;
end;

procedure TFormPoundKZ.BtnOKClick(Sender: TObject);
var nStr,nSQL,nOID,nDID: string;
    nIdx: Integer;
begin
  if not QueryDlg('确定要修改上述扣重数据吗?', sHint) then Exit;

  if not IsNumber(EditPoundKZ.Text,True) then
  begin
    EditPoundKZ.SetFocus;
    nStr := '请输入有效扣重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    nSQL := 'Update %s Set P_KZValue=''%s'' Where P_ID=''%s'' ';
    nSQL := Format(nSQL, [sTable_PoundLog,EditPoundKZ.Text,
                                          FListA.Strings[nIdx]]);
    FDM.ExecuteSQL(nSQL);
    WriteOptionLog(FListA.Strings[nIdx]);

    nSQL := ' Select D_OID  from %s where D_ID = ''%s'' ';
    nSQL := Format(nSQL,[sTable_OrderDtl,nP_Order]);
    with FDM.QueryTemp(nSQL) do
    begin
      if RecordCount < 1 then
        Continue;

      nDID := FieldByName('D_OID').AsString;

      nStr := ' Update P_OrderDtl Set D_KZValue = %f Where D_ID=''%s''';
      nStr := Format(nStr, [StrToFloatDef(Trim(EditPoundKZ.Text),0) ,Trim(nP_Order)]);
      FDM.ExecuteSQL(nStr);
    end;
  end;

  ModalResult := mrOK;
  nStr := '一次扣重完成';
  ShowMsg(nStr, sHint);
end;

initialization
  gControlManager.RegCtrl(TFormPoundKZ, TFormPoundKZ.FormID);
end.
