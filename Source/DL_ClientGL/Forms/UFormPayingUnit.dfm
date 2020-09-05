inherited fFormPayingUnit: TfFormPayingUnit
  Left = 586
  Top = 381
  ClientHeight = 161
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 161
    inherited BtnOK: TButton
      Left = 229
      Top = 128
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 128
      TabOrder = 4
    end
    object EditPayingUnit: TcxTextEdit [2]
      Left = 87
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditSalesMan: TcxComboBox [3]
      Left = 87
      Top = 36
      Properties.OnChange = EditSalesManPropertiesChange
      TabOrder = 0
      Width = 121
    end
    object EditName: TcxComboBox [4]
      Left = 87
      Top = 61
      Properties.OnEditValueChanged = EditNamePropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #19994#21153#20154#21592':'
          Control = EditSalesMan
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #20132#27454#21333#20301#65306
          Control = EditPayingUnit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
