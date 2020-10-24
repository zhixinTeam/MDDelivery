{*******************************************************************************
  作者: dmzn@163.com 2016-08-18
  描述: 明华RF-35LT读卡器驱动单元

  备注:
  *.IC卡共分为 16个扇区,每个扇区有4个块;其中每个扇区的1、2、3是可写的,
    每块可写16个字符.
  *.第一扇区的1、2、3块为保留（或许）区块,第4块不可动.真正写入数据,是从
    第2个扇区开始,每个扇区只写前3块.
  *.每个扇区的区块不是从0-3相对编号,而是从0开始的绝对编号,每个扇区的第一个
    区块编号nBlock=扇区x4.
*******************************************************************************}
unit UMgrMHReader;

interface

uses
  Windows, Classes, SysUtils, NativeXml, ULibFun, USysLoger;

const
  cLibDLL = 'mwrf32.dll';

function rf_init(port: smallint;baud:longint): longint; stdcall;
  far;external cLibDLL name 'rf_init';
function rf_exit(icdev: longint):smallint;stdcall;
  far;external cLibDLL name 'rf_exit';
function rf_encrypt(key:pchar;ptrsource:pchar;msglen:smallint;
  ptrdest:pchar):smallint;stdcall;far;external cLibDLL name 'rf_encrypt';
function rf_decrypt(key:pchar;ptrsource:pchar;msglen:smallint;
  ptrdest:pchar):smallint;stdcall;far;external cLibDLL name 'rf_decrypt';
//xxxxx

