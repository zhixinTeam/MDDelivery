unit UFrameCusTotalMoney;

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
  TfFrameCusTotalMoney = class(TfFrameNormal)
    editDate: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    procedure editDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    procedure OnInitFormData(var nDefault: Boolean; const nWhere: string = '';
     const nQuery: TADOQuery = nil); override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameCusTotalMoney: TfFrameCusTotalMoney;

implementation

uses UDataModule, UFormDateFilter, ULibFun, USysDB, USysConst, UMgrControl;

{$R *.dfm}

{ TfFrameCusTotalMoney }

procedure TfFrameCusTotalMoney.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCusTotalMoney.OnDestroyFrame;
begin
  inherited;
  SaveDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCusTotalMoney.OnInitFormData(var nDefault: Boolean;
  const nWhere: string; const nQuery: TADOQuery);
var nStr: string;
    nList: TStrings;
    i: integer;
begin
  nList := nil;
  //with TStringHelper, TDateTimeHelper do
  try
    EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
    nDefault := False;
    nList := TStringList.Create;

    nStr := 'if object_id(''tempdb..#qichu'') is not null ' +
            'begin Drop Table #qichu end ';
    nList.Add(nStr);
    //准备创建期初表

    nStr := 'Select A_CID as C_ID, CONVERT(Varchar(200), '''') As C_CusName,CONVERT(Decimal(15,2), A_InitMoney) as C_Init, CONVERT(Decimal(15,2), 0) C_InMoney,  ' +
            '	CONVERT(Decimal(15,2), 0) C_SaleMoney, CONVERT(Decimal(15,2), 0) C_FLMoney, CONVERT(Decimal(15,2), 0) C_AvailableMoney ' +
            ' into #qichu From %s';
    nStr := Format(nStr, [sTable_CusAccount]);
    nList.Add(nStr);
    //期初金额

    nStr := 'UPDate #qichu Set C_Init=C_Init+CusInMoney From ( ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s ' +
            'Where M_Date<''$ST''  ' +
            'Group  by M_CusID ) a  Where M_CusID=C_ID ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //合并入金

    nStr := 'UPDate #qichu Set C_Init=C_Init- L_Money From ( ' +
            'Select L_CusID, IsNull(Sum(L_Price*L_Value), 0) L_Money From %s ' +
            'Where L_OutFact<''$ST''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //合并出金 发货金额

    nStr := 'UPDate #qichu Set C_InMoney=CusInMoney From (   ' +
            'Select M_CusID, IsNull(Sum(M_Money), 0) CusInMoney From %s  ' +
            'Where M_Date>=''$ST'' And M_Date<''$ED''  ' +
            'Group  by M_CusID ) a  Where M_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_InOutMoney]);
    nList.Add(nStr);
    //期初金额

    nStr := 'UPDate #qichu Set C_SaleMoney=L_Money From ( ' +
            'Select L_CusID, Sum(CONVERT(Decimal(15,2), L_Price*L_Value)) L_Money From %s ' +
            'Where L_OutFact>=''$ST'' And L_OutFact<''$ED''  ' +
            'Group  by L_CusID ) a  Where L_CusID=C_ID  ';
    nStr := Format(nStr, [sTable_Bill]);
    nList.Add(nStr);
    //出金记录

    nStr := 'UPDate #qichu Set C_CusName=C_Name From S_Customer a Where a.C_ID=#qichu.C_ID';
    nList.Add(nStr);
    //******
    nStr := 'UPDate #qichu Set C_AvailableMoney=C_Init+C_InMoney-C_SaleMoney-C_FLMoney';
    nList.Add(nStr);
    //计算结余

    nList.Text := MacroValue(nList.Text, [MI('$ST', Date2Str(FStart)),
                  MI('$ED', Date2Str(FEnd + 1))]);
    //xxxxx

    try
      FDM.ADOConn.BeginTrans;
      for i := 0 to nList.Count -1 do
        FDM.ExecuteSQL(nList[i]);
      fdm.ADOConn.CommitTrans;
    except
      ShowMessage('生成财务数据失败,请重试.');
      exit;
    end;
    //DBExecute(nList, nQuery);
    //生成报表

    nStr := 'Select * From #qichu order by c_id ';
    FDM.QueryData(SQLQuery, nStr, FEnableBackDB);
    //查询结果

    nStr := 'Drop Table #qichu';
    FDM.ExecuteSQL(nStr);
    //删除临时表
  finally
    nList.Free;
  end;
end;

class function TfFrameCusTotalMoney.FrameID: integer;
begin
  Result := cFI_FrameCusTotalMoney;
end;

procedure TfFrameCusTotalMoney.editDatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFrameCusTotalMoney, TfFrameCusTotalMoney.FrameID)
end.
