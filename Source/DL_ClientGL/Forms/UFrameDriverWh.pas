unit UFrameDriverWh;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel,
  UBitmapPanel, cxSplitter, dxLayoutControl, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, USysConst;

type
  TfFrameDriverWh = class(TfFrameNormal)
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameDriverWh: TfFrameDriverWh;

implementation
  uses UMgrControl, USysDB, UFormBase, UDataModule, ULibFun;
{$R *.dfm}

procedure TfFrameDriverWh.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormDriverWh, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

class function TfFrameDriverWh.FrameID: integer;
begin
  Result := cFI_FrameDriverWh;
end;

function TfFrameDriverWh.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_DriverWh;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
end;

procedure TfFrameDriverWh.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormDriverWh, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

procedure TfFrameDriverWh.BtnDelClick(Sender: TObject);
var nStr,nDriverWh,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nDriverWh := SQLQuery.FieldByName('D_Name').AsString;
    nStr    := Format('确定要删除司机姓名[ %s ]吗?', [nDriverWh]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_DriverWh, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除[ %s ]司机姓名信息.';
    nEvent := Format(nEvent, [nDriverWh]);
    FDM.WriteSysLog(sFlag_CommonItem, nDriverWh, nEvent);

    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameDriverWh, TfFrameDriverWh.FrameID);

end.
