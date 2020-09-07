{*******************************************************************************
  作者: dmzn@163.com 2018-12-26
  描述: 基于地磅的定量装车业务
*******************************************************************************}
unit UMgrBasisWeight;

interface

uses
  Windows, Classes, SysUtils, SyncObjs, UMgrPoundTunnels, ULibFun,
  UWaitItem, USysLoger;

type
  TBWStatus = (bsInit, bsNew, bsStart, bsProcess, bsStable, bsDone, bsClose,bsError);
  //状态: 初始化;新添加;开始;装车中;平稳;完成;关闭

  PBWTunnel = ^TBWTunnel;
  TBWTunnel = record
    FID           : string;            //通道标识
    FBill         : string;            //交货单据
    FValue        : Double;            //待装量
    FValHas       : Double;            //已装量:平稳后的有效值
    FValMax       : Double;            //最大数据:地磅出现的最大数值
    FValTunnel    : Double;            //通道数据:当前地磅数据
    FValUpdate    : Cardinal;          //通道更新:通道数据的更新时间
    FValLastUse   : Cardinal;          //数据使用:最后使用数据的时间
    FValAdjust    : Double;            //冲击修正:定值,物料下落产生的重量
    FValKPFix     : Double;            //防超修正:定值,防止发超的保留量
    FValKPPercent : Double;            //防超修正:百分比,防止发超的保留量
    FValTwiceDiff : Double;            //数据差额:定值,两次平稳数据的有效差额
    FValTruckP    : Double;            //车辆皮重
    FWeightMax    : Double;            //修正后可装量:定值,装车中允许的最大量

    FShowDetail   : Boolean;           //显示明细日志
    FShowLastRecv : Cardinal;          //上次接收数据
    FStatusNow    : TBWStatus;         //当前状态
    FStatusNew    : TBWStatus;         //新状态
    FStableDone   : Boolean;           //平稳状态
    FStableLast   : Cardinal;          //平稳计时
    FWeightDone   : Boolean;           //装车完成:完成装车量
    FWeightOver   : Boolean;           //装车结束:完成并保存完毕

    //TimeOut
    FTONoData     : Integer;           //长时间无数据
    FTONoWeight   : Integer;           //长时间未上磅
    FInitWeight   : Cardinal;          //开始业务计时
    FTOProceFresh : Integer;           //装车进度刷新
    FInitFresh    : Cardinal;          //进度刷新计时
    FValFresh     : Double;            //进度刷新数据

    FTunnel       : PPTTunnelItem;     //通道参数
    FParams       : TStrings;          //参数项
    FFixParams    : TStrings;          //固定参数
    FSampleIndex  : Integer;           //采样索引
    FValSamples   : array of Double;   //数据采样
    FEnable       : Boolean;           //是否可用
    FLevel1       : Boolean;           //是否阀门关一级
    FLevel2       : Boolean;           //是否阀门关二级
  end;

  TBasisWeightManager = class;
  TBasisWeightWorker = class(TThread)
  private
    FOwner: TBasisWeightManager;
    //拥有者
    FActive: PBWTunnel;
    //当前通道
    FWaiter: TWaitObject;
    //等待对象
  protected
    procedure DoBasisWeight;
    procedure Execute; override;
    //执行业务
    function IsValidSamaple(const nCheckMin: Boolean): Boolean;
    //验证采样
  public
    constructor Create(AOwner: TBasisWeightManager);
    destructor Destroy; override;
    //创建释放
    procedure WakupMe;
    //唤醒线程
    procedure StopMe;
    //停止线程
  end;

  TBWStatusChange = procedure (const nTunnel: PBWTunnel);
  TBWStatusChangeEvent = procedure (const nTunnel: PBWTunnel) of object;
  //事件定义

  TBWEnumTunnels = procedure (const nTunnels: TList);
  //通道枚举回调

  TBasisWeightManager = class(TObject)
  private
    FTunnelManager: TPoundTunnelManager;
    FTunnels: TList;
    //通道列表
    FWorker: TBasisWeightWorker;
    //扫描对象
    FChangeProc: TBWStatusChange;
    FchangeEvent: TBWStatusChangeEvent;
    //事件定义
    FSyncLock: TCriticalSection;
    //同步锁定
  protected
    procedure ClearTunnels(const nFree: Boolean);
    //清理通道
    procedure OnTunnelData(const nValue: Double; const nPort: PPTPortItem);
    //通道数据
    procedure InitTunnelData(const nTunnel: PBWTunnel; nSimpleOnly: Boolean);
    //初始化
    function FindTunnel(const nTunnel: string; nLoged: Boolean): Integer;
    //检索通道
    procedure DoChangeEvent(const nTunnel: PBWTunnel; nNewStatus: TBWStatus);
    //响应事件
  public
    constructor Create;
    destructor Destroy; override;
    //创建释放
    procedure LoadConfig(const nFile: string);
    //读取配置
    procedure StartService;
    procedure StopService;
    //起停服务
    function IsBillBusy(const nBill: string;
     const nData: PBWTunnel = nil): Boolean;
    function IsTunnelBusy(const nTunnel: string;
     const nData: PBWTunnel = nil): Boolean;
    //通道忙
    procedure StartWeight(const nTunnel,nBill: string; const nValue: Double;
     const nPValue: Double = 0; const nParams: string = '');
    procedure StopWeight(const nTunnel: string);
    //起停称重
    procedure SetTruckPValue(const nTunnel: string; const nPValue: Double);
    //设置皮重
    procedure SetParam(const nTunnel,nName,nValue: string;
     const nFix: Boolean = False);
    function GetParam(const nTunnel,nName: string;
     const nFix: Boolean = False): string;
    //通道参数
    procedure EnumTunnels(const nCallback: TBWEnumTunnels);
    //检索通道
    property TunnelManager: TPoundTunnelManager read FTunnelManager;
    property OnStatusChange: TBWStatusChange read FChangeProc write FChangeProc;
    property OnStatusEvent: TBWStatusChangeEvent read FchangeEvent write FchangeEvent;
    //属性相关
  end;

