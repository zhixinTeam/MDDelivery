{*******************************************************************************
  ����: dmzn@ylsoft.com 2007-10-09
  ����: ��Ŀͨ�ó�,�������嵥Ԫ
*******************************************************************************}
unit USysConst;

interface

uses
  SysUtils, Classes, ComCtrls;

const
  cSBar_Date            = 0;                         //�����������
  cSBar_Time            = 1;                         //ʱ���������
  cSBar_User            = 2;                         //�û��������
  cRecMenuMax           = 5;                         //���ʹ�õ����������Ŀ��
  
  cShouJuIDLength       = 7;                         //�����վݱ�ʶ����
  cItemIconIndex        = 11;                        //Ĭ�ϵ�������б�ͼ��

const
  {*Frame ID*}
  cFI_FrameSysLog       = $0001;                     //ϵͳ��־
  cFI_FrameViewLog      = $0002;                     //������־
  cFI_FrameAuthorize    = $0003;                     //ϵͳ��Ȩ

  cFI_FrameCustomer     = $0004;                     //�ͻ�����
  cFI_FrameSalesMan     = $0005;                     //ҵ��Ա
  cFI_FrameSaleContract = $0006;                     //���ۺ�ͬ
  cFI_FrameZhiKa        = $0007;                     //����ֽ��
  cFI_FrameMakeCard     = $0012;                     //�����ſ�
  cFI_FrameBill         = $0013;                     //�������
  cFI_FrameBillQuery    = $0014;                     //������ѯ
  cFI_FrameMakeOCard    = $0015;                     //�����ɹ��ſ�
  cFI_FrameMakeLSCard   = $0016;                     //�������۴ſ�
  cFI_FrameSanPreHK     = $0017;                     //ɢװ���ǰԤ�ϵ�
  cFI_FrameAuditTruck   = $0018;                     //��˳���
  cFI_FrameBillBuDanAudit = $0019;                     //�������

  cFI_FrameShouJu       = $0020;                     //�վݲ�ѯ
  cFI_FrameZhiKaVerify  = $0021;                     //ֽ�����
  cFI_FramePayment      = $0022;                     //���ۻؿ�
  cFI_FrameCusCredit    = $0023;                     //���ù���
  cFI_FramePayMentEx    = $0024;                     //��ʱ�ؿ�

  cFI_FrameLadingDai    = $0030;                     //��װ���
  cFI_FramePoundQuery   = $0031;                     //������ѯ
  cFI_FramePoundQueryKS = $0038;                     //��ɽ������ѯ
  cFI_FramePoundQueryKZ = $0037;                     //������һ�ο���
  cFI_FrameFangHuiQuery = $0032;                     //�ŻҲ�ѯ
  cFI_FrameZhanTaiQuery = $0033;                     //ջ̨��ѯ
  cFI_FrameZTDispatch   = $0034;                     //ջ̨����
  cFI_FramePoundManual  = $0035;                     //�ֶ�����
  cFI_FramePoundAuto    = $0036;                     //�Զ�����

  cFI_FramePoundMtAuto  = $0040;                     //��ͷץ����
  cFI_FramePoundMtQuery = $0041;                     //��ͷץ���Ӳ�ѯ

  cFI_FrameStock        = $0042;                     //Ʒ�ֹ���
  cFI_FrameStockRecord  = $0043;                     //�����¼
  cFI_FrameStockHuaYan  = $0045;                     //�����鵥
  cFI_FrameStockHY_Each = $0046;                     //�泵����
  cFI_FrameBatch        = $0047;                     //���ι���

  cFI_FrameYCLStock        = $8007;                   //ԭ����Ʒ�ֹ���
  cFI_FrameYCLStockRecord  = $8008;                   //ԭ���ϼ����¼
  cFI_FrameSaletunnelQuery = $8054;                  //����ͳ��1

  cFI_FrameTruckQuery   = $0050;                     //������ѯ
  cFI_FrameCusAccountQuery = $0051;                  //�ͻ��˻�
  cFI_FrameCusInOutMoney   = $0052;                  //�������ϸ
  cFI_FrameSaleTotalQuery  = $0053;                  //�ۼƷ���
  cFI_FrameSaleDetailQuery = $0054;                  //������ϸ
  cFI_FrameZhiKaDetail  = $0055;                     //ֽ����ϸ
  cFI_FrameDispatchQuery = $0056;                    //���Ȳ�ѯ
  cFI_FrameOrderDetailQuery = $0057;                 //�ɹ���ϸ

  cFI_FrameSaleInvoice  = $0061;                     //��Ʊ����
  cFI_FrameMakeInvoice  = $0062;                     //���߷�Ʊ
  cFI_FrameInvoiceWeek  = $0063;                     //��������
  cFI_FrameSaleZZ       = $0065;                     //��������
  cFI_FrameSaleJS       = $0069;                     //���۽���

  cFI_FrameTrucks       = $0070;                     //��������
  cFI_FrameTodo         = $0071;                     //�������¼�
  cFI_FrameCrossCard    = $0072;                     //�����ſ�(ͨ�п�)

  cFI_FrameXHSpot       = $2071;                     //ж���ص�ά��
  cFI_FormXHSpot        = $2072;                     //ж���ص�༭
  cFI_FrameDriverWh     = $2073;                     //˾����Ϣά��
  cFI_FormDriverWh      = $2074;                     //˾����Ϣ�༭
  cFI_FormKDInfo        = $2075;                     //�����Ϣ�༭
  cFI_FrameKDInfo       = $2076;                     //�����Ϣά��

  cFI_FramePMaterailControl= $0077;                  //ԭ���Ͻ�������
  cFI_FormPMaterailControl= $1098;                   //ԭ���Ͻ�������

  cFI_FrameProvider     = $0102;                     //��Ӧ
  cFI_FrameProvideLog   = $0105;                     //��Ӧ��־
  cFI_FrameMaterails    = $0106;                     //ԭ����
  cFI_FrameOrder        = $0107;                     //�ɹ�����
  cFI_FrameOrderBase    = $0108;                     //�ɹ����뵥
  cFI_FrameOrderDetail  = $0109;                     //�ɹ���ϸ

  cFI_FrameWXAccount    = $0110;                     //΢���˻�
  cFI_FrameWXSendLog    = $0111;                     //������־

  cFI_FormMemo          = $1000;                     //��ע����
  cFI_FormBackup        = $1001;                     //���ݱ���
  cFI_FormRestore       = $1002;                     //���ݻָ�
  cFI_FormIncInfo       = $1003;                     //��˾��Ϣ
  cFI_FormChangePwd     = $1005;                     //�޸�����
  cFI_FormOptions       = $1102;                     //����ѡ��

  cFI_FormBaseInfo      = $1006;                     //������Ϣ
  cFI_FormCustomer      = $1007;                     //�ͻ�����
  cFI_FormSaleMan       = $1008;                     //ҵ��Ա
  cFI_FormSaleContract  = $1009;                     //���ۺ�ͬ
  cFI_FormZhiKa         = $1010;                     //ֽ������
  cFI_FormZhiKaParam    = $1011;                     //ֽ������
  cFI_FormGetZhika      = $1012;                     //ѡ��ֽ��
  cFI_FormMakeCard      = $1013;                     //�����ſ�
  cFI_FormMakeRFIDCard  = $1014;                     //�������ӱ�ǩ
  cFI_FormMakeLSCard    = $1015;                     //�������۰쿨

  cFI_FormBill          = $1016;                     //�������
  cFI_FormSanPreHK      = $1101;                     //ɢװԤ�Ͽ�
  cFI_FormDaiPD         = $2101;                     //��װƴ����
  cFI_FormShouJu        = $1017;                     //���վ�
  cFI_FormZhiKaVerify   = $1018;                     //ֽ�����
  cFI_FormCusCredit     = $1019;                     //���ñ䶯
  cFI_FormPayment       = $1020;                     //���ۻؿ�
  cFI_FormKPPayment     = $2020;                     //��Ʊ�����ۻؿ�
  cFI_FormTruckIn       = $1021;                     //��������
  cFI_FormTruckOut      = $1022;                     //��������
  cFI_FormVerifyCard    = $1023;                     //�ſ���֤
  cFI_FormAutoBFP       = $1024;                     //�Զ���Ƥ
  cFI_FormBangFangP     = $1025;                     //����Ƥ��
  cFI_FormBangFangM     = $1026;                     //����ë��
  cFI_FormLadDai        = $1027;                     //��װ���
  cFI_FormLadSan        = $1028;                     //ɢװ���
  cFI_FormJiShuQi       = $1029;                     //��������
  cFI_FormBFWuCha       = $1030;                     //�������
  cFI_FormZhiKaQuery    = $1031;                     //��Ƭ��Ϣ
  cFI_FormBuDan         = $1032;                     //���۲���
  cFI_FormZhiKaInfoExt1 = $1033;                     //ֽ����չ
  cFI_FormZhiKaInfoExt2 = $1034;                     //ֽ����չ
  cFI_FormZhiKaAdjust   = $1035;                     //ֽ������
  cFI_FormZhiKaFixMoney = $1036;                     //������
  cFI_FormSaleAdjust    = $1037;                     //���۵���
  cFI_FormEditPrice     = $1040;                     //�������
  cFI_FormGetProvider   = $1041;                     //ѡ��Ӧ��
  cFI_FormGetMeterail   = $1042;                     //ѡ��ԭ����
  cFI_FormTruckEmpty    = $1043;                     //�ճ�����
  cFI_FormReadCard      = $1044;                     //��ȡ�ſ�
  cFI_FormZTLine        = $1045;                     //װ����   

  cFI_FormGetTruck      = $1047;                     //ѡ����
  cFI_FormGetContract   = $1048;                     //ѡ���ͬ
  cFI_FormGetCustom     = $1049;                     //ѡ��ͻ�
  cFI_FormGetStockNo    = $1050;                     //ѡ����
  cFI_FormProvider      = $1051;                     //��Ӧ��
  cFI_FormMaterails     = $1052;                     //ԭ����
  cFI_FormOrder         = $1053;                     //�ɹ�����
  cFI_FormOrderBase     = $1054;                     //�ɹ�����
  cFI_FormPurchase      = $1055;                     //�ɹ�����
  cFI_FormGetPOrderBase  = $1056;                    //�ɹ�����
  cFI_FormOrderDtl      = $1057;                     //�ɹ���ϸ
  cFI_FormGetWXAccount  = $1058;                     //��ȡ�̳�ע����Ϣ

  cFI_FormBatch         = $1064;                     //���ι���
  cFI_FormStockParam    = $1065;                     //Ʒ�ֹ���
  cFI_FormStockHuaYan   = $1066;                     //�����鵥
  cFI_FormStockHY_Each  = $1067;                     //�泵����

  cFI_FormPaymentZK     = $1068;                     //ֽ���ؿ�
  cFI_FormFreezeZK      = $1069;                     //����ֽ��
  cFI_FormAdjustPrice   = $1070;                     //ֽ������

  cFI_FormTrucks        = $1071;                     //��������

  cFI_FormInvoiceWeek   = $1075;                     //��������
  cFI_FormSaleInvoice   = $1076;                     //��Ʊ����
  cFI_FormMakeInvoice   = $1077;                     //���߷�Ʊ
  cFI_FormViewInvoices  = $1078;                     //��Ʊ�б�
  cFI_FormSaleZZALL     = $1079;                     //����(ȫ��)
  cFI_FormSaleZZCus     = $1080;                     //����(�ͻ�)
  cFI_FormInvGetWeek    = $1081;                     //ѡ������
  cFI_FormInvAdjust     = $1082;                     //�޸�������

  cFI_FormAuthorize     = $1090;                     //��ȫ��֤
  cFI_FormWXAccount     = $1091;                     //΢���˻�
  cFI_FormWXSendlog     = $1092;                     //΢����־
  cFI_FormTodo          = $1093;                     //���Ԥ�¼�
  cFI_FormTodoSend      = $1094;                     //�����¼�
  cFI_FormAuditTruck    = $1095;                     //�������
  cFI_FormSealInfo      = $1096;                     //Ǧ����Ϣ¼��
  CFI_FormSearchCard    = $1157;                     //�ſ���ѯ
  CFI_FormCrossCard     = $1097;                     //ͨ�п�����

  cFI_Form_HT_SalePlan  = $1100;                     //���ۼƻ�(����)
  cFI_FrameTransBase    = $1103;                     //�̵�����
  cFI_FormTransBase     = $1104;                     //�̵�����

  cFI_FrameNotice       = $1105;                     //����֪ͨ��
  cFI_FrameDaySales     = $1106;                     //��������ϸ
  cFI_FrameMonthSales   = $1107;                     //��������ϸ
  cFI_FrameDayPrice     = $1108;                     //�����
  cFI_FrameMonthPrice   = $1109;                     //�����
  cFI_FrameAccReport    = $1110;                     //��Ʊ���
  cFI_FrameCollectMoney = $1111;                     //�ؿ��
  cFI_FrameSaleAndMoney = $1112;                     //�����ؿ��
  cFI_FrameDaySalesHj   = $1113;                     //�������ϼ�
  cFI_FrameDayReport    = $1114;                     //�ձ���
  cFI_FrameDayReport_HY = $1120;                     //�ձ��������

  cFI_FrameSalesCredit  = $1115;                     //ҵ��Ա����
  cFI_FormSalesCredit   = $1116;                     //ҵ��Ա����
  cFI_FrameSaleTotalQuery2HY = $1117;                //�������ۻ���
  cFI_FrameCusTotalMoney     = $1118;                //��������
  cFI_FrameCusReceivable     = $1119;                //Ӧ�տ���ϸ

  cFI_FrameQrySaleByMonth    = $1121;                //����ͳ����������
  cFI_FramePurchByMonth      = $1122;                //����ͳ�Ʋɹ�����

  cFI_FormPoundKZ   = $6011;                         //ԭ����һ�ο���
  cFI_FormPoundTwoKZ= $6012;                         //�������ο���

  {*Command*}
  cCmd_RefreshData      = $0002;                     //ˢ������
  cCmd_ViewSysLog       = $0003;                     //ϵͳ��־

  cCmd_ModalResult      = $1001;                     //Modal����
  cCmd_FormClose        = $1002;                     //�رմ���
  cCmd_AddData          = $1003;                     //��������
  cCmd_EditData         = $1005;                     //�޸�����
  cCmd_ViewData         = $1006;                     //�鿴����
  cCmd_GetData          = $1007;                     //ѡ������

  cSendWeChatMsgType_AddBill=1; //�������
  cSendWeChatMsgType_OutFactory=2; //��������
  cSendWeChatMsgType_Report=3; //����
  cSendWeChatMsgType_DelBill=4; //ɾ�����

  c_WeChatStatusCreateCard=0;  //�����Ѱ쿨
  c_WeChatStatusFinished=1;  //���������
  c_WeChatStatusDeleted=2;  //������ɾ��

