{*******************************************************************************
  ����: dmzn@163.com 2014-10-20
  ����: �Զ�����ͨ����
*******************************************************************************}
unit UFramePoundAutoItem;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UMgrPoundTunnels, UBusinessConst, UFrameBase, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, StdCtrls,
  UTransEdit, ExtCtrls, cxRadioGroup, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLabel, ULEDFont, DateUtils, dxSkinsCore,
  dxSkinsDefaultPainters;

type
  TfFrameAutoPoundItem = class(TBaseFrame)
    GroupBox1: TGroupBox;
    EditValue: TLEDFontNum;
    GroupBox3: TGroupBox;
    ImageGS: TImage;
    Label16: TLabel;
    Label17: TLabel;
    ImageBT: TImage;
    Label18: TLabel;
    ImageBQ: TImage;
    ImageOff: TImage;
    ImageOn: TImage;
    HintLabel: TcxLabel;
    EditTruck: TcxComboBox;
    EditMID: TcxComboBox;
    EditPID: TcxComboBox;
    EditMValue: TcxTextEdit;
    EditPValue: TcxTextEdit;
    EditJValue: TcxTextEdit;
    Timer1: TTimer;
    EditBill: TcxComboBox;
    EditZValue: TcxTextEdit;
    GroupBox2: TGroupBox;
    RadioPD: TcxRadioButton;
    RadioCC: TcxRadioButton;
    EditMemo: TcxTextEdit;
    EditWValue: TcxTextEdit;
    RadioLS: TcxRadioButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    cxLabel10: TcxLabel;
    Timer2: TTimer;
    Timer_ReadCard: TTimer;
    TimerDelay: TTimer;
    MemoLog: TZnTransMemo;
    Timer_SaveFail: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Timer_ReadCardTimer(Sender: TObject);
    procedure TimerDelayTimer(Sender: TObject);
    procedure Timer_SaveFailTimer(Sender: TObject);
    procedure EditBillKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FCardUsed: string;
    //��Ƭ����
    FLEDContent: string;
    //��ʾ������
    FIsWeighting, FIsSaving: Boolean;
    //���ر�ʶ,�����ʶ
    FPoundTunnel: PPTTunnelItem;
    //��վͨ��
    FLastGS,FLastBT,FLastBQ: Int64;
    //�ϴλ
    FBillItems: TLadingBillItems;
    FUIData,FInnerData: TLadingBillItem;
    //��������
    FLastCardDone: Int64;
    FLastCard, FCardTmp, FLastReader: string;
    //�ϴο���, ��ʱ����, ���������
    FSampleIndex: Integer;
    FValueSamples: array of Double;
    //���ݲ���
    FVirPoundID: string;
    //����ذ����
    FBarrierGate: Boolean;
    //�Ƿ���õ�բ
    FAutoTruckOut : Boolean;
    //�Ƿ��Զ�����
    FSaveResult: Boolean;
    //������
    FEmptyPoundInit, FDoneEmptyPoundInit: Int64;
    //�հ���ʱ,���������հ�
    FEmptyPoundIdleLong, FEmptyPoundIdleShort: Int64;
    FLogin: Integer;
    //�������½
    FIsChkPoundStatus : Boolean;
    procedure SetUIData(const nReset: Boolean; const nOnlyData: Boolean = False);
    //��������
    procedure SetImageStatus(const nImage: TImage; const nOff: Boolean);
    //����״̬
    procedure SetTunnel(const nTunnel: PPTTunnelItem);
    //����ͨ��
    procedure OnPoundDataEvent(const nValue: Double);
    procedure OnPoundData(const nValue: Double);
    //��ȡ����
    procedure LoadBillItems(const nCard: string);
    //��ȡ������
    procedure InitSamples;
    procedure AddSample(const nValue: Double);
    function IsValidSamaple: Boolean;
    //��������
    function SavePoundSale: Boolean;
    function SavePoundData: Boolean;
    //�������
    procedure WriteLog(nEvent: string);
    //��¼��־
    procedure PlayVoice(const nStrtext: string);
    //��������
    procedure LEDDisplay(const nContent: string);
    //LED��ʾ
    function ChkPoundStatus:Boolean;
  public
    { Public declarations }
    class function FrameID: integer; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //����̳�
    property PoundTunnel: PPTTunnelItem read FPoundTunnel write SetTunnel;
    //�������
  end;

implementation

{$R *.dfm}

uses
  ULibFun, UFormBase, {$IFDEF HR1847}UKRTruckProber,{$ELSE}UMgrTruckProbe,{$ENDIF}
  UMgrRemoteVoice, UMgrVoiceNet, UDataModule, USysBusiness, UMgrLEDDisp,
  USysLoger, USysConst, USysDB;

const
  cFlag_ON    = 10;
  cFlag_OFF   = 20;

class function TfFrameAutoPoundItem.FrameID: integer;
begin
  Result := 0;
end;

procedure TfFrameAutoPoundItem.OnCreateFrame;
begin
  inherited;
  FPoundTunnel := nil;
  FIsWeighting := False;

  FLEDContent := '';
  FEmptyPoundInit := 0;
  FLogin := -1;
end;

procedure TfFrameAutoPoundItem.OnDestroyFrame;
begin
  gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
  //�رձ�ͷ�˿�
  {$IFDEF CapturePictureEx}
  FreeCapture(FLogin);
  {$ENDIF}
  inherited;
end;

//Desc: ��������״̬ͼ��
procedure TfFrameAutoPoundItem.SetImageStatus(const nImage: TImage;
  const nOff: Boolean);
begin
  if nOff then
  begin
    if nImage.Tag <> cFlag_OFF then
    begin
      nImage.Tag := cFlag_OFF;
      nImage.Picture.Bitmap := ImageOff.Picture.Bitmap;
    end;
  end else
  begin
    if nImage.Tag <> cFlag_ON then
    begin
      nImage.Tag := cFlag_ON;
      nImage.Picture.Bitmap := ImageOn.Picture.Bitmap;
    end;
  end;
end;

