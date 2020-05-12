unit uHttpClient;

interface

uses Classes, HproseCommon,IdHeaderList, SysUtils{$IFDEF FPC}, LResources{$ENDIF},
      System.TypInfo, uRecordType, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Vcl.Imaging.GIFImg,
      IdMultiPartFormData, uMsMultiPartFormData, Vcl.ExtCtrls, IdSSLOpenSSL;


type

  THttpClient = class
  private
    FHttpPool: IList;
    FUserName: string;
    FPassword: string;
    FHeaders: TIdHeaderList;
    FUserAgent: string;
    FKeepAlive: Boolean;
    FKeepAliveTimeout: Integer;
    FTimeout: Integer;
    FServiceUrl : string;
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor  Destroy; override;
  public
    function Invoke(const xURL: string; const Args: TArrXParam): Variant;overload;
    function Invoke(const xURL: string; const PostParam:TMsMultiPartFormDataStream): Variant; overload;
    function DownPic(szUrl, szPathFileName : string): string;
    function DownFile(szUrl, szPathFileName : string): string;
  public
    property KeepAlive: Boolean read FKeepAlive write FKeepAlive;
    property Timeout: Integer read FTimeout write FTimeout;
    property ServiceUrl: string read FServiceUrl write FServiceUrl;
  end;


implementation


uses IdHttp, IdGlobalProtocols, IdCookieManager;

var
  CookieManager: TIdCookieManager = nil;


constructor THttpClient.Create(AOwner: TComponent);
begin
  FHttpPool := TArrayList.Create(10);
  FHeaders := TIdHeaderList.Create(TIdHeaderQuotingType.QuotePlain);
  FUserName := '';
  FPassword := '';
  FKeepAlive := True;
  FKeepAliveTimeout := 300;
  //FUserAgent := 'Http Client for Delphi (Indy10)';
  FTimeout := 30000;
end;

destructor THttpClient.Destroy;
var
  I: Integer;
  IdHttp: TIdHttp;
begin
  FHttpPool.Lock;
  try
    for I := FHttpPool.Count - 1 downto 0 do begin
      IdHttp := TIdHttp(VarToObj(FHttpPool.Delete(I)));
      FreeAndNil(IdHttp);
    end;
  finally
    FHttpPool.Unlock;
  end;
  FreeAndNil(FHeaders);
  inherited;
end;

function THttpClient.Invoke(const xURL: string; const Args:TArrXParam): Variant;
var IdHttp : TIdHttp;
    FidSSL : TIdSSLIOHandlerSocketOpenSSL;
    OutStream, InStream, ZipStream: TBytesStream;
    wParam : TStringList;
    nIdx : Integer;
    EHttpException : Exception;
begin
  wParam := TStringList.Create();
  try
    Result:= '';
    try
      FHttpPool.Lock;
      try
        if FHttpPool.Count > 0 then
          IdHttp := TIdHttp(VarToObj(FHttpPool.Delete(FHttpPool.Count - 1)))
        else
        begin
          IdHttp := TIdHttp.Create(nil);
          FidSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
          IdHttp.IOHandler := FidSSL;
        end;
      finally
        FHttpPool.Unlock;
      end;
      //***********************************************************
      wParam.Clear;

      for nIdx := 0 to High(Args) do
        wParam.Add(Args[nIdx].Key+'='+Args[nIdx].value);

      IdHttp.ReadTimeout := FTimeout;
      IdHttp.Request.UserAgent := FUserAgent;
      if KeepAlive then begin
        IdHttp.Request.Connection := 'keep-alive';
        FHeaders.Values['Keep-Alive'] := IntToStr(FKeepAliveTimeout);
      end
      else IdHttp.Request.Connection := 'close';
      IdHttp.Request.ContentType := 'application/x-www-form-urlencoded';
      IdHttp.AllowCookies := True;
      IdHttp.CookieManager := CookieManager;
      IdHttp.HTTPOptions := IdHttp.HTTPOptions + [hoKeepOrigProtocol];
      IdHttp.ProtocolVersion := pv1_1;
      IdHttp.Request.CustomHeaders := FHeaders;

      Result:= IdHttp.Post(xURL, wParam);
      //***********************************************************
      IdHttp.Request.Clear;
      IdHttp.Request.CustomHeaders.Clear;
      IdHttp.Response.Clear;
      FHttpPool.Lock;
      try
        FHttpPool.Add(ObjToVar(IdHttp));
      finally
        FHttpPool.Unlock;
      end;
    except
      On Ex:Exception do
      begin
        EHttpException.Create(Ex.ToString);
        raise EHttpException;
      end;
    end;
  finally
    wParam.Free;
  end;
end;

function THttpClient.Invoke(const xURL: string; const PostParam:TMsMultiPartFormDataStream): Variant;
var IdHttp: TIdHttp;
    FidSSL : TIdSSLIOHandlerSocketOpenSSL;
    OutStream, InStream, ZipStream: TBytesStream;
    nIdx : Integer;
    EHttpException : Exception;
