unit UFormPoundOldValue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMemo;

type
  TFormPoundOldValue = class(TfFormNormal)
    EditD_SerialNo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditNetWeight: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditOldValue: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  protected
    { Private declarations }
    FListA: TStrings;

    nLID,nP_Order:string;
    nOldPoundOldValue:string;

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
  FormPoundOldValue: TFormPoundOldValue;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormBase, UMgrControl, UAdjustForm, UDataModule,
  USysPopedom, USysGrid, USysDB, USysConst, USysBusiness,uSuperObject;

var
  gParam: PFormCommandParam = nil;
  //全局使用
  
{ TFormPoundOldValue }

class function TFormPoundOldValue.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var
  nModifyStr: string;
begin
  Result := nil;
  if Assigned(nParam) then
    gParam := nParam
  else Exit;
  
  nModifyStr :=gParam.FParamA;

  with TFormPoundOldValue.Create(Application) do
  try
    Caption := '原厂净重';

    FListA.Text := nModifyStr;
    InitFormData('');
    
    gParam.FCommand := cCmd_ModalResult;
    gParam.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TFormPoundOldValue.FormID: integer;
begin
  Result := cFI_FormPoundOldValue;
end;

procedure TFormPoundOldValue.FormCreate(Sender: TObject);
begin
  inherited;
  FListA    := TStringList.Create;
end;

procedure TFormPoundOldValue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ReleaseCtrlData(Self);
  FListA.Free;
end;

procedure TFormPoundOldValue.InitFormData(const nID: string);
var
  i:Integer;
  nStr: string;
  ReJo, ParamJo, BodyJo, OneJo, ReBodyJo : ISuperObject;
  ArrsM,ArrsN: TSuperArray;
begin
  nStr := ' select *,(P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeight From %s c  where c.P_ID = ''%s'' ';
  nStr := Format(nStr,[sTable_PoundLog,FListA.Strings[0]]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;

    nLID                := FieldByName('P_ID').AsString;
    nP_Order            := FieldByName('P_Order').AsString;
    nOldPoundOldValue   := FieldByName('P_OldValue').AsString;
    EditD_SerialNo.Text := FieldByName('P_ID').AsString;
    EditTruck.Text      := FieldByName('P_Truck').AsString;
    EditNetWeight.Text  := FloatToStr(FieldByName('P_NetWeight').AsFloat);
    EditOldValue.Text   := FloatToStr(FieldByName('P_OldValue').AsFloat);
  end;

end;

procedure TFormPoundOldValue.WriteOptionLog(const LID: string);
var nEvent: string;
begin
  nEvent := '';

  try
    if nOldPoundOldValue <> EditOldValue.Text then
    begin
      nEvent := nEvent + '原厂净重由 [ %s ] --> [ %s ];';
      nEvent := Format(nEvent, [nOldPoundOldValue, EditOldValue.Text]);
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

procedure TFormPoundOldValue.BtnOKClick(Sender: TObject);
var nStr,nSQL,nOID,nDID: string;
    nIdx: Integer;
begin
  if not QueryDlg('确定要修改上述原厂净重数据吗?', sHint) then Exit;

  if not IsNumber(EditOldValue.Text,True) then
  begin
    EditOldValue.SetFocus;
    nStr := '请输入有效原厂净重';
    ShowMsg(nStr,sHint);
    Exit;
  end;

  for nIdx := 0 to FListA.Count - 1 do
  begin
    nSQL := ' Update %s Set P_OldValue = ''%s'' Where P_ID = ''%s'' ';
    nSQL := Format(nSQL, [sTable_PoundLog,EditOldValue.Text,
                                          FListA.Strings[nIdx]]);
    FDM.ExecuteSQL(nSQL);
    WriteOptionLog(FListA.Strings[nIdx]);
  end;

  ModalResult := mrOK;
  nStr := '保存原厂净重成功。';
  ShowMsg(nStr, sHint);
end;

initialization
  gControlManager.RegCtrl(TFormPoundOldValue, TFormPoundOldValue.FormID);
end.
