{*******************************************************************************
  作者: juner11212436@163.com 2017-12-28
  描述: 自助办卡窗口--单厂版
*******************************************************************************}
unit uZXNewCard;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, Menus, StdCtrls, cxButtons, cxGroupBox,
  cxRadioGroup, cxTextEdit, cxCheckBox, ExtCtrls, dxLayoutcxEditAdapters,
  dxLayoutControl, cxDropDownEdit, cxMaskEdit, cxButtonEdit,
  USysConst, cxListBox, ComCtrls,Contnrs,UFormCtrl, UMgrSDTReader;

type

  TfFormNewCard = class(TForm)
    editWebOrderNo: TcxTextEdit;
    labelIdCard: TcxLabel;
    btnQuery: TcxButton;
    PanelTop: TPanel;
    PanelBody: TPanel;
    dxLayout1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditValue: TcxTextEdit;
    EditCus: TcxTextEdit;
    EditCName: TcxTextEdit;
    EditStock: TcxTextEdit;
    EditSName: TcxTextEdit;
    EditTruck: TcxButtonEdit;
    EditType: TcxComboBox;
    EditPrice: TcxButtonEdit;
    dxLayoutGroup1: TdxLayoutGroup;
    dxGroup1: TdxLayoutGroup;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxlytmLayout1Item4: TdxLayoutItem;
    dxGroup2: TdxLayoutGroup;
    dxlytmLayout1Item9: TdxLayoutItem;
    dxlytmLayout1Item10: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    dxLayout1Item11: TdxLayoutItem;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxLayout1Item8: TdxLayoutItem;
    dxLayoutGroup3: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    pnlMiddle: TPanel;
    cxLabel1: TcxLabel;
    lvOrders: TListView;
    Label1: TLabel;
    btnClear: TcxButton;
    TimerAutoClose: TTimer;
    dxLayout1Group2: TdxLayoutGroup;
    EditMemo: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    dxLayout1Item32: TdxLayoutItem;
    EditSJName: TcxTextEdit;
    dxLayout1Group3: TdxLayoutGroup;
    procedure BtnExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure TimerAutoCloseTimer(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure lvOrdersClick(Sender: TObject);
    procedure editWebOrderNoKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    FAutoClose:Integer; //窗口自动关闭倒计时（分钟）
    FWebOrderIndex:Integer; //商城订单索引
    FWebOrderItems:array of stMallOrderItem; //商城订单数组
    FCardData:TStrings; //云天系统返回的大票号信息
    Fbegin:TDateTime;
    FListA : TStrings;
    procedure InitListView;
    procedure SetControlsReadOnly;
    function DownloadOrder(const nCard:string):Boolean;
    procedure Writelog(nMsg:string);
    procedure AddListViewItem(var nWebOrderItem:stMallOrderItem);
    procedure LoadSingleOrder;
    function IsRepeatCard(const nWebOrderItem:string):Boolean;
    function VerifyCtrl(Sender: TObject; var nHint: string): Boolean;
    function SaveBillProxy:Boolean;
    function SaveBillProxyPD: Boolean;
    function SaveWebOrderMatch(const nBillID,nWebOrderID,nBillType:string):Boolean;
    function CheckYYOrderState(const nWebOrderID:string; var nHint: string):Boolean;
    procedure SyncCard(const nCard: TIdCardInfoStr;const nReader: TSDTReaderItem);
    function GetZhiKaMoney(const nZhika:string):Double;
  public
    { Public declarations }
    procedure SetControlsClear;
  end;

var
  fFormNewCard: TfFormNewCard;

implementation
uses
  ULibFun,UBusinessPacker,USysLoger,UBusinessConst,UFormMain,USysBusiness,USysDB,
  UAdjustForm,UFormBase,UDataReport,UDataModule,NativeXml,UMgrTTCEDispenser,UFormWait,
  DateUtils;
{$R *.dfm}

{ TfFormNewCard }

procedure TfFormNewCard.SetControlsClear;
var
  i:Integer;
  nComp:TComponent;
begin
  editWebOrderNo.Clear;
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Clear;
    end;
  end;
end;
procedure TfFormNewCard.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormNewCard.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FListA.Free;
  FCardData.Free;
  Action:=  caFree;
  fFormNewCard := nil;
  gSDTReaderManager.OnSDTEvent := nil;  
end;

procedure TfFormNewCard.FormShow(Sender: TObject);
begin
  SetControlsReadOnly;
  dxlytmLayout1Item13.Visible := False;
  EditTruck.Properties.Buttons[0].Visible := False;
  ActiveControl := editWebOrderNo;
  btnOK.Enabled := False;
  FAutoClose := gSysParam.FAutoClose_Mintue;
  TimerAutoClose.Interval := 60*1000;
  TimerAutoClose.Enabled := True;
  EditPrice.Properties.Buttons[0].Visible := False;
  dxLayout1Item11.Visible := False;

  dxLayout1Item32.Visible := True;
  EditSJName.Text := '';
end;

procedure TfFormNewCard.SetControlsReadOnly;
var
  i:Integer;
  nComp:TComponent;
begin
  for i := 0 to dxLayout1.ComponentCount-1 do
  begin
    nComp := dxLayout1.Components[i];
    if nComp is TcxTextEdit then
    begin
      TcxTextEdit(nComp).Properties.ReadOnly := True;
    end;
  end;
  EditPrice.Properties.ReadOnly := True;
end;

procedure TfFormNewCard.TimerAutoCloseTimer(Sender: TObject);
begin
  if FAutoClose=0 then
  begin
    TimerAutoClose.Enabled := False;
    Close;
  end;
  Dec(FAutoClose);
end;

procedure TfFormNewCard.btnQueryClick(Sender: TObject);
var
  nCardNo,nStr:string;
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  btnQuery.Enabled := False;
  editWebOrderNo.SelectAll;
  try
    nCardNo := Trim(editWebOrderNo.Text);
    if nCardNo='' then
    begin
      nStr := '请先输入或扫描订单号';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;
    lvOrders.Items.Clear;

    if IsRepeatCard(editWebOrderNo.Text) then
    begin
      nStr := '订单'+editWebOrderNo.Text+'已成功制单，请勿重复操作';
      ShowMsg(nStr,sHint);
      Writelog(nStr);
      Exit;
    end;

    if not DownloadOrder(nCardNo) then Exit;
    btnOK.Enabled := True;
  finally
    btnQuery.Enabled := True;
  end;
end;

function TfFormNewCard.DownloadOrder(const nCard: string): Boolean;
var
  nXmlStr,nData:string;
  nListA,nListB,nListC:TStringList;
  i:Integer;
  nWebOrderCount:Integer;
begin
  Result := False;
  FWebOrderIndex := 0;

  nXmlStr := PackerEncodeStr(nCard);

  FBegin := Now;
  nData := get_shoporderbyno(nXmlStr);
  if nData='' then
  begin
    ShowMsg('未查询到网上商城订单详细信息，请检查订单号是否正确',sHint);
    Writelog('未查询到网上商城订单详细信息，请检查订单号是否正确');
    Exit;
  end;
  Writelog('TfFormNewCard.DownloadOrder(nCard='''+nCard+''') 查询商城订单-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  //解析网城订单信息
  Writelog('get_shoporderbyno res:'+nData);

  {$IFDEF UseWXServiceEx}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    nListC := TStringList.Create;
    try
      nListA.Text := PackerDecodeStr(nData);

      nListB.Text := PackerDecodeStr(nListA.Values['details']);
      nWebOrderCount := nListB.Count;
      SetLength(FWebOrderItems,nWebOrderCount);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListC.Text := PackerDecodeStr(nListB[i]);

        FWebOrderItems[i].FOrder_id     := nListA.Values['orderId'];
        FWebOrderItems[i].FOrdernumber  := nListA.Values['orderNo'];
        FWebOrderItems[i].Ftracknumber  := nListA.Values['licensePlate'];
        FWebOrderItems[i].FfactoryName  := nListA.Values['factoryName'];
        FWebOrderItems[i].FdriverId     := nListA.Values['driverId'];
        FWebOrderItems[i].FdrvName      := nListA.Values['drvName'];
        FWebOrderItems[i].FdrvPhone     := nListA.Values['FdrvPhone'];
        FWebOrderItems[i].FType         := nListA.Values['type'];
        FWebOrderItems[i].FXHSpot       := nListA.Values['orderRemark'];
        FWebOrderItems[i].FPrice        := '';
        with nListC do
        begin
          FWebOrderItems[i].FCusID          := Values['clientNo'];
          FWebOrderItems[i].FCusName        := Values['clientName'];
          FWebOrderItems[i].FGoodsID        := Values['materielNo'];
          FWebOrderItems[i].FGoodstype      := Values['orderDetailType'];
          FWebOrderItems[i].FGoodsname      := Values['materielName'];
          FWebOrderItems[i].FData           := Values['quantity'];
          FWebOrderItems[i].ForderDetailType:= Values['orderDetailType'];
          FWebOrderItems[i].FYunTianOrderId := Values['contractNo'];
          FWebOrderItems[i].FStatus         := Values['status'];
          AddListViewItem(FWebOrderItems[i]);
        end;
      end;
    finally
      nListC.Free;
      nListB.Free;
      nListA.Free;
    end;
  {$ELSE}
    nListA := TStringList.Create;
    nListB := TStringList.Create;
    try
      nListA.Text := nData;

      nWebOrderCount := nListA.Count;
      SetLength(FWebOrderItems,nWebOrderCount);
      for i := 0 to nWebOrderCount-1 do
      begin
        nListB.Text := PackerDecodeStr(nListA.Strings[i]);
        FWebOrderItems[i].FOrder_id := nListB.Values['order_id'];
        FWebOrderItems[i].FOrdernumber := nListB.Values['ordernumber'];
        FWebOrderItems[i].FGoodsID := nListB.Values['goodsID'];
        FWebOrderItems[i].FGoodstype := nListB.Values['goodstype'];
        FWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
        FWebOrderItems[i].FData := nListB.Values['data'];
        FWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
        FWebOrderItems[i].FYunTianOrderId := nListB.Values['fac_order_no'];
        AddListViewItem(FWebOrderItems[i]);
      end;
    finally
      nListB.Free;
      nListA.Free;
    end;
  {$ENDIF}
  LoadSingleOrder;
end;

procedure TfFormNewCard.Writelog(nMsg: string);
var
  nStr:string;
begin
  nStr := 'weborder[%s]clientid[%s]clientname[%s]sotckno[%s]stockname[%s]';
  nStr := Format(nStr,[editWebOrderNo.Text,EditCus.Text,EditCName.Text,EditStock.Text,EditSName.Text]);
  gSysLoger.AddLog(nStr+nMsg);
end;

procedure TfFormNewCard.AddListViewItem(
  var nWebOrderItem: stMallOrderItem);
var
  nListItem:TListItem;
begin
  nListItem := lvOrders.Items.Add;
  nlistitem.Caption := nWebOrderItem.FOrdernumber;

  nlistitem.SubItems.Add(nWebOrderItem.FGoodsID);
  nlistitem.SubItems.Add(nWebOrderItem.FGoodsname);
  nlistitem.SubItems.Add(nWebOrderItem.Ftracknumber);
  nlistitem.SubItems.Add(nWebOrderItem.FData);
  nlistitem.SubItems.Add(nWebOrderItem.FYunTianOrderId);
end;

procedure TfFormNewCard.InitListView;
var
  col:TListColumn;
begin
  lvOrders.ViewStyle := vsReport;
  col := lvOrders.Columns.Add;
  col.Caption := '网上订单编号';
  col.Width := 300;
  col := lvOrders.Columns.Add;
  col.Caption := '骨料型号';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '骨料名称';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '提货车辆';
  col.Width := 200;
  col := lvOrders.Columns.Add;
  col.Caption := '办理吨数';
  col.Width := 150;
  col := lvOrders.Columns.Add;
  col.Caption := '订单编号';
  col.Width := 250;
end;

procedure TfFormNewCard.FormCreate(Sender: TObject);
begin
  editWebOrderNo.Properties.MaxLength := gSysParam.FWebOrderLength;
  FCardData := TStringList.Create;
  if not Assigned(FDR) then
  begin
    FDR := TFDR.Create(Application);
  end;
  InitListView;
  gSysParam.FUserID := 'AICM';
  FListA := TStringList.Create;  
  gSDTReaderManager.OnSDTEvent := SyncCard;
end;

procedure TfFormNewCard.LoadSingleOrder;
var
  nOrderItem:stMallOrderItem;
  nRepeat, nIsSale : Boolean;
  nWebOrderID:string;
  nMsg,nStr:string;
begin
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := nOrderItem.FOrdernumber;

  FBegin := Now;
  nRepeat := IsRepeatCard(nWebOrderID);

  if nRepeat then
  begin
    nMsg := '此订单已成功办卡，请勿重复操作';
    ShowMsg(nMsg,sHint);
    Writelog(nMsg);
    Exit;
  end;
  writelog('TfFormNewCard.LoadSingleOrder 检查商城订单是否重复使用-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');

  {$IFDEF UseWXServiceEx}
    if Pos('销售',nOrderItem.FType) > 0 then
      nIsSale := True
    else
      nIsSale := False;

    if not nIsSale then
    begin
      nMsg := '此订单不是销售订单！';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg);
      Exit;
    end;

    if nOrderItem.FStatus <> '1' then
    begin
      if nOrderItem.FStatus = '0' then
        nMsg := '此订单状态未知'
      else if nOrderItem.FStatus = '6' then
        nMsg := '此订单已取消'
      else if nOrderItem.FStatus = '7' then
        nMsg := '此订单已过期'
      else
        nMsg := '此订单已使用';
      ShowMsg(nMsg,sHint);
      Writelog(nMsg+nOrderItem.FStatus);
      Exit;
    end;

    //填充界面信息
    //基本信息
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'select Z_Customer,D_Price from %s a join %s b on a.Z_ID = b.D_ZID ' +
            'where Z_ID=''%s'' and D_StockNo=''%s'' ';

    nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,nOrderItem.FYunTianOrderId,nOrderItem.FGoodsID]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount = 1 then
      begin
        EditPrice.Text  := Fields[1].AsString;
      end;
    end;

    //提单信息
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname;
    if StrToFloatDef(nOrderItem.FData,0) <= 50 then
      EditValue.Text := nOrderItem.FData
    else
      EditValue.Text := '50';
    EditTruck.Text  := nOrderItem.Ftracknumber;
    EditCus.Text    := nOrderItem.FCusID;
    EditCName.Text  := nOrderItem.FCusName;
    EditMemo.Text   := nOrderItem.FXHSpot;
    EditSJName.Text := nOrderItem.FdrvName;
  {$ELSE}
    //填充界面信息
    //基本信息
    EditCus.Text    := '';
    EditCName.Text  := '';

    nStr := 'select Z_Customer,D_Price from %s a join %s b on a.Z_ID = b.D_ZID ' +
            'where Z_ID=''%s'' and D_StockNo=''%s'' ';

    nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,nOrderItem.FYunTianOrderId,nOrderItem.FGoodsID]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount = 1 then
      begin
        EditCus.Text    := Fields[0].AsString;
        EditPrice.Text  := Fields[1].AsString;
      end;
    end;

    nStr := 'Select C_Name From %s Where C_ID=''%s'' ';
    nStr := Format(nStr, [sTable_Customer, EditCus.Text]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount>0 then
      begin
        EditCName.Text  := Fields[0].AsString;
      end;
    end;

    //提单信息
    EditType.ItemIndex := 0;
    EditStock.Text  := nOrderItem.FGoodsID;
    EditSName.Text  := nOrderItem.FGoodsname;
    EditValue.Text := nOrderItem.FData;
    EditTruck.Text := nOrderItem.Ftracknumber;
  {$ENDIF}

  BtnOK.Enabled := not nRepeat;
end;

function TfFormNewCard.IsRepeatCard(const nWebOrderItem: string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := 'select * from %s where WOM_WebOrderID=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,nWebOrderItem]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

function TfFormNewCard.VerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    if not Result then
    begin
      nHint := '车牌号长度应大于2位';
      Writelog(nHint);
      Exit;
    end;
  end;
  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    if not Result then
    begin
      nHint := '请填写有效的办理量';
      Writelog(nHint);
      Exit;
    end;
  end;
end;

procedure TfFormNewCard.BtnOKClick(Sender: TObject);
var nIdx, nInt: Integer;
begin
  BtnOK.Enabled := False;
  try
    {$IFDEF UseWXServiceEx}
    nInt := 0;
    for nidx := Low(FWebOrderItems) to High(FWebOrderItems) do
    with FWebOrderItems[nidx] do
    begin
      if ForderDetailType = '3' then//拼单
        Inc(nInt);
    end;

    if nInt > 1 then
    begin
      if not SaveBillProxyPD then
      begin
        BtnOK.Enabled := True;
        Exit;
      end;
    end
    else
    begin
      if not SaveBillProxy then
      begin
        BtnOK.Enabled := True;
        Exit;
      end;
    end;
    {$ELSE}
    if not SaveBillProxy then
    begin
      BtnOK.Enabled := True;
      Exit;
    end;
    {$ENDIF}
    Close;
  except
  end;
end;

function TfFormNewCard.SaveBillProxy: Boolean;
var
  nHint,nMsg:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact:Boolean;
  nBillData:string;
  nBillID :string;
  nWebOrderID:string;
  nNewCardNo:string;
  nidx:Integer;
  i:Integer;
  nRet, nCanLade : Boolean;
  nOrderItem:stMallOrderItem;
  nCard,nMemo,nStr:string;
  nZhiKaMoney, nBLMoney:Double;
begin
  Result := False;
  nOrderItem  := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := editWebOrderNo.Text;

  //获取纸卡限提金额
  nZhiKaMoney := GetZhiKaMoney(nOrderItem.FYunTianOrderId);
  nBLMoney := 0;
  nStr := ' Select D_ParamA, D_Memo From %s Where D_Name=''%s'' '+
          ' and D_Value = (Select Z_PayMent From S_ZhiKa where Z_ID = ''%s'') ';
  nStr := Format(nStr, [sTable_SysDict, 'PaymentItem', nOrderItem.FYunTianOrderId]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nBLMoney := Fields[0].AsFloat;
    nMemo    := Fields[1].AsString;
  end;
  if nZhiKaMoney < nBLMoney then
  begin
    if Trim(nMemo) = 'Y' then
    begin
      ShowMsg('剩余金额已不足'+FloatToStr(nBLMoney), sHint);
      Exit;
    end
    else
    begin
      nStr := '剩余金额已不足'+FloatToStr(nBLMoney)+',您确定要继续办理吗？';
      if not QueryDlg(nStr, sAsk) then Exit;
    end;
  end;
  
  GetCusSaleControlValue(EditCus.Text);

  nCanLade := True;
  if nCanLade then//总量不超
  begin
    for nIdx := Low(gSysParam.FCusSaleControl) to High(gSysParam.FCusSaleControl) do
    with gSysParam.FCusSaleControl[nIdx] do
    begin
      if (not FCanLade) and (nOrderItem.FGoodsID = FGroup) then
      begin
        nCanLade := False;
        Break;
      end;
    end;
  end;

  if not nCanLade then
  begin
    ShowMsg('当日销售量已超,此订单无法办卡', sHint);
    Exit;
  end;

  if Trim(EditValue.Text) = '' then
  begin
    ShowMsg('获取物料价格异常！请联系管理员',sHint);
    Writelog('获取物料价格异常！请联系管理员');
    Exit;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  {$IFDEF UseTruckXTNum}
    if not IsEnoughNum(EditTruck.Text, StrToFloatDef(EditValue.Text,0)) then
    begin
      ShowMsg('超过车辆允许提单最大量！请联系管理员', sHint);
      Exit;
    end;
  {$ENDIF}

  {$IFDEF ForceEleCard}
  {$IFDEF XXCJ}
  if not IsEleCardVaidEx(EditTruck.Text) then
  {$ELSE}
  if not IsEleCardVaid(EditTruck.Text) then
  {$ENDIF}
  begin
    ShowMsg('车辆未办理电子标签或电子标签未启用！请联系管理员', sHint); Exit;
  end;
  {$ENDIF}

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  {$IFDEF UseWebYYOrder}
  if not CheckYYOrderState(nWebOrderID, nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;
  {$ENDIF}

  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(500);
  end;
  //连续三次读卡,成功则退出。
 // nCard := '123456';

  if nCard = '' then
  begin
    nMsg := '卡箱异常,请查看是否有卡.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  WriteLog('读取到卡片: ' + nCard);
  //解析卡片
  if not IsCardValid(nCard) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nMsg := '卡号' + nCard + '非法,回收中,请稍后重新取卡';
    WriteLog(nMsg);
    ShowMsg(nMsg, sWarn);
    Exit;
  end;
  
  if IFHasBill(EditTruck.Text) then
  begin
    ShowMsg('车辆存在未完成的提货单,无法开单,请联系管理员',sHint);
    Exit;
  end;

  //保存提货单
  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    LoadSysDictItem(sFlag_PrintBill, nStocks);

    nTmp.Values['Type']      := 'S';
    nTmp.Values['StockNO']   := EditStock.Text;
    nTmp.Values['StockName'] := EditSName.Text;
    nTmp.Values['Price']     := EditPrice.Text;
    nTmp.Values['Value']     := EditValue.Text;
    nTmp.Values['PrintHY']   := sFlag_Yes;


    nList.Add(PackerEncodeStr(nTmp.Text));
    nPrint := nStocks.IndexOf(EditStock.Text) >= 0;

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := nOrderItem.FYunTianOrderId;
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := sFlag_TiHuo;
      Values['Memo']  := EmptyStr;
      Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
      Values['Seal'] := '';
      Values['HYDan'] := '';
      Values['WebOrderID'] := nWebOrderID;
      {$IFDEF UseXHSpot}
      Values['L_XHSpot'] := EditMemo.Text;
      {$ENDIF}
      Values['SJName']   := EditSJName.Text;
    end;
    nBillData := PackerEncodeStr(nList.Text);
    FBegin := Now;
    nBillID := SaveBill(nBillData);
    if nBillID = '' then
    begin
      nHint := '保存提货单失败';
      ShowMsg(nHint,sError);
      Writelog(nHint);
      Exit;
    end;
    writelog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
    FBegin := Now;
    SaveWebOrderMatch(nBillID,nWebOrderID,sFlag_Sale);
    writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
  finally
    nStocks.Free;
    nList.Free;
    nTmp.Free;
  end;

  nRet := SaveBillCard(nBillID, nCard);

  if not nRet then
  begin
    nMsg := '办理磁卡失败,请重试.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
  //发卡

  if nRet then
  begin
    nMsg := '提货单[ %s ]发卡成功,卡号[ %s ],请收好您的卡片';
    nMsg := Format(nMsg, [nBillID, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

    nMsg := '卡号[ %s ]关联订单失败,请到开票窗口重新关联.';
    nMsg := Format(nMsg, [nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;
  Result := True;
  //达到条件自动冻结纸卡
  CheckDJZhika;
end;

function TfFormNewCard.SaveBillProxyPD: Boolean;
var
  nHint,nMsg,nStr:string;
  nList,nTmp,nStocks: TStrings;
  nPrint,nInFact,nFixMoney:Boolean;
  nBillData:string;
  nBillID :string;
  nWebOrderID:string;
  nNewCardNo:string;
  nidx:Integer;
  i:Integer;
  nRet: Boolean;
  nOrderItem:stMallOrderItem;
  nCard:string;
  nZKMoney : Double;
begin
  Result := False;
  nOrderItem := FWebOrderItems[FWebOrderIndex];
  nWebOrderID := editWebOrderNo.Text;

  if Trim(EditPrice.Text) = '' then
  begin
    ShowMsg('获取物料价格异常！请联系管理员',sHint);
    Writelog('获取物料价格异常！请联系管理员');
    Exit;
  end;

  if not VerifyCtrl(EditTruck,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  {$IFDEF ForceEleCard}
  {$IFDEF XXCJ}
  if not IsEleCardVaidEx(EditTruck.Text) then
  {$ELSE}
  if not IsEleCardVaid(EditTruck.Text) then
  {$ENDIF}
  begin
    ShowMsg('车辆未办理电子标签或电子标签未启用！请联系管理员', sHint); Exit;
  end;
  {$ENDIF}

  if not VerifyCtrl(EditValue,nHint) then
  begin
    ShowMsg(nHint,sHint);
    Writelog(nHint);
    Exit;
  end;

  for nIdx:=0 to 3 do
  begin
    nCard := gDispenserManager.GetCardNo(gSysParam.FTTCEK720ID, nHint, False);
    if nCard <> '' then
      Break;
    Sleep(500);
  end;
  //连续三次读卡,成功则退出。

  if nCard = '' then
  begin
    nMsg := '卡箱异常,请查看是否有卡.';
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  WriteLog('读取到卡片: ' + nCard);
  //解析卡片
  if not IsCardValid(nCard) then
  begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);
    nMsg := '卡号' + nCard + '非法,回收中,请稍后重新取卡';
    WriteLog(nMsg);
    ShowMsg(nMsg, sWarn);
    Exit;
  end;

  if IFHasBill(EditTruck.Text) then
  begin
    ShowMsg('车辆存在未完成的提货单,无法开单,请联系管理员',sHint);
    Exit;
  end;

  for nidx := Low(FWebOrderItems) to High(FWebOrderItems) do
  with FWebOrderItems[nidx] do
  begin
    if ForderDetailType <> '3' then//不是拼单
    begin
      ShowMsg('申请单不是拼单类型,无法开单,请联系管理员',sHint);
      Exit;
    end;
    nStr := 'select Z_Customer,D_Price from %s a join %s b on a.Z_ID = b.D_ZID ' +
            'where Z_ID=''%s'' and D_StockNo=''%s'' ';

    nStr := Format(nStr,[sTable_ZhiKa,sTable_ZhiKaDtl,FYunTianOrderId,FGoodsID]);
    with fdm.QueryTemp(nStr) do
    begin
      if RecordCount = 1 then
      begin
        FPrice  := Fields[1].AsString;
      end;
    end;

    if not IsNumber(FPrice, True) then
    begin
      ShowMsg('订单' + FYunTianOrderId +'价格异常,请联系管理员',sHint);
      Exit;
    end;
    nZKMoney := GetZhikaValidMoney(FYunTianOrderId, nFixMoney);

    nMsg := '订单' + FYunTianOrderId +'开单量' + FData + ',单价' + FPrice +
              ',当前可用金额' + FloatToStr(nZKMoney);
    Writelog(nMsg);
    if (StrToFloat(FPrice) * StrToFloat(FData)) > nZKMoney then
    begin
      ShowMsg( nMsg + ',金额不足,无法开单',sHint);
      Exit;
    end;
  end;

  FListA.Clear;
  for nidx := Low(FWebOrderItems) to High(FWebOrderItems) do
  with FWebOrderItems[nidx] do
  begin
    //保存提货单
    nStocks := TStringList.Create;
    nList := TStringList.Create;
    nTmp := TStringList.Create;
    try
      LoadSysDictItem(sFlag_PrintBill, nStocks);
      nTmp.Values['Type'] := 'S';
      nTmp.Values['StockNO'] := FGoodsID;
      nTmp.Values['StockName'] := FGoodsname;
      nTmp.Values['Price'] := FPrice;
      nTmp.Values['Value'] := FData;

      nTmp.Values['PrintHY'] := sFlag_Yes;

      nList.Add(PackerEncodeStr(nTmp.Text));
      nPrint := nStocks.IndexOf(FGoodsID) >= 0;

      with nList do
      begin
        Values['Bills'] := PackerEncodeStr(nList.Text);
        Values['ZhiKa'] := FYunTianOrderId;
        Values['Truck'] := EditTruck.Text;
        Values['Lading'] := sFlag_TiHuo;
        Values['Memo']  := EmptyStr;
        Values['IsVIP'] := Copy(GetCtrlData(EditType),1,1);
        Values['Seal'] := '';
        Values['HYDan'] := '';
        Values['WebOrderID'] := nWebOrderID;
        {$IFDEF UseXHSpot}
        Values['L_XHSpot'] := FXHSpot;
        {$ENDIF}
      end;
      nBillData := PackerEncodeStr(nList.Text);
      FBegin := Now;
      nBillID := SaveBill(nBillData);
      if nBillID = '' then
      begin
        nHint := '保存提货单失败';
        ShowMsg(nHint,sError);
        Writelog(nHint);
        Exit;
      end;
      writelog('TfFormNewCard.SaveBillProxy 生成提货单['+nBillID+']-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
      FBegin := Now;
      SaveWebOrderMatch(nBillID,nWebOrderID,sFlag_Sale);
      writelog('TfFormNewCard.SaveBillProxy 保存商城订单号-耗时：'+InttoStr(MilliSecondsBetween(Now, FBegin))+'ms');
      FListA.Add(nBillID);
    finally
      nStocks.Free;
      nList.Free;
      nTmp.Free;
    end;
  end;

  for nidx := 0 to FListA.Count - 1 do
    nRet := SaveBillCard(FListA[nidx], nCard);

  if not nRet then
  begin
    nMsg := '办理磁卡失败,请重试.';
    ShowMsg(nMsg, sHint);
    Exit;
  end;

  nRet := gDispenserManager.SendCardOut(gSysParam.FTTCEK720ID, nHint);
  //发卡

  if nRet then
  begin
    nMsg := '提货单[ %s ]发卡成功,卡号[ %s ],请收好您的卡片';
    nMsg := Format(nMsg, [nBillID, nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end
  else begin
    gDispenserManager.RecoveryCard(gSysParam.FTTCEK720ID, nHint);

    nMsg := '卡号[ %s ]关联订单失败,请到开票窗口重新关联.';
    nMsg := Format(nMsg, [nCard]);

    WriteLog(nMsg);
    ShowMsg(nMsg,sWarn);
  end;
  Result := True;
  if nPrint then
  begin
    for nidx := 0 to FListA.Count - 1 do
      PrintBillReport(FListA[nidx], True);
      //print report
  end;
end;

function TfFormNewCard.SaveWebOrderMatch(const nBillID,
  nWebOrderID,nBillType: string):Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := MakeSQLByStr([
  SF('WOM_WebOrderID'   , nWebOrderID),
  SF('WOM_LID'          , nBillID),
  SF('WOM_StatusType'   , c_WeChatStatusCreateCard),
  SF('WOM_MsgType'      , cSendWeChatMsgType_AddBill),
  SF('WOM_BillType'     , nBillType),
  SF('WOM_deleted'     , sFlag_No)
  ], sTable_WebOrderMatch, '', True);
  fdm.ADOConn.BeginTrans;
  try
    fdm.ExecuteSQL(nStr);
    fdm.ADOConn.CommitTrans;
    Result := True;
  except
    fdm.ADOConn.RollbackTrans;
  end;

  if Result then
  begin
    nStr := ' Update %s set W_deleted = ''%s'', W_State = ''%s'',W_SucessTime = %s  where W_WebOrderID = ''%s''';
    nStr := Format(nStr,[sTable_YYWebBill, sFlag_Yes, '1', sField_SQLServer_Now, nWebOrderID]);
    fdm.ExecuteSQL(nStr);
    //更新为已处理
  end;
end;
procedure TfFormNewCard.lvOrdersClick(Sender: TObject);
var
  nSelItem:TListItem;
  i:Integer;
begin
  nSelItem := lvorders.Selected;
  if Assigned(nSelItem) then
  begin
    for i := 0 to lvOrders.Items.Count-1 do
    begin
      if nSelItem = lvOrders.Items[i] then
      begin
        FWebOrderIndex := i;
        LoadSingleOrder;
        Break;
      end;
    end;
  end;
end;

procedure TfFormNewCard.editWebOrderNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  if Key=Char(vk_return) then
  begin
    key := #0;
    if btnQuery.CanFocus then
      btnQuery.SetFocus;
    btnQuery.Click;
  end;
end;

procedure TfFormNewCard.btnClearClick(Sender: TObject);
begin
  FAutoClose := gSysParam.FAutoClose_Mintue;
  editWebOrderNo.Clear;
  ActiveControl := editWebOrderNo;
end;

procedure TfFormNewCard.SyncCard(const nCard: TIdCardInfoStr;
  const nReader: TSDTReaderItem);
var nStr: string;
begin
  nStr := '读取到身份证信息: [ %s ]=>[ %s.%s ]';
  nStr := Format(nStr, [nReader.FID, nCard.FName, nCard.FIdSN]);
  WriteLog(nStr);

  //EditIdent.Text := nCard.FIdSN;
  //
end;

function TfFormNewCard.CheckYYOrderState(const nWebOrderID: string;
  var nHint: string): Boolean;
var
  nStr : string;
begin
  Result := False;
  nHint  := '';
  
  nStr   := ' Select W_State From %s Where W_WebOrderID = ''%s'' ';
  nStr   := Format(nStr, [sTable_YYWebBill, nWebOrderID]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    if Fields[0].AsString = '1' then
    begin
      Result := True;
    end
    else if Fields[0].AsString = '0' then
    begin
      nHint := '订单尚未预约成功,请等待!';
    end
    else
    begin
      nHint := '订单已失效!';
    end;
  end
  else
  begin
    nHint := '订单不存在!';
  end;
end;

function TfFormNewCard.GetZhiKaMoney(const nZhika: string): Double;
var
  nStr : string;
begin
  Result := 0;
  nStr   := ' Select Z_FixedMoney From %s Where Z_ID = ''%s'' ';
  nStr   := Format(nStr, [sTable_ZhiKa, nZhika]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsFloat;
  end;
end;

end.
