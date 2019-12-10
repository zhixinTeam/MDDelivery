inherited fFormPayment: TfFormPayment
  Left = 460
  Top = 110
  ClientHeight = 503
  ClientWidth = 388
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 388
    Height = 503
    inherited BtnOK: TButton
      Left = 242
      Top = 470
      TabOrder = 18
    end
    inherited BtnExit: TButton
      Left = 312
      Top = 470
      TabOrder = 19
    end
    object EditType: TcxComboBox [2]
      Left = 93
      Top = 238
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 20
      TabOrder = 8
      Width = 105
    end
    object EditMoney: TcxTextEdit [3]
      Left = 261
      Top = 238
      ParentFont = False
      TabOrder = 9
      Text = '0'
      OnExit = EditMoneyExit
      Width = 125
    end
    object EditDesc: TcxMemo [4]
      Left = 93
      Top = 413
      ParentFont = False
      Properties.MaxLength = 200
      Properties.ScrollBars = ssVertical
      TabOrder = 17
      Height = 45
      Width = 369
    end
    object cxLabel2: TcxLabel [5]
      Left = 340
      Top = 238
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 248
    end
    object ListInfo: TcxMCListBox [6]
      Left = 23
      Top = 36
      Width = 427
      Height = 110
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 85
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 338
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditID: TcxButtonEdit [7]
      Left = 93
      Top = 99
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 124
    end
    object EditSalesMan: TcxComboBox [8]
      Left = 280
      Top = 99
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.ItemHeight = 18
      Properties.OnChange = EditSalesManPropertiesChange
      TabOrder = 2
      Width = 121
    end
    object EditName: TcxComboBox [9]
      Left = 93
      Top = 124
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.OnEditValueChanged = EditNamePropertiesEditValueChanged
      TabOrder = 3
      OnKeyPress = EditNameKeyPress
      Width = 185
    end
    object EditIn: TcxTextEdit [10]
      Left = 93
      Top = 181
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 4
      Text = '0'
      Width = 90
    end
    object EditOut: TcxTextEdit [11]
      Left = 276
      Top = 181
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Text = '0'
      Width = 75
    end
    object cxLabel1: TcxLabel [12]
      Left = 188
      Top = 181
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 191
    end
    object cxLabel3: TcxLabel [13]
      Left = 340
      Top = 181
      AutoSize = False
      Caption = #20803
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 20
      Width = 25
      AnchorY = 191
    end
    object EditPrice1: TcxTextEdit [14]
      Left = 93
      Top = 263
      ParentFont = False
      TabOrder = 11
      Width = 100
    end
    object EditStockName1: TcxComboBox [15]
      Left = 93
      Top = 288
      ParentFont = False
      TabOrder = 12
      Width = 121
    end
    object EditPrice2: TcxTextEdit [16]
      Left = 93
      Top = 313
      ParentFont = False
      TabOrder = 13
      Width = 121
    end
    object EditStockName2: TcxComboBox [17]
      Left = 93
      Top = 338
      ParentFont = False
      TabOrder = 14
      Width = 121
    end
    object EditPrice3: TcxTextEdit [18]
      Left = 93
      Top = 363
      ParentFont = False
      TabOrder = 15
      Width = 121
    end
    object EditStockName3: TcxComboBox [19]
      Left = 93
      Top = 388
      ParentFont = False
      TabOrder = 16
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #23458#25143#20449#24687
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #23458#25143#32534#21495':'
            Control = EditID
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item9: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #19994#21153#20154#21592':'
            Control = EditSalesMan
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup3: TdxLayoutGroup [1]
        Caption = #36134#25143#20449#24687
        LayoutDirection = ldHorizontal
        object dxLayout1Item12: TdxLayoutItem
          Caption = #20837#37329#24635#39069':'
          Control = EditIn
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #20986#37329#24635#39069':'
          Control = EditOut
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          ShowCaption = False
          Control = cxLabel3
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [2]
        Caption = #36135#27454#22238#25910
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #20184#27454#26041#24335':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32564#32435#37329#39069':'
            Control = EditMoney
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item6: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahRight
            ShowCaption = False
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #20215#26684#20449#24687'1:'
          Control = EditPrice1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem
          Caption = #21697#31181#20449#24687'1:'
          Control = EditStockName1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = #20215#26684#20449#24687'2'
          Control = EditPrice2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item18: TdxLayoutItem
          Caption = #21697#31181#20449#24687'2'
          Control = EditStockName2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item19: TdxLayoutItem
          Caption = #20215#26684#20449#24687'3'#65306
          Control = EditPrice3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item20: TdxLayoutItem
          Caption = #21697#31181#20449#24687'3:'
          Control = EditStockName3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditDesc
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