begin
  try
    Result:= '';
    try
      FHttpPool.Lock;
      try
        if FHttpPool.Count > 0 then
          IdHttp := TIdHttp(VarToObj(FHttpPool.Delete(FHttpPool.Count - 1)))
        else
        begin
          IdHttp := TIdHttp.Create(nil);
          FidSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
          IdHttp.IOHandler := FidSSL;
        end;
      finally
        FHttpPool.Unlock;
      end;
      //***********************************************************
      IdHttp.ReadTimeout := FTimeout;
      IdHttp.Request.UserAgent := FUserAgent;
      if KeepAlive then begin
        IdHttp.Request.Connection := 'keep-alive';
        FHeaders.Values['Keep-Alive'] := IntToStr(FKeepAliveTimeout);
      end
      else IdHttp.Request.Connection := 'close';
      IdHttp.Request.ContentType := 'application/x-www-form-urlencoded';
      IdHttp.AllowCookies := True;
      IdHttp.CookieManager := CookieManager;
      IdHttp.Request.ContentType := PostParam.RequestContentType;
      PostParam.PrepareStreamForDispatch;
      IdHttp.HTTPOptions := IdHttp.HTTPOptions + [hoKeepOrigProtocol];
      IdHttp.ProtocolVersion := pv1_1;
      IdHttp.Request.CustomHeaders := FHeaders;
      PostParam.Position := 0;

      Result:= IdHttp.Post(xURL, PostParam);
      //***********************************************************
      IdHttp.Request.Clear;
      IdHttp.Request.CustomHeaders.Clear;
      IdHttp.Response.Clear;
      FHttpPool.Lock;
      try
        FHttpPool.Add(ObjToVar(IdHttp));
      finally
        FHttpPool.Unlock;
      end;
    except
      On Ex:Exception do
      begin
        EHttpException.Create(Ex.ToString);
        raise EHttpException;
      end;
    end;
  finally
    PostParam.Free;
  end;
end;

function THttpClient.DownPic(szUrl, szPathFileName : string): string;
const ReJson = '{"code":%s,"msg":"%s","data":{"FilePath":"%s"}}';
var
  FidHttp: TIdHttp;
  FidSSL : TIdSSLIOHandlerSocketOpenSSL;
  BMPStrem : TMemoryStream;
  Buffer : Word;
begin
  Result:= Format(ReJson, ['0', '操作失败', '']);
  try
    FidHttp := TIdHttp.Create(nil);
    FidSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FidHttp.IOHandler := FidSSL;
    BMPStrem := TMemoryStream.Create;
    try
      FIdHttp.Request.Clear;
      FIdHttp.HTTPOptions:= FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
      FIdHttp.ProtocolVersion:= pv1_1;
      FidHttp.Get(szUrl, BMPStrem);
      //************************************************************************
      BMPStrem.Position := 0;
      BMPStrem.ReadBuffer(Buffer, 2);
      BMPStrem.Position := 0;
      if Buffer = $5089 then          // $4947 gif      $5089 png     $D8FF  JPEG     $4D42  BMP
      begin
        BMPStrem.SaveToFile(szPathFileName+'.png');
        Result:= Format(ReJson, ['1', '操作成功', StringReplace(szPathFileName+'.png', '\', '\\', [rfReplaceAll])]);
      end
      else if Buffer = $4947 then          // gif
      begin
        BMPStrem.SaveToFile(szPathFileName+'.gif');
        Result:= Format(ReJson, ['1', '操作成功', StringReplace(szPathFileName+'.gif', '\', '\\', [rfReplaceAll])]);
      end
      else if Buffer=$D8FF then       // jpg
      begin
        BMPStrem.SaveToFile(szPathFileName+'.jpeg');
        Result:= Format(ReJson, ['1', '操作成功', StringReplace(szPathFileName+'.jpeg', '\', '\\', [rfReplaceAll])]);
      end
      else if Buffer=$4D42 then       // jpg
      begin
        BMPStrem.SaveToFile(szPathFileName+'.bmp');
        Result:= Format(ReJson, ['1', '操作成功', StringReplace(szPathFileName+'.bmp', '\', '\\', [rfReplaceAll])]);
      end;
    except
      on Ex: Exception do
      begin
        Result:= Format(ReJson, ['0', Ex.ToString, '']);
      end;
    end;
  finally
    if BMPStrem <> nil then FreeAndNil(BMPStrem);
    FidHttp.Disconnect;
  end;
end;

function THttpClient.DownFile(szUrl, szPathFileName : string): string;
const ReJson = '{"code":%s,"msg":"%s","data":{"FilePath":"%s"}}';
var
  FidHttp: TIdHttp;
  FidSSL : TIdSSLIOHandlerSocketOpenSSL;
  MemStream : TMemoryStream;
  FileStream: TFileStream;
begin
  Result:= Format(ReJson, ['0', '操作失败', '']);
  try
    FidHttp := TIdHttp.Create(nil);
    FidSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FidHttp.IOHandler := FidSSL;
    MemStream := TMemoryStream.Create;
    FileStream:= TFileStream.Create(szPathFileName, fmCreate);
    try
      FIdHttp.Request.Clear;
      FIdHttp.HTTPOptions:= FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
      FIdHttp.ProtocolVersion:= pv1_1;
      FidHttp.Get(szUrl, MemStream);
      //************************************************************************
      MemStream.Position := 0;
      MemStream.SaveToStream(FileStream);
      Result:= Format(ReJson, ['1', '下载成功', szPathFileName]);
    except
      on Ex: Exception do
      begin
        Result:= Format(ReJson, ['0', Ex.ToString, '']);
      end;
    end;
  finally
    FreeAndNil(MemStream);
    FreeAndNil(FileStream);
    FidHttp.Disconnect;
  end;
end;


end.
