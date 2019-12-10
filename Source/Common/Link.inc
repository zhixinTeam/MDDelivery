//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境
{$DEFINE RemObjects}
{.$DEFINE RO_v90}
//XE.Lib启用RO支持

{$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {.$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE XXMD}
//特定系统

//新乡孟电
{$IFDEF XXMD}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE TTCEM100}
  //自动收卡票箱
  {$DEFINE MITTruckProber}
  //车检由中间件控制
  {$DEFINE MultiReplay}
  //计数器应答模式
  {.$DEFINE PrintHYEach}
  //随车开化验单
  {.$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //随车开单时打合格证、化验单
  {$DEFINE BatchInHYOfBill}
  //批次保存在化验单字段
  {$DEFINE SanPreHK}
  //散装开单时预合卡
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE NoShowPriceChange}
  //不显示价格调整提示
  {$DEFINE NoCheckOnPayment}
  //退款时不校验资金余额
  {$DEFINE MicroMsg}
  //使用微信
  {$DEFINE UseCustomertMoney}
  //订单量使用客户余额计算
  {$DEFINE PrintHY}
  //出厂打印化验单
  {$DEFINE SaveHyDanEvent}
  //生成推送化验单事件
  {.$DEFINE ForceEleCard}
  //强制车辆办理和启用电子标签
  {$DEFINE WxShowCusMoney}
  //微信端显示客户金额
  {$DEFINE CastMoney}
  //对吨位及金额小数位后2位四舍五入
  {$DEFINE NoCheckOrderValue}
  //自助机原材料开卡不检查订单剩余量
  {$DEFINE ProberShow}
  //车检发送小屏
  {$DEFINE OrderNoMulCard}
  //采购禁止一车多单
  {$DEFINE CapturePictureEx}
  //磅房抓拍模式扩展
  {.$DEFINE BusinessOnly}
  //车辆同一时间只能进行1种业务
  {$DEFINE ForceMemo}
  //强制输入备注
  {$DEFINE InfoOnly}
  //档案信息唯一
  {$DEFINE AlwaysUseDate}
  //报表查询始终使用日期条件
  {$DEFINE AllowMultiM}
  //允许多次过重车
  {$DEFINE ChangeBillWhenPriceAdjust}
  //纸卡调价时修改已提货单据价格
  {$DEFINE UseFreight}
  //使用运费
  {$DEFINE Between2BillTime}
  //同一车两次开单间隔
 {$DEFINE UseWXServiceEx}
  //使用二期微信中间件
  {$DEFINE SaveCusMoneyByOutFact}
   //出厂随车保存可用余额
  {$DEFINE UseSelectDateTime}
   //启用查询日期包含时分秒
  {$DEFINE UseXHSpot}
  //卸货地点
  {$DEFINE UseYCLHY}
  //使用录入原材料化验记录  
 {$DEFINE TruckAutoIn}
 //车辆自动进厂
 {$DEFINE SendMsgInOutMoney}
 //货款回收发送消息到销售部电脑
 {$DEFINE NoCheckMemo}
 //处理待办事项备注不校验
 {$DEFINE UseWebYYOrder}
 //使用商城预约下单
 {$DEFINE UseOrderNoPrint}
 //原材料出厂不打印磅单
 {$DEFINE UseKuangDian}
 //原材料开单使用矿点
 {$DEFINE PrintHYEach}
 //随车开化验单
 {$DEFINE PackMachine}
  //装车机
 {.$DEFINE BasisWeight}  
 //定量装车
 {$DEFINE AutoPoundInManual} 
 //自动过磅人工干预
 {$DEFINE UseBXFontLED}
 //票箱小屏显示
{$ENDIF}