procedure TfFrameAutoPoundItem.WriteLog(nEvent: string);
var nInt: Integer;
begin
  with MemoLog do
  try
    Lines.BeginUpdate;
    if Lines.Count > 20 then
     for nInt:=1 to 10 do
      Lines.Delete(0);
    //��������

    Lines.Add(DateTime2Str(Now) + #9 + nEvent);
  finally
    Lines.EndUpdate;
    Perform(EM_SCROLLCARET,0,0);
    Application.ProcessMessages;
  end;
end;

procedure WriteSysLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFrameAutoPoundItem, '�Զ�����ҵ��', nEvent);
end;

//------------------------------------------------------------------------------
//Desc: ��������״̬
procedure TfFrameAutoPoundItem.Timer1Timer(Sender: TObject);
begin
  SetImageStatus(ImageGS, GetTickCount - FLastGS > 5 * 1000);
  SetImageStatus(ImageBT, GetTickCount - FLastBT > 5 * 1000);
  SetImageStatus(ImageBQ, GetTickCount - FLastBQ > 5 * 1000);
end;

//Desc: �رպ��̵�
procedure TfFrameAutoPoundItem.Timer2Timer(Sender: TObject);
begin
  Timer2.Tag := Timer2.Tag + 1;
  if Timer2.Tag < 10 then Exit;

  Timer2.Tag := 0;
  Timer2.Enabled := False;

  {$IFNDEF MITTruckProber}
    {$IFDEF HR1847}
    gKRMgrProber.TunnelOC(FPoundTunnel.FID,False);
    {$ELSE}
    gProberManager.TunnelOC(FPoundTunnel.FID,False);
    {$ENDIF}
  {$ENDIF}
end;

//Desc: ����ͨ��
procedure TfFrameAutoPoundItem.SetTunnel(const nTunnel: PPTTunnelItem);
begin
  FBarrierGate := False;
  FEmptyPoundIdleLong := -1;
  FEmptyPoundIdleShort:= -1;

  FPoundTunnel := nTunnel;
  SetUIData(True);

  {$IFDEF CapturePictureEx}
  if not InitCapture(FPoundTunnel,FLogin) then
    WriteLog('ͨ��:'+ FPoundTunnel.FID+'��ʼ��ʧ��,������:'+IntToStr(FLogin))
  else
    WriteLog('ͨ��:'+ FPoundTunnel.FID+'��ʼ���ɹ�,��½ID:'+IntToStr(FLogin));
  {$ENDIF}
  FAutoTruckOut := False;
  if Assigned(FPoundTunnel.FOptions) then
  with FPoundTunnel.FOptions do
  begin
    FVirPoundID  := Values['VirPoundID'];
    FBarrierGate := Values['BarrierGate'] = sFlag_Yes;
    FEmptyPoundIdleLong := StrToInt64Def(Values['EmptyIdleLong'], 60);
    FEmptyPoundIdleShort:= StrToInt64Def(Values['EmptyIdleShort'], 5);

    FAutoTruckOut := Values['AutoTruckOut'] = sFlag_Yes;
  end;
end;

//Desc: ���ý�������
procedure TfFrameAutoPoundItem.SetUIData(const nReset,nOnlyData: Boolean);
var nStr: string;
    nInt: Integer;
    nVal: Double;
    nItem: TLadingBillItem;
