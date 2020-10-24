{*******************************************************************************
  作者: dmzn@163.com 2018-07-26
  描述: 上海仰邦BX-5K、5MK、5K1Q-YY、6K、6K-YY等字库卡驱动
*******************************************************************************}
unit UMgrBXFontCard;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, IdGlobal, IdTCPClient, NativeXml,
  ULibFun, UWaitItem, USysLoger;

const
  BX_Any                  = $FE;
  BX_5K1                  = $51;
  BX_5K2                  = $58;
  BX_5MK2                 = $53;
  BX_5MK1                 = $54;
  BX_5K1Q_YY              = $5c;
  BX_6K1                  = $61;
  BX_6K2                  = $62;
  BX_6K3                  = $63;
  BX_6K1_YY               = $64;
  BX_6K2_YY               = $65;
  BX_6K3_YY               = $66;

  BX_SingLine_01          = $01;  //单行显示
  BX_SingLine_02          = $02;  //多行显示
  BX_NewLine_01           = $01;  //不自定换行
  BX_NewLine_02           = $02;  //自动换行
  BX_DisplayMode_01       = $01;  //静止显示
  BX_DisplayMode_02       = $02;  //快速打出
  BX_DisplayMode_03       = $03;  //向左移动
  BX_DisplayMode_04       = $04;  //向右移动
  BX_DisplayMode_05       = $05;  //向上移动
  BX_DisplayMode_06       = $06;  //向下移动

const
  cBXDataMax              = 1024; //数据上限,字节单位
  cBXDataNull             = #0#0; //空字符串,不会发送

