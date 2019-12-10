unit UAccReport;

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
  cxTextEdit, cxMaskEdit, cxButtonEdit;

type
  TfAccReport = class(TfFrameNormal)
    editDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    editType: TcxComboBox;
    dxLayout1Item2: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item3: TdxLayoutItem;
    procedure Button1Click(Sender: TObject);
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
  public
    class function FrameID: integer; override;
  end;

var
  fAccReport: TfAccReport;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

class function TfAccReport.FrameID: integer;
begin
  Result := cFI_FrameAccReport;
end;

procedure TfAccReport.Button1Click(Sender: TObject);
var
  nStr, nSQL:string;
begin
  nStr := '该操作可能需要一段时间,请耐心等候.' + #13#10 +
          '要继续吗?';
  if not QueryDlg(nStr, sAsk) then Exit;

  FEnableBackDB := true;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  
  nSQL := 'select * from %s where D_Name=''%s''';
  nSQL := Format(nSQL,[sTable_SysDict,sFlag_StockItem]);
  with FDM.QueryTemp(nSQL) do
  begin
    First;
    nStr := '';
    while not Eof do
    begin
      nStr := nStr +
          'CONVERT(Decimal(15,2), 0) C_'+fieldbyname('D_ParamB').AsString+
          'Num,CONVERT(Decimal(15,2), 0) C_'+fieldbyname('D_ParamB').AsString+
          'Price,CONVERT(Decimal(15,2), 0) C_'+fieldbyname('D_ParamB').AsString+
          'Money,';
      Next;
    end;
  end;

  nSQL := 'Select A_CID as C_ID, C_Name,CONVERT(Decimal(15,2), A_InitMoney) as C_Init,'+
          nStr + 'CONVERT(Decimal(15,2), 0) C_Num,CONVERT(Decimal(15,2), 0) C_Money,'+
          'CONVERT(Decimal(15,2), 0) C_Xj,CONVERT(Decimal(15,2), 0) C_Yh,'+
          'CONVERT(Decimal(15,2), 0) C_Cd,CONVERT(Decimal(15,2), 0) C_Zz,'+
          'CONVERT(Decimal(15,2), 0) C_Hj,CONVERT(Decimal(15,2), 0) C_Ysk,'+
          'CONVERT(Decimal(15,2), 0) C_Sk,CONVERT(Decimal(15,2), 0) C_Total'+
          ' into #qichu From Sys_CustomerAccount,S_Customer '+
          ' where A_CID=C_ID ' ;

  //客户类型        
  if editType.ItemIndex = 1 then
    nSQL := nSQL + ' and C_Type=''A'''
  else if editType.ItemIndex = 2 then
    nSQL := nSQL + ' and C_Type=''B''';

  FDM.ADOConn.BeginTrans;
  try
    nStr := 'if object_id(''tempdb..#qichu'') is not null begin Drop Table #qichu end';
    FDM.ExecuteSQL(nStr);

    //生成临时表结构
    FDM.ExecuteSQL(nSQL);

    //计算C_Init, 加上入金
    nSQL := 'UPDate #qichu Set C_Init=C_Init+CusInMoney From ( '+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney '+
            ' From Sys_CustomerInOutMoney Where M_Date<''%s'' Group by M_CusID'+
            ' ) a Where M_CusID=C_ID ';
    nSQL := Format(nSQL,[Date2Str(FStart)]);
    FDM.ExecuteSQL(nSQL);

    //计算C_Init, 减去出金
    nSQL := 'UPDate #qichu Set C_Init=C_Init- L_Money From ('+
            ' Select L_CusID, IsNull(Sum(L_Price*L_Value), 0) L_Money '+
            ' From S_Bill Where L_OutFact<''%s''  Group  by L_CusID '+
            ' ) a  Where L_CusID=C_ID ';
    nSQL := Format(nSQL,[Date2Str(FStart)]);
    FDM.ExecuteSQL(nSQL);

    //更新C_Hj收款小计
    nSQL := 'UPDate #qichu Set C_Hj=CusInMoney From ('+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney '+
            ' From Sys_CustomerInOutMoney  Where M_Date>=''%s'' And M_Date<''%s'''+
            ' Group by M_CusID ) a Where M_CusID=C_ID ';
    nSQL := Format(nSQL, [Date2Str(FStart), Date2Str(FEnd + 1)]);
    FDM.ExecuteSQL(nSQL);

    //更新C_Xj 现金收款
    nSQL := 'UPDate #qichu Set C_XJ=CusInMoney From ('+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney,M_Payment '+
            ' From Sys_CustomerInOutMoney  Where M_Date>=''%s'' And M_Date<''%s'''+
            ' Group by M_CusID, M_Payment)a Where M_CusID=C_ID And M_Payment=''%s''';
    nSQL := Format(nSQL, [Date2Str(FStart), Date2Str(FEnd + 1), '现金']);
    FDM.ExecuteSQL(nSQL);

    //更新C_Yh 银行存款
    nSQL := 'UPDate #qichu Set C_Yh=CusInMoney From ('+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney,M_Payment '+
            ' From Sys_CustomerInOutMoney  Where M_Date>=''%s'' And M_Date<''%s'''+
            ' Group by M_CusID, M_Payment)a Where M_CusID=C_ID And M_Payment=''%s''';
    nSQL := Format(nSQL, [Date2Str(FStart), Date2Str(FEnd + 1), '银行存款']);
    FDM.ExecuteSQL(nSQL);

    //更新C_Cd 承兑汇票收款
    nSQL := 'UPDate #qichu Set C_Cd=CusInMoney From ('+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney,M_Payment '+
            ' From Sys_CustomerInOutMoney  Where M_Date>=''%s'' And M_Date<''%s'''+
            ' Group by M_CusID, M_Payment)a Where M_CusID=C_ID And M_Payment=''%s''';
    nSQL := Format(nSQL, [Date2Str(FStart), Date2Str(FEnd + 1), '承兑汇票']);
    FDM.ExecuteSQL(nSQL);

    //更新C_Zz 转账
    nSQL := 'UPDate #qichu Set C_Zz=CusInMoney From ('+
            ' Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney,M_Payment '+
            ' From Sys_CustomerInOutMoney  Where M_Date>=''%s'' And M_Date<''%s'''+
            ' Group by M_CusID, M_Payment)a Where M_CusID=C_ID And M_Payment=''%s''';
    nSQL := Format(nSQL, [Date2Str(FStart), Date2Str(FEnd + 1), '转账']);
    FDM.ExecuteSQL(nSQL);

    //更新各品种销量和总价
    nSQL := 'select * from %s where D_Name=''%s''';
    nSQL := Format(nSQL,[sTable_SysDict,sFlag_StockItem]);
    with FDM.QueryTemp(nSQL) do
    begin
      First;
      while not Eof do
      begin
        //更新销量和总价
        nSQL := 'UPDate #qichu Set C_%sNum=CNum,C_%sMoney=CMoney From ('+
                ' Select L_CusID, IsNull(Sum(L_Value), 0) CNum, IsNull(Sum(L_Price*L_Value), 0) cmoney '+
                ' From S_Bill Where L_OutFact>=''%s'' and L_OutFact<''%s'' and L_StockNo=''%s'''+
                ' Group  by L_CusID ) a  Where L_CusID=C_ID ';
        nSQL := Format(nSQL,[FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString,
                            Date2Str(FStart), Date2Str(FEnd + 1),
                            FieldByName('D_ParamB').AsString]);
        FDM.ExecuteSQL(nSQL);

        //更新均价,总销量,总价
        nSQL := 'UPDate #qichu Set C_%sPrice=C_%sMoney / C_%sNum,'+
                'C_Num=C_Num+C_%sNum, C_Money=C_Money+C_%sMoney where C_%sNum<>0';
        nSQL := Format(nSQL,[FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString,
                            FieldByName('D_ParamB').AsString]);
        FDM.ExecuteSQL(nSQL);

        Next;
      end;
    end;

    FDM.ADOConn.CommitTrans;

    nSQL := 'Select * From #qichu order by c_id';
    FDM.QueryData(SQLQuery, nSQL, FEnableBackDB);

    nSQL := 'Drop Table #qichu';
    FDM.ExecuteSQL(nSQL);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMessage('查询会计报表失败退出.');
    exit;
  end;
end;

procedure TfAccReport.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
end;

procedure TfAccReport.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfAccReport.editDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  inherited;
  if ShowDateFilterForm(FStart, FEnd) then
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
end;

initialization
  gControlManager.RegCtrl(TfAccReport, TfAccReport.FrameID);
end.
