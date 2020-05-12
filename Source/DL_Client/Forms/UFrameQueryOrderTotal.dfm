inherited fFrameOrderDetailTotal: TfFrameOrderDetailTotal
  Width = 1089
  Height = 429
  inherited ToolBar1: TToolBar
    Width = 1089
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
    Top = 205
    Width = 1089
    Height = 224
    inherited cxView1: TcxGridDBTableView
      PopupMenu = pmPMenu1
      DataController.Summary.Options = [soNullIgnore]
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1089
    Height = 138
    object cxtxtdt1: TcxTextEdit [0]
      Left = 93
      Top = 93
      Hint = 'T.D_ProName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 165
    end
    object EditDate: TcxButtonEdit [1]
      Left = 321
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 1
      Width = 185
    end
    object EditCustomer: TcxButtonEdit [2]
      Left = 93
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 165
    end
    object cxtxtdt2: TcxTextEdit [3]
      Left = 569
      Top = 93
      Hint = 'T.L_Value'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 8
      Width = 168
    end
    object cxtxtdt4: TcxTextEdit [4]
      Left = 321
      Top = 93
      Hint = 'T.D_StockName'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 185
    end
    object Radio1: TcxRadioButton [5]
      Left = 592
      Top = 36
      Width = 110
      Height = 17
      Caption = #21516#21697#31181#21516#36710#36742
      Checked = True
      ParentColor = False
      TabOrder = 3
      TabStop = True
      OnClick = Radio1Click
    end
    object Radio2: TcxRadioButton [6]
      Left = 707
      Top = 36
      Width = 79
      Height = 17
      Caption = #21516#21697#31181
      ParentColor = False
      TabOrder = 4
      OnClick = Radio2Click
    end
    object cxLabel1: TcxLabel [7]
      Left = 511
      Top = 36
      Caption = '   '#21512#35745#26041#24335':'
      ParentFont = False
      Style.BorderStyle = ebsNone
      Style.Edges = [bBottom]
      Transparent = True
    end
    object Radio3: TcxRadioButton [8]
      Left = 791
      Top = 36
      Width = 113
      Height = 17
      Caption = #21516#21697#31181#21516#36710#20027
      ParentColor = False
      TabOrder = 5
      OnClick = Radio3Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem
          Caption = #20379#24212#21830#21517#31216':'
          Control = EditCustomer
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Control = Radio1
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = Radio2
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = 'cxRadioButton1'
          ShowCaption = False
          Control = Radio3
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #20379#24212#21830#21517#31216':'
          Control = cxtxtdt1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21697#31181#21517#31216':'
          Control = cxtxtdt4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #25968#37327'('#21544'):'
          Control = cxtxtdt2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 1089
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1089
    inherited TitleBar: TcxLabel
      Caption = #21407#26448#26009#32479#35745#26597#35810
      Style.IsFontAssigned = True
      Width = 1089
      AnchorX = 545
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
      Caption = #26102#38388#27573#26597#35810
      OnClick = mniN1Click
    end
    object N1: TMenuItem
      Caption = #25171#21360#32467#31639#21333
      OnClick = N1Click
    end
  end
end