type
  TSysParam = record
    FProgID     : string;                            //�����ʶ
    FAppTitle   : string;                            //�����������ʾ
    FMainTitle  : string;                            //���������
    FHintText   : string;                            //��ʾ�ı�
    FCopyRight  : string;                            //��������ʾ����

    FUserID     : string;                            //�û���ʶ
    FUserName   : string;                            //��ǰ�û�
    FUserPwd    : string;                            //�û�����
    FGroupID    : string;                            //������
    FIsAdmin    : Boolean;                           //�Ƿ����Ա
    FIsNormal   : Boolean;                           //�ʻ��Ƿ�����

    FRecMenuMax : integer;                           //����������
    FIconFile   : string;                            //ͼ�������ļ�
    FUsesBackDB : Boolean;                           //ʹ�ñ��ݿ�

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FMITServURL : string;                            //ҵ�����
    FHardMonURL : string;                            //Ӳ���ػ�
    FWechatURL  : string;                            //΢�ŷ���
    
    FFactNum    : string;                            //�������
    FSerialID   : string;                            //���Ա��
    FDepartment : string;                            //��������
    FIsManual   : Boolean;                           //�ֶ�����
    FAutoPound  : Boolean;                           //�Զ�����

    FPoundDaiZ  : Double;
    FPoundDaiZ_1: Double;                            //��װ�����
    FPoundDaiF  : Double;
    FPoundDaiF_1: Double;                            //��װ�����
    FDaiPercent : Boolean;                           //����������ƫ��
    FDaiWCStop  : Boolean;                           //��������װƫ��
    FPoundSanF  : Double;                            //ɢװ�����
    FPicBase    : Integer;                           //ͼƬ����
    FPicPath    : string;                            //ͼƬĿ¼
    FVoiceUser  : Integer;                           //��������
    FProberUser : Integer;                           //���������
    FEmpTruckWc : Double;                            //�ճ��������
    FIsKS       : Integer;                           //0:����ҵ��;1����ɽҵ��
    FJsWc       : Double;                            //�ɹ��������
  end;
  //ϵͳ����

  TModuleItemType = (mtFrame, mtForm);
  //ģ������

  PMenuModuleItem = ^TMenuModuleItem;
  TMenuModuleItem = record
    FMenuID: string;                                 //�˵�����
    FModule: integer;                                //ģ���ʶ
    FItemType: TModuleItemType;                      //ģ������
  end;

