{*******************************************************************************
  作者: dmzn@163.com 2009-07-20
  描述: 品种管理
*******************************************************************************}
unit UFormYCLHYStock;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, cxGraphics, StdCtrls, cxMaskEdit, cxDropDownEdit,
  cxMCListBox, cxMemo, dxLayoutControl, cxContainer, cxEdit, cxTextEdit,
  cxControls, cxButtonEdit, cxCalendar, ExtCtrls, cxPC, cxLookAndFeels,
  cxLookAndFeelPainters;

type
  TfFormYCLHYStock = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group5: TdxLayoutGroup;
    EditID: TcxButtonEdit;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditStockEx: TcxComboBox;
    dxLayoutControl1Item12: TdxLayoutItem;
    EditMemo: TcxMemo;
    dxLayoutControl1Item8: TdxLayoutItem;
    wPage: TcxPageControl;
    dxLayoutControl1Item25: TdxLayoutItem;
    Sheet1: TcxTabSheet;
    Sheet2: TcxTabSheet;
    cxTextEdit2: TcxTextEdit;
    cxTextEdit3: TcxTextEdit;
    cxTextEdit14: TcxTextEdit;
    cxTextEdit16: TcxTextEdit;
    cxTextEdit15: TcxTextEdit;
    cxTextEdit1: TcxTextEdit;
    cxTextEdit6: TcxTextEdit;
    cxTextEdit5: TcxTextEdit;
    cxTextEdit13: TcxTextEdit;
    cxTextEdit7: TcxTextEdit;
    cxTextEdit4: TcxTextEdit;
    cxTextEdit8: TcxTextEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label33: TLabel;
    cxTextEdit44: TcxTextEdit;
    Label35: TLabel;
    cxTextEdit46: TcxTextEdit;
    Label36: TLabel;
    cxTextEdit50: TcxTextEdit;
    Label37: TLabel;
    cxTextEdit51: TcxTextEdit;
    Label24: TLabel;
    cxTextEdit17: TcxTextEdit;
    Label29: TLabel;
    cxTextEdit26: TcxTextEdit;
    Label41: TLabel;
    cxTextEdit55: TcxTextEdit;
    Label31: TLabel;
    cxTextEdit23: TcxTextEdit;
    Label20: TLabel;
    cxTextEdit21: TcxTextEdit;
    Label42: TLabel;
    cxTextEdit56: TcxTextEdit;
    Label32: TLabel;
    cxTextEdit24: TcxTextEdit;
    Label27: TLabel;
    cxTextEdit28: TcxTextEdit;
    Label43: TLabel;
    cxTextEdit57: TcxTextEdit;
    Label22: TLabel;
    cxTextEdit19: TcxTextEdit;
    Label28: TLabel;
    cxTextEdit27: TcxTextEdit;
    Label44: TLabel;
    cxTextEdit58: TcxTextEdit;
    Label19: TLabel;
    cxTextEdit22: TcxTextEdit;
    Label30: TLabel;
    cxTextEdit25: TcxTextEdit;
    Label1: TLabel;
    cxTextEdit9: TcxTextEdit;
    Label21: TLabel;
    cxTextEdit20: TcxTextEdit;
    Label40: TLabel;
    cxTextEdit54: TcxTextEdit;
    Label2: TLabel;
    cxTextEdit10: TcxTextEdit;
    Label34: TLabel;
    cxTextEdit45: TcxTextEdit;
    Label39: TLabel;
    cxTextEdit53: TcxTextEdit;
    Label9: TLabel;
    cxTextEdit11: TcxTextEdit;
    Label23: TLabel;
    cxTextEdit18: TcxTextEdit;
    Label38: TLabel;
    cxTextEdit52: TcxTextEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cxTextEdit2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FRecordID: string;
    //合同编号
    FPrefixID: string;
    //前缀编号
    FIDLength: integer;
    //前缀长度
    procedure InitFormData(const nID: string);
    //载入数据
  public
    { Public declarations }
  end;

function ShowStockAddForm: Boolean;
function ShowStockEditForm(const nID: string): Boolean;
procedure ShowStockViewForm(const nID: string);
procedure CloseStockForm;
//入口函数

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormCtrl, UAdjustForm, USysDB, USysConst;

var
  gForm: TfFormYCLHYStock = nil;
  //全局使用

