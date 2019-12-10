inherited FrameDaySalesHj: TFrameDaySalesHj
  inherited dxLayout1: TdxLayoutControl
    object editType: TcxComboBox [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Items.Strings = (
        #20840#37096#23458#25143
        'A'#31867
        'B'#31867)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Text = #20840#37096#23458#25143
      Width = 121
    end
    object editDate: TcxButtonEdit [1]
      Left = 265
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = editDatePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      Width = 180
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#31867#22411':'
          Control = editType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = editDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #24403#26085#38144#37327#21512#35745
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
