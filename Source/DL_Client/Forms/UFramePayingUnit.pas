unit UFramePayingUnit;

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
  TfFramePayingUnit = class(TfFrameNormal)
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure OnCreateFrame; override;

    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFramePayingUnit: TfFramePayingUnit;

implementation
  uses UMgrControl, USysDB, UFormBase, UDataModule, ULibFun;
{$R *.dfm}

procedure TfFramePayingUnit.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormPayingUnit, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

class function TfFramePayingUnit.FrameID: integer;
begin
  Result := cFI_FramePayingUnit;
end;

function TfFramePayingUnit.InitFormDataSQL(const nWhere: string): string;
begin
  Result := ' Select A.*,B.C_Name as P_CustName,C.S_Name as P_SaleName From S_PayingUnit A '+
            ' Left join S_Customer B on A.P_CustID = B.C_ID ' +
            ' Left join S_Salesman C on A.P_SaleID = C.S_ID ';
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
end;

procedure TfFramePayingUnit.BtnEditClick(Sender: TObject);
begin
  //
end;

procedure TfFramePayingUnit.BtnDelClick(Sender: TObject);
var nStr,nPayingUnit,nEvent: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nPayingUnit := SQLQuery.FieldByName('P_PayingUnit').AsString;
    nStr    := Format('确定要删除交款单位[ %s ]吗?', [nPayingUnit]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_PayingUnit, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);

    nEvent := '删除[ %s ]交款单位信息.';
    nEvent := Format(nEvent, [nPayingUnit]);
    FDM.WriteSysLog(sFlag_CommonItem, nPayingUnit, nEvent);

    InitFormData(FWhere);
  end;
end;

procedure TfFramePayingUnit.OnCreateFrame;
begin
  BtnEdit.Visible := False;
  inherited;
end;

initialization
  gControlManager.RegCtrl(TfFramePayingUnit, TfFramePayingUnit.FrameID);

end.
