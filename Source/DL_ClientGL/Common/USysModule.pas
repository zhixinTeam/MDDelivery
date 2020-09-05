{*******************************************************************************
  作者: dmzn@163.com 2009-6-25
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  UClientWorker, UMITPacker, UFormBase, UFormMemo,
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFormBaseInfo, UFrameAuthorize, UFormAuthorize, UFormOptions,
  UFrameCustomer, UFormCustomer, UFormGetCustom, UFrameSalesMan, UFormSalesMan,
  UFrameSaleContract, UFormSaleContract, UFrameZhiKa, UFormZhiKa,
  UFormGetContract, UFormZhiKaAdjust, UFormZhiKaFixMoney, UFrameZhiKaVerify,
  UFormZhiKaVerify, UFrameShouJu, UFormShouJu, UFramePayment, UFormPayment,
  UFramePaymentQT, UFormPaymentQT, UFormQTInfo,
  UFrameCustomerCredit, UFormCustomerCredit, UFrameCusAccount,UFramePaymentEx,
  UFrameCusInOutMoney, UFrameInvoiceWeek, UFormInvoiceWeek, UFormInvoiceGetWeek,
  UFrameInvoice, UFormInvoice, UFormInvoiceAdjust,UFrameInvoiceK, UFormInvoiceK,
  UFrameInvoiceDtl, UFrameInvoiceZZ, UFormInvoiceZZAll, UFormInvoiceZZCus,
  UFormGetZhiKa, UFrameBill, UFormReadCard, UFormTruckEmpty,
  UFormBill, UFormGetTruck, UFrameZhiKaDetail, UFormZhiKaFreeze,
  UFormZhiKaPrice, UFrameQueryDiapatch, UFrameTruckQuery, UFrameBillCard,
  UFormCard, UFormTruckIn, UFormTruckOut, UFormLadingDai, UFormLadingSan,
  UFramePoundManual, UFramePoundAuto, UFramePMaterails, UFormPMaterails,
  UFramePProvider, UFormPProvider, UFramePoundQuery, UFramePoundQueryKS,
  UFramePoundQueryKZ, UFormPoundTwoKZ, UFramePoundQueryGY, UFormPoundOldValue,
  UFrameQuerySaleDetail,UFrameQuerySaletunnel,
  UFrameQuerySaleTotal, UFrameZTDispatch, UFrameTrucks, UFormTruck,
  UFormRFIDCard, UFrameBillFactIn, UFormBillFactIn, UFormBillSalePlan,
  UFormTodo, UFormTodoSend, UFrameTodo, UFrameBatcodeJ, UFormBatcodeJ,
  UFrameBillHK, UFormBillHK, UFormCardSearch, UFormKPPayment,
  UFormBillPD,UFormOnLineSet,
  {$IFDEF MicroMsg}
  UFrameWeiXinAccount, UFormWeiXinAccount,
  UFrameWeiXinSendlog, UFormWeiXinSendlog,
  {$ENDIF}
   UMgrSDTReader,UFormSealInfo,//铅封输入
  {.$IFDEF XAZL}
  UFramePurchaseOrder, UFormPurchaseOrder, UFormPurchasing,
  UFrameQueryOrderDetail, UFrameQueryOrderTotal, UFrameOrderCard,  UFrameOrderDetail,
  UFormGetProvider, UFormGetMeterails, UFramePOrderBase, UFormPOrderBase,
  UFormGetPOrderBase, UFormOrderDtl, UFormGetPayingUnit,
  {.$ENDIF}
  UFramePoundMtAuto,UFramePoundMtAutoItem,UFramePoundMtQuery,
  //桐乡码头抓斗秤
  UFramePMaterailControl, UFormPMaterailControl,
  UFormCrossCard, UFrameCrossCard,
  //通行卡业务
  //----------------------------------------------------------------------------
  UFormGetWechartAccount, UFrameAuditTruck, UFormAuditTruck, UFrameBillBuDanAudit,
  UFormHYStock, UFormHYData, UFormHYRecord, UFormGetStockNo, UFrameXHSpot,UFormXHSpot,
  UFrameHYStock, UFrameHYData, UFrameHYRecord, UFormTransfer, UFrameTransfer,
  UFrameDriverWh,UFormDriverWh,UFormKDInfo,UFrameKDInfo,UFrameSCustomerControl,
  UFormSCustomerControl, UFramePayingUnit,UFormPayingUnit,
  UFrameBillRefresh,UFormStockQueue,UFormGetStockQueue,
  
  //东义财务报表
  UFrameNotice, UFrameDaySals, UFrameMonthSales, UFrameDayPrice,
  UFrameMonthPrice, UCollectMoney, UAccReport, UFrameSaleAndMoney,UFormKSKD,
  UFrameDaySalesHj, UFrameDayReport,UFrameDayReport_HY, UFrameQuerySaleTotal2HY,
  UFrameCusTotalMoney, UFrameCusReceivable, UFrameQrySaleByMonth,
  UFramePurchByMonth;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  UMgrChannel, UChannelChooser, UDataModule, USysDB, USysMAC, SysUtils,
  USysLoger, USysConst, UMemDataPool, UMgrLEDDisp;

//Desc: 初始化系统对象
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //mem pool

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
  {$IFDEF IdentCard}
  gSDTReaderManager.LoadConfig(gPath + 'SDTReader.XML');
  gSDTReaderManager.TempDir := gPath + 'Temp\';
  {$ENDIF}
end;

//Desc: 运行系统对象
procedure RunSystemObject;
var nStr: string;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
  end;

  nStr := 'Select W_Factory,W_Serial,W_Departmen,W_HardUrl,W_MITUrl From %s ' +
          'Where W_MAC=''%s'' And W_Valid=''%s''';
  nStr := Format(nStr, [sTable_WorkePC, gSysParam.FLocalMAC, sFlag_Yes]);

  with FDM.QueryTemp(nStr),gSysParam do
  if RecordCount > 0 then
  begin
    FFactNum := Fields[0].AsString;
    FSerialID := Fields[1].AsString;

    FDepartment := Fields[2].AsString;
    FHardMonURL := Trim(Fields[3].AsString);
    FMITServURL := Trim(Fields[4].AsString);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam]);

  with FDM.QueryTemp(nStr),gSysParam do
  if RecordCount > 0 then
  begin
    First;
    while not Eof do
    begin
      nStr := Fields[1].AsString;

      if nStr = sFlag_WXServiceMIT then
        FWechatURL := Fields[0].AsString;
      //xxxxx

      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  with gSysParam do
  begin
    FPoundDaiZ := 0;
    FPoundDaiF := 0;
    FPoundSanF := 0;
    FDaiWCStop := False;
    FDaiPercent := False;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PDaiWuChaZ then
        gSysParam.FPoundDaiZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiWuChaF then
        gSysParam.FPoundDaiF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiPercent then
        gSysParam.FDaiPercent := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PDaiWuChaStop then
        gSysParam.FDaiWCStop := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PSanWuChaF then
        gSysParam.FPoundSanF := Fields[0].AsFloat;

      if nStr = sFlag_PEmpTWuCha then
        gSysParam.FEmpTruckWc := Fields[0].AsFloat;

      if nStr = sFlag_JsWc then
        gSysParam.FJsWc := Fields[0].AsFloat;

      Next;
    end;

    with gSysParam do
    begin
      FPoundDaiZ_1 := FPoundDaiZ;
      FPoundDaiF_1 := FPoundDaiF;
      //backup wucha value
    end;
  end;

  //----------------------------------------------------------------------------
  if gSysParam.FMITServURL = '' then  //使用默认URL
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        gChannelChoolser.AddChannelURL(Fields[0].AsString);
        Next;
      end;

      {$IFNDEF DEBUG}
      //gChannelChoolser.StartRefresh;
      {$ENDIF}//update channel
    end;
  end else
  begin
    gChannelChoolser.AddChannelURL(gSysParam.FMITServURL);
    //电脑专用URL
  end;

  if gSysParam.FHardMonURL = '' then //采用系统默认硬件守护
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

    with FDM.QueryTemp(nStr) do
     if RecordCount > 0 then
      gSysParam.FHardMonURL := Fields[0].AsString;
    //xxxxx
  end;

  CreateBaseFormItem(cFI_FormTodo);
  //待处理事项

  {$IFDEF BFLED}
  if FileExists(gPath + cDisp_Config) then
  begin
    gDisplayManager.LoadConfig(gPath + cDisp_Config);
    gDisplayManager.StartDisplay;
  end;
  {$ENDIF}

  {$IFDEF IdentCard}
  gSDTReaderManager.StartReader;
  //启动身份证读卡器
  {$ENDIF}
end;

//Desc: 释放系统对象
procedure FreeSystemObject;
begin
  {$IFDEF IdentCard}
  gSDTReaderManager.StopReader;
  //关闭身份证读卡器
  {$ENDIF}
  
  FreeAndNil(gSysLoger);
end;

end.
