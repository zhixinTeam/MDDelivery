{*******************************************************************************
  作者: dmzn@163.com 2010-3-8
  描述: 系统业务处理
*******************************************************************************}
unit USysBusiness;

interface
{$I Link.inc}
uses
  Windows, DB, Classes, Controls, SysUtils, UBusinessPacker, UBusinessWorker,
  UBusinessConst, ULibFun, UAdjustForm, UFormCtrl, UDataModule, UDataReport,
  UFormBase, cxMCListBox, UMgrPoundTunnels, UMgrCamera, UBase64, USysConst,
  USysDB, USysLoger;

type
  TLadingStockItem = record
    FID: string;         //编号
    FType: string;       //类型
    FName: string;       //名称
    FParam: string;      //扩展
  end;

  TDynamicStockItemArray = array of TLadingStockItem;
  //系统可用的品种列表

  PZTLineItem = ^TZTLineItem;
  TZTLineItem = record
    FID       : string;      //编号
    FName     : string;      //名称
    FStock    : string;      //品名
    FWeight   : Integer;     //袋重
    FValid    : Boolean;     //是否有效
    FPrinterOK: Boolean;     //喷码机
  end;

  PZTTruckItem = ^TZTTruckItem;
  TZTTruckItem = record
    FTruck    : string;      //车牌号
    FLine     : string;      //通道
    FBill     : string;      //提货单
    FValue    : Double;      //提货量
    FDai      : Integer;     //袋数
    FTotal    : Integer;     //总数
    FInFact   : Boolean;     //是否进厂
    FIsRun    : Boolean;     //是否运行    
  end;

  TZTLineItems = array of TZTLineItem;
  TZTTruckItems = array of TZTTruckItem;

  PSalePlanItem = ^TSalePlanItem;
  TSalePlanItem = record
    FOrderNo: string;        //订单号     
    FInterID: string;        //主表编号
    FEntryID: string;        //附表编号
    FStockID: string;        //物料编号
    FStockName: string;      //物料名称

    FTruck: string;          //车牌号码
    FValue: Double;          //开单量
    FSelected: Boolean;      //状态
  end;
  TSalePlanItems = array of TSalePlanItem;
  
//------------------------------------------------------------------------------
function AdjustHintToRead(const nHint: string): string;
//调整提示内容
function WorkPCHasPopedom: Boolean;
//验证主机是否已授权
function GetSysValidDate: Integer;
//获取系统有效期
function GetTruckEmptyValue(nTruck: string): Double;
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean = True): string;
//获取串行编号
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
//可用品种列表
function GetCardUsed(const nCard: string): string;
//获取卡片类型

function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
//读取系统字典项
function LoadSysDictPayType(const nList: TStrings): TDataSet;
//读取系统付款方式
function LoadSysDictQTType(const nList: TStrings): TDataSet;
//读取系统欠提方式
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取业务员列表
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
//读取客户列表
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
//载入客户信息

function IsZhiKaNeedVerify: Boolean;
//纸卡是否需要审核
function IsPrintZK: Boolean;
//是否打印纸卡
function DeleteZhiKa(const nZID: string): Boolean;
//删除指定纸卡
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
//载入纸卡
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
//纸卡可用金
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
 const nCredit: PDouble = nil): Double;
//客户可用金额

function SyncRemoteCustomer: Boolean;
//同步远程用户
function SyncRemoteSaleMan: Boolean;
//同步远程业务员
function SyncRemoteProviders: Boolean;
//同步远程用户
function SyncRemoteMeterails: Boolean;
//同步远程业务员
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
//存临时客户
function IsAutoPayCredit: Boolean;
//回款时冲信用
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nPrice: Double; const nStockName: string;
 const nAcceptNum: string; const nPayingUnit: string;
 const nPayingMan: string;
 const nCredit: Boolean = True): Boolean;
//保存回款记录
function SaveCustomerKPPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nPrice: Double; const nStockName: string;
 const nAcceptNum: string; const nPayingUnit: string;
 const nPayingMan: string;
 const nCredit: Boolean = True): Boolean;
//保存回款记录
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
//保存信用记录
function IsCustomerCreditValid(const nCusID: string): Boolean;
//客户信用是否有效
procedure SaveCustomerPaymentEvent(const nSID,nEvent,
      nFrom,nSolution,nDepartment: string);
//财务收款向销售部门电脑推送消息

//车牌识别
function VeriFyTruckLicense(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;

function GetTruckIsQueue(const nTruck: string): Boolean;
//获取车辆是否在队列中
function GetTruckIsOut(const nTruck: string): Boolean;
//获取车辆是否已出队
function IsStockValid(const nStocks: string): Boolean;
//品种是否可以发货
function SaveBill(const nBillData: string): string;
//保存交货单
function DeleteBill(const nBill: string): Boolean;
//删除交货单
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
//更改提货车辆
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
//交货单调拨
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//为交货单办理磁卡
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
//办理厂内零售磁卡
function LoadSalePlan(const nCusID: string;var nPlans: TSalePlanItems): Boolean;
//读取销售计划
function SaveBillCard(const nBill, nCard: string): Boolean;
//保存交货单磁卡
function LogoutBillCard(const nCard: string): Boolean;
//注销指定磁卡
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;

function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//获取指定岗位的交货单列表
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
//载入单据信息到列表
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil;const nLogin: Integer = -1): Boolean;
//保存指定岗位的交货单

function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
//获取指定车辆的已称皮重信息
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems;const nLogin: Integer = -1): Boolean;
//保存车辆过磅记录
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
//读取指定磅站读头上的卡号
function ReadPoundCardEx(var nReader: string;
  const nTunnel: string; nReadOnly: String = ''): string;
//读取指定磅站读头上的卡号(电子标签)
function GetTruckRealLabel(const nTruck: string): string;
//获取车辆绑定的电子标签
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
//抓拍指定通道

procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string = '');
//获取误差范围
function GetSaleMValueMax: Double;
//获取销售毛重最大限值
function GetTruckNO(const nTruck: WideString; const nLong: Integer=12): string;
function GetValue(const nValue: Double): string;
//显示格式化

function IsTunnelOK(const nTunnel: string): Boolean;
//查询通道光栅是否正常
procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
//控制通道红绿灯开合
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
//经中间件播发语音
procedure ProberShowTxt(const nTunnel, nText: string);
//车检发送小屏
procedure CheckAllCusMoney;
//校正所有客户资金
procedure CheckZhiKaXTMoney;

function SaveOrderBase(const nOrderData: string): string;
//保存采购申请单
function DeleteOrderBase(const nOrder: string): Boolean;
//删除采购申请单
function SaveOrder(const nOrderData: string): string;
//保存采购单
function DeleteOrder(const nOrder: string): Boolean;
//删除采购单
//function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
////更改提货车辆
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
//为采购单办理磁卡
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//保存采购单磁卡
function LogoutOrderCard(const nCard: string): Boolean;
//注销指定磁卡
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
//修改车牌号

function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
//获取指定岗位的采购单列表
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem = nil;const nLogin: Integer = -1): Boolean;
//保存指定岗位的采购单
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);

function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean = False): Boolean;
//读取车辆队列
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
//启停喷码机
function ChangeDispatchMode(const nMode: Byte): Boolean;
//切换调度模式
function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
//读卡器打开道闸

function GetHYMaxValue: Double;
function GetHYValueByStockNo(const nNo: string): Double;
//获取化验单已开量
function IsEleCardVaid(const nTruckNo: string): Boolean;
//验证车辆电子标签
function IsEleCardVaidEx(const nTruckNo: string): Boolean;
//验证车辆电子标签
function IfStockHasLs(const nStockNo: string): Boolean;
//验证物料是否需要输入流水
function IFHasOrder(const nTruck: string): Boolean;
//车辆是否存在未完成采购单
function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
//周期是否有效
function IsWeekHasEnable(const nWeek: string): Boolean;
//周期是否启用
function IsNextWeekEnable(const nWeek: string): Boolean;
//下一周期是否启用
function IsPreWeekOver(const nWeek: string): Integer;
//上一周期是否结束
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
//保存用户补偿金

//------------------------------------------------------------------------------
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
//打印合同
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
//打印纸卡
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
//打印收据
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
//打印提货单
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
//打印采购单
function PrintRCOrderReport(const nID: string;  const nAsk: Boolean): Boolean;
//打印采购单
function PrintPoundReport(const nPound: string; nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
//打印榜单
function PrintPoundReportKS(const nPound: string; nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
//打印矿山榜单
function PrintHuaYanReport(nHID: string; const nAsk: Boolean): Boolean;
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
//化验单,合格证
function PrintBillFYDReport(const nBill: string;  const nAsk: Boolean): Boolean;
function PrintBillLoadReport(nBill: string; const nAsk: Boolean): Boolean;
//打印发运单，过路费

function GetTruckLastTime(const nTruck: string): Integer;
//最后一次过磅时间
function IsStrictSanValue: Boolean;
//判断是否严格执行散装禁止超发

function GetFQValueByStockNo(const nStock: string): Double;
//获取封签号已发量
function VerifyFQSumValue: Boolean;
//是否校验封签号
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom: string = sFlag_DepBangFang ;
 const nSolution: string = sFlag_Solution_YN;
 const nDepartmen: string = sFlag_DepDaTing;
 const nReset: Boolean = False; const nMemo: string = ''): Boolean;
//添加待处理事项记录
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string = sFlag_Yes; const nUpdateHint: Boolean = True): Boolean;
//检查事件是否通过处理
function VerifyManualEventRecordEx(const nEID: string; var nHint: string;
 const nWant: string = sFlag_Yes; const nUpdateHint: Boolean = True): Boolean;
//检查事件是否通过处理

function getCustomerInfo(const nData: string): string;
//获取客户注册信息
function get_Bindfunc(const nData: string): string;
//客户与微信账号绑定
function send_event_msg(const nData: string): string;
//发送消息
function edit_shopclients(const nData: string): string;
//新增商城用户
function edit_shopgoods(const nData: string): string;
//添加商品
function get_shoporders(const nData: string): string;
//获取订单信息
function complete_shoporders(const nData: string): string;
//更新订单状态
function getAuditTruck(const nData: string): string;
//获取审核车辆
function UploadAuditTruck(const nData: string): string;
//审核车辆结果上传
function DownLoadPic(const nData: string): string;
//下载照片
function GetshoporderbyTruck(const nData: string): string;
//根据车牌号获取订单
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
//插入推送消息

function MakeSaleViewData: Boolean;
//生成销售特定字段数据(特定使用)
function MakeOrderViewData: Boolean;
//生成采购特定字段数据(特定使用)

function SaveDDBases(const nDDData: string): string;
//保存短倒基本信息
function DeleteDDBase(const nBase: string): Boolean;
//删除短倒基本信息

function LogoutDDCard(const nCard: string): Boolean;
//注销短倒磁卡

function SaveDDCard(const nBID, nCard: string): Boolean;
//绑定短倒磁卡
function GetDuanDaoItems(const nCard,nPost: string;
  var nBills: TLadingBillItems): Boolean;
//获取指定岗位的短倒明细列表
function SaveDuanDaoItems(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem=nil;const nLogin: Integer = -1): Boolean;
//保存指定岗位的短倒明细
function DeleteDDDetial(const nDID: string): Boolean;
//删除短倒明细
function SetDDCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
//为交货单办理磁卡
function PrintDuanDaoReport(const nID: string; nAsk: Boolean): Boolean;
//打印短倒单

procedure CapturePictureEx(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
//抓拍nTunnel的图像Ex
function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
//初始化抓拍，与CapturePictureEx配套使用
function FreeCapture(nLogin: Integer): Boolean;
//释放抓拍
function IsSealInfoDone(const nCardUse : string; nBill: TLadingBillItem): Boolean;
function ShowLedText(nTunnel, nStr:string):Boolean;
//发送led显示内容
function GetIDCardNumCheckCode(nIDCardNum: string): string;
//身份证号校验算法

function GetWlbYsStatus(const nStockNo,nOrderId: string): Boolean;
//获取化验室验收状态

implementation

//Desc: 记录日志
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(nEvent);
end;

//Date: 2017-09-22
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的短倒单据对象
function CallBusinessDuanDao(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessDuanDao);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 调整nHint为易读的格式
function AdjustHintToRead(const nHint: string): string;
var nIdx: Integer;
    nList: TStrings;
begin
  nList := TStringList.Create;
  try
    nList.Text := nHint;
    for nIdx:=0 to nList.Count - 1 do
      nList[nIdx] := '※.' + nList[nIdx];
    Result := nList.Text;
  finally
    nList.Free;
  end;
end;

//Desc: 验证主机是否已授权接入系统
function WorkPCHasPopedom: Boolean;
begin
  Result := gSysParam.FSerialID <> '';
  if not Result then
  begin
    ShowDlg('该功能需要更高权限,请向管理员申请.', sHint);
  end;
end;

//------------------------------------------------------------------------------
//Desc: 车辆有效皮重
function GetTruckEmptyValue(nTruck: string): Double;
var nStr: string;
begin
  Result := 0;
  //init

  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyTruckP]);
  with FDM.QueryTemp(nStr) do
  if Recordcount > 0 then
   nStr := Fields[0].AsString;

  if nStr <> sFlag_Yes then Exit;
  //不校验皮重

  nStr := 'Select T_PValue From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的业务命令对象
