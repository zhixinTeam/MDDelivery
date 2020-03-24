inherited FormPoundOldValue: TFormPoundOldValue
  Left = 479
  Top = 201
  Caption = #21407#21378#20928#37325
  ClientHeight = 178
  ClientWidth = 455
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 455
    Height = 178
    inherited BtnOK: TButton
      Left = 309
      Top = 145
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 379
      Top = 145
      TabOrder = 5
    end
    object EditD_SerialNo: TcxTextEdit [2]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditTruck: TcxTextEdit [3]
      Left = 87
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditNetWeight: TcxTextEdit [4]
      Left = 87
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 121
    end
    object EditOldValue: TcxTextEdit [5]
      Left = 87
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #35760#24405#32534#21495#65306
          Control = EditD_SerialNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710' '#29260' '#21495#65306
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #20928'    '#37325#65306
          Visible = False
          Control = EditNetWeight
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21407#21378#20928#37325#65306
          Control = EditOldValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
