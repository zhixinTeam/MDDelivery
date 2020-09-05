unit UFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, ULEDFont, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxMaskEdit, cxDropDownEdit, UMgrdOPCTunnels,
  ExtCtrls, IdContext, IdGlobal, UBusinessConst, ULibFun,
  Menus, cxButtons, UMgrSendCardNo, USysLoger, cxCurrencyEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxSpinEdit, DateUtils,Activex, StrUtils, USysConst;

type
  TFrame1 = class(TFrame)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    btnPause: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton1: TToolButton;
    GroupBox1: TGroupBox;
    StateTimer: TTimer;
    DelayTimer: TTimer;
    cxLabel6: TcxLabel;
    EditMaxValue: TcxTextEdit;
    cxLabel1: TcxLabel;
    editPValue: TcxTextEdit;
    cxLabel2: TcxLabel;
    editZValue: TcxTextEdit;
    cxLabel4: TcxLabel;
    EditBill: TcxComboBox;
    cxLabel5: TcxLabel;
    EditTruck: TcxComboBox;
    cxLabel7: TcxLabel;
    EditMValue: TcxComboBox;
    cxLabel8: TcxLabel;
    EditValue: TcxComboBox;
    procedure BtnStopClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure StateTimerTimer(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
  private
    { Private declarations }
    FCardUsed: string;            //卡片类型
    FUIData: TLadingBillItem;     //界面数据
    FOPCTunnel: PPTOPCItem;       //OPC通道
    FHasDone, FSetValue, FUseTime: Double;
    FDataLarge: Double;//放大倍数
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //设置界面数据
    procedure SetTunnel(const Value: PPTOPCItem);
    procedure WriteLog(const nEvent: string);
    procedure SyncReadValues(const FromCache: boolean);
    procedure Get_Card_Message(var Message: TMessage); message WM_HAVE_CARD ;
  public
    FrameId:Integer;              //PLC通道
    FIsBusy: Boolean;             //占用标识
    FSysLoger : TSysLoger;
    FCard: string;
    FLastValue,FControl : Double;
    property OPCTunnel: PPTOPCItem read FOPCTunnel write SetTunnel;
    procedure LoadBillItems(const nCard: string);
    //读取交货单
    procedure StopPound;
  end;

implementation

{$R *.dfm}

uses
   USysBusiness, USysDB, UDataModule, UFormInputbox, UFormCtrl, main;

procedure TFrame1.Get_Card_Message(var Message: TMessage);
Begin
  EditBill.Text := FCard;
  LoadBillItems(EditBill.Text);
End ;

//Parm: 磁卡或交货单号
//Desc: 读取nCard对应的交货单
procedure TFrame1.LoadBillItems(const nCard: string);
var
  nStr,nTruck: string;
  nBills: TLadingBillItems;
  nRet,nHisMValueControl: Boolean;
  nIdx,nSendValue: Integer;
  nVal, nPreKD: Double;
  nEvent,nEID:string;
begin
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendToPlc']) = sFlag_Yes) then
  begin
    WriteLog('非OPC启动,退出操作');
    Exit;
  end;
  if DelayTimer.Enabled then
  begin
    nStr := '请勿频繁刷卡';
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, nStr);
    SetUIData(True);
    Exit;
  end;
  FDataLarge := 1;

  if Assigned(FOPCTunnel.FOptions) And
       (IsNumber(FOPCTunnel.FOptions.Values['DataLarge'], True)) then
  begin
    FDataLarge := StrToFloat(FOPCTunnel.FOptions.Values['DataLarge']);
  end;

  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['ClearLj']) = sFlag_Yes) then
  begin
    if StrToFloatDef(EditValue.Text, 0) > 0.1 then
    begin
      nStr := '请清除累计量';
      WriteLog(nStr);
      LineClose(FOPCTunnel.FID, sFlag_Yes);
      ShowLedText(FOPCTunnel.FID, nStr);
      SetUIData(True);
      Exit;
    end;
  end;

  WriteLog('接收到卡号:' + nCard);
  FCard := nCard;

  nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills);

  if (not nRet) or (Length(nBills) < 1) then
  begin
    nStr := '读取磁卡信息失败,请联系管理员';
    WriteLog(nStr);
    SetUIData(True);
    Exit;
  end;

  //获取最大限载值
  //nBills[0].FMData.FValue := StrToFloatDef(GetLimitValue(nBills[0].FTruck),0);

  FUIData := nBills[0];

  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['NoHasDone']) = sFlag_Yes) then
    FHasDone := 0
  else
    FHasDone := ReadDoneValue(FUIData.FID, FUseTime);

  FSetValue := FUIData.FValue;

  nHisMValueControl := False;
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['TruckHzValueControl']) = sFlag_Yes) then
    nHisMValueControl := True;

  if nHisMValueControl then
  begin
    nVal := GetTruckSanMaxLadeValue(FUIData.FTruck);
    if (nVal > 0) and (FUIData.FValue > nVal) then//开单量大于系统设定最大量
    begin
      EditMaxValue.Text := Format('%.2f', [nVal]);
      FSetValue := nVal;
      nEvent := '车辆[ %s ]交货单[ %s ],' +
                '开单量[ %.2f ]大于核载量[ %.2f ],调整后开单量[ %.2f ].';
      nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                                FUIData.FValue, nVal, nVal]);
      WriteLog(nEvent);
    end;
  end;

  nVal := GetSanMaxLadeValue;
  if (nVal > 0) and (FUIData.FValue > nVal) then//开单量大于系统设定最大量
  begin
    EditMaxValue.Text := Format('%.2f', [nVal]);
    FSetValue := nVal;
    nEvent := '车辆[ %s ]交货单[ %s ],' +
              '开单量[ %.2f ]大于系统设定最大量[ %.2f ],调整后开单量[ %.2f ].';
    nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                              FUIData.FValue, nVal, nVal]);
    WriteLog(nEvent);
  end;

  nVal := ReadTruckHisMValueMax(FUIData.FTruck);
  nPreKD := GetSanPreKD;

  nHisMValueControl := False;
  if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['HisMValueControl']) = sFlag_Yes) then
    nHisMValueControl := True;

  if nHisMValueControl and (nVal > 0) and
  ((FUIData.FPData.FValue + FUIData.FValue) > nVal) then
  begin
    FSetValue := nVal - FUIData.FPData.FValue - nPreKD;

    //生成事件
    if Assigned(FOPCTunnel.FOptions) And
       (UpperCase(FOPCTunnel.FOptions.Values['SendMsg']) = sFlag_Yes) then
    begin
      try
        nEID := FUIData.FID + 'H';
        nStr := 'Delete From %s Where E_ID=''%s''';
        nStr := Format(nStr, [sTable_ManualEvent, nEID]);

        FDM.ExecuteSQL(nStr);

        nEvent := '车辆[ %s ]交货单[ %s ]装车量已调整,历史最大毛重[ %.2f ],' +
                  '当前皮重[ %.2f ],开单量[ %.2f ],预扣量[ %.2f ],调整后装车量[ %.2f ].';
        nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID, nVal,
                                  FUIData.FPData.FValue, FUIData.FValue,
                                  nPreKD, FSetValue]);
        WriteLog(nEvent);
        nStr := MakeSQLByStr([
            SF('E_ID', nEID),
            SF('E_Key', ''),
            SF('E_From', sFlag_DepJianZhuang),
            SF('E_Event', nEvent),
            SF('E_Solution', sFlag_Solution_OK),
            SF('E_Departmen', sFlag_DepDaTing),
            SF('E_Date', sField_SQLServer_Now, sfVal)
            ], sTable_ManualEvent, '', True);
        FDM.ExecuteSQL(nStr);
      except
        on E: Exception do
        begin
          WriteLog('保存事件失败:' + e.message);
        end;
      end;
    end;
  end
  else
  begin
    if (FUIData.FValue - nPreKD) > 0 then
    begin
      FSetValue := FSetValue - nPreKD;

      nEvent := '车辆[ %s ]交货单[ %s ],' +
                '开单量[ %.2f ],预扣量[ %.2f ],调整后装车量[ %.2f ].';
      nEvent := Format(nEvent, [FUIData.FTruck, FUIData.FID,
                                FUIData.FValue, nPreKD, FSetValue]);
      WriteLog(nEvent);
    end;
  end;

  if FHasDone >= FSetValue then
  begin
    nStr := '交货单[ %s ]设置量[ %.2f ],已装量[ %.2f ],无法继续装车';
    nStr := Format(nStr, [FUIData.FID, FSetValue, FHasDone]);
    WriteLog(nStr);
    LineClose(FOPCTunnel.FID, sFlag_Yes);
    ShowLedText(FOPCTunnel.FID, '装车量已达到设置量');
    SetUIData(True);
    Exit;
  end;

  EditValue.Text := Format('%.2f', [FHasDone]);
  SetUIData(False);

  try
    if Trim(FOPCTunnel.FStartTag) <> '' then
    begin
      for nIdx := 1 to 30 do
      begin
        Sleep(100);
        Application.ProcessMessages;
      end;


      for nIdx := 1 to 30 do
      begin
        Sleep(100);
        Application.ProcessMessages;
      end;
    end;

    LineClose(FOPCTunnel.FID, sFlag_No);
    WriteLog(FOPCTunnel.FID +'发送启动命令成功');
    StateTimer.Tag := 0;
  except
    on E: Exception do
    begin
      StopPound;
      WriteLog(FOPCTunnel.FID +'启动失败,原因为:' + e.Message);
      ShowLedText(FOPCTunnel.FID, '启动失败,请重新刷卡');
    end;
  end;
