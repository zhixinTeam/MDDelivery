inherited fFormBillHK: TfFormBillHK
  Left = 693
  Top = 386
  ClientHeight = 465
  ClientWidth = 394
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 394
    Height = 465
    inherited BtnOK: TButton
      Left = 248
      Top = 432
      Caption = #30830#23450
      TabOrder = 13
    end
    inherited BtnExit: TButton
      Left = 318
      Top = 432
      TabOrder = 14
    end
    object EditLID: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 32
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 174
    end
    object EditZhiKa: TcxButtonEdit [3]
      Left = 81
      Top = 260
      HelpType = htKeyword
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditZhiKaPropertiesButtonClick
      TabOrder = 7
      Width = 165
    end
    object EditCusID: TcxTextEdit [4]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 403
    end
    object EditCusName: TcxTextEdit [5]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 403
    end
    object EditSID: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 121
    end
    object EditSName: TcxTextEdit [7]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Width = 121
    end
    object EditValue: TcxTextEdit [8]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 121
    end
    object EditNCusID: TcxTextEdit [9]
      Left = 81
      Top = 335
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 10
      Width = 121
    end
    object EditNCusName: TcxTextEdit [10]
      Left = 81
      Top = 360
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 11
      Width = 121
    end
    object EditZName: TcxTextEdit [11]
      Left = 81
      Top = 285
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 8
      Width = 121
    end
    object EditProject: TcxTextEdit [12]
      Left = 81
      Top = 310
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 9
      Width = 121
    end
    object EditTruck: TcxTextEdit [13]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Width = 121
    end
    object EditMoney: TcxTextEdit [14]
      Left = 81
      Top = 385
      Properties.ReadOnly = True
      TabOrder = 12
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #25552#36135#21333#20449#24687
        object dxLayout1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditSID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #27700#27877#21517#31216':'
          Control = EditSName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #25552' '#36135' '#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #24453#21512#21345#32440#21345
        object dxLayout1Item6: TdxLayoutItem
          Caption = #32440#21345#32534#21495':'
          Control = EditZhiKa
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #32440#21345#21517#31216':'
          Control = EditZName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #39033#30446#21517#31216':'
          Control = EditProject
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditNCusID
          ControlOptions.ShowBorder = False
        end
        object dxlytmNCusName: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditNCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          Caption = #21487#29992#37329#39069':'
          Control = EditMoney
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