begin
  if nReset then
  begin
    FillChar(nItem, SizeOf(nItem), #0);
    //init

    with nItem do
    begin
      FPModel := sFlag_PoundPD;
      FFactory := gSysParam.FFactNum;
    end;

    FUIData := nItem;
    FInnerData := nItem;
    if nOnlyData then Exit;

    SetLength(FBillItems, 0);
    EditValue.Text := '0.00';
    EditBill.Properties.Items.Clear;

    FIsSaving    := False;
    FEmptyPoundInit := 0;

    if not FIsWeighting then
    begin
      gPoundTunnelManager.ClosePort(FPoundTunnel.FID);
      //�رձ�ͷ�˿�

      Timer_ReadCard.Enabled := True;
      //��������
    end;
  end;

  with FUIData do
  begin
    EditBill.Text := FID;
    EditTruck.Text := FTruck;
    EditMID.Text := FStockName;
    EditPID.Text := FCusName;

    EditMValue.Text := Format('%.2f', [FMData.FValue]);
    EditPValue.Text := Format('%.2f', [FPData.FValue]);
    EditZValue.Text := Format('%.2f', [FValue]);

    if (FValue > 0) and (FMData.FValue > 0) and (FPData.FValue > 0) then
    begin
      nVal := FMData.FValue - FPData.FValue;
      EditJValue.Text := Format('%.2f', [nVal]);
      EditWValue.Text := Format('%.2f', [FValue - nVal]);
    end else
    begin
      EditJValue.Text := '0.00';
      EditWValue.Text := '0.00';
    end;

    RadioPD.Checked := FPModel = sFlag_PoundPD;
    RadioCC.Checked := FPModel = sFlag_PoundCC;
    RadioLS.Checked := FPModel = sFlag_PoundLS;

    RadioLS.Enabled := (FPoundID = '') and (FID = '');
    //�ѳƹ�����������,������ʱģʽ
    RadioCC.Enabled := FID <> '';
    //ֻ�������г���ģʽ

    EditBill.Properties.ReadOnly := (FID = '') and (FTruck <> '');
    EditTruck.Properties.ReadOnly := FTruck <> '';
    EditMID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    EditPID.Properties.ReadOnly := (FID <> '') or (FPoundID <> '');
    //�����������

    EditMemo.Properties.ReadOnly := True;
    EditMValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditPValue.Properties.ReadOnly := not FPoundTunnel.FUserInput;
    EditJValue.Properties.ReadOnly := True;
    EditZValue.Properties.ReadOnly := True;
    EditWValue.Properties.ReadOnly := True;
    //������������

    if FTruck = '' then
    begin
      EditMemo.Text := '';
      Exit;
    end;
  end;

  nInt := Length(FBillItems);
  if nInt > 0 then
  begin
    if nInt > 1 then
         nStr := '���۲���'
    else nStr := '����';

    if FCardUsed = sFlag_Provide then nStr := '��Ӧ';

    if FUIData.FNextStatus = sFlag_TruckBFP then
    begin
      RadioCC.Enabled := False;
      EditMemo.Text := nStr + '��Ƥ��';
    end else
    begin
      RadioCC.Enabled := True;
      EditMemo.Text := nStr + '��ë��';
    end;
  end else
  begin
    if RadioLS.Checked then
      EditMemo.Text := '������ʱ����';
    //xxxxx

    if RadioPD.Checked then
      EditMemo.Text := '������Գ���';
    //xxxxx
  end;
end;

//Date: 2014-09-19
//Parm: �ſ��򽻻�����
//Desc: ��ȡnCard��Ӧ�Ľ�����
procedure TfFrameAutoPoundItem.LoadBillItems(const nCard: string);
var nRet: Boolean;
    nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nStr,nHint, nVoice, nLabel,nPos: string;
begin
  nStr := Format('��ȡ������[ %s ],��ʼִ��ҵ��.', [nCard]);
  WriteLog(nStr);

  FCardUsed := GetCardUsed(nCard);
  if FCardUsed = sFlag_Provide then
     nRet := GetPurchaseOrders(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_DuanDao then
     nRet := GetDuanDaoItems(nCard, sFlag_TruckBFP, nBills) else
  if FCardUsed=sFlag_Sale then
     nRet := GetLadingBills(nCard, sFlag_TruckBFP, nBills) else nRet := False;

  if (not nRet) or (Length(nBills) < 1)
  then
  begin
    nVoice := '��ȡ�ſ���Ϣʧ��,����ϵ����Ա';
    PlayVoice(nVoice);
    WriteLog(nVoice);
    SetUIData(True);
    Exit;
  end;

  nHint := '';
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    {$IFDEF TruckAutoIn}
    if FStatus=sFlag_TruckNone then
    begin
      if FCardUsed = sFlag_Provide then
      begin
        if SavePurchaseOrders(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end
      else
      if FCardUsed = sFlag_Sale then
      begin
//        if not GetTruckIsQueue(FTruck) then
//        begin
//          nStr := '[n1]%s���ܹ���,��ȴ�';
//          nStr := Format(nStr, [FTruck]);
//          PlayVoice(nStr);
//          Exit;
//        end;
        if GetTruckIsOut(FTruck) then
        begin
          nStr := '[n1]%s�ѳ�ʱ����,����ϵ����Ա����';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);
          Exit;
        end;
        
        if SaveLadingBills(sFlag_TruckIn, nBills) then
        begin
          ShowMsg('���������ɹ�', sHint);
          LoadBillItems(FCardTmp);
          Exit;
        end else
        begin
          ShowMsg('��������ʧ��', sHint);
        end;
      end;
    end;
    {$ENDIF}
    if (FStatus <> sFlag_TruckBFP) and (FNextStatus = sFlag_TruckZT) then
      FNextStatus := sFlag_TruckBFP;
    //״̬У��

    FSelected := (FNextStatus = sFlag_TruckBFP) or
                 (FNextStatus = sFlag_TruckBFM);
    //�ɳ���״̬�ж�

    //��Ӧ��ҵ��,��������δ���գ���ֱ������ѭ��
    {$IFDEF DoubleCheck}
    if (FCardUsed=sFlag_Provide) and (FNextStatus = sFlag_TruckBFM) and GetWlbYsStatus(FStockNo,FID) then
    begin
      nInt := 0;
      nVoice := '������δ����,���� %s ���ܹ���';
      nVoice := Format(nVoice, [FTruck]);

      nStr := '��.����:[ %s ] ״̬: ������δ����';
      nstr := Format(nStr,[FID]);
      nHint := nStr;
      Break;
    end;
    {$ENDIF} 

    if FSelected then
    begin
      Inc(nInt);
      Continue;
    end;

    nStr := '��.����:[ %s ] ״̬:[ %-6s -> %-6s ]   ';
    if nIdx < High(nBills) then nStr := nStr + #13#10;

    nStr := Format(nStr, [FID,
            TruckStatusToStr(FStatus), TruckStatusToStr(FNextStatus)]);
    nHint := nHint + nStr;

    nVoice := '���� %s ���ܹ���,Ӧ��ȥ %s ';
    nVoice := Format(nVoice, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt = 0 then
  begin
    PlayVoice(nVoice);
    //����״̬�쳣

    nHint := '�ó�����ǰ���ܹ���,��������: ' + #13#10#13#10 + nHint;
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;

  {$IFDEF UseEnableStruck}
//  if nBills[0].FStatus=sFlag_TruckNone then
//  begin
//    if not VeriFyTruckLicense(FLastReader, nBills[0], nHint, nPos) then
//    begin
//      nVoice := '%s����ʶ��ʧ��,���ƶ���������ϵ����Ա';
//      nVoice := Format(nVoice, [nBills[0].FTruck]);
//      PlayVoice(nHint);
//      WriteSysLog(nHint);
//      SetUIData(True);
//      Exit;
//    end
//    else
//    begin
//      if nHint <> '' then
//      begin
//        PlayVoice(nHint);
//        WriteSysLog(nHint);
//      end;
//    end;
//  end;
  {$ENDIF}

  EditBill.Properties.Items.Clear;
  SetLength(FBillItems, nInt);
  nInt := 0;

  for nIdx:=Low(nBills) to High(nBills) do
  with nBills[nIdx] do
  begin
    if FSelected then
    begin
      FPoundID := '';
      //�ñ����������;

      if nInt = 0 then
           FInnerData := nBills[nIdx]
      else FInnerData.FValue := FInnerData.FValue + FValue;
      //�ۼ���

      EditBill.Properties.Items.Add(FID);
      FBillItems[nInt] := nBills[nIdx];
      Inc(nInt);
    end;
  end;

  FInnerData.FPModel := sFlag_PoundPD;
  FUIData := FInnerData;
  SetUIData(False);

  nInt := GetTruckLastTime(FUIData.FTruck);
  if (nInt > 0) and (nInt < FPoundTunnel.FCardInterval) then
  begin
    nStr := '��վ[ %s.%s ]: ����[ %s ]��ȴ� %d �����ܹ���';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            FUIData.FTruck, FPoundTunnel.FCardInterval - nInt]);
    WriteSysLog(nStr);
    SetUIData(True);
    Exit;
  end;
  //ָ��ʱ���ڳ�����ֹ����

  if FVirPoundID <> '' then
  begin
    nLabel := GetTruckRealLabel(FUIData.FTruck);
    if nLabel <> '' then
    begin
      nHint := ReadPoundCardEx(nStr, FVirPoundID);
      if (nHint = '') or (Pos(nLabel, nHint) < 1) then
      begin
        nStr := 'δʶ�����ǩ,���ƶ�����.';
        PlayVoice(nStr);

        nStr := '��վ[ %s.%s ]: ����[ %s.%s ]���ӱ�ǩ��ƥ��[ %s ],��ֹ�ϰ�';
        nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
                FUIData.FTruck, nLabel, nHint]);
        WriteSysLog(nStr);
        SetUIData(True);
        Exit;
      end;
    end;
  end;
  //�жϳ����Ƿ��λ

  {$IFDEF SpecialControl}
  if not IsSealInfoDone(FCardUsed, FUIData) then
  begin
    nStr := 'Ǧ����Ϣ������,�޷�����.';
    PlayVoice(nStr);

    SetUIData(True);
    Exit;
  end;
  {$ENDIF}  //Ǧ����ϢУ��

  InitSamples;
  //��ʼ������

  if not FPoundTunnel.FUserInput then
  if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
         OnPoundDataEvent, True) then
  begin
    nHint := '���ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
    WriteSysLog(nHint);

    nVoice := nHint;
    PlayVoice(nVoice);

    SetUIData(True);
    Exit;
  end;

  Timer_ReadCard.Enabled := False;
  FDoneEmptyPoundInit := 0;
  FIsWeighting := True;
  FSaveResult := True;
  //ֹͣ����,��ʼ����

  if FBarrierGate then
  begin
    {$IFDEF ZZSJ}
    if (FUIData.FStatus = sFlag_TruckIn) or
       (FUIData.FStatus = sFlag_TruckBFP) then
    begin
      nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��,������ϵ�ð�ȫ��,���ð�ȫñ';
      nStr := Format(nStr, [FUIData.FTruck]);
    end;
    {$ELSE}
    nStr := '[n1]%sˢ���ɹ����ϰ�,��Ϩ��ͣ��';
    nStr := Format(nStr, [FUIData.FTruck]);
    {$ENDIF}
    
    PlayVoice(nStr);
    //�����ɹ���������ʾ

    {$IFNDEF DEBUG}
    for nIdx := 0 to 2 do
    begin
      OpenDoorByReader(FLastReader);
    end;
    //������բ
    {$ENDIF}
  end;
  //�����ϰ�
end;

//------------------------------------------------------------------------------
//Desc: �ɶ�ʱ��ȡ������
procedure TfFrameAutoPoundItem.Timer_ReadCardTimer(Sender: TObject);
var nStr,nCard: string;
    nLast, nDoneTmp: Int64;
begin
  if gSysParam.FIsManual then Exit;
  Timer_ReadCard.Tag := Timer_ReadCard.Tag + 1;
  if Timer_ReadCard.Tag < 2 then Exit;

  Timer_ReadCard.Tag := 0;
  if FIsWeighting then Exit;

  try
    WriteLog('���ڶ�ȡ�ſ���.');
    {$IFNDEF DEBUG}
    nCard := Trim(ReadPoundCard(FPoundTunnel.FID, FLastReader));
    {$ENDIF}
    if nCard = '' then Exit;

    if nCard <> FLastCard then
         nDoneTmp := 0
    else nDoneTmp := FLastCardDone;
    //�¿�ʱ����

    {$IFDEF DEBUG}
    nStr := '��վ[ %s.%s ]: ��ȡ���¿���::: %s =>�ɿ���::: %s';
    nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
            nCard, FLastCard]);
    WriteSysLog(nStr);
    {$ENDIF}

    nLast := Trunc((GetTickCount - nDoneTmp) / 1000);
    if (nDoneTmp <> 0) and (nLast < FPoundTunnel.FCardInterval)  then
    begin
      nStr := '��վ[ %s.%s ]: �ſ�[ %s ]��ȴ� %d �����ܹ���';
      nStr := Format(nStr, [FPoundTunnel.FID, FPoundTunnel.FName,
              nCard, FPoundTunnel.FCardInterval - nLast]);
      WriteSysLog(nStr);
      Exit;
    end;
    {$IFNDEF NoCheckPound}
    if Not ChkPoundStatus then Exit;
    {$ENDIF}
    //���ذ�״̬ �粻Ϊ�հ����򺰻� �˳�����

    FCardTmp := nCard;
    EditBill.Text := nCard;
    LoadBillItems(EditBill.Text);
  except
    on E: Exception do
    begin
      nStr := Format('��վ[ %s.%s ]: ',[FPoundTunnel.FID,
              FPoundTunnel.FName]) + E.Message;
      WriteSysLog(nStr);

      SetUIData(True);
      //����������
    end;
  end;
end;

//Desc: ��������
function TfFrameAutoPoundItem.SavePoundSale: Boolean;
var nStr: string;
    nVal,nNet: Double;
    nMoney,nMValueMax: Double;
    nFixMoney: Boolean;
