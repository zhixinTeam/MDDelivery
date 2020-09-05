inherited fAccReport: TfAccReport
  inherited dxLayout1: TdxLayoutControl
    object editDate: TcxButtonEdit [0]
      Left = 248
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
      Width = 193
    end
    object editType: TcxComboBox [1]
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
      Width = 104
    end
    object Button1: TButton [2]
      Left = 446
      Top = 36
      Width = 75
      Height = 25
      Caption = #32479#35745
      TabOrder = 2
      OnClick = Button1Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#31867#22411':'
          Control = editType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = editDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Control = Button1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #20250#35745#25253#34920
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
