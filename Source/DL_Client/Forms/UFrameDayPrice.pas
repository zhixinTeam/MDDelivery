unit UFrameDayPrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, StdCtrls, cxDropDownEdit,
  cxTextEdit, cxMaskEdit, cxCalendar;

type
  TfFrameDayPrice = class(TfFrameNormal)
    editDate: TcxDateEdit;
    dxLayout1Item1: TdxLayoutItem;
    editType: TcxComboBox;
    dxLayout1Item2: TdxLayoutItem;
    Button1: TButton;
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
    function MakeSQlByArea:string;
    function MakeSQlByStockType:string;
  end;

var
  fFrameDayPrice: TfFrameDayPrice;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

class function TfFrameDayPrice.FrameID: integer;
begin
  Result := cFI_FrameDayPrice;
end;

function TfFrameDayPrice.MakeSQlByArea: string;
var
  nStr:string;
begin
  nStr := 'select SUM(L_Value*(L_Price-L_Freight))/sum(L_Value) as L_Price, '+
            'L_Area as L_GroupItem from %s '+
            'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
            'group by L_Area';
  Result := Format(nStr,[sTable_Bill,
            Date2Str(editdate.Date),Date2Str(editdate.Date+1)]);
end;

function TfFrameDayPrice.MakeSQlByStockType: string;
var
  nStr:string;
begin
  nStr := 'select SUM(L_Value*(L_Price-L_Freight))/sum(L_Value) as L_Price,'+
          'L_StockName as L_GroupItem from %s '+
          'where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_StockName '+
          'Union All '+
          'select SUM(L_Value*(L_Price-L_Freight))/sum(L_Value) as L_Price,'+
          'case L_Type when ''D'' then ''袋装'' when ''S'' then ''散装'' end '+
          ' from %s where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_Type '+
          'Union All '+
          'select SUM(L_Value*(L_Price-L_Freight))/sum(L_Value) as L_Price,'+
          'case L_CusType when ''A'' then ''A类客户'' when ''B'' then ''B类客户'' end '+
          ' from %s where L_OutFact>=''%s'' and L_OutFact<''%s'' '+
          'group by L_CusType ';
  Result := Format(nStr,[sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1),
                        sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1),
                        sTable_Bill,Date2Str(editdate.Date),Date2Str(editdate.Date+1)]);
end;

procedure TfFrameDayPrice.Button1Click(Sender: TObject);
begin
  InitFormData(FWhere);
end;

function TfFrameDayPrice.InitFormDataSQL(const nWhere: string): string;
var
  nDate: TDate;
  nValue: Double;
  nStr: string;
begin
  FEnableBackDB := True;
  nDate := editdate.Date;

  if editType.itemindex = 0 then
    Result := MakeSQlByArea
  else
    Result := MakeSQlByStockType;
end;

procedure TfFrameDayPrice.OnCreateFrame;
begin
  inherited;
  editDate.Date := Date;
end;

initialization
  gControlManager.RegCtrl(TfFrameDayPrice, TfFrameDayPrice.FrameID);
end.