function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessSaleBill(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessSaleBill);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessPurchaseOrder(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessPurchaseOrder);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-01
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessHardware(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //自动称重时不提示
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;


//Date: 2017-10-26
//Parm: 命令;数据;参数;服务地址;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessWechat(const nCmd: Integer; const nData,nExt,nSrvURL: string;
  const nOut: PWorkerWebChatData; const nWarn: Boolean = True): Boolean;
var nIn: TWorkerWebChatData;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FRemoteUL := nSrvURL;

    if nWarn then
         nIn.FBase.FParam := ''
    else nIn.FBase.FParam := sParam_NoHintOnError;

    if gSysParam.FAutoPound and (not gSysParam.FIsManual) then
      nIn.FBase.FParam := sParam_NoHintOnError;
    //close hint param
    
    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessWebchat);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-04
//Parm: 分组;对象;使用日期编码模式
//Desc: 依据nGroup.nObject生成串行编号
function GetSerialNo(const nGroup,nObject: string; nUseDate: Boolean): string;
var nStr: string;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Group'] := nGroup;
    nList.Values['Object'] := nObject;

    if nUseDate then
         nStr := sFlag_Yes
    else nStr := sFlag_No;

    if CallBusinessCommand(cBC_GetSerialNO, nList.Text, nStr, @nOut) then
      Result := nOut.FData;
    //xxxxx
  finally
    nList.Free;
  end;   
end;

//Desc: 获取系统有效期
function GetSysValidDate: Integer;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_IsSystemExpired, '', '', @nOut) then
       Result := StrToInt(nOut.FData)
  else Result := 0;
end;

function GetCardUsed(const nCard: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut) then
    Result := nOut.FData;
  //xxxxx
end;

//Desc: 获取当前系统可用的水泥品种列表
function GetLadingStockItems(var nItems: TDynamicStockItemArray): Boolean;
var nStr: string;
    nIdx: Integer;