begin
  Result := False;
  //init

  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
  begin
    if FUIData.FPData.FValue <= 0 then
    begin
      WriteLog('���ȳ���Ƥ��');
      Exit;
    end;

    nNet := GetTruckEmptyValue(FUIData.FTruck);
    nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

    if (nNet > 0) and (Abs(nVal) > gSysParam.FPoundSanF) then
    begin
      {$IFDEF AutoPoundInManual}
      nStr := '����[%s]ʵʱƤ�����ϴ�,��֪ͨ˾����鳵��';
      nStr := Format(nStr, [FUIData.FTruck]);
      PlayVoice(nStr);

      nStr := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10#13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10#13#10 +
              '�Ƿ��������?';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);
      if not QueryDlg(nStr, sAsk) then Exit;
      {$ELSE}
      nStr := '����[ %s ]ʵʱƤ�����ϴ�,��������:' + #13#10 +
              '��.ʵʱƤ��: %.2f��' + #13#10 +
              '��.��ʷƤ��: %.2f��' + #13#10 +
              '��.�����: %.2f����' + #13#10 +
              '��������,��ѡ��;��ֹ����,��ѡ��.';
      nStr := Format(nStr, [FUIData.FTruck, FUIData.FPData.FValue,
              nNet, nVal]);

      if not VerifyManualEventRecord(FUIData.FID + sFlag_ManualB, nStr,
        sFlag_Yes, False) then
      begin
        AddManualEventRecord(FUIData.FID + sFlag_ManualB, FUIData.FTruck, nStr,
            sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepDaTing, True);
        WriteSysLog(nStr);

        nStr := '[n1]%sƤ�س���Ԥ��,���°���ϵ��ƱԱ�������ٴι���';
        nStr := Format(nStr, [FUIData.FTruck]);
        PlayVoice(nStr);
        Exit;
      end;
      {$ENDIF}
    end;
  end else
  begin
    if FUIData.FMData.FValue <= 0 then
    begin
      WriteLog('���ȳ���ë��');
      Exit;
    end;
    nMValueMax := GetSaleMValueMax;
    if nMValueMax > 0 then
    begin
      if FBillItems[0].FType = sFlag_San then
      begin
        if (FUIData.FMData.FValue > nMValueMax) and (FUIData.FMData.FValue-nMValueMax <=0.5) then
        begin
          nStr := '����[ %s ]ë�س����涨��Χ,��������:' + #13#10 +
                  '��.ʵʱë��: %.2f��' + #13#10 +
                  '��������,��ѡ��;��ֹ����,��ѡ��.';
          nStr := Format(nStr, [FUIData.FTruck, FUIData.FMData.FValue]);

          if not VerifyManualEventRecord(FUIData.FID + sFlag_ManualF, nStr, sFlag_Yes, False) then
          begin
            AddManualEventRecord(FUIData.FID + sFlag_ManualF, FUIData.FTruck, nStr,
              sFlag_DepBangFang1, sFlag_Solution_YN, sFlag_DepBangFang1, True);
            WriteSysLog(nStr);
            nStr := '����[ %s ]ë�س����涨��Χ,��������:' + #13#10 +
                    '��.ʵʱë��: %.2f��';
            nStr := Format(nStr, [FUIData.FTruck, FUIData.FMData.FValue]);
            nStr := nStr + #13#10#13#10 + '�Ƿ��������?';
            PlayVoice('ë�س����涨��Χ,��ж��');
            LEDDisplay('ë�س����涨��Χ,��ж��');
            if not QueryDlg(nStr, sAsk) then
            begin
              Exit;
            end;
          end;
        end
        else if (FUIData.FMData.FValue > nMValueMax) and (FUIData.FMData.FValue-nMValueMax > 0.5) then
        begin
          nStr := 'ë�س����涨��Χ,��ж��';
          WriteSysLog(nStr);
          PlayVoice(nStr);
          LEDDisplay(nStr);
          Exit;
        end;
      end;
    end;
  end;

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FBillItems[0].FYSValid <> sFlag_Yes then //�ж��Ƿ�ճ�����
    begin
      if FUIData.FPData.FValue > FUIData.FMData.FValue then
      begin
        WriteLog('Ƥ��ӦС��ë��');
        Exit;
      end;

      nNet := FUIData.FMData.FValue - FUIData.FPData.FValue;
      //����
      nVal := nNet * 1000 - FInnerData.FValue * 1000;
      //�뿪Ʊ�����(����)

      with gSysParam,FBillItems[0] do
      begin
        {$IFDEF DaiStepWuCha}
        if FType = sFlag_Dai then
        begin
          GetPoundAutoWuCha(FPoundDaiZ, FPoundDaiF, FInnerData.FValue);
          //�������
        end;
        {$ELSE}
        if FDaiPercent and (FType = sFlag_Dai) then
        begin
          if nVal > 0 then
               FPoundDaiZ := Float2Float(FInnerData.FValue * FPoundDaiZ_1 * 1000,
                                         cPrecision, False)
          else FPoundDaiF := Float2Float(FInnerData.FValue * FPoundDaiF_1 * 1000,
                                         cPrecision, False);
        end;
        {$ENDIF}
        //���������־
        if (FType = sFlag_Dai) then
        begin
          nStr := '����[ %s ]����[%s]������: %.2f��,װ����: %.2f��,�����: %.2f����,��Χ:%.2f ~ %.2f';
          nStr := Format(nStr, [FID, FTruck, FInnerData.FValue, nNet, nVal,FPoundDaiF,FPoundDaiZ]);
          WriteSysLog(nStr);
          {$IFDEF DaiWCInManual}
            nStr := '����[ %s ]����δ������������ϴ����Ϣ:' + #13#10 +
                    '�����Ϻ�,���ȷ�����¹���.';
            nStr := Format(nStr, [FTruck]);

            if not VerifyManualEventRecordEx(FID + sFlag_ManualC, nStr) then
            begin
              nStr := '����[ %s ]����δ������������ϴ����Ϣ:' + #13#10 +
                    '�����Ϻ�,���ȷ�����¹���.';
              nStr := Format(nStr, [FTruck]);
              PlayVoice(nStr);

              nStr := GetTruckNO(FTruck) + '��ȥ��װ���';
              LEDDisplay(nStr);

              {$IFDEF ProberShow}
                {$IFDEF MITTruckProber}
                ProberShowTxt(FPoundTunnel.FID, nStr);
                {$ELSE}
                gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
                {$ENDIF}
              {$ENDIF}
              Exit;
            end;
          {$ENDIF}
        end;
        if ((FType = sFlag_Dai) and (
            ((nVal > 0) and (FPoundDaiZ > 0) and (nVal > FPoundDaiZ)) or
            ((nVal < 0) and (FPoundDaiF > 0) and (-nVal > FPoundDaiF)))) then
        begin
          {$IFDEF AutoPoundInManual}
          nStr := '����[%s]ʵ��װ�������ϴ���֪ͨ˾���������';
          nStr := Format(nStr, [FTruck]);
          PlayVoice(nStr);

          nStr := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10#13#10 +
                  '��.������: %.2f��' + #13#10 +
                  '��.װ����: %.2f��' + #13#10 +
                  '��.�����: %.2f����';

          if FDaiWCStop then
          begin
            nStr := nStr + #13#10#13#10 + '��֪ͨ˾���������.';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

            ShowDlg(nStr, sHint);
            Exit;
          end else
          begin
            nStr := nStr + #13#10#13#10 + '�Ƿ��������?';
            nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);
            if not QueryDlg(nStr, sAsk) then Exit;
          end;
          {$ELSE}
          nStr := '����[ %s ]ʵ��װ�������ϴ�,��������:' + #13#10 +
                  '��.������: %.2f��' + #13#10 +
                  '��.װ����: %.2f��' + #13#10 +
                  '��.�����: %.2f����' + #13#10 +
                  '�����Ϻ�,���ȷ�����¹���.';
          nStr := Format(nStr, [FTruck, FInnerData.FValue, nNet, nVal]);

          if not VerifyManualEventRecord(FID + sFlag_ManualC, nStr) then
          begin
            AddManualEventRecord(FID + sFlag_ManualC, FTruck, nStr,
              sFlag_DepBangFang, sFlag_Solution_YN, sFlag_DepJianZhuang, True);
            WriteSysLog(nStr);

            nStr := '����[n1]%s����[n2]%.2f��,��Ʊ��[n2]%.2f��,'+
                    '�����[n2]%.2f����,��ȥ��װ���';
            nStr := Format(nStr, [FTruck, nNet, FInnerData.FValue, nVal]);
            PlayVoice(nStr);

            nStr := GetTruckNO(FTruck) + '��ȥ��װ���';
            LEDDisplay(nStr);

            {$IFDEF ProberShow}
              {$IFDEF MITTruckProber}
              ProberShowTxt(FPoundTunnel.FID, nStr);
              {$ELSE}
              gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
              {$ENDIF}
            {$ENDIF}
            Exit;
          end;
          {$ENDIF}
        end;

        if (FType = sFlag_San) and IsStrictSanValue and
           FloatRelation(FValue, nNet, rtLess, cPrecision) then
        begin
          nStr := '����[n1]%s[p500]����[n2]%.2f��[p500]��Ʊ��[n2]%.2f��,��ж��';
          nStr := Format(nStr, [FTruck, Float2Float(nNet, cPrecision, True),
                  Float2Float(FValue, cPrecision, True)]);
          WriteSysLog(nStr);
          PlayVoice(nStr);
          Exit;
        end;
      end;
    end
    else
    begin
      nNet := FUIData.FMData.FValue;
      nVal := nNet * 1000 - FUIData.FPData.FValue * 1000;

      if (nNet > 0) and (Abs(nVal) > gSysParam.FEmpTruckWc) then
      begin
        nVal := nVal - gSysParam.FEmpTruckWc;
        nStr := '����[n1]%s[p500]�ճ���������[n2]%.2f����';
        nStr := Format(nStr, [FBillItems[0].FTruck, Float2Float(nVal, cPrecision, True)]);
        WriteSysLog(nStr);
        PlayVoice(nStr);

        nStr := nStr + #13#10#13#10 + '�Ƿ��������?';
        if not QueryDlg(nStr, sAsk) then Exit;
      end;
    end;
  end;

  with FBillItems[0] do
  begin
    FPModel := FUIData.FPModel;
    FFactory := gSysParam.FFactNum;

    with FPData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FPData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    with FMData do
    begin
      FStation := FPoundTunnel.FID;
      FValue := FUIData.FMData.FValue;
      FOperator := gSysParam.FUserID;
    end;

    FPoundID := sFlag_Yes;
    //��Ǹ����г�������
    FSaveResult := SaveLadingBills(FNextStatus, FBillItems, FPoundTunnel, FLogin);
    Result := FSaveResult;
    //�������
  end;
