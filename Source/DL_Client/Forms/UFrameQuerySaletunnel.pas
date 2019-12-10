{*******************************************************************************
  作者: dmzn@163.com 2012-03-26
  描述: 发货明细
*******************************************************************************}
unit UFrameQuerySaletunnel;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxSpinEdit, cxTimeEdit, StdCtrls, Buttons,
  cxDropDownEdit, cxCalendar;

type
  TfFrameSaletunnelQuery = class(TfFrameNormal)
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    btnOK1: TBitBtn;
    dxLayout1Item6: TdxLayoutItem;
    dxLayout1Item7: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    btnOK2: TBitBtn;
    dxLayout1Item4: TdxLayoutItem;
    btnOK3: TBitBtn;
    dxLayout1Item8: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure btnOK1Click(Sender: TObject);
    procedure btnOK2Click(Sender: TObject);
    procedure btnOK3Click(Sender: TObject);
  private
    procedure SaveGroupTmp(const nGroup: string);
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    FGL: Boolean;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataModule;

class function TfFrameSaletunnelQuery.FrameID: integer;
begin
  Result := cFI_FrameSaletunnelQuery;
end;

procedure TfFrameSaletunnelQuery.OnCreateFrame;
var
  nSQL: string;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
  nSQL := ' Delete From S_SaleTotal1 ';
  FDM.ExecuteSQL(nSQL);
end;

procedure TfFrameSaletunnelQuery.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFrameSaletunnelQuery.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s 至 %s', [DateTime2Str(FStart), DateTime2Str(FEnd)]);
  FEnableBackDB := True;
  Result := '';
  if nWhere = '' then
    nStr := ' select * from  ' +
            ' (select R_Group,sum(R_Stock1) R_Stock1, sum(R_Stock2) R_Stock2,sum(R_Stock3) R_Stock3,sum(R_Stock4) R_Stock4,sum(R_Stock5) R_Stock5,'+
            ' sum(R_Stock6) R_Stock6, sum(R_Stock7) R_Stock7,sum(R_Stock8) R_Stock8,sum(R_Stock9) R_Stock9,sum(R_Stock10) R_Stock10,'+
            ' sum(R_Stock1+R_Stock2+R_Stock3+R_Stock4+R_Stock5+R_Stock6+R_Stock7+R_Stock8+R_Stock9+R_Stock10) R_Sum1 from S_SaleTotal1 Group by R_Group) a  order by R_Sum1 Desc '
  else
  begin
    nStr := ' select ''三四线水泥'' as R_Group,sum(R_Stock1) R_Stock1, sum(R_Stock2) R_Stock2,sum(R_Stock3) R_Stock3,sum(R_Stock4) R_Stock4,sum(R_Stock5) R_Stock5,'+
            ' sum(R_Stock6) R_Stock6, sum(R_Stock7) R_Stock7,sum(R_Stock8) R_Stock8,sum(R_Stock9) R_Stock9,sum(R_Stock10) R_Stock10,'+
            ' sum(R_Stock1+R_Stock2+R_Stock3+R_Stock4+R_Stock5+R_Stock6+R_Stock7+R_Stock8+R_Stock9+R_Stock10) R_Sum1 from S_SaleTotal1 '+
            ' union all ' +
            ' select distinct ''三车间水泥'' as R_Group,0 R_Stock1, 0 R_Stock2,0 R_Stock3,0 R_Stock4,0 R_Stock5,'+
            ' 0 R_Stock6, 0 R_Stock7,0 R_Stock8,0 R_Stock9,0 R_Stock10,'+
            ' 0 R_Sum1 from S_SaleTotal1 ';
  end;


  Result := nStr;

end;

//Desc: 过滤字段
function TfFrameSaletunnelQuery.FilterColumnField: string;
begin
  //
end;

//Desc: 日期筛选
procedure TfFrameSaletunnelQuery.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd, True) then
  begin
    //
  end;
end;

//Desc: 执行查询
procedure TfFrameSaletunnelQuery.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  //
end;