function rf_card(icdev:longint;mode:smallint;snr:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_card';
function rf_load_key(icdev:longint;mode,secnr:smallint;
  nkey:pchar):smallint;stdcall;far;external cLibDLL name 'rf_load_key';
function rf_load_key_hex(icdev:longint;mode,secnr:smallint;
  nkey:pchar):smallint;stdcall;far;external cLibDLL name 'rf_load_key_hex';
function rf_authentication(icdev:longint;mode,secnr:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_authentication';
//xxxxx

function rf_read(icdev:longint;adr:smallint;data:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_read';
function rf_read_hex(icdev:longint;adr:smallint;data:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_read_hex';
function rf_write(icdev:longint;adr:smallint;data:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_write';
function rf_write_hex(icdev:longint;adr:smallint;data:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_write_hex';
function rf_HL_writehex(icdev:longint;adr:smallint;snr:longint;
  data:pchar):smallint;stdcall;far;external cLibDLL name 'rf_HL_writehex';
//xxxxx

function rf_halt(icdev:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_halt';
function rf_reset(icdev:longint;msec:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_reset';
//xxxxx

function rf_initval(icdev:longint;adr:smallint;value:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_initval';
function rf_readval(icdev:longint;adr:smallint;value:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_readval';
function rf_increment(icdev:longint;adr:smallint;value:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_increment';
function rf_decrement(icdev:longint;adr:smallint;value:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_decrement';
function rf_restore(icdev:longint;adr:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_restore';
function rf_transfer(icdev:longint;adr:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_transfer';
function rf_check_write(icdev,snr:longint;adr,authmode:smallint;
  data:pchar):smallint;stdcall;far;external cLibDLL name 'rf_check_write';
function rf_check_writehex(icdev,snr:longint;adr,authmode:smallint;
  data:pchar):smallint;stdcall;far;external cLibDLL name 'rf_check_writehex';
//xxxxx

//M1 CARD HIGH FUNCTION
function rf_HL_initval(icdev:longint;mode:smallint;secnr:smallint;value:longint;
  snr:pchar):smallint;stdcall;far;external cLibDLL name 'rf_HL_initval';
function rf_HL_increment(icdev:longint;mode:smallint;secnr:smallint;
  value,snr:longint;svalue,ssnr:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_HL_increment';
function rf_HL_decrement(icdev:longint;mode:smallint;secnr:smallint;
  value:longint;snr:longint;svalue,ssnr:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_HL_decrement';
function rf_HL_write(icdev:longint;mode,adr:smallint;
  ssnr,sdata:pchar):smallint;stdcall; far;external cLibDLL name 'rf_HL_write';
function rf_HL_read(icdev:longint;mode,adr:smallint;snr:longint;
  sdata,ssnr:pchar):smallint;stdcall;far;external cLibDLL name 'rf_HL_read';
function rf_changeb3(icdev:longint;Adr:smallint;keyA:pchar;B0:smallint;
  B1:smallint;B2:smallint;B3:smallint;Bk:smallint;KeyB:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_changeb3';
//xxxxx

function rf_get_status(icdev:longint;status:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_get_status';
function rf_beep(icdev:longint;time:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_beep';
function rf_ctl_mode(icdev:longint;ctlmode:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_ctl_mode';
function rf_disp_mode(icdev:longint;mode:smallint):smallint;stdcall;
  far;external cLibDLL name 'rf_disp_mode';
function rf_disp8(icdev:longint;len:longint;disp:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_disp8';
function rf_disp(icdev:longint;pt_mode:smallint;disp:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_disp';
//xxxxx

function rf_request(icdev:longint;find_mode:smallint;
  cardtype:pchar):smallint;stdcall;far;external cLibDLL name 'rf_request';
function rf_anticoll(icdev:longint;find_mode:pchar;snr:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_anticoll';
function rf_select(icdev:longint;snr:longint;size:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_select';
//xxxxx

function rf_settimehex(icdev:longint;dis_time:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_settimehex';
function rf_gettimehex(icdev:longint;dis_time:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_gettimehex';
function rf_swr_eeprom(icdev:longint;offset,len:smallint;
  data:pchar):smallint;stdcall;far;external cLibDLL name 'rf_swr_eeprom';
function rf_srd_eeprom(icdev:longint;offset,len:smallint;
  data:pchar):smallint;stdcall;far;external cLibDLL name 'rf_srd_eeprom';
//xxxxx

function rf_authentication_2(icdev:longint;mode,keyNum,
  secnr:smallint):smallint;stdcall;far;external cLibDLL name 'rf_authentication_2';
function rf_initval_ml(icdev:longint;value:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_initval_ml';
function rf_readval_ml(icdev:longint;rvalue:pchar):smallint;stdcall;
  far;external cLibDLL name 'rf_readval_ml';
function rf_decrement_transfer(icdev:longint;adr:smallint;
  value:longint):smallint;stdcall;far;external cLibDLL name 'rf_decrement_transfer';
function rf_sam_rst(icdev:longint;baud:smallint;samack:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_sam_rst';
function rf_sam_trn(icdev:longint;samblock,recv:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_sam_trn';
function rf_sam_off(icdev:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_sam_off';
function rf_cpu_rst(icdev:longint;baud:smallint;cpuack:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_cpu_rst';
function rf_cpu_trn(icdev:longint;cpublock,recv:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_cpu_trn';
function rf_pro_rst(icdev:longint;_Data:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_pro_rst';
function rf_pro_trn(icdev:longint;problock,recv:pChar):smallint;stdcall;
  far;external cLibDLL name 'rf_pro_trn';
function rf_pro_halt(icdev:longint):smallint;stdcall;
  far;external cLibDLL name 'rf_pro_halt';
function hex_a(hex,a:pChar;length:smallint):smallint;stdcall;
  far;external cLibDLL name 'hex_a';
function a_hex(a,hex:pChar;length:smallint):smallint;stdcall;
  far;external cLibDLL name 'a_hex';
//xxxxx

//------------------------------------------------------------------------------
type
  TMHReader = record
    FEnable: Boolean;        //启用标记
    FID: string;             //标识
    FName: string;           //名称
    FPort: Integer;          //端口
    FBaud: Integer;          //波特率

    FFullData: Boolean;      //全块写入
    FEncryptKey: string;     //加密密钥
    FHwnd: LongInt;          //端口句柄
    FBuf,FData: string;      //数据缓存
  end;

  TMHReaders = array of TMHReader;

  TMHReaderManager = class(TObject)
  private
    FReaders: TMHReaders;
    //读头列表
    FErrorCode: Integer;
    FErrorDesc: string;
    //错误信息
    FReaderLog: Boolean;
    FReaderBeep: Boolean;
    //运行开关
  protected
    function GetReader(const nID: string): Integer;
    //检索堵头
    function InitReader(const nIdx: Integer;
      const nReset: Boolean = True): Boolean;
    procedure ResetReader(const nIdx: Integer; const nAction: string);
    procedure CloseReader(const nIdx: Integer = -1);
    //打开关闭
    procedure BeepReader(const nIdx: Integer; const nNum: Integer = 1;
      const nForce: Boolean = False);
    //读头蜂鸣
    procedure WriteReaderLog(const nIdx,nCode: Integer;
      const nAction,nResult: string;const nForce: Boolean = False);
    //记录日志
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    class function GetErrorDesc(const nErr: Integer): string;
    //错误描述
    procedure LoadConfig(const nFile: string);
    //载入配置
    function ReadCardID(const nID: string = ''): string;
    //读取编号
    function ReadCardData(const nID: string = ''; nLen: Integer = 0): string;
    function WriteCardData(const nData: string; const nID: string = ''): Boolean;
    //读写数据
    property LastError: Integer read FErrorCode;
    property ErrorDesc: string read FErrorDesc;
    property ReaderLog: Boolean read FReaderLog write FReaderLog;
    property ReaderBeep: Boolean read FReaderBeep write FReaderBeep;
    property Readers:  TMHReaders read FReaders;
    //属性相关
  end;

var
  gMHReaderManager: TMHReaderManager = nil;
  //全局使用

implementation

const
  sKey          = 'ffffffffffff';    //卡片密钥
  sDataPrefix   = '@';               //数据前缀
  cPrefixLen    = 4;                 //前缀长度
  cBlockDataLen = 16;                //区块容量

  cMaxDataLen   = 15 * 3 * 16 - cPrefixLen;
  //数据容量: 15扇区,每区3块,每块16字符,扣除前缀

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMHReaderManager, '明华RF驱动', nEvent);
end;

constructor TMHReaderManager.Create;
begin
  FReaderLog := True;
  FReaderBeep := True;
  SetLength(FReaders, 0);
end;

destructor TMHReaderManager.Destroy;
begin
  CloseReader;
  inherited;
end;

//Date: 2016-09-01
//Parm: 读头索引;错误码;动作;结果
//Desc: 记录nIdx读头的错误信息
procedure TMHReaderManager.WriteReaderLog(const nIdx, nCode: Integer;
  const nAction,nResult: string; const nForce: Boolean);
var nStr: string;
begin
  if (not FReaderLog) and (not nForce) then Exit;
  //xxxxx
  
  with FReaders[nIdx] do
  begin
    nStr := '%s[ %s.%s ]%s,详情:[ %d.%s ].';
    nStr := Format(nStr, [nAction, FID, FName, nResult,
                          nCode, GetErrorDesc(nCode)]);
    //xxxxx

    FErrorCode := nCode;
    FErrorDesc := nStr;
    WriteLog(nStr);
  end;
end;

//Date: 2016-09-01
//Parm: 读头标识
//Desc: 检索标识为nID的读头索引
function TMHReaderManager.GetReader(const nID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;
  if (nID = '') and (Length(FReaders) > 0) then
    Result := 0;
  //first reader is default

  for nIdx:=Low(FReaders) to High(FReaders) do
  if CompareText(nID, FReaders[nIdx].FID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2016-09-01
//Parm: 读头索引;是否重置
//Desc: 连接索引为nIdx的读头
function TMHReaderManager.InitReader(const nIdx: Integer;
  const nReset: Boolean): Boolean;
var nStr: string;
    nHwnd: LongInt;
    nBuf: array[0..18] of Char;
begin
  with FReaders[nIdx] do
  begin
    Result := False;
    if not FEnable then
    begin
      WriteReaderLog(nIdx, 50, '读卡器', '已关闭', True);
      Exit;
    end;

    if nReset then
      CloseReader(nIdx);
    //xxxxx

    if FHwnd > 0 then
         nHwnd := FHwnd
    else nHwnd := rf_init(FPort, FBaud);

    if nHwnd <= 0 then
    begin
      WriteReaderLog(nIdx, nHwnd, '初始化', '失败', True);
      Exit;
    end;

    Result := True;
    FHwnd := nHwnd;

    if nReset and FReaderLog and (rf_get_status(nHwnd, @nBuf) = 0) then
    begin
      nStr := '初始化[ %s.%s ]成功,版本:[ %s ].';
      nStr := Format(nStr, [FID, FName, nBuf]);
      WriteLog(nStr);
    end; //device version
  end;
end;

//Date: 2016-09-01
//Parm: 读头索引(-1表示全部)
//Desc: 关闭索引为读头
procedure TMHReaderManager.CloseReader(const nIdx: Integer);
var i: Integer;
    nHwnd: LongInt;
begin
  for i:=Low(FReaders) to High(FReaders) do
  if (i = nIdx) or (nIdx = -1) then
  begin
    nHwnd := FReaders[i].FHwnd;
    FReaders[i].FHwnd := 0;

    if nHwnd > 0 then
      rf_exit(nHwnd);
    //close reader
  end;
end;

//Date: 2016-09-01
//Parm: 配置文件
//Desc: 载入nFile配置文件
procedure TMHReaderManager.LoadConfig(const nFile: string);
var nIdx: Integer;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('readers');
    SetLength(FReaders, nNode.NodeCount);
    
    for nIdx:=0 to nNode.NodeCount - 1 do
    begin
      with FReaders[nIdx],nNode.Nodes[nIdx] do
      begin
        FHwnd := 0;
        FID := AttributeByName['id'];
        FName := AttributeByName['name'];

        FPort := NodeByName('port').ValueAsInteger;
        FBaud := NodeByName('baud').ValueAsInteger;
        FEnable := NodeByName('enable').ValueAsString <> 'N';

        nTmp := NodeByName('encrypt');
        if Assigned(nTmp) then
             FEncryptKey := nTmp.ValueAsString
        else FEncryptKey := sKey;

        nTmp := NodeByName('fulldata');
        if Assigned(nTmp) then
             FFullData := nTmp.ValueAsString <> 'N'
        else FFullData := True;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//Date: 2016-09-01
//Parm: 错误代码
//Desc: 返回nCode对应的文字描述
class function TMHReaderManager.GetErrorDesc(const nErr: Integer): string;
begin
  case nErr of
    0: Result := '正确';
    1: Result := '无卡';
    2: Result := 'CRC校验错';
    3: Result := '值溢出';
    4: Result := '未验证密码';
    5: Result := '奇偶校验错';
    6: Result := '通讯出错';
    8: Result := '错误的序列号';
    10: Result := '验证密码失败';
    11: Result := '接收的数据位错误';
    12: Result := '接收的数据字节错误';
    14: Result := 'Transfer错误';
    15: Result := '写失败';
    16: Result := '加值失败';
    17: Result := '减值失败';
    18: Result := '读失败';
    -$10: Result := 'PC与读写器通讯错误';
    -$11: Result := '通讯超时';
    -$20: Result := '打开通信口失败';
    -$24: Result := '串口已被占用';
    -$30: Result := '地址格式错误';
    -$31: Result := '该块数据不是值格式';
    -$32: Result := '度错误';
    -$40: Result := '值操作失败';
    -$50: Result := '卡中的值不够减';

    50: Result := '驱动业务定义' else Result := '未知错误';
  end;
end;

//------------------------------------------------------------------------------
//Date: 2016-09-01
//Parm: 读头索引;蜂鸣次数
//Desc: 使nIdx的读头蜂鸣nNum次
procedure TMHReaderManager.BeepReader(const nIdx: Integer; const nNum: Integer;
  const nForce: Boolean);
var i: Integer;
begin
  if (FReaderBeep and (FReaders[nIdx].FHwnd > 0)) or nForce then
  begin
    for i:=nNum downto 1 do
    begin
      rf_beep(FReaders[nIdx].FHwnd, 12);
      Sleep(20);
    end; //beep loop
  end;
end;

//Date: 2016-09-03
//Parm: 读头索引;动作名称
//Desc: 重置读卡器状态
procedure TMHReaderManager.ResetReader(const nIdx: Integer; const nAction: string);
var nHwnd: Integer;
begin
  with FReaders[nIdx] do
  begin
    nHwnd := rf_halt(FHwnd);
    if nHwnd <> 0 then
      WriteReaderLog(nIdx, nHwnd, nAction + 'HALT', '失败');
    //xxxxx

    nHwnd := rf_reset(FHwnd, 10);
    if nHwnd <> 0 then
      WriteReaderLog(nIdx, nHwnd, nAction + 'RESET', '失败');
    //xxxxx
  end;
end;

//Date: 2016-09-01
//Parm: 读头标识
//Desc: 读取nID上当前磁卡的0扇区0区块,默认为卡号
function TMHReaderManager.ReadCardID(const nID: string): string;
var nCr: LongInt;
    nIdx,nInt: Integer;
    nBuf: array[0..3] of Byte;
begin
  Result := '';
  nIdx := GetReader(nID);

  if nIdx < 0 then Exit;
  if not InitReader(nIdx) then Exit;

  with FReaders[nIdx] do
  try
    nInt := rf_card(FHwnd, 1, @nCr);
    if nInt <> 0 then
    begin
      WriteReaderLog(nIdx, nInt, '读取卡号', '失败');
      Exit;
    end;

    Move(nCr, nBuf[0], 4);
    for nInt:=0 to 3 do
      Result := Result + IntToHex(nBuf[nInt], 2);
    //xxxxx
  finally
    if Result = '' then
         BeepReader(nIdx, 2)
    else BeepReader(nIdx, 1, True);

    ResetReader(nIdx, '读取卡号');
    //xxxxx
  end;
end;

//Date: 2016-09-01
//Parm: 读头标识;待读取长度
//Desc: 读取nID上的卡片数据
function TMHReaderManager.ReadCardData(const nID: string; nLen: Integer): string;
var nStr: string;
    nIdx,nHwnd: Integer;
    nLInt: LongInt;
    nBuf: array[0..15] of Char;
    nMode,nSection,nBlock: SmallInt;
begin
  Result := '';
  nIdx := GetReader(nID);

  if nIdx < 0 then Exit;
  if not InitReader(nIdx) then Exit;

  with FReaders[nIdx] do
  try
    if (not FFullData) and (nLen < 1) then Exit;
    //invalid data length

    FData := '';
    nHwnd := rf_card(FHwnd, 1, @nLInt);
    
    if nHwnd <> 0 then
    begin
      WriteReaderLog(nIdx, nHwnd, 'CARD', '失败');
      Exit;
    end; //no card

    if FFullData then
      nLen := 0;
    //init card data length

    nSection := 1;
    nBlock := 4;
    nMode := 0;

    while True do
    begin
      if nBlock mod 4 = 0 then
      begin
        nHwnd := rf_load_key_hex(FHwnd, nMode, nSection, PChar(FEncryptKey));
        if nHwnd <> 0 then
        begin
          WriteReaderLog(nIdx, nHwnd, 'LOADKEY', '失败');
          Exit;
        end;

        nHwnd := rf_authentication(FHwnd, nMode, nSection);
        if nHwnd <> 0 then
        begin
          WriteReaderLog(nIdx, nHwnd, 'AUTH', '失败');
          Exit;
        end;
      end; //new section,load key and auth

      nHwnd := rf_read(FHwnd, nBlock, @nBuf);
      if nHwnd <> 0 then
      begin
        WriteReaderLog(nIdx, nHwnd, 'READ', '失败');
        Exit;
      end;

      FBuf := nBuf;
      //block data

      if (nBlock = 4) and FFullData then //2扇区1区块
      begin
        nStr := Copy(FBuf, 1, cPrefixLen);
        if Pos(sDataPrefix, nStr) <> 1 then
        begin
          WriteReaderLog(nIdx, 50, '卡片数据', '前缀无效');
          Exit;
        end;

        System.Delete(nStr, 1, 1);
        if not IsNumber(nStr, False) then
        begin
          WriteReaderLog(nIdx, 50, '卡片数据', '长度无效');
          Exit;
        end;

        nLen := StrToInt(nStr);
        //data length
        System.Delete(FBuf, 1, cPrefixLen);
      end;

      FData := FData + FBuf;
      if Length(FData) >= nLen then
      begin
        FData := Copy(FData, 1, nLen);
        Break;
      end;

      Inc(nBlock);
      if nBlock mod 4 = 3 then
      begin
        Inc(nSection);
        Inc(nBlock);
        if nSection = 16 then Break;
      end; //next section
    end;

    if (nLen > 0) and (nLen = Length(FData)) then
      Result := FData;
    //xxxxx
  finally
    if Result = '' then
         BeepReader(nIdx, 2)
    else BeepReader(nIdx, 1, True);

    ResetReader(nIdx, '读取数据');
    //xxxxx
  end;
end;

//Date: 2016-09-01
//Parm: 读头标识
//Desc: 将nData写入nID读头上的卡片
function TMHReaderManager.WriteCardData(const nData, nID: string): Boolean;
var nStr: string;
    nIdx,nHwnd,nPos,nLen,nInt: Integer;
    nLInt: LongInt;
    nMode,nSection,nBlock: SmallInt;
begin
  Result := False;
  nIdx := GetReader(nID);

  if nIdx < 0 then Exit;
  if not InitReader(nIdx) then Exit;

  with FReaders[nIdx] do
  try
    nPos := 1;
    nLen := Length(nData);

    if (nLen > cMaxDataLen) or (nLen < 1) then
    begin
      if nLen < 1 then
           nStr := '数据为空'
      else nStr := Format('长度超过%d字节', [cMaxDataLen]);

      WriteReaderLog(nIdx, 50, '待写入', nStr);
      Exit;
    end;

    nHwnd := rf_card(FHwnd, 1, @nLInt);
    if nHwnd <> 0 then
    begin
      WriteReaderLog(nIdx, nHwnd, 'CARD', '失败');
      Exit;
    end; //no card

    nSection := 1;
    nBlock := 4;
    nMode := 0;

    while True do
    begin
      if nBlock mod 4 = 0 then
      begin
        nHwnd := rf_load_key_hex(FHwnd, nMode, nSection, PChar(FEncryptKey));
        if nHwnd <> 0 then
        begin
          WriteReaderLog(nIdx, nHwnd, 'LOADKEY', '失败');
          Exit;
        end;

        nHwnd := rf_authentication(FHwnd, nMode, nSection);
        if nHwnd <> 0 then
        begin
          WriteReaderLog(nIdx, nHwnd, 'AUTH', '失败');
          Exit;
        end;
      end; //new section,load key and auth

      if (nBlock = 4) and FFullData then //2扇区1区块
      begin
        nStr := IntToStr(nLen);
        nInt := cPrefixLen - 1 - Length(nStr);
        nStr := sDataPrefix + StringOfChar('0', nInt) + nStr;
        //write data length

        nInt := cBlockDataLen - Length(nStr);
        if nLen <= nInt then
        begin
          nStr := nStr + nData;
          nPos := nPos + nLen;
        end else
        begin
          nStr := nStr + Copy(nData, 1, nInt);
          nPos := nPos + nInt;
        end;
      end else
      begin
        nInt := nLen - nPos + 1;
        //剩余字节数
        if nInt <= cBlockDataLen then
        begin
          nStr := Copy(nData, nPos, nInt);
          nPos := nPos + nInt;
        end else
        begin
          nStr := Copy(nData, nPos, cBlockDataLen);
          nPos := nPos + cBlockDataLen;
        end;
      end;

      nHwnd := rf_write(FHwnd, nBlock, PChar(nStr));
      if nHwnd <> 0 then
      begin
        WriteReaderLog(nIdx, nHwnd, 'WRITE', '失败');
        Exit;
      end;

      if nPos >= nLen + 1 then
      begin
        Result := True;
        Break;
      end; //write over

      Inc(nBlock);
      if nBlock mod 4 = 3 then
      begin
        Inc(nSection);
        Inc(nBlock);
        if nSection = 16 then Break;
      end; //next section
    end;
  finally
    if Result then
         BeepReader(nIdx, 1, True)
    else BeepReader(nIdx, 2);

    ResetReader(nIdx, '写入数据');
    //xxxxx
  end;
end;

initialization
  gMHReaderManager := nil;
finalization
  FreeAndNil(gMHReaderManager);
end.
 