unit UFormPoundTwoKZ;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMemo;

type
  TFormPoundTwoKZ = class(TfFormNormal)
    EditD_SerialNo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditKZ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditStockName: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditPoundTwoKZ: TcxTextEdit;
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
    nOldPoundTwoKZ:string;

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
  FormPoundTwoKZ: TFormPoundTwoKZ;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule,
  USysPopedom, USysGrid, USysDB, USysConst, USysBusiness,uSuperObject;

var
  gParam: PFormCommandParam = nil;
  //全局使用
  
{ TFormPoundTwoKZ }

class function TFormPoundTwoKZ.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nModifyStr: string;
begin
  Result := nil;
  if Assigned(nParam) then
    gParam := nParam
  else Exit;
  
  nModifyStr :=gParam.FParamA;

  with TFormPoundTwoKZ.Create(Application) do
  try
    Caption := '磅房二次扣重';

    FListA.Text := nModifyStr;
    InitFormData('');
    
    gParam.FCommand := cCmd_ModalResult;
    gParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TFormPoundTwoKZ.FormID: integer;
begin
  Result := cFI_FormPoundTwoKZ;
end;

procedure TFormPoundTwoKZ.FormCreate(Sender: TObject);
begin
  inherited;
  FListA    := TStringList.Create;
end;

procedure TFormPoundTwoKZ.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ReleaseCtrlData(Self);
  FListA.Free;
end;

procedure TFormPoundTwoKZ.InitFormData(const nID: string);
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
    nOldPoundTwoKZ         := FieldByName('P_KZValue').AsString;
    EditD_SerialNo.Text := FieldByName('D_SerialNo').AsString;
    EditTruck.Text      := FieldByName('P_Truck').AsString;
    EditKZ.Text         := FloatToStr(FieldByName('P_KZValueEx').AsFloat);
    EditPoundTwoKZ.Text    := FloatToStr(FieldByName('P_KZValue').AsFloat);
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

procedure TFormPoundTwoKZ.WriteOptionLog(const LID: string);
var nEvent: string;
begin
  nEvent := '';

  try
    if nOldPoundTwoKZ <> EditPoundTwoKZ.Text then
    begin
      nEvent := nEvent + '磅房扣重由 [ %s ] --> [ %s ];';
      nEvent := Format(nEvent, [nOldPoundTwoKZ, EditPoundTwoKZ.Text]);
    end;

    if nEvent <> '' then
    begin
      nEvent := '磅单 [ %s ] 参数已被操作人[ %s ]修改:' + nEvent;
      nEvent := Format(nEvent, [LID,gSysParam.FUserID]);
    end;
    
    if nEvent <> '' then
    begin
      FDM.WriteSysLog(sFlag_BillItem, LID, nEvent);
    end;
  except
  end;
end;

procedure TFormPoundTwoKZ.BtnOKClick(Sender: TObject);
var nStr,nSQL,nOID,nDID: string;
    nIdx: Integer;
begin
  if not QueryDlg('确定要修改上述磅单数据吗?', sHint) then Exit;

  if not IsNumber(EditPoundTwoKZ.Text,True) then
  begin
    EditPoundTwoKZ.SetFocus;
    nStr := '请输入有效扣重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    nSQL := 'Update %s Set P_KZValue=''%s'',P_AdjustMan=''%s'',P_AdjustTime=%s Where P_ID=''%s'' ';
    nSQL := Format(nSQL, [sTable_PoundLog,EditPoundTwoKZ.Text,
                                          gSysParam.FUserID,
                                          FDM.SQLServerNow,
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

      nStr := ' Update P_OrderDtl Set D_KZValue = %f,D_AdjustMan=''%s'',D_AdjustTime=%s Where D_ID=''%s''';
      nStr := Format(nStr, [StrToFloatDef(Trim(EditPoundTwoKZ.Text),0),gSysParam.FUserID,FDM.SQLServerNow,Trim(nP_Order)]);
      FDM.ExecuteSQL(nStr);
    end;
  end;

  ModalResult := mrOK;
  nStr := '磅房二次扣重完成';
  ShowMsg(nStr, sHint);
end;

initialization
  gControlManager.RegCtrl(TFormPoundTwoKZ, TFormPoundTwoKZ.FormID);
end.