var
  gBasisWeightManager: TBasisWeightManager = nil;
  //全局使用

implementation

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TBasisWeightManager, '定量装车管理', nEvent);
end;

constructor TBasisWeightManager.Create;
begin
  FWorker := nil;
  FTunnels := TList.Create;
  FSyncLock := TCriticalSection.Create;

  FTunnelManager := TPoundTunnelManager.Create;
  FTunnelManager.OnData := OnTunnelData;
end;

destructor TBasisWeightManager.Destroy;
begin
  if Assigned(FWorker) then
  begin
    FWorker.StopMe;
    FWorker := nil;
  end;

  ClearTunnels(True);
  FreeAndNil(FTunnelManager);
  FreeAndNil(FSyncLock);
  inherited;
end;

procedure TBasisWeightManager.ClearTunnels(const nFree: Boolean);
var nIdx: Integer;
    nTunnel: PBWTunnel;
begin
  for nIdx:=FTunnels.Count-1 downto 0 do
  begin
    nTunnel := FTunnels[nIdx];
    FreeAndNil(nTunnel.FParams);
    FreeAndNil(nTunnel.FFixParams);

    Dispose(nTunnel);
    FTunnels.Delete(nIdx);
  end;

  if nFree then
  begin
    FreeAndNil(FTunnels);
  end;
  //xxxxx
end;

procedure TBasisWeightManager.DoChangeEvent(const nTunnel: PBWTunnel;
 nNewStatus: TBWStatus);
begin
  try
    nTunnel.FStatusNew := nNewStatus;
    if Assigned(FChangeProc) then FChangeProc(nTunnel);
    if Assigned(FChangeEvent) then FchangeEvent(nTunnel);
  except
    on nErr: Exception do
    begin
      WriteLog(nErr.Message);
    end;
  end;

  nTunnel.FStatusNow := nNewStatus;
  //apply status
end;