//Desc: 交接班查询
procedure TfFrameSaletunnelQuery.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FStart, FEnd, True) then
  try
    if Sender = mniN1 then
      FJBWhere := '(L_OutFact>=''%s'' and L_OutFact <''%s'')' else
    if Sender = N2 then
      FJBWhere := '(L_LadeTime>=''%s'' and L_LadeTime <''%s'')' else
    if Sender = N3 then
      FJBWhere := '(L_MDate>=''%s'' and L_MDate <''%s'')' else
    if Sender = N4 then
      FJBWhere := '(L_PDate>=''%s'' and L_PDate <''%s'')';

    FJBWhere := Format(FJBWhere, [DateTime2Str(FStart), DateTime2Str(FEnd)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

procedure TfFrameSaletunnelQuery.btnOK1Click(Sender: TObject);
begin
  inherited;
  SaveGroupTmp('L_SaleMan');
  InitFormDataSQL('');
  InitFormData('');
end;

procedure TfFrameSaletunnelQuery.btnOK2Click(Sender: TObject);
begin
  inherited;
  SaveGroupTmp('L_SaleMan');
  InitFormDataSQL('工厂');
  InitFormData('工厂');
end;

procedure TfFrameSaletunnelQuery.SaveGroupTmp(const nGroup: string);
var
  nIdx,i : Integer;
  nStr, nSQL  : string;
  aList : TStrings;
begin
  aList := TStringList.Create;
  try
    nSQL := ' SELECT  D_ParamB FROM  Sys_Dict  WHERE D_Name = ''StockItem'' order by D_Index ';
    with FDM.QueryTemp(nSQL) do
    begin
      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          aList.Values[IntToStr(nIdx)] := FieldByName('D_ParamB').AsString;
          Next;
          Inc(nIdx);
        end;
      end;
    end;

    nSQL := ' Delete From S_SaleTotal1 ';
    FDM.ExecuteSQL(nSQL);
    
    for i := 0 to aList.Count - 1 do
    begin
      if i = 0 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, '+
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select SUM(L_Value) R_Stock1,0 R_Stock2,0 R_Stock3,0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 1 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, '+
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,SUM(L_Value) R_Stock2,0 R_Stock3,0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 2 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, SUM(L_Value) R_Stock3,0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 3 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3,SUM(L_Value) R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 4 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, SUM(L_Value) R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 5 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, 0 R_Stock5, '+
                ' SUM(L_Value) R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 6 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,SUM(L_Value) R_Stock7,0 R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 7 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,SUM(L_Value) R_Stock8,0 R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 8 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,SUM(L_Value) R_Stock9, 0 R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end
      else if i = 9 then
      begin
        nSQL := ' insert into S_SaleTotal1 (R_Stock1,R_Stock2,R_Stock3,R_Stock4,R_Stock5, ' +
                ' R_Stock6,R_Stock7,R_Stock8,R_Stock9,R_Stock10,R_Group) ' +
                ' select 0 R_Stock1,0 R_Stock2, 0 R_Stock3, 0 R_Stock4, 0 R_Stock5, '+
                ' 0 R_Stock6,0 R_Stock7,0 R_Stock8,0 R_Stock9, SUM(L_Value) R_Stock10, ' +
                ' %s R_Group from S_Bill where  L_OutFact >= ''%s'' and L_OutFact < ''%s'' ' +
                ' and L_StockNo = ''%s'' Group by %s ';
        nSQL := Format(nSQL, [nGroup,DateTime2Str(FStart),DateTime2Str(FEnd),aList.values[IntToStr(i)],nGroup]);
      end;
      
      FDM.ExecuteSQL(nSQL);
    end;
  finally
    aList.Free;
  end;
end;

procedure TfFrameSaletunnelQuery.btnOK3Click(Sender: TObject);
begin
  inherited;
  SaveGroupTmp('L_CusName');
  InitFormDataSQL('');
  InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFrameSaletunnelQuery, TfFrameSaletunnelQuery.FrameID);
end.