begin
  nStr := 'Select D_Value,D_Memo,D_ParamB From $Table ' +
          'Where D_Name=''$Name'' Order By D_Index ASC';
  nStr := MacroValue(nStr, [MI('$Table', sTable_SysDict),
                            MI('$Name', sFlag_StockItem)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    SetLength(nItems, RecordCount);
    if RecordCount > 0 then
    begin
      nIdx := 0;
      First;

      while not Eof do
      begin
        nItems[nIdx].FType := FieldByName('D_Memo').AsString;
        nItems[nIdx].FName := FieldByName('D_Value').AsString;
        nItems[nIdx].FID := FieldByName('D_ParamB').AsString;

        Next;
        Inc(nIdx);
      end;
    end;
  end;

  Result := Length(nItems) > 0;
end;

//------------------------------------------------------------------------------
//Date: 2014-06-19
//Parm: 记录标识;车牌号;图片文件
//Desc: 将nFile存入数据库
procedure SavePicture(const nID, nTruck, nMate, nFile: string);
var nStr: string;
    nRID: Integer;
begin
  FDM.ADOConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('P_ID', nID),
            SF('P_Name', nTruck),
            SF('P_Mate', nMate),
            SF('P_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Picture, '', True);
    //xxxxx

    if FDM.ExecuteSQL(nStr) < 1 then Exit;
    nRID := FDM.GetFieldMax(sTable_Picture, 'R_ID');

    nStr := 'Select P_Picture From %s Where R_ID=%d';
    nStr := Format(nStr, [sTable_Picture, nRID]);
    FDM.SaveDBImage(FDM.QueryTemp(nStr), 'P_Picture', nFile);

    FDM.ADOConn.CommitTrans;
  except
    FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 构建图片路径
function MakePicName: string;
begin
  while True do
  begin
    Result := gSysParam.FPicPath + IntToStr(gSysParam.FPicBase) + '.jpg';
    if not FileExists(Result) then
    begin
      Inc(gSysParam.FPicBase);
      Exit;
    end;

    DeleteFile(Result);
    if FileExists(Result) then Inc(gSysParam.FPicBase)
  end;
end;

//Date: 2014-06-19
//Parm: 通道;列表
//Desc: 抓拍nTunnel的图像
procedure CapturePicture(const nTunnel: PPTTunnelItem; const nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nLogin,nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  nLogin := -1;
  gCameraNetSDKMgr.NET_DVR_SetDevType(nTunnel.FCamera.FType);
  //xxxxx

  gCameraNetSDKMgr.NET_DVR_Init;
  //xxxxx

  try
    for nIdx:=1 to cRetry do
    begin
      nLogin := gCameraNetSDKMgr.NET_DVR_Login(nTunnel.FCamera.FHost,
                   nTunnel.FCamera.FPort,
                   nTunnel.FCamera.FUser,
                   nTunnel.FCamera.FPwd, nInfo);
      //to login

      nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        Exit;
      end;
    end;

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        gCameraNetSDKMgr.NET_DVR_CaptureJPEGPicture(nLogin,
                                   nTunnel.FCameraTunnels[nIdx],
                                   nPic, nStr);
        //capture pic

        nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;

        if nErr = 0 then
        begin
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := '抓拍图像[ %s.%d ]失败,错误码: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  finally
    if nLogin > -1 then
     gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
    gCameraNetSDKMgr.NET_DVR_Cleanup();
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-07-09
//Parm: 包装正负误差;票重;磅站号
//Desc: 计算nVal的误差范围
procedure GetPoundAutoWuCha(var nWCValZ,nWCValF: Double; const nVal: Double;
 const nStation: string);
var nStr: string;
begin
  nWCValZ := 0;
  nWCValF := 0;
  if nVal <= 0 then Exit;

  nStr := 'Select * From %s Where P_Start<=%.2f and P_End>%.2f';
  nStr := Format(nStr, [sTable_PoundDaiWC, nVal, nVal]);

  if Length(nStation) > 0 then
    nStr := nStr + ' And P_Station=''' + nStation + '''';
  //xxxxx

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    if FieldByName('P_Percent').AsString = sFlag_Yes then
    begin
      nWCValZ := nVal * 1000 * FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := nVal * 1000 * FieldByName('P_DaiWuChaF').AsFloat;
      //按比例计算误差
    end else
    begin
      nWCValZ := FieldByName('P_DaiWuChaZ').AsFloat;
      nWCValF := FieldByName('P_DaiWuChaF').AsFloat;
      //按固定值计算误差
    end;
  end;
end;

function GetSaleMValueMax: Double;
var nStr: string;
begin
  Result := 0;

  nStr := ' Select D_Value From %s Where D_Name = ''%s'' and  D_Memo = ''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, 'MValueMax']);
  
  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    Result := FieldByName('D_Value').AsFloat;
  end;
end;

//Date: 2017-07-09
//Parm: 参数描述
//Desc: 添加异常事件处理
function AddManualEventRecord(const nEID,nKey,nEvent:string;
 const nFrom,nSolution,nDepartmen: string;
 const nReset: Boolean; const nMemo: string): Boolean;
var nStr: string;
    nUpdate: Boolean;
begin
  Result := False;
  if Trim(nSolution) = '' then
  begin
    WriteLog('请选择处理方案.');
    Exit;
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := '事件记录:[ %s ]已存在';
    WriteLog(Format(nStr, [nEID]));

    if not nReset then Exit;
    nUpdate := True;
  end else nUpdate := False;

  nStr := SF('E_ID', nEID);
  nStr := MakeSQLByStr([
          SF('E_ID', nEID),
          SF('E_Key', nKey),
          SF('E_From', nFrom),
          SF('E_Memo', nMemo),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', nSolution),
          SF('E_Departmen', nDepartmen),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx

  FDM.ExecuteSQL(nStr);
  Result := True;
end;

//Date: 2017-07-09
//Parm: 事件ID;预期结果;错误返回
//Desc: 判断事件是否处理
function VerifyManualEventRecord(const nEID: string; var nHint: string;
 const nWant: string; const nUpdateHint: Boolean): Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select E_Result, E_Event From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      if nUpdateHint then
        nHint := FieldByName('E_Event').AsString;
      Exit;
    end;

    if nStr <> nWant then
    begin
      if nUpdateHint then
        nHint := '请联系管理员，做换票处理';
      Exit;
    end;

    Result := True;
  end;
end;

//Date: 2017-07-09
//Parm: 事件ID;预期结果;错误返回
//Desc: 判断事件是否处理
function VerifyManualEventRecordEx(const nEID: string; var nHint: string;
 const nWant: string; const nUpdateHint: Boolean): Boolean;
var nStr: string;
begin
  Result := True;
  nStr := 'Select E_Result, E_Event From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nEID]);

  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    nStr := Trim(FieldByName('E_Result').AsString);
    if nStr = '' then
    begin
      if nUpdateHint then
        nHint := FieldByName('E_Event').AsString;
      Result := False;
      Exit;
    end;

    if nStr <> nWant then
    begin
      if nUpdateHint then
        nHint := '请联系管理员，做换票处理';
      Result := False;
      Exit;
    end;

    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014-07-03
//Parm: 通道号
//Desc: 查询nTunnel的光栅状态是否正常
function IsTunnelOK(const nTunnel: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessHardware(cBC_IsTunnelOK, nTunnel, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

procedure TunnelOC(const nTunnel: string; const nOpen: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nOpen then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_TunnelOC, nTunnel, nStr, @nOut);
end;

//Date: 2016-01-06
//Parm: 文本;语音卡;内容
//Desc: 用nCard播发nContent模式的nText文本.
function PlayNetVoice(const nText,nCard,nContent: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Card=' + nCard + #13#10 +
          'Content=' + nContent + #13#10 + 'Truck=' + nText;
  //xxxxxx

  Result := CallBusinessHardware(cBC_PlayVoice, nStr, '', @nOut);
  if not Result then
    WriteLog(nOut.FBase.FErrDesc);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Date: 2010-4-13
//Parm: 字典项;列表
//Desc: 从SysDict中读取nItem项的内容,存入nList中
function LoadSysDictItem(const nItem: string; const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', nItem)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

function LoadSysDictPayType(const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', sFlag_PaymentItem2)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      if Pos('欠提',FieldByName('D_Value').AsString) < 1 then
        nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

function LoadSysDictQTType(const nList: TStrings): TDataSet;
var nStr: string;
begin
  nList.Clear;
  nStr := MacroValue(sQuery_SysDict, [MI('$Table', sTable_SysDict),
                                      MI('$Name', sFlag_PaymentItem2)]);
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with Result do
  begin
    First;

    while not Eof do
    begin
      if Pos('欠提',FieldByName('D_Value').AsString) > 0 then
        nList.Add(FieldByName('D_Value').AsString);
      Next;
    end;
  end else Result := nil;
end;

//Desc: 读取业务员列表到nList中,包含附加数据
function LoadSaleMan(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'S_ID=Select S_ID,S_PY,S_Name From %s ' +
          'Where IsNull(S_InValid, '''')<>''%s'' %s Order By S_PY';
  nStr := Format(nStr, [sTable_Salesman, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.', DSA(['S_ID']));
  
  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 读取客户列表到nList中,包含附加数据
function LoadCustomer(const nList: TStrings; const nWhere: string = ''): Boolean;
var nStr,nW: string;
begin
  if nWhere = '' then
       nW := ''
  else nW := Format(' And (%s)', [nWhere]);

  nStr := 'C_ID=Select C_ID,C_Name From %s ' +
          'Where IsNull(C_XuNi, '''')<>''%s'' %s Order By C_PY';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nW]);

  AdjustStringsItem(nList, True);
  FDM.FillStringsData(nList, nStr, -1, '.');

  AdjustStringsItem(nList, False);
  Result := nList.Count > 0;
end;

//Desc: 载入nCID客户的信息到nList中,并返回数据集
function LoadCustomerInfo(const nCID: string; const nList: TcxMCListBox;
 var nHint: string): TDataSet;
var nStr: string;
begin
  nStr := 'Select cus.*,S_Name as C_SaleName From $Cus cus ' +
          ' Left Join $SM sm On sm.S_ID=cus.C_SaleMan ' +
          'Where C_ID=''$ID''';
  nStr := MacroValue(nStr, [MI('$Cus', sTable_Customer), MI('$ID', nCID),
          MI('$SM', sTable_Salesman)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount > 0 then
  with nList.Items,Result do
  begin
    Add('客户编号:' + nList.Delimiter + FieldByName('C_ID').AsString);
    Add('客户名称:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('企业法人:' + nList.Delimiter + FieldByName('C_FaRen').AsString + ' ');
    Add('联系方式:' + nList.Delimiter + FieldByName('C_Phone').AsString + ' ');
    Add('所属业务员:' + nList.Delimiter + FieldByName('C_SaleName').AsString);
  end else
  begin
    Result := nil;
    nHint := '客户信息已丢失';
  end;
end;

//Desc: 保存nSaleMan名下的nName为临时客户,返回客户号
function SaveXuNiCustomer(const nName,nSaleMan: string): string;
var nID: Integer;
    nStr: string;
    nBool: Boolean;
begin
  nStr := 'Select C_ID From %s ' +
          'Where C_XuNi=''%s'' And C_SaleMan=''%s'' And C_Name=''%s''';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes, nSaleMan, nName]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString;
    Exit;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into %s(C_Name,C_PY,C_SaleMan,C_XuNi) ' +
            'Values(''%s'',''%s'',''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Customer, nName, GetPinYinOfStr(nName),
            nSaleMan, sFlag_Yes]);
    FDM.ExecuteSQL(nStr);

    nID := FDM.GetFieldMax(sTable_Customer, 'R_ID');
    Result := FDM.GetSerialID2('KH', sTable_Customer, 'R_ID', 'C_ID', nID);

    nStr := 'Update %s Set C_ID=''%s'' Where R_ID=%d';
    nStr := Format(nStr, [sTable_Customer, Result, nID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(A_CID,A_Date) Values(''%s'', %s)';
    nStr := Format(nStr, [sTable_CusAccount, Result, FDM.SQLServerNow]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := '';
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 汇款时冲信用额度
function IsAutoPayCredit: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PayCredit)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 保存nCusID的一次回款记录
function SaveCustomerPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nPrice: Double;  const nStockName: string;
 const nAcceptNum: string; const nPayingUnit: string;
 const nPayingMan: string;
 const nCredit: Boolean): Boolean;
var nStr, nData, nSaleManName: string;
    nBool: Boolean;
    nVal,nLimit: Double;
begin
  Result := False;
  nVal := Float2Float(nMoney, cPrecision, False);
  //adjust float value

  {$IFNDEF NoCheckOnPayment}
  if nVal < 0 then
  begin
    nLimit := GetCustomerValidMoney(nCusID, False);
    //get money value
    
    if (nLimit <= 0) or (nLimit < -nVal) then
    begin
      nStr := '客户: %s ' + #13#10#13#10 +
              '当前余额为[ %.2f ]元,无法支出[ %.2f ]元.';
      nStr := Format(nStr, [nCusName, nLimit, -nVal]);
      
      ShowDlg(nStr, sHint);
      Exit;
    end;
  end;
  {$ENDIF}

  nLimit := 0;
  //no limit

  if nCredit and (nVal > 0) and IsAutoPayCredit then
  begin
    nStr := 'Select A_CreditLimit From %s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nCusID]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) and (Fields[0].AsFloat > 0) then
    begin
      if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
           nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False)
      else nLimit := nVal;

      nStr := '客户[ %s ]当前信用额度为[ %.2f ]元,是否冲减?' +
              #32#32#13#10#13#10 + '点击"是"将降低[ %.2f ]元的额度.';
      nStr := Format(nStr, [nCusName, Fields[0].AsFloat, nLimit]);

      if not QueryDlg(nStr, sAsk) then
        nLimit := 0;
      //xxxxx
    end;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_InMoney=A_InMoney+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,' +
            'M_Type,M_Payment,M_Money,M_Date,M_Man,M_Memo,M_RuZhang,M_Price,M_PriceStock,M_AcceptNum,M_PayingUnit,M_PayingMan) ' +
            'Values(''%s'',''%s'',''%s'',''%s'',''%s'',%.2f,%s,''%s'',''%s'',''%s'',%.2f,''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName, nType,
            nPayment, nVal, FDM.SQLServerNow, gSysParam.FUserID, nMemo, sFlag_Yes,nPrice,nStockName,nAcceptNum,nPayingUnit,nPayingMan]);
    FDM.ExecuteSQL(nStr);

    if (nLimit > 0) and (
       not SaveCustomerCredit(nCusID, '回款时冲减', -nLimit, Now)) then
    begin
      nStr := '发生未知错误,导致冲减客户[ %s ]信用操作失败.' + #13#10 +
              '请手动调整该客户信用额度.';
      nStr := Format(nStr, [nCusName]);
      ShowDlg(nStr, sHint);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;

    {$IFDEF SendMsgInOutMoney}
    nStr := ' Select S_Name From %s Where S_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_Salesman, nSaleMan]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) then
    begin
      nSaleManName := Fields[0].AsString;
    end;
    if nPrice > 0 then
      nData := '业务员: '+nSaleManName+' 客户名称: '+nCusName+' 入金金额: '+FloatToStr(nVal)+' 付款方式: '+ nPayment +' 详情: '+nStockName
    else
      nData := '业务员: '+nSaleManName+' 客户名称: '+nCusName+' 入金金额: '+FloatToStr(nVal);

    SaveCustomerPaymentEvent(nCusID,nData,sFlag_DepCaiWu,sFlag_Solution_OK,sFlag_DepXiaoShou);
    {$ENDIF}
    
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//财务收款向销售部门电脑推送消息
procedure SaveCustomerPaymentEvent(const nSID,nEvent,
      nFrom,nSolution,nDepartment: string);
var
  nStr:string;
  nEID:string;
begin
  try
    nEID := nSID + FormatDateTime('YYYYMMDD',Now);
    nStr := 'Delete From %s Where E_ID=''%s''';
    nStr := Format(nStr, [sTable_ManualEvent, nEID]);

    FDM.ExecuteSQL(nStr);

    nStr := MakeSQLByStr([
        SF('E_ID', nEID),
        SF('E_Key', ''),
        SF('E_From', nFrom),
        SF('E_Event', nEvent),
        SF('E_Solution', nSolution),
        SF('E_Departmen', nDepartment),
        SF('E_Date', sField_SQLServer_Now, sfVal)
        ], sTable_ManualEvent, '', True);
    FDM.ExecuteSQL(nStr);
  except
    on E: Exception do
    begin
      WriteLog(e.message);
    end;
  end;
end;


//Desc: 保存nCusID的一次回款记录
function SaveCustomerKPPayment(const nCusID,nCusName,nSaleMan: string;
 const nType,nPayment,nMemo: string; const nMoney: Double;
 const nPrice: Double; const nStockName: string;
 const nAcceptNum: string; const nPayingUnit: string;
 const nPayingMan: string;
 const nCredit: Boolean): Boolean;
var nStr, nData,nSaleManName : string;
    nBool: Boolean;
    nVal,nLimit: Double;
begin
  Result := False;
  nVal := Float2Float(nMoney, cPrecision, False);
  //adjust float value

  {$IFNDEF NoCheckOnPayment}
  if nVal < 0 then
  begin
    nLimit := GetCustomerValidMoney(nCusID, False);
    //get money value
    
    if (nLimit <= 0) or (nLimit < -nVal) then
    begin
      nStr := '客户: %s ' + #13#10#13#10 +
              '当前余额为[ %.2f ]元,无法支出[ %.2f ]元.';
      nStr := Format(nStr, [nCusName, nLimit, -nVal]);
      
      ShowDlg(nStr, sHint);
      Exit;
    end;
  end;
  {$ENDIF}

  nLimit := 0;
  //no limit

  if nCredit and (nVal > 0) and IsAutoPayCredit then
  begin
    nStr := 'Select A_CreditLimit From %s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nCusID]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) and (Fields[0].AsFloat > 0) then
    begin
      if FloatRelation(nVal, Fields[0].AsFloat, rtGreater) then
           nLimit := Float2Float(Fields[0].AsFloat, cPrecision, False)
      else nLimit := nVal;

      nStr := '客户[ %s ]当前信用额度为[ %.2f ]元,是否冲减?' +
              #32#32#13#10#13#10 + '点击"是"将降低[ %.2f ]元的额度.';
      nStr := Format(nStr, [nCusName, Fields[0].AsFloat, nLimit]);

      if not QueryDlg(nStr, sAsk) then
        nLimit := 0;
      //xxxxx
    end;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_InMoney=A_InMoney+%.2f Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,' +
            'M_Type,M_Payment,M_Money,M_Date,M_Man,M_Memo,M_RuZhang,M_Price,M_PriceStock,M_AcceptNum,M_PayingUnit,M_PayingMan) ' +
            'Values(''%s'',''%s'',''%s'',''%s'',''%s'',%.2f,%s,''%s'',''%s'',''%s'',%.2f,''%s'',''%s'',''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName, nType,
            nPayment, nVal, FDM.SQLServerNow, gSysParam.FUserID, nMemo,sFlag_No,nPrice,nStockName,nAcceptNum,nPayingUnit,nPayingMan]);
    FDM.ExecuteSQL(nStr);

    if (nLimit > 0) and (
       not SaveCustomerCredit(nCusID, '回款时冲减', -nLimit, Now)) then
    begin
      nStr := '发生未知错误,导致冲减客户[ %s ]信用操作失败.' + #13#10 +
              '请手动调整该客户信用额度.';
      nStr := Format(nStr, [nCusName]);
      ShowDlg(nStr, sHint);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    
    {$IFDEF SendMsgInOutMoney}
    nStr := ' Select S_Name From %s Where S_ID = ''%s'' ';
    nStr := Format(nStr, [sTable_Salesman, nSaleMan]);

    with FDM.QueryTemp(nStr) do
    if (RecordCount > 0) then
    begin
      nSaleManName := Fields[0].AsString;
    end;
    if nPrice > 0 then
      nData := '业务员: '+nSaleManName+' 客户名称: '+nCusName+' 入金金额: '+FloatToStr(nVal)+' 付款方式: '+ nPayment +' 详情: '+nStockName
    else
      nData := '业务员: '+nSaleManName+' 客户名称: '+nCusName+' 入金金额: '+FloatToStr(nVal);
    SaveCustomerPaymentEvent(nCusID,nData,sFlag_DepKaiPiao,sFlag_Solution_OK,sFlag_DepXiaoShou);
    {$ENDIF}

    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 保存nCusID的一次授信记录
function SaveCustomerCredit(const nCusID,nMemo: string; const nCredit: Double;
 const nEndTime: TDateTime): Boolean;
var nStr: string;
    nVal: Double;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nVal := Float2Float(nCredit, cPrecision, False);
    //adjust float value

    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_CreditVerify]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
         nStr := Fields[0].AsString
    else nStr := sFlag_No; 

    if nStr = sFlag_Yes then //需审核
    begin
      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', FDM.SQLServerNow, sfVal),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Memo',nMemo)
              ], sTable_CusCredit, '', True);
      FDM.ExecuteSQL(nStr);
    end else
    begin
      nStr := MakeSQLByStr([SF('C_CusID', nCusID),
              SF('C_Money', nVal, sfVal),
              SF('C_Man', gSysParam.FUserID),
              SF('C_Date', FDM.SQLServerNow, sfVal),
              SF('C_End', DateTime2Str(nEndTime)),
              SF('C_Verify', sFlag_Yes),
              SF('C_VerMan', gSysParam.FUserID),
              SF('C_VerDate', FDM.SQLServerNow, sfVal),
              SF('C_Memo',nMemo)
              ], sTable_CusCredit, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set A_CreditLimit=A_CreditLimit+%.2f ' +
              'Where A_CID=''%s''';
      nStr := Format(nStr, [sTable_CusAccount, nVal, nCusID]);
      FDM.ExecuteSQL(nStr);
    end;

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Date: 2014-09-14
//Parm: 客户编号
//Desc: 验证nCusID是否有足够的钱,或信用没有过期
function IsCustomerCreditValid(const nCusID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_CustomerHasMoney, nCusID, '', @nOut) then
       Result := nOut.FData = sFlag_Yes
  else Result := False;
end;

//Date: 2014-10-13
//Desc: 同步业务员到DL系统
function SyncRemoteSaleMan: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncSaleMan, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: 同步用户到DL系统
function SyncRemoteCustomer: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncCustomer, '', '', @nOut);
end;