procedure TBasisWeightManager.StartService;
var nIdx: Integer;
begin
  if FTunnels.Count < 1 then
    raise Exception.Create('TBasisWeightManager Need LoadConfig() First.');
  //xxxxx

  if not Assigned(FWorker) then
    FWorker := TBasisWeightWorker.Create(Self);
  //xxxxx

  for nIdx:=FTunnels.Count-1 downto 0 do
  begin
    FTunnelManager.ActivePort(PBWTunnel(FTunnels[nIdx]).FID, nil, True);
  end;
  //启动端口
end;

procedure TBasisWeightManager.StopService;
var nIdx: Integer;
begin
  if Assigned(FWorker) then
  begin
    FWorker.StopMe;
    FWorker := nil;
  end;

  for nIdx:=FTunnels.Count-1 downto 0 do
    FTunnelManager.ClosePort(PBWTunnel(FTunnels[nIdx]).FID);
  //启动端口
end;

//Desc: 初始化通道数据
procedure TBasisWeightManager.InitTunnelData(const nTunnel: PBWTunnel;
 nSimpleOnly: Boolean);
var nIdx: Integer;
begin
  if not nSimpleOnly then
  begin
    nTunnel.FBill := '';
    nTunnel.FParams.Clear;
    nTunnel.FStableLast := 0;
    nTunnel.FStableDone := False;
    nTunnel.FWeightOver := False;
    nTunnel.FWeightDone := False;
    nTunnel.FLevel1     := False;
    nTunnel.FLevel2     := False;

    nTunnel.FValue := 0;
    nTunnel.FValHas := 0;
    nTunnel.FValMax := 0;
    nTunnel.FValTunnel := 0;
    nTunnel.FValLastUse := 0;
    nTunnel.FValUpdate := GetTickCount;

    nTunnel.FValTruckP := 0;
    nTunnel.FWeightMax := 0;
    nTunnel.FValFresh := 0;
    nTunnel.FInitFresh := 0;
    nTunnel.FInitWeight := GetTickCount;
  end;

  for nIdx:=Low(nTunnel.FValSamples) to High(nTunnel.FValSamples) do
    nTunnel.FValSamples[nIdx] := 0;
  nTunnel.FSampleIndex := Low(nTunnel.FValSamples);
end;

//Date: 2018-12-27
//Parm: 通道号;记录日志
//Desc: 检索nTunnel索引
function TBasisWeightManager.FindTunnel(const nTunnel: string;
 nLoged: Boolean): Integer;
var nIdx: Integer;
begin
  Result := -1;
  //default
  
  for nIdx:=FTunnels.Count-1 downto 0 do
  if CompareText(nTunnel, PBWTunnel(FTunnels[nIdx]).FID) = 0 then
  begin
    Result := nIdx;
    Break;
  end;

  if (Result < 0) and nLoged then
    WriteLog(Format('通道[ %s ]不存在.', [nTunnel]));
  //xxxxx
end;

//Date: 2018-12-27
//Parm: 通道号;返回通道数据
//Desc: 判断nTunnel是否空闲
function TBasisWeightManager.IsTunnelBusy(const nTunnel: string;
  const nData: PBWTunnel): Boolean;
var nIdx: Integer;
    nPT: PBWTunnel;
begin
  Result := False;
  nIdx := FindTunnel(nTunnel, True);

  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FTunnels[nIdx];
    Result := (nPT.FBill <> '') and
              (nPT.FValue > 0) and (nPT.FValue > nPT.FValHas - nPT.FValTruckP)
              and (nPT.FValTunnel>0);
    //未装完

    if Assigned(nData) then
      nData^ := nPT^;
    //xxxxx
  finally
    FSyncLock.Leave;
  end;   
end;

//Date: 2018-12-27
//Parm: 通道号;交货单;应装;皮重;参数
//Desc: 开启新的称重业务
procedure TBasisWeightManager.StartWeight(const nTunnel, nBill: string;
  const nValue, nPValue: Double; const nParams: string);
var nIdx: Integer;
    nPT: PBWTunnel;