type
  PBXHeader = ^TBXHeader;
  TBXHeader = packed record
    FDstAddr       : Word;                        //屏地址
    FSrcAddr       : Word;                        //源地址
    FReserved      : array[0..2] of Byte;         //保留
    FOption        : Byte;                        //选项
    FCheckMode     : Byte;                        //校验模式
    FDisplayMode   : Byte;                        //显示模式
    FDeviceType    : Byte;                        //设备类型
    FProtocol      : Byte;                        //协议版本
    FDataLen       : Word;                        //数据长度
  end;

  PBXData = ^TBXData;
  TBXData = packed record
    FFrameBegin    : array[0..7] of Byte;         //帧头
    FHead          : TBXHeader;                   //包头
    FData          : array[0..cBXDataMax-1] of Byte;//数据
    FVerify        : array[0..1] of Byte;         //校验
    FFrameEnd      : Byte;                        //帧尾
  end;

  PBXDisplayMode = ^TBXDisplayMode;
  TBXDisplayMode = packed record
    FSingleLine    : Byte;                        //单行显示
    FNewLine       : Byte;                        //自动换行
    FDisplayMode   : Byte;                        //显示方式
    FExitMode      : Byte;                        //退出方式
    FSpeed         : Byte;                        //显示速度
    FStayTime      : Byte;                        //停留时间,单位为0.5s
  end;

  PBXArea = ^TBXArea;
  TBXArea = packed record
    FAreaType      : Byte;                        //区域类型
    FAreaX         : Word;                        //区域X坐标,字节(8像素)单位
    FAreaY         : Word;                        //区域Y坐标,像素点单位
    FAreaWidth     : Word;                        //区域宽度,字节(8像素)单位
    FAreaHeight    : Word;                        //区域高度,像素点单位
    FDynamicAreaLoc: Byte;                        //动态区域编号
    FLine_sizes    : Byte;                        //行间距
    FRunMode       : Byte;                        //运行模式
    FTimeout       : Word;                        //数据超时
    FReserved      : array[0..2] of Byte;         //保留
    FDisplayMode   : TBXDisplayMode;              //显示模式
    FDataLen       : Integer;                     //数据长度
    FData          : array[0..cBXDataMax-1] of Byte;//数据
  end;

  PBXRequest = ^TBXRequest;
  TBXRequest = packed record
    FCmdGroup      : Byte;                        //命令分组编号
    FCmd           : Byte;                        //命令编号
    FResponse      : Byte;                        //是否要求控制器回复
    FProcessMode   : Byte;                        //是否自动清理
    FReserved      : Byte;                        //保留
    FDeleteAreaNum : Byte;                        //要删除的区域
    FAreaNum       : Byte;                        //本次更新的区域个数
    FAreaDataLen   : Word;                        //数据长度
    FData          : array[0..cBXDataMax-1] of Byte;//数据
  end;

  PBXResponse = ^TBXResponse;
  TBXResponse = packed record
    FCmdGroup      : Byte;                        //命令分组编号
    FCmd           : Byte;                        //命令编号
    FCmdError      : Byte;                        //命令处理状态
    FReserved      : array[0..1] of Byte;         //保留
    FData          : array[0..cBXDataMax-1] of Byte;//数据
  end;

  PBXFontCardArea = ^TBXFontCardArea;
  TBXFontCardArea = record
    FAreaLoc       : Byte;                        //区域编号
    FRect          : TRect;                       //区域
    FText          : string;                      //显示内容
    FTextMode      : TBXDisplayMode;              //显示方式
    FTextSend      : Boolean;                     //是否需要发送
    FLastSend      : Cardinal;                    //最后发送时间

    FUserTimeout   : Integer;                     //自定义超时
    FUserMode      : TBXDisplayMode;              //自定义模式
    FUserEnable    : Boolean;                     //启用自定义模式

    FDefaultText   : string;                      //默认内容
    FDefaultTimeout: Integer;                     //超时转为默认
    FDefaultMode   : TBXDisplayMode;              //显示方式
    FDefaultSend   : Boolean;                     //是否需要发送
  end;

  PBXFontCard = ^TBXFontCard;
  TBXFontCard = record
    FID            : string;                      //标识
    FName          : string;                      //名称
    FHost          : string;                      //IP
    FPort          : Integer;                     //Port
    FAreaTitle     : TBXFontCardArea;             //标题区
    FAreaData      : TBXFontCardArea;             //数据区
    FEnabled       : Boolean;                     //是否启用
  end;
  TBXFontCards = array of TBXFontCard;

  TBXFontCardManager = class;
  TBXFontCardSender = class(TThread)
  private
    FOwner: TBXFontCardManager;
    //拥有者
    FWaiter: TWaitObject;
    //等待对象
    FClient: TIdTCPClient;
    //网络对象
    FListA: TStrings;
    //列表对象
  protected
    procedure Execute; override;
    procedure Doexecute;
    //执行线程
    procedure DisconnectClient;
    //清理链路
  public
    constructor Create(AOwner: TBXFontCardManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TBXFontCardManager = class(TObject)
  private
    FCards: TBXFontCards;
    //屏卡列表
    FSender: TBXFontCardSender;
    //发送对象
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    function FindCard(const nID: string): Integer;
    //检索屏卡
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartService;
    procedure StopService;
    //起停服务
    procedure Display(const nTitle,nData: string; const nID: string = '';
      const nTitleKeep: Integer = 0; const nDataKeep: Integer = 0;
      const nTitleMode: PBXDisplayMode = nil;
      const nDataMode: PBXDisplayMode = nil);
    //显示内容
    class procedure InitData(var nData: TBXData);
    class procedure InitArea(var nArea: TBXArea);
    class procedure InitRequest(var nRequest: TBXRequest);
    class procedure InitDisplayMode(var nMode: TBXDisplayMode);
    //初始化数据
    class function Data2Bytes(const nArea: PBXArea; const nRequest: PBXRequest;
      const nData: PBXData; var nBuf: TIdBytes;
      const nCRC: Boolean = True): Boolean;
    //合并数据
  end;

var
  gBXFontCardManager: TBXFontCardManager = nil;
  //全局使用

implementation

const
  ERR_NO				          = 0;   //No Error
	ERR_OUTOFGROUP		      = 1;   //Command Group Error
	ERR_NOCMD			          = 2;   //Command Not Found
	ERR_BUSY			          = 3;   //The Controller is busy now
	ERR_MEMORYVOLUME	      = 4;   //Out of the Memory Volume
	ERR_CHECKSUM		        = 5;   //CRC16 Checksum Error
	ERR_FILENOTEXIST	      = 6;   //File Not Exist
	ERR_FLASH			          = 7;   //Flash Access Error
	ERR_FILE_DOWNLOAD       = 8;   //File Download Error
	ERR_FILE_NAME		        = 9;   //Filename Error
	ERR_FILE_TYPE		        = 10;  //File type Error
	ERR_FILE_CRC16		      = 11;  //File CRC16 Error
	ERR_FONT_NOT_EXIST      = 12;  //Font Library Not Exist
	ERR_FIRMWARE_TYPE       = 13;  //Firmware Type Error (Check the controller type)
	ERR_DATE_TIME_FORMAT    = 14;  //Date Time format error
	ERR_FILE_EXIST		      = 15;  //File Exist for File overwrite
	ERR_FILE_BLOCK_NUM      = 16;  //File block number error
	ERR_COMMUNICATE		      = 100; //通信失败
	ERR_PROTOCOL		        = 101; //协议数据不正确
	ERR_TIMEOUT			        = 102; //通信超时
	ERR_NETCLOSE		        = 103; //通信断开
	ERR_INVALID_HAND	      = 104; //无效句柄
	ERR_PARAMETER		        = 105; //参数错误
	ERR_SHOULDREPEAT	      = 106; //需要重复上次数据包
	ERR_FILE			          = 107; //无效文件

const
  cSizeData        = SizeOf(TBXData);
  cSizeArea        = SizeOf(TBXArea);
  cSizeRequst      = SizeOf(TBXRequest);
  cSizeResponse    = SizeOf(TBXResponse);
  cSizeDisplayMode = SizeOf(TBXDisplayMode);

  cSizeFontCard    = SizeOf(TBXFontCard);
  cSizeCardArea    = SizeOf(TBXFontCardArea);

  cCRCTable: array [0..255] of ULONG = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040
  );

