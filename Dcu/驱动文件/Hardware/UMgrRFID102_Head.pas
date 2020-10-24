{*******************************************************************************
  作者: dmzn@163.com 2015-12-05
  描述: 深圳市中科华益科技有限公司 RFID102读取器驱动头文件
*******************************************************************************}
unit UMgrRFID102_Head;

interface

const
  cHY_DLLName = 'RFID102.dll';

type
  TReadCmdType = (
    tCmd_Err_Cmd                  = $00,  //未识别命令   
    tCmd_G2_Seek                  = $01,
    tCmd_G2_ReadData              = $02,
    tCmd_G2_WriteData             = $03,
    tCmd_G2_WriteEPCID            = $04,
    tCmd_G2_Destory               = $05,
    tCmd_G2_SetMemRWProtect       = $06,
    tCmd_G2_EreaseArea            = $07,
    tCmd_G2_InstalReadProtect     = $08,
    tCmd_G2_SetReadProtect        = $09,
    tCmd_G2_UnlockRProtect        = $0A,
    tCmd_G2_ChargeRProtect        = $0B,
    tCmd_G2_SetEASWarn            = $0C,
    tCmd_G2_ChargeEASWarn         = $0D,
    tCmd_G2_UseAreaLock           = $0E,
    tCmd_G2_SeekSingle            = $0F,
    tCmd_G2_WriteArea             = $10,

    //以上EPC C1G2命令 范围0x01-0x10
    //1	0x01	询查标签
    //2	0x02	读数据
    //3	0x03	写数据
    //4	0x04	写EPC号
    //5	0x05	销毁标签
    //6	0x06	设定存储区读写保护状态
    //7	0x07	块擦除
    //8	0x08	根据EPC号设定读保护设置
    //9	0x09	不需要EPC号读保护设定
    //10	0x0a	解锁读保护
    //11	0x0b	测试标签是否被设置读保护
    //12	0x0c	EAS报警设置
    //13	0x0d	EAS报警探测
    //14	0x0e	user区块锁
    //15	0x0f	询查单标签
    //16	0x10	块写

    
    tCmd_6B_SeekSingle             = $50,
    tCmd_6B_SeekMulti              = $51,
    tCmd_6B_ReadData               = $52,
    tCmd_6B_WriteData              = $53,
    tCmd_6B_ChargeLock             = $54,
    tCmd_6B_Lock                   = $55,
    //以上1800-68命令 范围0x50-0x55
    //1	0x50	询查命令(单张)。这个命令每次只能询查一张电子标签。不带条件询查。
    //2	0x51	条件询查命令(多张)。这个命令根据给定的条件进行询查标签，返回
    //        符合条件的电子标签的UID。可以同时询查多张电子标签。
    //3	0x52	读数据命令。这个命令读取电子标签的数据，一次最多可以读32个字节。
    //4	0x53	写数据命令。写入数据到电子标签中，一次最多可以写32个字节。
    //5	0x54	检测锁定命令。检测某个存储单元是否已经被锁定。
    //6	0x55	锁定命令。锁定某个尚未被锁定的电子标签。
    
    
    tCmd_Reader_ReadInfo              = $21,
    tCmd_Reader_SetWorkrate           = $22,
    tCmd_Reader_SetAddr               = $24,
    tCmd_Reader_SetSeekTimeOut        = $25,
    tCmd_Reader_SetBoundrate          = $28,
    tCmd_Reader_SetOutweight          = $2F,
    tCmd_Reader_SetRoundAndRight      = $33,
    tCmd_Reader_SetWGParam            = $34,
    tCmd_Reader_SetWorkmode           = $35,
    tCmd_Reader_ReadWorkmode          = $36,
    tCmd_Reader_SetEASweight          = $37,
    tCmd_Reader_SetSyris485TimeOut    = $38,
    tCmd_Reader_SetReplyTimeOut       = $3B,
    tCmd_Reader_SetReLay              = $3C
    //读写器自定义命令

    //1	0x21	读取读写器信息
    //2	0x22	设置读写器工作频率
    //3	0x24	设置读写器地址
    //4	0x25	设置读写器询查时间
    //5	0x28	设置读写器的波特率
    //6	0x2F	调整读写器输出功率
    //7	0x33	声光控制命令
    //8	0x34	韦根参数设置命令
    //9	0x35	工作模式设置命令
    //10	0x36	读取工作模式参数命令
    //11	0x37	EAS测试精度设置命令
    //12	0x38	设置Syris485响应偏执时间
    //13	0x3b	设置触发有效时间
    //14  0x3c  设置继电器开合状态
  );

  PRFIDReaderCmd = ^TRFIDReaderCmd;
  TRFIDReaderCmd = record
    FLen :Char;
    //指令长度命令数据块的长度，但不包括Len本身。
    //即数据块的长度等于4加Data[]的长度。Len允许的最大值为96，最小值为4

    FAddr:Char;
    //读写器地址。地址范围：0x00~0xFE，0xFF为广播地址，
    //读写器只响应和自身地址相同及地址为0xFF的命令。读写器出厂时地址为0x00

    FCmd :TReadCmdType;
    //命令代码。

    FStatus: Char;
    //命令执行结果状态值。

    FData:string;
    //参数域。在实际命令中，可以不存在。

    FLSB, FMSB:Char;
    //CRC16低字节和高字节。CRC16是从Len到Data[]的CRC16值
  end;

