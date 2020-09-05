inherited fFrameCusTotalMoney: TfFrameCusTotalMoney
  inherited dxLayout1: TdxLayoutControl
    object editDate: TcxButtonEdit [0]
      Left = 81
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
      TabOrder = 0
      Width = 184
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          CaptionOptions.Text = #26085#26399#31579#36873':'
          Control = editDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #36134#21153#26597#35810
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