begin
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FTunnels[nIdx];
    if nPT.FBill <> nBill then
    begin
      InitTunnelData(nPT, False);
      nPT.FBill := nBill;
      nPT.FValue := nValue;

      if nPValue > 0 then
      begin
        nPT.FValTruckP := nPValue;
        nPT.FWeightMax := nValue + nPValue + nPT.FValAdjust - nPT.FValKPFix -
                          nValue * nPT.FValKPPercent;
        //表头最大重量
//        WriteLog('开单重量:' + FloatToStr(nPT.FValue) +
//               '皮重重量:' + FloatToStr(nPValue) +
//               '冲击重量:' + FloatToStr(nPT.FValAdjust) +
//               '预扣重量:' + FloatToStr(nPT.FValKPFix) +
//               '预扣重量(%):' + FloatToStr(nPT.FValue * nPT.FValKPPercent) +
//               '最终计算:' + FloatToStr(nPT.FWeightMax));
      end;
    end;

    if nParams <> '' then
      SplitStr(nParams, nPT.FParams, 0, ';');
    DoChangeEvent(nPT, bsNew);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2018-12-27
//Parm: 通道号
//Desc: 停止称重业务
procedure TBasisWeightManager.StopWeight(const nTunnel: string);
var nIdx: Integer;
begin
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    InitTunnelData(FTunnels[nIdx], False);
    DoChangeEvent(FTunnels[nIdx], bsClose);
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2019-03-19
//Parm: 通道号;皮重
//Desc: 设置nTunnel通道的皮重值
procedure TBasisWeightManager.SetTruckPValue(const nTunnel: string;
  const nPValue: Double);
var nIdx: Integer;
    nPT: PBWTunnel;
begin
  if nPValue <= 0 then Exit;
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FTunnels[nIdx];
    if (nPT.FBill <> '') and (nPT.FValue > 0) then
    begin
      nPT.FValTruckP := nPValue;
      nPT.FWeightMax := nPT.FValue + nPValue + nPT.FValAdjust - nPT.FValKPFix -
                        nPT.FValue * nPT.FValKPPercent;
      //表头最大重量
      WriteLog('开单重量:' + FloatToStr(nPT.FValue) +
               '皮重重量:' + FloatToStr(nPValue) +
               '冲击重量:' + FloatToStr(nPT.FValAdjust) +
               '预扣重量:' + FloatToStr(nPT.FValKPFix) +
               '预扣重量(%):' + FloatToStr(nPT.FValue * nPT.FValKPPercent) +
               '最终计算:' + FloatToStr(nPT.FWeightMax));
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2019-03-12
//Parm: 通道号;参数名;参数值;固定参数
//Desc: 为nTunnel增加一个nName=nValue的参数
procedure TBasisWeightManager.SetParam(const nTunnel, nName, nValue: string;
  const nFix: Boolean);
var nIdx: Integer;
    nPT: PBWTunnel;
begin
  if Trim(nName) = '' then Exit;
  //invalid name
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FTunnels[nIdx];
    //xxxxxx

    if nFix then
    begin
      if not Assigned(nPT.FFixParams) then
        nPT.FFixParams := TStringList.Create;
      nPT.FFixParams.Values[nName] := nValue;
    end else
    begin
      nPT.FParams.Values[nName] := nValue;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2019-03-20
//Parm: 通道名称;参数名;固定参数
//Desc: 获取nTunnel名称为nName的参数值
function TBasisWeightManager.GetParam(const nTunnel, nName: string;
  const nFix: Boolean): string;
var nIdx: Integer;
    nPT: PBWTunnel;
begin
  Result := '';
  if Trim(nName) = '' then Exit;
  //invalid name
  
  nIdx := FindTunnel(nTunnel, True);
  if nIdx < 0 then Exit;

  FSyncLock.Enter;
  try
    nPT := FTunnels[nIdx];
    //xxxxxx

    if nFix then
    begin
      if Assigned(nPT.FFixParams) then
        Result := nPT.FFixParams.Values[nName];
      //xxxxxx
    end else
    begin
      Result := nPT.FParams.Values[nName];
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//Date: 2019-03-19
//Parm: 枚举回调
//Desc: 获取通道列表项
procedure TBasisWeightManager.EnumTunnels(const nCallback: TBWEnumTunnels);
begin
  FSyncLock.Enter;
  try
    nCallback(FTunnels);
  finally
    FSyncLock.Leave;
  end;   
