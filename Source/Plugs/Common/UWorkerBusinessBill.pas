{*******************************************************************************
  作者: dmzn@163.com 2016-12-30
  描述: 模块业务对象
*******************************************************************************}
unit UWorkerBusinessBill;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF}
  UWorkerBusiness, UBusinessConst, UMgrDBConn, ULibFun, UFormCtrl, UBase64,
  USysLoger, USysDB, UMITConst,UMgrQueue;

type
  TStockMatchItem = record
    FStock: string;         //品种
    FGroup: string;         //分组
    FRecord: string;        //记录
  end;

  TBillLadingLine = record
    FBill: string;          //交货单
    FLine: string;          //装车线
    FName: string;          //线名称
    FPerW: Integer;         //袋重
    FTotal: Integer;        //总袋数
    FNormal: Integer;       //正常
    FBuCha: Integer;        //补差
    FHKBills: string;       //合卡单
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSanMultiBill: Boolean;
    //散装多单
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //分组匹配
    FBillLines: array of TBillLadingLine;
    //装车线 
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //物料分组
    function AllowedSanMultiBill: Boolean;
    function GetStockKuWei(const nStockNo: string): string;
    //读取物料库位
    function GetCusType(const nCusID: string): string;
    //读取客户分类
    function VerifyBeforSave(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //保存交货单
    function DeleteBill(var nData: string): Boolean;
    //删除交货单
    function ChangeBillTruck(var nData: string): Boolean;
    //修改车牌号
    function BillSaleAdjust(var nData: string): Boolean;
    //销售调拨
    function SaveBillCard(var nData: string): Boolean;
    function SaveBillLSCard(var nData: string): Boolean;
    //绑定磁卡
    function LogoffCard(var nData: string): Boolean;
    //注销磁卡
    function MakeSanPreHK(var nData: string): Boolean;
    //执行散装预合卡
    function GetPostBillItems(var nData: string): Boolean;
    //获取岗位交货单
    function SavePostBillItems(var nData: string): Boolean;
    //保存岗位交货单
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //验证车牌是否有效
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
class function TWorkerBusinessBills.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-15
//Parm: 输入数据
//Desc: 执行nData业务指令
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := '业务执行成功.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaleAdjust          : Result := BillSaleAdjust(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_SaveBillLSCard      : Result := SaveBillLSCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   cBC_MakeSanPreHK        : Result := MakeSanPreHK(nData);
   else
    begin
      Result := False;
      nData := '无效的业务代码(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索nStock对应的物料分组
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: 品种编号
//Desc: 检索车辆队列中与nStock同品种,或同组的记录
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: 车牌号;
//Desc: 验证nTruck是否有效
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '有效的车牌号长度为3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('车牌号[ %s ]无效.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: 允许散装多单
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2014-09-15
//Desc: 验证能否开单
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
    nOut: TWorkerBusinessCommand;
    nTime: Integer;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  nStr := 'Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid From %s ' +
          'Where T_Truck=''%s''';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nData := '车辆[ %s ]被管理员禁止开单.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;
  end;

  {$IFDEF BusinessOnly}
  nStr := 'Select top 10 * From %s Where O_Truck=''%s'' order by O_Date desc';
  nStr := Format(nStr, [sTable_Order, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        if Trim(FieldByName('O_Card').AsString) <> '' then
        begin
          nStr := '车辆[ %s ]在未完成[ %s ]采购单之前禁止开单.';
          nData := Format(nStr, [nTruck, FieldByName('O_ID').AsString]);
          Exit;
        end;
        Next;
      end;
    end;
  end;
  {$ENDIF}
  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  {$IFDEF SanPreHK}
  FSanMultiBill := True;
  {$ELSE}
  FSanMultiBill := AllowedSanMultiBill;
  {$ENDIF}//散装允许开多单

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //品种分组匹配

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select R_ID,T_Bill,T_StockNo,T_Type,T_InFact,T_Valid From %s ' +
          'Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //还在队列中车辆

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if (FieldByName('T_Type').AsString = sFlag_Dai) and
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '车辆[ %s ]在未完成[ %s ]交货单之前禁止开单.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '车辆[ %s ]有已出队的交货单[ %s ],需先处理.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end;

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //出厂一定时间内禁止开单
  {$IFDEF Between2BillTime}
  nTime := 30;
  nStr  := ' select D_Value from %s where D_Name = ''%s'' and D_Memo  = ''%s'' ';
  nStr  := Format(nStr,[sTable_SysDict,sFlag_SysParam,'Between2BillTime']);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if recordcount > 0 then
    begin
      nTime :=  FieldByName('D_Value').AsInteger;
    end;
  end;

  nStr := 'select top 1 L_OutFact from %s where '+
          'l_truck=''%s'' order by L_OutFact desc';
  nStr := Format(nStr,[sTable_Bill,nTruck]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if recordcount > 0 then
    begin
      if (Now - FieldByName('L_OutFact').AsDateTime)*24*60 < nTime then
      begin
        nStr := '车辆[ %s ]出厂未到'+inttostr(nTime)+'分钟,禁止开单.';
        nData := Format(nStr, [nTruck]);
        Exit;
      end;
    end;
  end;
  {$ENDIF}

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //保存车牌号

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FListA.Values['ZhiKa'])]);
  //纸卡信息

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FListA do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [Values['ZhiKa']]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [Values['ZhiKa']]);
      Exit;
    end;

    nStr := FieldByName('Z_TJStatus').AsString;

    {$IFNDEF NoShowPriceChange}
    if nStr  <> '' then
    begin
      if nStr = sFlag_TJOver then
           nData := '纸卡[ %s ]已调价,请重新开单.'
      else nData := '纸卡[ %s ]正在调价,请稍后.';

      nData := Format(nData, [Values['ZhiKa']]);
      Exit;
    end;
    {$ELSE}
    if nStr  = sFlag_TJing then
    begin
      nData := '纸卡[ %s ]正在调价,请稍后.';
      nData := Format(nData, [Values['ZhiKa']]);
      Exit;
    end;
    {$ENDIF}

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [Values['ZhiKa'],
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    {$IFDEF UseFreight}
    Values['XHSpot'] := FieldByName('Z_XHSpot').AsString;
    if FieldByName('Z_Lading').AsString = sflag_songh then
      Values['Freight'] := FieldByName('Z_Freight').AsString;
    {$ENDIF}  //运费

    Values['Lading'] := FieldByName('Z_Lading').AsString;
    Values['Project'] := FieldByName('Z_Project').AsString;
    Values['Area'] := FieldByName('Z_Area').AsString;
    Values['CusID'] := FieldByName('Z_Customer').AsString;
    Values['CusName'] := FieldByName('C_Name').AsString;
    Values['CusPY'] := FieldByName('C_PY').AsString;
    Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
    Values['SaleMan'] := FieldByName('S_Name').AsString;
    Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
  end;

  Result := True;
  //verify done
end;

//Date: 2014-09-15
//Desc: 保存交货单
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nIdx: Integer;
    nVal,nMoney, nPeerWeight: Double;
    nStr,nSQL,nFixMoney: string;
    {$IFDEF TruckInNow}
    nStatus, nNextStatus: string;
    {$ENDIF}
    nOut, nTmp: TWorkerBusinessCommand;
    nLine:string;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FListA.Values['ZhiKa'], '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end;

  nMoney := StrToFloat(nOut.FData);
  nFixMoney := nOut.FExtParam;
  //zhika money

  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);
  //unpack bill list
  nVal := 0;

  for nIdx:=0 to FListB.Count - 1 do
  begin
    FListC.Text := PackerDecodeStr(FListB[nIdx]);
    //get bill info

    with FListC do
      nVal := nVal + Float2Float(StrToFloat(Values['Price']) *
                     StrToFloat(Values['Value']), cPrecision, True);
    //xxxx
  end;

  if FloatRelation(nVal, nMoney, rtGreater) then
  begin
    nData := '纸卡[ %s ]上没有足够的金额,详情如下:' + #13#10#13#10 +
             '可用金额: %.2f' + #13#10 +
             '开单金额: %.2f' + #13#10#13#10 +
             '请减小提货量后再开单.';
    nData := Format(nData, [FListA.Values['ZhiKa'], nMoney, nVal]);
    Exit;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    for nIdx:=0 to FListB.Count - 1 do
    begin
      if Length(FListA.Values['Card']) > 0 then
      begin      //厂内销售业务，自带交货单号
        nSQL := 'Select L_ID From %s Where L_Card = ''%s'' And L_OutFact Is NULL';
        nSQL := Format(nSQL, [sTable_Bill, FListA.Values['Card']]);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if RecordCount < 1 then
          begin
            nData := '无法找到磁卡[ %s ]对应厂内业务单号.';
            nData := Format(nData, [FListA.Values['Card']]);
            Exit;
          end;

          if RecordCount > 1 then
          begin
            nData := '厂内销售业务禁止拼单.';
            Exit;
          end;

          nOut.FData := Fields[0].AsString;
        end;

      end else   //其他业务，获取交货单号

      begin
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_BillNo;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx
      end;

      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill

      FListC.Text := PackerDecodeStr(FListB[nIdx]);
      //get bill info

      {$IFDEF CustomerType}
        {$IFDEF HYJC}    //恒宇区分AB客户，但是不区分批次号
         if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
           FListC.Values['StockNO'], FListC.Values['Value'], @nTmp) then
           raise Exception.Create(nTmp.FData);
        {$ELSE}
        FListC.Values['CustomerType'] := GetCusType(FListA.Values['CusID']);
        if FListC.Values['CustomerType'] = '' then
          raise Exception.Create('客户' + FListA.Values['CusID'] + '分类为空');

        if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcodeByCusType,
           FListC.Values['StockNO'], FListC.Text, @nTmp) then
           raise Exception.Create(nTmp.FData);
        {$ENDIF}
      {$ELSE}
      if not TWorkerBusinessCommander.CallMe(cBC_GetStockBatcode,
         FListC.Values['StockNO'], FListC.Values['Value'], @nTmp) then
         raise Exception.Create(nTmp.FData);
      {$ENDIF}

      {$IFDEF BatchInHYOfBill}
      if nTmp.FData = '' then
           FListC.Values['HYDan'] := FListC.Values['Seal']
      else FListC.Values['HYDan'] := nTmp.FData;
      {$ELSE}
      if nTmp.FData <> '' then
        FListC.Values['Seal'] := nTmp.FData;
      //auto batcode
      {$ENDIF}

      if PBWDataBase(@nTmp).FErrCode = sFlag_ForceHint then
      begin
        FOut.FBase.FErrCode := sFlag_ForceHint;
        FOut.FBase.FErrDesc := PBWDataBase(@nTmp).FErrDesc;
      end;
      //获取批次号信息

      FListC.Values['StockKuWei'] := GetStockKuWei(FListC.Values['StockNO']);

      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FListA.Values['ZhiKa']),
              SF('L_Order', FListC.Values['OrderNo']),
              SF('L_Project', FListA.Values['Project']),
              SF('L_Area', FListA.Values['Area']),
              SF('L_CusID', FListA.Values['CusID']),
              SF('L_CusName', FListA.Values['CusName']),
              SF('L_CusPY', FListA.Values['CusPY']),
              SF('L_SaleID', FListA.Values['SaleID']),
              SF('L_SaleMan', FListA.Values['SaleMan']),

              SF('L_Type', FListC.Values['Type']),
              SF('L_StockNo', FListC.Values['StockNO']),
              SF('L_StockName', FListC.Values['StockName']),
              SF('L_Value', FListC.Values['Value'], sfVal),
              SF('L_Price', FListC.Values['Price'], sfVal),

              {$IFDEF PrintGLF}
              SF('L_PrintGLF', FListC.Values['PrintGLF']),
              {$ENDIF} //自动打印过路费

              {$IFDEF PrintHYEach}
              SF('L_PrintHY', FListC.Values['PrintHY']),
              {$ENDIF} //随车打印化验单

              {$IFDEF StockKuWei}
              SF('L_KuWei', FListC.Values['StockKuWei']),
              {$ENDIF} //随车打印化验单

              {$IFDEF CustomerType}
              SF('L_CusType', FListC.Values['CustomerType']),
              {$ENDIF} //随车打印化验单

              {$IFDEF UseFreight}
              SF('L_Freight', FListA.Values['Freight'],sfVal),
                {$IFDEF UseXHSpot}
                SF('L_XHSpot', FListA.Values['L_XHSpot']),
                {$ELSE}
                SF('L_XHSpot', FListA.Values['XHSpot']),
                {$ENDIF}
              {$ENDIF} //启用运费

              {$IFDEF UseWebYYOrder}
              SF('L_WebOrderID', FListA.Values['WebOrderID']),
              {$ENDIF}
              SF('L_SJName', FListA.Values['SJName']),
              SF('L_ZKMoney', nFixMoney),
              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListC.Values['Seal']),
              SF('L_HYDan', FListC.Values['HYDan']),
              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Bill,SF('L_ID', nOut.FData),FListA.Values['Card']='');
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //根据卡号新增或者更新信息

      nStr := MakeSQLByStr([
                SF('P_Truck', FListA.Values['Truck']),
                SF('P_CusID', FListA.Values['CusID']),
                SF('P_CusName', FListA.Values['CusName']),
                SF('P_MID', FListC.Values['StockNO']),
                SF('P_MName', FListC.Values['StockName']),
                SF('P_MType', FListC.Values['Type']),
                SF('P_LimValue', FListC.Values['Value'], sfVal)
                ], sTable_PoundLog, SF('P_Bill', nOut.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新磅单基本信息

      nStr := 'Update %s Set B_HasUse=B_HasUse+%s Where B_Batcode=''%s''';
      nStr := Format(nStr, [sTable_StockBatcode, FListC.Values['Value'],
              FListC.Values['HYDan']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新批次号使用量

      if FListA.Values['Card'] = '' then
      begin
        nStr := MakeSQLByStr([
                SF('L_Status', sFlag_TruckNone)
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //新生成交货单状态为未知

        if FListC.Values['IsPlan'] = sFlag_Yes then
        begin
          nStr := MakeSQLByStr([
                  SF('S_InterID', FListC.Values['InterID']),
                  SF('S_EntryID', FListC.Values['EntryID']),
                  SF('S_Truck', FListA.Values['Truck']),
                  SF('S_Date', sField_SQLServer_Now, sfVal)
                  ], sTable_K3_SalePlan, '', True);
          gDBConnManager.WorkerExec(FDBConn, nStr);
        end;
        //保存已使用的销售计划
      end;

      if FListA.Values['BuDan'] = sFlag_Yes then //补单
      begin
        {$IFDEF BuDanChangeDate}
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', FListA.Values['BuDanDate']),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', FListA.Values['BuDanDate']),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', FListA.Values['BuDanDate']),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', FListA.Values['BuDanDate']),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                {$IFDEF BDAUDIT}
                SF('L_Audit', sFlag_Yes),
                {$ENDIF}
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        {$ELSE}
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                {$IFDEF BDAUDIT}
                SF('L_Audit', sFlag_Yes),
                {$ENDIF}
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        {$ENDIF}
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        if FListC.Values['Type'] = sFlag_San then
        begin
          nStr := '';
          //散装不予合单
        end else
        begin
          nStr := FListC.Values['StockNO'];
          nStr := GetMatchRecord(nStr);
          //该品种在装车队列中的记录号
        end;

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr), MI('$Val', FListC.Values['Value']),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          {$IFDEF ChkPeerWeight}
          nStr := 'select * from %s where D_Name=''%s'' and D_Value=''%s''';
          nStr := Format(nStr,[sTable_SysDict,sFlag_PeerWeight,FListC.Values['StockNO']]);
          with gDBConnManager.WorkerQuery(FDBConn,nStr) do
          begin
            nPeerWeight := 0;
            if recordCount > 0 then
              nPeerWeight := FieldByName('D_ParamA').AsFloat;
          end;
          {$ENDIF}
          nLine := '';
          {$IFDEF MoreNumZDLine}
          nStr := 'Select D_Name From $Sys where D_Memo=''$ST'' and D_ParamB = ''$SA'' and D_Value <= $SV ';
          nStr := MacroValue(nStr, [MI('$Sys', sTable_SysDict),
                  MI('$ST', FListC.Values['StockName']),
                  MI('$SA', sFlag_ZDLineItem),
                  MI('$SV', FListC.Values['Value'])]);
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if RecordCount > 0 then
            begin
              nLine := FieldByName('D_Name').AsString;
            end;
          end;
          {$ENDIF}
          nSQL := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListC.Values['StockNO']),
            SF('T_Stock'   , FListC.Values['StockName']),
            SF('T_Type'    , FListC.Values['Type']),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            {$IFDEF MoreNumZDLine}
            SF('T_Line',     nLine),
            {$ENDIF}
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListC.Values['Value'], sfVal),
            SF('T_VIP'     , FListA.Values['IsVIP']),
            {$IFDEF ChkPeerWeight}
            SF('T_PeerWeight',floattostr(nPeerWeight)),
            {$ENDIF}
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;

        if Length(FListA.Values['Card']) > 0 then
        begin
          if FListC.Values['Type'] = sFlag_Dai then
          begin
            nSQL := 'Update $Bill Set L_NextStatus=''$NT'' '+
                    'Where L_ID=''$ID''';
            nSQL := MacroValue(nSQL, [MI('$Bill', sTable_Bill),
                    MI('$NT', sFlag_TruckZT),
                    MI('$ID', nOut.FData)]);
            gDBConnManager.WorkerExec(FDBConn, nSQL);
          end;
          //包装下一状态栈台

          nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
          nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                  nOut.FData]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //厂内零售业务，已进厂

        {$IFDEF TruckInNow}
        nStatus := sFlag_TruckIn;
        nNextStatus := sFlag_TruckBFP;
        if FListC.Values['Type'] = sFlag_Dai then
        begin
          nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
          nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
           if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
            nNextStatus := sFlag_TruckZT;
          //袋装不过磅
        end;

        nSQL := MakeSQLByStr([
                SF('L_Status', nStatus),
                SF('L_NextStatus', nNextStatus),
                SF('L_InTime', sField_SQLServer_Now, sfVal)
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                nOut.FData]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
        {$ENDIF}
      end;
    end;

    if FListA.Values['BuDan'] = sFlag_Yes then //补单
    begin
      {$IFDEF BDAUDIT}
      WriteLog('补单审核功能启用,出金未增加,等待二次审核...');
      {$ELSE}
      nStr := 'Update %s Set A_OutMoney=A_OutMoney+%s Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
              FListA.Values['CusID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from account
      {$ENDIF}
    end else
    begin
      nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney+%s Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nVal),
              FListA.Values['CusID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from account
    end;

    if nFixMoney = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney-%s Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, FloatToStr(nVal),
              FListA.Values['ZhiKa']]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //freeze money from zhika
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  //使用业务员授信
  {$IFDEF UseSalesCredit}
  TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FListA.Values['ZhiKa'], '', @nOut);
  {$ENDIF}

  {$IFDEF MicroMsg}
  with FListC do
  begin
    Clear;
    Values['bill'] := FOut.FData;
    Values['company'] := gSysParam.FHintText;
  end;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nStr := cWXBus_OutFact
  else nStr := cWXBus_MakeCard;

  gWXPlatFormHelper.WXSendMsg(nStr, FListC.Text);
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: 交货单[FIn.FData];车牌号[FIn.FExtParam]
//Desc: 修改指定交货单的车牌号
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

