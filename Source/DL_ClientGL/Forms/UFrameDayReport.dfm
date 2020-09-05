inherited fFrameDayReport: TfFrameDayReport
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
    object editDate: TcxDateEdit [1]
      Left = 265
      Top = 36
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Width = 121
    end
    object Button1: TButton [2]
      Left = 391
      Top = 36
      Width = 75
      Height = 25
      Caption = #32479#35745
      TabOrder = 2
      OnClick = Button1Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#31867#22411':'
          Control = editType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #32479#35745#26085#26399':'
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
      Caption = #26085#25253#34920
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
