{*******************************************************************************
  作者: dmzn@163.com 2017-01-11
  描述: 原材料结算单
*******************************************************************************}
unit UFrameQueryOrderTotal;

{$I Link.inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, IniFiles, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  StdCtrls, cxRadioGroup, cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB,
  cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin;

type
  TfFrameOrderDetailTotal = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    Radio1: TcxRadioButton;
    dxLayout1Item2: TdxLayoutItem;
    Radio2: TcxRadioButton;
    dxLayout1Item4: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item7: TdxLayoutItem;
    N1: TMenuItem;
    Radio3: TcxRadioButton;
    dxLayout1Item9: TdxLayoutItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure Radio1Click(Sender: TObject);
    procedure Radio2Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Radio3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //时间区间
    FJBWhere: string;
    //交班条件
    FValue,FMoney: Double;
    //均价参数间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnLoadGridConfig(const nIni: TIniFile); override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //查询SQL
    procedure SummaryItemsGetText(Sender: TcxDataSummaryItem;
      const AValue: Variant; AIsFooter: Boolean; var AText: String);
    //处理摘要
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UDataReport, UDataModule;

class function TfFrameOrderDetailTotal.FrameID: integer;
begin
  Result := cFI_FrameOrderTotalQuery;
end;

procedure TfFrameOrderDetailTotal.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameOrderDetailTotal.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameOrderDetailTotal.OnLoadGridConfig(const nIni: TIniFile);
var i,nCount: Integer;
begin
  with cxView1.DataController.Summary do
  begin
    nCount := FooterSummaryItems.Count - 1;
    for i:=0 to nCount do
      FooterSummaryItems[i].OnGetText := SummaryItemsGetText;
    //绑定事件

    nCount := DefaultGroupSummaryItems.Count - 1;
    for i:=0 to nCount do
      DefaultGroupSummaryItems[i].OnGetText := SummaryItemsGetText;
    //绑定事件
  end;

  inherited;
end;

//------------------------------------------------------------------------------
function TfFrameOrderDetailTotal.InitFormDataSQL(const nWhere: string): string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);

  if Radio1.Checked then
  begin
    Result := 'Select D_ProID, D_ProName, D_StockNo, D_StockName, D_Truck, D_Price, ' +
              '( select Top 1 T_Owner from S_Truck where T_Truck = D_Truck ) as T_Owner,' +
              'CAST(Sum(P_MValue-P_PValue-isnull(P_KZValue,0)) as decimal(38, 2)) as D_Value,' +
              'CAST(Sum(((P_MValue-P_PValue-isnull(P_KZValue,0)) * D_Price)+((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))*isnull(D_KCPrice,0))) as decimal(38, 2)) as D_Money,'+
              ' Count(*) as D_Num, ' +
              'CAST(Sum((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))) as decimal(38, 2)) as D_KCD,'+
              'D_KD '+
              'From $OD od Inner Join $PL pl on (od.D_ID = pl.P_Order and isnull(pl.P_TwoState,''N'') = ''Y'') ';
    //xxxxx
  end
  else if Radio2.Checked then
  begin
    Result := 'Select D_ProID,D_ProName, D_StockNo, D_StockName,D_Price, ' +
              'CAST(Sum(P_MValue-P_PValue-isnull(P_KZValue,0)) as decimal(38, 2)) as D_Value,' +
              'CAST(Sum(((P_MValue-P_PValue-isnull(P_KZValue,0)) * D_Price)+((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))*isnull(D_KCPrice,0))) as decimal(38, 2)) as D_Money,'+
              ' '''' D_Truck,'''' T_Owner, Count(*) as D_Num, ' +
              'CAST(Sum((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))) as decimal(38, 2)) as D_KCD,'+
              'D_KD '+
              'From $OD od Inner Join $PL pl on (od.D_ID = pl.P_Order and isnull(pl.P_TwoState,''N'') = ''Y'') ';
    //xxxxx
  end
  else if Radio3.Checked then
  begin
    Result := 'Select D_ProID,D_ProName, D_StockNo, D_StockName,D_Price, ' +
              'CAST(Sum(P_MValue-P_PValue-isnull(P_KZValue,0)) as decimal(38, 2)) as D_Value,' +
              'CAST(Sum(((P_MValue-P_PValue-isnull(P_KZValue,0)) * D_Price)+((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))*isnull(D_KCPrice,0))) as decimal(38, 2)) as D_Money,'+
              ' IsNull(T_Owner,D_Truck) T_Own, Count(*) as D_Num, ' +
              'CAST(Sum((P_MValue-P_PValue-isnull(P_KZValue,0)-isnull(P_OldValue,P_MValue-P_PValue-isnull(P_KZValue,0)))) as decimal(38, 2)) as D_KCD,'+
              'D_KD '+
              'From $OD od Inner Join $PL pl on (od.D_ID = pl.P_Order and isnull(pl.P_TwoState,''N'') = ''Y'') '+
              'Inner Join S_Truck on (od.D_Truck = T_Truck) ';
    //xxxxx
  end;

  if FJBWhere = '' then
  begin
    Result := Result + ' Where (D_PDate>=''$S'' and D_PDate <''$End'') and D_OutFact is not null ';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' Where (' + FJBWhere + ')';
  end;

  if Radio1.Checked then
  begin
    Result := Result + ' Group By D_ProID,D_ProName, D_StockNo, D_StockName, D_Truck,D_Price,D_KD ';
  end
  else if Radio2.Checked then
  begin
    Result := Result + ' Group By D_ProID,D_ProName, D_StockNo, D_StockName, D_Price,D_KD ';
    //xxxxx
  end
  else if Radio3.Checked then
  begin
    Result := ' Select *, Case When (Select COUNT(*) from S_Truck where T_Owner= T_Own) > 0 ' +
              ' then T_Own else '''' end  as T_Owner, ' +
              ' Case when (select COUNT(*) from S_Truck where T_Truck= T_Own) > 0 '+
              ' then T_Own else '''' end  as D_Truck  from ( '+
              Result + ' Group By D_ProID,D_ProName, D_StockNo, D_StockName, D_Price,D_KD,IsNull(T_Owner,D_Truck)) A ';
    //xxxxx
  end;

  Result := MacroValue(Result,
            [MI('$OD', sTable_OrderDtl),
            MI('$PL', sTable_PoundLog),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

//  Result := 'Select *,(case L_Value when 0 then 0 else convert(decimal(15,2),' +
//            'L_Money/L_Value) end) as L_Price From (' + Result + ') t';
  //计算均价
end;

//Desc: 过滤字段
function TfFrameOrderDetailTotal.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'D_Price;D_Money';
end;

//Desc: 日期筛选
procedure TfFrameOrderDetailTotal.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFrameOrderDetailTotal.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'D_ProPY like ''%%%s%%'' Or D_ProName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: 时间段查询
procedure TfFrameOrderDetailTotal.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(D_PDate>=''%s'' and D_PDate <''%s'') and D_OutFact is not null';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE),
                sFlag_BillPick, sFlag_BillPost]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//Desc: 处理均价
procedure TfFrameOrderDetailTotal.SummaryItemsGetText(
  Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
  var AText: String);
var nStr: string;
begin
//  nStr := TcxGridDBColumn(TcxGridTableSummaryItem(Sender).Column).DataBinding.FieldName;
//  try
//    if CompareText(nStr, 'L_Value') = 0 then FValue := SplitFloatValue(AText);
//    if CompareText(nStr, 'L_Money') = 0 then FMoney := SplitFloatValue(AText);
//
//    if CompareText(nStr, 'L_Price') = 0 then
//    begin
//      if FValue = 0 then
//           AText := '均价: 0.00元'
//      else AText := Format('均价: %.2f元', [Round(FMoney / FValue * cPrecision) / cPrecision]);
//    end;
//  except
//    //ignor any error
//  end;
end;

procedure TfFrameOrderDetailTotal.Radio1Click(Sender: TObject);
begin
  inherited;
  InitFormData(FWhere);
end;

procedure TfFrameOrderDetailTotal.Radio2Click(Sender: TObject);
begin
  inherited;
  InitFormData(FWhere);
end;

//------------------------------------------------------------------------------
function SmallTOBig(small: real): string;
var
  SmallMonth, BigMonth: string;
  wei1, qianwei1: string[2];
  qianwei, dianweizhi, qian: integer;
  fs_bj: boolean;
begin
  if small < 0 then
    fs_bj := True
  else
    fs_bj := False;
  small      := abs(small);
  {------- 修改参数令值更精确 -------}
  {小数点后的位置，需要的话也可以改动-2值}
  qianwei    := -2;
  {转换成货币形式，需要的话小数点后加多几个零}
  Smallmonth := formatfloat('0.00', small);
  {---------------------------------}
  dianweizhi := pos('.', Smallmonth);{小数点的位置}
  {循环小写货币的每一位，从小写的右边位置到左边}
  for qian := length(Smallmonth) downto 1 do
  begin
    {如果读到的不是小数点就继续}
    if qian <> dianweizhi then
    begin
      {位置上的数转换成大写}
      case StrToInt(Smallmonth[qian]) of
        1: wei1 := '壹';
        2: wei1 := '贰';
        3: wei1 := '叁';
        4: wei1 := '肆';
        5: wei1 := '伍';
        6: wei1 := '陆';
        7: wei1 := '柒';
        8: wei1 := '捌';
        9: wei1 := '玖';
        0: wei1 := '零';
      end;
      {判断大写位置，可以继续增大到real类型的最大值}
      case qianwei of
        -3: qianwei1 := '厘';
        -2: qianwei1 := '分';
        -1: qianwei1 := '角';
        0: qianwei1  := '元';
        1: qianwei1  := '拾';
        2: qianwei1  := '佰';
        3: qianwei1  := '仟';
        4: qianwei1  := '万';
        5: qianwei1  := '拾';
        6: qianwei1  := '佰';
        7: qianwei1  := '仟';
        8: qianwei1  := '亿';
        9: qianwei1  := '拾';
        10: qianwei1 := '佰';
        11: qianwei1 := '仟';
      end;
      inc(qianwei);
      BigMonth := wei1 + qianwei1 + BigMonth;{组合成大写金额}
    end;
  end;

  BigMonth := StringReplace(BigMonth, '零拾', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零佰', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零仟', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零角', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零分', '', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零零', '零', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零亿', '亿', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零万', '万', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '零元', '元', [rfReplaceAll]);
  BigMonth := StringReplace(BigMonth, '亿万', '亿', [rfReplaceAll]);
  BigMonth := BigMonth + '整';
  BigMonth := StringReplace(BigMonth, '分整', '分', [rfReplaceAll]);

  if BigMonth = '元整' then
    BigMonth := '零元整';
  if copy(BigMonth, 1, 2) = '元' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if copy(BigMonth, 1, 2) = '零' then
    BigMonth := copy(BigMonth, 3, length(BigMonth) - 2);
  if fs_bj = True then
    SmallTOBig := '- ' + BigMonth
  else
    SmallTOBig := BigMonth;
end;

procedure TfFrameOrderDetailTotal.N1Click(Sender: TObject);
var nStr: string;
    nParam: TReportParamItem;
    nBool: Boolean;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('D_ProID').AsString;

    nStr := gPath + sReportDir + 'OrderJS.fr3';
    if not FDR.LoadReportFile(nStr) then
    begin
      nStr := '无法正确加载报表文件';
      ShowMsg(nStr, sHint);
      Exit;
    end;

    nParam.FName := 'D_ProID';
    nParam.FValue:= SQLQuery.FieldByName('D_ProID').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_ProName';
    nParam.FValue:= SQLQuery.FieldByName('D_ProName').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_StockNo';
    nParam.FValue:= SQLQuery.FieldByName('D_StockNo').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_StockName';
    nParam.FValue := SQLQuery.FieldByName('D_StockName').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Truck';
    nParam.FValue := SQLQuery.FieldByName('D_Truck').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Owner';
    nParam.FValue := SQLQuery.FieldByName('T_Owner').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Price';
    nParam.FValue := SQLQuery.FieldByName('D_Price').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Value';
    nParam.FValue := SQLQuery.FieldByName('D_Value').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Money';
    nParam.FValue := SQLQuery.FieldByName('D_Money').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_Num';
    nParam.FValue := SQLQuery.FieldByName('D_Num').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_KD';
    nParam.FValue := SQLQuery.FieldByName('D_KD').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_KCD';
    nParam.FValue := SQLQuery.FieldByName('D_KCD').AsString;
    FDR.AddParamItem(nParam);

    nParam.FName := 'D_MoneyEx';
    nParam.FValue := SmallTOBig(SQLQuery.FieldByName('D_Money').AsFloat);
    FDR.AddParamItem(nParam);
    
    nParam.FName := 'UserName';
    nParam.FValue := gSysParam.FUserID;
    FDR.AddParamItem(nParam);

    nParam.FName := 'Company';
    nParam.FValue := gSysParam.FHintText;
    FDR.AddParamItem(nParam);

    nStr := ' Select Top 1  b.* From %s b  ';
    nStr := Format(nStr, [sTable_OrderDtl]);
    with  FDM.QueryTemp(nStr) do
    begin

    end;
    FDR.Dataset1.DataSet := FDM.SqlTemp;
    FDR.ShowReport;
    nBool := FDR.PrintSuccess;
  end;
end;

procedure TfFrameOrderDetailTotal.Radio3Click(Sender: TObject);
begin
  inherited;
  InitFormData(FWhere);
end;

initialization
  gControlManager.RegCtrl(TfFrameOrderDetailTotal, TfFrameOrderDetailTotal.FrameID);
end.
