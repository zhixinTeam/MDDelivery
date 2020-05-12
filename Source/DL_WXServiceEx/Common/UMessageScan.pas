{*******************************************************************************
作者: juner11212436@163.com 2017/11/20
描述: 微信业务发送表扫描线程
*******************************************************************************}
unit UMessageScan;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBussinessWebchat ;

type
  TMessageScan = class;
  TMessageScanThread = class(TThread)
  private
    FOwner: TMessageScan;
    //拥有者
    FDBConn: PDBWorker;
    //数据对象
    FListA,FListB,FListC,FListD: TStrings;
    //列表对象
    FXMLBuilder: TNativeXml;
    //XML构建器
    FWaiter: TWaitObject;
    //等待对象
    FSyncLock: TCrossProcWaitObject;
    //同步锁定
    FNumOutFactMsg: Integer;
    //提货单出厂消息推送计时计数
  protected
    function SendSaleMsgToWebMall(nList: TStrings):Boolean;
    //销售发送消息
    function SendOrderMsgToWebMall(nList: TStrings):Boolean;
    //采购发送消息
    procedure UpdateMsgNum(const nSuccess: Boolean; nLID: string);
    //更新消息状态
    procedure UpdateYYMsgNum(const nSuccess: Boolean; nWebOrderID: string);
    //更新消息状态
    procedure DoSaveOutFactMsg;
    //执行出厂消息插入
    function GetQueueENum(const nStockNo : string) : Integer;
    //获取品种队列容量
    procedure DoYYSuccess;
    //执行预约成功单据
    procedure DoYYOverTime;
    //执行预约超时单据
    procedure DoWebOrderAutoLoss;
    //申请单是否失效
    function SaveSaleOutFactMsg(nList: TStrings):Boolean;
    //销售出厂消息
    function SaveOrderOutFactMsg(nList: TStrings):Boolean;
    //销售出厂消息
    procedure CheckZhiKaXTMoney;
    procedure Execute; override;
    //执行线程
  public
    constructor Create(AOwner: TMessageScan);
    destructor Destroy; override;
    //创建释放
    procedure Wakeup;
    procedure StopMe;
    //启止线程
  end;

  TMessageScan = class(TObject)
  private
    FThread: TMessageScanThread;
    //扫描线程
  public
    FSyncTime:Integer;
    //设定同步次数阀值
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure Start;
    procedure Stop;
    //起停上传
    procedure LoadConfig(const nFile:string);//载入配置文件
  end;

var
  gMessageScan: TMessageScan = nil;
  //全局使用


implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TMessageScan, '微信消息扫描', nMsg);
end;

constructor TMessageScan.Create;
begin
  FThread := nil;
end;

destructor TMessageScan.Destroy;
begin
  Stop;
  inherited;
end;

procedure TMessageScan.Start;
begin
  if not Assigned(FThread) then
    FThread := TMessageScanThread.Create(Self);
  FThread.Wakeup;
end;

procedure TMessageScan.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//载入nFile配置文件
procedure TMessageScan.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      FSyncTime:= StrToInt(nNode.NodeByName('SyncTime').ValueAsString);
    except
      FSyncTime:= 5;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TMessageScanThread.Create(AOwner: TMessageScan);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 30*1000;  

  FSyncLock := TCrossProcWaitObject.Create('WXService_MessageScan');
  //process sync
end;

destructor TMessageScanThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FListD.Free;
  FXMLBuilder.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TMessageScanThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TMessageScanThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMessageScanThread.Execute;
var nErr, nSuccessCount, nFailCount: Integer;
    nStr: string;
    nResult : Boolean;
    nInit: Int64;
    nOut: TWorkerBusinessCommand;
