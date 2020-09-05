{*******************************************************************************
  作者: dmzn 2008-9-20
  描述: 公司信息
*******************************************************************************}
unit UFormStockQueue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, StdCtrls, ExtCtrls, dxLayoutControl, cxContainer, cxEdit,
  cxTextEdit, cxControls, cxMemo, UFormBase, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters,UFormGetStockQueue;

type
  TfFormStockQueue = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnExit: TButton;
    dxLayoutControl1Item7: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item8: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    Button1: TButton;
    dxLayoutControl1Item9: TdxLayoutItem;
    Button2: TButton;
    dxLayoutControl1Item1: TdxLayoutItem;
    Button3: TButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    Button4: TButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    Button5: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
  private
    { Private declarations }
    Form1,Form2,Form3,Form4,Form5 : TfFormGetStockQueue;
    procedure InitFormData;
    {*初始化界面*}
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysConst, USysDB, USysPopedom;

ResourceString
  sCompany = 'Company';

//------------------------------------------------------------------------------
class function TfFormStockQueue.CreateForm;
begin
  Result := nil;

  with TfFormStockQueue.Create(Application) do
  begin
    Caption := '排队一览表';
    InitFormData;
    BtnOK.Visible := False;

    ShowModal;
    Free;
  end;
end;

class function TfFormStockQueue.FormID: integer;
begin
  Result := cFI_FormStockQueue;
end;

//------------------------------------------------------------------------------
//Date: 2009-5-31
//Parm: 字符串;处理或者逆向处理
//Desc: 处理nStr中的回车换行符
function RegularStr(const nStr: string; const nGo: Boolean): string;
begin
  if nGo then
       Result := StringReplace(nStr, #13#10, '*|*', [rfReplaceAll])
  else Result := StringReplace(nStr, '*|*', #13#10, [rfReplaceAll]);
end;

//Desc: 初始化界面数据
procedure TfFormStockQueue.InitFormData;
var nIni: TIniFile;
begin
  //
end;

//Desc: 保存
procedure TfFormStockQueue.BtnOKClick(Sender: TObject);
var nIni: TIniFile;
begin
  //
end;

procedure TfFormStockQueue.Button1Click(Sender: TObject);
begin
  inherited;
  if  not Assigned(Form1) then
   Form1                       := TfFormGetStockQueue.Create(nil);
   Form1.FStockName            := '1-2';
   Form1.Caption               := '1-2排队一览表';
   Form1.dxLayout1Item3.Caption:= '1-2  排  队  一  览  表                     ';
   Form1.Button1Click(nil);
   Form1.Show;
end;

procedure TfFormStockQueue.Button2Click(Sender: TObject);
begin
  inherited;
  if not Assigned(Form2) then
   Form2                       := TfFormGetStockQueue.Create(nil);
   Form2.FStockName            := '1-25';
   Form2.Caption               := '1-25排队一览表';
   Form2.dxLayout1Item3.Caption:= '1-25  排  队  一  览  表                     ';
   Form2.Button1Click(nil);
   Form2.Show;
end;

procedure TfFormStockQueue.Button3Click(Sender: TObject);
begin
  inherited;
  if not Assigned(Form3) then
   Form3                       := TfFormGetStockQueue.Create(nil);
   Form3.FStockName            := '3-6';
   Form3.Caption               := '3-6排队一览表';
   Form3.dxLayout1Item3.Caption:= '3-6  排  队  一  览  表                     ';
   Form3.Button1Click(nil);
   Form3.Show;
end;

procedure TfFormStockQueue.Button4Click(Sender: TObject);
begin
  inherited;
  if not Assigned(Form4) then
   Form4                       := TfFormGetStockQueue.Create(nil);
   Form4.FStockName            := '0-5';
   Form4.Caption               := '0-5排队一览表';
   Form4.dxLayout1Item3.Caption:= '0-5  排  队  一  览  表                     ';
   Form4.Button1Click(nil);
   Form4.Show;
end;

procedure TfFormStockQueue.Button5Click(Sender: TObject);
begin
  inherited;
  if not Assigned(Form5) then
   Form5                       := TfFormGetStockQueue.Create(nil);
   Form5.FStockName            := '机制砂';
//   Form5.FStockName            := 'P·C32.5R袋装水泥';
   Form5.Caption               := '机制砂排队一览表';
   Form5.dxLayout1Item3.Caption:= '机制砂  排  队  一  览  表                     ';
   Form5.Button1Click(nil);
   Form5.Show;
end;

procedure TfFormStockQueue.BtnExitClick(Sender: TObject);
begin
  if Assigned(Form1) then
    Form1.Free;
  if Assigned(Form2) then
    Form2.Free;
  if Assigned(Form3) then
    Form3.Free;
  if Assigned(Form4) then
    Form4.Free;
  if Assigned(Form5) then
    Form5.Free;
  inherited;
end;

initialization
  gControlManager.RegCtrl(TfFormStockQueue, TfFormStockQueue.FormID);
end.