end;

procedure TBasisWeightManager.LoadConfig(const nFile: string);
var nStr: string;
    nIdx: Integer;
    nTunnel: PBWTunnel;
begin
  if FTunnels.Count > 0 then
    ClearTunnels(False);
  FTunnelManager.LoadConfig(nFile);

  for nIdx:=FTunnelManager.Tunnels.Count-1 downto 0 do
  begin
    New(nTunnel);
    FTunnels.Add(nTunnel);
    nTunnel.FTunnel := FTunnelManager.Tunnels[nIdx];

    nTunnel.FID     := nTunnel.FTunnel.FID;
    nTunnel.FParams := TStringList.Create;
    nTunnel.FFixParams := nil;
    SetLength(nTunnel.FValSamples, nTunnel.FTunnel.FSampleNum);

    if Assigned(nTunnel.FTunnel.FOptions) then
    begin
      nStr := nTunnel.FTunnel.FOptions.Values['NoDataTimeOut'];
      if IsNumber(nStr, False) then
           nTunnel.FTONoData := StrToInt(nStr) * 1000
      else nTunnel.FTONoData := 10 * 1000;

      nStr := nTunnel.FTunnel.FOptions.Values['EmptyIdleLong'];
      if IsNumber(nStr, False) then
           nTunnel.FTONoWeight := StrToInt(nStr) * 1000
      else nTunnel.FTONoWeight := 60 * 1000;

      nStr := nTunnel.FTunnel.FOptions.Values['ProceFresh'];
      if IsNumber(nStr, False) then
           nTunnel.FTOProceFresh := StrToInt(nStr) * 1000
      else nTunnel.FTOProceFresh := 1 * 1000;

      nStr := nTunnel.FTunnel.FOptions.Values['DashValue'];
      if IsNumber(nStr, True) then
           nTunnel.FValAdjust := StrToFloat(nStr)
      else nTunnel.FValAdjust := 0;

      nStr := nTunnel.FTunnel.FOptions.Values['KeepValue'];
      if IsNumber(nStr, True) then
           nTunnel.FValKPFix := StrToFloat(nStr)
      else nTunnel.FValKPFix := 0;

      nStr := nTunnel.FTunnel.FOptions.Values['KeepPercent'];
      if IsNumber(nStr, True) then
           nTunnel.FValKPPercent := StrToFloat(nStr)
      else nTunnel.FValKPPercent := 0;

      nStr := nTunnel.FTunnel.FOptions.Values['TwiceDiff'];
      if IsNumber(nStr, True) then
           nTunnel.FValTwiceDiff := StrToFloat(nStr)
      else nTunnel.FValTwiceDiff := 0.2; //大约2个成人

      nStr := nTunnel.FTunnel.FOptions.Values['ShowWeight'];
      nTunnel.FShowDetail := CompareText(nStr, 'Y') = 0;
      nTunnel.FShowLastRecv := 0;
    end;

    InitTunnelData(nTunnel, False);
    nTunnel.FStatusNow := bsInit;
    DoChangeEvent(nTunnel, bsInit);
  end;
end;

//Date: 2018-12-26
//Parm: 通道值;通道端口
//Desc: 处理从nPort发送来的数据
procedure TBasisWeightManager.OnTunnelData(const nValue: Double;
  const nPort: PPTPortItem);
var nIdx: Integer;
    nTunnel: PBWTunnel;