//------------------------------------------------------------------------------
var
  gPath: string;                                     //��������·��
  gSysParam:TSysParam;                               //���򻷾�����
  gStatusBar: TStatusBar;                            //ȫ��ʹ��״̬��
  gMenuModule: TList = nil;                          //�˵�ģ��ӳ���

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'DMZN';                      //Ĭ�ϱ�ʶ
  sAppTitle           = 'DMZN';                      //�������
  sMainCaption        = 'DMZN';                      //�����ڱ���

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = 'δ֪����';                  //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogExt             = '.log';                      //��־��չ��
  sLogField           = #9;                          //��¼�ָ���

  sImageDir           = 'Images\';                   //ͼƬĿ¼
  sReportDir          = 'Report\';                   //����Ŀ¼
  sBackupDir          = 'Backup\';                   //����Ŀ¼
  sBackupFile         = 'Bacup.idx';                 //��������
  sCameraDir          = 'Camera\';                   //ץ��Ŀ¼

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��
  sVerifyCode         = ';Verify:';                  //У������

  sFormConfig         = 'FormInfo.ini';              //��������
  sSetupSec           = 'Setup';                     //����С��
  sDBConfig           = 'DBConn.ini';                //��������
  sDBConfig_bk        = 'isbk';                      //���ݿ�

  sExportExt          = '.txt';                      //����Ĭ����չ��
  sExportFilter       = '�ı�(*.txt)|*.txt|�����ļ�(*.*)|*.*';
                                                     //������������ 

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�

implementation

//------------------------------------------------------------------------------
//Desc: ���Ӳ˵�ģ��ӳ����
procedure AddMenuModuleItem(const nMenu: string; const nModule: Integer;
 const nType: TModuleItemType = mtFrame);
var nItem: PMenuModuleItem;
begin
  New(nItem);
  gMenuModule.Add(nItem);

  nItem.FMenuID := nMenu;
  nItem.FModule := nModule;
  nItem.FItemType := nType;
end;

//Desc: �˵�ģ��ӳ���
procedure InitMenuModuleList;
begin
  gMenuModule := TList.Create;

  AddMenuModuleItem('MAIN_A01', cFI_FormIncInfo, mtForm);
  AddMenuModuleItem('MAIN_A02', cFI_FrameSysLog);
  AddMenuModuleItem('MAIN_A03', cFI_FormBackup, mtForm);
  AddMenuModuleItem('MAIN_A04', cFI_FormRestore, mtForm);
  AddMenuModuleItem('MAIN_A05', cFI_FormChangePwd, mtForm);
  AddMenuModuleItem('MAIN_A06', cFI_FormOptions, mtForm);
  AddMenuModuleItem('MAIN_A07', cFI_FrameAuthorize);
  AddMenuModuleItem('MAIN_A08', cFI_FormTodo, mtForm);
  AddMenuModuleItem('MAIN_A09', cFI_FrameTodo);

  AddMenuModuleItem('MAIN_B01', cFI_FormBaseInfo, mtForm);
  AddMenuModuleItem('MAIN_B02', cFI_FrameCustomer);
  AddMenuModuleItem('MAIN_B03', cFI_FrameSalesMan);
  AddMenuModuleItem('MAIN_B04', cFI_FrameSaleContract);
  AddMenuModuleItem('MAIN_B06', CFI_FormSearchCard, mtForm);

  AddMenuModuleItem('MAIN_C01', cFI_FrameZhiKaVerify);
  AddMenuModuleItem('MAIN_C02', cFI_FramePayment);
  AddMenuModuleItem('MAIN_C03', cFI_FrameCusCredit);
  AddMenuModuleItem('MAIN_C04', cFI_FrameSaleInvoice);
  AddMenuModuleItem('MAIN_C05', cFI_FrameMakeInvoice);
  AddMenuModuleItem('MAIN_C06', cFI_FrameInvoiceWeek);
  AddMenuModuleItem('MAIN_C07', cFI_FrameShouJu);
  AddMenuModuleItem('MAIN_C08', cFI_FrameSaleZZ);
  AddMenuModuleItem('MAIN_C09', cFI_FrameSalesCredit);
  AddMenuModuleItem('MAIN_C10', cFI_FramePaymentEx);

  AddMenuModuleItem('MAIN_D01', cFI_FormZhiKa, mtForm);
  AddMenuModuleItem('MAIN_D02', cFI_FrameMakeCard);
  AddMenuModuleItem('MAIN_D03', cFI_FormBill, mtForm);
  AddMenuModuleItem('MAIN_D04', cFI_FormBill, mtForm);
  AddMenuModuleItem('MAIN_D05', cFI_FrameZhiKa);
  AddMenuModuleItem('MAIN_D06', cFI_FrameBill);
  AddMenuModuleItem('MAIN_D08', cFI_FormTruckEmpty, mtForm);
  AddMenuModuleItem('MAIN_D09', cFI_FrameMakeLSCard);
  AddMenuModuleItem('MAIN_D10', cFI_FrameSanPreHK);
  AddMenuModuleItem('MAIN_D11', cFI_FrameAuditTruck);
  AddMenuModuleItem('MAIN_D12', cFI_FrameBillBuDanAudit);

  AddMenuModuleItem('MAIN_D13', cFI_FormKPPayment, mtForm);
  AddMenuModuleItem('MAIN_D14', cFI_FormDaiPD, mtForm);

  AddMenuModuleItem('MAIN_E01', cFI_FramePoundManual);
  AddMenuModuleItem('MAIN_E02', cFI_FramePoundAuto);
  AddMenuModuleItem('MAIN_E03', cFI_FramePoundQuery);
  AddMenuModuleItem('MAIN_E06', cFI_FramePoundMtAuto);
  AddMenuModuleItem('MAIN_E07', cFI_FramePoundMtQuery);
  AddMenuModuleItem('MAIN_E13', cFI_FramePoundQueryKS);
  
  AddMenuModuleItem('MAIN_F01', cFI_FormLadDai, mtForm);
  AddMenuModuleItem('MAIN_F03', cFI_FrameZhanTaiQuery);
  AddMenuModuleItem('MAIN_F04', cFI_FrameZTDispatch);
  AddMenuModuleItem('MAIN_F05', cFI_FormPurchase, mtForm);
  AddMenuModuleItem('MAIN_F06', cFI_FormSealInfo, mtForm);

  AddMenuModuleItem('MAIN_G01', cFI_FormLadSan, mtForm);
  AddMenuModuleItem('MAIN_G02', cFI_FrameFangHuiQuery);

  AddMenuModuleItem('MAIN_K01', cFI_FrameStock);
  AddMenuModuleItem('MAIN_K02', cFI_FrameStockRecord);
  AddMenuModuleItem('MAIN_K03', cFI_FrameStockHuaYan);
  AddMenuModuleItem('MAIN_K04', cFI_FormStockHuaYan, mtForm);
  AddMenuModuleItem('MAIN_K05', cFI_FormStockHY_Each, mtForm);
  AddMenuModuleItem('MAIN_K06', cFI_FrameStockHY_Each);
  AddMenuModuleItem('MAIN_K07', cFI_FrameBatch);
  AddMenuModuleItem('MAIN_K08', cFI_FormBatch, mtForm);
  AddMenuModuleItem('MAIN_K09', cFI_FramePoundQueryKZ);

  AddMenuModuleItem('MAIN_L01', cFI_FrameTruckQuery);
  AddMenuModuleItem('MAIN_L02', cFI_FrameCusAccountQuery);
  AddMenuModuleItem('MAIN_L03', cFI_FrameCusInOutMoney);
  AddMenuModuleItem('MAIN_L05', cFI_FrameDispatchQuery);
  AddMenuModuleItem('MAIN_L06', cFI_FrameSaleDetailQuery);
  AddMenuModuleItem('MAIN_L07', cFI_FrameSaleTotalQuery);
  AddMenuModuleItem('MAIN_L08', cFI_FrameZhiKaDetail);
  AddMenuModuleItem('MAIN_L09', cFI_FrameSaleJS);
  AddMenuModuleItem('MAIN_L10', cFI_FrameOrderDetailQuery);
  AddMenuModuleItem('MAIN_L28', cFI_FrameSaletunnelQuery);
  //���񱨱�
  AddMenuModuleItem('MAIN_L11', cFI_FrameNotice);
  AddMenuModuleItem('MAIN_L12', cFI_FrameDaySales);
  AddMenuModuleItem('MAIN_L13', cFI_FrameMonthSales);
  AddMenuModuleItem('MAIN_L14', cFI_FrameDayPrice);
  AddMenuModuleItem('MAIN_L15', cFI_FrameMonthPrice);
  AddMenuModuleItem('MAIN_L16', cFI_FrameCollectMoney);
  AddMenuModuleItem('MAIN_L17', cFI_FrameAccReport);
  AddMenuModuleItem('MAIN_L18', cFI_FrameSaleAndMoney);
  AddMenuModuleItem('MAIN_L19', cFI_FrameDaySalesHj);
  {$IFDEF SXDY}
  AddMenuModuleItem('MAIN_L20', cFI_FrameDayReport);
  {$ELSE}
  AddMenuModuleItem('MAIN_L20', cFI_FrameDayReport_HY);
  {$ENDIF}
  AddMenuModuleItem('MAIN_L21', cFI_FrameSaleTotalQuery2HY);
  AddMenuModuleItem('MAIN_L22', cFI_FrameCusTotalMoney);
  AddMenuModuleItem('MAIN_L23', cFI_FrameCusReceivable);
  AddMenuModuleItem('MAIN_L24', cFI_FrameQrySaleByMonth);
  AddMenuModuleItem('MAIN_L25', cFI_FramePurchByMonth);

  AddMenuModuleItem('MAIN_H01', cFI_FormTruckIn, mtForm);
  AddMenuModuleItem('MAIN_H02', cFI_FormTruckOut, mtForm);
  AddMenuModuleItem('MAIN_H03', cFI_FrameTruckQuery);

  AddMenuModuleItem('MAIN_J01', cFI_FrameTrucks);

  AddMenuModuleItem('MAIN_X01', cFI_FrameXHSpot);
  AddMenuModuleItem('MAIN_X02', cFI_FrameDriverWh);

  AddMenuModuleItem('MAIN_M01', cFI_FrameProvider);
  AddMenuModuleItem('MAIN_M02', cFI_FrameMaterails);
  AddMenuModuleItem('MAIN_M03', cFI_FrameMakeOCard); 
  AddMenuModuleItem('MAIN_M04', cFI_FrameOrder);
  AddMenuModuleItem('MAIN_M05', cFI_FormTransBase, mtForm);
  AddMenuModuleItem('MAIN_M06', cFI_FrameTransBase);
  AddMenuModuleItem('MAIN_M08', cFI_FrameOrderDetail);
  AddMenuModuleItem('MAIN_M09', cFI_FrameOrderBase);
  AddMenuModuleItem('MAIN_M10', cFI_FramePMaterailControl);
  AddMenuModuleItem('MAIN_M11', cFI_FrameCrossCard);
  AddMenuModuleItem('MAIN_M15', cFI_FrameKDInfo);
 // AddMenuModuleItem('MAIN_M13', cFI_FrameYCLStock);
 // AddMenuModuleItem('MAIN_M14', cFI_FrameYCLStockRecord);
 

  AddMenuModuleItem('MAIN_W01', cFI_FrameWXAccount);
  AddMenuModuleItem('MAIN_W02', cFI_FrameWXSendLog);
end;

//Desc: ����ģ���б�
procedure ClearMenuModuleList;
var nIdx: integer;
begin
  for nIdx:=gMenuModule.Count - 1 downto 0 do
  begin
    Dispose(PMenuModuleItem(gMenuModule[nIdx]));
    gMenuModule.Delete(nIdx);
  end;

  FreeAndNil(gMenuModule);
end;

initialization
  InitMenuModuleList;
finalization
  ClearMenuModuleList;
end.

