//----------------------------------- ͨ�� -------------------------------------
{.$DEFINE DEBUG}
//����ģʽ

{.$DEFINE TrialVersion}
//���ð汾

{$DEFINE UseReport}
//����֧��

{.$DEFINE RandomID}
//ʹ��������

{$DEFINE cxLibrary42}
//Ver4.2���뻷��
{$DEFINE RemObjects}
{.$DEFINE RO_v90}
//XE.Lib����RO֧��

{$DEFINE EnableBackupDB}
//�������ݿ�֧��
{.$DEFINE EnableDoubleDB}
//˫���ݿ�֧��

//---------------------------------- �м�� ------------------------------------
{.$DEFINE ClientMon}
//�����ػ��ͻ���

{$DEFINE HardMon}
//����Ӳ���ػ�

{.$DEFINE GenRODL}
//����RODL��Դ

{$DEFINE COM_MIT}
//����ϵͳģʽ

//ͨ���м��
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //�������ݿ�֧��
  {.$DEFINE ChannelPool}
  //����ͨ��֧��
  {.$DEFINE AutoChannel}
  //����ͨ��ƽ��
  {.$DEFINE SAP}
  //����SAP֧��
  {.$DEFINE ClientMon}
  //֧���ػ�����
{$ENDIF}

//--------------------------------- �ض�ϵͳ -----------------------------------
{.$DEFINE COMMON}
//ͨ�ð汾

{$DEFINE XXMD}
//�ض�ϵͳ

//�����ϵ�
{$IFDEF XXMD}
  {$DEFINE COMMON}
  {$DEFINE HYRFID201}
  //�����ͷ
  {$DEFINE TTCEM100}
  //�Զ��տ�Ʊ��
  {$DEFINE MITTruckProber}
  //�������м������
  {$DEFINE MultiReplay}
  //������Ӧ��ģʽ
  {.$DEFINE PrintHYEach}
  //�泵�����鵥
  {.$DEFINE PrintHeGeZheng}
  {$DEFINE PrintHuaYanDan}
  //�泵����ʱ��ϸ�֤�����鵥
  {$DEFINE BatchInHYOfBill}
  //���α����ڻ��鵥�ֶ�
  {$DEFINE SanPreHK}
  //ɢװ����ʱԤ�Ͽ�
  {.$DEFINE AutoPoundInManual}
  //�Զ������˹���Ԥ�쳣
  {$DEFINE DaiStepWuCha}
  //��װ�������
  {$DEFINE NoShowPriceChange}
  //����ʾ�۸������ʾ
  {$DEFINE NoCheckOnPayment}
  //�˿�ʱ��У���ʽ����
  {$DEFINE MicroMsg}
  //ʹ��΢��
  {$DEFINE UseCustomertMoney}
  //������ʹ�ÿͻ�������
  {$DEFINE PrintHY}
  //������ӡ���鵥
  {$DEFINE SaveHyDanEvent}
  //�������ͻ��鵥�¼�
  {.$DEFINE ForceEleCard}
  //ǿ�Ƴ������������õ��ӱ�ǩ
  {$DEFINE WxShowCusMoney}
  //΢�Ŷ���ʾ�ͻ����
  {$DEFINE CastMoney}
  //�Զ�λ�����С��λ��2λ��������
  {$DEFINE NoCheckOrderValue}
  //������ԭ���Ͽ�������鶩��ʣ����
  {$DEFINE ProberShow}
  //���췢��С��
  {$DEFINE OrderNoMulCard}
  //�ɹ���ֹһ���൥
  {$DEFINE CapturePictureEx}
  //����ץ��ģʽ��չ
  {.$DEFINE BusinessOnly}
  //����ͬһʱ��ֻ�ܽ���1��ҵ��
  {$DEFINE ForceMemo}
  //ǿ�����뱸ע
  {$DEFINE InfoOnly}
  //������ϢΨһ
  {$DEFINE AlwaysUseDate}
  //������ѯʼ��ʹ����������
  {$DEFINE AllowMultiM}
  //������ι��س�
  {$DEFINE ChangeBillWhenPriceAdjust}
  //ֽ������ʱ�޸���������ݼ۸�
  {$DEFINE UseFreight}
  //ʹ���˷�
  {$DEFINE Between2BillTime}
  //ͬһ�����ο������
 {$DEFINE UseWXServiceEx}
  //ʹ�ö���΢���м��
  {$DEFINE SaveCusMoneyByOutFact}
   //�����泵����������
  {$DEFINE UseSelectDateTime}
   //���ò�ѯ���ڰ���ʱ����
  {$DEFINE UseXHSpot}
  //ж���ص�
  {$DEFINE UseYCLHY}
  //ʹ��¼��ԭ���ϻ����¼  
 {$DEFINE TruckAutoIn}
 //�����Զ�����
 {$DEFINE SendMsgInOutMoney}
 //������շ�����Ϣ�����۲�����
 {$DEFINE NoCheckMemo}
 //�����������ע��У��
 {$DEFINE UseWebYYOrder}
 //ʹ���̳�ԤԼ�µ�
 {$DEFINE UseOrderNoPrint}
 //ԭ���ϳ�������ӡ����
 {$DEFINE UseKuangDian}
 //ԭ���Ͽ���ʹ�ÿ��
 {$DEFINE PrintHYEach}
 //�泵�����鵥
 {$DEFINE PackMachine}
  //װ����
 {.$DEFINE BasisWeight}  
 //����װ��
 {$DEFINE AutoPoundInManual} 
 //�Զ������˹���Ԥ
 {$DEFINE UseBXFontLED}
 //Ʊ��С����ʾ
{$ENDIF}