begin
  FSyncLock.Enter;
  try
    for nIdx:=FTunnels.Count-1 downto 0 do
    begin
      nTunnel := FTunnels[nIdx];
      if nTunnel.FTunnel <> nPort.FEventTunnel then Continue;
      nTunnel.FValUpdate := GetTickCount;

      if (nPort.FMinValue > 0) and (nValue < nPort.FMinValue) then
           nTunnel.FValTunnel := 0
      else nTunnel.FValTunnel := nValue;

      if nTunnel.FShowDetail and (
         GetTickCountDiff(nTunnel.FShowLastRecv) >= 1200) then
      begin
        WriteLog(Format('通道:[ %s.%s ] 数据:[ %.2f %.2f ]', [
          nTunnel.FID, nTunnel.FTunnel.FName, nValue, nTunnel.FValTunnel]));
        nTunnel.FShowLastRecv := GetTickCount();
      end;

      if nTunnel.FValTunnel > nTunnel.FValMax then
        nTunnel.FValMax := nTunnel.FValTunnel;
      Break;
    end;
  finally
    FSyncLock.Leave;
  end;
end;

//------------------------------------------------------------------------------
constructor TBasisWeightWorker.Create(AOwner: TBasisWeightManager);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 200;
end;

destructor TBasisWeightWorker.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TBasisWeightWorker.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TBasisWeightWorker.WakupMe;
begin
  FWaiter.Wakeup;
end;

procedure TBasisWeightWorker.Execute;
var nIdx: Integer;
    nItv: Int64;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    for nIdx:=FOwner.FTunnels.Count-1 downto 0 do
    try
      FOwner.FSyncLock.Enter;
      FActive := FOwner.FTunnels[nIdx];
      if (FActive.FBill = '') or (FActive.FValue <= 0) then Continue; //无业务

      if FActive.FValFresh <> FActive.FValTunnel then
      begin
        nItv := GetTickCountDiff(FActive.FInitFresh);
        if nItv >= FActive.FTOProceFresh then
        begin
          if (FActive.FValFresh = 0) and (FActive.FValTunnel > 0) then
               FOwner.DoChangeEvent(FActive, bsStart)
          else FOwner.DoChangeEvent(FActive, bsProcess);

          FActive.FValFresh := FActive.FValTunnel;
          //刷新仪表数值
          FActive.FInitFresh := GetTickCount;
        end;
      end;

      nItv := GetTickCountDiff(FActive.FInitWeight);
      if (FActive.FValMax <= 0) and (nItv >= FActive.FTONoWeight) then
      begin
        FOwner.DoChangeEvent(FActive, bsClose);
        FOwner.InitTunnelData(FActive, False);

        WriteLog(Format('通道[ %s.%s ]业务超时,已退出.', [
          FActive.FID, FActive.FTunnel.FName]));
        Continue;
      end;
      
      nItv := GetTickCountDiff(FActive.FValUpdate);
      if nItv >= FActive.FTONoData then //地磅故障
      begin
        FOwner.DoChangeEvent(FActive, bsError);
        FOwner.InitTunnelData(FActive, False);

        WriteLog(Format('通道[ %s.%s ]故障,无数据应答.', [
          FActive.FID, FActive.FTunnel.FName]));
        Continue;
      end;

      if nItv >= 3200 then Continue;
      //更新超时: 不予认可
      if nItv < 200 then
      begin
        nItv := GetTickCountDiff(FActive.FValLastUse);
        if nItv < 200 then Continue;
        //更新过频: 减速
      end;

      FActive.FValLastUse := GetTickCount();
      DoBasisWeight;
      if Terminated then Break;
    finally
      FOwner.FSyncLock.Leave;
    end;
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end;
end;

//Date: 2018-12-27
//Parm: 是否验证最小值
//Desc: 验证采样是否稳定
function TBasisWeightWorker.IsValidSamaple(const nCheckMin: Boolean): Boolean;
var nIdx: Integer;
    nVal: Integer;
begin
  Result := False;
  //default

  for nIdx:=High(FActive.FValSamples) downto 1 do
  begin
    if nCheckMin and (FActive.FValSamples[nIdx] < 0.02) then Exit;
    //样本不完整

    nVal := Trunc(FActive.FValSamples[nIdx] * 1000 -
                  FActive.FValSamples[nIdx-1] * 1000);
    if Abs(nVal) >= FActive.FTunnel.FSampleFloat then Exit; //浮动值过大
  end;
  
  Result := True;