function CRC(const nCrc, nData: ULONG): ULONG;
begin
  Result := (nCrc shr 8) xor cCRCTable[(nCrc xor nData) and $FF];
end;

//Date: 2018-07-31
//Parm: 数据;起始;结束
//Desc: 计算nData在nStart-nEnd区间内的CRC值
function CRC16(const nData: TIdBytes; nStart,nEnd: Integer): ULONG;
var nIdx: Integer;
begin
  Result := 0;
  nIdx := Low(nData);
  if nStart < nIdx then nStart := nIdx; //low

  nIdx := High(nData);
  if nEnd > nIdx then nEnd := nIdx; //high

  for nIdx:=nStart to nEnd do
    Result := CRC(Result, nData[nIdx]);
  //xxxxx
end;

//------------------------------------------------------------------------------
procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBXFontCardManager, '小屏LED服务', nEvent);
end;

//Date: 2018-07-31
//Parm: 整型值
//Desc: 将nInt转为低字节在前高字节在后字符串
function Int2LHStr(const nInt: Integer): string;
begin
  Result := Char(nInt mod 256) + Char(nInt div 256);
end;

//Date: 2018-07-31
//Parm: 字符串
//Desc: 将低字节在前高字节在后的字符串转为整型
function LHStr2Int(const nStr: string): Integer;
begin
  if Length(nStr) = 2 then
       Result := Ord(nStr[1]) + Ord(nStr[2]) * 256
  else Result := 0;
end;

procedure Int2LHBuf(const nInt: Integer; var nData: array of Byte);
begin
  if Length(nData) >= 2 then
  begin
    nData[0] := nInt mod 256;
    nData[1] := nInt div 256;
  end else
  begin
    nData[0] := 0;
    nData[1] := 0;
  end;
end;

function LHBuf2Int(const nData: array of Byte): Integer;
begin
  if Length(nData) >= 2 then
       Result := nData[0] +  nData[1] * 256
  else Result := 0;
end;