//    {$IFNDEF TruckInNow}
//    if Fields[1].AsString <> '' then
//    begin
//      nData := '交货单[ %s ]已提货,无法修改车牌号.';
//      nData := Format(nData, [FIn.FData]);
//      Exit;
//    end;
//    {$ENDIF}

    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //更新修改信息

    nStr := 'Update %s Set P_Truck=''%s'' Where P_Bill=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //同步磅单记录车牌号

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号

        nStr := 'Update %s Set P_Truck=''%s'' Where P_Bill=''%s''';
        nStr := Format(nStr, [sTable_PoundLog, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单磅单记录车牌号
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //同步合单车牌号
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-30
//Parm: 交货单号[FIn.FData];新纸卡[FIn.FExtParam]
//Desc: 将交货单调拨给新纸卡的客户
function TWorkerBusinessBills.BillSaleAdjust(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal,nMon: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  //----------------------------------------------------------------------------
  nStr := 'Select L_CusID,L_StockNo,L_StockName,L_Value,L_Price,L_ZhiKa,' +
          'L_ZKMoney,L_OutFact From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    if FieldByName('L_OutFact').AsString = '' then
    begin
      nData := '车辆出厂后(提货完毕)才能调拨.';
      Exit;
    end;

    FListB.Clear;
    with FListB do
    begin
      Values['CusID'] := FieldByName('L_CusID').AsString;
      Values['StockNo'] := FieldByName('L_StockNo').AsString;
      Values['StockName'] := FieldByName('L_StockName').AsString;
      Values['ZhiKa'] := FieldByName('L_ZhiKa').AsString;
      Values['ZKMoney'] := FieldByName('L_ZKMoney').AsString;
    end;
    
    nVal := FieldByName('L_Value').AsFloat;
    nMon := nVal * FieldByName('L_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FIn.FExtParam)]);
  //纸卡信息

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('纸卡[ %s ]已丢失.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员冻结.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('纸卡[ %s ]已被管理员作废.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('纸卡[ %s ]已在[ %s ]过期.', [FIn.FExtParam,
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    FListA.Clear;
    with FListA do
    begin
      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
      Values['ZArea']   := FieldByName('Z_Area').AsString;
      Values['XHSpot']  := FieldByName('Z_XHSpot').AsString;
      Values['Lading']  := FieldByName('Z_Lading').AsString;
      Values['Freight']  := FieldByName('Z_Freight').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Price,b.Z_Freight From %s,%s b Where D_Zid=Z_ID And '+
          ' D_ZID=''%s'' And D_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl,sTable_ZhiKa, FIn.FExtParam, FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '纸卡[ %s ]上没有名称为[ %s ]的品种.';
      nData := Format(nData, [FIn.FExtParam, FListB.Values['StockName']]);
      Exit;
    end;

    FListC.Clear;
    nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListB.Values['CusID']]);
    FListC.Add(nStr); //还原提货方出金

    if FListB.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) ' +
              'Where Z_ID=''%s'' And Z_OnlyMoney=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon,
              FListB.Values['ZhiKa'], sFlag_Yes]);
      FListC.Add(nStr); //还原提货方限提金额
    end;

    nMon := nVal * FieldByName('D_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);

    if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FIn.FExtParam, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    if FloatRelation(nMon, StrToFloat(nOut.FData), rtGreater, cPrecision) then
    begin
      nData := '客户[ %s.%s ]余额不足,详情如下:' + #13#10#13#10 +
               '※.可用余额: %.2f元' + #13#10 +
               '※.调拨所需: %.2f元' + #13#10 +
               '※.需 补 交: %.2f元' + #13#10#13#10 +
               '请到财务室办理"补交货款"手续,然后再次调拨.';
      nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
               StrToFloat(nOut.FData), nMon,
               Float2Float(nMon - StrToFloat(nOut.FData), cPrecision, True)]);
      Exit;
    end;

    nStr := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListA.Values['CusID']]);
    FListC.Add(nStr); //增加调拨方出金

    if FListA.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon, FIn.FExtParam]);
      FListC.Add(nStr); //扣减调拨方限提金额
    end;

    nStr := MakeSQLByStr([SF('L_ZhiKa', FIn.FExtParam),
            SF('L_Project', FListA.Values['Project']),
            SF('L_Area', FListA.Values['ZArea']),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', FListA.Values['CusPY']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),
            SF('L_Price', FieldByName('D_Price').AsFloat, sfVal),
            SF('L_ZKMoney', FListA.Values['ZKMoney']),
            SF('L_Lading', FListA.Values['Lading']),
            SF('L_Freight', FieldByName('Z_Freight').AsFloat, sfVal),
            SF('L_XHSpot', FListA.Values['XHSpot'])
            ], sTable_Bill, SF('L_ID', FIn.FData), False);
    FListC.Add(nStr); //增加调拨方出金
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-16
//Parm: 交货单号[FIn.FData]
//Desc: 删除指定交货单
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nHasOut: Boolean;
    nVal,nMoney: Double;
    nStr,nP,nFix,nRID,nCus,nBill,nZK,nHY: string;
