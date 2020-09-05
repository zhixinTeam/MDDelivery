inherited fFrameDaySales: TfFrameDaySales
  inherited dxLayout1: TdxLayoutControl
    object editdate: TcxDateEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 132
    end
    object Button1: TButton [1]
      Left = 402
      Top = 36
      Width = 61
      Height = 21
      Caption = #32479#35745
      TabOrder = 2
      OnClick = Button1Click
    end
    object editType: TcxComboBox [2]
      Left = 276
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        #25353#21306#22495#32479#35745
        #25353#29289#26009#32479#35745)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Text = #25353#21306#22495#32479#35745
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #32479#35745#26085#26399':'
          Control = editdate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32479#35745#26041#24335':'
          Control = editType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Control = Button1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #24403#26085#38144#37327#26126#32454#34920
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
