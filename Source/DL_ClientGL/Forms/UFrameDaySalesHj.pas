unit UFrameDaySalesHj;
{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxButtonEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit;

type
  TFrameDaySalesHj = class(TfFrameNormal)
    editType: TcxComboBox;
    dxLayout1Item1: TdxLayoutItem;
    editDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    procedure editDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FrameTitle: string; override;
  public
    class function FrameID: integer; override;
  end;

var
  FrameDaySalesHj: TFrameDaySalesHj;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

class function TFrameDaySalesHj.FrameID: integer;
begin
  Result := cFI_FrameDaySalesHj;
end;

function TFrameDaySalesHj.InitFormDataSQL(const nWhere: string): string;
var
  nStr, nTypeStr, nDate : string;
begin
  FEnableBackDB := True;
  
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  nDate := EditDate.Text;

  if editType.ItemIndex = 0 then
    nTypeStr := ''
  else if editType.ItemIndex = 1 then
    nTypeStr := 'and L_CusType=''A'''
  else if editType.ItemIndex = 2 then
    nTypeStr := 'and L_CusType=''B''';

  nStr := 'Select '+''''+nDate+''''+'as L_SelDate, L_CusID, L_CusName,L_XHSpot, L_Lading, L_StockName,L_HYDan,'+
          'Sum(L_Value) L_Value From  S_Bill Where L_Date>=''%s'' And '+
          'L_Date<''%s''' + nTypeStr + 'Group by L_CusID, L_CusName,L_XHSpot,'+
          'L_Lading, L_stockName,L_HYDan Order by L_StockName';
  Result := Format(nStr,[Date2Str(FStart),Date2Str(FEnd + 1)]);
end;

procedure TFrameDaySalesHj.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TFrameDaySalesHj.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;                        
end;

procedure TFrameDaySalesHj.editDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

function TFrameDaySalesHj.FrameTitle: string;
begin
  {$IFDEF SXDY}
  titlebar.Caption := '东义骨料当日销量合计';
  Result  := '东义骨料当日销量合计';
  {$ENDIF}
end;

initialization
  gControlManager.RegCtrl(TFrameDaySalesHj, TFrameDaySalesHj.FrameID);
end.
