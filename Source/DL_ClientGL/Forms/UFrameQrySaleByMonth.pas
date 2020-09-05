unit UFrameQrySaleByMonth;

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
  cxDropDownEdit, StdCtrls;

type
  TfFrameQrySaleByMonth = class(TfFrameNormal)
    editYearStart: TcxComboBox;
    dxLayout1Item1: TdxLayoutItem;
    editMonthStart: TcxComboBox;
    dxLayout1Item2: TdxLayoutItem;
    editMonthEnd: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item5: TdxLayoutItem;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure OnCreateFrame; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
    function MakeDate(var nIdx:Integer):TDate;
  end;

var
  fFrameQrySaleByMonth: TfFrameQrySaleByMonth;

implementation

uses
  UDataModule, UFormDateFilter, ULibFun, USysDB, USysConst, UMgrControl,
  UFormBase, UAdjustForm;

{$R *.dfm}

{ TfFrameQrySaleByMonth }

class function TfFrameQrySaleByMonth.FrameID: integer;
begin
  Result := cFI_FrameQrySaleByMonth;
end;

procedure TfFrameQrySaleByMonth.OnCreateFrame;
var
  nStr:string;
  i,nYear:Integer;
begin
  inherited;
  nStr := Formatdatetime('yyyy',now);
  nYear := StrToInt(nStr);
  for i := 0 to 9 do
    editYearStart.Properties.Items.Add(IntToStr(nYear-i));
end;

function TfFrameQrySaleByMonth.MakeDate(var nIdx: Integer): TDate;
var
  nEnd:string;
begin
  case nIdx of
    2:begin
      if StrToInt(editYearStart.Text) mod 4=0 then
        nEnd := editYearStart.Text+'-'+inttostr(nIdx)+'-29'
      else
        nEnd := editYearStart.Text+'-'+inttostr(nIdx)+'-28';
    end;
    4,6,9,11: nEnd := editYearStart.Text+'-'+inttostr(nIdx)+'-30';
    1,3,5,7,8,10,12:nEnd := editYearStart.Text+'-'+inttostr(nIdx)+'-31';
  end;
  Result := StrToDate(nEnd);
end;

procedure TfFrameQrySaleByMonth.Button1Click(Sender: TObject);
var
  nStr, nSQL: string;
  FStart, FEnd: TDate;
  nIdx, nMonthStart, nMonthEnd:Integer;
  nList: TStrings;
begin
  nStr := '该操作可能需要一段时间,请耐心等候.' + #13#10 +
          '要继续吗?';
  if not QueryDlg(nStr, sAsk) then Exit;

  nList := TStringList.Create;

  nMonthStart := StrToInt(editMonthStart.Text);
  nMonthEnd := StrToInt(editMonthEnd.Text);
  if nMonthStart > nMonthEnd then
  begin
    ShowMessage('请选择合适的时间段.');
    exit;
  end;

  try
    FDM.ADOConn.BeginTrans;
    nSQL := 'if object_id(''tempdb..#SaleHj'') is not null ' +
            'begin Drop Table #SaleHj end ';
    FDM.ExecuteSQL(nSQL);
    //准备创建期初表
    
    nStr := '';
    for nIdx := nMonthStart to nMonthEnd do
    begin
      nStr := nStr + 'S_'+IntToStr(nIdx)+'value decimal(15,2) default 0,S_'+IntToStr(nIdx)+
              'Money decimal(15,2) default 0,';
    end;

    nSQL := 'Create Table #SaleHj(S_CusId varchar(40),S_CusName varchar(50),'+
            'S_StockNo varchar(20),S_StockName varchar(50),'+ nStr +
            'S_CusPY varchar(50),S_Type char(1),S_custype char(1),'+
            'S_ZValue decimal(15,2) default 0,S_ZMoney decimal(15,2) default 0)';
    FDM.ExecuteSQL(nSQL);
    //创建临时表
  
    FStart := StrToDate(editYearStart.Text+'-'+editMonthStart.Text+'-01');
    FEnd := MakeDate(nMonthEnd);
    //起始时间

    nSQL := 'insert into #SaleHj(S_CusId,S_CusName,S_CusPY,S_Type,S_Custype,'+
            'S_StockNo,S_StockName,S_ZValue,S_ZMoney) '+
            'select L_CusID,L_CusName,L_CusPY,L_Type,l_custype,L_StockNo,'+
            'L_StockName,CAST(Sum(L_Value) as decimal(38, 2)) as L_Value,'+
            'CAST(Sum(L_Value * L_Price) as decimal(38, 2)) as L_Money From $Bill '+
            'Where L_OutFact>=''$Start'' and L_OutFact <''$End'' '+
            'Group By L_CusID,L_CusName,L_CusPY,L_Type,L_StockNo,L_StockName,'+
            'l_custype order by L_CusID,L_StockNo';
    nSQL :=  MacroValue(nSQL,[MI('$Bill', sTable_Bill),MI('$Start', Date2Str(FStart)),
              MI('$End', Date2Str(FEnd+1))]);
    FDM.ExecuteSQL(nSQL);
    //总时间段汇总

    //循环月份
    for nIdx := nMonthStart to nMonthEnd do
    begin
      FStart := StrToDate(editYearStart.Text+'-'+inttostr(nIdx)+'-01');
      FEnd := MakeDate(nIdx);

      nSQL := 'select L_CusID,L_CusName,L_CusPY,L_Type,l_custype,L_StockNo,'+
              'L_StockName,CAST(Sum(L_Value) as decimal(38, 2)) as L_Value,'+
              'CAST(Sum(L_Value * L_Price) as decimal(38, 2)) as L_Money From $Bill '+
              'Where L_OutFact>=''$Start'' and L_OutFact <''$End'' '+
              'Group By L_CusID,L_CusName,L_CusPY,L_Type,L_StockNo,L_StockName,'+
              'l_custype order by L_CusID,L_StockNo';
      nSQL :=  MacroValue(nSQL,[MI('$Bill', sTable_Bill),MI('$Start', Date2Str(FStart)),
                MI('$End', Date2Str(FEnd+1))]);
      with FDM.QueryTemp(nSQL) do
      begin
        First;
        //逐条循环每月数据并更新
        while not Eof do
        begin
            nSQL := 'update #SaleHj set S_'+inttostr(nIdx)+'Value=%s,'+
                    'S_'+inttostr(nIdx)+'Money=%s where S_CusId=''%s'' '+
                    'And S_StockNo=''%s'' and S_Type=''%s'' and S_CusType=''%s''';
            nSQL := Format(nSQL,[FieldByName('L_Value').AsString,
                    FieldByName('L_Money').AsString,FieldByName('L_CusID').AsString,
                    FieldByName('L_StockNo').AsString,FieldByName('L_Type').AsString,
                    FieldByName('L_CusType').AsString]);
            FDM.ExecuteSQL(nSQL);
          Next;
        end;
      end;
    end;

    nSQL := 'Select * From #SaleHj ';
    FDM.QueryData(SQLQuery, nSQL, FEnableBackDB);
    //查询结果

    nSQL := 'Drop Table #SaleHj';
    FDM.ExecuteSQL(nSQL);
    //删除临时表
    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
    ShowMessage('查询失败.');
    Exit;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameQrySaleByMonth, TfFrameQrySaleByMonth.FrameID);
end.