end;

//------------------------------------------------------------------------------
//Desc: ԭ���ϻ���ʱ
function TfFrameAutoPoundItem.SavePoundData: Boolean;
var
  nStr : string;
  nNextStatus: string;
  nVal: Double;
begin
  Result := False;
  //init

  if (FUIData.FPData.FValue > 0) and (FUIData.FMData.FValue > 0) then
  begin
    if FUIData.FPData.FValue > FUIData.FMData.FValue then
    begin
      WriteLog('Ƥ��ӦС��ë��');
      Exit;
    end;
  end;

  //������գ��ж�Ƥë����̫�಻��������
  if (FCardUsed = sFlag_Provide) and (FUIData.FYSValid = sFlag_No) then
  begin
    nVal := Abs(FUIData.FMData.FValue - FUIData.FPData.FValue);
    if nVal > gSysParam.FJsWc then
    begin
      nStr := '�ɹ����ճ������:'+floattostr(nVal)+',�������:'+floattostr(gSysParam.FJsWc)+
              ',Ƥë��������׼ֵƤ��:['+floattostr(FUIData.FPData.FValue)+
              '],ë��:['+floattostr(FUIData.FMData.FValue)+'],����ϵ����Ա����.';
      WriteSysLog(nStr);
      PlayVoice(nStr);
      Exit;
    end
    else
    begin
      FUIData.FMData.FValue := FUIData.FPData.FValue;
    end;
  end;

  nNextStatus := FBillItems[0].FNextStatus;
  //�ݴ����״̬

  SetLength(FBillItems, 1);
  FBillItems[0] := FUIData;
  //�����û���������

  with FBillItems[0] do
  begin
    FFactory := gSysParam.FFactNum;
    //xxxxx

    if FNextStatus = sFlag_TruckBFP then
         FPData.FStation := FPoundTunnel.FID
    else FMData.FStation := FPoundTunnel.FID;
  end;
  
  if FCardUsed = sFlag_Provide then
       Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel, FLogin)
  else Result := SaveDuanDaoItems(nNextStatus, FBillItems, FPoundTunnel, FLogin);
  //�������
  //Result := SavePurchaseOrders(nNextStatus, FBillItems,FPoundTunnel)
  if gSysParam.FIsKS = 1 then
  begin
    nStr := 'Update %s Set P_IsKS = ''%s'' Where P_Order = ''%s'' ';
    nStr := Format(nStr, [sTable_PoundLog, sFlag_Yes, FBillItems[0].FID]);
    FDM.ExecuteSQL(nStr);
  end
  else
  begin
    nStr := 'Update %s Set P_IsKS = ''%s'' Where P_Order = ''%s'' ';
    nStr := Format(nStr, [sTable_PoundLog, sFlag_No, FBillItems[0].FID]);
    FDM.ExecuteSQL(nStr);
  end;
  //�������
  if FAutoTruckOut then
  begin
    nStr := 'Select D_NextStatus From %s Where D_ID=''%s'' ';
    nStr := Format(nStr, [sTable_OrderDtl,FBillItems[0].FID]);

    with FDM.QueryTemp(nStr) do
    begin
      if (RecordCount > 0) then
      begin
        nStr := Fields[0].AsString;
      end
      else
        Exit;
    end;
    WriteSysLog('������һ״̬Ϊ��'+nStr);

    if (nStr = sFlag_TruckOut) then
    begin
      WriteSysLog('�ƹ�ë��,ֱ�ӳ�����');
      SavePurchaseOrders(sFlag_TruckOut, FBillItems,FPoundTunnel, FLogin);
    end;
  end;