//Desc: 同步供应商到DL系统
function SyncRemoteProviders: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncProvider, '', '', @nOut);
end;

//Date: 2014-10-13
//Desc: 同步原材料到DL系统
function SyncRemoteMeterails: Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_SyncMaterails, '', '', @nOut);
end;

//Date: 2014-09-25
//Parm: 车牌号
//Desc: 获取nTruck的称皮记录
function GetTruckPoundItem(const nTruck: string;
 var nPoundData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetTruckPoundData, nTruck, '', @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nPoundData);
  //xxxxx
end;

//Date: 2014-09-25
//Parm: 称重数据
//Desc: 保存nData称重数据
function SaveTruckPoundItem(const nTunnel: PPTTunnelItem;
 const nData: TLadingBillItems;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessCommand(cBC_SaveTruckPoundData, nStr, '', @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  nList := TStringList.Create;
  try
    {$IFDEF CapturePictureEx}
    CapturePictureEx(nTunnel, nLogin, nList);
    {$ELSE}
    CapturePicture(nTunnel, nList);
    //capture file
    {$ENDIF}

    for nIdx:=0 to nList.Count - 1 do
      SavePicture(nOut.FData, nData[0].FTruck,
                              nData[0].FStockName, nList[nIdx]);
    //save file
  finally
    nList.Free;
  end;
end;

//Date: 2014-10-02
//Parm: 通道号
//Desc: 读取nTunnel读头上的卡号
function ReadPoundCard(const nTunnel: string; var nReader: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //卡号

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, '', @nOut) then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

//Date: 2018-04-27
//Parm: 通道号
//Desc: 读取nTunnel读头上的卡号(电子标签)
function ReadPoundCardEx(var nReader: string;
    const nTunnel: string; nReadOnly: String = ''): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  nReader:= '';
  //卡号

  if CallBusinessHardware(cBC_GetPoundCard, nTunnel, nReadOnly, @nOut)  then
  begin
    Result := Trim(nOut.FData);
    nReader:= Trim(nOut.FExtParam);
  end;
end;

//Date: 2017/5/18
//Parm: 车牌号码
//Desc: 获取车辆在用的电子标签
function GetTruckRealLabel(const nTruck: string): string;
var nStr: string;
begin
  Result := '';
  //默认允许

  nStr := 'Select Top 1 T_Card From %s ' +
          'Where T_Truck=''%s'' And T_CardUse=''%s'' And T_Card Is not NULL';
  nStr := Format(nStr, [sTable_Truck, nTruck, sFlag_Yes]);
  //选择该车提一条有电子标签的记录

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString;
end;

//------------------------------------------------------------------------------
//Date: 2014-10-01
//Parm: 通道;车辆
//Desc: 读取车辆队列数据
function LoadTruckQueue(var nLines: TZTLineItems; var nTrucks: TZTTruckItems;
 const nRefreshLine: Boolean): Boolean;
var nIdx: Integer;
    nSLine,nSTruck: string;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    if nRefreshLine then
         nSLine := sFlag_Yes
    else nSLine := sFlag_No;

    Result := CallBusinessHardware(cBC_GetQueueData, nSLine, '', @nOut);
    if not Result then Exit;

    nListA.Text := PackerDecodeStr(nOut.FData);
    nSLine := nListA.Values['Lines'];
    nSTruck := nListA.Values['Trucks'];

    nListA.Text := PackerDecodeStr(nSLine);
    SetLength(nLines, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nLines[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FID       := Values['ID'];
      FName     := Values['Name'];
      FStock    := Values['Stock'];
      FValid    := Values['Valid'] <> sFlag_No;
      FPrinterOK:= Values['Printer'] <> sFlag_No;

      if IsNumber(Values['Weight'], False) then
           FWeight := StrToInt(Values['Weight'])
      else FWeight := 1;
    end;

    nListA.Text := PackerDecodeStr(nSTruck);
    SetLength(nTrucks, nListA.Count);

    for nIdx:=0 to nListA.Count - 1 do
    with nTrucks[nIdx],nListB do
    begin
      nListB.Text := PackerDecodeStr(nListA[nIdx]);
      FTruck    := Values['Truck'];
      FLine     := Values['Line'];
      FBill     := Values['Bill'];

      if IsNumber(Values['Value'], True) then
           FValue := StrToFloat(Values['Value'])
      else FValue := 0;

      FInFact   := Values['InFact'] = sFlag_Yes;
      FIsRun    := Values['IsRun'] = sFlag_Yes;
           
      if IsNumber(Values['Dai'], False) then
           FDai := StrToInt(Values['Dai'])
      else FDai := 0;

      if IsNumber(Values['Total'], False) then
           FTotal := StrToInt(Values['Total'])
      else FTotal := 0;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;
end;

//Date: 2014-10-01
//Parm: 通道号;启停标识
//Desc: 启停nTunnel通道的喷码机
procedure PrinterEnable(const nTunnel: string; const nEnable: Boolean);
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nEnable then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  CallBusinessHardware(cBC_PrinterEnable, nTunnel, nStr, @nOut);
end;

//Date: 2014-10-07
//Parm: 调度模式
//Desc: 切换系统调度模式为nMode
function ChangeDispatchMode(const nMode: Byte): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ChangeDispatchMode, IntToStr(nMode), '',
            @nOut);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 纸卡是否需要审核
function IsZhiKaNeedVerify: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_ZhiKaVerify)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 是否打印纸卡
function IsPrintZK: Boolean;
var nStr: string;
begin
  nStr := 'Select D_Value From $T Where D_Name=''$N'' and D_Memo=''$M''';
  nStr := MacroValue(nStr, [MI('$T', sTable_SysDict), MI('$N', sFlag_SysParam),
                           MI('$M', sFlag_PrintZK)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsString = sFlag_Yes
  else Result := False;
end;

//Desc: 删除编号为nZID的纸卡
function DeleteZhiKa(const nZID: string): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Delete From %s Where Z_ID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKa, nZID]);
    Result := FDM.ExecuteSQL(nStr) > 0;

    nStr := 'Delete From %s Where D_ZID=''%s''';
    nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set M_ZID=M_ZID+''_d'' Where M_ZID=''%s''';
    nStr := Format(nStr, [sTable_InOutMoney, nZID]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    //commit if need
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//Desc: 载入nZID的信息到nList中,并返回查询数据集
function LoadZhiKaInfo(const nZID: string; const nList: TcxMCListBox;
 var nHint: string): TDataset;
var nStr: string;
begin
  nStr := 'Select zk.*,sm.S_Name,cus.C_Name From $ZK zk ' +
          ' Left Join $SM sm On sm.S_ID=zk.Z_SaleMan ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          'Where Z_ID=''$ID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
             MI('$Con', sTable_SaleContract), MI('$SM', sTable_Salesman),
             MI('$Cus', sTable_Customer), MI('$ID', nZID)]);
  //xxxxx

  nList.Clear;
  Result := FDM.QueryTemp(nStr);

  if Result.RecordCount = 1 then
  with nList.Items,Result do
  begin
    Add('纸卡编号:' + nList.Delimiter + FieldByName('Z_ID').AsString);
    Add('业务人员:' + nList.Delimiter + FieldByName('S_Name').AsString+ ' ');
    Add('客户名称:' + nList.Delimiter + FieldByName('C_Name').AsString + ' ');
    Add('项目名称:' + nList.Delimiter + FieldByName('Z_Project').AsString + ' ');
    
    nStr := DateTime2Str(FieldByName('Z_Date').AsDateTime);
    Add('办卡时间:' + nList.Delimiter + nStr);
  end else
  begin
    Result := nil;
    nHint := '纸卡已无效';
  end;
end;

//Date: 2014-09-14
//Parm: 纸卡号;是否限提
//Desc: 获取nZhiKa的可用金哦
function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean): Double;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetZhiKaMoney, nZhiKa, '', @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    nFixMoney := nOut.FExtParam = sFlag_Yes;
  end else Result := 0;
end;

//Desc: 获取nCID用户的可用金额,包含信用额或净额
function GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nCredit: PDouble): Double;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut) then
  begin
    Result := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
end;

function VerifyTruckLicense(const nReader: string; nBill: TLadingBillItem;
                         var nMsg, nPos: string): Boolean;
var nStr, nDept: string;
    nNeedManu, nUpdate: Boolean;
    nTruck, nEvent, nPicName: string;
    nLastTime: TDateTime;
begin
  Result := False;
  nPos := sFlag_DepBangFang;
  nNeedManu := False;
  nDept := '';
  nTruck := nBill.Ftruck;

  nStr := ' Select D_Value From %s Where D_Name=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_EnableTruck]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;

      if nNeedManu then
      begin
        nMsg := '读卡器[ %s ]车牌识别已启用.';
        nMsg := Format(nMsg, [nReader]);
      end
      else
      begin
        nMsg := '读卡器[ %s ]车牌识别已关闭.';
        nMsg := Format(nMsg, [nReader]);
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      nMsg := '读卡器[ %s ]未配置车牌识别.';
      nMsg := Format(nMsg, [nReader]);
      Exit;
    end;
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_TruckInNeedManu,nPos]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nNeedManu := FieldByName('D_Value').AsString = sFlag_Yes;

      if nNeedManu then
      begin
        nMsg := '读卡器[ %s ]绑定岗位[ %s ]干预规则:人工干预已启用.';
        nMsg := Format(nMsg, [nReader, nPos]);
      end
      else
      begin
        nMsg := '读卡器[ %s ]绑定岗位[ %s ]干预规则:人工干预已关闭.';
        nMsg := Format(nMsg, [nReader, nPos]);
        Result := True;
        Exit;
      end;
    end
    else
    begin
      Result := True;
      nMsg := '读卡器[ %s ]绑定岗位[ %s ]未配置干预规则,无法进行车牌识别.';
      nMsg := Format(nMsg, [nReader, nPos]);
      Exit;
    end;
  end;

  nStr := 'Select T_LastTime From %s Where T_Truck=''%s''  ';
  nStr := Format(nStr, [sTable_Truck, nTruck]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then
    begin
      if not nNeedManu then
        Result := True;
      Exit;
    end;

    nLastTime := FieldByName('T_LastTime').AsDateTime;
    WriteLog('识别时间'+DateTimeToStr(nLastTime));
    WriteLog('当前时间'+DateTimeToStr(Now));
    WriteLog('时间差'+FloatToStr(Now-nlastTime));
    if Now - nLastTime <= 0.02 then
    begin
      Result := True;
      nMsg := '车辆[ %s ]车牌识别成功,抓拍车牌号:[ %s ]';
      nMsg := Format(nMsg, [nTruck,nTruck]);
      Exit;
    end;
    //车牌识别成功
  end;

  nStr := 'Select * From %s Where E_ID=''%s''';
  nStr := Format(nStr, [sTable_ManualEvent, nBill.FID+sFlag_ManualE]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if FieldByName('E_Result').AsString = 'N' then
      begin
        nMsg := '车辆[ %s ]车牌识别失败,管理员禁止';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      if FieldByName('E_Result').AsString = 'Y' then
      begin
        Result := True;
        nMsg := '车辆[ %s ]车牌识别失败,管理员允许';
        nMsg := Format(nMsg, [nTruck]);
        Exit;
      end;
      nUpdate := True;
    end
    else
    begin
      nMsg := '车辆[ %s ]车牌识别失败';
      nMsg := Format(nMsg, [nTruck]);
      nUpdate := False;
      if not nNeedManu then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  nEvent := '车辆[ %s ]车牌识别失败';
  nEvent := Format(nEvent, [nTruck]);

  nStr := SF('E_ID', nBill.FID+sFlag_ManualE);
  nStr := MakeSQLByStr([
          SF('E_ID', nBill.FID+sFlag_ManualE),
          SF('E_Key', nPicName),
          SF('E_From', nPos),
          SF('E_Result', 'Null', sfVal),

          SF('E_Event', nEvent),
          SF('E_Solution', sFlag_Solution_YN),
          SF('E_Departmen', nDept),
          SF('E_Date', sField_SQLServer_Now, sfVal)
          ], sTable_ManualEvent, nStr, (not nUpdate));
  //xxxxx
  FDM.ExecuteSQL(nStr);
end;

function GetTruckIsQueue(const nTruck: string): Boolean;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := False;
  //默认不允许
  nStr := ' Select T_InQueue From %s Where T_Truck=''%s'' and T_InQueue Is Not Null ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

function GetTruckIsOut(const nTruck: string): Boolean;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := False;
  //默认不允许
  nStr := ' Select T_InQueue From %s Where T_Truck=''%s'' and T_InQueue Is Not Null and isnull(T_Valid,''Y'') = ''N'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

//Date: 2014-10-16
//Parm: 品种列表(s1,s2..)
//Desc: 验证nStocks是否可以发货
function IsStockValid(const nStocks: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_CheckStockValid, nStocks, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存交货单,返回交货单号列表
function SaveBill(const nBillData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessSaleBill(cBC_SaveBills, nBillData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nBillID单据
function DeleteBill(const nBill: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_DeleteBill, nBill, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单;新车牌
//Desc: 修改nBill的车牌为nTruck.
function ChangeLadingTruckNo(const nBill,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_ModifyBillTruck, nBill, nTruck, @nOut);
end;

//Date: 2014-09-30
//Parm: 交货单;纸卡
//Desc: 将nBill调拨给nNewZK的客户
function BillSaleAdjust(const nBill, nNewZK: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaleAdjust, nBill, nNewZK, @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetBillCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Sale;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2016-12-30
//Parm: 磁卡号;车牌号
//Desc: 为nTruck办理厂内零售磁卡
function SaveBillLSCard(const nCard,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillLSCard, nCard, nTruck, @nOut);
end;

//Date: 2017-01-03
//Parm: 客户编号;计划列表
//Desc: 读取nCusID的销售计划
function LoadSalePlan(const nCusID: string;var nPlans: TSalePlanItems): Boolean;
var nIdx: Integer;
    nListA,nListB: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_LoadSalePlan, nCusID, '', @nOut);
  if not Result then Exit;

  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := DecodeBase64(nOut.FData);
    SetLength(nPlans, nListA.Count);

    for nIdx:=0 to nListA.Count-1 do
    begin
      nListB.Text := DecodeBase64(nListA[nIdx]);
      with nPlans[nIdx] do
      begin
        FSelected := False;
        FOrderNo := nListB.Values['billno'];
        FInterID := nListB.Values['inter'];
        FEntryID := nListB.Values['entry'];
        
        FStockID := nListB.Values['id'];
        FStockName := nListB.Values['name'];
        FTruck := nListB.Values['truck'];
        FValue := StrToFloat(nListB.Values['value']);
      end;
    end;
  finally
    nListA.Free;
    nListB.Free;
  end;   
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveBillCard(const nBill, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_SaveBillCard, nBill, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutBillCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetLadingBills(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表;磅站通道
//Desc: 保存nPost岗位上的交货单数据
function SaveLadingBills(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      {$IFDEF CapturePictureEx}
      CapturePictureEx(nTunnel, nLogin, nList);
      {$ELSE}
      CapturePicture(nTunnel, nList);
      //capture file
      {$ENDIF}

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm: 
//Desc: 保存采购申请单
function SaveOrderBase(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrderBase, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

function DeleteOrderBase(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrderBase, nOrder, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存采购单,返回采购单号列表
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-15
//Parm: 交货单号
//Desc: 删除nBillID单据
function DeleteOrder(const nOrder: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_DeleteOrder, nOrder, '', @nOut);
end;

//Date: 2014-09-17
//Parm: 交货单;车牌号;校验制卡开关
//Desc: 为nBill交货单制卡
function SetOrderCard(const nOrder,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nOrder;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_Provide;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutOrderCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_LogOffOrderCard, nCard, '', @nOut);
end;

//Date: 2014-09-15
//Parm: 交货单;新车牌
//Desc: 修改nOrder的车牌为nTruck.
function ChangeOrderTruckNo(const nOrder,nTruck: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_ModifyBillTruck, nOrder, nTruck, @nOut);
end;

//Date: 2014-09-17
//Parm: 磁卡号;岗位;交货单列表
//Desc: 获取nPost岗位上磁卡为nCard的交货单列表
function GetPurchaseOrders(const nCard,nPost: string;
 var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

//Date: 2014-09-18
//Parm: 岗位;交货单列表;磅站通道
//Desc: 保存nPost岗位上的交货单数据
function SavePurchaseOrders(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      {$IFDEF CapturePictureEx}
      CapturePictureEx(nTunnel, nLogin, nList);
      {$ELSE}
      CapturePicture(nTunnel, nList);
      //capture file
      {$ENDIF}

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end;
end;


//Date: 2014-09-17
//Parm: 交货单项; MCListBox;分隔符
//Desc: 将nItem载入nMC
procedure LoadBillItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('车牌号码:%s %s', [nDelimiter, FTruck]));
    Add(Format('当前状态:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('交货单号:%s %s', [nDelimiter, FId]));
    Add(Format('交货数量:%s %.3f 吨', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '袋装' else nStr := '散装';

    Add(Format('品种类型:%s %s', [nDelimiter, nStr]));
    Add(Format('品种名称:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('提货磁卡:%s %s', [nDelimiter, FCard]));
    Add(Format('单据类型:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('客户名称:%s %s', [nDelimiter, FCusName]));
  end;
end;

//Date: 2014-09-17
//Parm: 交货单项; MCListBox;分隔符
//Desc: 将nItem载入nMC
procedure LoadOrderItemToMC(const nItem: TLadingBillItem; const nMC: TStrings;
 const nDelimiter: string);
var nStr: string;
begin
  with nItem,nMC do
  begin
    Clear;
    Add(Format('车牌号码:%s %s', [nDelimiter, FTruck]));
    Add(Format('当前状态:%s %s', [nDelimiter, TruckStatusToStr(FStatus)]));

    Add(Format('%s ', [nDelimiter]));
    Add(Format('采购单号:%s %s', [nDelimiter, FZhiKa]));
//    Add(Format('交货数量:%s %.3f 吨', [nDelimiter, FValue]));
    if FType = sFlag_Dai then nStr := '袋装' else nStr := '散装';

    Add(Format('品种类型:%s %s', [nDelimiter, nStr]));
    Add(Format('品种名称:%s %s', [nDelimiter, FStockName]));
    
    Add(Format('%s ', [nDelimiter]));
    Add(Format('送货磁卡:%s %s', [nDelimiter, FCard]));
    Add(Format('单据类型:%s %s', [nDelimiter, BillTypeToStr(FIsVIP)]));
    Add(Format('供 应 商:%s %s', [nDelimiter, FCusName]));
  end;
end;

//------------------------------------------------------------------------------
//Desc: 每批次最大量
function GetHYMaxValue: Double;
var nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsFloat
  else Result := 0;
end;

//Desc: 获取nNo水泥编号的已开量
function GetHYValueByStockNo(const nNo: string): Double;
var nStr: string;
begin
  nStr := 'Select R_SerialNo,Sum(H_Value) From %s ' +
          ' Left Join %s on H_SerialNo= R_SerialNo ' +
          'Where R_SerialNo=''%s'' Group By R_SerialNo';
  nStr := Format(nStr, [sTable_StockRecord, sTable_StockHuaYan, nNo]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[1].AsFloat
  else Result := -1;
end;

//Desc: 检测nWeek是否存在或过期
function IsWeekValid(const nWeek: string; var nHint: string): Boolean;
var nStr: string;
begin
  nStr := 'Select W_End,$Now From $W Where W_NO=''$NO''';
  nStr := MacroValue(nStr, [MI('$W', sTable_InvoiceWeek),
          MI('$Now', FDM.SQLServerNow), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsDateTime + 1 > Fields[1].AsDateTime;
    if not Result then
      nHint := '该结算周期已结束';
    //xxxxx
  end else
  begin
    Result := False;
    nHint := '该结算周期已无效';
  end;
end;

//Desc: 检查nWeek是否已扎账
function IsWeekHasEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week=''$NO''';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: 检测nWeek后面的周期是否已扎账
function IsNextWeekEnable(const nWeek: string): Boolean;
var nStr: string;
begin
  nStr := 'Select Top 1 * From $Req Where R_Week In ' +
          '( Select W_NO From $W Where W_Begin > (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO''))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  Result := FDM.QueryTemp(nStr).RecordCount > 0;
end;

//Desc: 检测nWee前面的周期是否已结算完成
function IsPreWeekOver(const nWeek: string): Integer;
var nStr: string;
begin
  nStr := 'Select Count(*) From $Req Where (R_ReqValue<>R_KValue) And ' +
          '(R_Week In ( Select W_NO From $W Where W_Begin < (' +
          '  Select Top 1 W_Begin From $W Where W_NO=''$NO'')))';
  nStr := MacroValue(nStr, [MI('$Req', sTable_InvoiceReq),
          MI('$W', sTable_InvoiceWeek), MI('$NO', nWeek)]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
       Result := Fields[0].AsInteger
  else Result := 0;
end;

//Desc: 保存用户补偿金
function SaveCompensation(const nSaleMan,nCusID,nCusName,nPayment,nMemo: string;
 const nMoney: Double): Boolean;
var nStr: string;
    nBool: Boolean;
begin
  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Update %s Set A_Compensation=A_Compensation+%s Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FloatToStr(nMoney), nCusID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Insert Into %s(M_SaleMan,M_CusID,M_CusName,M_Type,M_Payment,' +
            'M_Money,M_Date,M_Man,M_Memo) Values(''%s'',''%s'',''%s'',' +
            '''%s'',''%s'',%s,%s,''%s'',''%s'')';
    nStr := Format(nStr, [sTable_InOutMoney, nSaleMan, nCusID, nCusName,
            sFlag_MoneyFanHuan, nPayment, FloatToStr(nMoney),
            FDM.SQLServerNow, gSysParam.FUserID, nMemo]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
    Result := True;
  except
    Result := False;
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 打印标识为nID的销售合同
procedure PrintSaleContractReport(const nID: string; const nAsk: Boolean);
var nStr: string;
    nParam: TReportParamItem;
begin
  if nAsk then
  begin
    nStr := '是否要打印销售合同?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select sc.*,S_Name,C_Name From $SC sc ' +
          '  Left Join $SM sm On sm.S_ID=sc.C_SaleMan ' +
          '  Left Join $Cus cus On cus.C_ID=sc.C_Customer ' +
          'Where sc.C_ID=''$ID''';

  nStr := MacroValue(nStr, [MI('$SC', sTable_SaleContract),
          MI('$SM', sTable_Salesman), MI('$Cus', sTable_Customer),
          MI('$ID', nID)]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s] 的销售合同已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where E_CID=''%s''';
  nStr := Format(nStr, [sTable_SContractExt, nID]);
  FDM.QuerySQL(nStr);

  nStr := gPath + sReportDir + 'SaleContract.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
end;

//Desc: 打印纸卡
function PrintZhiKaReport(const nZID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印纸卡?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select zk.*,C_Name,S_Name From %s zk ' +
          ' Left Join %s cus on cus.C_ID=zk.Z_Customer' +
          ' Left Join %s sm on sm.S_ID=zk.Z_SaleMan ' +
          'Where Z_ID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKa, sTable_Customer, sTable_Salesman, nZID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '纸卡号为[ %s ] 的记录已无效';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := 'Select * From %s Where D_ZID=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, nZID]);
  if FDM.QuerySQL(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的纸卡无明细';
    nStr := Format(nStr, [nZID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ZhiKa.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.Dataset2.DataSet := FDM.SqlQuery;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印收据
function PrintShouJuReport(const nSID: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印收据?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where R_ID=%s';
  nStr := Format(nStr, [sTable_SysShouJu, nSID]);
  
  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '凭单号为[ %s ] 的收据已无效!!';
    nStr := Format(nStr, [nSID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'ShouJu.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印提货单
function PrintBillReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印提货单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nBill := AdjustListStrFormat(nBill, '''', True, ',', False);
  //添加引号

  nStr := ' Select b.*,c.*,d.Z_Name, '+
          ' Case When ((L_HdOrderId Is Null) or (L_HdOrderId = '''')) Then L_MValue Else ' +
          ' ( Select sum(isnull(L_MValue,0)) from S_Bill where L_HdOrderId = b.L_HdOrderId) End as L_MValueEx, '+
          ' Case When ((L_HdOrderId Is Null) or (L_HdOrderId = '''')) Then L_PValue Else ' +
          ' ( Select sum(isnull(L_PValue,0)) from S_Bill where L_HdOrderId = b.L_HdOrderId) End as L_PValueEx, '+
          ' Case When ((L_HdOrderId Is Null) or (L_HdOrderId = '''')) Then L_Value Else ' +
          ' ( Select sum(isnull(L_Value,0)) from S_Bill where L_HdOrderId = b.L_HdOrderId) End as L_ValueEx '+
          ' From %s b,%s c,%s d Where '+
          ' b.L_Truck=c.T_Truck and b.L_ZhiKa=d.Z_ID and L_ID In(%s)';
  nStr := Format(nStr, [sTable_Bill,sTable_Truck,sTable_ZhiKa, nBill]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的记录已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'LadingBill.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;


//Date: 2012-4-1
//Parm: 采购单号;提示;数据对象;打印机
//Desc: 打印nOrder采购单号
function PrintOrderReport(const nOrder: string;  const nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印采购单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  if nMul then
    nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID In (%s)'
  else
    nStr := 'Select * From %s oo Inner Join %s od on oo.O_ID=od.D_OID Where D_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, sTable_OrderDtl, nOrder]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '采购单[ %s ] 已无效!!';
    nStr := Format(nStr, [nOrder]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\PurchaseOrder.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2012-4-15
//Parm: 过磅单号;是否询问;是否批量打印
//Desc: 打印nPound过磅记录
function PrintPoundReport(const nPound: string; nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  if nMul then
    nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
            ' (P_MValue - isnull(P_KZValue,0)) as P_MValueEx, '+
            ' (P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeightEx '+
            ' From %s P Where P_ID In (%s)'
  else
    nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
            ' (P_MValue - isnull(P_KZValue,0)) as P_MValueEx, '+
            ' (P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeightEx '+
            ' From %s P Where P_ID=''%s'' ';

  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '称重记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2012-4-15
//Parm: 过磅单号;是否询问;是否批量打印
//Desc: 打印nPound过磅记录
function PrintPoundReportKS(const nPound: string; nAsk: Boolean;
                          const nMul: Boolean = False): Boolean;
var nStr: string;
    nParam: TReportParamItem;
    FNum1,Fnum2,FNum3: Double;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过磅单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s ';
  nStr := Format(nStr, [sTable_KSKD]);
  FDM.QueryTemp(nStr);
  with FDM.SqlTemp do
  begin
    if (RecordCount < 1) then
    begin
      FNum1 := 0;
      FNum2 := 0;
      FNum3 := 0;
    end
    else
    begin
      FNum1 := FieldByName('P_Num1').AsFloat;
      FNum2 := FieldByName('P_Num2').AsFloat;
      FNum3 := FieldByName('P_Num3').AsFloat;
    end;
  end;

  if nMul then
  begin
    if FNum1 > 0 then
    begin
      nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
                ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = P.P_MID) = ''Y'' then ' +
                ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then P_PValue+'+Floattostr(FNum2)+
                ' else (P_MValue-'+Floattostr(FNum3)+') end) '+
                ' else (P_MValue-isnull(P_KZValue,0)) end P_MValueEx,  '+
                ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = P.P_MID) = ''Y'' then ' +
                ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then '+Floattostr(FNum2)+
                ' else (P_MValue-P_PValue-'+Floattostr(FNum3)+') end) '+
                ' else (P_MValue-P_PValue-isnull(P_KZValue,0)) end P_NetWeightEx, '+
                ' (Select D_KD from P_OrderDtl where D_ID = P.P_Order) as D_KD '+
                ' From %s P Where P_ID In (%s)';
    end
    else
    begin
      nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
              ' (P_MValue - isnull(P_KZValue,0)) as P_MValueEx, '+
              ' (P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeightEx, '+
              ' (Select D_KD from P_OrderDtl where D_ID = P.P_Order) as D_KD '+
              ' From %s P Where P_ID In (%s)';
    end;
  end
  else
  begin
    if FNum1 > 0 then
    begin
      nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
                ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = P.P_MID) = ''Y'' then ' +
                ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then P_PValue+'+Floattostr(FNum2)+
                ' else (P_MValue-'+Floattostr(FNum3)+') end) '+
                ' else (P_MValue-isnull(P_KZValue,0)) end P_MValueEx,  '+
                ' case When (Select isnull(M_AutoKZ,''N'') from P_Materails where M_ID = P.P_MID) = ''Y'' then ' +
                ' (case When (P_MValue-P_PValue) >= '+Floattostr(FNum1)+' then '+Floattostr(FNum2)+
                ' else (P_MValue-P_PValue-'+Floattostr(FNum3)+') end) '+
                ' else (P_MValue-P_PValue-isnull(P_KZValue,0)) end P_NetWeightEx,  '+
                ' (Select D_KD from P_OrderDtl where D_ID = P.P_Order) as D_KD '+
                ' From %s P Where P_ID=''%s'' ';
    end
    else
    begin
      nStr := ' Select *, (Select L_HYDan from S_Bill where L_ID = P.P_Bill) L_HYDan, '+
              ' (P_MValue - isnull(P_KZValue,0)) as P_MValueEx, '+
              ' (P_MValue-P_PValue-isnull(P_KZValue,0)) As P_NetWeightEx, '+
              ' (Select D_KD from P_OrderDtl where D_ID = P.P_Order) as D_KD '+
              ' From %s P Where P_ID=''%s'' ';
    end;
  end;

  nStr := Format(nStr, [sTable_PoundLog, nPound]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '称重记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nPound]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'Pound.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := 'Update %s Set P_PrintNum=P_PrintNum+1 Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_PoundLog, nPound]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Date: 2017-01-11
//Parm: 采购单号;是否弹出询问
//Desc: 打印采购验收单
function PrintRCOrderReport(const nID: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印入厂单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where O_ID=''%s''';
  nStr := Format(nStr, [sTable_Order, nID]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '入厂单[ %s ] 已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\ProvideRC.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 获取nStock品种的报表文件
function GetReportFileByStock(const nStock: string): string;
var nStr: string;
begin
  Result := '';
  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HYReportName, nStock]);
  with FDM.QuerySQL(nStr) do
  if RecordCount > 0 then
  begin
    Result := gPath + sReportDir + Fields[0].AsString;
  end;
end;

//Desc: 打印标识为nHID的化验单
function PrintHuaYanReport(nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印化验单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  nHID := AdjustListStrFormat(nHID, '''', True, ',', False);
  //添加引号

  {nStr := ' Select sr.*, sb.*,C_Name,(case when isnull(sb.L_HYPrintNum,0) > 0 THEN ''补'' ELSE '''' END) AS IsBuDan From $SR sr ' +
          ' ,($SB) sb , $Cus cus  ' +
          ' Where cus.C_ID = sb.L_CusID and sr.R_SerialNo = sb.L_HYDan and sb.L_ID = ''$ID'' ';
  //xxxxx
  nStr := MacroValue(nStr, [MI('$SR', sTable_StockRecord),
          MI('$SB', sTable_Bill),MI('$Cus', sTable_Customer), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('L_StockNo').AsString;}

  nSR := 'Select * From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name, convert(varchar(100),(H_BillDate-4),23) as H_QYDate From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := FDM.SqlTemp.FieldByName('P_Stock').AsString;
  nStr := GetReportFileByStock(nStr);

  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;

  if Result  then
  begin
    nStr := ' UPDate %s Set L_HyPrintCount = L_HyPrintCount + 1 Where L_ID '+
    ' in (Select Distinct H_Reporter From S_StockHuaYan where H_ID in (%s) ) ';
    nStr := Format(nStr, [sTable_Bill, nHID]);
    FDM.ExecuteSQL(nStr);
  end;
end;

//Desc: 打印标识为nID的合格证
function PrintHeGeReport(const nHID: string; const nAsk: Boolean): Boolean;
var nStr,nSR: string;
begin
  if nAsk then
  begin
    Result := True;
    nStr := '是否要打印合格证?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end else Result := False;

  {$IFDEF HeGeZhengSimpleData}
  nSR := 'Select * From %s hy ' +
         '  Left Join %s b On b.L_ID=hy.H_Reporter ' +
         '  Left Join %s sp On sp.P_Stock=b.L_StockName ' +
         'Where hy.H_ID in (%s)';
  nStr := Format(nSR, [sTable_StockHuaYan, sTable_Bill, sTable_StockParam, nHID]);
  {$ELSE}
  nSR := 'Select R_SerialNo,P_Stock,P_Name,P_QLevel From %s sr ' +
         ' Left Join %s sp on sp.P_ID=sr.R_PID';
  nSR := Format(nSR, [sTable_StockRecord, sTable_StockParam]);

  nStr := 'Select hy.*,sr.*,C_Name From $HY hy ' +
          ' Left Join $Cus cus on cus.C_ID=hy.H_Custom' +
          ' Left Join ($SR) sr on sr.R_SerialNo=H_SerialNo ' +
          'Where H_ID in ($ID)';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$HY', sTable_StockHuaYan),
          MI('$Cus', sTable_Customer), MI('$SR', nSR), MI('$ID', nHID)]);
  //xxxxx
  {$ENDIF}

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '编号为[ %s ] 的化验单记录已无效!!';
    nStr := Format(nStr, [nHID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'HeGeZheng.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2016-8-10
//Parm: 交货单号;提示
//Desc: 打印nBill单号的发运单
function PrintBillFYDReport(const nBill: string;  const nAsk: Boolean): Boolean;
var nStr: string;
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印现场发运单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s  Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '交货单[ %s ] 已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\BillFYD.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Desc: 打印过路单
function PrintBillLoadReport(nBill: string; const nAsk: Boolean): Boolean;
var nStr: string; 
    nDS: TDataSet;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印过路单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s  Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill]);

  nDS := FDM.QueryTemp(nStr);
  if not Assigned(nDS) then Exit;

  if nDS.RecordCount < 1 then
  begin
    nStr := '交货单[ %s ] 已无效!!';
    nStr := Format(nStr, [nBill]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + 'Report\BillLoad.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;                                                 

//Date: 2015/1/18
//Parm: 车牌号；电子标签；是否启用；旧电子标签
//Desc: 读标签是否成功；新的电子标签
function SetTruckRFIDCard(nTruck: string; var nRFIDCard: string;
  var nIsUse: string; nOldCard: string=''): Boolean;
var nP: TFormCommandParam;
begin
  nP.FParamA := nTruck;
  nP.FParamB := nOldCard;
  nP.FParamC := nIsUse;
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);

  nRFIDCard := nP.FParamB;
  nIsUse    := nP.FParamC;
  Result    := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2016/8/7
//Parm: 车牌号
//Desc: 查看车辆上次过磅时间间隔
function GetTruckLastTime(const nTruck: string): Integer;
var nStr: string;
    nNow, nPDate, nMDate: TDateTime;
begin
  Result := -1;
  //默认允许

  nStr := 'Select Top 1 %s as T_Now,P_PDate,P_MDate ' +
          'From %s Where P_Truck=''%s'' Order By P_ID Desc';
  nStr := Format(nStr, [sField_SQLServer_Now, sTable_PoundLog, nTruck]);
  //选择最后一次过磅

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nNow   := FieldByName('T_Now').AsDateTime;
    nPDate := FieldByName('P_PDate').AsDateTime;
    nMDate := FieldByName('P_MDate').AsDateTime;

    if nPDate > nMDate then
         Result := Trunc((nNow - nPDate) * 24 * 60 * 60)
    else Result := Trunc((nNow - nMDate) * 24 * 60 * 60);
  end;
end;

function IsStrictSanValue: Boolean;
var nSQL: string;
begin
  Result := False;

  nSQL := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nSQL := Format(nSQL, [sTable_SysDict, sFlag_SysParam, sFlag_StrictSanVal]);

  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
end;

function GetFQValueByStockNo(const nStock: string): Double;
var nSQL: string;
begin
  Result := 0;
  if nStock = '' then Exit;

  nSQL := 'Select Sum(L_Value) From %s Where L_Seal=''%s'' ' +
          'and L_Date > GetDate() - 30';   //一个月内的总计
  nSQL := Format(nSQL, [sTable_Bill, nStock]);
  with FDM.QueryTemp(nSQL) do
  if RecordCount > 0 then
    Result := Fields[0].AsFloat;
end;

function VerifyFQSumValue: Boolean;
var nStr: string;
begin
  Result := False;
  //默认不判断

  nStr := 'Select D_Value From %s Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_VerifyFQValue]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
    Result := Fields[0].AsString = sFlag_Yes;
end;

function OpenDoorByReader(const nReader: string; nType: string = 'Y'): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_OpenDoorByReader, nReader, nType,
            @nOut, False);
end;

//------------------------------------------------------------------------------
//获取客户注册信息
function getCustomerInfo(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_getCustomerInfo, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//客户与微信账号绑定
function get_Bindfunc(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_get_Bindfunc, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//发送消息
function send_event_msg(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_send_event_msg, nData, '', '', @nOut,false) then
       Result := nOut.FData
  else Result := '';
end;

//新增商城用户
function edit_shopclients(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_edit_shopclients, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//添加商品
function edit_shopgoods(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_edit_shopgoods, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//获取订单信息
function get_shoporders(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_get_shoporders, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//更新订单状态
function complete_shoporders(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_complete_shoporders, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//获取车辆审核信息
function getAuditTruck(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_GetAuditTruck, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//车辆审核结果上传
function UpLoadAuditTruck(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_UpLoadAuditTruck, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//下载图片
function DownLoadPic(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_DownLoadPic, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//------------------------------------------------------------------------------
//根据车牌号获取订单
function GetshoporderbyTruck(const nData: string): string;
var nOut: TWorkerWebChatData;
begin
  if CallBusinessWechat(cBC_WX_get_shoporderbyTruck, nData, '', '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017-11-22
//Parm: 交货单号,商城申请单
//Desc: 插入删除推送消息
procedure SaveWebOrderDelMsg(const nLID, nBillType: string);
var nStr, nWebOrderID: string;
    nBool: Boolean;
begin
  nStr := 'Select WOM_WebOrderID From %s Where WOM_LID=''%s'' ';
  nStr := Format(nStr, [sTable_WebOrderMatch, nLID]);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount <= 0 then
      Exit;
    //手工单
    nWebOrderID := Fields[0].AsString;
  end;

  nBool := FDM.ADOConn.InTransaction;
  if not nBool then FDM.ADOConn.BeginTrans;
  try
    nStr := 'Insert Into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,' +
            'WOM_MsgType,WOM_BillType) Values(''%s'',''%s'',%d,' +
            '%d,''%s'')';
    nStr := Format(nStr, [sTable_WebOrderMatch, nWebOrderID, nLID, c_WeChatStatusDeleted,
            cSendWeChatMsgType_DelBill, nBillType]);
    FDM.ExecuteSQL(nStr);

    if not nBool then
      FDM.ADOConn.CommitTrans;
  except
    if not nBool then FDM.ADOConn.RollbackTrans;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017-10-17
//Parm: 车牌号;保留长度
//Desc: 将nTruck整合为长度为nLen的字符串
function GetTruckNO(const nTruck: WideString; const nLong: Integer): string;
var nStr: string;
    nIdx,nLen,nPos: Integer;
begin
  nPos := 0;
  nLen := 0;

  for nIdx:=Length(nTruck) downto 1 do
  begin
    nStr := nTruck[nIdx];
    nLen := nLen + Length(nStr);

    if nLen >= nLong then Break;
    nPos := nIdx;
  end;

  Result := Copy(nTruck, nPos, Length(nTruck));
  nIdx := nLong - Length(Result);
  Result := Result + StringOfChar(' ', nIdx);
end;

function GetValue(const nValue: Double): string;
var nStr: string;
begin
  nStr := Format('      %.2f', [nValue]);
  Result := Copy(nStr, Length(nStr) - 6 + 1, 6);
end;

//验证车辆电子标签
function IsEleCardVaid(const nTruckNo: string): Boolean;
var
  nSql:string;
begin
  Result := True;

  nSql := 'select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruckNo]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      if FieldByName('T_CardUse').AsString = sFlag_Yes then//启用
      begin
        if (FieldByName('T_Card').AsString = '') and (FieldByName('T_Card2').AsString = '') then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

//验证车辆电子标签
function IsEleCardVaidEx(const nTruckNo: string): Boolean;
var
  nSql:string;
begin
  Result := False;

  nSql := 'select * from %s where T_Truck = ''%s'' ';
  nSql := Format(nSql,[sTable_Truck,nTruckNo]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      if FieldByName('T_CardUse').AsString = sFlag_Yes then//启用
      begin
        if (FieldByName('T_Card').AsString <> '') or (FieldByName('T_Card2').AsString <> '') then
        begin
          Result := True;
        end;
      end;
    end;
  end;
end;

//验证物料是否需要输入流水
function IfStockHasLs(const nStockNo: string): Boolean;
var
  nSql:string;
begin
  Result := False;

  nSql := 'select * from %s where M_ID = ''%s'' ';
  nSql := Format(nSql,[sTable_Materails,nStockNo]);

  with FDM.QueryTemp(nSql) do
  begin
    if recordcount>0 then
    begin
      if FieldByName('M_HasLs').AsString = sFlag_Yes then//启用
      begin
        Result := True;
      end;
    end;
  end;
end;

//车辆是否存在未完成采购单
function IFHasOrder(const nTruck: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr :='select D_ID from %s where D_Status <> ''%s'' and D_Truck =''%s'' ';
  nStr := Format(nStr, [sTable_OrderDtl, sFlag_TruckOut, nTruck]);
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    Result := True;
  end;
end;

procedure ProberShowTxt(const nTunnel, nText: string);
var nOut: TWorkerBusinessCommand;
begin
  CallBusinessHardware(cBC_ShowTxt, nTunnel, nText, @nOut);
end;

//Desc: 生成销售特定字段数据(特定使用)
function MakeSaleViewData: Boolean;
var nID: string;
    nStr: string;
    nList : TStrings;
    nIdx, nInt, nMax: Integer;
    nDataView: string;
begin
  nMax := 49;
  nDataView := ' (40 + 899*rand() / 100) ';

  nStr := 'Select D_Value, D_Memo From %s ' +
          'Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_DataView]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nInt := Abs(Fields[1].AsInteger - Fields[0].AsInteger) * 100 - 1;
    nDataView := ' (' + Fields[0].AsString + ' + ' + IntToStr(nInt) + '*rand() / 100) ';
  end;

  nList := TStringList.Create;
  try
    nStr := 'Select top 1000 L_ID , L_MValue From %s ' +
            'Where L_MValueView is null';
    nStr := Format(nStr, [sTable_Bill]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nID := Fields[0].AsString;

        if Fields[1].AsString = '' then
        begin
          Next;
          Continue;
        end;

        if Fields[1].AsFloat <= nMax then
        begin
          nStr := 'Update %s Set L_MValueview = L_MValue Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, nID]);
          nList.Add(nStr);

          nStr := 'Update %s Set L_Valueview = L_Value Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, nID]);
          nList.Add(nStr);

          nStr := 'Update a set a.P_MValueView = b.L_MValueView,'+
                  ' a.P_ValueView = b.L_ValueView from %s a, %s b'+
                  ' where  a.P_Bill = b.L_ID and b.L_ID=''%s''';
          nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
          nList.Add(nStr);
        end
        else
        begin
          nStr := 'Update %s Set L_MValueview = %s Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, nDataView, nID]);
          nList.Add(nStr);

          nStr := 'Update %s Set L_Valueview = L_MValueView - L_PValue Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, nID]);
          nList.Add(nStr);

          nStr := 'Update a set a.P_MValueView = b.L_MValueView,'+
                  ' a.P_ValueView = b.L_ValueView from %s a, %s b'+
                  ' where  a.P_Bill = b.L_ID and b.L_ID=''%s''';
          nStr := Format(nStr, [sTable_PoundLog, sTable_Bill, nID]);
          nList.Add(nStr);
        end;
        Next;
      end;
    end;

    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to nList.Count - 1 do
      begin
        WriteLog('数据调整SQL:' + nList[nIdx]);
        FDM.ExecuteSQL(nList[nIdx]);
      end;
      FDM.ADOConn.CommitTrans;
    except
      On E: Exception do
      begin
        Result := False;
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Desc: 生成采购特定字段数据(特定使用)
function MakeOrderViewData: Boolean;
var nID: string;
    nStr: string;
    nList : TStrings;
    nIdx, nInt, nMax: Integer;
    nDataView: string;
begin
  nMax := 49;
  nDataView := ' (40 + 899*rand() / 100) ';

  nStr := 'Select D_Value, D_Memo From %s ' +
          'Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_DataView]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    nMax := Fields[1].AsInteger;
    nInt := Abs(Fields[1].AsInteger - Fields[0].AsInteger) * 100 - 1;
    nDataView := ' (' + Fields[0].AsString + ' + ' + IntToStr(nInt) + '*rand() / 100) ';
  end;

  nList := TStringList.Create;
  try
    nStr := 'Select top 1000 D_ID ,D_MValue From %s ' +
            'Where D_MValueView is null';
    nStr := Format(nStr, [sTable_OrderDtl]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        nID := Fields[0].AsString;

        if Fields[1].AsString = '' then
        begin
          Next;
          Continue;
        end;

        if Fields[1].AsFloat <= nMax then
        begin
          nStr := 'Update %s Set D_MValueview = D_MValue Where D_ID=''%s''';
          nStr := Format(nStr, [sTable_OrderDtl, nID]);
          nList.Add(nStr);

          nStr := 'Update %s Set D_Valueview = D_MValue - D_PValue Where D_ID=''%s''';
          nStr := Format(nStr, [sTable_OrderDtl, nID]);
          nList.Add(nStr);

          nStr := 'Update a set a.P_MValueView = b.D_MValueView,'+
                  ' a.P_ValueView = b.D_ValueView from %s a, %s b'+
                  ' where  a.P_Order = b.D_ID and b.D_ID=''%s''';
          nStr := Format(nStr, [sTable_PoundLog, sTable_OrderDtl, nID]);
          nList.Add(nStr);
        end
        else
        begin
          nStr := 'Update %s Set D_MValueview = %s Where D_ID=''%s''';
          nStr := Format(nStr, [sTable_OrderDtl, nDataView, nID]);
          nList.Add(nStr);

          nStr := 'Update %s Set D_Valueview = D_MValueView - D_PValue Where D_ID=''%s''';
          nStr := Format(nStr, [sTable_OrderDtl, nID]);
          nList.Add(nStr);

          nStr := 'Update a set a.P_MValueView = b.D_MValueView,'+
                  ' a.P_ValueView = b.D_ValueView from %s a, %s b'+
                  ' where  a.P_Order = b.D_ID and b.D_ID=''%s''';
          nStr := Format(nStr, [sTable_PoundLog, sTable_OrderDtl, nID]);
          nList.Add(nStr);
        end;
        Next;
      end;
    end;

    FDM.ADOConn.BeginTrans;
    try
      for nIdx:=0 to nList.Count - 1 do
      begin
        WriteLog('数据调整SQL:' + nList[nIdx]);
        FDM.ExecuteSQL(nList[nIdx]);
      end;
      FDM.ADOConn.CommitTrans;
    except
      On E: Exception do
      begin
        Result := False;
        FDM.ADOConn.RollbackTrans;
        WriteLog(E.Message);
      end;
    end;
  finally
    nList.Free;
  end;
end;

//Date: 2017-09-22
//Parm: 开短倒数据
//Desc: 保存短倒单,返回短倒单号列表
function SaveDDBases(const nDDData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessDuanDao(cBC_SaveBills, nDDData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2017-09-22
//Parm: 短倒单号
//Desc: 删除nBillID单据
function DeleteDDBase(const nBase: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_DeleteBill, nBase, '', @nOut);
end;

//Date: 2017-09-22
//Parm: 磁卡号
//Desc: 注销nCard
function LogoutDDCard(const nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_LogoffCard, nCard, '', @nOut);
end;

//Date: 2019-07-22
//Parm: 短倒编号,磁卡号
//Desc: 绑定磁卡nCard
function SaveDDCard(const nBID, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_SaveBillCard, nBID, nCard, @nOut);
end;

//Date: 2017-09-22
//Parm: 磁卡号;岗位;短倒单列表
//Desc: 获取nPost岗位上磁卡为nCard的短倒单列表
function GetDuanDaoItems(const nCard,nPost: string;
  var nBills: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
    AnalyseBillItems(nOut.FData, nBills);
  //xxxxx
end;

function DeleteDDDetial(const nDID: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessDuanDao(cBC_DeleteOrder, nDID, '', @nOut);
end;

function SetDDCard(const nBill,nTruck: string; nVerify: Boolean): Boolean;
var nStr: string;
    nP: TFormCommandParam;
begin
  Result := True;
  if nVerify then
  begin
    nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ViaBillCard]);

    with FDM.QueryTemp(nStr) do
     if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
    //no need do card
  end;

  nP.FParamA := nBill;
  nP.FParamB := nTruck;
  nP.FParamC := sFlag_DuanDao;
  CreateBaseFormItem(cFI_FormMakeCard, '', @nP);
  Result := (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK);
end;

//Date: 2017-09-22
//Parm: 短倒ID;是否打印
//Desc: 打印短倒明细
function PrintDuanDaoReport(const nID: string; nAsk: Boolean): Boolean;
var nStr: string;
    nParam: TReportParamItem;
begin
  Result := False;

  if nAsk then
  begin
    nStr := '是否要打印短倒单?';
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'Select * From %s Where T_ID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, nID]);

  if FDM.QueryTemp(nStr).RecordCount < 1 then
  begin
    nStr := '短倒记录[ %s ] 已无效!!';
    nStr := Format(nStr, [nID]);
    ShowMsg(nStr, sHint); Exit;
  end;

  nStr := gPath + sReportDir + 'DuanDao.fr3';
  if not FDR.LoadReportFile(nStr) then
  begin
    nStr := '无法正确加载报表文件';
    ShowMsg(nStr, sHint); Exit;
  end;

  nParam.FName := 'UserName';
  nParam.FValue := gSysParam.FUserID;
  FDR.AddParamItem(nParam);

  nParam.FName := 'Company';
  nParam.FValue := gSysParam.FHintText;
  FDR.AddParamItem(nParam);

  FDR.Dataset1.DataSet := FDM.SqlTemp;
  FDR.ShowReport;
  Result := FDR.PrintSuccess;
end;

//Date: 2017-09-22
//Parm: 岗位;短倒单列表;磅站通道
//Desc: 保存nPost岗位上的短倒单数据
function SaveDuanDaoItems(const nPost: string; const nData: TLadingBillItems;
 const nTunnel: PPTTunnelItem;const nLogin: Integer): Boolean;
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessDuanDao(cBC_SavePostBills, nStr, nPost, @nOut);
  if (not Result) or (nOut.FData = '') then Exit;

  if Assigned(nTunnel) then //过磅称重
  begin
    nList := TStringList.Create;
    try
      {$IFDEF CapturePictureEx}
      CapturePictureEx(nTunnel, nLogin, nList);
      {$ELSE}
      CapturePicture(nTunnel, nList);
      //capture file
      {$ENDIF}

      for nIdx:=0 to nList.Count - 1 do
        SavePicture(nOut.FData, nData[0].FTruck,
                                nData[0].FStockName, nList[nIdx]);
      //save file
    finally
      nList.Free;
    end;
  end; 
end;

//Date: 2018-09-25
//Parm: 通道;登陆ID;列表
//Desc: 抓拍nTunnel的图像
procedure CapturePictureEx(const nTunnel: PPTTunnelItem;
                         const nLogin: Integer; nList: TStrings);
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nPic: NET_DVR_JPEGPARA;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  nList.Clear;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera
  if nLogin <= -1 then Exit;

  WriteLog(nTunneL.FID + '开始抓拍');
  if not DirectoryExists(gSysParam.FPicPath) then
    ForceDirectories(gSysParam.FPicPath);
  //new dir

  if gSysParam.FPicBase >= 100 then
    gSysParam.FPicBase := 0;
  //clear buffer

  try

    nPic.wPicSize := nTunnel.FCamera.FPicSize;
    nPic.wPicQuality := nTunnel.FCamera.FPicQuality;

    for nIdx:=Low(nTunnel.FCameraTunnels) to High(nTunnel.FCameraTunnels) do
    begin
      if nTunnel.FCameraTunnels[nIdx] = MaxByte then continue;
      //invalid

      for nInt:=1 to cRetry do
      begin
        nStr := MakePicName();
        //file path

        gCameraNetSDKMgr.NET_DVR_CaptureJPEGPicture(nLogin,
                                   nTunnel.FCameraTunnels[nIdx],
                                   nPic, nStr);
        //capture pic

        nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;

        if nErr = 0 then
        begin
          WriteLog('通道'+IntToStr(nTunnel.FCameraTunnels[nIdx])+'抓拍成功');
          nList.Add(nStr);
          Break;
        end;

        if nIdx = cRetry then
        begin
          nStr := '抓拍图像[ %s.%d ]失败,错误码: %d';
          nStr := Format(nStr, [nTunnel.FCamera.FHost,
                   nTunnel.FCameraTunnels[nIdx], nErr]);
          WriteLog(nStr);
        end;
      end;
    end;
  except
  end;
end;

function InitCapture(const nTunnel: PPTTunnelItem; var nLogin: Integer): Boolean;
const
  cRetry = 2;
  //重试次数
var nStr: string;
    nIdx,nInt: Integer;
    nErr: Integer;
    nInfo: TNET_DVR_DEVICEINFO;
begin
  Result := False;
  if not Assigned(nTunnel.FCamera) then Exit;
  //not camera

  try
    nLogin := -1;
    gCameraNetSDKMgr.NET_DVR_SetDevType(nTunnel.FCamera.FType);
    //xxxxx

    gCameraNetSDKMgr.NET_DVR_Init;
    //xxxxx

    for nIdx:=1 to cRetry do
    begin
      nLogin := gCameraNetSDKMgr.NET_DVR_Login(nTunnel.FCamera.FHost,
                   nTunnel.FCamera.FPort,
                   nTunnel.FCamera.FUser,
                   nTunnel.FCamera.FPwd, nInfo);
      //to login

      nErr := gCameraNetSDKMgr.NET_DVR_GetLastError;
      if nErr = 0 then break;

      if nIdx = cRetry then
      begin
        nStr := '登录摄像机[ %s.%d ]失败,错误码: %d';
        nStr := Format(nStr, [nTunnel.FCamera.FHost, nTunnel.FCamera.FPort, nErr]);
        WriteLog(nStr);
        if nLogin > -1 then
         gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
        gCameraNetSDKMgr.NET_DVR_Cleanup();
        Exit;
      end;
    end;
    Result := True;
  except

  end;
end;

function FreeCapture(nLogin: Integer): Boolean;
begin
  Result := False;
  try
    if nLogin > -1 then
     gCameraNetSDKMgr.NET_DVR_Logout(nLogin);
    gCameraNetSDKMgr.NET_DVR_Cleanup();

    Result := True;
  except

  end;
end;

function IsSealInfoDone(const nCardUse : string; nBill: TLadingBillItem): Boolean;
var nStr : string ;
    nCount, nInt: Integer;
    nVerifySeal: Boolean;//是否校验
begin
  Result := True;
  nVerifySeal := False;

  if nCardUse <> sFlag_Sale then
    Exit;

  if nBill.FType <> sFlag_San then
    Exit;

  if nBill.FNextStatus <> sFlag_TruckBFM then
    Exit;

  nCount := 1;

  nStr := 'Select D_Value,D_ParamB From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SealCount]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      nCount := Fields[0].AsInteger;
      nVerifySeal := Fields[1].AsString = sFlag_Yes;
    end;
  end;

  if not nVerifySeal then
    Exit;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_NoSealStock]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        if nBill.FStockNo = Fields[0].AsString then
          Exit;
        Next;
      end;
    end;
  end;

  nInt := 0;

  nStr := 'Select L_Seal1,L_Seal2,L_Seal3 From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, nBill.FID]);
  //xxxxx

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount > 0 then
    begin
      if Trim(Fields[0].AsString) <> '' then
       Inc(nInt);
      if Trim(Fields[1].AsString) <> '' then
       Inc(nInt);
      if Trim(Fields[2].AsString) <> '' then
       Inc(nInt);
    end;
  end;

  if nInt < nCount then
  begin
    WriteLog('提货单号' + nBill.FID + '铅封信息不完整,禁止过磅');
    Result := False;
  end;
end;

function ShowLedText(nTunnel, nStr:string):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessHardware(cBC_ShowLedTxt, nTunnel, nStr,
            @nOut, False);
end;

//Date: 2017/6/14
//Parm: 身份证号的前17位
//Desc: 获取身份证号校验码
function GetIDCardNumCheckCode(nIDCardNum: string): string;
const
  cWIArray: Array[0..16] of Integer = (7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2);
  cModCode: array [0..10] of string = ('1','0','X','9','8','7','6','5','4','3','2');
var
  nIdx, nSum, nModResult: Integer;
begin
  Result := '';

  if Length(nIDCardNum) < 17 then
    Exit;

  nSum := 0;
  for nIdx := 0 to Length(cWIArray) - 1 do
  begin
    nSum := nSum + StrToInt(nIDCardNum[nIdx + 1]) * cWIArray[nIdx];
  end;  
  nModResult := nSum mod 11;
  Result := cModCode[nModResult];
end;

//Date: 2019-07-04
//Parm: 采购物料号;订单号
//Desc: 获取采购物料物流部验收状态
function GetWlbYsStatus(const nStockNo,nOrderId: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetWlbYsStatus, nStockNo, nOrderId, @nOut);
end;

procedure CheckAllCusMoney;
var
  nStr: string;
begin
  //校正出金
  nStr := ' update Sys_CustomerAccount set A_OutMoney = L_Money From( ' +
    ' Select Sum(L_Money) L_Money, L_CusID from ( ' +
    ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID from S_Bill ' +
    ' where L_OutFact Is not Null ) t Group by L_CusID) b where A_CID = b.L_CusID ';
  FDM.ExecuteSQL(nStr);

  //校正冻结资金
  nStr := ' update Sys_CustomerAccount set A_FreezeMoney = L_Money From( ' +
    ' Select Sum(L_Money) L_Money, L_CusID from ( ' +
    ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID from S_Bill ' +
    ' where L_OutFact Is  Null ) t Group by L_CusID) b where A_CID = b.L_CusID ';
  FDM.ExecuteSQL(nStr);

  //校正冻结资金
  nStr := ' update Sys_CustomerAccount set A_FreezeMoney = 0  where ' +
    ' A_CID  not in (select L_CusID from S_Bill    ' +
    ' where L_OutFact Is Null Group by L_CusID ) ';
  FDM.ExecuteSQL(nStr);
end;

procedure CheckZhiKaXTMoney;
var
  nStr: string;
begin
  //校正纸卡付款方式
  nStr := ' update S_ZhiKa set Z_PayType = (select D_Index from Sys_Dict ' +
          ' where D_Name= ''PaymentItem'' and D_Value=Z_Payment)';
  FDM.ExecuteSQL(nStr);
  //校正出入金付款方式
  nStr := ' update Sys_CustomerInOutMoney set M_PayType = '+
          ' (select D_Index from Sys_Dict where D_Name= ''PaymentItem2'' and D_Value=M_Payment)';
  FDM.ExecuteSQL(nStr);

  //初始化
  nStr := ' update S_ZhiKa set Z_FixedMoney = 0';
  FDM.ExecuteSQL(nStr);

  //校正纸卡限提1
  nStr := ' update S_ZhiKa set Z_FixedMoney  = M_Money From( ' +
          ' Select Sum(isnull(M_Money,0)) M_Money, M_CusID,M_PayType from ( ' +
          ' select M_Money, M_CusID,M_PayType from Sys_CustomerInOutMoney ' +
          '  ) t Group by M_CusID,M_PayType) b where Z_Customer = b.M_CusID and Z_PayType= M_PayType ';
  FDM.ExecuteSQL(nStr);
  //校正纸卡限提2
  nStr := ' update S_ZhiKa set Z_FixedMoney  = Z_FixedMoney-L_Money From( ' +
          ' Select isnull(Sum(L_Money),0) L_Money, L_CusID,L_ZhiKa from ( ' +
          ' select isnull(L_Value,0) * isnull(L_Price,0) as L_Money, L_CusID,L_ZhiKa from S_Bill ' +
          '  ) t Group by L_CusID,L_ZhiKa) b where Z_Customer = b.L_CusID and Z_ID= b.L_ZhiKa ';
  FDM.ExecuteSQL(nStr);
  //校正纸卡限提标识1
  nStr := ' update S_ZhiKa set Z_OnlyMoney= ''Y'' where Z_Customer ' +
          ' not in (select A_CID from Sys_CustomerAccount ' +
          ' where A_CreditLimit >0 Group by A_CID ) ';
  FDM.ExecuteSQL(nStr);
  //校正纸卡限提标识2
  nStr := ' update S_ZhiKa set Z_OnlyMoney= NULL where Z_Customer ' +
	        ' in (select A_CID from Sys_CustomerAccount ' +
          ' where A_CreditLimit >0 Group by A_CID ) ';
  FDM.ExecuteSQL(nStr);
end;

end.
