unit UFramePurchByMonth;

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
  TfFramePurchByMonth = class(TfFrameNormal)
    editYearStart: TcxComboBox;
    dxLayout1Item1: TdxLayoutItem;
    editMonthStart: TcxComboBox;
    dxLayout1Item2: TdxLayoutItem;
    editMonthEnd: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item4: TdxLayoutItem;
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
  fFramePurchByMonth: TfFramePurchByMonth;

implementation

uses
  UDataModule, UFormDateFilter, ULibFun, USysDB, USysConst, UMgrControl,
  UFormBase, UAdjustForm;

{$R *.dfm}

{ TfFramePurchByMonth }

class function TfFramePurchByMonth.FrameID: integer;
begin
  Result := cFI_FramePurchByMonth;
end;

function TfFramePurchByMonth.MakeDate(var nIdx: Integer): TDate;
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

procedure TfFramePurchByMonth.OnCreateFrame;
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

procedure TfFramePurchByMonth.Button1Click(Sender: TObject);
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
    nSQL := 'if object_id(''tempdb..#CaiHJ'') is not null ' +
            'begin Drop Table #CaiHJ end ';
    FDM.ExecuteSQL(nSQL);
    //准备创建期初表
    
    nStr := '';
    for nIdx := nMonthStart to nMonthEnd do
    begin
      nStr := nStr + 'P_'+IntToStr(nIdx)+'value decimal(15,2) default 0,P_'+IntToStr(nIdx)+
              'KPValue decimal(15,2) default 0,';
    end;

    nSQL := 'Create Table #CaiHJ(P_ProId varchar(40),P_ProName varchar(50),'+
            'P_StockNo varchar(20),P_StockName varchar(50),'+ nStr +
            'P_ZValue decimal(15,2) default 0,P_ZKpValue decimal(15,2) default 0)';
    FDM.ExecuteSQL(nSQL);
    //创建临时表
  
    FStart := StrToDate(editYearStart.Text+'-'+editMonthStart.Text+'-01');
    FEnd := MakeDate(nMonthEnd);
    //起始时间

    nSQL := 'insert into #CaiHJ(P_ProId,P_ProName,P_StockNo,P_StockName,'+
            'P_ZValue,P_ZKpValue) '+
            'select D_ProID,D_ProName,D_StockNo,D_StockName,SUM(D_Value)D_Value,'+
            'SUM(O_Value) D_KPValue from P_Order,P_OrderDtl where D_OID=O_ID '+
            'And D_OutFact>=''$Start'' and D_OutFact <''$End'' '+
            'group by D_ProID,D_ProName,D_StockNo,D_StockName';
    nSQL :=  MacroValue(nSQL,[MI('$Start', Date2Str(FStart)),
              MI('$End', Date2Str(FEnd+1))]);
    FDM.ExecuteSQL(nSQL);
    //总时间段汇总

    //循环月份
    for nIdx := nMonthStart to nMonthEnd do
    begin
      FStart := StrToDate(editYearStart.Text+'-'+inttostr(nIdx)+'-01');
      FEnd := MakeDate(nIdx);

      nSQL := 'select D_ProID,D_ProName,D_StockNo,D_StockName,SUM(D_Value)D_Value,'+
              'SUM(O_Value) D_KPValue from P_Order,P_OrderDtl where D_OID=O_ID '+
              'And D_OutFact>=''$Start'' and D_OutFact <''$End'' '+
              'group by D_ProID,D_ProName,D_StockNo,D_StockName';
      nSQL :=  MacroValue(nSQL,[MI('$Start', Date2Str(FStart)),
                MI('$End', Date2Str(FEnd+1))]);
      with FDM.QueryTemp(nSQL) do
      begin
        First;
        //逐条循环每月数据并更新
        while not Eof do
        begin
            nSQL := 'update #CaiHJ set P_'+inttostr(nIdx)+'Value=%s,'+
                    'P_'+inttostr(nIdx)+'KPValue=%s where P_ProID=''%s'' '+
                    'And P_StockNo=''%s'' ';
            nSQL := Format(nSQL,[FieldByName('D_Value').AsString,
                    FieldByName('D_KPValue').AsString,FieldByName('D_ProID').AsString,
                    FieldByName('D_StockNo').AsString]);
            FDM.ExecuteSQL(nSQL);
          Next;
        end;
      end;
    end;

    nSQL := 'Select * From #CaiHJ ';
    FDM.QueryData(SQLQuery, nSQL, FEnableBackDB);
    //查询结果

    nSQL := 'Drop Table #CaiHJ';
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
  gControlManager.RegCtrl(TfFramePurchByMonth, TfFramePurchByMonth.FrameID);
end.
