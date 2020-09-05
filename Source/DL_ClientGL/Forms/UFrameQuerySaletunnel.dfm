inherited fFrameSaletunnelQuery: TfFrameSaletunnelQuery
  Width = 1115
  Height = 480
  inherited ToolBar1: TToolBar
    Width = 1115
    ButtonWidth = 79
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Left = 79
      Visible = False
    end
    inherited BtnDel: TToolButton
      Left = 158
      Visible = False
    end
    inherited S1: TToolButton
      Left = 237
      Visible = False
    end
    inherited BtnRefresh: TToolButton
      Left = 245
      Caption = '    '#21047#26032'    '
    end
    inherited S2: TToolButton
      Left = 324
    end
    inherited BtnPrint: TToolButton
      Left = 332
    end
    inherited BtnPreview: TToolButton
      Left = 411
    end
    inherited BtnExport: TToolButton
      Left = 490
    end
    inherited S3: TToolButton
      Left = 569
    end
    inherited BtnExit: TToolButton
      Left = 577
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 140
    Width = 1115
    Height = 340
    inherited cxView1: TcxGridDBTableView
      PopupMenu = pmPMenu1
      DataController.Summary.Options = [soNullIgnore]
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1115
    Height = 73
    object btnOK1: TBitBtn [0]
      Left = 343
      Top = 36
      Width = 96
      Height = 25
      Caption = #19994#21153#21592#38144#21806#26597#35810
      TabOrder = 1
      OnClick = btnOK1Click
    end
    object EditDate: TcxButtonEdit [1]
      Left = 81
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
      TabOrder = 0
      Width = 257
    end
    object btnOK2: TBitBtn [2]
      Left = 444
      Top = 36
      Width = 89
      Height = 25
      Caption = #24037#21378#38144#21806#26597#35810
      TabOrder = 2
      OnClick = btnOK2Click
    end
    object btnOK3: TBitBtn [3]
      Left = 538
      Top = 36
      Width = 83
      Height = 25
      Caption = #23458#25143#38144#21806#26597#35810
      TabOrder = 3
      OnClick = btnOK3Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = 'BitBtn1'
          ShowCaption = False
          Control = btnOK1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'BitBtn1'
          ShowCaption = False
          Control = btnOK2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'BitBtn1'
          ShowCaption = False
          Control = btnOK3
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        Visible = False
        UseIndent = False
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 132
    Width = 1115
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1115
    inherited TitleBar: TcxLabel
      Caption = #21457#36135#26126#32454#32479#35745#26597#35810
      Style.IsFontAssigned = True
      Width = 1115
      AnchorX = 558
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 10
    Top = 252
  end
  inherited DataSource1: TDataSource
    Left = 38
    Top = 252
  end
  object pmPMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 10
    Top = 280
    object mniN1: TMenuItem
      Tag = 10
      Caption = #25353#20986#21378#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Tag = 20
      Caption = #25353#21457#36135#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N3: TMenuItem
      Caption = #25353#36807#37325#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
    object N4: TMenuItem
      Caption = #25353#36807#31354#26102#38388#26597#35810
      Visible = False
      OnClick = mniN1Click
    end
  end
end