end;

procedure TBasisWeightWorker.DoBasisWeight;
begin
  if (not FActive.FWeightDone) and (FActive.FWeightMax > 0) and
     (FActive.FValTunnel >= FActive.FWeightMax) then //未装车完成
  begin
    FActive.FWeightDone := True;
    FOwner.DoChangeEvent(FActive, bsDone);
  end; 

  FActive.FValSamples[FActive.FSampleIndex] := FActive.FValTunnel;
  Inc(FActive.FSampleIndex);

  if FActive.FSampleIndex >= FActive.FTunnel.FSampleNum then
    FActive.FSampleIndex := Low(FActive.FValSamples);
  //循环索引

  if FActive.FStableDone then
  begin
    FActive.FStableDone := (FActive.FValHas = FActive.FValTunnel) or (
      Abs(FActive.FValHas - FActive.FValTunnel) < FActive.FValTwiceDiff);
    //小范围浮动视为平稳

    if FActive.FValHas = FActive.FValTunnel then
    begin
      FActive.FStableLast := GetTickCount();
      //未浮动,更新计时
    end else

    if FActive.FStableDone and (GetTickCountDiff(
       FActive.FStableLast) >= 3 * 1000) then
    begin
      FActive.FStableDone := False;
      FActive.FStableLast := GetTickCount();
      //长时间小范围浮动,更新计时
    end;
  end;

  if not FActive.FStableDone then
  begin
    {**************************** FActive.FStableDone **************************
    标记位用法:
     1.正常情况下,若通道数据FValTunnel没变化,则DoChangeEvent只调用一次.
     2.若DoChangeEvent由于某些原因,比如光栅判定失败,则需要再次触发业务,可手动
       设置FStableDone=False.
    ***************************************************************************}
    if IsValidSamaple(True) then //有效数据平稳
    begin
      FActive.FStableDone := True;
      FActive.FValHas := FActive.FValTunnel;

      if not FActive.FWeightOver then //未完成保存
      begin
        FOwner.DoChangeEvent(FActive, bsStable);
        if not FActive.FStableDone then
          FOwner.InitTunnelData(FActive, True);
        //reset simples

        if FActive.FStableDone and FActive.FWeightDone then
          FActive.FWeightOver := True;
        //装车完成且成功保存
      end;
    end;

    if (FActive.FValTunnel = 0) and
       (FActive.FValMax > 0) and IsValidSamaple(False) then //车辆下磅
    begin
      if not FActive.FWeightOver then //未装车完成且保存
      begin
        if FActive.FValMax - FActive.FValAdjust -
           FActive.FValHas >= FActive.FValTwiceDiff then
        begin
          FActive.FValHas := FActive.FValMax;
          FOwner.DoChangeEvent(FActive, bsStable);
        end;
        {************************* FActive.FValTwiceDiff ***********************
        未装车完成下磅:
        1.磅重未达到车辆最大可装量(皮重 + 装车量 + 冲击修正 - 保留量)
        2.磅重达到最大可装量,但未等待数据平稳并保存,直接下磅.
        3.由于车辆已下磅,无法获取平稳后的磅重,需参考已知最大磅重.
        4.若最后保存的平稳重量FValHas与最大磅重误差过大,则按最大量保存.
        ***********************************************************************}
      end;

      FActive.FStableDone := True;
      FOwner.DoChangeEvent(FActive, bsClose); //关闭业务
      FOwner.InitTunnelData(FActive, False);

      WriteLog(Format('通道[ %s.%s ]车辆已下磅.', [
        FActive.FID, FActive.FTunnel.FName]));
      //xxxxx
    end;
  end;
end;

function TBasisWeightManager.IsBillBusy(const nBill: string;
  const nData: PBWTunnel): Boolean;
begin
  //
end;

initialization
  gBasisWeightManager := nil;
finalization
  FreeAndNil(gBasisWeightManager);
end.
