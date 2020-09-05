{*******************************************************************************
  作者: juner11212436@163.com 2018-08-24
  描述: 模式设置
*******************************************************************************}
unit UFormOnLineSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxControls,
  cxContainer, cxEdit, cxTextEdit, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxMaskEdit,
  cxDropDownEdit;

type
  TfFormOnLineSet = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditOnLine: TcxComboBox;
    dxLayoutControl1Item2: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, USysPopedom;

//------------------------------------------------------------------------------
class function TfFormOnLineSet.CreateForm;
var nStr: string;
begin
  Result := nil;

  with TfFormOnLineSet.Create(Application) do
  begin
    nStr := 'select D_Value from %s where D_Name=''%s'' ';
    nStr := Format(nStr, [sTable_SysDict, sFlag_VerifiyCard]);

    with FDM.QuerySQL(nStr) do
    if RecordCount > 0 then
    begin
      nStr:=Fields[0].AsString;
      if nStr = sFlag_No then
        EditOnLine.ItemIndex := 1
      else
        EditOnLine.ItemIndex := 0;
    end;
    EditOnLine.Enabled := gSysParam.FIsAdmin;
    BtnOK.Enabled      := gPopedomManager.HasPopedom(nPopedom, sPopedom_Edit);
    ShowModal;
    Free;
  end;
end;

class function TfFormOnLineSet.FormID: integer;
begin
  Result := cFI_FormOnLineSet;
end;

//------------------------------------------------------------------------------
//Desc: 保存
procedure TfFormOnLineSet.BtnOKClick(Sender: TObject);
var nStr,nEvent: string;
begin
  if EditOnLine.ItemIndex = 0 then
  begin
    nStr :=' Update Sys_Dict set D_Value=''Y'',D_ParamB=NULL where D_Name=''VerifiyCard'' ';

    nEvent := '[ %s ]把取卡校验模式设置为校验模式.';
    nEvent := Format(nEvent, [gSysParam.FUserID]);
    FDM.WriteSysLog(sFlag_VerifiyCard, gSysParam.FUserID, nEvent);
  end else
  begin
    nStr :=' Update Sys_Dict set D_Value=''N'',D_ParamB=''%s'' where D_Name=''VerifiyCard'' ';
    nStr := Format(nStr, [DateTime2Str(Now)]);

    nEvent := '[ %s ]把取卡校验模式设置为取消校验模式.';
    nEvent := Format(nEvent, [gSysParam.FUserID]);
    FDM.WriteSysLog(sFlag_VerifiyCard, gSysParam.FUserID, nEvent);
  end;

  if FDM.ExecuteSQL(nStr, False) > 0 then
  begin
    ModalResult := mrOK;
    ShowMsg('模式切换成功', sHint);
  end else ShowMsg('切换模式时发生未知错误', '保存失败');
end;

initialization
  gControlManager.RegCtrl(TfFormOnLineSet, TfFormOnLineSet.FormID);
end.
