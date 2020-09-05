unit UCollectMoney;
{$I Link.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxContainer, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, dxLayoutControl, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, dxLayoutcxEditAdapters, cxDropDownEdit, cxTextEdit,
  cxMaskEdit, cxButtonEdit;

type
  TfFrameCollectMoney = class(TfFrameNormal)
    editDate: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    editType: TcxComboBox;
    dxLayout1Item2: TdxLayoutItem;
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    //时间区间
    FUseDate: Boolean;
    //使用区间
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

var
  fFrameCollectMoney: TfFrameCollectMoney;

implementation

{$R *.dfm}

uses
  USysConst, UMgrControl, UFormDateFilter, USysDB, ULibFun, UDataModule;

class function TfFrameCollectMoney.FrameID: integer;
begin
  Result := cFI_FrameCollectMoney;
end;

function TfFrameCollectMoney.InitFormDataSQL(const nWhere: string): string;
var
  nStr, nTypeStr: string;
begin
  FEnableBackDB := True;
  EditDate.Text := Format('%s 至 %s', [Date2Str(FStart), Date2Str(FEnd)]);
  if editType.ItemIndex = 0 then
    nTypeStr := ''
  else if editType.ItemIndex = 1 then
    nTypeStr := 'and b.C_Type=''A'''
  else if editType.ItemIndex = 2 then
    nTypeStr := 'and b.C_Type=''B''';

  {$IFNDEF HYJC}
  nStr := 'Select M_CusID, M_CusName, SUM(Xj) Xj, SUM(Yh) Yh, SUM(Cd) Cd,'+
          ' SUM(Zz) Zz, SUM(Xj+Yh+Cd+Zz) Hj From ( '+
          ' Select M_CusID, M_CusName,'+
          ' Case When M_Payment=''现金'' then M_Money else 0.00 End Xj,'+
          ' Case When M_Payment=''银行存款'' then M_Money else 0.00 End Yh,'+
          ' Case When M_Payment=''承兑汇票'' then M_Money else 0.00 End Cd,'+
          ' Case When M_Payment=''转账'' then M_Money else 0.00 End Zz '+
          ' From Sys_CustomerInOutMoney a,S_Customer b '+
          ' Where a.M_CusID=b.C_ID '+ nTypeStr +
          ' and M_Date>=''%s'' And M_Date<''%s'' ) x '+
          ' Group by M_CusID, M_CusName '+
          ' Order by M_CusID ';
  {$ELSE}
  nStr := 'Select M_CusID, M_CusName, SUM(Xj) Xj, SUM(Yh) Yh, SUM(Cd) Cd,'+
          ' SUM(Zz) Zz,SUM(Qt) Qt,SUM(TK) Tk, SUM(Xj+Yh+Cd+Zz+Qt+TK) Hj From ( '+
          ' Select M_CusID, M_CusName,'+
          ' Case When M_Payment=''现金'' then M_Money else 0.00 End Xj,'+
          ' Case When M_Payment=''银行转账'' then M_Money else 0.00 End Yh,'+
          ' Case When M_Payment=''承兑汇票'' then M_Money else 0.00 End Cd,'+
          ' Case When M_Payment=''转款'' then M_Money else 0.00 End Zz, '+
          ' Case When M_Payment=''其它'' then M_Money else 0.00 End Qt, '+
          ' Case When M_Payment=''退款'' then M_Money else 0.00 End TK '+
          ' From Sys_CustomerInOutMoney a,S_Customer b '+
          ' Where a.M_CusID=b.C_ID '+ nTypeStr +
          ' and M_Date>=''%s'' And M_Date<''%s'' ) x '+
          ' Group by M_CusID, M_CusName '+
          ' Order by M_CusID ';
  {$ENDIF}
  Result := Format(nStr, [Date2Str(FStart), Date2Str(FEnd + 1)]);
end;

procedure TfFrameCollectMoney.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFrameCollectMoney.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameCollectMoney.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

initialization
  gControlManager.RegCtrl(TfFrameCollectMoney, TfFrameCollectMoney.FrameID);
end.
