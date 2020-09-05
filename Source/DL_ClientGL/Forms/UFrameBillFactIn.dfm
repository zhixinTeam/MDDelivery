inherited fFrameBillFactIn: TfFrameBillFactIn
  Width = 1028
  Height = 493
  inherited ToolBar1: TToolBar
    Width = 1028
    inherited BtnAdd: TToolButton
      Caption = #21046#21345
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
    Height = 288
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1028
    Height = 138
    object EditCard: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object cxTextEdit2: TcxTextEdit [1]
      Left = 269
      Top = 93
      Hint = 'T.L_CusName'
      ParentFont = False
      TabOrder = 3
      Width = 176
    end
    object cxTextEdit4: TcxTextEdit [2]
      Left = 81
      Top = 93
      Hint = 'T.L_Truck'
      ParentFont = False
      TabOrder = 2
      Width = 125
    end
    object EditDate: TcxButtonEdit [3]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 1
      Width = 176
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
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
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
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
      Caption = #21378#20869#38646#21806#19994#21153#21150#21345#26597#35810
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
end
