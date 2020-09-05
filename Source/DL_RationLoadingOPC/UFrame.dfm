object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 303
  Height = 324
  TabOrder = 0
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 288
    Height = 317
    Caption = #24211#20301
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = #21326#25991#23435#20307
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      288
      317)
    object ToolBar1: TToolBar
      Left = 8
      Top = 509
      Width = 44
      Height = 0
      Align = alNone
      AutoSize = True
      ButtonHeight = 7
      ButtonWidth = 8
      Caption = 'ToolBar1'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 0
      object ToolButton2: TToolButton
        Left = 0
        Top = 2
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnPause: TToolButton
        Left = 8
        Top = 2
        Width = 4
        Caption = #26242'  '#20572
        Enabled = False
        ImageIndex = 4
        Style = tbsSeparator
        Visible = False
      end
      object ToolButton9: TToolButton
        Left = 12
        Top = 2
        Width = 8
        Caption = 'ToolButton9'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton6: TToolButton
        Left = 20
        Top = 2
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton10: TToolButton
        Left = 28
        Top = 2
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 36
        Top = 2
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 4
        Style = tbsSeparator
      end
    end
    object cxLabel6: TcxLabel
      Left = 9
      Top = 24
      Caption = #26368' '#22823' '#37327':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object EditMaxValue: TcxTextEdit
      Left = 111
      Top = 22
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 2
      Text = '0'
      Width = 167
    end
    object cxLabel1: TcxLabel
      Left = 9
      Top = 59
      Caption = #30382'    '#37325':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object editPValue: TcxTextEdit
      Left = 111
      Top = 61
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.ReadOnly = True
      Style.Color = clAqua
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clFuchsia
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 4
      Text = '0'
      Width = 167
    end
    object cxLabel2: TcxLabel
      Left = 9
      Top = 102
      Caption = #24320' '#21333' '#37327':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object editZValue: TcxTextEdit
      Left = 111
      Top = 100
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 6
      Text = '0'
      Width = 167
    end
    object cxLabel4: TcxLabel
      Left = 9
      Top = 137
      Caption = #20132#36135#21333#21495':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object EditBill: TcxComboBox
      Left = 111
      Top = 140
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.ItemHeight = 22
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 8
      Width = 167
    end
    object cxLabel5: TcxLabel
      Left = 9
      Top = 180
      Caption = #36710#29260#21495#30721':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object EditTruck: TcxComboBox
      Left = 111
      Top = 179
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.ItemHeight = 22
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 10
      Width = 167
    end
    object cxLabel7: TcxLabel
      Left = 9
      Top = 215
      Caption = #27611'    '#37325':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object EditMValue: TcxComboBox
      Left = 111
      Top = 217
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 22
      Properties.ReadOnly = True
      Style.Color = 16777088
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clFuchsia
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 12
      Width = 167
    end
    object cxLabel8: TcxLabel
      Left = 9
      Top = 258
      Caption = #20928'    '#37325':'
      ParentFont = False
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clBlack
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.TextColor = clBlack
      Style.IsFontAssigned = True
    end
    object EditValue: TcxComboBox
      Left = 111
      Top = 257
      Anchors = [akTop, akRight]
      ParentFont = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 22
      Properties.ReadOnly = True
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -19
      Style.Font.Name = #24188#22278
      Style.Font.Style = []
      Style.LookAndFeel.NativeStyle = True
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 14
      Width = 167
    end
  end
  object StateTimer: TTimer
    Interval = 3000
    OnTimer = StateTimerTimer
    Left = 32
    Top = 396
  end
  object DelayTimer: TTimer
    Enabled = False
    OnTimer = DelayTimerTimer
    Left = 66
    Top = 396
  end
end