end;

procedure TFrame1.SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
var
  nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    nItem.FFactory := gSysParam.FFactNum;

    FUIData := nItem;
    if nOnlyData then Exit;

    EditValue.Text := '0.00';
    EditMValue.Text := '0.00';
    EditBill.Properties.Items.Clear;
  end;

  with FUIData do
  begin
    EditBill.Text  := FID;
    EditTruck.Text := FTruck;

    //EditMaxValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);
  end;
end;

procedure TFrame1.WriteLog(const nEvent: string);
begin
  FSysLoger.AddLog(TFrame, '定置装车主单元', nEvent);
end;

procedure TFrame1.SetTunnel(const Value: PPTOPCItem);
begin
  FOPCTunnel := Value;
  SetUIData(true);
end;

procedure TFrame1.StopPound;
begin

end;

procedure TFrame1.BtnStopClick(Sender: TObject);
begin
  try
    StopPound;
  except
    on E: Exception do
    begin
      WriteLog('通道' + FOPCTunnel.FID + '停止称重失败,原因:' + e.Message);
    end;
  end;
end;

procedure TFrame1.BtnStartClick(Sender: TObject);
var nStr: string;
begin
  nStr := FCard;
  if not ShowInputBox('请输入磁卡号:', '提示', nStr) then Exit;
  try
    LoadBillItems(nStr);
  except
    on E: Exception do
    begin
      WriteLog('通道' + FOPCTunnel.FID + '启动称重失败,原因:' + e.Message);
    end;
  end;
