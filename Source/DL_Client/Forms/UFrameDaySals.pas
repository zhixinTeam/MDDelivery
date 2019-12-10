unit UFrameDaySals;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, StdCtrls;

type
  TfFrameDaySales = class(TfFrameNormal)
    editdate: TcxDateEdit;
    dxLayout1Item1: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item2: TdxLayoutItem;
    editType: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure OnCreateFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
    function MakeSQlByArea(nValue:Double):string;
    function MakeSQlByStockType(nValue:Double):string;
  end;

var
  fFrameDaySales: TfFrameDaySales;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

{ TfFrameDaySales }

class function TfFrameDaySales.FrameID: integer;
begin
  Result := cFI_FrameDaySales;
end;

function TfFrameDaySales.InitFormDataSQL(const nWhere: string): string;
var
  nDate: TDate;
  nValue: Double;
  nStr: string;
begin
  FEnableBackDB := True;
  nDate := editdate.Date;

  nStr := 'select sum(L_Value) as L_Value from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s''';
  nStr := Format(nStr,[sTable_Bill, Date2Str(nDate),Date2Str(nDate+1)]);
  with FDM.QueryTemp(nStr) do
    nValue := fieldbyname('L_Value').AsFloat;
  if nValue = 0 then
  begin
    ShowMsg('所选日期当日销量为零.',sHint);
    Exit;
  end;
  if editType.itemindex = 0 then
    Result := MakeSQlByArea(nValue)
  else
    Result := MakeSQlByStockType(nValue);
end;

function TfFrameDaySales.MakeSQlByArea(nValue: Double): string;
var
  nStr:string;
begin
  nStr := 'select sum(L_Value) as Value,L_Area as L_GroupItem, '+
            'round(sum(L_Value)/%s*100,2) as L_Percent from %s '+
            'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
            'group by L_Area';
  Result := Format(nStr,[FloatToStr(nValue),sTable_Bill,
            Date2Str(editdate.Date),Date2Str(editdate.Date+1)]);
end;

procedure TfFrameDaySales.OnCreateFrame;
begin
  inherited;
  editdate.Date := Date;
end;

procedure TfFrameDaySales.Button1Click(Sender: TObject);
begin
  InitFormData(FWhere);
end;

function TfFrameDaySales.MakeSQlByStockType(nValue: Double): string;
var
  nStr:string;
begin
  nStr := 'select sum(L_Value) as Value,L_StockName as L_GroupItem, '+
          'round(sum(L_Value)/%s*100,2) as L_Percent from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_StockName '+
          'Union All '+
          'select sum(L_Value) as Value, '+
          'case L_Type when ''D'' then ''袋装'' when ''S'' then ''散装'' end, '+
          'round(sum(L_Value)/%s*100,2) as L_Percent from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_Type '+
          'Union All '+
          'select sum(L_Value) as Value,'+
          'case L_CusType when ''A'' then ''A类客户'' when ''B'' then ''B类客户'' end, '+
          'round(sum(L_Value)/%s*100,2) as L_Percent from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_CusType ';
  Result := Format(nStr,[FloatToStr(nValue),sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1),
                        FloatToStr(nValue),sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1),
                        FloatToStr(nValue),sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1)]);
end;

initialization
  gControlManager.RegCtrl(TfFrameDaySales, TfFrameDaySales.FrameID);
end.
