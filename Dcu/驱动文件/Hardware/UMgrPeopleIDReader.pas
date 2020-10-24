{*******************************************************************************
  作者: dmzn@163.com 2019-03-18
  描述: 新中新身份证读卡器驱动
*******************************************************************************}
unit UMgrPeopleIDReader;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, USysLoger;

type
  TCardOpenMode = (omManual=0, omAuto=1);
  //打开方式: 手动;自动

  TCardPhotoPath = (ppCRoot=0, ppCurrent=1, ppFix=2);
  //照片路径: C盘;当前路径;指定路径

  TCardPhotoType = (ptBMP=0, ptJPG=1, ptBase64=2, ptWLT=3, ptNone=4);
  //照片类型

  TCardPhotoName = (pnTMP=0, pnName=1, pnID=2, pnNameID=3);
  //照片名称
  
  PCardData = ^TCardData;
  TCardData = packed record
    FName            : array[0..31] of Char;  //姓名
    FSex             : array[0..5] of Char;   //性别
    FNation          : array[0..63] of Char;  //民族
    FBorn            : array[0..17] of Char;  //出生日期
    FAddress         : array[0..71] of Char;  //住址
    FIDCardNo        : array[0..37] of Char;  //身份证号
    FGrantDept       : array[0..31] of Char;  //发证机关
    FUserLifeBegin   : array[0..17] of Char;  //有效期开始
    FUserLifeEnd     : array[0..17] of Char;  //有效期结束
    FPassID          : array[0..19] of Char;  //通行证号
    FIssuesTimes     : array[0..5] of Char;   //签发次数
    FReserved        : array[0..11] of Char;  //保留
    FPhotoFileName   : array[0..254] of Char; //照片路径
    FCardType        : array[0..3] of Char;   //证件类型
    FEngName         : array[0..121] of Char; //英文名
    FCertVol         : array[0..5] of Char;   //证件版本
  end;
  
  TPeopleIDReader = class
  private
    FPort: Integer;
    //读卡器端口
    FLastCode: Integer;
    FLastError: string;
    //上次异常
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure InitData(var nData: TCardData);
    //初始数据
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    function ReadData(const nPath: string=''; const nName: TCardPhotoName = pnID;
      const nType: TCardPhotoType = ptBMP): TCardData;
    //读取数据
    property LastCode: Integer read FLastCode;
    property LastError: string read FLastError;
    //属性相关
  end;

var
  gPeopleIDReader: TPeopleIDReader = nil;

implementation

const
  cLibDLL = 'SynIDCard.dll';

function Syn_FindReader(): Integer;
 stdcall; external cLibDLL;
//寻读卡器
function Syn_OpenPort(nPort: Integer): Integer;
 stdcall; external cLibDLL;
//打开端口
function Syn_ClosePort(nPort: Integer): Integer;
 stdcall; external cLibDLL;
//关闭端口
function Syn_StartFindIDCard(nPort: Integer; nIn: PChar;
 nIFOpen: Integer): Integer; stdcall; external cLibDLL;
//开始寻卡
function Syn_SelectIDCard(nPort: Integer; nIN: PChar;
 nIfOpen: Integer): Integer; stdcall; external cLibDLL;
//选中卡片
function Syn_SetPhotoPath(nPath: Integer; nPhotoPath: PChar): Integer;
 stdcall; external cLibDLL;
//设置照片文件存储的路径
function Syn_SetPhotoType(nType: Integer): Integer;
 stdcall; external cLibDLL;
//设置照片类型
function Syn_SetPhotoName(nName: Integer): Integer;
 stdcall; external cLibDLL;
//设置照片名称
function Syn_ReadMsg(nPort: Integer; nIfOpen: Integer;
 nCardData: PCardData): Integer; stdcall; external cLibDLL;
//读取身份证信息
function Syn_ReadBaseMsg(nPort: Integer; nCHMsg: PChar; nCHMsgLen: PInteger;
 nPHMsg: PChar; nPHMsgLen: PInteger; nIfOpen: Integer): Integer;
 stdcall; external cLibDLL;
//读取身份证内基本信息区域信息

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TPeopleIDReader, '身份证服务', nEvent);
end;

