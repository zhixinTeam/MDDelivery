inherited fFrameBillRefresh: TfFrameBillRefresh
  Width = 1028
  Height = 744
  inherited ToolBar1: TToolBar
    Width = 1028
    inherited BtnAdd: TToolButton
      Caption = #20170#26085#35760#24405
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Caption = #26412#26376#35760#24405
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      Visible = False
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 1028
    Height = 539
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1028
    Height = 138
    object EditLID: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditLIDPropertiesButtonClick
      TabOrder = 0
      Width = 121
    end
    object EditCus: TcxButtonEdit [1]
      Left = 265
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditLIDPropertiesButtonClick
      TabOrder = 1
      Width = 121
    end
    object EditCard: TcxButtonEdit [2]
      Left = 449
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditLIDPropertiesButtonClick
      TabOrder = 2
      Width = 121
    end
    object EditDate: TcxButtonEdit [3]
      Left = 633
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 3
      Width = 257
    end
    object cxTextEdit1: TcxTextEdit [4]
      Left = 81
      Top = 93
      Hint = 'T.L_ID'
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [5]
      Left = 265
      Top = 93
      Hint = 'T.L_CusName'
      TabOrder = 5
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit [6]
      Left = 449
      Top = 93
      Hint = 'T.L_StockName'
      TabOrder = 6
      Width = 121
    end
    object cxTextEdit4: TcxTextEdit [7]
      Left = 633
      Top = 93
      Hint = 'T.L_Truck'
      TabOrder = 7
      Width = 121
    end
    object cxTextEdit5: TcxTextEdit [8]
      Left = 829
      Top = 93
      Hint = 'T.L_Value'
      TabOrder = 8
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = EditLID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25552#36135#21333#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #39592#26009#21697#31181':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #25552#36135#36710#36742':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #25552#36135#37327'('#21544'):'
          Control = cxTextEdit5
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
      Caption = #23454#26102#25552#36135#26597#35810
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
      Visible = False
      OnClick = N1Click
    end
    object N10: TMenuItem
      Caption = #25171#21360#36807#36335#36153
      Visible = False
    end
    object N11: TMenuItem
      Caption = #25171#21360#21457#36816#21333
      Visible = False
    end
    object N2: TMenuItem
      Caption = '-'
      Visible = False
    end
    object N5: TMenuItem
      Caption = #20462#25913#36710#29260#21495
      Visible = False
      OnClick = N5Click
    end
    object N7: TMenuItem
      Caption = #20462#25913#23553#31614#21495
      Visible = False
      OnClick = N7Click
    end
    object N12: TMenuItem
      Caption = #22238#21333#22788#29702
      Visible = False
    end
    object N6: TMenuItem
      Caption = '-'
      Visible = False
    end
    object N3: TMenuItem
      Caption = #35843#25320#25552#36135#21333
      Visible = False
    end
    object N8: TMenuItem
      Caption = '-'
      Visible = False
    end
    object N4: TMenuItem
      Tag = 10
      Caption = #26597#35810#26410#36827#21378
      Visible = False
      OnClick = N4Click
    end
    object N9: TMenuItem
      Tag = 20
      Caption = #26597#35810#26410#23436#25104
      Visible = False
      OnClick = N4Click
    end
    object N14: TMenuItem
      Caption = #25552#21333#20351#29992#32769#25552#21333#36164#37329
      Visible = False
    end
    object N13: TMenuItem
      Caption = #21516#27493#25152#23646#21306#22495
      Visible = False
    end
  end
  object Timer1: TTimer
    Interval = 15000
    OnTimer = Timer1Timer
    Left = 586
    Top = 27
  end
end
