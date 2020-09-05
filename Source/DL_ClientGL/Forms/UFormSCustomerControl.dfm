inherited fFormSCustomerControl: TfFormSCustomerControl
  Left = 482
  Top = 252
  ClientHeight = 262
  ClientWidth = 423
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 423
    Height = 262
    inherited BtnOK: TButton
      Left = 277
      Top = 229
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 347
      Top = 229
      TabOrder = 7
    end
    object CheckValid: TcxCheckBox [2]
      Left = 23
      Top = 196
      Caption = #25511#21046#26377#25928
      ParentFont = False
      TabOrder = 5
      Transparent = True
      Width = 80
    end
    object ChkUseControl: TcxCheckBox [3]
      Left = 23
      Top = 36
      Caption = #21551#29992#26085#38144#21806#37327#24635#25511#21046
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditCus: TcxComboBox [4]
      Left = 81
      Top = 96
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.IncrementalSearch = False
      Properties.OnChange = EditCusPropertiesChange
      TabOrder = 1
      Width = 121
    end
    object EditMemo: TcxTextEdit [5]
      Left = 81
      Top = 171
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditStock: TcxComboBox [6]
      Left = 81
      Top = 121
      ParentFont = False
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 2
      Width = 121
    end
    object EditValue: TcxTextEdit [7]
      Left = 81
      Top = 146
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26085#38144#21806#37327#24635#25511#21046
        Visible = False
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkUseControl
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #25511#21046#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          Caption = #19994#21153#21592#21517':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #26085#38144#21806#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #25511#21046#22791#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