//------------------------------------------------------------------------------
  RTempRecord=Record
  end;

  function OpenNetPort(Port : LongInt; IPaddr:string; var ComAdr : byte;
    var frmcomportindex:longint): LongInt; stdcall;external cHY_DLLName ;
  function CloseNetPort( frmComPortindex : longint ): LongInt;
    stdcall; external cHY_DLLName;
  //xxxxxx

  function OpenComPort(Port : LongInt;var ComAdr : byte;Baud:byte;
    var frmcomportindex: longint): LongInt; stdcall; external cHY_DLLName ;
  function CloseComPort(  ): LongInt; stdcall;external cHY_DLLName ;
  function AutoOpenComPort(var Port : longint; var ComAdr : byte;Baud:byte;
    var frmComPortindex :longint ) : LongInt; stdcall; external cHY_DLLName ;
  function CloseSpecComPort( frmComPortindex : longint ): LongInt;
    stdcall;external cHY_DLLName;
  //xxxxxx
  
  function GetReaderInformation(var ComAdr: byte; VersionInfo: pchar;
    var ReaderType: byte; TrType: pchar;
    var dmaxfre ,dminfre,powerdBm:Byte;
    var ScanTime: byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function SetWGParameter(var ComAdr:Byte;
    Wg_mode:Byte;
    Wg_Data_Inteval:Byte;
    Wg_Pulse_Width:Byte;
    Wg_Pulse_Inteval:Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function ReadActiveModeData(ScanModeData: pchar;
    var ValidDatalength: longint;
    frmComPortindex: longint): LongInt; Stdcall;external cHY_DLLName;
  function SetWorkMode(var ComAdr:Byte;
    Parameter:PChar;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function GetWorkModeParameter(var ComAdr:Byte;
    Parameter:PChar;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function BuzzerAndLEDControl(var ComAdr:Byte;
    AvtiveTime:Byte;
    SilentTime:Byte;
    Times:Byte;
    frmComPortindex: LongInt):LongInt; stdcall;external cHY_DLLName;
  //xxxxxx

  function WriteComAdr(var ComAdr : byte; var ComAdrData : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function SetPowerDbm(var ComAdr : byte;powerDbm : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function Writedfre(var ComAdr : byte;var dmaxfre : Byte; var dminfre : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function Writebaud(var ComAdr : byte;var baud : Byte;
    frmComPortindex : longint): LongInt; stdcall; external cHY_DLLName;
  function WriteScanTime(var ComAdr:byte;var ScanTime : Byte;
    frmComPortindex : longint): LongInt; stdcall;external cHY_DLLName;
  function SetAccuracy(var ComAdr:Byte;Accuracy:Byte;
    frmComPortindex:longint):LongInt; stdcall;external cHY_DLLName;
  function SetOffsetTime(var ComAdr:Byte;OffsetTime:Byte;
    frmComPortindex:longint):LongInt; stdcall;external cHY_DLLName;
  function SetFhssMode(var ComAdr:Byte;FhssMode :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function GetFhssMode(var ComAdr:Byte;var FhssMode :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function SetTriggerTime(var ComAdr:Byte;var TriggerTime :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  function SetRelay(var ComAdr:Byte;RelayStatus :Byte;
    frmComPortindex: longint):LongInt; stdcall;external cHY_DLLName;
  //xxxxxx
  
  //EPC  G2
  function Inventory_G2(var ComAdr : byte;
    AdrTID,LenTID,TIDFlag:Byte;
    EPClenandEPC : pchar;
    var Totallen:longint;
    var CardNum : longint;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  //xxxxxx
 
  function ReadCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Num:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    Data:PChar;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Writedatalen:Byte;
    Writedata:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    WrittenDataNum:LongInt;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function EraseCard_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Num:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetCardProtect_G2(var ComAdr:Byte;EPC:PChar;select,setprotect:Byte;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function DestroyCard_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteEPC_G2(var ComAdr:Byte;
    Password:PChar;WriteEPC:PChar;WriteEPClen:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetReadProtect_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EPClength:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetMultiReadProtect_G2(var ComAdr:Byte;
    Password:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function RemoveReadProtect_G2(var ComAdr:Byte;
    Password:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckReadProtected_G2(var ComAdr:Byte; var readpro:byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function SetEASAlarm_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;EAS:byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckEASAlarm_G2(var ComAdr:Byte;
    var errorcode:longint;frmComPortindex : longint ): LongInt;
    stdcall;external cHY_DLLName;
  function LockUserBlock_G2(var ComAdr:Byte;EPC:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;BlockNum:byte;
    EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  
  function WriteBlock_G2(var ComAdr:Byte;EPC:PChar;Mem,WordPtr,Writedatalen:Byte;
    Writedata:PChar;
    Password:PChar;maskadr:Byte;maskLen:Byte;maskFlag:Byte;
    WrittenDataNum:LongInt;EPClength:byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  //18000_6B

  function Inventory_6B(var ComAdr : byte; ID_6B : pchar;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  function inventory2_6B(var ComAdr : byte;Condition,StartAddress,mask:byte;
    ConditionContent:PChar; ID_6B : pchar;var Cardnum:longint;
    frmComPortindex:LongInt): LongInt; stdcall; external cHY_DLLName;
  function ReadCard_6B(var ComAdr;ID_6B:PChar;StartAddress,Num:Byte;
    Data:PChar;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function WriteCard_6B(var ComAdr;ID_6B:PChar;StartAddress:Byte;
    Writedata:PChar;Writedatalen:Byte;var writtenbyte:longint;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function LockByte_6B(var ComAdr;ID_6B:PChar;Address:Byte;
    var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  function CheckLock_6B(var ComAdr;ID_6B:PChar;Address:Byte;
    var ReLockState:Byte;var errorcode:longint;
    frmComPortindex : longint ): LongInt;stdcall;external cHY_DLLName;
  //xxxxxx
  
implementation


end.












 
