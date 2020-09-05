{*******************************************************************************
  作者: fendou116688@163.com 2015/9/8
  描述: 选择供应商
*******************************************************************************}
unit UFormGetStockQueue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, ComCtrls, cxCheckBox, Menus,
  cxLabel, cxListView, cxTextEdit, cxMaskEdit, cxButtonEdit,
  dxLayoutControl, StdCtrls, ExtCtrls;

type
  TfFormGetStockQueue = class(TfFormNormal)
    ListProvider: TcxListView;
    dxLayout1Item6: TdxLayoutItem;
    Button1: TButton;
    dxLayout1Item3: TdxLayoutItem;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure ListProviderKeyPress(Sender: TObject; var Key: Char);
    procedure EditCIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ListProviderDblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    function QueryProvider(const nProvider: string): Boolean;
    //查询供应商
  public
    { Public declarations }
    FStockName:string;
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}

uses
  IniFiles, ULibFun, UMgrControl, UFormBase, USysGrid, USysDB, USysConst,
  USysBusiness, UDataModule, UFormInputbox;

class function TfFormGetStockQueue.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
begin
  Result := nil;

  with TfFormGetStockQueue.Create(Application) do
  begin
    Caption := '排队一览表';

    QueryProvider(FStockName);
    Show;
  end;
end;

class function TfFormGetStockQueue.FormID: integer;
begin
  Result := cFI_FormGetStockQueue;
end;

procedure TfFormGetStockQueue.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    LoadcxListViewConfig(Name, ListProvider, nIni);
  finally
    nIni.Free;
  end;
end;

procedure TfFormGetStockQueue.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    SavecxListViewConfig(Name, ListProvider, nIni);
  finally
    nIni.Free;
  end;
end;

//------------------------------------------------------------------------------
//Desc: 查询车牌号
function TfFormGetStockQueue.QueryProvider(const nProvider: string): Boolean;
var nStr: string;
begin
  Result := True;
  if Trim(nProvider) = '' then Exit;
  ListProvider.Items.Clear;

  nStr := ' Select ROW_NUMBER() over(order by T_InFact) RID, * From S_ZTTrucks a, S_Bill b '+
          ' Where a.T_Bill = b.L_ID and T_Stock = ''%s'' Order by T_InFact ';
  nStr := Format(nStr, [FStockName]);
  //xxxxxx

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      with ListProvider.Items.Add do
      begin
        Caption := FieldByName('RID').AsString;
        SubItems.Add(FieldByName('T_Truck').AsString);
        SubItems.Add(FieldByName('L_Date').AsString);
        SubItems.Add(FieldByName('L_CusName').AsString);
        if Trim(FieldByName('L_Status').AsString) = 'N' then
          SubItems.Add('未知')
        else if Trim(FieldByName('L_Status').AsString) = 'I' then
          SubItems.Add('进厂')
        else if Trim(FieldByName('L_Status').AsString) = 'P' then
          SubItems.Add('称皮重')
        else if Trim(FieldByName('L_Status').AsString) = 'M' then
          SubItems.Add('称毛重')
        else if Trim(FieldByName('L_Status').AsString) = 'O' then
          SubItems.Add('出厂');

        ImageIndex := 11;
        StateIndex := ImageIndex;
      end;
      Next;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfFormGetStockQueue.EditCIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  QueryProvider(FStockName);
end;

procedure TfFormGetStockQueue.ListProviderKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;

    if ListProvider.ItemIndex > -1 then
      ModalResult := mrOk;
    //xxxxx
  end;
end;

procedure TfFormGetStockQueue.ListProviderDblClick(Sender: TObject);
begin
  if ListProvider.ItemIndex > -1 then
    ModalResult := mrOk;
  //xxxxx
end;

procedure TfFormGetStockQueue.BtnOKClick(Sender: TObject);
begin
  if ListProvider.ItemIndex > -1 then
       ModalResult := mrOk
  else ShowMsg('请在查询结果中选择', sHint);
end;

procedure TfFormGetStockQueue.Button1Click(Sender: TObject);
begin
  inherited;
  QueryProvider(FStockName);
end;

procedure TfFormGetStockQueue.Timer1Timer(Sender: TObject);
begin
  inherited;
  QueryProvider(FStockName);
end;

initialization
  gControlManager.RegCtrl(TfFormGetStockQueue, TfFormGetStockQueue.FormID);
end.