//------------------------------------------------------------------------------
//Desc: 添加
function ShowStockAddForm: Boolean;
begin
  with TfFormYCLHYStock.Create(Application) do
  begin
    FRecordID := '';
    Caption := '原材料品种 - 添加';

    InitFormData('');
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 修改
function ShowStockEditForm(const nID: string): Boolean;
begin
  with TfFormYCLHYStock.Create(Application) do
  begin
    FRecordID := nID;
    Caption := '原材料品种 - 修改';

    InitFormData(nID);
    Result := ShowModal = mrOK;
    Free;
  end;
end;

//Desc: 查看
procedure ShowStockViewForm(const nID: string);
begin
  if not Assigned(gForm) then
  begin
    gForm := TfFormYCLHYStock.Create(Application);
    gForm.Caption := '原材料品种 - 查看';
    gForm.FormStyle := fsStayOnTop;
    gForm.BtnOK.Visible := False;
  end;

  with gForm  do
  begin
    InitFormData(nID);
    if not Showing then Show;
  end;
end;

procedure CloseStockForm;
begin
  FreeAndNil(gForm);
end;

//------------------------------------------------------------------------------
procedure TfFormYCLHYStock.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  wPage.ActivePageIndex := 0;
  ResetHintAllForm(Self, 'T', sTable_YCLParam);
  ResetHintAllForm(Self, 'E', sTable_YCLParamExt);
  //重置表名称
  
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    FPrefixID := nIni.ReadString(Name, 'IDPrefix', 'PZ');
    FIDLength := nIni.ReadInteger(Name, 'IDLength', 8);
  finally
    nIni.Free;
  end;
end;

procedure TfFormYCLHYStock.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormYCLHYStock.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormYCLHYStock.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end else

  if Key = VK_DOWN then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end else

  if Key = VK_UP then
  begin
    Key := 0;
    Perform(WM_NEXTDLGCTL, 1, 0);
  end;
end;

procedure TfFormYCLHYStock.cxTextEdit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2009-6-2
//Parm: 品种编号
//Desc: 载入nID供应商的信息到界面
procedure TfFormYCLHYStock.InitFormData(const nID: string);
var nStr: string;
begin
  if EditStockEx.Properties.Items.Count < 1 then
  begin
    nStr := ' Select M_Name From  %s ';
    nStr := Format(nStr, [sTable_Materails]);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditStockEx.Properties.Items.Add(FieldByName('M_Name').AsString);
        Next;
      end;
    end;
  end;
  
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_YCLParam, nID]);
    LoadDataToForm(FDM.QuerySQL(nStr), Self, sTable_YCLParam);

    nStr := 'Select * From %s Where R_PID=''%s''';
    nStr := Format(nStr, [sTable_YCLParamExt, nID]);
    LoadDataToForm(FDM.QueryTemp(nStr), Self, sTable_YCLParamExt);
  end;
end;

//Desc: 生成随机编号
procedure TfFormYCLHYStock.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  EditID.Text := FDM.GetRandomID(FPrefixID, FIDLength);
end;

//Desc: 保存数据
procedure TfFormYCLHYStock.BtnOKClick(Sender: TObject);
var nList: TStrings;
    nStr,nSQL: string;
begin
  EditID.Text := Trim(EditID.Text);
  if EditID.Text = '' then
  begin
    EditID.SetFocus;
    ShowMsg('请填写有效的品种编号', sHint); Exit;
  end;

  if FRecordID = '' then
  begin
    nStr := 'Select Count(*) From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_YCLParam, EditID.Text]);
    //查询编号是否存在

    with FDM.QueryTemp(nStr) do
     if Fields[0].AsInteger > 0 then
     begin
       EditID.SetFocus;
       ShowMsg('该编号的品种已经存在', sHint); Exit;
     end;

     nSQL := MakeSQLByForm(Self, sTable_YCLParam, '', True);
  end else
  begin
    EditID.Text := FRecordID;
    nStr := 'P_ID=''' + FRecordID + '''';
    nSQL := MakeSQLByForm(Self, sTable_YCLParam, nStr, False);
  end;

  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nSQL);

    if FRecordID = '' then
    begin
      nList := TStringList.Create;
      nList.Text := 'R_PID=''' + EditID.Text + '''';
      
      nSQL := MakeSQLByForm(Self, sTable_YCLParamExt, '', True, nil, nList);
      nList.Free;
    end else
    begin
      nStr := 'R_PID=''' + FRecordID + '''';
      nSQL := MakeSQLByForm(Self, sTable_YCLParamExt, nStr, False);
    end;

    FDM.ExecuteSQL(nSQL);
    FDM.ADOConn.CommitTrans;
    
    ModalResult := mrOK;
    ShowMsg('数据已保存', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('数据保存失败', '未知原因');
  end;
end;

end.
