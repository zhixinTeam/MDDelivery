unit UFrameXHSpot;

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
  TfFrameXHSpot = class(TfFrameNormal)
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
  fFrameXHSpot: TfFrameXHSpot;

implementation
  uses UMgrControl, USysDB, UFormBase, UDataModule, ULibFun;
{$R *.dfm}

procedure TfFrameXHSpot.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormXHSpot, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

class function TfFrameXHSpot.FrameID: integer;
begin
  Result := cFI_FrameXHSpot;
end;

function TfFrameXHSpot.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_XHSpot;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
end;

procedure TfFrameXHSpot.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('R_ID').AsString;
    CreateBaseFormItem(cFI_FormXHSpot, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

procedure TfFrameXHSpot.BtnDelClick(Sender: TObject);
var nStr,nXHSpot,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nXHSpot := SQLQuery.FieldByName('X_XHSpot').AsString;
    nStr    := Format('确定要删除卸货地点[ %s ]吗?', [nXHSpot]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_XHSpot, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除[ %s ]卸货地点信息.';
    nEvent := Format(nEvent, [nXHSpot]);
    FDM.WriteSysLog(sFlag_CommonItem, nXHSpot, nEvent);

    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameXHSpot, TfFrameXHSpot.FrameID);

end.
