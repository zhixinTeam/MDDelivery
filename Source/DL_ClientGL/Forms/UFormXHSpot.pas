{*******************************************************************************
  作者: dmzn@163.com 2014-11-25
  描述: 车辆档案管理
*******************************************************************************}
unit UFormXHSpot;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormBase, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxDropDownEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxCheckBox;

type
  TfFormXHSpot = class(TfFormNormal)
    EditXHSpot: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  protected
    { Protected declarations }
    FXHSPot: string;
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
  ULibFun, UMgrControl, UDataModule, UFormCtrl, USysDB, USysConst;

class function TfFormXHSpot.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormXHSpot.Create(Application) do
  try
    if nP.FCommand = cCmd_AddData then
    begin
      Caption := '卸货地点 - 添加';
      FXHSPot := '';
    end;

    if nP.FCommand = cCmd_EditData then
    begin
      Caption := '卸货地点 - 修改';
      FXHSPot := nP.FParamA;
    end;

    LoadFormData(FXHSPot); 
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormXHSpot.FormID: integer;
begin
  Result := cFI_FormXHSpot;
end;

procedure TfFormXHSpot.LoadFormData(const nID: string);
var nStr: string;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_XHSpot, nID]);
    FDM.QueryTemp(nStr);
  end;

  with FDM.SqlTemp do
  begin
    if (nID = '') or (RecordCount < 1) then
    begin
      Exit;
    end;

    EditXHSpot.Text := FieldByName('X_XHSpot').AsString;
  end;
end;

//Desc: 保存
procedure TfFormXHSpot.BtnOKClick(Sender: TObject);
var nStr,nXHSpot,nU,nV,nP,nVip,nGps,nEvent: string;
begin
  nXHSpot := UpperCase(Trim(EditXHSpot.Text));
  if nXHSpot = '' then
  begin
    ActiveControl := EditXHSpot;
    ShowMsg('请输入卸货地点', sHint);
    Exit;
  end;
  if FXHSPot = '' then
  begin
    nStr := ' select X_XHSpot from %s where X_XHSpot=''%s''';
    nStr := Format(nStr,[sTable_XHSpot, nXHSpot]);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount>0 then
      begin
        ActiveControl := EditXHSpot;
        ShowMsg('已存在此卸货地点', sHint);
        Exit;
      end;
    end;
  end;
  
  if FXHSPot = '' then
       nStr := ''
  else nStr := SF('R_ID', FXHSPot, sfVal);

  nStr := MakeSQLByStr([SF('X_XHSpot', nXHSpot)
          ], sTable_XHSpot, nStr, FXHSPot = '');
  FDM.ExecuteSQL(nStr);

  if FXHSPot = '' then
        nEvent := '添加[ %s ]卸货地点信息.'
  else  nEvent := '修改[ %s ]卸货地点信息.';
  nEvent := Format(nEvent, [nXHSpot]);
  FDM.WriteSysLog(sFlag_CommonItem, nXHSpot, nEvent);


  ModalResult := mrOk;
  ShowMsg('卸货地点信息保存成功', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormXHSpot, TfFormXHSpot.FormID);
end.
