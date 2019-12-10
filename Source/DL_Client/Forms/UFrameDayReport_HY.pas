unit UFrameDayReport_HY;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxDropDownEdit, cxCalendar,
  cxTextEdit, cxMaskEdit, StdCtrls, cxButtonEdit;

type
  TfFrameDayReport_HY = class(TfFrameNormal)
    editType: TcxComboBox;
    dxLayout1Item1: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item3: TdxLayoutItem;
    editDate: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure Button1Click(Sender: TObject);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
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
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameDayReport_HY: TfFrameDayReport_HY;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

class function TfFrameDayReport_HY.FrameID: integer;
begin
  Result := cFI_FrameDayReport_HY;
end;

procedure TfFrameDayReport_HY.Button1Click(Sender: TObject);
var
  nStr, nSQL: string;
begin
  nStr := '该操作可能需要一段时间,请耐心等候.' + #13#10 +
          '要继续吗?';
  if not QueryDlg(nStr, sAsk) then Exit;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  FEnableBackDB := true;
  //客户类型   
  if editType.ItemIndex = 0 then
    nStr := ''
  else if editType.ItemIndex = 1 then
    nStr := ' And L_CusType=''A'' '
  else if editType.ItemIndex = 2 then
    nStr := ' And L_CusType=''B'' ';

  FDM.ADOConn.BeginTrans;
  try
    nSQL := 'if object_id(''tempdb..#DayReport'') is not null begin Drop '+
            'Table #DayReport end ';
    FDM.ExecuteSQL(nSQL);

    //生成数据结构
    nSQL := 'create table #DayReport(D_ID varchar(30),D_Name varchar(200),D_Area varchar(50),'+
            'D_XHSpot varchar(60),D_StockName varchar(30),D_Value Decimal(15,2) default 0,D_Lading varchar(30),'+
            'D_SNPrice Decimal(15,2) default 0,D_Freight Decimal(15,2) default 0,D_Price Decimal(15,2) default 0,'+
            'D_Money Decimal(15,2) default 0,D_PayType varchar(30),D_PayMoney Decimal(15,2) default 0,'+
            'D_Ys Decimal(15,2) default 0,D_SNMOney Decimal(15,2) default 0,D_FreightMoney Decimal(15,2) default 0,D_SaleMan varchar(50))';
    FDM.ExecuteSQL(nSQL);

    //插入当日提货信息
    nSQL := 'insert into #DayReport(D_ID,D_Name,D_Area,D_StockName,D_SaleMan,'+
        'D_XHSpot,D_Lading,D_Price,D_Freight,D_SNPrice,D_Value,D_Money,D_SNMOney,D_FreightMoney)'+
        'select L_CusID,L_CusName,L_Area,L_StockName,L_SaleMan,L_XHSpot,L_Lading,L_Price,'+
        'L_Freight,L_Price-L_Freight as L_SNPrice,SUM(L_Value) as L_value,'+
        'sum(L_Price*L_Value) as L_Money,sum((L_Price-L_Freight)*L_Value) as L_SNMoney,'+
        'Sum(L_Freight*L_Value) as L_TotalFreight '+
        'from S_Bill  where L_OutFact>=''%s'' And L_OutFact<''%s'''+ nStr +
        'group by  L_CusID,L_CusName,L_Area,L_StockName,L_SaleMan,L_XHSpot,L_Lading,L_Price,L_Freight';
    nSQL := Format(nSQL,[Date2Str(FStart),Date2Str(FEnd + 1)]);
    FDM.ExecuteSQL(nSQL);

    //更新应收款,入金
    nSQL := 'UPDate #DayReport Set D_Ys=D_Ys+CusInMoney From '+
            '( Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney '+
            'From Sys_CustomerInOutMoney Where M_Date<''%s'' Group '+
            'by M_CusID ) a  Where M_CusID=D_ID';
    nSQL := Format(nSQL,[Date2Str(FEnd + 1)]);
    FDM.ExecuteSQL(nSQL);

    //出金
    nSQL := 'UPDate #DayReport Set D_Ys=D_Ys- L_Money From '+
            '( Select L_CusID, IsNull(Sum(L_Price*L_Value), 0) L_Money '+
            'From S_Bill Where L_OutFact<''%s'' Group by L_CusID )a Where L_CusID=D_ID';
    nSQL := Format(nSQL,[Date2Str(FEnd + 1)]);
    FDM.ExecuteSQL(nSQL);


    //客户类型   
    if editType.ItemIndex = 0 then
      nStr := ''
    else if editType.ItemIndex = 1 then
      nStr := ' And C_Type=''A'' '
    else if editType.ItemIndex = 2 then
      nStr := ' And C_Type=''B'' ';

    //插入回款
    nSQL := 'insert into #DayReport(D_ID,D_Name,D_PayType,D_PayMoney)'+
            'Select M_CusID, M_CusName,M_Payment,'+
            'SUM(M_Money) M_Money  From Sys_CustomerInOutMoney,S_Customer '+
            'Where M_CusID=C_ID and M_Date>=''%s'' And M_Date<''%s'''+ nStr+
            'Group by M_CusID, M_CusName,M_Payment';
    nSQL := Format(nSQL,[Date2Str(FStart), Date2Str(FEnd+ 1)]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;

    nSQL := 'select * from #DayReport order by D_ID,D_StockName desc';
    FDM.QueryData(SQLQuery, nSQL, FEnableBackDB);

    nSQL := 'Drop Table #DayReport';
    FDM.ExecuteSQL(nSQL);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMessage('查询水泥回款及销量统计报表失败.');
    exit;
  end;
end;

procedure TfFrameDayReport_HY.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameDayReport_HY.OnDestroyFrame;
begin
  inherited;
  SaveDateRange(Name, FStart, FEnd);
end;

procedure TfFrameDayReport_HY.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
end;

initialization
  gControlManager.RegCtrl(TfFrameDayReport_HY, TfFrameDayReport_HY.FrameID);
end.
