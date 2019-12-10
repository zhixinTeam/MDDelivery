unit UFrameNotice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxDropDownEdit, cxTextEdit,
  cxMaskEdit, cxButtonEdit;

type
  TfFrameNotice = class(TfFrameNormal)
    editDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    editCusType: TcxComboBox;
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
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameNotice: TfFrameNotice;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun;


{ TfFrameNotice }

class function TfFrameNotice.FrameID: integer;
begin
  Result := cFI_FrameNotice;
end;

function TfFrameNotice.InitFormDataSQL(const nWhere: string): string;
var
  nStr, nCusType: string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  if editCusType.ItemIndex = 0 then
    nCusType := 'A'
  else
    nCusType := 'B';
  
  nStr := 'select L_CusID,L_CusName,L_StockNo,L_StockName,L_Price,'+
          'isnull(L_Freight,0) as L_Freight,L_Price-isnull(L_Freight,0) '+
          'as L_NetPrice,sum(L_Value) as L_Value,sum(L_Value)*L_Price as TotalMoney from $Bill '+
          'Where (L_OutFact>=''$St'' and L_OutFact <''$End'') '+
          'and L_CusType=''$Type''';
          
  nStr := MacroValue(nStr,[MI('$Bill', sTable_Bill),MI('$St', Date2Str(FStart)),
          MI('$End', Date2Str(FEnd + 1)), MI('$Type', nCusType)]);

  nStr := nStr +' group by L_CusID,L_CusName,L_Price,L_Freight,L_StockNo,'+
          'L_StockName order by L_StockNo,l_cusname';

  Result := nStr;
end;

procedure TfFrameNotice.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
  
end;

procedure TfFrameNotice.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameNotice.editDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFrameNotice, TfFrameNotice.FrameID);
end.