//Date: 2019-03-18
//Parm: 错误码
//Desc: 返回nCode的描述
function Code2Desc(const nCode: Integer): string;
begin
  case nCode of
    $90	: Result := '操作成功';
    $91	: Result := '居民身份证中无此项内容';
    $9F	: Result := '寻找居民身份证成功';
    $01	: Result := '端口打开失败/端口尚未打开/端口号不合法';
    $02	: Result := 'PC接收超时，在规定的时间内未接收到规定长度的数据';
    $03	: Result := '数据传输错误';
    $05	: Result := 'SAM_A串口不可用，只有Syn_GetCOMBaud函数返回';
    $09	: Result := '打开文件失败';
    $10	: Result := '接收业务终端数据的校验和错';
    $11	: Result := '接收业务终端数据的长度错';
    $21	: Result := '接收业务终端的命令错误,包括命令中的各种数值或逻辑搭配错误';
    $23	: Result := '越权操作';
    $24	: Result := '无法识别的错误';
    $80	: Result := '寻找居民身份证失败';
    $81	: Result := '选取居民身份证失败';
    $31	: Result := '居民身份证认证SAM_A失败';
    $32	: Result := 'SAM_A认证居民身份证失败';
    $33	: Result := '信息验证失败';
    $37	: Result := '指纹信息验证错误';
    $3F	: Result := '信息长度错误';
    $40	: Result := '无法识别的居民身份证类型';
    $41	: Result := '读居民身份证操作失败';
    $47	: Result := '取随机数失败';
    $60	: Result := 'SAM_A自检失败，不能接收命令';
    $66	: Result := 'SAM_A没经过授权,无法使用';
  end;
end;

//------------------------------------------------------------------------------
constructor TPeopleIDReader.Create;
begin
  FLastCode := -1;
  FLastError := '';

  FPort := 0;
  FSyncLock := TCriticalSection.Create;
end;

destructor TPeopleIDReader.Destroy;
begin
  if FPort > 0 then
    Syn_ClosePort(FPort);
  //xxxxx

  FSyncLock.Free;
  inherited;
end;

//Date: 2019-03-28
//Parm: 数据
//Desc: 初始化nData数据
procedure TPeopleIDReader.InitData(var nData: TCardData);
var nDef: TCardData;
begin
  FillChar(nDef, SizeOf(nDef), #0);
  nData := nDef;
end;

//Date: 2019-03-28
//Parm: 照片路径;照片文件名;照片类型
//Desc: 读取身份证信息
function TPeopleIDReader.ReadData(const nPath: string;
  const nName: TCardPhotoName; const nType: TCardPhotoType): TCardData;
var nHasOpen: Boolean;
    nBuf: array[0..254] of Char;
begin
  InitData(Result);
  //init
  nHasOpen := False;

  FSyncLock.Enter;
  try
    if FPort = 0 then
    begin
      FLastCode := Syn_FindReader();
      if FLastCode <= 0 then
      begin
        FLastError := '没有找到读卡器';
        WriteLog(FLastError);

        FPort := 0;
        Exit;
      end;

      FPort := FLastCode;
      //find port
    end;

    if DirectoryExists(nPath) then
    begin
      StrPCopy(@nBuf[0], nPath);
      FLastCode := Syn_SetPhotoPath(Ord(ppFix), @nBuf[0]);
    end else FLastCode := Syn_SetPhotoPath(Ord(ppCurrent), @nBuf[0]);

    if FLastCode <> 0 then
    begin
      FLastError := '设置照片路径错误,描述: %d,%s';
      FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
      WriteLog(FLastError);
      Exit;
    end;

    FLastCode := Syn_SetPhotoType(Ord(nType));
    if FLastCode <> 0 then
    begin
      FLastError := '设置照片类型错误,描述: %d,%s';
      FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
      WriteLog(FLastError);
      Exit;
    end;

    FLastCode := Syn_SetPhotoName(Ord(nName));
    if FLastCode <> 0 then
    begin
      FLastError := '设置照片名称错误,描述: %d,%s';
      FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
      WriteLog(FLastError);
      Exit;
    end;

    FLastCode := Syn_OpenPort(FPort);
    if FLastCode <> 0 then
    begin
      Syn_ClosePort(FPort); //打开异常则关闭
      FPort := 0;

      FLastError := '打开端口错误,描述: %d,%s';
      FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
      WriteLog(FLastError);
      Exit;
    end;

    nHasOpen := True;
    FLastCode := Syn_StartFindIDCard(FPort, @nBuf[0], Ord(omManual)); //寻卡    
    if FLastCode = 0 then
    begin
      Sleep(20);
      FLastCode := Syn_SelectIDCard(FPort, @nBuf[0], Ord(omManual)); //选卡

      if FLastCode <> 0 then
      begin
        FLastError := '选卡失败,描述: %d,%s';
        FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
        WriteLog(FLastError);
        Exit;
      end;
    end;

    Sleep(20);
    FLastCode := Syn_ReadMsg(FPort, Ord(omManual), @Result); //读卡    
    if (FLastCode <> 0) and (FLastCode <> 1) then
    begin
      FLastError := '读取身份证信息失败,描述: %d,%s';
      FLastError := Format(FLastError, [FLastCode, Code2Desc(FLastCode)]);
      WriteLog(FLastError);
      Exit;
    end;

    FLastCode := -1;
    FLastError := '';
    //no error
  finally
    if nHasOpen then
      Syn_ClosePort(FPort);
    FSyncLock.Leave;
  end;
end;

initialization
  gPeopleIDReader := nil;
finalization
  FreeAndNil(gPeopleIDReader);
end.
