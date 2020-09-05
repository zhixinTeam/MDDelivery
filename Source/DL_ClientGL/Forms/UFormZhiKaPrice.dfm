inherited fFormZKPrice: TfFormZKPrice
  Left = 296
  Top = 302
  ClientHeight = 322
  ClientWidth = 465
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 465
    Height = 322
    inherited BtnOK: TButton
      Left = 319
      Top = 289
      Caption = #30830#23450
      TabOrder = 10
    end
    inherited BtnExit: TButton
      Left = 389
      Top = 289
      TabOrder = 11
    end
    object EditStock: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditPrice: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditNew: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 2
      Width = 121
    end
    object Check1: TcxCheckBox [5]
      Left = 23
      Top = 111
      Caption = #26032#21333#20215#29983#25928#21518#35299#20923#32440#21345'.'
      ParentFont = False
      State = cbsChecked
      TabOrder = 3
      Transparent = True
      Width = 121
    end
    object Check2: TcxCheckBox [6]
      Left = 23
      Top = 137
      Caption = #22312#21407#21333#20215#22522#30784#19978#24212#29992#26032#21333#20215'.'
      ParentFont = False
      TabOrder = 4
      Transparent = True
      Width = 121
    end
    object Check3: TcxCheckBox [7]
      Left = 23
      Top = 173
      Caption = #22312#24050#21457#36135'('#20986#21378#25110#26032#24320#21333')'#25552#36135#21333#19978#24212#29992#26032#21333#20215'.'
      ParentFont = False
      Properties.OnEditValueChanged = Check3PropertiesEditValueChanged
      TabOrder = 6
      Transparent = True
      Width = 341
    end
    object cxLabel1: TcxLabel [8]
      Left = 23
      Top = 163
      AutoSize = False
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaBottom
      Transparent = True
      Height = 5
      Width = 346
    end
    object EditStart: TcxDateEdit [9]
      Left = 81
      Top = 199
      Enabled = False
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 7
      Width = 121
    end
    object EditEnd: TcxDateEdit [10]
      Left = 81
      Top = 224
      Enabled = False
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 8
      Width = 121
    end
    object cxLabel2: TcxLabel [11]
      Left = 23
      Top = 249
      Caption = #27880': '#35843#39640#25351#23450#26102#38388#27573#30340#24050#20986#21378#21333#25454','#21487#33021#23548#33268#23458#25143#36164#37329#19981#36275'('#36229#21457').'
      ParentFont = False
      Transparent = True
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36873#39033
        object dxLayout1Item3: TdxLayoutItem
          Caption = #39592#26009#21697#31181':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #38144#21806#20215#26684':'
          Control = EditPrice
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #26032' '#21333' '#20215':'
          Control = EditNew
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          ShowCaption = False
          Control = Check3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #24320#22987#26102#38388':'
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #32467#26463#26102#38388':'
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = 'cxLabel2'
          ShowCaption = False
          Control = cxLabel2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