end;

//Desc: ��ȡ��ͷ����
procedure TfFrameAutoPoundItem.OnPoundDataEvent(const nValue: Double);
begin
  try
    if FIsSaving then Exit;
    //���ڱ��档����

    OnPoundData(nValue);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      SetUIData(True);
    end;
  end;
end;

//Desc: ������ͷ����
procedure TfFrameAutoPoundItem.OnPoundData(const nValue: Double);
var nRet: Boolean;
    nInt: Int64;
    nStr: string;
    nIdx : Integer;
begin
  FLastBT := GetTickCount;
  EditValue.Text := Format('%.2f', [nValue]);

  if FIsChkPoundStatus  then Exit;
  //���ذ�״̬
  if not FIsWeighting then Exit;
  //���ڳ�����
  if gSysParam.FIsManual then Exit;
  //�ֶ�ʱ��Ч

  if nValue < FPoundTunnel.FPort.FMinValue then //�հ�
  begin
    if FEmptyPoundInit = 0 then
      FEmptyPoundInit := GetTickCount;
    nInt := GetTickCount - FEmptyPoundInit;

    if (nInt > FEmptyPoundIdleLong * 1000) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('ˢ����˾������Ӧ,�˳�����.');
      Exit;
    end;
    //�ϰ�ʱ��,�ӳ�����

    if (nInt > FEmptyPoundIdleShort * 1000) and   //��֤�հ�
       (FDoneEmptyPoundInit>0) and (GetTickCount-FDoneEmptyPoundInit>nInt) then
    begin
      FIsWeighting :=False;
      Timer_SaveFail.Enabled := True;

      WriteSysLog('˾�����°�,�˳�����.');
      Exit;
    end;
    //�ϴα���ɹ���,�հ���ʱ,��Ϊ�����°�

    Exit;
  end else
  begin
    FEmptyPoundInit := 0;
    if FDoneEmptyPoundInit > 0 then
      FDoneEmptyPoundInit := GetTickCount;
    //����������Ϻ�δ�°�
  end;

  AddSample(nValue);
  if not IsValidSamaple then Exit;
  //������֤��ͨ��

  if Length(FBillItems) < 1 then Exit;
  //�޳�������

  //if FCardUsed = sFlag_Provide then
  //��ʱ����Ҳ�Ե�����
  if FCardUsed <> sFlag_Sale then
  begin
    if FInnerData.FPData.FValue > 0 then
    begin
      if nValue <= FInnerData.FPData.FValue then
      begin
        FUIData.FPData := FInnerData.FMData;
        FUIData.FMData := FInnerData.FPData;

        FUIData.FPData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFP;
        //�л�Ϊ��Ƥ��
      end else
      begin
        FUIData.FPData := FInnerData.FPData;
        FUIData.FMData := FInnerData.FMData;

        FUIData.FMData.FValue := nValue;
        FUIData.FNextStatus := sFlag_TruckBFM;
        //�л�Ϊ��ë��
      end;
    end else FUIData.FPData.FValue := nValue;
  end else
  if FBillItems[0].FNextStatus = sFlag_TruckBFP then
       FUIData.FPData.FValue := nValue
  else FUIData.FMData.FValue := nValue;

  SetUIData(False);
  //���½���

  {$IFDEF MITTruckProber}
    if not IsTunnelOK(FPoundTunnel.FID) then
  {$ELSE}
    {$IFDEF HR1847}
    if not gKRMgrProber.IsTunnelOK(FPoundTunnel.FID) then
    {$ELSE}
      {$IFNDEF TruckProberEx}
      if not gProberManager.IsTunnelOK(FPoundTunnel.FID) then
      {$ELSE}
      if not gProberManager.IsTunnelOKEx(FPoundTunnel.FID) then
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  begin
    nStr := '����δͣ��λ,���ƶ�����.';
    PlayVoice(nStr);
    LEDDisplay(nStr);
    WriteSysLog(nStr);

    InitSamples;
    Exit;
  end;

  FIsSaving := True;
//  if FCardUsed = sFlag_Provide then
//       nRet := SavePoundData
//  else nRet := SavePoundSale;

  if FCardUsed = sFlag_Sale then
       nRet := SavePoundSale
  else nRet := SavePoundData;

  if nRet then
  begin
    {$IFDEF XXMD}
    if (FCardUsed = sFlag_Sale) and (FBillItems[0].FType = sFlag_Dai)
       and (FBillItems[0].FNextStatus = sFlag_TruckBFM) then
      nStr := GetTruckNO(FUIData.FTruck) + 'Ʊ��:' +
              GetValue(StrToFloatDef(EditZValue.Text,0))
    else
      nStr := GetTruckNO(FUIData.FTruck) + '�������';
    LEDDisplay(nStr);
    {$ELSE}
    if (FCardUsed = sFlag_Sale) and (FBillItems[0].FType = sFlag_Dai)
       and (FBillItems[0].FNextStatus = sFlag_TruckBFM) then
      nStr := GetTruckNO(FUIData.FTruck) + 'Ʊ��:' +
              GetValue(StrToFloatDef(EditZValue.Text,0))
    else
      nStr := GetTruckNO(FUIData.FTruck) + '����:' + GetValue(nValue);
    LEDDisplay(nStr);
    {$ENDIF}

    {$IFDEF ProberShow}
      {$IFDEF MITTruckProber}
      if (FCardUsed = sFlag_Sale) and (FBillItems[0].FType = sFlag_San) then
      begin
        nStr := GetTruckNO(FUIData.FTruck) + '����:' + GetValue(nValue);
      end;
      ProberShowTxt(FPoundTunnel.FID, nStr);
      {$ELSE}
      gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
      {$ENDIF}
    {$ENDIF}

    TimerDelay.Enabled := True
  end
  else
  begin
    if not FSaveResult then
    begin
      nStr := GetTruckNO(FUIData.FTruck) + '���ݱ���ʧ��';
      {$IFDEF MITTruckProber}
      ProberShowTxt(FPoundTunnel.FID, nStr);
      {$ELSE}
      gProberManager.ShowTxt(FPoundTunnel.FID, nStr);
      {$ENDIF}
      nStr := '���ݱ���ʧ��,�����¹���.';
      PlayVoice(nStr);
    end;

    Timer_SaveFail.Enabled := True;
  end;

  if FBarrierGate and FSaveResult then
  begin
    for nIdx := 0 to 2 do
    begin
      OpenDoorByReader(FLastReader, sFlag_No);
    end;
    //�򿪸���բ
  end;