begin
  Result := False;
  //init

  nStr := 'Select L_ZhiKa,L_Value,L_Price,L_CusID,L_OutFact,L_ZKMoney,L_HYDan ' +
          'From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '交货单[ %s ]已无效.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    //已出厂
    {$IFDEF HYJC}
    if nHasOut and (FIn.FBase.FFrom.FUser<>'admin') then
    begin
      nData := '交货单[ %s ]已出厂,不允许删除.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
    {$ENDIF}
    nCus := FieldByName('L_CusID').AsString;
    nHY  := FieldByName('L_HYDan').AsString;
    nZK  := FieldByName('L_ZhiKa').AsString;
    nFix := FieldByName('L_ZKMoney').AsString;

    nVal := FieldByName('L_Value').AsFloat;
    nMoney := Float2Float(nVal*FieldByName('L_Price').AsFloat, cPrecision, True);
  end;

  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '交货单[ %s ]出现在多条记录上,异常终止!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //移出合单列表

      if nBill = FIn.FData then
        nBill := FListA[0];
      //更换交货单

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //更新合单信息
    end;

    //--------------------------------------------------------------------------
    if nHasOut then
    begin
      nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //释放出金
    end else
    begin
      nStr := 'Update %s Set A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nMoney, nCus]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //释放冻结金
    end;

    if nFix = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMoney, nZK]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
      //释放限提金额
    end;

    nStr := 'Update %s Set B_HasUse=B_HasUse-%.2f Where B_Batcode=''%s''';
    nStr := Format(nStr, [sTable_StockBatcode, nVal, nHY]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //释放使用的批次号

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //所有字段,不包括删除

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 交货单[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 为交货单绑定磁卡
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin  
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //磁卡列表
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //交货单列表

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('交货单[ %s ]已丢失.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '交货单[ %s ]已出厂,禁止办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '交货单[ %s ]的车牌号不一致,不能并单.' + #13#10#13#10 +
                 '*.本单车牌: %s' + #13#10 +
                 '*.其它车牌: %s' + #13#10#13#10 +
                 '相同牌号才能并单,请修改车牌号,或者单独办卡.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '交货单[ %s ]同为散装,不能并单.'
        else nData := '交货单[ %s ]的水泥类型不一致,不能并单.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //正在使用的磁卡
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //交货单列表
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //磁卡列表

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '车辆[ %s ]正在使用该卡,无法并单.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '车辆[ %s ]正在使用该卡,相同牌号才能并单.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  if not AllowedSanMultiBill then
  begin
    nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

    //还在队列中车辆
    nStr := '';
    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := nStr + Fields[0].AsString;
      finally
        Next;
      end;

      nStr := Copy(nStr, 1, Length(nStr)-1);
      nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
    end;

    nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
    //队列中交货单列表

    nSQL := 'Select L_Card From %s Where L_ID In (%s)';
    nSQL := Format(nSQL, [sTable_Bill, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        if (Fields[0].AsString <> '') and
           (Fields[0].AsString <> FIn.FExtParam) then
        begin
          nData := '车辆[ %s ]的磁卡号不一致,不能并单.' + #13#10#13#10 +
                   '*.本单磁卡: [%s]' + #13#10 +
                   '*.其它磁卡: [%s]' + #13#10#13#10 +
                   '相同磁卡号才能并单,请修改车牌号,或者单独办卡.';
          nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
          Exit;
        end;

        Next;
      end;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //重新计算列表

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016-12-30
//Parm: 车牌号[FIn.FData];磁卡号[FIn.FExtParam]
//Desc: 生成车辆的厂内零售提货记录
function TWorkerBusinessBills.SaveBillLSCard(var nData: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nStr := 'Select T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := '车辆[ %s ]还有单据[ %s ]未完成,不能办理磁卡.';
    nData := Format(nStr, [FIn.FData, Fields[0].AsString]);
    Exit;
  end;

  FListC.Values['Group'] :=sFlag_BusGroup;
  FListC.Values['Object'] := sFlag_BillNo;
  //to get serial no

  if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
    raise Exception.Create(nOut.FData);
  //xxxxx

  FOut.FData := nOut.FData;
  //bill no

  FDBConn.FConn.BeginTrans;
  try
    nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
            SF('L_Card', FIn.FExtParam),
            SF('L_CusID', sFlag_LSCustomer),
            SF('L_CusName', '零售客户_待定'),

            SF('L_Type', sFlag_San),
            SF('L_StockNo', sFlag_LSStock),
            SF('L_StockName', '零售物料_待定'),
            SF('L_Value', 0, sfVal),
            SF('L_Price', 0, sfVal),

            SF('L_Truck', FIn.FData),
            SF('L_Status', sFlag_BillNew),
            SF('L_Man', FIn.FBase.FFrom.FUser),
            SF('L_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Bill, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
    nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
            SF('C_Used', sFlag_Sale),
            SF('C_Freeze', sFlag_No),
            SF('C_Man', FIn.FBase.FFrom.FUser),
            SF('C_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Card, nStr, False);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData]
//Desc: 注销磁卡
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2017-07-04
//Parm: 提货单号[FIn.FData];合卡量[FIn.FExtParam]
//Desc: 从预先关联的纸卡中扣除超发量
function TWorkerBusinessBills.MakeSanPreHK(var nData: string): Boolean;
var nStr: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;

  Result := False;
  try
    nStr := 'Select * From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '提货单[ %s ]丢失,合卡失败';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      with nListA do
      begin
        Clear;
        Values['BillID']   := FIn.FData;
        Values['BillCard'] := FieldByName('L_Card').AsString;
        //原单据

        Values['Truck']    := FieldByName('L_Truck').AsString;
        Values['Lading']   := FieldByName('L_Lading').AsString;
        Values['IsVIP']    := FieldByName('L_IsVIP').AsString;
        Values['BuDan']    := sFlag_No;
      end;

      with nListB do
      begin
        Clear;
        Values['Type']      := FieldByName('L_Type').AsString;
        Values['StockNO']   := FieldByName('L_StockNo').AsString;
        Values['StockName'] := FieldByName('L_StockName').AsString;

        Values['Seal']      := FieldByName('L_Seal').AsString;
        Values['PrintGLF']  := FieldByName('L_PrintGLF').AsString;
        Values['PrintHY']   := FieldByName('L_PrintHY').AsString;
      end;
    end;

    nStr := 'Select H_ZhiKa,D_StockNo,D_Price From %s hk ' +
            ' Left Join %s zd on zd.D_ZID=hk.H_ZhiKa ' +
            'Where H_Bill=''%s''';
    nStr := Format(nStr, [sTable_BillHK, sTable_ZhiKaDtl, FIn.FData]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := '车辆[ %s ]超发[ %s ]吨,请关联纸卡';
        nData := Format(nData, [nListA.Values['Truck'], FIn.FExtParam]);
        Exit;
      end;

      First;
      nListA.Values['ZhiKa'] := FieldByName('H_ZhiKa').AsString;
    
      while not Eof do
      begin
        if FieldByName('D_StockNo').AsString = nListB.Values['StockNO'] then
        begin
          nListB.Values['Price'] := FieldByName('D_Price').AsString;
          nListB.Values['Value'] := FIn.FExtParam;

          nListA.Values['Bills'] := PackerEncodeStr(PackerEncodeStr(nListB.Text));
          Break;
        end;

        Next;
      end;

      if nListB.Values['Price'] = '' then
      begin
        nData := '车辆[ %s ]超发[ %s ]吨,待合单纸卡中没有[ %s ]品种.';
        nData := Format(nData, [nListA.Values['Truck'], FIn.FExtParam,
                 nListB.Values['StockName']]);
        Exit;
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := PackerEncodeStr(nListA.Text);
    if not TWorkerBusinessBills.CallMe(cBC_SaveBills, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    FDBConn.FConn.BeginTrans;
    try
      nListA.Values['HKBill'] := nOut.FData;
      //合卡生成的单据

      nStr := MakeSQLByStr([SF('L_Card', nListA.Values['BillCard']),
              SF('L_Status', sFlag_TruckBFM),
              SF('L_NextStatus', sFlag_TruckOut),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_MDate', sField_SQLServer_Now, sfVal),
              SF('L_PValue', '0', sfVal),
              SF('L_MValue', FIn.FExtParam, sfVal),
              SF('L_HdOrderId', FIn.FData),
              SF('L_Man', FIn.FData + '-合单')
              ], sTable_Bill, SF('L_ID', nListA.Values['HKBill']), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := MakeSQLByStr([SF('L_HdOrderId', FIn.FData)
              ], sTable_Bill, SF('L_ID', FIn.FData), False);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      nStr := 'Update %s Set H_HKBill=''%s'' Where H_Bill=''%s''';
      nStr := Format(nStr, [sTable_BillHK, nListA.Values['HKBill'],
              nListA.Values['BillID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      FDBConn.FConn.CommitTrans;
      Result := True;
    except
      on E: Exception do
      begin
        nData := '车辆[ %s ]合单失败,描述: %s';
        nData := Format(nData, [nListA.Values['Truck'], E.Message]);
        FDBConn.FConn.RollbackTrans;

        TWorkerBusinessBills.CallMe(cBC_DeleteBill, nOut.FData, '', @nOut);
        //删除提货单
      end;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-09-17
//Parm: 磁卡号[FIn.FData];岗位[FIn.FExtParam]
//Desc: 获取特定岗位所需要的交货单列表
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //前缀和长度都满足交货单编码规则,则视为交货单号
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('磁卡[ %s ]信息已丢失.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '磁卡[ %s ]当前状态为[ %s ],无法提货.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '磁卡[ %s ]已被冻结,无法提货.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;
  
  nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,' +
          'L_NextStatus,L_Card,L_IsVIP,L_PValue,L_MValue,L_PrintHY,' +
          'L_HYDan, L_EmptyOut, L_LadeTime,L_CusType,L_SJName From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '交货单[ %s ]已无效.'
      else nData := '磁卡号[ %s ]没有交货单.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      FHYDan      := FieldByName('L_HYDan').AsString;
      FPrintHY    := FieldByName('L_PrintHY').AsString = sFlag_Yes;
      FLadeTime   := FieldByName('L_LadeTime').AsString;
      FCusType    := FieldByName('L_CusType').AsString;
      FSJName     := FieldByName('L_SJName').AsString;

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FYSValid      := FieldByName('L_EmptyOut').AsString;
      if Assigned(FindField('L_SPlace')) then
        FSPlace := FieldByName('L_SPlace').AsString;

      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: 交货单[FIn.FData];岗位[FIn.FExtParam]
//Desc: 保存指定岗位提交的交货单列表
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp,nFixMoney,nBillDate: string;
    f,m,nVal,nMVal,nMValEx: Double;
    i,nIdx,nInt,nSanHK: Integer;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nTruck: string;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);
  nSanHK := 0;

  if nInt < 1 then
  begin
    nData := '岗位[ %s ]提交的单据为空.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  {$IFNDEF SanPreHK}
  if (nBills[0].FType = sFlag_San) and (nInt > 1) then
  begin
    nData := '岗位[ %s ]提交了散装合单,该业务系统暂时不支持.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  {$ENDIF}

  FListA.Clear;
  //用于存储SQL列表

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //进厂
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //袋装不过磅
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //更新队列车辆进厂状态
    end;

    nPLine := nil;
    with gTruckQueueManager do
    if not IsDelayQueue then //厂外模式,进厂时绑定道号(一车多单)
    try
      SyncLock.Enter;
      nTruck := nBills[0].FTruck;

      for nIdx:=Lines.Count - 1 downto 0 do
      begin
        nPLine := Lines[nIdx];
        nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

        if nInt < 0 then Continue;
        nPTruck := nPLine.FTrucks[nInt];
        {$IFDEF ChkPeerWeight}
        nStr := 'Update %s Set T_Line=''%s'' Where T_Bill=''%s''';
        nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID,nPTruck.FBill]);
        {$ELSE}
        nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
        nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
                nPTruck.FBill]);
        {$ENDIF}
        //xxxxx

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //绑定通道
      end;
    finally
      SyncLock.Leave;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //称量皮重
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的皮重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //保存车辆有效皮重

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //现场不发货直接过重

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //返回榜单号,用于拍照绑定

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_SJName', nBills[nInt].FSJName),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '出厂'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;

    nSQL := 'Update %s Set T_PDate=%s Where T_Truck=''%s''';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                          nBills[nInt].FTruck]);
    FListA.Add(nSQL); //更新过皮时间,厂内排队时可参考该时间排队
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //栈台现场
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //已称皮
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              {$IFDEF SendUnLoadPlace}
              SF('L_SPlace', FSPlace),
              {$ENDIF}
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //放灰现场
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_EmptyOut', FYSValid),
              {$IFDEF SendUnLoadPlace}
              SF('L_SPlace', FSPlace),
              {$ENDIF}
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //更新队列车辆提货状态
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    nInt := -1;
    nMVal := 0;

    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '岗位[ %s ]提交的毛重数据为0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    with nBills[0] do
    begin
      if FYSValid <> sFlag_Yes then
      begin
        if FType = sFlag_San then //散装需交验资金额
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
                 nBills[0].FZhiKa, '', @nOut) then
          begin
            nData := nOut.FData;
            Exit;
          end;

          m := StrToFloat(nOut.FData);
          m := m + Float2Float(FPrice * FValue, cPrecision, False);
          //纸卡可用金

          nVal := FValue;
          FValue := nMVal - FPData.FValue;
          //新净重,实际提货量
          f := Float2Float(FPrice * FValue, cPrecision, False)+0.01 - m;
          //实际所需金额与可用金差额,只入不舍

          if f > 0 then
          begin
            {$IFDEF SanPreHK}
            nSanHK := 1;
            nMValEx:= FMData.FValue;
            f := Float2Float(f / FPrice, cPrecision, False)+0.01;
            //纸卡超发吨数

            FValue := FValue - f;
            //纸卡最大可发量
            nMVal := nMVal - f;
            FMData.FValue := nMVal;
            //调整毛重,使过磅数据一致
                                                 // L_HdOrderId
            if not TWorkerBusinessBills.CallMe(cBC_MakeSanPreHK,
                   nBills[0].FID, FloatToStr(f), @nOut) then
            begin
              nData := nOut.FData;
              Exit;
            end;
            //新增磅单记录
            
            {$ELSE}
            nData := '客户[ %s.%s ]资金余额不足,详情如下:' + #13#10#13#10 +
                     '※.可用金额: %.2f元' + #13#10 +
                     '※.提货金额: %.2f元' + #13#10 +
                     '※.需 补 交: %.2f元' + #13#10+#13#10 +
                     '请到财务室办理"补交货款"手续,然后再次称重.';
            nData := Format(nData, [FCusID, FCusName, m, FPrice * FValue, f]);
            Exit;
            {$ENDIF}
          end;

          m := Float2Float(FPrice * FValue, cPrecision, True);
          m := m - Float2Float(FPrice * nVal, cPrecision, True);
          //新增冻结金额

          WriteLog('zyww::保存毛重新增冻结金,客户：'+FCusID+',新增:'+floattostr(m));

          nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney+(%.2f) ' +
                  'Where A_CID=''%s''';
          nSQL := Format(nSQL, [sTable_CusAccount, m, FCusID]);
          FListA.Add(nSQL); //更新账户

          nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
                  ], sTable_Bill, SF('L_ID', FID), False);
          FListA.Add(nSQL); //更新提货量

          if nOut.FExtParam = sFlag_Yes then
          begin
            nSQL := 'Update %s Set Z_FixedMoney=Z_FixedMoney-(%.2f) ' +
                    'Where Z_ID=''%s''';
            nSQL := Format(nSQL, [sTable_ZhiKa, m, FZhiKa]);
            FListA.Add(nSQL); //更新纸卡限提金额
          end;

          nSQL := 'Select L_HYDan From %s Where L_ID=''%s''';
          nSQL := Format(nSQL, [sTable_Bill, FID]);
          with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
          if RecordCount > 0 then
          begin
            nSQL := 'Update %s Set B_HasUse=B_HasUse+(%.2f - %.2f) ' +
                    'Where B_Batcode=''%s''';
            nSQL := Format(nSQL, [sTable_StockBatcode, FValue, nVal,
                    Fields[0].AsString]);
            FListA.Add(nSQL);
          end;
          //更新批次号使用量
        end;
      end
      else
      begin
        if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
               nBills[0].FZhiKa, '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end;
        nFixMoney := nOut.FExtParam;

        if nFixMoney = sFlag_Yes then
        begin
          nSQL := 'Update %s Set Z_FixedMoney=Z_FixedMoney-%s Where Z_ID=''%s''';
          nSQL := Format(nSQL, [sTable_ZhiKa, FloatToStr(nVal),
                  nBills[0].FZhiKa]);
          //xxxxx

          FListA.Add(nSQL);
        end;
        //释放限提金额

        nVal := Float2Float(FPrice * FValue, cPrecision, False);

        nSQL := 'Update %s Set A_FreezeMoney=A_FreezeMoney-%s Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, FloatToStr(nVal),
                FCusID]);
        FListA.Add(nSQL);
        //释放冻结金

        nSQL := 'Update %s Set B_HasUse=B_HasUse-%.2f Where B_Batcode=''%s''';
        nSQL := Format(nSQL, [sTable_StockBatcode, FValue, FHYDan]);
        FListA.Add(nSQL);
        //释放使用的批次号
      end;
    end;

    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        //累计净重
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //扣减已累计的净重

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //出厂模式,毛重不生效
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //未称毛重记录

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //出厂模式,不更新状态

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //排除本次称重

      if FYSValid <> sFlag_Yes then   //判断是否空车出厂
      begin
        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FMData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);
        if nSanHK = 1 then
        begin
          nSQL := MakeSQLByStr([
                  SF('P_MValue', nMValEx, sfVal)
                  ], sTable_PoundLog, SF('P_Bill', FID), False);
          FListA.Add(nSQL);
        end;
      end else
      begin
        nSQL := MakeSQLByStr([SF('L_Value', 0.00, sfVal),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_MValue', FPData.FValue , sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('P_MValue', FPData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //未过重交货单列表

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的提货记录的皮重,等于本次的毛重

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //没有称毛重的过磅记录的皮重,等于本次的毛重
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //未称毛重记录

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //交货单列表

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //更新交货单

      if FYSValid <> sFlag_Yes then
      begin
        nVal := Float2Float(FPrice * FValue, cPrecision, True);
        //提货金额

        nSQL := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f),' +
                'A_FreezeMoney=A_FreezeMoney-(%.2f) Where A_CID=''%s''';
        nSQL := Format(nSQL, [sTable_CusAccount, nVal, nVal, FCusID]);
        FListA.Add(nSQL); //更新客户资金(可能不同客户)
      end;
      {$IFDEF PrintHYEach}
      if FPrintHY then
      begin
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_HYDan;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nBillDate := DateTime2Str(Now);
        
        nSQL := ' Select B_FirstDate, B_PreDate, B_Batcode  From %s ' +
                ' Where  B_Stock = ''%s'' ';
        nSQL := Format(nSQL, [sTable_StockBatcode, FStockNo]);
        WriteLog('批次时间：'+nSQL);
        with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
        begin
          if RecordCount > 0 then
          begin
            if  FHYDan = Trim(FieldByName('B_Batcode').AsString) then
              nBillDate := FieldByName('B_FirstDate').AsString
            else
              nBillDate := FieldByName('B_PreDate').AsString;
          end;
        end;

        nSQL := MakeSQLByStr([SF('H_No', nOut.FData),
                SF('H_Custom', FCusID),
                SF('H_CusName', FCusName),
                SF('H_SerialNo', FHYDan),
                SF('H_Truck', FTruck),
                SF('H_Value', FValue, sfVal),
                SF('H_BillDate', nBillDate),
                SF('H_ReportDate', sField_SQLServer_Now, sfVal),
                //SF('H_EachTruck', sFlag_Yes),
                SF('H_Reporter', FID)], sTable_StockHuaYan, '', True);
        FListA.Add(nSQL); //自动生成化验单
      end;
      {$ENDIF}
    end;
    
    {$IFDEF SendBillToBakDB}
    if nBills[0].FCusType = 'A' then    //A:开票客户
    begin
      nStr := CombinStr(FListB, ',', True);
      if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill, nStr, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
    end;
    {$ENDIF}

    nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //更新磁卡状态

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //交货单列表

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //合卡,但非主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //袋重无效

        i := Trunc(FValue * 1000 / FPerW);
        //袋数

        nSQL := MakeSQLByStr([
//                SF('L_LadeLine', FLine),
//                SF('L_LineName', FName),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //扣减合卡副单的装车量
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //合卡主单

      if nInt < 0 then Continue;
      //检索装车信息

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([
//                SF('L_LadeLine', FLine),
//                SF('L_LineName', FName),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //更新装车信息
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //清理装车队列

    {$IFDEF UseWebYYOrder}
    nSQL := ' Delete From %s Where W_WebOrderID In (select distinct L_WebOrderID from S_Bill where L_ID In(%s)) ';
    nSQL := Format(nSQL, [sTable_YYWebBill, nStr]);
    FListA.Add(nSQL); //清理预约单信息
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  //使用业务员授信
  {$IFDEF UseSalesCredit}
  if FIn.FExtParam = sFlag_TruckBFM then
    TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
                 nBills[0].FZhiKa, '', @nOut);
  {$ENDIF}

  if FIn.FExtParam = sFlag_TruckBFM then //称量毛重
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nBills[0].FCard);
    //磅房处理自动出厂
  end;

  {$IFDEF MicroMsg}
  nStr := '';
  for nIdx:=Low(nBills) to High(nBills) do
    nStr := nStr + nBills[nIdx].FID + ',';
  //xxxxx

  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with FListA do
    begin
      Clear;
      Values['bill'] := nStr;
      Values['company'] := gSysParam.FHintText;
    end;

    gWXPlatFormHelper.WXSendMsg(cWXBus_OutFact, FListA.Text);
  end;
  {$ENDIF}

  {$IFDEF SaveCusMoneyByOutFact}
  if FIn.FExtParam = sFlag_TruckOut then //出厂
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoneyEx,
                FZhiKa, '', @nOut) then
      begin
        WriteLog('客户剩余资金：'+nOut.FData);
        nSQL := MakeSQLByStr([
                SF('L_NowValidMoney', nOut.FData)
                ], sTable_Bill, SF('L_ID', FID), False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
    end;
  end;
  {$ENDIF}
end;

//Date: 2019-03-17
//Desc: 读取物料库位
function TWorkerBusinessBills.GetStockKuWei(const nStockNo: string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_StockKuWei, nStockNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

function TWorkerBusinessBills.GetCusType(const nCusID: string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select C_Type From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, nCusID]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
  end;
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.
