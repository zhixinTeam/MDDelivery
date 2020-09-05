unit UFrameCusReceivable;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxTextEdit, cxMaskEdit,
  cxButtonEdit;

type
  TfFrameCusReceivable = class(TfFrameNormal)
    EditCustomer: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    QryTmp: TADOQuery;
    procedure cxButtonEdit2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    FCusID,FCusName: string;
    //用户ID,用户名
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
    procedure CalJieCun;
  public
    class function FrameID: integer; override;
  end;

var
  fFrameCusReceivable: TfFrameCusReceivable;

implementation

uses
  UDataModule, UFormDateFilter, ULibFun, USysDB, USysConst, UMgrControl,
  UFormBase, UAdjustForm;


{$R *.dfm}

{ TfFrameCusReceivable }

class function TfFrameCusReceivable.FrameID: integer;
begin
  Result := cFI_FrameCusReceivable;
end;

procedure TfFrameCusReceivable.OnCreateFrame;
begin
  inherited;
  FCusID := '';
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCusReceivable.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFrameCusReceivable.cxButtonEdit2PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameCusReceivable.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  nP: TFormCommandParam;
begin
  nP.FParamA := GetCtrlData(EditCustomer);

  if nP.FParamA = '' then
    nP.FParamA := EditCustomer.Text;
  //xxxxx

  CreateBaseFormItem(cFI_FormGetCustom, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
  FCusID := nP.FParamB;
  FCusName := nP.FParamC;
  EditCustomer.Text := nP.FParamB+'.'+nP.FParamC;

end;

procedure TfFrameCusReceivable.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var
  nStr: string;
  nList: TStrings;
  I:integer;
begin
  nList := nil;
  try
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    nDefault := False;
    nList := TStringList.Create;

    nStr := 'if object_id(''tempdb..#qichu'') is not null ' +
            'begin Drop Table #qichu end ';
    nList.Add(nStr);
    //准备创建期初表

    nStr := 'Select A_CID as C_ID,A_InitMoney as C_Init into #qichu From %s ' +
            'where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, FCusID]);
    nList.Add(nStr);
    //期初金额

    nStr := 'Update #qichu Set C_Init=C_Init+IsNull((Select Sum(M_Money) ' +
            ' From %s Where M_CusID=''%s'' And M_Date<''$ST''), 0)';
    nStr := Format(nStr, [sTable_InOutMoney, FCusID]);
    nList.Add(nStr);
    //合并入金

    nStr := 'Update #qichu Set C_Init=C_Init-IsNull((Select Sum(L_Price*' +
            'L_Value) From %s Where L_CusID=''%s'' And L_OutFact<''$ST''), 0)';
    nStr := Format(nStr, [sTable_Bill, FCusID]);
    nList.Add(nStr);
    //合并出金

    nStr := 'if object_id(''tempdb..#recv'') is not null ' +
            'begin Drop Table #recv end ';
    nList.Add(nStr);
    //准备创建应收表

    nStr := 'Create Table dbo.#recv(R_ID varChar(32), R_Date DateTime,' +
      'R_Type Integer, R_Desc varChar(32), R_Stock varChar(80),' +
      'R_Init decimal(15,5) default 0, R_Shou decimal(15,5) default 0,' +
      'R_Value decimal(15,5) default 0, R_Price decimal(15,5) default 0,' +
      'R_Money decimal(15,2) default 0, R_YunFei decimal(15,5) default 0,' +
      'R_End decimal(15,5) default 0)';
    nList.Add(nStr);
    //记录号,日期,类型,品种,期初结存,收款,发货量,单价,应收金额,运费,结存

    nStr := 'Insert into #recv(R_Date,R_Type,R_Desc,R_Init) Select ' +
         '''2000-01-01'' as R_Date,1 as R_Type,''结存'' as R_Desc,' +
         'C_Init as R_Init From #qichu';
    nList.Add(nStr);
    //期初金额

    nStr := 'Insert into #recv(R_ID,R_Date,R_Type,R_Desc,R_Stock,R_Value,' +
      'R_Price,R_Money) Select L_ID,L_OutFact,2,''发货凭证'',L_StockName,' +
      'L_Value,L_Price,CONVERT(Decimal(15,2), L_Price*L_Value) From %s ' +
      'Where L_CusID=''%s'' And L_OutFact>=''$ST'' and L_OutFact<''$ED''';
    nStr := Format(nStr, [sTable_Bill, FCusID]);
    nList.Add(nStr);
    //出金记录

    nStr := 'Insert into #recv(R_ID,R_Date,R_Type,R_Desc,R_Shou) Select ' +
      '''IOMONEY-''+CAST(R_ID as nvarchar(10)),M_Date,3,''销售回款'',' +
      'M_Money From %s Where M_CusID=''%s'' And M_Date>=''$ST'' And ' +
      'M_Date<''$ED''';
    nStr := Format(nStr, [sTable_InOutMoney, FCusID]);
    nList.Add(nStr);
    //出入金

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    try
      FDM.ADOConn.BeginTrans;
      for i := 0 to nList.Count -1 do
        FDM.ExecuteSQL(nList[i]);
      fdm.ADOConn.CommitTrans;
    except
      FDM.ADOConn.RollbackTrans;
      ShowMessage('生成财务数据失败,请重试.');
      exit;
    end;

    nStr := 'Select row_number()over(Order By R_Date ASC) as ID,* From #recv ' +
            'Order By R_Date ASC';
    FDM.QueryData(SQLQuery, nStr, FEnableBackDB);
    //查询结果

    CalJieCun;

    nStr := 'Drop Table #recv';
    FDM.ExecuteSQL(nStr);
    nStr := 'Drop Table #qichu';
    FDM.ExecuteSQL(nStr);
    //删除临时表
  finally
    nList.Free;
  end;
end;

procedure TfFrameCusReceivable.CalJieCun;
var nType: Integer;
    nInit: Double;
  procedure ApplyData(const nVal: Double);
  begin
    with SQLQuery do
    begin
      Edit; //to change
      //FieldByName('R_YunFei').AsFloat := Float2Float(FieldByName('R_YunFei').AsFloat, cPrecision, True);
      FieldByName('R_End').AsFloat := Float2Float(nVal, cPrecision, True);
      Post; //apply
    end;
  end;
begin
  with SQLQuery do
  begin
    if (not Active) or (RecordCount < 1) then Exit;
    //no data
    First;

    if FieldByName('R_Type').AsInteger <> 1 then
    begin
      ShowMessage('数据计算错误,无法读取期初数据');
      Exit;
    end;

    Edit;
    nInit := FieldByName('R_Init').AsFloat;
    FieldByName('R_End').AsFloat := nInit;
    FieldByName('R_Date').AsDateTime := FStart;
    Post;

    Next;//xxxxx
    while not Eof do
    begin
      nType := FieldByName('R_Type').AsInteger;
      if nType = 2 then
      begin
        nInit := nInit - FieldByName('R_Money').AsFloat;
        ApplyData(nInit);                              
      end else

      if nType = 3 then
      begin
        nInit := nInit + FieldByName('R_Shou').AsFloat;
        ApplyData(nInit);
      end else

      if nType = 4 then
      begin
        nInit := nInit - FieldByName('R_Money').AsFloat;//- FieldByName('R_YunFei').AsFloat;
        ApplyData(nInit);
      end;

      Next;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCusReceivable, TfFrameCusReceivable.FrameID);
end.