end;

procedure TfFrameAutoPoundItem.TimerDelayTimer(Sender: TObject);
begin
  try
    TimerDelay.Enabled := False;
    WriteSysLog(Format('�Գ���[ %s ]�������.', [FUIData.FTruck]));
    PlayVoice(#9 + FUIData.FTruck);
    //��������

    FLastCard     := FCardTmp;
    FLastCardDone := GetTickCount;
    FDoneEmptyPoundInit := GetTickCount;
    //����״̬

    if not FBarrierGate then
      FIsWeighting := False;
    //�����޵�բʱ����ʱ�������

    {$IFDEF MITTruckProber}
        TunnelOC(FPoundTunnel.FID, True);
    {$ELSE}
      {$IFDEF HR1847}
      gKRMgrProber.TunnelOC(FPoundTunnel.FID, True);
      {$ELSE}
      gProberManager.TunnelOC(FPoundTunnel.FID, True);
      {$ENDIF}
    {$ENDIF} //�����̵�

    Timer2.Enabled := True;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ��ʼ������
procedure TfFrameAutoPoundItem.InitSamples;
var nIdx: Integer;
begin
  SetLength(FValueSamples, FPoundTunnel.FSampleNum);
  FSampleIndex := Low(FValueSamples);

  for nIdx:=High(FValueSamples) downto FSampleIndex do
    FValueSamples[nIdx] := 0;
  //xxxxx
end;

//Desc: ���Ӳ���
procedure TfFrameAutoPoundItem.AddSample(const nValue: Double);
begin
  FValueSamples[FSampleIndex] := nValue;
  Inc(FSampleIndex);

  if FSampleIndex >= FPoundTunnel.FSampleNum then
    FSampleIndex := Low(FValueSamples);
  //ѭ������
end;

//Desc: ��֤�����Ƿ��ȶ�
function TfFrameAutoPoundItem.IsValidSamaple: Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;

  for nIdx:=FPoundTunnel.FSampleNum-1 downto 1 do
  begin
    if FValueSamples[nIdx] < 0.02 then Exit;
    //����������

    nVal := Trunc(FValueSamples[nIdx] * 1000 - FValueSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FPoundTunnel.FSampleFloat then Exit;
    //����ֵ����
  end;

  Result := True;
end;

procedure TfFrameAutoPoundItem.PlayVoice(const nStrtext: string);
begin
  {$IFNDEF DEBUG}
  if (Assigned(FPoundTunnel.FOptions)) and
     (CompareText('NET', FPoundTunnel.FOptions.Values['Voice']) = 0) then
       gNetVoiceHelper.PlayVoice(nStrtext, FPoundTunnel.FID, 'pound')
  else gVoiceHelper.PlayVoice(nStrtext);
  {$ENDIF}
end;

procedure TfFrameAutoPoundItem.Timer_SaveFailTimer(Sender: TObject);
begin
  inherited;
  try
    FDoneEmptyPoundInit := GetTickCount;
    Timer_SaveFail.Enabled := False;
    SetUIData(True);
  except
    on E: Exception do
    begin
      WriteSysLog(Format('��վ[ %s.%s ]: %s', [FPoundTunnel.FID,
                                               FPoundTunnel.FName, E.Message]));
      //loged
    end;
  end;
end;

procedure TfFrameAutoPoundItem.EditBillKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
  if Key = #13 then
  try
    Key := #0;
    EditBill.Text := Trim(EditBill.Text);

    if FIsWeighting or EditBill.Properties.ReadOnly or
       (EditBill.Text = '') then
    begin
      SwitchFocusCtrl(ParentForm, True);
      Exit;
    end;

    {$IFDEF DEBUG}
    FCardTmp := EditBill.Text;
    LoadBillItems(EditBill.Text);
    {$ENDIF}
  finally
    EditBill.Enabled := True;
  end;
end;

procedure TfFrameAutoPoundItem.LEDDisplay(const nContent: string);
begin
  {$IFDEF BFLED}
  WriteSysLog(Format('LEDDisplay:%s.%s', [FPoundTunnel.FID, nContent]));
  if Assigned(FPoundTunnel.FOptions) And
     (UpperCase(FPoundTunnel.FOptions.Values['LEDEnable'])='Y') then
  begin
    if FLEDContent = nContent then Exit;
    FLEDContent := nContent;
    gDisplayManager.Display(FPoundTunnel.FID, nContent);
  end;
  {$ENDIF}
end;

function TfFrameAutoPoundItem.ChkPoundStatus:Boolean;
var nIdx:Integer;
    nHint : string;
begin
  Result:= True;
  try
    FIsChkPoundStatus:= True;
    if not FPoundTunnel.FUserInput then
    if not gPoundTunnelManager.ActivePort(FPoundTunnel.FID,
           OnPoundDataEvent, True) then
    begin
      nHint := '���ذ������ӵذ���ͷʧ�ܣ�����ϵ����Ա���Ӳ������';
      WriteSysLog(nHint);
      PlayVoice(nHint);
    end;

    for nIdx:= 0 to 5 do
    begin
      Sleep(500);  Application.ProcessMessages;
      if StrToFloatDef(Trim(EditValue.Text), -1) > FPoundTunnel.FPort.FMinValue then
      begin
        Result:= False;
        nHint := '���ذ����ذ��������� %s ,���ܽ��г�����ҵ';
        nhint := Format(nHint, [EditValue.Text]);
        WriteSysLog(nHint);

        PlayVoice('���ܽ��г�����ҵ,��س�������Ա���°�');
        Break;
      end;
    end;
  finally
    FIsChkPoundStatus:= False;
    SetUIData(True);
  end;
end;

end.