begin
  FNumOutFactMsg := 0;

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumOutFactMsg);

    if FNumOutFactMsg >= 4 then
      FNumOutFactMsg := 0;

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //其它进程正在执行

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      if FNumOutFactMsg = 0 then
      begin
        DoSaveOutFactMsg;
      end
      else if FNumOutFactMsg = 1 then
      begin
        {$IFDEF UseWebYYOrder}
        TBusWorkerBusinessWebchat.CallMe(cBC_WX_get_shopYYWebBill,'','',@nOut);
        DoYYSuccess;
        {$ENDIF}
        {$IFDEF WebOrderAutoLoss}
        TBusWorkerBusinessWebchat.CallMe(cBC_WX_get_shopYYWebBill,'','',@nOut);
        DoWebOrderAutoLoss;
        {$ENDIF}
      end
      else if FNumOutFactMsg = 2 then
      begin
        {$IFDEF UseWebYYOrder}
        DoYYOverTime;
        {$ENDIF}
      end
      else if FNumOutFactMsg = 3 then
      begin
        CheckZhiKaXTMoney;
      end;

      nStr := ' select top 100 * from %s where WOM_SyncNum <= %d And WOM_deleted <> ''%s'' ';
      nStr := Format(nStr,[sTable_WebOrderMatch, gMessageScan.FSyncTime, sFlag_Yes]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
          Continue;
        //无新消息
        nSuccessCount := 0;
        nFailCount := 0;
        WriteLog('共查询到'+ IntToStr(RecordCount) + '条数据,开始推送...');
        nInit := GetTickCount;

        First;

        while not Eof do
        begin
          FListA.Clear;
          FListA.Values['WOM_WebOrderID'] := FieldByName('WOM_WebOrderID').AsString;
          FListA.Values['WOM_LID']:= FieldByName('WOM_LID').AsString;
          FListA.Values['WOM_StatusType']:= FieldByName('WOM_StatusType').AsString;
          FListA.Values['WOM_MsgType']:= FieldByName('WOM_MsgType').AsString;
          FListA.Values['WOM_BillType']:= FieldByName('WOM_BillType').AsString;

          FDBConn.FConn.BeginTrans;
          try
            nStr := PackerEncodeStr(FListA.Text);
            nResult := TBusWorkerBusinessWebchat.CallMe(cBC_WX_complete_shoporders
                       ,nStr,'',@nOut);

            if nResult then
            begin
              //更新为已处理
              Inc(nSuccessCount);
            end
            else
            begin
              Inc(nFailCount);
            end;
            UpdateMsgNum(nResult,FListA.Values['WOM_LID']);
            FDBConn.FConn.CommitTrans;
          except
            if FDBConn.FConn.InTransaction then
              FDBConn.FConn.RollbackTrans;
          end ;
          WriteLog('第'+IntToStr(RecNo)+'条数据处理完成！提货单号:'+FListA.Values['WOM_LID']);
          Next;
        end;
      end;
      WriteLog(IntToStr(nSuccessCount) + '条消息同步成功，'
                + IntToStr(nFailCount) + '条消息同步失败，'
                + '耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

function TMessageScanThread.SendSaleMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Card,L_Price ' +
            'From $Bill b ';
    //xxxxx

    nStr := nStr + 'Where L_ID=''$CD''';

    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
      nTableName := sTable_BillBak
    else
      nTableName := sTable_Bill;
    nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '交货单[ %s ]已无效.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('L_CusID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('L_ID').AsString;
        FListB.Values['Card']       := FieldByName('L_Card').AsString;
        FListB.Values['Truck']      := FieldByName('L_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('L_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('L_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('L_CusName').AsString;
        FListB.Values['Value']      := FieldByName('L_Value').AsString;
        nStr := PackerEncodeStr(FListB.Text);
        
        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TMessageScanThread.SendOrderMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusFinished then
    begin
      nStr := 'Select D_ID,D_OID,D_ProID,D_ProName,D_Type,D_StockNo,' +
              'D_StockName,D_Truck,D_Value,D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where D_OID=''$CD''';

      nTableName := sTable_OrderDtl;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end
    else
    begin
      nStr := 'Select O_ID as D_OID,O_ProID as D_ProID,O_ProName as D_ProName,'+
              'O_Type as D_Type,O_StockNo as D_StockNo,O_StockName as D_StockName,' +
              'O_Truck as D_Truck,O_Value as D_Value,O_Card as D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where O_ID=''$CD''';

      if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
        nTableName := sTable_OrderBak
      else
        nTableName := sTable_Order;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end;

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '采购单[ %s ]已无效.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('D_ProID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('D_OID').AsString;
        FListB.Values['Card']       := FieldByName('D_Card').AsString;
        FListB.Values['Truck']      := FieldByName('D_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('D_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('D_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('D_ProName').AsString;
        FListB.Values['Value']      := FieldByName('D_Value').AsString;

        nStr := PackerEncodeStr(FListB.Text);

        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

procedure TMessageScanThread.UpdateMsgNum(const nSuccess: Boolean; nLID: string);
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  nUpdateDBWorker := nil;

  try
    if nSuccess then
    begin
      nStr := 'Update %s set WOM_deleted = ''%s'' where WOM_LID = ''%s''';
      nStr:= Format(nStr,[sTable_WebOrderMatch, sFlag_Yes,nLID]);
      gDBConnManager.ExecSQL(nStr);
      //更新为已处理
    end
    else
    begin
      nStr := 'Update %s Set WOM_SyncNum = WOM_SyncNum + 1 '+
              ' where WOM_LID = ''%s''';
      nStr:= Format(nStr,[sTable_WebOrderMatch, nLID]);
      gDBConnManager.ExecSQL(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nUpdateDBWorker);
  end;
end;

procedure TMessageScanThread.DoSaveOutFactMsg;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nOut: TWorkerWebChatData;
begin
  nStr:= 'select top 1000 * from %s where WOM_StatusType =%d Order by R_ID desc';
  nStr:= Format(nStr,[sTable_WebOrderMatch, c_WeChatStatusCreateCard]);
  //查询最近1000条网上开单记录
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //无新消息
    WriteLog('共查询到'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;
    FListB.Clear;

    First;

    while not Eof do
    begin
      FListA.Clear;
      FListA.Values['WOM_WebOrderID'] := FieldByName('WOM_WebOrderID').AsString;
      FListA.Values['WOM_LID']:= FieldByName('WOM_LID').AsString;
      FListA.Values['WOM_StatusType']:= FieldByName('WOM_StatusType').AsString;
      FListA.Values['WOM_MsgType']:= FieldByName('WOM_MsgType').AsString;
      FListA.Values['WOM_BillType']:= FieldByName('WOM_BillType').AsString;
      nStr := StringReplace(FListA.Text, #$D#$A, '\S', [rfReplaceAll]);
      FListB.Add(nStr);
      Next;
    end;
  end;
  for nIdx := 0 to FListB.Count - 1 do
  begin
    nStr := FListB.Strings[nIdx];
    FListA.Text := StringReplace(nStr, '\S', #$D#$A, [rfReplaceAll]);
    if FListA.Values['WOM_BillType'] = sFlag_Sale then
      SaveSaleOutFactMsg(FListA)
    else
      SaveOrderOutFactMsg(FListA);
  end;
  WriteLog('插入出厂推送消息耗时: ' + IntToStr(GetTickCount - nInit) + 'ms');
end;

function TMessageScanThread.SaveSaleOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select L_ID from %s where L_ID=''%s'' and L_OutFact is not null ';
  nStr := Format(nStr,[sTable_Bill,nLID]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('查询到提货单'+ nLID +'已出厂,插入推送消息...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

function TMessageScanThread.SaveOrderOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select D_ID from %s where D_OID=''%s'' and D_OutFact is not null ';
  nStr := Format(nStr,[sTable_OrderDtl,nLID]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('查询到采购单'+ nLID +'已出厂,插入推送消息...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

procedure TMessageScanThread.DoYYSuccess;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nBool : Boolean;
    nStockNo,nWebOrderID,nOrderNo: string;
    nOut: TWorkerWebChatData;
begin
  nStr := ' select top 100 * from %s where W_State = ''%s'' and W_SyncNum <= %d '+
          ' and W_deleted <> ''%s'' and  W_StockNo in (select distinct D_ParamB from Sys_Dict where D_Name=''StockItem'' ) Order by W_MakeTime asc ';
  nStr := Format(nStr,[sTable_YYWebBill, '0', gMessageScan.FSyncTime, sFlag_Yes]);
  //查询最早100条网上预约单记录
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //无新消息
    WriteLog('共查询到预约单据'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;

    FListC.Clear;
    FListD.Clear;
    First;
    while not Eof do
    begin
      nStockNo    := FieldByName('W_StockNo').AsString;
      nWebOrderID := FieldByName('W_WebOrderID').AsString;
      nOrderNo    := FieldByName('W_OrderNo').AsString;
      FListC.Add(nStockNo);
      FListD.Add(nWebOrderID);
      Next;
    end;
  end;

  if (FListC.Count > 0) then
  try
    //开启事务
    for nIdx := 0 to FListC.Count - 1 do
    begin
      //判断队列中是否有容量
      if GetQueueENum(FListC[nIdx]) > 0 then
      begin
        //发送预约成功信息
        FListB.Clear;
        FListB.Values['orderNo'] := FListD[nIdx];
        FListB.Values['status']  := '10';
        nStr                     := PackerEncodeStr(FListB.Text);

        nBool := TBusWorkerBusinessWebchat.CallMe(cBC_WX_get_syncYYWebState,nStr,'',@nOut);
        if nBool then
        begin
          UpdateYYMsgNum(nBool,FListD[nIdx]);
        end
        else
        begin
          UpdateYYMsgNum(nBool,FListD[nIdx]);
        end;
      end;
    end;
  except
    //
  end;
end;

function TMessageScanThread.GetQueueENum(const nStockNo: string): Integer;
var
  nStr: string;
  sumNum,num1,num2:Integer;
begin
  Result := 0;
  sumNum := 0;
  num1   := 0;
  num2   := 0;
  nStr   :=' SELECT SUM(Z_QueueMax) as Z_QueueMax FROM %s where Z_StockNo = ''%s'' and Z_Valid = ''Y'' ';
  nStr   := Format(nStr,[sTable_ZTLines, nStockNo]);
  //查询品种的总队列容量
  WriteLog('队列总容量:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    sumNum := FieldByName('Z_QueueMax').AsInteger;
  end;

  nStr   :=' SELECT count(*) as num FROM %s where T_StockNo = ''%s'' and T_Valid = ''%s'' ';
  nStr   := Format(nStr,[sTable_ZTTrucks, nStockNo,sFlag_Yes]);
  //查询品种的已使用量1
  WriteLog('已使用量1:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    num1 := FieldByName('num').AsInteger;
  end;

  nStr := ' select count(*) as num from %s where W_State = ''%s'' and W_StockNo = ''%s'' ';
  nStr := Format(nStr,[sTable_YYWebBill, '1',nStockNo]);
  //查询品种的已使用量2
  WriteLog('已使用量2:'+nStr);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    num2 := FieldByName('num').AsInteger;
  end;

  Result := sumNum - num1 -num2;
  
end;

procedure TMessageScanThread.UpdateYYMsgNum(const nSuccess: Boolean; nWebOrderID: string);
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  nUpdateDBWorker := nil;

  try
    if nSuccess then
    begin
      nStr := ' Update %s set W_deleted = ''%s'', W_State = ''%s'',W_SucessTime = %s  where W_WebOrderID = ''%s''';
      nStr := Format(nStr,[sTable_YYWebBill, sFlag_Yes, '1', sField_SQLServer_Now, nWebOrderID]);
      gDBConnManager.ExecSQL(nStr);
      //更新为已处理
    end
    else
    begin
      nStr := ' Update %s Set W_SyncNum = W_SyncNum + 1 where W_WebOrderID = ''%s'' ';
      nStr := Format(nStr,[sTable_YYWebBill, nWebOrderID]);
      gDBConnManager.ExecSQL(nStr);
    end;
  finally
    gDBConnManager.ReleaseConnection(nUpdateDBWorker);
  end;
end;

procedure TMessageScanThread.DoYYOverTime;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nBool : Boolean;
    nStockNo,nWebOrderID,nOrderNo: string;
    nOut: TWorkerWebChatData;
    nUpdateDBWorker: PDBWorker;
begin
  nStr := ' select top 100 * from %s o where W_State = ''%s'' '+
          ' and not exists(Select R_ID from S_Bill od where o.W_WebOrderID=od.L_WebOrderID) '+
          ' Order by W_MakeTime asc ';
  nStr := Format(nStr,[sTable_YYWebBill, '1']);
  //查询最早100条网上预约单记录
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //无新消息
    WriteLog('共查询到预约成功单据'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;

    FListC.Clear;
    First;
    while not Eof do
    begin
      nStockNo    := FieldByName('W_StockNo').AsString;
      nWebOrderID := FieldByName('W_WebOrderID').AsString;
      nOrderNo    := FieldByName('W_OrderNo').AsString;
      //判断预约成功单据是否超时
      if (Now - FieldByName('W_SucessTime').AsDateTime)*24*60 > gSysParam.FOverTime then
      begin
        FListC.Add(nWebOrderID);
      end;
      Next;
    end;
  end;

  if (FListC.Count > 0) then
  try
    //开启事务
    for nIdx := 0 to FListC.Count - 1 do
    begin
      //发送预约成功超时信息
      FListB.Clear;
      FListB.Values['orderNo'] := FListC[nIdx];
      FListB.Values['status']  := '11';
      nStr                     := PackerEncodeStr(FListB.Text);

      nBool := TBusWorkerBusinessWebchat.CallMe(cBC_WX_get_syncYYWebState,nStr,'',@nOut);
      if nBool then
      begin
        nUpdateDBWorker := nil;

        try
          nStr := ' update %s set W_State = ''2'' where W_WebOrderID = ''%s''';
          nStr := Format(nStr,[sTable_YYWebBill, FListC[nIdx]]);
          gDBConnManager.ExecSQL(nStr);
          //更新预约超时单据

          nStr := ' update %s set W_State = ''2'' where W_StockNo not in (select distinct D_ParamB from Sys_Dict where D_Name=''StockItem'' )';
          nStr := Format(nStr,[sTable_YYWebBill]);
          gDBConnManager.ExecSQL(nStr);
          //更新原材料单据
        finally
          gDBConnManager.ReleaseConnection(nUpdateDBWorker);
        end;
      end;
    end;
  except
    //
  end;
end;

procedure TMessageScanThread.DoWebOrderAutoLoss;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nBool : Boolean;
    nWebOrderID: string;
    nOut: TWorkerWebChatData;
    nLossDate: TDateTime;
begin
  nBool := False;

  nStr := 'Select * From %s Where D_Name=''%s''' ;
  nStr := Format(nStr,[sTable_SysDict, sFlag_WebOrderLoss]);
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
    begin
      nBool:= Fieldbyname('D_Value').AsString = sFlag_Yes;
      if FieldByName('D_Index').AsInteger > 0 then
        nLossDate := IncDay(Now, 0 - FieldByName('D_Index').AsInteger)
      else
      begin
        nStr := FormatDateTime('YYYY-MM-DD',Now) + ' ' + Fieldbyname('D_Memo').AsString;
        nLossDate := StrToDateTime(nStr);
      end;
    end;
  end;

  if not nBool then
    Exit;

  WriteLog('申请单过期时间节点:' + DateTime2Str(nLossDate));

  nStr := ' select top 100 * from %s y where W_State = ''%s'' '+
          ' and not exists(Select R_ID from %s w where y.W_WebOrderID=w.WOM_WebOrderID) '+
          ' Order by W_MakeTime asc ';
  nStr := Format(nStr,[sTable_YYWebBill, '0', sTable_WebOrderMatch]);
  //查询最早100条网上预约单记录
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //无新消息
    WriteLog('共查询到网上申请单'+ IntToStr(RecordCount) + '条数据,开始筛选...');
    nInit := GetTickCount;
    FListB.Clear;
    FListD.Clear;
    First;
    while not Eof do
    begin
      nWebOrderID := FieldByName('W_WebOrderID').AsString;
      if FieldByName('W_MakeTime').AsDateTime < nLossDate then
      begin
        WriteLog('订单' + nWebOrderID + '已过期,下单时间:' + FieldByName('W_MakeTime').AsString
                  + '执行取消订单动作');
        FListB.Add(nWebOrderID);
        FListD.Add(FieldByName('W_OrderNo').AsString);
      end;
      Next;
    end;
  end;

  if (FListB.Count > 0) then
  try
    FDBConn.FConn.BeginTrans;
    //开启事务
    for nIdx:=0 to FListB.Count - 1 do
    begin
      FListC.Clear;
      FListC.Values['WOM_WebOrderID'] := FListB[nIdx];
      FListC.Values['WOM_LID']:= 'DelBill';
      FListC.Values['WOM_StatusType']:= IntToStr(c_WeChatStatusDeleted);
      FListC.Values['WOM_MsgType']:= IntToStr(cSendWeChatMsgType_DelBill);
      FListC.Values['WOM_ZhiKa']:= FListD[nIdx];
      nStr := PackerEncodeStr(FListC.Text);
      if TBusWorkerBusinessWebchat.CallMe(cBC_WX_complete_shoporders
                       ,nStr,'',@nOut) then
      begin
        nStr := ' Delete %s  where W_WebOrderID = ''%s'' ';
        nStr := Format(nStr,[sTable_YYWebBill,FListB[nIdx]]);
        gDBConnManager.WorkerExec(FDBConn,nStr);
      end;
    end;
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

procedure TMessageScanThread.CheckZhiKaXTMoney;
var
  nStr: string;
  nUpdateDBWorker: PDBWorker;
begin
  nUpdateDBWorker := nil;

  try
    //校正纸卡付款方式
    nStr := ' update S_ZhiKa set Z_PayType = (select D_Index from Sys_Dict ' +
            ' where D_Name= ''PaymentItem'' and D_Value=Z_Payment)';
    gDBConnManager.ExecSQL(nStr);
    //校正出入金付款方式
    nStr := ' update Sys_CustomerInOutMoney set M_PayType = '+
            ' (select D_Index from Sys_Dict where D_Name= ''PaymentItem2'' and D_Value=M_Payment)';
    gDBConnManager.ExecSQL(nStr);

    //初始化
    nStr := ' update S_ZhiKa set Z_FixedMoney = 0';
    gDBConnManager.ExecSQL(nStr);

    //校正纸卡限提1
    nStr := ' update S_ZhiKa set Z_FixedMoney  = M_Money From( ' +
            ' Select Sum(isnull(M_Money,0)) M_Money, M_CusID,M_PayType from ( ' +
            ' select M_Money, M_CusID,M_PayType from Sys_CustomerInOutMoney ' +
            '  ) t Group by M_CusID,M_PayType) b where Z_Customer = b.M_CusID and Z_PayType= M_PayType ';
    gDBConnManager.ExecSQL(nStr);
    //校正纸卡限提2
    nStr := ' update S_ZhiKa set Z_FixedMoney  = Z_FixedMoney-L_Money From( ' +
            ' Select isnull(Sum(L_Money),0) L_Money, L_CusID,L_ZhiKa from ( ' +
            ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID,L_ZhiKa from S_Bill ' +
            '  ) t Group by L_CusID,L_ZhiKa) b where Z_Customer = b.L_CusID and Z_ID= b.L_ZhiKa ';
    gDBConnManager.ExecSQL(nStr);
    //校正纸卡限提标识1
    nStr := ' update S_ZhiKa set Z_OnlyMoney= ''Y'' where Z_Customer ' +
            ' not in (select A_CID from Sys_CustomerAccount ' +
            ' where A_CreditLimit >0 Group by A_CID ) ';
    gDBConnManager.ExecSQL(nStr);
    //校正纸卡限提标识2
    nStr := ' update S_ZhiKa set Z_OnlyMoney= NULL where Z_Customer ' +
            ' in (select A_CID from Sys_CustomerAccount ' +
            ' where A_CreditLimit >0 Group by A_CID ) ';
    gDBConnManager.ExecSQL(nStr);

  finally
    gDBConnManager.ReleaseConnection(nUpdateDBWorker);
  end;
end;

initialization
  gMessageScan := nil;
finalization
  FreeAndNil(gMessageScan);
end.