end;

procedure TFrame1.SyncReadValues(const FromCache: boolean);
begin

end;

procedure TFrame1.StateTimerTimer(Sender: TObject);
var nInfo: string;
    nList: TStrings;
begin
  StateTimer.Enabled := False;
  StateTimer.Tag := StateTimer.Tag + 1;
  try
    WriteLog('读取库底计量');
    if not ReadBaseWeight(FOPCTunnel.FID, nInfo) then
    begin
      StateTimer.Enabled := True;
      Exit;
    end;
    WriteLog('库底计量:' + nInfo);
    nList := TStringList.Create;
    try
      nList.Text        := nInfo;
      EditMaxValue.Text := nList.Values['ValueMax'];
      EditBill.Text     := nList.Values['Bill'];
      editPValue.Text   := nList.Values['PValue'];
      EditMValue.Text   := nList.Values['MValue'];
      EditValue.Text    := nList.Values['NetValue'];
      editZValue.Text   := nList.Values['Value'];
      EditTruck.Text    := GetTruckInfo(nList.Values['Bill']);
    finally
      nList.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLog(e.Message);
    end;
  end;
  StateTimer.Enabled := True;
end;

procedure TFrame1.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Tag := DelayTimer.Tag + 1;
  if DelayTimer.Tag >= 10 then
  begin
    DelayTimer.Enabled := False;
  end;
end;

end.
