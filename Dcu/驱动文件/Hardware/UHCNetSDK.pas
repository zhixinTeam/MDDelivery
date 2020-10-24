{*******************************************************************************
  作者: dmzn@163.com 2017-10-17
  描述: 海康威视SDK常量及函数声明
*******************************************************************************}
unit UHCNetSDK;

interface

const
  /// <summary>
  /// CHCNetSDK 的摘要说明。
  /// </summary>
  //
  // TODO: 在此处添加构造函数逻辑
  //

  //SDK类型
  SDK_PLAYMPEG4 = 1;//播放库
  SDK_HCNETSDK = 2;//网络库

  NAME_LEN = 32;//用户名长度
  PASSWD_LEN = 16;//密码长度
  GUID_LEN = 16;      //GUID长度
  DEV_TYPE_NAME_LEN = 24;      //设备类型名称长度
  MAX_NAMELEN = 16;//DVR本地登陆名
  MAX_RIGHT = 32;//设备支持的权限（1-12表示本地权限，13-32表示远程权限）
  SERIALNO_LEN = 48;//序列号长度
  MACADDR_LEN = 6;//mac地址长度
  MAX_ETHERNET = 2;//设备可配以太网络
  MAX_NETWORK_CARD = 4; //设备可配最大网卡数目
  PATHNAME_LEN = 128;//路径长度

  MAX_NUMBER_LEN = 32;	//号码最大长度
  MAX_NAME_LEN = 128; //设备名称最大长度

  MAX_TIMESEGMENT_V30 = 8;//9000设备最大时间段数
  MAX_TIMESEGMENT = 4;//8000设备最大时间段数
  MAX_ICR_NUM = 8;   //抓拍机红外滤光片预置点数

  MAX_SHELTERNUM = 4;//8000设备最大遮挡区域数
  PHONENUMBER_LEN = 32;//pppoe拨号号码最大长度

  MAX_DISKNUM = 16;//8000设备最大硬盘数
  MAX_DISKNUM_V10 = 8;//1.2版本之前版本

  MAX_WINDOW_V30 = 32;//9000设备本地显示最大播放窗口数
  MAX_WINDOW = 16;//8000设备最大硬盘数
  MAX_VGA_V30 = 4;//9000设备最大可接VGA数
  MAX_VGA = 1;//8000设备最大可接VGA数

  MAX_USERNUM_V30 = 32;//9000设备最大用户数
  MAX_USERNUM = 16;//8000设备最大用户数
  MAX_EXCEPTIONNUM_V30 = 32;//9000设备最大异常处理数
  MAX_EXCEPTIONNUM = 16;//8000设备最大异常处理数
  MAX_LINK = 6;//8000设备单通道最大视频流连接数
  MAX_ITC_EXCEPTIONOUT = 32;//抓拍机最大报警输出

  MAX_DECPOOLNUM = 4;//单路解码器每个解码通道最大可循环解码数
  MAX_DECNUM = 4;//单路解码器的最大解码通道数（实际只有一个，其他三个保留）
  MAX_TRANSPARENTNUM = 2;//单路解码器可配置最大透明通道数
  MAX_CYCLE_CHAN = 16; //单路解码器最大轮循通道数
  MAX_CYCLE_CHAN_V30 = 64;//最大轮询通道数（扩展）
  MAX_DIRNAME_LENGTH = 80;//最大目录长度

  MAX_STRINGNUM_V30 = 8;//9000设备最大OSD字符行数数
  MAX_STRINGNUM = 4;//8000设备最大OSD字符行数数
  MAX_STRINGNUM_EX = 8;//8000定制扩展
  MAX_AUXOUT_V30 = 16;//9000设备最大辅助输出数
  MAX_AUXOUT = 4;//8000设备最大辅助输出数
  MAX_HD_GROUP = 16;//9000设备最大硬盘组数
  MAX_NFS_DISK = 8; //8000设备最大NFS硬盘数

  IW_ESSID_MAX_SIZE = 32;//WIFI的SSID号长度
  IW_ENCODING_TOKEN_MAX = 32;//WIFI密锁最大字节数
  WIFI_WEP_MAX_KEY_COUNT = 4;
  WIFI_WEP_MAX_KEY_LENGTH = 33;
  WIFI_WPA_PSK_MAX_KEY_LENGTH = 63;
  WIFI_WPA_PSK_MIN_KEY_LENGTH = 8;
  WIFI_MAX_AP_COUNT = 20;
  MAX_SERIAL_NUM = 64;//最多支持的透明通道路数
  MAX_DDNS_NUMS = 10;//9000设备最大可配ddns数
  MAX_EMAIL_ADDR_LEN = 48;//最大email地址长度
  MAX_EMAIL_PWD_LEN = 32;//最大email密码长度

  MAXPROGRESS = 100;//回放时的最大百分率
  MAX_SERIALNUM = 2;//8000设备支持的串口数 1-232， 2-485
  CARDNUM_LEN = 20;//卡号长度
  CARDNUM_LEN_OUT = 32; //外部结构体卡号长度
  MAX_VIDEOOUT_V30 = 4;//9000设备的视频输出数
  MAX_VIDEOOUT = 2;//8000设备的视频输出数

  MAX_PRESET_V30 = 256;// 9000设备支持的云台预置点数
  MAX_TRACK_V30 = 256;// 9000设备支持的云台轨迹数
  MAX_CRUISE_V30 = 256;// 9000设备支持的云台巡航数
  MAX_PRESET = 128;// 8000设备支持的云台预置点数
  MAX_TRACK = 128;// 8000设备支持的云台轨迹数
  MAX_CRUISE = 128;// 8000设备支持的云台巡航数

  CRUISE_MAX_PRESET_NUMS = 32;// 一条巡航最多的巡航点

  MAX_SERIAL_PORT = 8;//9000设备支持232串口数
  MAX_PREVIEW_MODE = 8;// 设备支持最大预览模式数目 1画面,4画面,9画面,16画面....
  MAX_MATRIXOUT = 16;// 最大模拟矩阵输出个数
  LOG_INFO_LEN = 11840; // 日志附加信息
  DESC_LEN = 16;// 云台描述字符串长度
  PTZ_PROTOCOL_NUM = 200;// 9000最大支持的云台协议数

  MAX_AUDIO = 1;//8000语音对讲通道数
  MAX_AUDIO_V30 = 2;//9000语音对讲通道数
  MAX_CHANNUM = 16;//8000设备最大通道数
  MAX_ALARMIN = 16;//8000设备最大报警输入数
  MAX_ALARMOUT = 4;//8000设备最大报警输出数
  //9000 IPC接入
  MAX_ANALOG_CHANNUM = 32;//最大32个模拟通道
  MAX_ANALOG_ALARMOUT = 32; //最大32路模拟报警输出
  MAX_ANALOG_ALARMIN = 32;//最大32路模拟报警输入

  MAX_IP_DEVICE = 32;//允许接入的最大IP设备数
  MAX_IP_DEVICE_V40 = 64;//允许接入的最大IP设备数
  MAX_IP_CHANNEL = 32;//允许加入的最多IP通道数
  MAX_IP_ALARMIN = 128;//允许加入的最多报警输入数
  MAX_IP_ALARMOUT = 64;//允许加入的最多报警输出数
  MAX_IP_ALARMIN_V40 = 4096;    //允许加入的最多报警输入数
  MAX_IP_ALARMOUT_V40 = 4096;    //允许加入的最多报警输出数

  MAX_RECORD_FILE_NUM = 20;      // 每次删除或者刻录的最大文件数

  //SDK_V31 ATM
  MAX_ATM_NUM = 1;
  MAX_ACTION_TYPE = 12;
  ATM_FRAMETYPE_NUM = 4;
  MAX_ATM_PROTOCOL_NUM = 1025;
  ATM_PROTOCOL_SORT = 4;
  ATM_DESC_LEN = 32;
  // SDK_V31 ATM

  //* 最大支持的通道数 最大模拟加上最大IP支持 */
  MAX_CHANNUM_V30 = MAX_ANALOG_CHANNUM + MAX_IP_CHANNEL;//64
  MAX_ALARMOUT_V30 = MAX_ANALOG_ALARMOUT + MAX_IP_ALARMOUT;//96
  MAX_ALARMIN_V30 = MAX_ANALOG_ALARMIN + MAX_IP_ALARMIN;//160

  MAX_CHANNUM_V40 = 512;
  MAX_ALARMOUT_V40 = MAX_IP_ALARMOUT_V40 + MAX_ANALOG_ALARMOUT;//4128
  MAX_ALARMIN_V40 = MAX_IP_ALARMIN_V40 + MAX_ANALOG_ALARMOUT;//4128

  MAX_HUMAN_PICTURE_NUM = 10;   //最大照片数
  MAX_HUMAN_BIRTHDATE_LEN = 10;

  MAX_LAYERNUMS = 32;

  MAX_ROIDETECT_NUM = 8;    //支持的ROI区域数
  MAX_LANERECT_NUM   =     5;    //最大车牌识别区域数
  MAX_FORTIFY_NUM   =      10;   //最大布防个数
  MAX_INTERVAL_NUM  =      4;    //最大时间间隔个数
  MAX_CHJC_NUM     =       3;    //最大车辆省份简称字符个数
  MAX_VL_NUM        =      5;    //最大虚拟线圈个数
  MAX_DRIVECHAN_NUM =      16;   //最大车道数
  MAX_COIL_NUM      =      3;    //最大线圈个数
  MAX_SIGNALLIGHT_NUM =    6;   //最大信号灯个数
  LEN_32				=	32;
  LEN_31				=	31;
  MAX_CABINET_COUNT  =     8;    //最大支持机柜数量
  MAX_ID_LEN         =     48;
  MAX_PARKNO_LEN    =      16;
  MAX_ALARMREASON_LEN =    32;
  MAX_UPGRADE_INFO_LEN=    48; //获取升级文件匹配信息(模糊升级)
  MAX_CUSTOMDIR_LEN  =     32; //自定义目录长度

  MAX_TRANSPARENT_CHAN_NUM  =    4;   //每个串口允许建立的最大透明通道数
  MAX_TRANSPARENT_ACCESS_NUM =   4;   //每个监听端口允许接入的最大主机数

  //ITS
  MAX_PARKING_STATUS  =     8;    //车位状态 0代表无车，1代表有车，2代表压线(优先级最高), 3特殊车位
  MAX_PARKING_NUM	   =      4;    //一个通道最大4个车位 (从左到右车位 数组0～3)

  MAX_ITS_SCENE_NUM    =    16;   //最大场景数量
  MAX_SCENE_TIMESEG_NUM =   16;   //最大场景时间段数量
  MAX_IVMS_IP_CHANNEL  =    128;  //最大IP通道数
  DEVICE_ID_LEN      =      48;   //设备编号长度
  MONITORSITE_ID_LEN  =     48;   //监测点编号长度
  MAX_AUXAREA_NUM       =   16;   //辅助区域最大数目
  MAX_SLAVE_CHANNEL_NUM =   16;   //最大从通道数量

  MAX_SCH_TASKS_NUM = 10;

  MAX_SERVERID_LEN   =         64; //最大服务器ID的长度
  MAX_SERVERDOMAIN_LEN =       128; //服务器域名最大长度
  MAX_AUTHENTICATEID_LEN =     64; //认证ID最大长度
  MAX_AUTHENTICATEPASSWD_LEN = 32; //认证密码最大长度
  MAX_SERVERNAME_LEN =         64; //最大服务器用户名
  MAX_COMPRESSIONID_LEN =      64; //编码ID的最大长度
  MAX_SIPSERVER_ADDRESS_LEN =  128; //SIP服务器地址支持域名和IP地址
  //压线报警
  MAX_PlATE_NO_LEN =        32;   //车牌号码最大长度 2013-09-27
  UPNP_PORT_NUM	=		12;	  //upnp端口映射端口数目


  MAX_LOCAL_ADDR_LEN	= 96;		//SOCKS最大本地网段个数
  MAX_COUNTRY_NAME_LEN = 4;		//国家简写名称长度

  //码流连接方式
  NORMALCONNECT = 1;
  MEDIACONNECT = 2;

  //设备型号(大类)
  HCDVR = 1;
  MEDVR = 2;
  PCDVR = 3;
  HC_9000 = 4;
  HF_I = 5;
  PCNVR = 6;
  HC_76NVR = 8;

  //NVR类型
  DS8000HC_NVR = 0;
  DS9000HC_NVR = 1;
  DS8000ME_NVR = 2;

  //*******************全局错误码 begin**********************/
  NET_DVR_NOERROR = 0;//没有错误
  NET_DVR_PASSWORD_ERROR = 1;//用户名密码错误
  NET_DVR_NOENOUGHPRI = 2;//权限不足
  NET_DVR_NOINIT = 3;//没有初始化
  NET_DVR_CHANNEL_ERROR = 4;//通道号错误
  NET_DVR_OVER_MAXLINK = 5;//连接到DVR的客户端个数超过最大
  NET_DVR_VERSIONNOMATCH = 6;//版本不匹配
  NET_DVR_NETWORK_FAIL_CONNECT = 7;//连接服务器失败
  NET_DVR_NETWORK_SEND_ERROR = 8;//向服务器发送失败
  NET_DVR_NETWORK_RECV_ERROR = 9;//从服务器接收数据失败
  NET_DVR_NETWORK_RECV_TIMEOUT = 10;//从服务器接收数据超时
  NET_DVR_NETWORK_ERRORDATA = 11;//传送的数据有误
  NET_DVR_ORDER_ERROR = 12;//调用次序错误
  NET_DVR_OPERNOPERMIT = 13;//无此权限
  NET_DVR_COMMANDTIMEOUT = 14;//DVR命令执行超时
  NET_DVR_ERRORSERIALPORT = 15;//串口号错误
  NET_DVR_ERRORALARMPORT = 16;//报警端口错误
  NET_DVR_PARAMETER_ERROR = 17;//参数错误
  NET_DVR_CHAN_EXCEPTION = 18;//服务器通道处于错误状态
  NET_DVR_NODISK = 19;//没有硬盘
  NET_DVR_ERRORDISKNUM = 20;//硬盘号错误
  NET_DVR_DISK_FULL = 21;//服务器硬盘满
  NET_DVR_DISK_ERROR = 22;//服务器硬盘出错
  NET_DVR_NOSUPPORT = 23;//服务器不支持
  NET_DVR_BUSY = 24;//服务器忙
  NET_DVR_MODIFY_FAIL = 25;//服务器修改不成功
  NET_DVR_PASSWORD_FORMAT_ERROR = 26;//密码输入格式不正确
  NET_DVR_DISK_FORMATING = 27;//硬盘正在格式化，不能启动操作
  NET_DVR_DVRNORESOURCE = 28;//DVR资源不足
  NET_DVR_DVROPRATEFAILED = 29;//DVR操作失败
  NET_DVR_OPENHOSTSOUND_FAIL = 30;//打开PC声音失败
  NET_DVR_DVRVOICEOPENED = 31;//服务器语音对讲被占用
  NET_DVR_TIMEINPUTERROR = 32;//时间输入不正确
  NET_DVR_NOSPECFILE = 33;//回放时服务器没有指定的文件
  NET_DVR_CREATEFILE_ERROR = 34;//创建文件出错
  NET_DVR_FILEOPENFAIL = 35;//打开文件出错
  NET_DVR_OPERNOTFINISH = 36; //上次的操作还没有完成
  NET_DVR_GETPLAYTIMEFAIL = 37;//获取当前播放的时间出错
  NET_DVR_PLAYFAIL = 38;//播放出错
  NET_DVR_FILEFORMAT_ERROR = 39;//文件格式不正确
  NET_DVR_DIR_ERROR = 40;//路径错误
  NET_DVR_ALLOC_RESOURCE_ERROR = 41;//资源分配错误
  NET_DVR_AUDIO_MODE_ERROR = 42;//声卡模式错误
  NET_DVR_NOENOUGH_BUF = 43;//缓冲区太小
  NET_DVR_CREATESOCKET_ERROR = 44;//创建SOCKET出错
  NET_DVR_SETSOCKET_ERROR = 45;//设置SOCKET出错
  NET_DVR_MAX_NUM = 46;//个数达到最大
  NET_DVR_USERNOTEXIST = 47;//用户不存在
  NET_DVR_WRITEFLASHERROR = 48;//写FLASH出错
  NET_DVR_UPGRADEFAIL = 49;//DVR升级失败
  NET_DVR_CARDHAVEINIT = 50;//解码卡已经初始化过
  NET_DVR_PLAYERFAILED = 51;//调用播放库中某个函数失败
  NET_DVR_MAX_USERNUM = 52;//设备端用户数达到最大
  NET_DVR_GETLOCALIPANDMACFAIL = 53;//获得客户端的IP地址或物理地址失败
  NET_DVR_NOENCODEING = 54;//该通道没有编码
  NET_DVR_IPMISMATCH = 55;//IP地址不匹配
  NET_DVR_MACMISMATCH = 56;//MAC地址不匹配
  NET_DVR_UPGRADELANGMISMATCH = 57;//升级文件语言不匹配
  NET_DVR_MAX_PLAYERPORT = 58;//播放器路数达到最大
  NET_DVR_NOSPACEBACKUP = 59;//备份设备中没有足够空间进行备份
  NET_DVR_NODEVICEBACKUP = 60;//没有找到指定的备份设备
  NET_DVR_PICTURE_BITS_ERROR = 61;//图像素位数不符，限24色
  NET_DVR_PICTURE_DIMENSION_ERROR = 62;//图片高*宽超限， 限128*256
  NET_DVR_PICTURE_SIZ_ERROR = 63;//图片大小超限，限100K
  NET_DVR_LOADPLAYERSDKFAILED = 64;//载入当前目录下Player Sdk出错
  NET_DVR_LOADPLAYERSDKPROC_ERROR = 65;//找不到Player Sdk中某个函数入口
  NET_DVR_LOADDSSDKFAILED = 66;//载入当前目录下DSsdk出错
  NET_DVR_LOADDSSDKPROC_ERROR = 67;//找不到DsSdk中某个函数入口
  NET_DVR_DSSDK_ERROR = 68;//调用硬解码库DsSdk中某个函数失败
  NET_DVR_VOICEMONOPOLIZE = 69;//声卡被独占
  NET_DVR_JOINMULTICASTFAILED = 70;//加入多播组失败
  NET_DVR_CREATEDIR_ERROR = 71;//建立日志文件目录失败
  NET_DVR_BINDSOCKET_ERROR = 72;//绑定套接字失败
  NET_DVR_SOCKETCLOSE_ERROR = 73;//socket连接中断，此错误通常是由于连接中断或目的地不可达
  NET_DVR_USERID_ISUSING = 74;//注销时用户ID正在进行某操作
  NET_DVR_SOCKETLISTEN_ERROR = 75;//监听失败
  NET_DVR_PROGRAM_EXCEPTION = 76;//程序异常
  NET_DVR_WRITEFILE_FAILED = 77;//写文件失败
  NET_DVR_FORMAT_READONLY = 78;//禁止格式化只读硬盘
  NET_DVR_WITHSAMEUSERNAME = 79;//用户配置结构中存在相同的用户名
  NET_DVR_DEVICETYPE_ERROR = 80;//导入参数时设备型号不匹配
  NET_DVR_LANGUAGE_ERROR = 81;//导入参数时语言不匹配
  NET_DVR_PARAVERSION_ERROR = 82;//导入参数时软件版本不匹配
  NET_DVR_IPCHAN_NOTALIVE = 83; //预览时外接IP通道不在线
  NET_DVR_RTSP_SDK_ERROR = 84;//加载高清IPC通讯库StreamTransClient.dll失败
  NET_DVR_CONVERT_SDK_ERROR = 85;//加载转码库失败
  NET_DVR_IPC_COUNT_OVERFLOW = 86;//超出最大的ip接入通道数

  NET_PLAYM4_NOERROR = 500;//no error
  NET_PLAYM4_PARA_OVER = 501;//input parameter is invalid
  NET_PLAYM4_ORDER_ERROR = 502;//The order of the function to be called is error
  NET_PLAYM4_TIMER_ERROR = 503;//Create multimedia clock failed
  NET_PLAYM4_DEC_VIDEO_ERROR = 504;//Decode video data failed
  NET_PLAYM4_DEC_AUDIO_ERROR = 505;//Decode audio data failed
  NET_PLAYM4_ALLOC_MEMORY_ERROR = 506;//Allocate memory failed
  NET_PLAYM4_OPEN_FILE_ERROR = 507;//Open the file failed
  NET_PLAYM4_CREATE_OBJ_ERROR = 508;//Create thread or event failed
  NET_PLAYM4_CREATE_DDRAW_ERROR = 509;//Create DirectDraw object failed
  NET_PLAYM4_CREATE_OFFSCREEN_ERROR = 510;//failed when creating off-screen surface
  NET_PLAYM4_BUF_OVER = 511;//buffer is overflow
  NET_PLAYM4_CREATE_SOUND_ERROR = 512;//failed when creating audio device
  NET_PLAYM4_SET_VOLUME_ERROR = 513;//Set volume failed
  NET_PLAYM4_SUPPORT_FILE_ONLY = 514;//The function only support play file
  NET_PLAYM4_SUPPORT_STREAM_ONLY = 515;//The function only support play stream
  NET_PLAYM4_SYS_NOT_SUPPORT = 516;//System not support
  NET_PLAYM4_FILEHEADER_UNKNOWN = 517;//No file header
  NET_PLAYM4_VERSION_INCORRECT = 518;//The version of decoder and encoder is not adapted
  NET_PALYM4_INIT_DECODER_ERROR = 519;//Initialize decoder failed
  NET_PLAYM4_CHECK_FILE_ERROR = 520;//The file data is unknown
  NET_PLAYM4_INIT_TIMER_ERROR = 521;//Initialize multimedia clock failed
  NET_PLAYM4_BLT_ERROR = 522;//Blt failed
  NET_PLAYM4_UPDATE_ERROR = 523;//Update failed
  NET_PLAYM4_OPEN_FILE_ERROR_MULTI = 524;//openfile error, streamtype is multi
  NET_PLAYM4_OPEN_FILE_ERROR_VIDEO = 525;//openfile error, streamtype is video
  NET_PLAYM4_JPEG_COMPRESS_ERROR = 526;//JPEG compress error
  NET_PLAYM4_EXTRACT_NOT_SUPPORT = 527;//Don't support the version of this file
  NET_PLAYM4_EXTRACT_DATA_ERROR = 528;//extract video data failed
  //*******************全局错误码 end**********************/

  {*************************************************
  NET_DVR_IsSupport()返回值
  1－9位分别表示以下信息（位与是TRUE)表示支持；
  **************************************************}
  NET_DVR_SUPPORT_DDRAW = 1;//支持DIRECTDRAW，如果不支持，则播放器不能工作
  NET_DVR_SUPPORT_BLT = 2;//显卡支持BLT操作，如果不支持，则播放器不能工作
  NET_DVR_SUPPORT_BLTFOURCC = 4;//显卡BLT支持颜色转换，如果不支持，播放器会用软件方法作RGB转换
  NET_DVR_SUPPORT_BLTSHRINKX = 8;//显卡BLT支持X轴缩小；如果不支持，系统会用软件方法转换
  NET_DVR_SUPPORT_BLTSHRINKY = 16;//显卡BLT支持Y轴缩小；如果不支持，系统会用软件方法转换
  NET_DVR_SUPPORT_BLTSTRETCHX = 32;//显卡BLT支持X轴放大；如果不支持，系统会用软件方法转换
  NET_DVR_SUPPORT_BLTSTRETCHY = 64;//显卡BLT支持Y轴放大；如果不支持，系统会用软件方法转换
  NET_DVR_SUPPORT_SSE = 128;//CPU支持SSE指令，Intel Pentium3以上支持SSE指令
  NET_DVR_SUPPORT_MMX = 256;//CPU支持MMX指令集，Intel Pentium3以上支持SSE指令

  //**********************云台控制命令 begin*************************/
  LIGHT_PWRON = 2;// 接通灯光电源
  WIPER_PWRON = 3;// 接通雨刷开关
  FAN_PWRON = 4;// 接通风扇开关
  HEATER_PWRON = 5;// 接通加热器开关
  AUX_PWRON1 = 6;// 接通辅助设备开关
  AUX_PWRON2 = 7;// 接通辅助设备开关
  SET_PRESET = 8;// 设置预置点
  CLE_PRESET = 9;// 清除预置点

  ZOOM_IN = 11;// 焦距以速度SS变大(倍率变大)
  ZOOM_OUT = 12;// 焦距以速度SS变小(倍率变小)
  FOCUS_NEAR = 13;// 焦点以速度SS前调
  FOCUS_FAR = 14;// 焦点以速度SS后调
  IRIS_OPEN = 15;// 光圈以速度SS扩大
  IRIS_CLOSE = 16;// 光圈以速度SS缩小

  TILT_UP = 21;/* 云台以SS的速度上仰 */
  TILT_DOWN = 22;/* 云台以SS的速度下俯 */
  PAN_LEFT = 23;/* 云台以SS的速度左转 */
  PAN_RIGHT = 24;/* 云台以SS的速度右转 */
  UP_LEFT = 25;/* 云台以SS的速度上仰和左转 */
  UP_RIGHT = 26;/* 云台以SS的速度上仰和右转 */
  DOWN_LEFT = 27;/* 云台以SS的速度下俯和左转 */
  DOWN_RIGHT = 28;/* 云台以SS的速度下俯和右转 */
  PAN_AUTO = 29;/* 云台以SS的速度左右自动扫描 */

  FILL_PRE_SEQ = 30;/* 将预置点加入巡航序列 */
  SET_SEQ_DWELL = 31;/* 设置巡航点停顿时间 */
  SET_SEQ_SPEED = 32;/* 设置巡航速度 */
  CLE_PRE_SEQ = 33;/* 将预置点从巡航序列中删除 */
  STA_MEM_CRUISE = 34;/* 开始记录轨迹 */
  STO_MEM_CRUISE = 35;/* 停止记录轨迹 */
  RUN_CRUISE = 36;/* 开始轨迹 */
  RUN_SEQ = 37;/* 开始巡航 */
  STOP_SEQ = 38;/* 停止巡航 */
  GOTO_PRESET = 39;/* 快球转到预置点 */
  //**********************云台控制命令 end*************************/

  {*************************************************
  回放时播放控制命令宏定义
  NET_DVR_PlayBackControl
  NET_DVR_PlayControlLocDisplay
  NET_DVR_DecPlayBackCtrl的宏定义
  具体支持查看函数说明和代码
  **************************************************}
  NET_DVR_PLAYSTART = 1;//开始播放
  NET_DVR_PLAYSTOP = 2;//停止播放
  NET_DVR_PLAYPAUSE = 3;//暂停播放
  NET_DVR_PLAYRESTART = 4;//恢复播放
  NET_DVR_PLAYFAST = 5;//快放
  NET_DVR_PLAYSLOW = 6;//慢放
  NET_DVR_PLAYNORMAL = 7;//正常速度
  NET_DVR_PLAYFRAME = 8;//单帧放
  NET_DVR_PLAYSTARTAUDIO = 9;//打开声音
  NET_DVR_PLAYSTOPAUDIO = 10;//关闭声音
  NET_DVR_PLAYAUDIOVOLUME = 11;//调节音量
  NET_DVR_PLAYSETPOS = 12;//改变文件回放的进度
  NET_DVR_PLAYGETPOS = 13;//获取文件回放的进度
  NET_DVR_PLAYGETTIME = 14;//获取当前已经播放的时间(按文件回放的时候有效)
  NET_DVR_PLAYGETFRAME = 15;//获取当前已经播放的帧数(按文件回放的时候有效)
  NET_DVR_GETTOTALFRAMES = 16;//获取当前播放文件总的帧数(按文件回放的时候有效)
  NET_DVR_GETTOTALTIME = 17;//获取当前播放文件总的时间(按文件回放的时候有效)
  NET_DVR_THROWBFRAME = 20;//丢B帧
  NET_DVR_SETSPEED = 24;//设置码流速度
  NET_DVR_KEEPALIVE = 25;//保持与设备的心跳(如果回调阻塞，建议2秒发送一次)
  NET_DVR_PLAYSETTIME = 26;//按绝对时间定位
  NET_DVR_PLAYGETTOTALLEN = 27;//获取按时间回放对应时间段内的所有文件的总长度
  NET_DVR_PLAY_FORWARD = 29;//倒放切换为正放
  NET_DVR_PLAY_REVERSE = 30;//正放切换为倒放
  NET_DVR_SET_TRANS_TYPE = 32;//设置转封装类型
  NET_DVR_PLAY_CONVERT = 33;//正放切换为倒放

  //远程按键定义如下：
  //* key value send to CONFIG program */
  KEY_CODE_1 = 1;
  KEY_CODE_2 = 2;
  KEY_CODE_3 = 3;
  KEY_CODE_4 = 4;
  KEY_CODE_5 = 5;
  KEY_CODE_6 = 6;
  KEY_CODE_7 = 7;
  KEY_CODE_8 = 8;
  KEY_CODE_9 = 9;
  KEY_CODE_0 = 10;
  KEY_CODE_POWER = 11;
  KEY_CODE_MENU = 12;
  KEY_CODE_ENTER = 13;
  KEY_CODE_CANCEL = 14;
  KEY_CODE_UP = 15;
  KEY_CODE_DOWN = 16;
  KEY_CODE_LEFT = 17;
  KEY_CODE_RIGHT = 18;
  KEY_CODE_EDIT = 19;
  KEY_CODE_ADD = 20;
  KEY_CODE_MINUS = 21;
  KEY_CODE_PLAY = 22;
  KEY_CODE_REC = 23;
  KEY_CODE_PAN = 24;
  KEY_CODE_M = 25;
  KEY_CODE_A = 26;
  KEY_CODE_F1 = 27;
  KEY_CODE_F2 = 28;

  //* for PTZ control */
  KEY_PTZ_UP_START = KEY_CODE_UP;
  KEY_PTZ_UP_STOP = 32;

  KEY_PTZ_DOWN_START = KEY_CODE_DOWN;
  KEY_PTZ_DOWN_STOP = 33;


  KEY_PTZ_LEFT_START = KEY_CODE_LEFT;
  KEY_PTZ_LEFT_STOP = 34;

  KEY_PTZ_RIGHT_START = KEY_CODE_RIGHT;
  KEY_PTZ_RIGHT_STOP = 35;

  KEY_PTZ_AP1_START = KEY_CODE_EDIT;/* 光圈+ */
  KEY_PTZ_AP1_STOP = 36;

  KEY_PTZ_AP2_START = KEY_CODE_PAN;/* 光圈- */
  KEY_PTZ_AP2_STOP = 37;

  KEY_PTZ_FOCUS1_START = KEY_CODE_A;/* 聚焦+ */
  KEY_PTZ_FOCUS1_STOP = 38;

  KEY_PTZ_FOCUS2_START = KEY_CODE_M;/* 聚焦- */
  KEY_PTZ_FOCUS2_STOP = 39;

  KEY_PTZ_B1_START = 40;/* 变倍+ */
  KEY_PTZ_B1_STOP = 41;

  KEY_PTZ_B2_START = 42;/* 变倍- */
  KEY_PTZ_B2_STOP = 43;

  //9000新增
  KEY_CODE_11 = 44;
  KEY_CODE_12 = 45;
  KEY_CODE_13 = 46;
  KEY_CODE_14 = 47;
  KEY_CODE_15 = 48;
  KEY_CODE_16 = 49;

  //*************************参数配置命令 begin*******************************/
  //用于NET_DVR_SetDVRConfig和NET_DVR_GetDVRConfig,注意其对应的配置结构
  NET_DVR_GET_DEVICECFG = 100;//获取设备参数
  NET_DVR_SET_DEVICECFG = 101;//设置设备参数
  NET_DVR_GET_NETCFG = 102;//获取网络参数
  NET_DVR_SET_NETCFG = 103;//设置网络参数
  NET_DVR_GET_PICCFG = 104;//获取图象参数
  NET_DVR_SET_PICCFG = 105;//设置图象参数
  NET_DVR_GET_COMPRESSCFG = 106;//获取压缩参数
  NET_DVR_SET_COMPRESSCFG = 107;//设置压缩参数
  NET_DVR_GET_RECORDCFG = 108;//获取录像时间参数
  NET_DVR_SET_RECORDCFG = 109;//设置录像时间参数
  NET_DVR_GET_DECODERCFG = 110;//获取解码器参数
  NET_DVR_SET_DECODERCFG = 111;//设置解码器参数
  NET_DVR_GET_RS232CFG = 112;//获取232串口参数
  NET_DVR_SET_RS232CFG = 113;//设置232串口参数
  NET_DVR_GET_ALARMINCFG = 114;//获取报警输入参数
  NET_DVR_SET_ALARMINCFG = 115;//设置报警输入参数
  NET_DVR_GET_ALARMOUTCFG = 116;//获取报警输出参数
  NET_DVR_SET_ALARMOUTCFG = 117;//设置报警输出参数
  NET_DVR_GET_TIMECFG = 118;//获取DVR时间
  NET_DVR_SET_TIMECFG = 119;//设置DVR时间
  NET_DVR_GET_PREVIEWCFG = 120;//获取预览参数
  NET_DVR_SET_PREVIEWCFG = 121;//设置预览参数
  NET_DVR_GET_VIDEOOUTCFG = 122;//获取视频输出参数
  NET_DVR_SET_VIDEOOUTCFG = 123;//设置视频输出参数
  NET_DVR_GET_USERCFG = 124;//获取用户参数
  NET_DVR_SET_USERCFG = 125;//设置用户参数
  NET_DVR_GET_EXCEPTIONCFG = 126;//获取异常参数
  NET_DVR_SET_EXCEPTIONCFG = 127;//设置异常参数
  NET_DVR_GET_ZONEANDDST = 128;//获取时区和夏时制参数
  NET_DVR_SET_ZONEANDDST = 129;//设置时区和夏时制参数
  NET_DVR_GET_SHOWSTRING = 130;//获取叠加字符参数
  NET_DVR_SET_SHOWSTRING = 131;//设置叠加字符参数
  NET_DVR_GET_EVENTCOMPCFG = 132;//获取事件触发录像参数
  NET_DVR_SET_EVENTCOMPCFG = 133;//设置事件触发录像参数

  NET_DVR_GET_AUXOUTCFG = 140;//获取报警触发辅助输出设置(HS设备辅助输出2006-02-28)
  NET_DVR_SET_AUXOUTCFG = 141;//设置报警触发辅助输出设置(HS设备辅助输出2006-02-28)
  NET_DVR_GET_PREVIEWCFG_AUX = 142;//获取-s系列双输出预览参数(-s系列双输出2006-04-13)
  NET_DVR_SET_PREVIEWCFG_AUX = 143;//设置-s系列双输出预览参数(-s系列双输出2006-04-13)

  NET_DVR_GET_PICCFG_EX = 200;//获取图象参数(SDK_V14扩展命令)
  NET_DVR_SET_PICCFG_EX = 201;//设置图象参数(SDK_V14扩展命令)
  NET_DVR_GET_USERCFG_EX = 202;//获取用户参数(SDK_V15扩展命令)
  NET_DVR_SET_USERCFG_EX = 203;//设置用户参数(SDK_V15扩展命令)
  NET_DVR_GET_COMPRESSCFG_EX = 204;//获取压缩参数(SDK_V15扩展命令2006-05-15)
  NET_DVR_SET_COMPRESSCFG_EX = 205;//设置压缩参数(SDK_V15扩展命令2006-05-15)

  NET_DVR_GET_NETAPPCFG = 222;//获取网络应用参数 NTP/DDNS/EMAIL
  NET_DVR_SET_NETAPPCFG = 223;//设置网络应用参数 NTP/DDNS/EMAIL
  NET_DVR_GET_NTPCFG = 224;//获取网络应用参数 NTP
  NET_DVR_SET_NTPCFG = 225;//设置网络应用参数 NTP
  NET_DVR_GET_DDNSCFG = 226;//获取网络应用参数 DDNS
  NET_DVR_SET_DDNSCFG = 227;//设置网络应用参数 DDNS
  //对应NET_DVR_EMAILPARA
  NET_DVR_GET_EMAILCFG = 228;//获取网络应用参数 EMAIL
  NET_DVR_SET_EMAILCFG = 229;//设置网络应用参数 EMAIL

  NET_DVR_GET_NFSCFG = 230;/* NFS disk config */
  NET_DVR_SET_NFSCFG = 231;/* NFS disk config */

  NET_DVR_GET_SHOWSTRING_EX = 238;//获取叠加字符参数扩展(支持8条字符)
  NET_DVR_SET_SHOWSTRING_EX = 239;//设置叠加字符参数扩展(支持8条字符)
  NET_DVR_GET_NETCFG_OTHER = 244;//获取网络参数
  NET_DVR_SET_NETCFG_OTHER = 245;//设置网络参数

  //对应NET_DVR_EMAILCFG结构
  NET_DVR_GET_EMAILPARACFG = 250;//Get EMAIL parameters
  NET_DVR_SET_EMAILPARACFG = 251;//Setup EMAIL parameters

  NET_DVR_GET_DDNSCFG_EX = 274;//获取扩展DDNS参数
  NET_DVR_SET_DDNSCFG_EX = 275;//设置扩展DDNS参数

  NET_DVR_SET_PTZPOS = 292;//云台设置PTZ位置
  NET_DVR_GET_PTZPOS = 293;//云台获取PTZ位置
  NET_DVR_GET_PTZSCOPE = 294;//云台获取PTZ范围

  NET_DVR_GET_AP_INFO_LIST = 305;//获取无线网络资源参数
  NET_DVR_SET_WIFI_CFG = 306;//设置IP监控设备无线参数
  NET_DVR_GET_WIFI_CFG = 307;//获取IP监控设备无线参数
  NET_DVR_SET_WIFI_WORKMODE = 308;//设置IP监控设备网口工作模式参数
  NET_DVR_GET_WIFI_WORKMODE = 309;//获取IP监控设备网口工作模式参数
  NET_DVR_GET_WIFI_STATUS = 310;	//获取设备当前wifi连接状态
  //***************************DS9000新增命令(_V30) begin *****************************/
  //网络(NET_DVR_NETCFG_V30结构)
  NET_DVR_GET_NETCFG_V30 = 1000;//获取网络参数
  NET_DVR_SET_NETCFG_V30 = 1001;//设置网络参数

  //图象(NET_DVR_PICCFG_V30结构)
  NET_DVR_GET_PICCFG_V30 = 1002;//获取图象参数
  NET_DVR_SET_PICCFG_V30 = 1003;//设置图象参数

  //录像时间(NET_DVR_RECORD_V30结构)
  NET_DVR_GET_RECORDCFG_V30 = 1004;//获取录像参数
  NET_DVR_SET_RECORDCFG_V30 = 1005;//设置录像参数

  //用户(NET_DVR_USER_V30结构)
  NET_DVR_GET_USERCFG_V30 = 1006;//获取用户参数
  NET_DVR_SET_USERCFG_V30 = 1007;//设置用户参数

  //9000DDNS参数配置(NET_DVR_DDNSPARA_V30结构)
  NET_DVR_GET_DDNSCFG_V30 = 1010;//获取DDNS(9000扩展)
  NET_DVR_SET_DDNSCFG_V30 = 1011;//设置DDNS(9000扩展)

  //EMAIL功能(NET_DVR_EMAILCFG_V30结构)
  NET_DVR_GET_EMAILCFG_V30 = 1012;//获取EMAIL参数
  NET_DVR_SET_EMAILCFG_V30 = 1013;//设置EMAIL参数

  //巡航参数 (NET_DVR_CRUISE_PARA结构)
  NET_DVR_GET_CRUISE = 1020;
  NET_DVR_SET_CRUISE = 1021;

  //报警输入结构参数 (NET_DVR_ALARMINCFG_V30结构)
  NET_DVR_GET_ALARMINCFG_V30 = 1024;
  NET_DVR_SET_ALARMINCFG_V30 = 1025;

  //报警输出结构参数 (NET_DVR_ALARMOUTCFG_V30结构)
  NET_DVR_GET_ALARMOUTCFG_V30 = 1026;
  NET_DVR_SET_ALARMOUTCFG_V30 = 1027;

  //视频输出结构参数 (NET_DVR_VIDEOOUT_V30结构)
  NET_DVR_GET_VIDEOOUTCFG_V30 = 1028;
  NET_DVR_SET_VIDEOOUTCFG_V30 = 1029;

  //叠加字符结构参数 (NET_DVR_SHOWSTRING_V30结构)
  NET_DVR_GET_SHOWSTRING_V30 = 1030;
  NET_DVR_SET_SHOWSTRING_V30 = 1031;

  //异常结构参数 (NET_DVR_EXCEPTION_V30结构)
  NET_DVR_GET_EXCEPTIONCFG_V30 = 1034;
  NET_DVR_SET_EXCEPTIONCFG_V30 = 1035;

  //串口232结构参数 (NET_DVR_RS232CFG_V30结构)
  NET_DVR_GET_RS232CFG_V30 = 1036;
  NET_DVR_SET_RS232CFG_V30 = 1037;

  //网络硬盘接入结构参数 (NET_DVR_NET_DISKCFG结构)
  NET_DVR_GET_NET_DISKCFG = 1038;//网络硬盘接入获取
  NET_DVR_SET_NET_DISKCFG = 1039;//网络硬盘接入设置

  //压缩参数 (NET_DVR_COMPRESSIONCFG_V30结构)
  NET_DVR_GET_COMPRESSCFG_V30 = 1040;
  NET_DVR_SET_COMPRESSCFG_V30 = 1041;

  //获取485解码器参数 (NET_DVR_DECODERCFG_V30结构)
  NET_DVR_GET_DECODERCFG_V30 = 1042;//获取解码器参数
  NET_DVR_SET_DECODERCFG_V30 = 1043;//设置解码器参数

  //获取预览参数 (NET_DVR_PREVIEWCFG_V30结构)
  NET_DVR_GET_PREVIEWCFG_V30 = 1044;//获取预览参数
  NET_DVR_SET_PREVIEWCFG_V30 = 1045;//设置预览参数

  //辅助预览参数 (NET_DVR_PREVIEWCFG_AUX_V30结构)
  NET_DVR_GET_PREVIEWCFG_AUX_V30 = 1046;//获取辅助预览参数
  NET_DVR_SET_PREVIEWCFG_AUX_V30 = 1047;//设置辅助预览参数

  //IP接入配置参数 （NET_DVR_IPPARACFG结构）
  NET_DVR_GET_IPPARACFG = 1048; //获取IP接入配置信息
  NET_DVR_SET_IPPARACFG = 1049;//设置IP接入配置信息

  //IP接入配置参数 （NET_DVR_IPPARACFG_V40结构）
  NET_DVR_GET_IPPARACFG_V40 = 1062; //获取IP接入配置信息
  NET_DVR_SET_IPPARACFG_V40 = 1063;//设置IP接入配置信息

  //IP报警输入接入配置参数 （NET_DVR_IPALARMINCFG结构）
  NET_DVR_GET_IPALARMINCFG = 1050; //获取IP报警输入接入配置信息
  NET_DVR_SET_IPALARMINCFG = 1051; //设置IP报警输入接入配置信息

  //IP报警输出接入配置参数 （NET_DVR_IPALARMOUTCFG结构）
  NET_DVR_GET_IPALARMOUTCFG = 1052;//获取IP报警输出接入配置信息
  NET_DVR_SET_IPALARMOUTCFG = 1053;//设置IP报警输出接入配置信息

  //硬盘管理的参数获取 (NET_DVR_HDCFG结构)
  NET_DVR_GET_HDCFG = 1054;//获取硬盘管理配置参数
  NET_DVR_SET_HDCFG = 1055;//设置硬盘管理配置参数

  //盘组管理的参数获取 (NET_DVR_HDGROUP_CFG结构)
  NET_DVR_GET_HDGROUP_CFG = 1056;//获取盘组管理配置参数
  NET_DVR_SET_HDGROUP_CFG = 1057;//设置盘组管理配置参数

  //设备编码类型配置(NET_DVR_COMPRESSION_AUDIO结构)
  NET_DVR_GET_COMPRESSCFG_AUD = 1058;//获取设备语音对讲编码参数
  NET_DVR_SET_COMPRESSCFG_AUD = 1059;//设置设备语音对讲编码参数

  //IP接入配置参数 （NET_DVR_IPPARACFG_V31结构）
  NET_DVR_GET_IPPARACFG_V31 = 1060;//获取IP接入配置信息
  NET_DVR_SET_IPPARACFG_V31 = 1061; //设置IP接入配置信息

  //设备参数配置 （NET_DVR_DEVICECFG_V40结构）
  NET_DVR_GET_DEVICECFG_V40 = 1100;//获取设备参数
  NET_DVR_SET_DEVICECFG_V40 = 1101;//设置设备参数

  //多网卡配置(NET_DVR_NETCFG_MULTI结构)
  NET_DVR_GET_NETCFG_MULTI = 1161;
  NET_DVR_SET_NETCFG_MULTI = 1162;

  //BONDING网卡(NET_DVR_NETWORK_BONDING结构)
  NET_DVR_GET_NETWORK_BONDING = 1254;
  NET_DVR_SET_NETWORK_BONDING = 1255;

  //NAT映射配置参数 （NET_DVR_NAT_CFG结构）
  NET_DVR_GET_NAT_CFG = 6111;    //获取NAT映射参数
  NET_DVR_SET_NAT_CFG = 6112;    //设置NAT映射参数
  //*************************参数配置命令 end*******************************/

  //************************DVR日志 begin***************************/
  //* 报警 */
  //主类型
  MAJOR_ALARM = 1;
  //次类型
  MINOR_ALARM_IN = 1;/* 报警输入 */
  MINOR_ALARM_OUT = 2;/* 报警输出 */
  MINOR_MOTDET_START = 3; /* 移动侦测报警开始 */
  MINOR_MOTDET_STOP = 4; /* 移动侦测报警结束 */
  MINOR_HIDE_ALARM_START = 5;/* 遮挡报警开始 */
  MINOR_HIDE_ALARM_STOP = 6;/* 遮挡报警结束 */
  MINOR_VCA_ALARM_START = 7;/*智能报警开始*/
  MINOR_VCA_ALARM_STOP = 8;/*智能报警停止*/

  //* 异常 */
  //主类型
  MAJOR_EXCEPTION = 2;
  //次类型
  MINOR_VI_LOST = 33;/* 视频信号丢失 */
  MINOR_ILLEGAL_ACCESS = 34;/* 非法访问 */
  MINOR_HD_FULL = 35;/* 硬盘满 */
  MINOR_HD_ERROR = 36;/* 硬盘错误 */
  MINOR_DCD_LOST = 37;/* MODEM 掉线(保留不使用) */
  MINOR_IP_CONFLICT = 38;/* IP地址冲突 */
  MINOR_NET_BROKEN = 39;/* 网络断开*/
  MINOR_REC_ERROR = 40;/* 录像出错 */
  MINOR_IPC_NO_LINK = 41;/* IPC连接异常 */
  MINOR_VI_EXCEPTION = 42;/* 视频输入异常(只针对模拟通道) */
  MINOR_IPC_IP_CONFLICT = 43;/*ipc ip 地址 冲突*/

  //视频综合平台
  MINOR_FANABNORMAL = 49;/* 视频综合平台：风扇状态异常 */
  MINOR_FANRESUME = 50;/* 视频综合平台：风扇状态恢复正常 */
  MINOR_SUBSYSTEM_ABNORMALREBOOT = 51;/* 视频综合平台：6467异常重启 */
  MINOR_MATRIX_STARTBUZZER = 52;/* 视频综合平台：dm6467异常，启动蜂鸣器 */

  //* 操作 */
  //主类型
  MAJOR_OPERATION = 3;
  //次类型
  MINOR_START_DVR = 65;/* 开机 */
  MINOR_STOP_DVR = 66;/* 关机 */
  MINOR_STOP_ABNORMAL = 67;/* 异常关机 */
  MINOR_REBOOT_DVR = 68;/*本地重启设备*/

  MINOR_LOCAL_LOGIN = 80;/* 本地登陆 */
  MINOR_LOCAL_LOGOUT = 81;/* 本地注销登陆 */
  MINOR_LOCAL_CFG_PARM = 82;/* 本地配置参数 */
  MINOR_LOCAL_PLAYBYFILE = 83;/* 本地按文件回放或下载 */
  MINOR_LOCAL_PLAYBYTIME = 84;/* 本地按时间回放或下载*/
  MINOR_LOCAL_START_REC = 85;/* 本地开始录像 */
  MINOR_LOCAL_STOP_REC = 86;/* 本地停止录像 */
  MINOR_LOCAL_PTZCTRL = 87;/* 本地云台控制 */
  MINOR_LOCAL_PREVIEW = 88;/* 本地预览 (保留不使用)*/
  MINOR_LOCAL_MODIFY_TIME = 89;/* 本地修改时间(保留不使用) */
  MINOR_LOCAL_UPGRADE = 90;/* 本地升级 */
  MINOR_LOCAL_RECFILE_OUTPUT = 91;/* 本地备份录象文件 */
  MINOR_LOCAL_FORMAT_HDD = 92;/* 本地初始化硬盘 */
  MINOR_LOCAL_CFGFILE_OUTPUT = 93;/* 导出本地配置文件 */
  MINOR_LOCAL_CFGFILE_INPUT = 94;/* 导入本地配置文件 */
  MINOR_LOCAL_COPYFILE = 95;/* 本地备份文件 */
  MINOR_LOCAL_LOCKFILE = 96;/* 本地锁定录像文件 */
  MINOR_LOCAL_UNLOCKFILE = 97;/* 本地解锁录像文件 */
  MINOR_LOCAL_DVR_ALARM = 98;/* 本地手动清除和触发报警*/
  MINOR_IPC_ADD = 99;/* 本地添加IPC */
  MINOR_IPC_DEL = 100;/* 本地删除IPC */
  MINOR_IPC_SET = 101;/* 本地设置IPC */
  MINOR_LOCAL_START_BACKUP = 102;/* 本地开始备份 */
  MINOR_LOCAL_STOP_BACKUP = 103;/* 本地停止备份*/
  MINOR_LOCAL_COPYFILE_START_TIME = 104;/* 本地备份开始时间*/
  MINOR_LOCAL_COPYFILE_END_TIME = 105;/* 本地备份结束时间*/
  MINOR_LOCAL_ADD_NAS = 106;/*本地添加网络硬盘*/
  MINOR_LOCAL_DEL_NAS = 107;/* 本地删除nas盘*/
  MINOR_LOCAL_SET_NAS = 108;/* 本地设置nas盘*/

  MINOR_REMOTE_LOGIN = 112;/* 远程登录 */
  MINOR_REMOTE_LOGOUT = 113;/* 远程注销登陆 */
  MINOR_REMOTE_START_REC = 114;/* 远程开始录像 */
  MINOR_REMOTE_STOP_REC = 115;/* 远程停止录像 */
  MINOR_START_TRANS_CHAN = 116;/* 开始透明传输 */
  MINOR_STOP_TRANS_CHAN = 117;/* 停止透明传输 */
  MINOR_REMOTE_GET_PARM = 118;/* 远程获取参数 */
  MINOR_REMOTE_CFG_PARM = 119;/* 远程配置参数 */
  MINOR_REMOTE_GET_STATUS = 120;/* 远程获取状态 */
  MINOR_REMOTE_ARM = 121;/* 远程布防 */
  MINOR_REMOTE_DISARM = 122;/* 远程撤防 */
  MINOR_REMOTE_REBOOT = 123;/* 远程重启 */
  MINOR_START_VT = 124;/* 开始语音对讲 */
  MINOR_STOP_VT = 125;/* 停止语音对讲 */
  MINOR_REMOTE_UPGRADE = 126;/* 远程升级 */
  MINOR_REMOTE_PLAYBYFILE = 127;/* 远程按文件回放 */
  MINOR_REMOTE_PLAYBYTIME = 128;/* 远程按时间回放 */
  MINOR_REMOTE_PTZCTRL = 129;/* 远程云台控制 */
  MINOR_REMOTE_FORMAT_HDD = 130;/* 远程格式化硬盘 */
  MINOR_REMOTE_STOP = 131;/* 远程关机 */
  MINOR_REMOTE_LOCKFILE = 132;/* 远程锁定文件 */
  MINOR_REMOTE_UNLOCKFILE = 133;/* 远程解锁文件 */
  MINOR_REMOTE_CFGFILE_OUTPUT = 134;/* 远程导出配置文件 */
  MINOR_REMOTE_CFGFILE_INTPUT = 135;/* 远程导入配置文件 */
  MINOR_REMOTE_RECFILE_OUTPUT = 136;/* 远程导出录象文件 */
  MINOR_REMOTE_DVR_ALARM = 137;/* 远程手动清除和触发报警*/
  MINOR_REMOTE_IPC_ADD = 138;/* 远程添加IPC */
  MINOR_REMOTE_IPC_DEL = 139;/* 远程删除IPC */
  MINOR_REMOTE_IPC_SET = 140;/* 远程设置IPC */
  MINOR_REBOOT_VCA_LIB = 141;/*重启智能库*/
  MINOR_REMOTE_ADD_NAS = 142;/* 远程添加nas盘*/
  MINOR_REMOTE_DEL_NAS = 143;/* 远程删除nas盘*/
  MINOR_REMOTE_SET_NAS = 144;/* 远程设置nas盘*/

  //2009-12-16 增加视频综合平台日志类型
  MINOR_SUBSYSTEMREBOOT = 160;/*视频综合平台：dm6467 正常重启*/
  MINOR_MATRIX_STARTTRANSFERVIDEO = 161;	/*视频综合平台：矩阵切换开始传输图像*/
  MINOR_MATRIX_STOPTRANSFERVIDEO = 162;	/*视频综合平台：矩阵切换停止传输图像*/
  MINOR_REMOTE_SET_ALLSUBSYSTEM = 163;	/*视频综合平台：设置所有6467子系统信息*/
  MINOR_REMOTE_GET_ALLSUBSYSTEM = 164;	/*视频综合平台：获取所有6467子系统信息*/
  MINOR_REMOTE_SET_PLANARRAY = 165;	/*视频综合平台：设置计划轮询组*/
  MINOR_REMOTE_GET_PLANARRAY = 166;	/*视频综合平台：获取计划轮询组*/
  MINOR_MATRIX_STARTTRANSFERAUDIO = 167;	/*视频综合平台：矩阵切换开始传输音频*/
  MINOR_MATRIX_STOPRANSFERAUDIO = 168;	/*视频综合平台：矩阵切换停止传输音频*/
  MINOR_LOGON_CODESPITTER = 169;	/*视频综合平台：登陆码分器*/
  MINOR_LOGOFF_CODESPITTER = 170;	/*视频综合平台：退出码分器*/

  //*日志附加信息*/
  //主类型
  MAJOR_INFORMATION = 4;/*附加信息*/
  //次类型
  MINOR_HDD_INFO = 161;/*硬盘信息*/
  MINOR_SMART_INFO = 162;/*SMART信息*/
  MINOR_REC_START = 163;/*开始录像*/
  MINOR_REC_STOP = 164;/*停止录像*/
  MINOR_REC_OVERDUE = 165;/*过期录像删除*/
  MINOR_LINK_START = 166;//连接前端设备
  MINOR_LINK_STOP = 167;//断开前端设备　
  MINOR_NET_DISK_INFO = 168;//网络硬盘信息

  //当日志的主类型为MAJOR_OPERATION=03，次类型为MINOR_LOCAL_CFG_PARM=0x52或者MINOR_REMOTE_GET_PARM=0x76或者MINOR_REMOTE_CFG_PARM=0x77时，dwParaType:参数类型有效，其含义如下：
  PARA_VIDEOOUT = 1;
  PARA_IMAGE = 2;
  PARA_ENCODE = 4;
  PARA_NETWORK = 8;
  PARA_ALARM = 16;
  PARA_EXCEPTION = 32;
  PARA_DECODER = 64;/*解码器*/
  PARA_RS232 = 128;
  PARA_PREVIEW = 256;
  PARA_SECURITY = 512;
  PARA_DATETIME = 1024;
  PARA_FRAMETYPE = 2048;/*帧格式*/
  //vca
  PARA_VCA_RULE = 4096;//行为规则
  //************************DVR日志 End***************************/


  //*******************查找文件和日志函数返回值*************************/
  NET_DVR_FILE_SUCCESS = 1000;//获得文件信息
  NET_DVR_FILE_NOFIND = 1001;//没有文件
  NET_DVR_ISFINDING = 1002;//正在查找文件
  NET_DVR_NOMOREFILE = 1003;//查找文件时没有更多的文件
  NET_DVR_FILE_EXCEPTION = 1004;//查找文件时异常

  //*********************回调函数类型 begin************************/
  COMM_ALARM = 0x1100;//8000报警信息主动上传，对应NET_DVR_ALARMINFO
  COMM_ALARM_RULE = 0x1102;//行为分析报警信息，对应NET_VCA_RULE_ALARM
  COMM_ALARM_PDC = 0x1103;//人流量统计报警上传，对应NET_DVR_PDC_ALRAM_INFO
  COMM_ALARM_ALARMHOST = 0x1105;//网络报警主机报警上传，对应NET_DVR_ALARMHOST_ALARMINFO
  COMM_ALARM_FACE = 0x1106;//人脸检测识别报警信息，对应NET_DVR_FACEDETECT_ALARM
  COMM_RULE_INFO_UPLOAD = 0x1107;  // 事件数据信息上传
  COMM_ALARM_AID = 0x1110;  //交通事件报警信息
  COMM_ALARM_TPS = 0x1111;  //交通参数统计报警信息
  COMM_UPLOAD_FACESNAP_RESULT = 0x1112;  //人脸识别结果上传
  COMM_ALARM_TFS = 0x1113;  //交通取证报警信息
  COMM_ALARM_TPS_V41 = 0x1114;  //交通参数统计报警信息扩展
  COMM_ALARM_AID_V41 = 0x1115;  //交通事件报警信息扩展
  COMM_ALARM_VQD_EX =  0x1116;	 //视频质量诊断报警
  COMM_SENSOR_VALUE_UPLOAD = 0x1120;  //模拟量数据实时上传
  COMM_SENSOR_ALARM  = 0x1121;  //模拟量报警上传
  COMM_SWITCH_ALARM   = 0x1122;	 //开关量报警
  COMM_ALARMHOST_EXCEPTION   =  0x1123; //报警主机故障报警
  COMM_ALARMHOST_OPERATEEVENT_ALARM  = 0x1124;  //操作事件报警上传
  COMM_ALARMHOST_SAFETYCABINSTATE = 0x1125;	 //防护舱状态
  COMM_ALARMHOST_ALARMOUTSTATUS  = 0x1126;	 //报警输出口/警号状态
  COMM_ALARMHOST_CID_ALARM 	 = 0x1127;	 //报告报警上传
  COMM_ALARMHOST_EXTERNAL_DEVICE_ALARM = 0x1128;	 //报警主机外接设备报警上传
  COMM_ALARMHOST_DATA_UPLOAD    = 0x1129;	 //报警数据上传
  COMM_ALARM_AUDIOEXCEPTION	 =  0x1150;	 //声音报警信息
  COMM_ALARM_DEFOCUS    =      0x1151;	 //虚焦报警信息
  COMM_ALARM_BUTTON_DOWN_EXCEPTION =  0x1152;	 //按钮按下报警信息
  COMM_ALARM_ALARMGPS   =    0x1202; //GPS报警信息上传
  COMM_TRADEINFO      =  0x1500;  //ATMDVR主动上传交易信息
  COMM_UPLOAD_PLATE_RESULT  =   0x2800;	 //上传车牌信息
  COMM_ITC_STATUS_DETECT_RESULT  = 0x2810;  //实时状态检测结果上传(智能高清IPC)
  COMM_IPC_AUXALARM_RESULT  = 0x2820;  //PIR报警、无线报警、呼救报警上传
  COMM_UPLOAD_PICTUREINFO    = 0x2900;	 //上传图片信息
  COMM_SNAP_MATCH_ALARM   = 0x2902;  //黑名单比对结果上传
  COMM_ITS_PLATE_RESULT   =  0x3050;  //终端图片上传
  COMM_ITS_TRAFFIC_COLLECT  = 0x3051;  //终端统计数据上传
  COMM_ITS_GATE_VEHICLE = 0x3052;  //出入口车辆抓拍数据上传
  COMM_ITS_GATE_FACE  = 0x3053 ; //出入口人脸抓拍数据上传
  COMM_ITS_GATE_COSTITEM = 0x3054;  //出入口过车收费明细 2013-11-19
  COMM_ITS_GATE_HANDOVER = 0x3055 ; //出入口交接班数据 2013-11-19
  COMM_ITS_PARK_VEHICLE  = 0x3056;  //停车场数据上传
  COMM_ITS_BLACKLIST_ALARM  = 0x3057;  //黑名单报警上传
  COMM_ALARM_V30	 =  0x4000;	 //9000报警信息主动上传
  COMM_IPCCFG	 =  0x4001;	 //9000设备IPC接入配置改变报警信息主动上传
  COMM_IPCCFG_V31 = 0x4002;	 //9000设备IPC接入配置改变报警信息主动上传扩展 9000_1.1
  COMM_IPCCFG_V40 =  0x4003; // IVMS 2000 编码服务器 NVR IPC接入配置改变时报警信息上传
  COMM_ALARM_DEVICE = 0x4004;  //设备报警内容，由于通道值大于256而扩展
  COMM_ALARM_CVR	 =  0x4005;  //CVR 2.0.X外部报警类型
  COMM_ALARM_HOT_SPARE = 0x4006;  //热备异常报警（N+1模式异常报警）
  COMM_ALARM_V40 = 0x4007;	//移动侦测，视频丢失，遮挡，IO信号量等报警信息主动上传，报警数据为可变长

  COMM_ITS_ROAD_EXCEPTION = 0x4500;	 //路口设备异常报警
  COMM_ITS_EXTERNAL_CONTROL_ALARM = 0x4520;  //外控报警
  COMM_SCREEN_ALARM    =  0x5000;  //多屏控制器报警类型
  COMM_DVCS_STATE_ALARM = 0x5001;  //分布式大屏控制器报警上传
  COMM_ALARM_VQD		 = 0x6000;  //VQD主动报警上传
  COMM_PUSH_UPDATE_RECORD_INFO  = 0x6001;  //推模式录像信息上传
  COMM_DIAGNOSIS_UPLOAD = 0x5100;  //诊断服务器VQD报警上传

  //*************操作异常类型(消息方式, 回调方式(保留))****************/
  EXCEPTION_EXCHANGE = 32768;//用户交互时异常
  EXCEPTION_AUDIOEXCHANGE = 32769;//语音对讲异常
  EXCEPTION_ALARM = 32770;//报警异常
  EXCEPTION_PREVIEW = 32771;//网络预览异常
  EXCEPTION_SERIAL = 32772;//透明通道异常
  EXCEPTION_RECONNECT = 32773;//预览时重连
  EXCEPTION_ALARMRECONNECT = 32774;//报警时重连
  EXCEPTION_SERIALRECONNECT = 32775;//透明通道重连
  EXCEPTION_PLAYBACK = 32784;//回放异常
  EXCEPTION_DISKFMT = 32785;//硬盘格式化

  //********************预览回调函数*********************/
  NET_DVR_SYSHEAD = 1;//系统头数据
  NET_DVR_STREAMDATA = 2;//视频流数据（包括复合流和音视频分开的视频流数据）
  NET_DVR_AUDIOSTREAMDATA = 3;//音频流数据
  NET_DVR_STD_VIDEODATA = 4;//标准视频流数据
  NET_DVR_STD_AUDIODATA = 5;//标准音频流数据

  //回调预览中的状态和消息
  NET_DVR_REALPLAYEXCEPTION = 111;//预览异常
  NET_DVR_REALPLAYNETCLOSE = 112;//预览时连接断开
  NET_DVR_REALPLAY5SNODATA = 113;//预览5s没有收到数据
  NET_DVR_REALPLAYRECONNECT = 114;//预览重连

  //********************回放回调函数*********************/
  NET_DVR_PLAYBACKOVER = 101;//回放数据播放完毕
  NET_DVR_PLAYBACKEXCEPTION = 102;//回放异常
  NET_DVR_PLAYBACKNETCLOSE = 103;//回放时候连接断开
  NET_DVR_PLAYBACK5SNODATA = 104;//回放5s没有收到数据

  //*********************回调函数类型 end************************/
  //设备型号(DVR类型)
  //* 设备类型 */
  DVR = 1;/*对尚未定义的dvr类型返回NETRET_DVR*/
  ATMDVR = 2;/*atm dvr*/
  DVS = 3;/*DVS*/
  DEC = 4;/* 6001D */
  ENC_DEC = 5;/* 6001F */
  DVR_HC = 6;/*8000HC*/
  DVR_HT = 7;/*8000HT*/
  DVR_HF = 8;/*8000HF*/
  DVR_HS = 9;/* 8000HS DVR(no audio) */
  DVR_HTS = 10; /* 8016HTS DVR(no audio) */
  DVR_HB = 11; /* HB DVR(SATA HD) */
  DVR_HCS = 12; /* 8000HCS DVR */
  DVS_A = 13; /* 带ATA硬盘的DVS */
  DVR_HC_S = 14; /* 8000HC-S */
  DVR_HT_S = 15;/* 8000HT-S */
  DVR_HF_S = 16;/* 8000HF-S */
  DVR_HS_S = 17; /* 8000HS-S */
  ATMDVR_S = 18;/* ATM-S */
  LOWCOST_DVR = 19;/*7000H系列*/
  DEC_MAT = 20; /*多路解码器*/
  DVR_MOBILE = 21;/* mobile DVR */
  DVR_HD_S = 22;   /* 8000HD-S */
  DVR_HD_SL = 23;/* 8000HD-SL */
  DVR_HC_SL = 24;/* 8000HC-SL */
  DVR_HS_ST = 25;/* 8000HS_ST */
  DVS_HW = 26; /* 6000HW */
  DS630X_D = 27; /* 多路解码器 */
  IPCAM = 30;/*IP 摄像机*/
  MEGA_IPCAM = 31;/*X52MF系列,752MF,852MF*/
  IPCAM_X62MF = 32;/*X62MF系列可接入9000设备,762MF,862MF*/
  IPDOME = 40; /*IP 标清球机*/
  IPDOME_MEGA200 = 41;/*IP 200万高清球机*/
  IPDOME_MEGA130 = 42;/*IP 130万高清球机*/
  IPMOD = 50;/*IP 模块*/
  DS71XX_H = 71;/* DS71XXH_S */
  DS72XX_H_S = 72;/* DS72XXH_S */
  DS73XX_H_S = 73;/* DS73XXH_S */
  DS76XX_H_S = 76;/* DS76XX_H_S */
  DS81XX_HS_S = 81;/* DS81XX_HS_S */
  DS81XX_HL_S = 82;/* DS81XX_HL_S */
  DS81XX_HC_S = 83;/* DS81XX_HC_S */
  DS81XX_HD_S = 84;/* DS81XX_HD_S */
  DS81XX_HE_S = 85;/* DS81XX_HE_S */
  DS81XX_HF_S = 86;/* DS81XX_HF_S */
  DS81XX_AH_S = 87;/* DS81XX_AH_S */
  DS81XX_AHF_S = 88;/* DS81XX_AHF_S */
  DS90XX_HF_S = 90;  /*DS90XX_HF_S*/
  DS91XX_HF_S = 91;  /*DS91XX_HF_S*/
  DS91XX_HD_S = 92; /*91XXHD-S(MD)*/
  //**********************设备类型 end***********************/

  {*************************************************
  参数配置结构、参数(其中_V30为9000新增)
  **************************************************}
  //校时结构参数

  //时间参数


  //时间段(子结构)

  //*设备报警和异常处理方式*/
  NOACTION = 0x0;/*无响应*/
  WARNONMONITOR = 0x1;/*监视器上警告*/
  WARNONAUDIOOUT = 0x2;/*声音警告*/
  UPTOCENTER = 0x4;/*上传中心*/
  TRIGGERALARMOUT = 0x8;/*触发报警输出*/
  TRIGGERCATPIC = 0x10;/*触发抓图并上传E-mail*/
  SEND_PIC_FTP = 0x200;  /*抓图并上传ftp*/


  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出*/
  //*0x10: 触发JPRG抓图并上传Email*/
  //*0x20: 无线声光报警器联动*/
  //*0x40: 联动电子地图(目前只有PCNVR支持)*/
  //*0x200: 抓图并上传FTP*/

  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出*/
  //*0x10: 触发JPRG抓图并上传Email*/
  //*0x20: 无线声光报警器联动*/
  //*0x40: 联动电子地图(目前只有PCNVR支持)*/
  //*0x200: 抓图并上传FTP*/

  //报警和异常处理结构(子结构)(多处使用)(9000扩展)
  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出*/
  //*0x10: 触发JPRG抓图并上传Email*/
  //*0x20: 无线声光报警器联动*/
  //*0x40: 联动电子地图(目前只有PCNVR支持)*/
  //*0x200: 抓图并上传FTP*/

  //报警和异常处理结构(子结构)(多处使用)
  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出*/
  //*0x10: Jpeg抓图并上传EMail*/

  //DVR设备参数
  //以下不可更改

  //*IP地址*/

  /// char[16]

  /// BYTE[128]


  //*网络数据结构(子结构)(9000扩展)*/

  //*网络数据结构(子结构)*/

  //pppoe结构

  //网络配置结构(9000扩展)

  //单个网卡配置信息结构体

  //多网卡网络配置结构

  //网络配置结构


  //IP可视对讲分机配置

  //Ip可视对讲音频相关参数配置

  //IP分机呼叫对讲参数配置结构体

  //通道图象结构
  //移动侦测(子结构)(按组方式扩展)

  //通道图象结构
  //移动侦测(子结构)(9000扩展)

  //移动侦测(子结构)

  //遮挡报警(子结构)(9000扩展)  区域大小704*576

  //遮挡报警(子结构)  区域大小704*576

  //信号丢失报警(子结构)(9000扩展)

  //信号丢失报警(子结构)

  //遮挡区域(子结构)


  //通道图象结构(9000扩展)
  //显示通道名
  //视频信号丢失报警
  //移动侦测
  //遮挡报警
  //遮挡  区域大小704*576
  //OSD
  //* 0: XXXX-XX-XX 年月日 */
  //* 1: XX-XX-XXXX 月日年 */
  //* 2: XXXX年XX月XX日 */
  //* 3: XX月XX日XXXX年 */
  //* 4: XX-XX-XXXX 日月年*/
  //* 5: XX日XX月XXXX年 */
  //* 0: 不显示OSD */
  //* 1: 透明,闪烁 */
  //* 2: 透明,不闪烁 */
  //* 3: 闪烁,不透明 */
  //* 4: 不透明,不闪烁 */

  //通道图象结构SDK_V14扩展
  //显示通道名
  //信号丢失报警
  //移动侦测
  //遮挡报警
  //遮挡  区域大小704*576
  //OSD
  //* 0: XXXX-XX-XX 年月日 */
  //* 1: XX-XX-XXXX 月日年 */
  //* 2: XXXX年XX月XX日 */
  //* 3: XX月XX日XXXX年 */
  //* 4: XX-XX-XXXX 日月年*/
  //* 5: XX日XX月XXXX年 */
  //* 0: 不显示OSD */
  //* 1: 透明,闪烁 */
  //* 2: 透明,不闪烁 */
  //* 3: 闪烁,不透明 */
  //* 4: 不透明,不闪烁 */

  //通道图象结构(SDK_V13及之前版本)
  //显示通道名
  //信号丢失报警
  //移动侦测
  //遮挡报警
  //遮挡  区域大小704*576
  //OSD
  //* 0: XXXX-XX-XX 年月日 */
  //* 1: XX-XX-XXXX 月日年 */
  //* 2: XXXX年XX月XX日 */
  //* 3: XX月XX日XXXX年 */
  //* 4: XX-XX-XXXX 日月年*/
  //* 5: XX日XX月XXXX年 */
  //* 0: 不显示OSD */
  //* 1: 透明,闪烁 */
  //* 2: 透明,不闪烁 */
  //* 3: 闪烁,不透明 */
  //* 4: 不透明,不闪烁 */

  //码流压缩参数(子结构)(9000扩展)
  // 13-384K 14-448K 15-512K 16-640K 17-768K 18-896K 19-1024K 20-1280K 21-1536K 22-1792K 23-2048K
  //最高位(31位)置成1表示是自定义码流, 0-30位表示码流值。
  //2006-08-11 增加单P帧的配置接口，可以改善实时流延时问题

  //通道压缩参数(9000扩展)

  //码流压缩参数(子结构)
  // 13-384K 14-448K 15-512K 16-640K 17-768K 18-896K 19-1024K 20-1280K 21-1536K 22-1792K 23-2048K
  //最高位(31位)置成1表示是自定义码流, 0-30位表示码流值(MIN-32K MAX-8192K)。

  //通道压缩参数

  //码流压缩参数(子结构)(扩展) 增加I帧间隔
  // 13-384K 14-448K 15-512K 16-640K 17-768K 18-896K 19-1024K 20-1280K 21-1536K 22-1792K 23-2048K
  //最高位(31位)置成1表示是自定义码流, 0-30位表示码流值(MIN-32K MAX-8192K)。
  //2006-08-11 增加单P帧的配置接口，可以改善实时流延时问题

  //通道压缩参数(扩展)

  //时间段录像参数配置(子结构)

  //全天录像参数配置(子结构)

  //通道录像参数配置(9000扩展)

  //通道录像参数配置

  //云台协议表结构配置

  //***************************云台类型(end)******************************/

  //通道解码器(云台)参数配置(9000扩展)

  //通道解码器(云台)参数配置

  //ppp参数配置(子结构)

  //ppp参数配置(子结构)

  //RS232串口参数配置(9000扩展)

  //RS232串口参数配置(9000扩展)

  //RS232串口参数配置




  //报警输入参数配置(256路NVR扩展)
  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出*/
  //*0x10: 触发JPRG抓图并上传Email*/
  //*0x20: 无线声光报警器联动*/
  //*0x40: 联动电子地图(目前只有PCNVR支持)*/
  //*0x200: 抓图并上传FTP*/
  //*触发的录像通道*/

  //报警输入参数配置(9000扩展)







  //报警输入参数配置

  //模拟报警输入参数配置

  //上传报警信息(9000扩展)






  //////////////////////////////////////////////////////////////////////////////////////
  //IPC接入参数配置
  //* IP设备结构 */


  //ipc接入设备信息扩展，支持ip设备的域名添加


  //* IP通道匹配参数 */

  //* IP接入配置结构 */



  //* 扩展IP接入配置结构 */




  //*流媒体服务器基本配置*/
  //设备通道信息









  //uGetStream.Init();

  //* V40扩展IP接入配置结构 */





  //为CVR扩展的报警类型
  //3-编码器状态异常；4-系统时钟异常；5-录像卷剩余容量过低；
  //6-编码器(通道)移动侦测报警；7-编码器(通道)遮挡报警。

  //* 报警输出参数 */


  //* IP报警输出配置结构 */

  //* IP报警输出参数 */

  //*IP报警输出*/

  //* 报警输入参数 */

  //* IP报警输入配置结构 */
  //* IP报警输入参数 */
  //*IP报警输入资源*/

  //ipc alarm info

  //ipc配置改变报警信息扩展 9000_1.1



  //本地硬盘信息配置
  // dwStorageType & 0x1 表示是否是普通录像专用存储盘
  // dwStorageType & 0x2  表示是否是抽帧录像专用存储盘
  // dwStorageType & 0x4 表示是否是图片录像专用存储盘



  //本地盘组信息配置扩展


  //本地盘组信息配置


  //配置缩放参数的结构

  //DVR报警输出(9000扩展)
  //0-5秒,1-10秒,2-30秒,3-1分钟,4-2分钟,5-5分钟,6-10分钟,7-手动

  //DVR报警输出
  //0-5秒,1-10秒,2-30秒,3-1分钟,4-2分钟,5-5分钟,6-10分钟,7-手动

  //DVR本地预览参数(9000扩展)

  //DVR本地预览参数

  //DVR视频输出

  //MATRIX输出参数结构



  //DVR视频输出(9000扩展)

  //DVR视频输出

  //单用户参数(子结构)(扩展)
  //*数组0: 本地控制云台*/
  //*数组1: 本地手动录象*/
  //*数组2: 本地回放*/
  //*数组3: 本地设置参数*/
  //*数组4: 本地查看状态、日志*/
  //*数组5: 本地高级操作(升级，格式化，重启，关机)*/
  //*数组6: 本地查看参数 */
  //*数组7: 本地管理模拟和IP camera */
  //*数组8: 本地备份 */
  //*数组9: 本地关机/重启 */
  //*数组0: 远程控制云台*/
  //*数组1: 远程手动录象*/
  //*数组2: 远程回放 */
  //*数组3: 远程设置参数*/
  //*数组4: 远程查看状态、日志*/
  //*数组5: 远程高级操作(升级，格式化，重启，关机)*/
  //*数组6: 远程发起语音对讲*/
  //*数组7: 远程预览*/
  //*数组8: 远程请求报警上传、报警输出*/
  //*数组9: 远程控制，本地输出*/
  //*数组10: 远程控制串口*/
  //*数组11: 远程查看参数 */
  //*数组12: 远程管理模拟和IP camera */
  //*数组13: 远程关机/重启 */
  {* 无……表示不支持优先级的设置
  低……默认权限:包括本地和远程回放,本地和远程查看日志和状态,本地和远程关机/重启
  中……包括本地和远程控制云台,本地和远程手动录像,本地和远程回放,语音对讲和远程预览、本地备份,本地/远程关机/重启
  高……管理员 *}

  //单用户参数(子结构)(9000扩展)
  //*数组0: 本地控制云台*/
  //*数组1: 本地手动录象*/
  //*数组2: 本地回放*/
  //*数组3: 本地设置参数*/
  //*数组4: 本地查看状态、日志*/
  //*数组5: 本地高级操作(升级，格式化，重启，关机)*/
  //*数组6: 本地查看参数 */
  //*数组7: 本地管理模拟和IP camera */
  //*数组8: 本地备份 */
  //*数组9: 本地关机/重启 */
  //*数组0: 远程控制云台*/
  //*数组1: 远程手动录象*/
  //*数组2: 远程回放 */
  //*数组3: 远程设置参数*/
  //*数组4: 远程查看状态、日志*/
  //*数组5: 远程高级操作(升级，格式化，重启，关机)*/
  //*数组6: 远程发起语音对讲*/
  //*数组7: 远程预览*/
  //*数组8: 远程请求报警上传、报警输出*/
  //*数组9: 远程控制，本地输出*/
  //*数组10: 远程控制串口*/
  //*数组11: 远程查看参数 */
  //*数组12: 远程管理模拟和IP camera */
  //*数组13: 远程关机/重启 */
  {*
  无……表示不支持优先级的设置
  低……默认权限:包括本地和远程回放,本地和远程查看日志和状态,本地和远程关机/重启
  中……包括本地和远程控制云台,本地和远程手动录像,本地和远程回放,语音对讲和远程预览
  本地备份,本地/远程关机/重启
  高……管理员
  *}

  //单用户参数(SDK_V15扩展)(子结构)
  //*数组0: 本地控制云台*/
  //*数组1: 本地手动录象*/
  //*数组2: 本地回放*/
  //*数组3: 本地设置参数*/
  //*数组4: 本地查看状态、日志*/
  //*数组5: 本地高级操作(升级，格式化，重启，关机)*/
  //*数组0: 远程控制云台*/
  //*数组1: 远程手动录象*/
  //*数组2: 远程回放 */
  //*数组3: 远程设置参数*/
  //*数组4: 远程查看状态、日志*/
  //*数组5: 远程高级操作(升级，格式化，重启，关机)*/
  //*数组6: 远程发起语音对讲*/
  //*数组7: 远程预览*/
  //*数组8: 远程请求报警上传、报警输出*/
  //*数组9: 远程控制，本地输出*/
  //*数组10: 远程控制串口*/

  //单用户参数(子结构)
  //*数组0: 本地控制云台*/
  //*数组1: 本地手动录象*/
  //*数组2: 本地回放*/
  //*数组3: 本地设置参数*/
  //*数组4: 本地查看状态、日志*/
  //*数组5: 本地高级操作(升级，格式化，重启，关机)*/
  //*数组0: 远程控制云台*/
  //*数组1: 远程手动录象*/
  //*数组2: 远程回放 */
  //*数组3: 远程设置参数*/
  //*数组4: 远程查看状态、日志*/
  //*数组5: 远程高级操作(升级，格式化，重启，关机)*/
  //*数组6: 远程发起语音对讲*/
  //*数组7: 远程预览*/
  //*数组8: 远程请求报警上传、报警输出*/
  //*数组9: 远程控制，本地输出*/
  //*数组10: 远程控制串口*/

  //DVR用户参数(扩展)

  //DVR用户参数(9000扩展)

  //DVR用户参数(SDK_V15扩展)

  //DVR用户参数

  //异常参数配置扩展结构体

  //DVR异常参数(9000扩展)
  //*数组0-盘满,1- 硬盘出错,2-网线断,3-局域网内IP 地址冲突, 4-非法访问, 5-输入/输出视频制式不匹配, 6-视频信号异常, 7-录像异常*/

  //DVR异常参数
  //*数组0-盘满,1- 硬盘出错,2-网线断,3-局域网内IP 地址冲突,4-非法访问, 5-输入/输出视频制式不匹配, 6-视频信号异常*/

  //通道状态(9000扩展)



  //通道状态

  //硬盘状态

  //设备工作状态扩展结构体


  //DVR工作状态(9000扩展)


  //DVR工作状态


  //日志信息(9000扩展)

  //日志信息

  //************************动环报警管理主机日志查找 begin************************************************/

  //*************************动环报警管理主机日志查找 end***********************************************/

  //报警输出状态(9000扩展)


  //报警输出状态

  //ATM专用
  //****************************ATM(begin)***************************/
  NCR = 0;
  DIEBOLD = 1;
  WINCOR_NIXDORF = 2;
  SIEMENS = 3;
  OLIVETTI = 4;
  FUJITSU = 5;
  HITACHI = 6;
  SMI = 7;
  IBM = 8;
  BULL = 9;
  YiHua = 10;
  LiDe = 11;
  GDYT = 12;
  Mini_Banl = 13;
  GuangLi = 14;
  DongXin = 15;
  ChenTong = 16;
  NanTian = 17;
  XiaoXing = 18;
  GZYY = 19;
  QHTLT = 20;
  DRS918 = 21;
  KALATEL = 22;
  NCR_2 = 23;
  NXS = 24;

  //交易信息

  //*帧格式*/

  //ATM参数

  //SDK_V31 ATM
  //*过滤设置*/

  //*起始标识设置*/

  //*报文信息位置*/

  //*报文信息长度*/

  //*OSD 叠加的位置*/

  //*日期显示格式*/

  //*时间显示格式*/






  //用户自定义协议


  //协议信息数据结构



  //*****************************DS-6001D/F(begin)***************************/
  //DS-6001D Decoder


  //*解码设备控制码定义*/
  NET_DEC_STARTDEC = 1;
  NET_DEC_STOPDEC = 2;
  NET_DEC_STOPCYCLE = 3;
  NET_DEC_CONTINUECYCLE = 4;

  //*连接的通道配置*/

  //*每个解码通道的配置*/

  //*整个设备解码配置*/

  //2005-08-01
  //* 解码设备透明通道设置 */



  //* 控制网络文件回放 */




  //*当前设备解码连接状态*/




  //*****************************DS-6001D/F(end)***************************/

  //单字符参数(子结构)

  //叠加字符(9000扩展)

  //叠加字符扩展(8条字符)

  //叠加字符

  //****************************DS9000新增结构(begin)******************************/
  //*EMAIL参数结构*/
  //与原结构体有差异






  //*DVR实现巡航数据结构*/
  //****************************DS9000新增结构(end)******************************/
  //时间点

  //夏令时参数

  //图片质量
  {*注意：当图像压缩分辨率为VGA时，支持0=CIF, 1=QCIF, 2=D1抓图，
  当分辨率为3=UXGA(1600x1200), 4=SVGA(800x600), 5=HD720p(1280x720),6=VGA,7=XVGA, 8=HD900p
  仅支持当前分辨率的抓图*}

  //* aux video out parameter */
  //辅助输出参数配置

  //ntp

  //ddns


  //9000扩展


  //email

  //网络参数配置

  //nfs结构配置






  //巡航点配置(HIK IP快球专用)




  //************************************多路解码器(begin)***************************************/


  //启动/停止动态解码



  //连接的通道配置 2007-11-05

  //2007-11-05 新增每个解码通道的配置

  //2007-12-22

  {*
  *	多路解码器本地有1个485串口，1个232串口都可以作为透明通道,设备号分配如下：
  *	0 RS485
  *	1 RS232 Console
  *}
  {*
  *	远程串口输出还是两个,一个RS232，一个RS485
  *	1表示232串口
  *	2表示485串口
  *}


  //2007-12-24 Merry Christmas Eve...



  //2009-4-11 added by likui 多路解码器new

  {*
  *	多路解码器本地有1个485串口，1个232串口都可以作为透明通道,设备号分配如下：
  *	0 RS485
  *	1 RS232 Console
  *}
  {*
  *	远程串口输出还是两个,一个RS232，一个RS485
  *	1表示232串口
  *	2表示485串口
  *}





  //*流媒体服务器基本配置*/

  //设备通道信息


  //动态域名参数配置

  //动态域名取流配置

  //取流模式配置联合体


  MAX_RESOLUTIONNUM = 64; //支持的最大分辨率数目


  //上传logo结构

  //*编码类型*/
  NET_DVR_ENCODER_UNKOWN = 0;/*未知编码格式*/
  NET_DVR_ENCODER_H264 = 1;/*HIK 264*/
  NET_DVR_ENCODER_S264 = 2;/*Standard H264*/
  NET_DVR_ENCODER_MPEG4 = 3;/*MPEG4*/
  NET_DVR_ORIGINALSTREAM = 4;/*Original Stream*/
  NET_DVR_PICTURE = 5;//*Picture*/
  NET_DVR_ENCODER_MJPEG = 6;
  NET_DVR_ECONDER_MPEG2 = 7;
  //* 打包格式 */
  NET_DVR_STREAM_TYPE_UNKOWN = 0;/*未知打包格式*/
  NET_DVR_STREAM_TYPE_HIKPRIVT = 1; /*海康自定义打包格式*/
  NET_DVR_STREAM_TYPE_TS = 7;/* TS打包 */
  NET_DVR_STREAM_TYPE_PS = 8;/* PS打包 */
  NET_DVR_STREAM_TYPE_RTP = 9;/* RTP打包 */

  //*解码通道状态*/

  //*显示通道状态*/
  NET_DVR_MAX_DISPREGION = 16;         /*每个显示通道最多可以显示的窗口*/
  //VGA分辨率，目前能用的是：VGA_THS8200_MODE_XGA_60HZ、VGA_THS8200_MODE_SXGA_60HZ、
  //
  //*VGA*/
  //*HDMI*/
  //*DVI*/

  //低帧率定义
  LOW_DEC_FPS_1_2 = 51;
  LOW_DEC_FPS_1_4 = 52;
  LOW_DEC_FPS_1_8 = 53;
  LOW_DEC_FPS_1_16 = 54;

  //*视频制式标准*/

  //*各个子窗口对应解码通道所对应的解码子系统的槽位号(对于视频综合平台中解码子系统有效)*/






  MAX_DECODECHANNUM = 32;//多路解码器最大解码通道数
  MAX_DISPCHANNUM = 24;//多路解码器最大显示通道数

  //*解码器设备状态*/

  //2009-12-1 增加被动解码播放控制

  PASSIVE_DEC_PAUSE = 1;	/*被动解码暂停(仅文件流有效)*/
  PASSIVE_DEC_RESUME = 2;	/*恢复被动解码(仅文件流有效)*/
  PASSIVE_DEC_FAST = 3;   /*快速被动解码(仅文件流有效)*/
  PASSIVE_DEC_SLOW = 4;   /*慢速被动解码(仅文件流有效)*/
  PASSIVE_DEC_NORMAL = 5;   /*正常被动解码(仅文件流有效)*/
  PASSIVE_DEC_ONEBYONE =	6;  /*被动解码单帧播放(保留)*/
  PASSIVE_DEC_AUDIO_ON = 7;   /*音频开启*/
  PASSIVE_DEC_AUDIO_OFF = 8; 	 /*音频关闭*/
  PASSIVE_DEC_RESETBUFFER = 9;    /*清空缓冲区*/

  //2009-12-16 增加控制解码器解码通道缩放
  //************************************多路解码器(end)***************************************/

  //************************************视频综合平台(begin)***************************************/
  MAX_SUBSYSTEM_NUM = 80;   //一个矩阵系统中最多子系统数量
  MAX_SUBSYSTEM_NUM_V40 = 120;   //一个矩阵系统中最多子系统数量
  MAX_SERIALLEN = 36;  //最大序列号长度
  MAX_LOOPPLANNUM = 16;  //最大计划切换组
  DECODE_TIMESEGMENT = 4;     //计划解码每天时间段数

  MAX_DOMAIN_NAME = 64;  /* 最大域名长度 */
  MAX_DISKNUM_V30 = 33; //9000设备最大硬盘数/* 最多33个硬盘(包括16个内置SATA硬盘、1个eSATA硬盘和16个NFS盘) */
  MAX_DAYS = 7;       //每周天数
  MAX_DISPNUM_V41 = 32;
  MAX_WINDOWS_NUM = 12;
  MAX_VOUTNUM = 32;
  MAX_SUPPORT_RES = 32;
  MAX_BIGSCREENNUM = 100;

  VIDEOPLATFORM_ABILITY = 0x210; //视频综合平台能力集
  MATRIXDECODER_ABILITY_V41 = 0x260; //解码器能力集

  NET_DVR_MATRIX_BIGSCREENCFG_GET = 1140;//获取大屏拼接参数







  //************************************视频综合平台(end)***************************************/



  //*子系统类型，1-解码用子系统，2-编码用子系统，3-级联输出子系统，4-级联输入子系统，5-码分器子系统，6-报警主机子系统，7-智能子系统，8-V6解码子系统，9-V6子系统，0-NULL（此参数只能获取）*/

  //增强型被大屏关联为子屏后资源可被借用，普通型则不能被借用)

  //  [FieldOffsetAttribute(0)]



  //大屏拼接从屏幕信息
  //起始坐标必须为基准坐标的整数倍


  //************************************视频综合平台(end)***************************************/



  //球机位置信息

  //球机范围信息

  //rtsp配置 ipcamera专用

  //********************************接口参数结构(begin)*********************************/

  //NET_DVR_Login()参数结构

  //NET_DVR_Login_V30()参数结构
  //bySupport & 0x1, 表示是否支持智能搜索
  //bySupport & 0x2, 表示是否支持备份
  //bySupport & 0x4, 表示是否支持压缩参数能力获取
  //bySupport & 0x8, 表示是否支持多网卡
  //bySupport & 0x10, 表示支持远程SADP
  //bySupport & 0x20, 表示支持Raid卡功能
  //bySupport & 0x40, 表示支持IPSAN 目录查找
  //bySupport & 0x80, 表示支持rtp over rtsp
  //bySupport1 & 0x1, 表示是否支持snmp v30
  //bySupport1 & 0x2, 支持区分回放和下载
  //bySupport1 & 0x4, 是否支持布防优先级
  //bySupport1 & 0x8, 智能设备是否支持布防时间段扩展
  //bySupport1 & 0x10, 表示是否支持多磁盘数（超过33个）
  //bySupport1 & 0x20, 表示是否支持rtsp over http
  //bySupport1 & 0x80, 表示是否支持车牌新报警信息2012-9-28, 且还表示是否支持NET_DVR_IPPARACFG_V40结构体
  //bySupport3 & 0x1, 表示是否多码流
  // bySupport3 & 0x4 表示支持按组配置， 具体包含 通道图像参数、报警输入参数、IP报警输入、输出接入参数、
  // 用户参数、设备工作状态、JPEG抓图、定时和时间抓图、硬盘盘组管理
  //bySupport3 & 0x8为1 表示支持使用TCP预览、UDP预览、多播预览中的"延时预览"字段来请求延时预览（后续都将使用这种方式请求延时预览）。而当bySupport3 & 0x8为0时，将使用 "私有延时预览"协议。
  //bySupport3 & 0x10 表示支持"获取报警主机主要状态（V40）"。
  //bySupport3 & 0x20 表示是否支持通过DDNS域名解析取流

  //  byLanguageType 等于0 表示 老设备
  //  byLanguageType & 0x1表示支持中文
  //  byLanguageType & 0x2表示支持英文

  //sdk网络环境枚举变量，用于远程升级

  //显示模式

  //发送模式

  //抓图模式

  //实时声音模式


  //SDK状态信息(9000新增)

  //SDK功能支持信息(9000新增)

  //报警设备信息

  //硬解码显示区域参数(子结构)

  //硬解码预览参数

  //录象文件参数

  //录象文件参数(9000)
  //3-报警|移动侦测 4-报警&移动侦测 5-命令触发 6-手动录像,7－震动报警，8-环境报警，9-智能报警，10-PIR报警，11-无线报警，12-呼救报警,14-智能交通事件

  //录象文件参数(cvr)
  //3-报警|移动侦测 4-报警&移动侦测 5-命令触发 6-手动录像,7－震动报警，8-环境报警，9-智能报警，10-PIR报警，11-无线报警，12-呼救报警,14-智能交通事件

  //录象文件参数(带卡号)

  //录象文件查找条件结构
  //3-报警|移动侦测 4-报警&移动侦测 5-命令触发 6-手动录像

  //云台区域选择放大缩小(HIK 快球专用)

  //语音对讲参数

















  //wifi连接状态


  //智能控制信息
  MAX_VCA_CHAN = 16;//最大智能通道数
  // byControlType &1 是否启用抓拍功能

  //智能控制信息结构

  //智能设备能力集
  //bySupport & 0x1，表示是否支持智能跟踪 2012-3-22
  //bySupport & 0x2，表示是否支持128路取流扩展2012-12-27

  //行为分析能力类型

  //智能通道类型

  //智能ATM模式类型(ATM能力特有)

  //行为分析场景模式

  //通道能力输入参数

  //行为能力集结构
  // bySupport & 0x01 支持标定功能

  // 交通能力集结构
  //***********************************end*******************************************/

  //************************************智能参数结构*********************************/
  //智能共用结构
  //坐标值归一化,浮点数值为当前画面的百分比大小, 精度为小数点后三位
  //点坐标结构

  //区域框结构

  //行为分析事件类型

  //行为分析事件类型扩展

  //警戒面穿越方向类型

  //线结构

  //             public void init()
  //             {
  //                 struStart = new NET_VCA_POINT();
  //                 struEnd = new NET_VCA_POINT();
  //             }

  //该结构会导致xaml界面出不来！！！！！！！！！？？问题暂时还没有找到
  //暂时屏蔽结构先
  //多边型结构体
  /// DWORD->unsigned int


  //             public void init()
  //             {
  //                 struPlaneBottom = new NET_VCA_LINE();
  //                 struPlaneBottom.init();
  //                 byRes2 = new byte[38];
  //             }

  //进入/离开区域参数

  //根据报警延迟时间来标识报警中带图片，报警间隔和IO报警一致，1秒发送一个。
  //入侵参数

  //徘徊参数

  //丢包/捡包参数

  //停车参数

  //奔跑参数

  //人员聚集参数

  //剧烈运动参数

  //攀高参数

  //起床参数

  //物品遗留

  // 物品拿取



  //贴纸条参数

  //读卡器参数

  //离岗事件

  //尾随参数

  //倒地参数

  //声强突变参数






  //警戒事件参数

  //[FieldOffsetAttribute(0)]
  //public NET_VCA_TRAVERSE_PLANE struTraversePlane;//穿越警戒面参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_AREA struArea;//进入/离开区域参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_INTRUSION struIntrusion;//入侵参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_LOITER struLoiter;//徘徊参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_TAKE_LEFT struTakeTeft;//丢包/捡包参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_PARKING struParking;//停车参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_RUN struRun;//奔跑参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_HIGH_DENSITY struHighDensity;//人员聚集参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_VIOLENT_MOTION struViolentMotion;	//剧烈运动
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_REACH_HIGHT struReachHight;      //攀高
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_GET_UP struGetUp;           //起床
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_LEFT struLeft;            //物品遗留
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_TAKE struTake;            // 物品拿取
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_HUMAN_ENTER struHumanEnter;      //人员进入
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_OVER_TIME struOvertime;        //操作超时
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_STICK_UP struStickUp;//贴纸条
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_SCANNER struScanner;//读卡器参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_LEAVE_POSITION struLeavePos;        //离岗参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_TRAIL struTrail;           //尾随参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_FALL_DOWN struFallDown;        //倒地参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_AUDIO_ABNORMAL struAudioAbnormal;   //声强突变
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_ADV_REACH_HEIGHT struReachHeight;     //折线攀高参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_TOILET_TARRY struToiletTarry;     //如厕超时参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_YARD_TARRY struYardTarry;       //放风场滞留参数
  //[FieldOffsetAttribute(0)]
  //public NET_VCA_ADV_TRAVERSE_PLANE struAdvTraversePlane;//折线警戒面参数

  // 尺寸过滤器类型

  //尺寸过滤器

  //警戒规则结构

  //行为分析配置结构体

  //尺寸过滤策略

  //规则触发参数

  //警戒规则结构

  //行为分析配置结构体

  //简化目标结构体

  //简化的规则信息, 包含规则的基本信息

  //前端设备地址信息，智能分析仪表示的是前端设备的地址信息，其他设备表示本机的地址

  //行为分析结果上报结构

  //行为分析规则DSP信息叠加结构

  //物体类型

  //物体颜色条件结构体

  //图片参数

  //颜色联合体

  //物体颜色参数结构体

  //区域类型

  //辅助区域

  //辅助区域列表

  //通道工作模式

  //通道工作模式参数结构体

  //设备通道参数结构体

  //从通道信息联合体

  //从通道参数结构体


  //从通道参数配置结构体

  //视频质量诊断检测事件

  //视频质量诊断事件条件结构体

  //视频质量诊断事件参数

  //视频质量诊断事件规则

  //基准场景参数

  //基准场景操作参数结构体

  //视频质量诊断报警结构体

  //标定点子结构

  //标定参数配置结构

  //球机配置结构

  //跟踪模式

  //手动控制结构

  //跟踪模式结构


  //分析仪行为分析规则结构
  //警戒规则结构

  // 分析仪规则结构

  // IVMS行为分析配置结构

  //智能分析仪取流计划子结构

  //智能分析仪参数配置结构

  //屏蔽区域

  //屏蔽区域链表结构

  //ATM进入区域参数

  //IVMS屏蔽区域链表

  //IVMS的ATM进入区域参数

  // ivms 报警图片上传结构

  // IVMS 后检索配置

  //************************************end******************************************/
  //NAS认证配置




  //网络硬盘结构配置

  MAX_NET_DISK = 16;


  //事件类型
  //主类型

  INQUEST_START_INFO = 0x1001;      /*讯问开始信息*/
  INQUEST_STOP_INFO = 0x1002;       /*讯问停止信息*/
  INQUEST_TAG_INFO = 0x1003;       /*重点标记信息*/
  INQUEST_SEGMENT_INFO = 0x1004;      /*审讯片断状态信息*/


  //行为分析主类型对应的此类型， 0xffff表示全部

  // 主类型100，对应的小类型

  //邦诺CVR
  MAX_ID_COUNT = 256;
  MAX_STREAM_ID_COUNT = 1024;
  STREAM_ID_LEN = 32;
  PLAN_ID_LEN = 32;

  // 流信息 - 72字节长

  //事件搜索条件 200-04-07 9000_1.1
  SEARCH_EVENT_INFO_LEN = 300;

  //报警输入


  //报警输入 按值表示


  //移动侦测


  //移动侦测--按值


  //行为分析


  //行为分析--按值方式查找

  //审讯事件搜索条件

  //智能侦测查找条件

  //智能侦测查找条件 ，通道号按值表示




  //报警输入结果

  //移动侦测结果

  //行为分析结果


  //审讯事件查询结果


  //流id录像查询结果


  //struMotionRet = new EVENT_MOTION_RET();
  //struMotionRet.init();
  //查找返回结果


  //SDK_V35  2009-10-26

  // 标定配置类型

  MAX_RECT_NUM = 6;

  // PDC 标定参数

  // 标定线的属性类别，用来表示当前标定线在实际表示的是高度线还是长度线。
  //*在设置标定信息的时候，如果相应位设置了使能，并设置相关参数，若没有设置使能，则标定后可以获取相关的摄像机参数*/

  {*当fValue表示目标高度的时候，struStartPoint和struEndPoint分别表示目标头部点和脚部点。
  * 当fValue表示线段长度的时候，struStartPoint和struEndPoint分别表示线段起始点和终点，
  * mode表示当前样本线表示高度线还是长度线。*}

  MAX_LINE_SEG_NUM = 8;

  //*标定样本线目前需要4-8调样本线，以获取摄像机相关参数*/

  {*该结构体表示IAS智能库标定样本，其中包括一个目标框和一条对应的高度标定线；
  * 目标框为站立的人体外接矩形框；高度线样本标识从人头顶点到脚点的标定线；用归一化坐标表示；*}

  MAX_SAMPLE_NUM = 5;


  CALIB_PT_NUM = 4;

  // 标定参数联合体
  // 后续的相关标定参数可以放在该结构里面

  // 标定配置结构

  //流量统计方向结构体



  //试用版信息结构体




  //byControlType &1 是否启用抓拍功能
  //byControlType &2 是否启用联动前端设备

  {*设置人流量统计参数  复用行为内部关键字参数
  * HUMAN_GENERATE_RATE
  * 目标生成速度参数，控制PDC库生成目标的速度。速度越快，目标越容易生成。
  * 当输入视频光照条件较差，对比度较低时，或者设置的规则区域较小时，应加快目标生成速度， 避免目标的漏检；
  * 当输入视频中对比度较高时，或者规则区域较大时，应该降低目标生成速度，以减少误检。
  * 目标生成速度参数共有5级，1级速度最慢，5级最快，默认参数为3。
  *
  * DETECT_SENSITIVE
  * 目标检测灵敏度控制参数，控制PDC库中一个矩形区域被检测为目标的灵敏度。
  * 灵敏度越高，矩形区域越容易被检测为目标，灵敏度越低则越难检测为目标。
  * 当输入视频光照条件较差，对比度较低时，应提高检测灵敏度， 避免目标的漏检；
  * 当输入视频中对比度较高时，应该降低检测灵敏度，以减少误检。
  * 对应参数共有5级，级别1灵敏度最低，5级最高，默认级别为3。
  *
  * TRAJECTORY_LEN
  * 轨迹生成长度控制参数，表示生成轨迹时要求目标的最大位移像素。
  * 对应参数共有5级，级别1，生成长度最长，轨迹生成最慢，5级生成长度最短，轨迹生成最快，默认级别为3。
  *
  * TRAJECT_CNT_LEN
  * 轨迹计数长度控制参数，表示轨迹计数时要求目标的最大位移像素。
  * 对应参数共有5级，级别1，计数要求长度最长，轨迹计数最慢，5级计数要求长度最短，轨迹计数最快，默认级别为3。
  *
  * PREPROCESS
  * 图像预处理控制参数，0 - 不处理；1 - 处理。默认为0；
  *
  * CAMERA_ANGLE
  * 摄像机角度输入参数， 0 - 倾斜； 1 - 垂直。默认为0；
  *}




  //单帧统计结果时使用


  //单帧统计结果时使用


  //人流量信息查询

  // 是否启用场景，在设置场景行为规则的时候该字段无效，在设置球机本地配置场景位置信息时作为使能位





  MAX_POSITION_NUM = 10;

  //巡航路径场景信息

  //场景巡航跟踪配置信息

  //球机本地规则菜单配置结构体

  //球机机芯参数

  //********************************智能交通事件 begin****************************************/
  MAX_REGION_NUM	= 8;  // 区域列表最大数目
  MAX_TPS_RULE = 8;   // 最大参数规则数目
  MAX_AID_RULE = 8;   // 最大事件规则数目
  MAX_LANE_NUM = 8;   // 最大车道数目

  //交通事件类型



  // 交通统计参数


  //方向结构体

  //单个车道

  //车道配置

  //交通事件参数

  //单条交通事件规则结构体

  //交通事件规则

  //单条交通事件规则结构体(扩展)

  //交通事件规则(扩展)

  //交通统计参数结构体

  //交通参数统计规则配置结构体

  //交通统计参数结构体(扩展)

  //交通参数统计规则配置结构体(扩展)

  //交通事件信息

  //交通事件报警

  //车道队列结构体








  //人脸规则配置





  //目前只有有人无人事件和人员聚集事件实时报警上传



  //单条场景时间段

  //场景起效时间段配置

  //单条场景配置信息

  //场景配置结构体

  //多场景操作条件

  //取证方式

  //报警场景信息

  //交通事件报警(扩展)

  //交通统计信息报警(扩展)

  //*******************************智能交通事件 end*****************************************/

  //******************************车牌识别 begin******************************************/


  //车牌识别结果子结构

  //******************************车牌识别 end******************************************/

  //******************************抓拍机*******************************************/
  //IO输入配置

  //IO输出配置

  //闪光灯配置

  //红绿灯功能（2个IO输入一组）

  //测速功能(2个IO输入一组）

  //视频参数配置

  //增益配置

  //白平衡配置

  //曝光控制

  //宽动态配置

  //日夜转换功能配置
  //定时模式参数
  //模式2
  //定时模式参数
  //报警输入触发模式参数

  //Gamma校正

  //背光补偿配置

  //数字降噪功能

  //CMOS模式下前端镜头配置

  //前端参数配置
  //20-HDMI_720P50输出开
  //21-HDMI_720P60输出开
  //22-HDMI_1080I60输出开
  //23-HDMI_1080I50输出开
  //24-HDMI_1080P24输出开
  //25-HDMI_1080P25输出开
  //26-HDMI_1080P30输出开
  //27-HDMI_1080P50输出开
  //28-HDMI_1080P60输出开
  //40-SDI_720P50,
  //41-SDI_720P60,
  //42-SDI_1080I50,
  //43-SDI_1080I60,
  //44-SDI_1080P24,
  //45-SDI_1080P25,
  //46-SDI_1080P30,
  //47-SDI_1080P50,
  //48-SDI_1080P60

  //透雾

  //电子防抖

  //走廊模式

  //SMART IR(防过曝)配置参数

  //在byIrisMode 为P-Iris1时生效，配置红外光圈大小等级，配置模式

  //前端参数配置
  //20-HDMI_720P50输出开
  //21-HDMI_720P60输出开
  //22-HDMI_1080I60输出开
  //23-HDMI_1080I50输出开
  //24-HDMI_1080P24输出开
  //25-HDMI_1080P25输出开
  //26-HDMI_1080P30输出开
  //27-HDMI_1080P50输出开
  //28-HDMI_1080P60输出开

  {*0-关闭、1-640*480@25fps、2-640*480@30ps、3-704*576@25fps、4-704*480@30fps、5-1280*720@25fps、6-1280*720@30fps、
  * 7-1280*720@50fps、8-1280*720@60fps、9-1280*960@15fps、10-1280*960@25fps、11-1280*960@30fps、
  * 12-1280*1024@25fps、13--1280*1024@30fps、14-1600*900@15fps、15-1600*1200@15fps、16-1920*1080@15fps、
  * 17-1920*1080@25fps、18-1920*1080@30fps、19-1920*1080@50fps、20-1920*1080@60fps、21-2048*1536@15fps、22-2048*1536@20fps、
  * 23-2048*1536@24fps、24-2048*1536@25fps、25-2048*1536@30fps、26-2560*2048@25fps、27-2560*2048@30fps、
  * 28-2560*1920@7.5fps、29-3072*2048@25fps、30-3072*2048@30fps、31-2048*1536@12.5、32-2560*1920@6.25、
  * 33-1600*1200@25、34-1600*1200@30、35-1600*1200@12.5、36-1600*900@12.5、37-1600@900@15、38-800*600@25、39-800*600@30*}

  //车牌颜色

  //车牌类型






  //图像叠加信息配置




  // bySupport&0x1，表示是否支持扩展的字符叠加配置
  // bySupport&0x2，表示是否支持扩展的校时配置结构
  // bySupport&0x4, 表示是否支持多网卡(多网隔离)
  // bySupport&0x8, 表示是否支持网卡的bonding功能(网络容错)
  // bySupport&0x10, 表示是否支持语音对讲
  //2013-07-09 能力集返回
  // wSupportMultiRadar&0x1，表示 卡口RS485雷达 支持车道关联雷达处理
  // wSupportMultiRadar&0x2，表示 卡口虚拟线圈 支持车道关联雷达处理
  // wSupportMultiRadar&0x4，表示 混行卡口 支持车道关联雷达处理
  // wSupportMultiRadar&0x8，表示 视频检测 支持车道关联雷达处理
  // 表示支持的ICR预置点（滤光片偏移点）数
  // byExpandRs485SupportSensor &0x1，表示电警车检器支持车检器
  // byExpandRs485SupportSensor &0x2，表示卡式电警车检器支持车检器
  // byExpandRs485SupportSignalLampDet &0x1，表示电警车检器支持外接信号灯检测器
  // byExpandRs485SupportSignalLampDet &0x2，表示卡式电警车检器支持外接信号灯检测器







  //2013-07-09 异常处理
  //*0x00: 无响应*/
  //*0x01: 监视器上警告*/
  //*0x02: 声音警告*/
  //*0x04: 上传中心*/
  //*0x08: 触发报警输出（继电器输出）*/
  //*0x10: 触发JPRG抓图并上传Email*/
  //*0x20: 无线声光报警器联动*/
  //*0x40: 联动电子地图(目前只有PCNVR支持)*/
  //*0x200: 抓图并上传FTP*/

  //数组的每个元素都表示一种异常，数组0- 硬盘出错,1-网线断,2-IP 地址冲突, 3-车检器异常, 4-信号灯检测器异常




  //场景模式



  //*ftp上传参数*/

  //*可用来命名图片的相关元素 */
  PICNAME_ITEM_DEV_NAME = 1;		/*设备名*/
  PICNAME_ITEM_DEV_NO = 2;		/*设备号*/
  PICNAME_ITEM_DEV_IP = 3;		/*设备IP*/
  PICNAME_ITEM_CHAN_NAME = 4;	/*通道名*/
  PICNAME_ITEM_CHAN_NO = 5;		/*通道号*/
  PICNAME_ITEM_TIME = 6;		/*时间*/
  PICNAME_ITEM_CARDNO = 7;		/*卡号*/
  PICNAME_ITEM_PLATE_NO = 8;   /*车牌号码*/
  PICNAME_ITEM_PLATE_COLOR = 9;   /*车牌颜色*/
  PICNAME_ITEM_CAR_CHAN = 10;  /*车道号*/
  PICNAME_ITEM_CAR_SPEED = 11;  /*车辆速度*/
  PICNAME_ITEM_CARCHAN = 12;  /*监测点*/
  PICNAME_ITEM_PIC_NUMBER = 13;  //图片序号
  PICNAME_ITEM_CAR_NUMBER = 14;  //车辆序号

  PICNAME_ITEM_SPEED_LIMIT_VALUES = 15; //限速值
  PICNAME_ITEM_ILLEGAL_CODE = 16; //国标违法代码
  PICNAME_ITEM_CROSS_NUMBER = 17; //路口编号
  PICNAME_ITEM_DIRECTION_NUMBER = 18; //方向编号

  PICNAME_MAXITEM = 15;
  //图片命名


  //命名规则：2013-09-27
  PICNAME_ITEM_PARK_DEV_IP = 1;	/*设备IP*/
  PICNAME_ITEM_PARK_PLATE_NO = 2;/*车牌号码*/
  PICNAME_ITEM_PARK_TIME = 3;	/*时间*/
  PICNAME_ITEM_PARK_INDEX = 4;   /*车位编号*/
  PICNAME_ITEM_PARK_STATUS = 5;  /*车位状态*/

  //图片命名扩展 2013-09-27

  //* 串口抓图设置*/

  //DVR抓图参数配置（基线）

  //抓拍触发请求结构(保留)


  //使用闪光灯补光时, 如果考虑减弱闪光灯的亮度增强效应, 则需要设为1;否则为0


  //***************************** end *********************************************/
  IPC_PROTOCOL_NUM = 50;  //ipc 协议最大个数

  //协议类型

  //协议列表

  MAX_ALERTLINE_NUM = 8; //最大警戒线条数

  //越界侦测查询条件

  MAX_INTRUSIONREGION_NUM = 8; //最大区域数数



  //智能搜索参数
  //*0-移动侦测区域 ，1-越界侦测， 2-区域入侵*/


  //IPSAN 文件目录查找


  //DVR设备参数
  //以下不可更改
  //bySupport & 0x1, 表示是否支持智能搜索
  //bySupport & 0x2, 表示是否支持备份
  //bySupport & 0x4, 表示是否支持压缩参数能力获取
  //bySupport & 0x8, 表示是否支持多网卡
  //bySupport & 0x10, 表示支持远程SADP
  //bySupport & 0x20, 表示支持Raid卡功能
  //bySupport & 0x40, 表示支持IPSAN搜索
  //bySupport & 0x80, 表示支持rtp over rtsp
  //bySupport1 & 0x1, 表示是否支持snmp v30
  //bySupport1 & 0x2, 支持区分回放和下载
  //bySupport1 & 0x4, 是否支持布防优先级
  //bySupport1 & 0x8, 智能设备是否支持布防时间段扩展
  //bySupport1 & 0x10, 表示是否支持多磁盘数（超过33个）
  //bySupport1 & 0x20, 表示是否支持rtsp over http
  //bySupport2 & 0x1, 表示是否支持扩展的OSD字符叠加(终端和抓拍机扩展区分)

  MAX_ZEROCHAN_NUM = 16;
  //零通道压缩配置参数
  //V2.0增加14-15, 15-18, 16-22;

  //零通道缩放参数

  DESC_LEN_64 = 64;


  //snmpv30

  PROCESSING = 0;    //正在处理
  PROCESS_SUCCESS = 100;   //过程完成
  PROCESS_EXCEPTION = 400;   //过程异常
  PROCESS_FAILED = 500;   //过程失败
  PROCESS_QUICK_SETUP_PD_COUNT = 501; //一键配置至少3块硬盘

  SOFTWARE_VERSION_LEN = 48;


  MAX_SADP_NUM = 256;  //搜索到设备最大数目

  //***************************** end *********************************************/

  //*******************************备份结构 begin********************************/
  //获取备份设备信息接口定义
  DESC_LEN_32 = 32;   //描述字长度
  MAX_NODE_NUM = 256;  //节点个数



  //备份进度列表
  BACKUP_SUCCESS            =    100;  //备份完成
  BACKUP_CHANGE_DEVICE      =    101;  //备份设备已满，更换设备继续备份

  BACKUP_SEARCH_DEVICE      =    300;  //正在搜索备份设备
  BACKUP_SEARCH_FILE        =    301;  //正在搜索录像文件
  BACKUP_SEARCH_LOG_FILE    =    302;  //正在搜索日志文件

  BACKUP_EXCEPTION		   =    400;  //备份异常
  BACKUP_FAIL			   =	500;  //备份失败

  BACKUP_TIME_SEG_NO_FILE   =    501;  //时间段内无录像文件
  BACKUP_NO_RESOURCE        =    502;  //申请不到资源
  BACKUP_DEVICE_LOW_SPACE   =    503;  //备份设备容量不足
  BACKUP_DISK_FINALIZED     =    504;  //刻录光盘封盘
  BACKUP_DISK_EXCEPTION     =    505;  //刻录光盘异常
  BACKUP_DEVICE_NOT_EXIST   =    506;  //备份设备不存在
  BACKUP_OTHER_BACKUP_WORK  =    507;  //有其他备份操作在进行
  BACKUP_USER_NO_RIGHT      =    508;  //用户没有操作权限
  BACKUP_OPERATE_FAIL       =    509;  //操作失败
  BACKUP_NO_LOG_FILE        =    510;  //硬盘中无日志

  //备份过程接口定义

  //********************************* end *******************************************/

  //能力列表

  MAX_ABILITYTYPE_NUM = 12;   //最大能力项

  // 压缩参数能力列表

  //模式A



  //联合体大小 12字节



  MAX_HOLIDAY_NUM = 32;


  //假日报警处理方式


  MAX_LINK_V30 = 128;



  MAX_BOND_NUM = 2;

  //单BONDING网卡配置结构体

  //BONDING网卡配置结构体


  //磁盘配额


  //6-10m 7-30m 8-1h 9-12h 10-24h


  MAX_PIC_EVENT_NUM = 32;
  MAX_ALARMIN_CAPTURE = 16;








  //通道抓图计划



  //录像标签
  LABEL_NAME_LEN = 40;

  LABEL_IDENTIFY_LEN = 64;


  MAX_DEL_LABEL_IDENTIFY = 20;// 删除的最大标签标识个数



  //标签搜索结构体

  //标签信息结构体

  CARDNUM_LEN_V30 = 40;

  PICTURE_NAME_LEN = 64;


  MAX_RECORD_PICTURE_NUM = 50;   //最大备份图片张数



  STEP_READY      = 0;    //准备升级
  STEP_RECV_DATA  = 1;    //接收升级包数据
  STEP_UPGRADE    = 2;    //升级系统
  STEP_BACKUP     = 3;    //备份系统
  STEP_SEARCH     = 255;  //搜索升级文件








  //*各个子窗口对应解码通道所对应的解码子系统的槽位号(对于视频综合平台中解码子系统有效)*/
  //显示窗口所解视频分辨率，1-D1,2-720P,3-1080P，设备端需要根据此//分辨率进行解码通道的分配，如1分屏配置成1080P，则设备会把4个解码通
  //道都分配给此解码通道


  //*区分共用体，0-视频综合平台内部解码器显示通道配置，1-其他解码器显示通道配置*/





  NET_DVR_V6PSUBSYSTEMARAM_GET = 1501;//获取V6子系统配置
  NET_DVR_V6PSUBSYSTEMARAM_SET = 1502;//设置V6子系统配置


  MAX_REDAREA_NUM = 6;   //最大红绿灯区域个数



  INQUEST_MESSAGE_LEN  = 44;    //审讯重点标记信息长度
  INQUEST_MAX_ROOM_NUM = 2;    //最大审讯室个数
  MAX_RESUME_SEGMENT   = 2;     //支持同时恢复的片段数目




  //0x1:米乐 0x2:镭彩 0x4:优力

  //6-160、7-192、8-224、9-256、10-320、11-384、12-448、
  //13-512、14-640、15-768、16-896前16个值保留)17-1024、18-1280、19-1536、
  //20-1792、21-2048、22-3072、23-4096、24-8192
  //8-16小时, 9-20小时,10-22小时,11-24小时








  //通过获取DVR的网络状态：单位bps

  //通过DVR设置前端IPC的IP地址

  //按时间锁定


  //67DVS
  //证书下载类型


  //下载状态





  //证书相关


  UPLOAD_CERTIFICATE = 1; //上传证书


  //channel record status
  //***通道录像状态*****//


  //****NVR end***//


  //*窗口信息*/



  //2011-04-18
  //*摄像机信息,最多9999个，从1开始 */

  //*监视器信息，最多2048个*/




  //*矩阵配置信息，最多20个*/


  //*串口配置信息*/

  //最多256个用户，1～256

  //最多255个资源组

  //最多255个用户组



  MATRIX_PROTOCOL_NUM   = 20;    //支持的最大矩阵协议数
  KEYBOARD_PROTOCOL_NUM = 20;    //支持的最大键盘协议数



  //人脸抓拍规则(单条)

  //人脸抓拍规则参数

  //人脸抓拍结果报警上传

  //虚焦侦测结果









  //籍贯参数结构体

  //人员信息结构体


  //黑名单信息





  MAX_FACE_PIC_LEN = 6144;   //最大人脸图片数据长度




  //联合体大小为44字节



  //人脸抓拍信息
  //黑名单报警信息

  //黑名单比对结果报警上传







  //单个分区配置

  //存储路径设置

  //********************************智能人脸识别 end****************************/
  //分辨率
  NOT_AVALIABLE = 0;
  SVGA_60HZ = 52505660;
  SVGA_75HZ = 52505675;
  XGA_60HZ = 67207228;
  XGA_75HZ = 67207243;
  SXGA_60HZ = 84017212;
  SXGA2_60HZ = 84009020;
  _720P_60HZ = 83978300;
  _720P_50HZ = 83978290;
  _1080I_60HZ = 394402876;
  _1080I_50HZ = 394402866;
  _1080P_60HZ = 125967420;
  _1080P_50HZ = 125967410;
  _1080P_30HZ = 125967390;
  _1080P_25HZ = 125967385;
  _1080P_24HZ = 125967384;
  UXGA_60HZ = 105011260;
  UXGA_30HZ = 105011230;
  WSXGA_60HZ = 110234940;
  WUXGA_60HZ = 125982780;
  WUXGA_30HZ = 125982750;
  WXGA_60HZ = 89227324;
  SXGA_PLUS_60HZ = 91884860;

  //显示通道画面分割模式

  //显示通道信息

  //大屏拼接信息



  MAX_WINDOWS = 16;//最大窗口数
  MAX_WINDOWS_V41 = 36;

  STARTDISPCHAN_VGA = 1;
  STARTDISPCHAN_BNC = 9;
  STARTDISPCHAN_HDMI	= 25;
  STARTDISPCHAN_DVI = 29;




  //*显示通道配置结构体*/

  //*解码器设备状态*/

  //*解码器设备状态*/
  //*显示通道状态*/

  //*******************************文件回放-远程回放设置*******************************/

  MAX_BIGSCREENNUM_SCENE = 100;

  //显示通道配置结构

  //显示窗口所解视频分辨率，1-D1,2-720P,3-1080P，设备端需要根据此//分辨率进行解码通道的分配，如1分屏配置成1080P，则设备会把4个解码通道都分配给此解码通道


  //*流媒体服务器基本配置*/



  //轮巡解码结构

  //单个解码通道配置结构体

  //[FieldOffsetAttribute(0)]
  //[MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 5480, ArraySubType = UnmanagedType.I1)]
  //public byte[] byRes;



  NET_DVR_GET_ALLWINCFG = 1503; //窗口参数获取


  //*******************************窗口设置*******************************/
  MAX_WIN_COUNT = 224; //支持的最大开窗数



  MAX_LAYOUT_COUNT = 16;		//最大布局数



  MAX_CAM_COUNT = 224;




  //*******************************输出参数配置*******************************/
  //*输出通道管理*/


  //*******************************能力集*******************************/
  SCREEN_PROTOCOL_NUM = 20;   //支持的最大大屏控制器协议数

  //多屏服务器能力集

  //多屏控制器能力集

  //*******************************输入信号状态*******************************/










  //*******************************底图上传*******************************/

  //*******************************OSD*******************************/
  MAX_OSDCHAR_NUM = 256;


  //*******************************获取串口信息*******************************/

  //*******************************屏幕控制*******************************/
  //屏幕输入源控制


  //显示单元颜色控制

  //显示单元位置控制



  //*******************************屏幕控制V41*******************************/

  //*******************************预案管理*******************************/
  MAX_PLAN_ACTION_NUM = 32; 	//预案动作个数
  DAYS_A_WEEK = 7;	//一周7天
  MAX_PLAN_COUNT = 16;	//预案个数


  //*预案项信息*/


  //*预案管理*/

  //*******************************获取设备状态*******************************/
  //*预案列表*/

  //*******************************预案控制*******************************/
  //该结构体可作为通用控制结构体

  //*******************************获取设备状态*******************************/

  //91系列HD-SDI高清DVR 相机信息




  //安全拔盘状态
  PULL_DISK_SUCCESS = 1;     // 安全拔盘成功
  PULL_DISK_FAIL = 2;        // 安全拔盘失败
  PULL_DISK_PROCESSING = 3;  // 正在停止阵列
  PULL_DISK_NO_ARRAY = 4;	// 阵列不存在
  PULL_DISK_NOT_SUPPORT = 5; // 不支持安全拔盘

  //扫描阵列状态
  SCAN_RAID_SUC = 1; 	// 扫描阵列成功
  SCAN_RAID_FAIL = 2; 	// 扫描阵列失败
  SCAN_RAID_PROCESSING = 3;	// 正在扫描阵列
  SCAN_RAID_NOT_SUPPORT = 4; // 不支持阵列扫描

  //设置前端相机类型状态
  SET_CAMERA_TYPE_SUCCESS = 1;  // 成功
  SET_CAMERA_TYPE_FAIL = 2;  // 失败
  SET_CAMERA_TYPE_PROCESSING	= 3;   // 正在处理

  //9000 2.2



  //端口映射配置结构体

  //端口映射配置结构体

  //Upnp端口映射状态结构体

  //Upnp端口映射状态结构体


  //录像回放结构体






  MAX_PRO_PATH = 256; //最大协议路径长度


  //预览V40接口

  ///抓拍机
  ///
  MAX_OVERLAP_ITEM_NUM = 50;       //最大字符叠加种数
  NET_ITS_GET_OVERLAP_CFG = 5072;//获取字符叠加参数配置（相机或ITS终端）
  NET_ITS_SET_OVERLAP_CFG = 5073;//设置字符叠加参数配置（相机或ITS终端）

  //字符叠加配置条件参数结构体

  //单条字符叠加信息结构体

  //字符串参数配置结构体

  //字符叠加内容信息结构体

  //字符叠加配置条件参数结构体

  //报警布防参数结构体



















  //********************************接口参数结构(end)*********************************/


  //********************************SDK接口函数声明*********************************/

  {*********************************************************
  Function:	NET_DVR_Init
  Desc:		初始化SDK，调用其他SDK函数的前提。
  Input:
  Output:
  Return:	TRUE表示成功，FALSE表示失败。
  **********************************************************}

  {*********************************************************
  Function:	NET_DVR_Cleanup
  Desc:		释放SDK资源，在结束之前最后调用
  Input:
  Output:
  Return:	TRUE表示成功，FALSE表示失败
  **********************************************************}




  {*********************************************************
  Function:	EXCEPYIONCALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}



  {*********************************************************
  Function:	MESSCALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  {*********************************************************
  Function:	MESSCALLBACKEX
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  {*********************************************************
  Function:	MESSCALLBACKNEW
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  {*********************************************************
  Function:	MESSAGECALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}



  {*********************************************************
  Function:	MSGCallBack
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}



















  //预览相关接口

  {*********************************************************
  Function:	REALDATACALLBACK
  Desc:		预览回调
  Input:	lRealHandle 当前的预览句柄
  dwDataType 数据类型
  pBuffer 存放数据的缓冲区指针
  dwBufSize 缓冲区大小
  pUser 用户数据
  Output:
  Return:	void
  **********************************************************}

  {*********************************************************
  Function:	NET_DVR_RealPlay_V30
  Desc:		实时预览。
  Input:	lUserID [in] NET_DVR_Login()或NET_DVR_Login_V30()的返回值
  lpClientInfo [in] 预览参数
  cbRealDataCallBack [in] 码流数据回调函数
  pUser [in] 用户数据
  bBlocked [in] 请求码流过程是否阻塞：0－否；1－是
  Output:
  Return:	1表示失败，其他值作为NET_DVR_StopRealPlay等函数的句柄参数
  **********************************************************}

  {*********************************************************
  Function:	NET_DVR_RealPlay_V40
  Desc:		实时预览扩展接口。
  Input:	lUserID [in] NET_DVR_Login()或NET_DVR_Login_V30()的返回值
  lpPreviewInfo [in] 预览参数
  fRealDataCallBack_V30 [in] 码流数据回调函数
  pUser [in] 用户数据
  Output:
  Return:	1表示失败，其他值作为NET_DVR_StopRealPlay等函数的句柄参数
  **********************************************************}

  // [DllImport(@"..\bin\HCNetSDK.dll")]
  // public static extern int NET_DVR_GetRealPlayerIndex(int lRealHandle);
  {*********************************************************
  Function:	NET_DVR_StopRealPlay
  Desc:		停止预览。
  Input:	lRealHandle [in] 预览句柄，NET_DVR_RealPlay或者NET_DVR_RealPlay_V30的返回值
  Output:
  Return:
  **********************************************************}

  {*********************************************************
  Function:	DRAWFUN
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}












  {*********************************************************
  Function:	REALDATACALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  {*********************************************************
  Function:	STDDATACALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}




  //动态生成I帧


  //云台控制相关接口
























  //文件查找与回放








  //2007-04-16增加查询结果带卡号的文件查找










  {*********************************************************
  Function:	PLAYDATACALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}













  //升级





  //远程格式化硬盘



  //报警





  //语音对讲
  {*********************************************************
  Function:	VOICEDATACALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  {*********************************************************
  Function:	VOICEDATACALLBACKV30
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}





  //语音转发



  //语音广播

  {*********************************************************
  Function:	VOICEAUDIOSTART
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}









  //透明通道设置
  {*********************************************************
  Function:	SERIALDATACALLBACK
  Desc:		(回调函数)
  Input:
  Output:
  Return:
  **********************************************************}


  //485作为透明通道时，需要指明通道号，因为不同通道号485的设置可以不同(比如波特率)




  //解码 nBitrate = 16000



  //编码



  //远程控制本地显示

  //远程控制设备端手动录像


  //解码卡
















  //获取解码卡序列号此接口无效，改用GetBoardDetail接口获得(2005-12-08支持)

  //日志






  //截止2004年8月5日,共113个接口
  //ATM DVR


  //2005-09-15

  //JPEG抓图到内存

  //2006-02-16


  //2006-08-28 704-640 缩放配置




  //2006-08-28 ATM机端口设置


  //2006-11-10 支持显卡辅助输出






  //解码设备DS-6001D/DS-6001F



  //2005-08-01










  //多路解码器
  //2007-11-30 V211支持以下接口 //11











  //2007-12-22 增加支持接口 //18





  //2009-4-13 新增
















  NET_DVR_SHOWLOGO = 1;/*显示LOGO*/
  NET_DVR_HIDELOGO = 2;/*隐藏LOGO*/



  //*显示通道命令码定义*/
  //上海世博 定制


  DISP_CMD_ENLARGE_WINDOW = 1;	/*显示通道放大某个窗口*/
  DISP_CMD_RENEW_WINDOW = 2;	/*显示通道窗口还原*/


  //end

  //恢复默认值

  //保存参数

  //重启

  //关闭DVR

  //参数配置 begin












  //获取UPNP端口映射状态

  //视频参数调节


  //配置文件





  //启用日志文件写入接口





  //前面板锁定




  //视频综合平台

  //SDK_V222
  //智能设备类型
  DS6001_HF_B = 60;//行为分析：DS6001-HF/B
  DS6001_HF_P = 61;//车牌识别：DS6001-HF/P
  DS6002_HF_B = 62;//双机跟踪：DS6002-HF/B
  DS6101_HF_B = 63;//行为分析：DS6101-HF/B
  IDS52XX = 64;//智能分析仪IVMS
  DS9000_IVS = 65;//9000系列智能DVR
  DS8004_AHL_A = 66;//智能ATM, DS8004AHL-S/A
  DS6101_HF_P = 67;//车牌识别：DS6101-HF/P

  //能力获取命令
  VCA_DEV_ABILITY = 256;//设备智能分析的总能力
  VCA_CHAN_ABILITY = 272;//行为分析能力
  MATRIXDECODER_ABILITY = 512;//多路解码器显示、解码能力
  //获取/设置大接口参数配置命令
  //车牌识别（NET_VCA_PLATE_CFG）
  NET_DVR_SET_PLATECFG = 150;//设置车牌识别参数
  NET_DVR_GET_PLATECFG = 151;//获取车牌识别参数
  //行为对应（NET_VCA_RULECFG）
  NET_DVR_SET_RULECFG = 152;//设置行为分析规则
  NET_DVR_GET_RULECFG = 153;//获取行为分析规则

  //双摄像机标定参数（NET_DVR_LF_CFG）
  NET_DVR_SET_LF_CFG = 160;//设置双摄像机的配置参数
  NET_DVR_GET_LF_CFG = 161;//获取双摄像机的配置参数

  //智能分析仪取流配置结构
  NET_DVR_SET_IVMS_STREAMCFG = 162;//设置智能分析仪取流参数
  NET_DVR_GET_IVMS_STREAMCFG = 163;//获取智能分析仪取流参数

  //智能控制参数结构
  NET_DVR_SET_VCA_CTRLCFG = 164;//设置智能控制参数
  NET_DVR_GET_VCA_CTRLCFG = 165;//获取智能控制参数

  //屏蔽区域NET_VCA_MASK_REGION_LIST
  NET_DVR_SET_VCA_MASK_REGION = 166;//设置屏蔽区域参数
  NET_DVR_GET_VCA_MASK_REGION = 167;//获取屏蔽区域参数

  //ATM进入区域 NET_VCA_ENTER_REGION
  NET_DVR_SET_VCA_ENTER_REGION = 168;//设置进入区域参数
  NET_DVR_GET_VCA_ENTER_REGION = 169;//获取进入区域参数

  //标定线配置NET_VCA_LINE_SEGMENT_LIST
  NET_DVR_SET_VCA_LINE_SEGMENT = 170;//设置标定线
  NET_DVR_GET_VCA_LINE_SEGMENT = 171;//获取标定线

  // ivms屏蔽区域NET_IVMS_MASK_REGION_LIST
  NET_DVR_SET_IVMS_MASK_REGION = 172;//设置IVMS屏蔽区域参数
  NET_DVR_GET_IVMS_MASK_REGION = 173;//获取IVMS屏蔽区域参数
  // ivms进入检测区域NET_IVMS_ENTER_REGION
  NET_DVR_SET_IVMS_ENTER_REGION = 174;//设置IVMS进入区域参数
  NET_DVR_GET_IVMS_ENTER_REGION = 175;//获取IVMS进入区域参数

  NET_DVR_SET_IVMS_BEHAVIORCFG = 176;//设置智能分析仪行为规则参数
  NET_DVR_GET_IVMS_BEHAVIORCFG = 177;//获取智能分析仪行为规则参数

  // IVMS 回放检索
  NET_DVR_IVMS_SET_SEARCHCFG = 178;//设置IVMS回放检索参数
  NET_DVR_IVMS_GET_SEARCHCFG = 179;//获取IVMS回放检索参数

  //结构参数宏定义
  VCA_MAX_POLYGON_POINT_NUM = 10;//检测区域最多支持10个点的多边形
  MAX_RULE_NUM = 8;//最多规则条数
  MAX_TARGET_NUM = 30;//最多目标个数
  MAX_CALIB_PT = 6;//最大标定点个数
  MIN_CALIB_PT = 4;//最小标定点个数
  MAX_TIMESEGMENT_2 = 2;//最大时间段数
  MAX_LICENSE_LEN = 16;//车牌号最大长度
  MAX_PLATE_NUM = 3;//车牌个数
  MAX_MASK_REGION_NUM = 4;//最多四个屏蔽区域
  MAX_SEGMENT_NUM = 6;//摄像机标定最大样本线数目
  MIN_SEGMENT_NUM = 3;//摄像机标定最小样本线数目
  {*********************************************************
  Function:	NET_DVR_GetDeviceAbility
  Desc:
  Input:
  Output:
  Return:	TRUE表示成功，FALSE表示失败。
  **********************************************************}

  //参数关键字

  //设置/获取参数关键字


  //获取/设置行为分析目标叠加接口


  //标定参数配置结构

  //LF双摄像机配置结构

  //L/F手动控制结构

  //L/F目标跟踪结构


  //双摄像机跟踪模式设置接口


  //识别场景

  //识别结果标志



  //视频识别触发类型

  MAX_CHINESE_CHAR_NUM = 64;    // 最大汉字类别数量
  //车牌可动态修改参数

  {*wMinPlateWidth:该参数默认配置为80像素；该参数的配置对于车牌海康威视车牌识别说明文档
  识别有影响，如果设置过大，那么如果场景中出现小车牌就会漏识别；如果场景中车牌宽度普遍较大，可以把该参数设置稍大，便于减少对虚假车牌的处理。在标清情况下建议设置为80， 在高清情况下建议设置为120
  wTriggerDuration － 外部触发信号持续帧数量，其含义是从触发信号开始识别的帧数量。该值在低速场景建议设置为50～100；高速场景建议设置为15～25；移动识别时如果也有外部触发，设置为15～25；具体可以根据现场情况进行配置
  *}
  //车牌识别参数子结构

  //车牌识别配置参数

  //车牌识别结果子结构

  //车牌检测结果

  //重启智能库


  //标定线链表






  //2009-7-22 end

  //邮件服务测试 9000_1.1




  //2009-8-18 抓拍机
  PLATE_INFO_LEN = 1024;
  PLATE_NUM_LEN = 16;
  FILE_NAME_LEN = 256;

  //liscense plate result
  //目前是17位，精确到ms:20090724155526948
  //*注：后面紧跟 dwPicLen 长度的 图片 信息*/





  //模式1(保留)
  //模式2

  NET_DVR_GET_CCDPARAMCFG = 1067;       //IPC获取CCD参数配置
  NET_DVR_SET_CCDPARAMCFG = 1068;      //IPC设置CCD参数配置

  //图像增强仪
  //图像增强去燥区域配置

  //图像增强、去噪级别及稳定性使能配置

  NET_DVR_GET_IMAGEREGION = 1062;       //图像增强仪图像增强去燥区域获取
  NET_DVR_SET_IMAGEREGION = 1063;       //图像增强仪图像增强去燥区域获取
  NET_DVR_GET_IMAGEPARAM = 1064;       // 图像增强仪图像参数(去噪、增强级别，稳定性使能)获取
  NET_DVR_SET_IMAGEPARAM = 1065;       // 图像增强仪图像参数(去噪、增强级别，稳定性使能)设置

  //图像增强时间段参数配置，周日开始


  {*********************************************************
  Function:	NET_DVR_Login_V30
  Desc:
  Input:	sDVRIP [in] 设备IP地址
  wServerPort [in] 设备端口号
  sUserName [in] 登录的用户名
  sPassword [in] 用户密码
  Output:	lpDeviceInfo [out] 设备信息
  Return:	-1表示失败，其他值表示返回的用户ID值
  **********************************************************}

  {*********************************************************
  Function:	NET_DVR_Logout_V30
  Desc:		用户注册设备。
  Input:	lUserID [in] 用户ID号
  Output:
  Return:	TRUE表示成功，FALSE表示失败
  **********************************************************}


























  WM_NETERROR = 0x0400 + 102;          //网络异常消息
  WM_STREAMEND = 0x0400 + 103;		  //文件播放结束

  FILE_HEAD = 0;      //文件头
  VIDEO_I_FRAME = 1;  //视频I帧
  VIDEO_B_FRAME = 2;  //视频B帧
  VIDEO_P_FRAME = 3;  //视频P帧
  VIDEO_BP_FRAME = 4; //视频BP帧
  VIDEO_BBP_FRAME = 5; //视频B帧B帧P帧
  AUDIO_PACKET = 10;   //音频包










  // 异常回调函数
  //帧数据回调函数

  //模块初始化

  //模块销毁



  // 根据ID、时间段打开流获取流句柄


  //根据ID、时间段打开批量下载


  // 开始流解析，发送数据帧

  // 根据时间定位


  // 根据时间定位

  // 根据时间定位





  // 0:  file head
  // 1:  video I frame
  // 2:  video B frame
  // 3:  video P frame
  // 10: audio frame
  // 11: private frame only for PS


  //      [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPStr)]



  {******************************************************************************
  * function：get a empty port number
  * parameters：
  * return： 0 - 499 : empty port number
  *          -1      : server is full
  * comment：
  ******************************************************************************}


  {******************************************************************************
  * function：open standard stream data for analyzing
  * parameters：lHandle - working port number
  *             pHeader - pointer to file header or info header
  * return：TRUE or FALSE
  * comment：
  ******************************************************************************}


  {******************************************************************************
  * function：close analyzing
  * parameters：lHandle - working port number
  * return：
  * comment：
  ******************************************************************************}


  {******************************************************************************
  * function：input stream data
  * parameters：lHandle		- working port number
  *			  pBuffer		- data pointer
  *			  dwBuffersize	- data size
  * return：TRUE or FALSE
  * comment：
  ******************************************************************************}


  {******************************************************************************
  * function：get analyzed packet
  * parameters：lHandle		- working port number
  *			  pPacketInfo	- returned structure
  * return：-1 : error
  *          0 : succeed
  *		   1 : failed
  *		   2 : file end (only in file mode)
  * comment：
  ******************************************************************************}


  {******************************************************************************
  * function：get remain data from input buffer
  * parameters：lHandle		- working port number
  *			  pBuf	        - pointer to the mem which stored remain data
  *             dwSize        - size of remain data
  * return： TRUE or FALSE
  * comment：
  ******************************************************************************}






  DATASTREAM_HEAD = 0;		//数据头
  DATASTREAM_BITBLOCK = 1;		//字节数据
  DATASTREAM_KEYFRAME = 2;		//关键帧数据
  DATASTREAM_NORMALFRAME = 3;		//非关键帧数据


  MESSAGEVALUE_DISKFULL = 0x01;
  MESSAGEVALUE_SWITCHDISK = 0x02;
  MESSAGEVALUE_CREATEFILE = 0x03;
  MESSAGEVALUE_DELETEFILE = 0x04;
  MESSAGEVALUE_SWITCHFILE = 0x05;
























  //设备区域设置
  REGIONTYPE = 0;//代表区域
  MATRIXTYPE = 11;//矩阵节点
  DEVICETYPE = 2;//代表设备
  CHANNELTYPE = 3;//代表通道
  USERTYPE = 5;//代表用户


  //视频综合平台软件




