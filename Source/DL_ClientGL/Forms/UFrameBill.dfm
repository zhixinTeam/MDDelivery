inherited fFrameBill: TfFrameBill
  Width = 1028
  Height = 744
  inherited ToolBar1: TToolBar
    Width = 1028
    inherited BtnAdd: TToolButton
      Caption = #24320#21333
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 1028
    Height = 539
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
      OnDblClick = cxView1DblClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1028
    Height = 138
    object EditCus: TcxButtonEdit [0]
      Left = 244
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditCard: TcxButtonEdit [1]
      Left = 432
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit1: TcxTextEdit [2]
      Left = 81
      Top = 94
      Hint = 'T.L_ID'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Width = 100
    end
    object cxTextEdit2: TcxTextEdit [3]
      Left = 244
      Top = 94
      Hint = 'T.L_CusName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 125
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 620
      Top = 94
      Hint = 'T.L_Truck'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Width = 100
    end
    object cxTextEdit3: TcxTextEdit [5]
      Left = 795
      Top = 94
      Hint = 'T.L_Value'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 9
      Width = 100
    end
    object EditDate: TcxButtonEdit [6]
      Left = 620
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 3
      Width = 257
    end
    object EditLID: TcxButtonEdit [7]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 100
    end
    object Edit1: TcxTextEdit [8]
      Left = 432
      Top = 94
      Hint = 'T.L_StockName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 125
    end
    object CheckDelete: TcxCheckBox [9]
      Left = 882
      Top = 36
      Caption = #26597#35810#24050#21024#38500
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Transparent = True
      OnClick = CheckDeleteClick
      Width = 105
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Control = CheckDelete
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #39592#26009#21697#31181':'
          Control = Edit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #25552#36135#36710#36742':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25552#36135#37327'('#21544'):'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 1028
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1028
    inherited TitleBar: TcxLabel
      Caption = #24320#25552#36135#21333#35760#24405#26597#35810
      Style.IsFontAssigned = True
      Width = 1028
      AnchorX = 514
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = PMenu1Popup
    Left = 4
    Top = 264
    object N1: TMenuItem
      Caption = #25171#21360#25552#36135#21333
      OnClick = N1Click
    end
    object N10: TMenuItem
      Caption = #25171#21360#36807#36335#36153
      Visible = False
      OnClick = N10Click
    end
    object N11: TMenuItem
      Caption = #25171#21360#21457#36816#21333
      Visible = False
      OnClick = N11Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Caption = #20462#25913#36710#29260#21495
      OnClick = N5Click
    end
    object N7: TMenuItem
      Caption = #20462#25913#23553#31614#21495
      OnClick = N7Click
    end
    object N12: TMenuItem
      Caption = #22238#21333#22788#29702
      OnClick = N12Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #35843#25320#25552#36135#21333
      OnClick = N3Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Tag = 10
      Caption = #26597#35810#26410#36827#21378
      OnClick = N4Click
    end
    object N9: TMenuItem
      Tag = 20
      Caption = #26597#35810#26410#23436#25104
      OnClick = N4Click
    end
    object N14: TMenuItem
      Caption = #25552#21333#20351#29992#32769#25552#21333#36164#37329
      OnClick = N14Click
    end
    object N13: TMenuItem
      Caption = #21516#27493#25152#23646#21306#22495
      OnClick = N13Click
    end
  end
end
