inherited fFrameNotice: TfFrameNotice
  Width = 841
  Height = 515
  inherited ToolBar1: TToolBar
    Width = 841
  end
  inherited cxGrid1: TcxGrid
    Width = 841
    Height = 348
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 841
    object editDate: TcxButtonEdit [0]
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
      Width = 192
    end
    object editCusType: TcxComboBox [1]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Items.Strings = (
        'A'#31867#23458#25143
        'B'#31867#23458#25143)
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Text = 'A'#31867#23458#25143
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#31867#22411':'
          Control = editCusType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = editDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Width = 841
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 841
    inherited TitleBar: TcxLabel
      Caption = #36130#21153#36890#30693#21333
      Style.IsFontAssigned = True
      Width = 841
      AnchorX = 421
      AnchorY = 11
    end
  end
end