//Date: 2018-07-31
//Parm: 数据
//Desc: 初始化
class procedure TBXFontCardManager.InitData(var nData: TBXData);
begin
  with nData do
  begin
    FillChar(nData, cSizeData, #0);
    FillChar(FFrameBegin, SizeOf(FFrameBegin), $A5);

    FHead.FDstAddr      := $0001;
    FHead.FSrcAddr      := $8000;
    FHead.FCheckMode    := $00;
    FHead.FDisplayMode  := $00;
    FHead.FDeviceType   := BX_Any;
    FHead.FProtocol     := $02;
    FFrameEnd           := $5A;
  end;
end;

//Date: 2018-08-01
//Parm: 区域
//Desc: 初始化区域数据
class procedure TBXFontCardManager.InitArea(var nArea: TBXArea);
begin
  FillChar(nArea, cSizeArea, #0);
  InitDisplayMode(nArea.FDisplayMode);
end;

//Date: 2018-08-03
//Parm: 请求
//Desc: 初始化请求数据
class procedure TBXFontCardManager.InitRequest(var nRequest: TBXRequest);
begin
  with nRequest do
  begin
    FillChar(nRequest, cSizeRequst, #0);
    FCmdGroup       := $A3;
    FCmd            := $06;
    FResponse       := $02;
    FProcessMode    := $00;
    FDeleteAreaNum  := $00;
    FAreaNum        := $01;
  end;
end;

//Date: 2018-08-06
//Parm: 显示模式
//Desc: 默认显示模式
class procedure TBXFontCardManager.InitDisplayMode(var nMode: TBXDisplayMode);
begin
  with nMode do
  begin
    FillChar(nMode, cSizeDisplayMode, #0);
    FSingleLine    := BX_SingLine_02;             //多行显示
    FNewLine       := BX_NewLine_01;              //不自动换行
    FDisplayMode   := BX_DisplayMode_02;          //快速打出
    FSpeed         := $01;                        //显示速度,最快
    FStayTime      := $04;                        //2s
  end;
end;

//Date: 2018-07-31
//Parm: 区域;请求;数据;缓冲;校验
//Desc: 合并nArea.nRequest.nData的数据到nBuf中
class function TBXFontCardManager.Data2Bytes(const nArea: PBXArea;
  const nRequest: PBXRequest; const nData: PBXData; var nBuf: TIdBytes;
  const nCRC: Boolean): Boolean;
var nSize,nStart,nEnd: Integer;
begin
  Result := False;
  nSize := cSizeArea - (cBXDataMax - nArea.FDataLen);  
  if nSize > cBXDataMax then
  begin
    WriteLog('区域内容超长,已丢弃');
    Exit;
  end;

  nRequest.FAreaDataLen := nSize;
  Move(nArea^, nRequest.FData[0], nSize);

  nSize := cSizeRequst - (cBXDataMax - nRequest.FAreaDataLen);
  if nSize > cBXDataMax then
  begin
    WriteLog('请求内容超长,已丢弃');
    Exit;
  end;

  nData.FHead.FDataLen := nSize;
  Move(nRequest^, nData.FData[0], nSize);

  nSize := cSizeData - (cBXDataMax - nSize); //有效数据
  nBuf := RawToBytes(nData^, nSize);
  Result := True;

  if nCRC then
  begin
    nStart := SizeOf(nData.FFrameBegin);
    nEnd := nSize - SizeOf(nData.FVerify) - SizeOf(nData.FFrameEnd) - 1;
    //不包含校验位和帧尾

    Int2LHBuf(CRC16(nBuf, nStart, nEnd), nData.FVerify); //CRC
    nBuf[nSize - 3] := nData.FVerify[0];
    nBuf[nSize - 2] := nData.FVerify[1];
    nBuf[nSize - 1] := $5A;
  end;
end;

//------------------------------------------------------------------------------
constructor TBXFontCardManager.Create;
begin
  FSender := nil;
  SetLength(FCards, 0);
  FSyncLock := TCriticalSection.Create;
end;

destructor TBXFontCardManager.Destroy;
begin
  StopService;
  FSyncLock.Free;
  inherited;
end;

procedure TBXFontCardManager.StartService;
begin
  if Length(FCards) < 1 then
    raise Exception.Create('LED Card List Is Null.');
  //xxxxx

  if not Assigned(FSender) then
    FSender := TBXFontCardSender.Create(Self);
  FSender.WakupMe;
end;

procedure TBXFontCardManager.StopService;
begin
  if Assigned(FSender) then
    FSender.StopMe;
  FSender := nil;
end;

//Date: 2018-08-02
//Parm: 卡标识
//Desc: 返回标识nID的屏卡索引
function TBXFontCardManager.FindCard(const nID: string): Integer;
var nIdx: Integer;
begin
  Result := -1;
  //default

  for nIdx:=Low(FCards) to High(FCards) do
  if ((nID = '') and FCards[nIdx].FEnabled) or         //第一个可用屏卡
     (CompareText(nID, FCards[nIdx].FID) = 0) then     //标识匹配成功
  begin
    Result := nIdx;
    Break;
  end;
end;

//Date: 2018-08-02
//Parm: 标题;内容;卡标识;保持时长;显示模式
//Desc: 在nID卡上显示nTitle.nData内容
procedure TBXFontCardManager.Display(const nTitle, nData, nID: string;
  const nTitleKeep,nDataKeep: Integer; const nTitleMode,nDataMode: PBXDisplayMode);
var nIdx: Integer;
    nBool: Boolean;
begin
  nBool := False;
  FSyncLock.Enter;
  try
    nIdx := FindCard(nID);
    if nIdx < 0 then
    begin
      WriteLog(Format('未找到标识为[ %s ]的屏卡.', [nID]));
      Exit;
    end;

    with FCards[nIdx] do
    begin
      if not FEnabled then
      begin
        WriteLog(Format('标识为[ %s ]的屏卡已停用.', [nID]));
        Exit;
      end;

      with FAreaTitle do
      if nTitle <> cBXDataNull then //title
      begin
        FText         := nTitle;
        FTextSend     := True;
        FLastSend     := 0;

        FUserTimeout  := nTitleKeep;
        FUserEnable   := Assigned(nTitleMode);
        
        if FUserEnable then
          FUserMode := nTitleMode^;
        nBool := True;
      end;

      with FAreaData do
      if nData <> cBXDataNull then //data
      begin
        FText         := nData;
        FTextSend     := True;
        FLastSend     := 0;

        FUserTimeout  := nDataKeep;
        FUserEnable   := Assigned(nDataMode);
        if FUserEnable then
          FUserMode := nDataMode^;
        nBool := True;
      end;
    end;
  finally
    FSyncLock.Leave;
    if nBool and Assigned(FSender) then
      FSender.WakupMe;
    //xxxxx
  end;   
end;

//Desc: 载入配置
procedure TBXFontCardManager.LoadConfig(const nFile: string);
var nIdx,nInt: Integer;
    nDefCard: TBXFontCard;
    nXML: TNativeXml;
    nNode,nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    FillChar(nDefCard, cSizeFontCard, #0);
    SetLength(FCards, 0);
    nXML.LoadFromFile(nFile);

    for nIdx:=nXML.Root.NodeCount - 1 downto 0 do
    begin
      nNode := nXML.Root.Nodes[nIdx];
      if CompareText(nNode.Name, 'card') <> 0 then Continue;

      nInt := Length(FCards);
      SetLength(FCards, nInt + 1);
      FCards[nInt] := nDefCard; //init
      
      with FCards[nInt],nNode do
      begin
        FID := AttributeByName['ID'];
        FName := AttributeByName['Name'];
        FHost := NodeByName('ip').ValueAsString;
        FPort := NodeByName('port').ValueAsInteger;
        FEnabled := NodeByName('enable').ValueAsString <> '0';
              
        with FAreaTitle do
        begin
          FAreaLoc := $00;
          FTextSend := False;
          FUserEnable := False;

          nTmp := NodeByName('title_rect');
          with nTmp do
          FRect := Rect(StrToInt(AttributeByName['Left']),
                        StrToInt(AttributeByName['Top']),
                        StrToInt(AttributeByName['Width']),
                        StrToInt(AttributeByName['Height']));
          //xxxxx

          nTmp := NodeByName('title_mode');
          with nTmp,FTextMode do
          begin
            InitDisplayMode(FTextMode);
            //init

            FDisplayMode := StrToInt(AttributeByName['Display']);
            FSpeed       := StrToInt(AttributeByName['Speed']);
            FStayTime    := StrToInt(AttributeByName['StayTime']);
          end;

          nTmp := NodeByName('title_default');
          with nTmp,FDefaultMode do
          begin
            FDefaultText := AttributeByName['Text'];
            FDefaultSend := FDefaultText <> '';
            FDefaultTimeout := StrToInt(AttributeByName['Timeout']);

            InitDisplayMode(FDefaultMode);
            //init
            
            FDisplayMode := StrToInt(AttributeByName['Display']);
            FSpeed       := StrToInt(AttributeByName['Speed']);
            FStayTime    := StrToInt(AttributeByName['StayTime']);
          end;
        end;

        with FAreaData do
        begin
          FAreaLoc := $01;
          FTextSend := False;
          FUserEnable := False;

          nTmp := NodeByName('data_rect');
          with nTmp do
          FRect := Rect(StrToInt(AttributeByName['Left']),
                        StrToInt(AttributeByName['Top']),
                        StrToInt(AttributeByName['Width']),
                        StrToInt(AttributeByName['Height']));
          //xxxxx

          nTmp := NodeByName('data_mode');
          with nTmp,FTextMode do
          begin
            InitDisplayMode(FTextMode);
            //init
            
            FDisplayMode := StrToInt(AttributeByName['Display']);
            FSpeed       := StrToInt(AttributeByName['Speed']);
            FStayTime    := StrToInt(AttributeByName['StayTime']);
          end;

          nTmp := NodeByName('data_default');
          with nTmp,FDefaultMode do
          begin
            FDefaultText := AttributeByName['Text'];
            FDefaultSend := FDefaultText <> '';
            FDefaultTimeout := StrToInt(AttributeByName['Timeout']);

            InitDisplayMode(FDefaultMode);
            //init
            
            FDisplayMode := StrToInt(AttributeByName['Display']);
            FSpeed       := StrToInt(AttributeByName['Speed']);
            FStayTime    := StrToInt(AttributeByName['StayTime']);
          end;
        end;
      end;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TBXFontCardSender.Create(AOwner: TBXFontCardManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  
  FOwner := AOwner;
  FListA := TStringList.Create;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 1000;

  FClient := TIdTCPClient.Create(nil);
  FClient.ReadTimeout := 3 * 1000;
  FClient.ConnectTimeout := 3 * 1000;
end;

destructor TBXFontCardSender.Destroy;
begin
  FClient.Disconnect;
  FClient.Free;

  FWaiter.Free;
  FListA.Free;
  inherited;
end;

procedure TBXFontCardSender.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TBXFontCardSender.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TBXFontCardSender.DisconnectClient;
begin
  FClient.Disconnect;
  if Assigned(FClient.IOHandler) then
    FClient.IOHandler.InputBuffer.Clear;
  //try to swtich connection
end;

procedure TBXFontCardSender.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Doexecute;
    //xxxxx
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

procedure TBXFontCardSender.Doexecute;
var nStr: string;
    nBuf: TIdBytes;
    nIdx,nInt: Integer;
    
    nData: TBXData;
    nArea: TBXArea;
    nReq: TBXRequest;

  //Desc: 处理转义字符
  procedure TextEncode(const nFrameBegin,nFrameEnd: Integer);
  var i: Integer;
  begin
    nStr := '';
    nInt := Length(nBuf) - nFrameEnd - 1;      
    for i:=nFrameBegin to nInt do //掐头去尾
    begin
      if i = nInt then
           nStr := nStr + IntToHex(nBuf[i], 2)
      else nStr := nStr + IntToHex(nBuf[i], 2) + ' ';
    end;

    nStr := StringReplace(nStr, 'A6', 'A6 01', [rfReplaceAll]);
    nStr := StringReplace(nStr, 'A5', 'A6 02', [rfReplaceAll]);
    //遇到A5,转义为A6 02;遇到A6,转义为A6 01

    nStr := StringReplace(nStr, '5B', '5B 01', [rfReplaceAll]);
    nStr := StringReplace(nStr, '5A', '5B 02', [rfReplaceAll]); 
    //遇到5A,转义为5B 02;遇到5B,转义为5B 01

    SplitStr(nStr, FListA, 0, ' ');
    nInt := nFrameBegin + FListA.Count + nFrameEnd; //新缓存大小
    SetLength(nBuf, nInt);

    for i:=0 to FListA.Count-1 do
      nBuf[nFrameBegin+i] := StrToInt('$' + FListA[i]);
    //xxxxx

    FillChar(nBuf[0], nFrameBegin, $A5);
    FillChar(nBuf[nInt-nFrameEnd], nFrameEnd, $5A);
    //填充头尾
  end;

  //Desc: 构建发送缓存
  function MakeBuffer(var nCardArea: TBXFontCardArea): Boolean;
  begin
    with FOwner do
    try
      Result := False;
      FSyncLock.Enter;
      //lock first

      if nCardArea.FUserTimeout > 0 then
           nInt := nCardArea.FUserTimeout
      else nInt := nCardArea.FDefaultTimeout;

      if (nCardArea.FLastSend > 0) and
         (GetTickCountDiff(nCardArea.FLastSend) >= nInt * 1000) then
        nCardArea.FDefaultSend := True;
      //timeout,send default
      
      if not (nCardArea.FTextSend or nCardArea.FDefaultSend) then Exit;
      //no data to be sent

      InitData(nData);
      InitArea(nArea);
      InitRequest(nReq); //init

      nArea.FDynamicAreaLoc := nCardArea.FAreaLoc;
      nArea.FAreaX := SetNumberBit(nCardArea.FRect.Left, 16, 1, Bit_16);
      nArea.FAreaY := nCardArea.FRect.Top;
      nArea.FAreaWidth := SetNumberBit(nCardArea.FRect.Right, 16, 1, Bit_16);
      nArea.FAreaHeight := nCardArea.FRect.Bottom;

      if nCardArea.FTextSend then //text
      begin
        nStr := nCardArea.FText;
        if nCardArea.FUserEnable then
             nArea.FDisplayMode := nCardArea.FUserMode
        else nArea.FDisplayMode := nCardArea.FTextMode;

        nCardArea.FUserEnable := False;
        nCardArea.FTextSend := False;
        nCardArea.FLastSend := GetTickCount; 
      end else //default
      begin
        nStr := nCardArea.FDefaultText; 
        nArea.FDisplayMode := nCardArea.FDefaultMode;

        nCardArea.FDefaultSend := False;
        nCardArea.FLastSend := 0;
        nCardArea.FUserTimeout := 0;
      end;

      //------------------------------------------------------------------------
      nInt := Length(nStr);
      if nInt > cBXDataMax then //超长截取
      begin
        nInt := cBXDataMax;
        nStr := Copy(nStr, 1, nInt);

        with FOwner.FCards[nIdx] do
         WriteLog(Format('发送至[ %s.%s ]内容超长,已截取', [FID, FName]));
        //xxxxx
      end;

      nArea.FDataLen := nInt;
      StrPCopy(@nArea.FData, nStr);
      if not Data2Bytes(@nArea, @nReq, @nData, nBuf) then Exit; //并入发送缓存

      TextEncode(SizeOf(nData.FFrameBegin), SizeOf(nData.FFrameEnd));
      //转义特殊字符
      Result := True;
    finally
      FSyncLock.Leave;
    end;
  end;

  //Desc: 向屏卡发送数据
  procedure SendBuffer(const nHost: string; const nPort: Integer);
  begin
    if (FClient.Host <> nHost) or (FClient.Port <> nPort) then
      DisconnectClient;
    //swtich host

    try
      if not FClient.Connected then
      begin
        FClient.Host := nHost;
        FClient.Port := nPort;
        FClient.Connect;
      end;

      FClient.Socket.Write(nBuf);
      //send
    except
      on nErr: Exception do
      begin
        nStr := '屏卡[ %s.%d ]发送错误,描述: %s';
        nStr := Format(nStr, [nHost, nPort, nErr.Message]);
        WriteLog(nStr);
      end;
    end;
  end;
begin
  for nIdx:=Low(FOwner.FCards) to High(FOwner.FCards) do
  with FOwner.FCards[nIdx] do
  begin
    if not FEnabled then Continue;
    //invalid card

    if MakeBuffer(FAreaTitle) then
      SendBuffer(FHost, FPort);
    //xxxxx

    if MakeBuffer(FAreaData) then
      SendBuffer(FHost, FPort);
    //xxxxx
  end;
end;

initialization
  gBXFontCardManager := nil;
finalization
  FreeAndNil(gBXFontCardManager);
end.
