{*******************************************************************************
  作者: dmzn@163.com 2009-7-15
  描述: 销售回款
*******************************************************************************}
unit UFramePayment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, Menus;

type
  TfFramePayment = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditID: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UFormBase, UFormDateFilter,
  UDataModule;

//------------------------------------------------------------------------------
class function TfFramePayment.FrameID: integer;
begin
  Result := cFI_FramePayment;
end;

procedure TfFramePayment.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePayment.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

function TfFramePayment.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  
  Result := 'Select iom.*,sm.S_Name From $IOM iom ' +
            ' Left Join $SM sm On sm.S_ID=iom.M_SaleMan ' +
            'Where M_Type=''$HK'' And M_Payment not like ''%%欠提%%'' ';
            
  if nWhere = '' then
       Result := Result + 'And (M_Date>=''$Start'' And M_Date <''$End'')'
  else Result := Result + 'And (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$SM', sTable_Salesman),
            MI('$IOM', sTable_InOutMoney), MI('$HK', sFlag_MoneyHuiKuan),
            MI('$Start', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx
end;

//------------------------------------------------------------------------------
//Desc: 回款
procedure TfFramePayment.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FParamA := '';
  CreateBaseFormItem(cFI_FormPayment, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData;
  end;
end;

//Desc: 特定客户回款
procedure TfFramePayment.cxView1DblClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then Exit;
  nP.FParamA := SQLQuery.FieldByName('M_CusID').AsString;
  CreateBaseFormItem(cFI_FormPayment, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData;
  end;
end;

//Desc: 纸卡回款
procedure TfFramePayment.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormPaymentZK, '', @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData;
  end;
end;

//Desc: 日期筛选
procedure TfFramePayment.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: 执行查询
procedure TfFramePayment.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;
    
    FWhere := '(M_CusID like ''%%%s%%'' Or M_CusName like ''%%%s%%'')';
    FWhere := Format(FWhere, [EditID.Text, EditID.Text]);
    InitFormData(FWhere);
  end else
end;

procedure TfFramePayment.N1Click(Sender: TObject);
var
  nStr, nRID, nRuZhang : string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRID     := SQLQuery.FieldByName('R_ID').AsString;
    nRuZhang := SQLQuery.FieldByName('M_RuZhang').AsString;

    nStr := '确定要对临时回款记录[ %s ]进行入账确认吗?';
    nStr := Format(nStr, [nRID]);
    if not QueryDlg(nStr, sAsk) then Exit;

    FDM.ADOConn.BeginTrans;
    try
      nStr := ' update %s set M_RuZhang= ''%s'' where R_ID = %s ';
      nStr := Format(nStr, [sTable_InOutMoney, sFlag_Yes, nRID]);
      FDM.ExecuteSQL(nStr);

      FDM.ADOConn.CommitTrans;
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('入账确认失败.', sHint);
      Exit;
    end;

    InitFormData(FWhere);
    ShowMsg('入账确认成功', sHint);
  end;
end;

procedure TfFramePayment.N3Click(Sender: TObject);
var
  nStr, nRID, nSql,nPayingUnit,nMoney : string;
  nPayingMan,nDesc,nPriceStock,nType,nAcceptNum,nDate,nMan : string;
  nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nRID        := SQLQuery.FieldByName('R_ID').AsString;
    nPayingUnit := SQLQuery.FieldByName('M_PayingUnit').AsString;
    nMoney      := SQLQuery.FieldByName('M_Money').AsString;
    nPayingMan  := SQLQuery.FieldByName('M_PayingMan').AsString;
    nDesc       := SQLQuery.FieldByName('M_Memo').AsString;
    nPriceStock := SQLQuery.FieldByName('M_PriceStock').AsString;
    nType       := SQLQuery.FieldByName('M_Payment').AsString;
    nAcceptNum  := SQLQuery.FieldByName('M_AcceptNum').AsString;
    nDate       := FormatDateTime('YYYY-MM-DD HH:MM:SS',SQLQuery.FieldByName('M_Date').AsDateTime) ;
    nMan        := SQLQuery.FieldByName('M_Man').AsString;

    //判断是否已生成收据
    nSql := ' Select Count(*) From %s Where S_InOutID = ''%s'' ';
    nSql := Format(nSql, [sTable_SysShouJu, nRID]);

    with FDM.QueryTemp(nSql) do
    if Fields[0].AsInteger > 0 then
    begin
      ShowMsg('已存在对应的收据信息', sHint); Exit;
    end;

    //补打收据
    nP.FCommand := cCmd_AddData;
    nP.FParamA  := nPayingUnit;
    if nAcceptNum <> '' then
      nP.FParamB  := nType +'('+nAcceptNum+')'
    else
      nP.FParamB  := nType;
    nP.FParamC  := nMoney;
    nP.FParamD  := nPayingMan;
    nP.FParamE  := nDesc;
    nP.FParamF  := nPriceStock;
    nP.FParamG  := nRID;
    nP.FParamH  := nDate;
    nP.FParamI  := nMan;
    CreateBaseFormItem(cFI_FormShouJu, '', @nP);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFramePayment, TfFramePayment.FrameID);
end.
