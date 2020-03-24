{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 矿点信息管理
*******************************************************************************}
unit UFormKSKD;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormKSKD = class(TfFormNormal)
    EditNum1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditNum2: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditNum3: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FRID: string;
    procedure LoadFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormKSKD.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  
  with TfFormKSKD.Create(Application) do
  try
    LoadFormData;
    ShowModal;
  finally
    Free;
  end;
end;

class function TfFormKSKD.FormID: integer;
begin
  Result := cFI_FormKSKD;
end;

procedure TfFormKSKD.LoadFormData;
var nStr: string;
begin
  nStr := 'Select * From %s ';
  nStr := Format(nStr, [sTable_KSKD]);
  FDM.QueryTemp(nStr);

  with FDM.SqlTemp do
  begin
    if (RecordCount < 1) then
    begin
      Exit;
    end;
    FRID          := FieldByName('R_ID').AsString;
    EditNum1.Text := FieldByName('P_Num1').AsString;
    EditNum2.Text := FieldByName('P_Num2').AsString;
    EditNum3.Text := FieldByName('P_Num3').AsString;
  end;
end;

//Desc: 保存
procedure TfFormKSKD.BtnOKClick(Sender: TObject);
var nStr,nNum1,nNum2,nNum3,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  nNum1 := UpperCase(Trim(EditNum1.Text));
  if nNum1 = '' then
  begin
    ActiveControl := EditNum1;
    ShowMsg('请输入净重超过具体值', sHint);
    Exit;
  end;

  nNum2 := UpperCase(Trim(EditNum2.Text));
  if nNum2 = '' then
  begin
    ActiveControl := EditNum2;
    ShowMsg('请输入默认净重值', sHint);
    Exit;
  end;

  nNum3 := UpperCase(Trim(EditNum3.Text));
  if nNum3 = '' then
  begin
    ActiveControl := EditNum3;
    ShowMsg('请输入其余扣吨数', sHint);
    Exit;
  end;

  if FRID <> '' then
  begin
    nStr := 'Update %s set P_Num1=%g, P_Num2=%g, P_Num3=%g where R_ID = ''%s'' ';
    nStr := Format(nStr,[sTable_KSKD,StrToFloat(EditNum1.Text),StrToFloat(EditNum2.Text),StrToFloat(EditNum3.Text),FRID]);
    FDM.ExecuteSQL(nStr);
  end
  else
  begin
    nStr := MakeSQLByStr([SF('P_Num1', EditNum1.Text),
            SF('P_Num2', EditNum2.Text),
            SF('P_Num3', EditNum3.Text)
            ], sTable_KSKD, '', True);
    FDM.ExecuteSQL(nStr);
  end;

  ModalResult := mrOk;
  ShowMsg('矿山扣吨规则保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormKSKD, TfFormKSKD.FormID);
end.
