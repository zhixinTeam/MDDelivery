object fFormYCLHYStock: TfFormYCLHYStock
  Left = 351
  Top = 99
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 490
  ClientWidth = 566
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 566
    Height = 490
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 410
      Top = 457
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 4
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 485
      Top = 457
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 5
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'T.P_ID'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      Width = 121
    end
    object EditStockEx: TcxComboBox
      Left = 81
      Top = 61
      Hint = 'T.P_Stock'
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 10
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 100
      TabOrder = 1
      Width = 291
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 86
      Hint = 'T.P_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      TabOrder = 2
      Height = 35
      Width = 331
    end
    object wPage: TcxPageControl
      Left = 11
      Top = 133
      Width = 428
      Height = 288
      ActivePage = Sheet2
      ParentColor = False
      ShowFrame = True
      Style = 9
      TabOrder = 3
      TabSlants.Kind = skCutCorner
      ClientRectBottom = 287
      ClientRectLeft = 1
      ClientRectRight = 427
      ClientRectTop = 19
      object Sheet1: TcxTabSheet
        Caption = #25351#26631#21442#25968
        ImageIndex = 0
        object Label3: TLabel
          Left = 12
          Top = 117
          Width = 54
          Height = 12
          Caption = #25381' '#21457' '#20221':'
          Transparent = True
        end
        object Label4: TLabel
          Left = 189
          Top = 39
          Width = 54
          Height = 12
          Caption = #30897' '#21547' '#37327':'
          Transparent = True
        end
        object Label5: TLabel
          Left = 12
          Top = 143
          Width = 54
          Height = 12
          Caption = #32467' '#26230' '#27700':'
          Transparent = True
        end
        object Label6: TLabel
          Left = 12
          Top = 91
          Width = 78
          Height = 12
          Caption = #36827#21378#21407#29028#27700#20998':'
          Transparent = True
        end
        object Label7: TLabel
          Left = 13
          Top = 195
          Width = 54
          Height = 12
          Caption = #28903' '#30690' '#37327':'
          Transparent = True
        end
        object Label8: TLabel
          Left = 12
          Top = 13
          Width = 66
          Height = 12
          Caption = #19977#27687#21270#20108#38081':'
          Transparent = True
        end
        object Label11: TLabel
          Left = 189
          Top = 65
          Width = 54
          Height = 12
          Caption = #20108#27687#21270#30789':'
          Transparent = True
        end
        object Label12: TLabel
          Left = 189
          Top = 90
          Width = 54
          Height = 12
          Caption = #28784'    '#20221':'
          Transparent = True
        end
        object Label13: TLabel
          Left = 189
          Top = 13
          Width = 66
          Height = 12
          Caption = #19977#27687#21270#20108#38109':'
          Transparent = True
        end
        object Label14: TLabel
          Left = 189
          Top = 195
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38209':'
          Transparent = True
        end
        object Label15: TLabel
          Left = 12
          Top = 39
          Width = 60
          Height = 12
          Caption = #27700'     '#20998':'
        end
        object Label16: TLabel
          Left = 12
          Top = 65
          Width = 54
          Height = 12
          Caption = #19977#27687#21270#30827':'
        end
        object Label33: TLabel
          Left = 12
          Top = 168
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38041':'
          Transparent = True
        end
        object Label35: TLabel
          Left = 189
          Top = 168
          Width = 54
          Height = 12
          Caption = #27604#34920#38754#31215':'
          Transparent = True
        end
        object Label36: TLabel
          Left = 189
          Top = 142
          Width = 54
          Height = 12
          Caption = #27695' '#31163' '#23376':'
          Transparent = True
        end
        object Label37: TLabel
          Left = 189
          Top = 116
          Width = 54
          Height = 12
          Caption = #23433' '#23450' '#24615':'
          Transparent = True
        end
        object cxTextEdit2: TcxTextEdit
          Left = 91
          Top = 8
          Hint = 'T.P_Fe2O3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit3: TcxTextEdit
          Left = 92
          Top = 190
          Hint = 'T.P_ShaoShi'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 7
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit14: TcxTextEdit
          Left = 91
          Top = 86
          Hint = 'T.P_YMWater'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit16: TcxTextEdit
          Left = 91
          Top = 138
          Hint = 'T.P_JJH2O'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 5
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit15: TcxTextEdit
          Left = 260
          Top = 34
          Hint = 'T.P_Jian'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 9
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit1: TcxTextEdit
          Left = 91
          Top = 112
          Hint = 'T.P_HuiFa'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 4
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit6: TcxTextEdit
          Left = 91
          Top = 34
          Hint = 'T.P_Water'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit5: TcxTextEdit
          Left = 91
          Top = 60
          Hint = 'T.P_SO3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit13: TcxTextEdit
          Left = 260
          Top = 190
          Hint = 'T.P_MgO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 15
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit7: TcxTextEdit
          Left = 260
          Top = 8
          Hint = 'T.P_Al2O3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 8
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit4: TcxTextEdit
          Left = 260
          Top = 60
          Hint = 'T.P_SiO2'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 10
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit8: TcxTextEdit
          Left = 260
          Top = 85
          Hint = 'T.P_Hui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 11
          Text = #8804
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit44: TcxTextEdit
          Left = 91
          Top = 163
          Hint = 'T.P_CaO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 6
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit46: TcxTextEdit
          Left = 260
          Top = 163
          Hint = 'T.P_BiBiao'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 14
          Text = #8805
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit50: TcxTextEdit
          Left = 260
          Top = 137
          Hint = 'T.P_CL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 13
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
        object cxTextEdit51: TcxTextEdit
          Left = 260
          Top = 111
          Hint = 'T.P_AnDing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 12
          Text = #21512#26684
          OnKeyPress = cxTextEdit2KeyPress
          Width = 75
        end
      end
      object Sheet2: TcxTabSheet
        Caption = #26816#39564#21442#25968
        ImageIndex = 1
        object Label24: TLabel
          Left = 16
          Top = 20
          Width = 66
          Height = 12
          Caption = #19977#27687#21270#20108#38081':'
          Transparent = True
        end
        object Label29: TLabel
          Left = 216
          Top = 21
          Width = 54
          Height = 12
          Caption = #27700'    '#20998':'
          Transparent = True
        end
        object Label41: TLabel
          Left = 380
          Top = 20
          Width = 54
          Height = 12
          Caption = #30897' '#21547' '#37327':'
          Transparent = True
        end
        object Label31: TLabel
          Left = 18
          Top = 47
          Width = 66
          Height = 12
          Caption = #19977#27687#21270#20108#38109':'
        end
        object Label20: TLabel
          Left = 216
          Top = 47
          Width = 54
          Height = 12
          Caption = #20108#27687#21270#30789':'
          Transparent = True
        end
        object Label42: TLabel
          Left = 380
          Top = 47
          Width = 48
          Height = 12
          Caption = #28784'   '#20221':'
        end
        object Label32: TLabel
          Left = 18
          Top = 73
          Width = 102
          Height = 12
          Caption = '26.5mm'#26631#20934#31579#31890#24230':'
        end
        object Label27: TLabel
          Left = 216
          Top = 73
          Width = 36
          Height = 12
          Caption = 'St.ad:'
          Transparent = True
        end
        object Label43: TLabel
          Left = 380
          Top = 73
          Width = 54
          Height = 12
          Caption = #25381' '#21457' '#20221':'
        end
        object Label22: TLabel
          Left = 18
          Top = 99
          Width = 78
          Height = 12
          Caption = #36827#21378#21407#29028#27700#20998':'
          Transparent = True
        end
        object Label28: TLabel
          Left = 217
          Top = 99
          Width = 48
          Height = 12
          Caption = 'Qnet.ar:'
          Transparent = True
        end
        object Label44: TLabel
          Left = 380
          Top = 99
          Width = 54
          Height = 12
          Caption = #32467' '#26230' '#27700':'
          Transparent = True
        end
        object Label19: TLabel
          Left = 18
          Top = 125
          Width = 54
          Height = 12
          Caption = #19977#27687#21270#30827':'
          Transparent = True
        end
        object Label30: TLabel
          Left = 215
          Top = 125
          Width = 30
          Height = 12
          Caption = 'Loss:'
          Transparent = True
        end
        object Label1: TLabel
          Left = 380
          Top = 123
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38041':'
          Transparent = True
        end
        object Label21: TLabel
          Left = 18
          Top = 151
          Width = 78
          Height = 12
          Caption = #24378#24230#27963#24615#25351#25968':'
          Transparent = True
        end
        object Label40: TLabel
          Left = 216
          Top = 150
          Width = 36
          Height = 12
          Caption = 'f-Cao:'
          Transparent = True
        end
        object Label2: TLabel
          Left = 380
          Top = 147
          Width = 54
          Height = 12
          Caption = #27687' '#21270' '#38209':'
          Transparent = True
        end
        object Label34: TLabel
          Left = 18
          Top = 176
          Width = 54
          Height = 12
          Caption = #27604#34920#38754#31215':'
          Transparent = True
        end
        object Label39: TLabel
          Left = 216
          Top = 176
          Width = 54
          Height = 12
          Caption = #23433' '#23450' '#24615':'
          Transparent = True
        end
        object Label9: TLabel
          Left = 380
          Top = 172
          Width = 54
          Height = 12
          Caption = #31890'    '#24230':'
          Transparent = True
        end
        object Label23: TLabel
          Left = 18
          Top = 203
          Width = 54
          Height = 12
          Caption = #27695' '#31163' '#23376':'
          Transparent = True
        end
        object Label38: TLabel
          Left = 216
          Top = 203
          Width = 54
          Height = 12
          Caption = #25918' '#23556' '#24615':'
          Transparent = True
        end
        object cxTextEdit17: TcxTextEdit
          Left = 116
          Top = 16
          Hint = 'E.R_Fe2O3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          Width = 74
        end
        object cxTextEdit26: TcxTextEdit
          Left = 276
          Top = 16
          Hint = 'E.R_Water'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          Width = 75
        end
        object cxTextEdit55: TcxTextEdit
          Left = 436
          Top = 16
          Hint = 'E.R_Jian'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          Width = 75
        end
        object cxTextEdit23: TcxTextEdit
          Left = 116
          Top = 41
          Hint = 'E.R_Al2O3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          Width = 74
        end
        object cxTextEdit21: TcxTextEdit
          Left = 277
          Top = 42
          Hint = 'E.R_SiO2'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 4
          Width = 75
        end
        object cxTextEdit56: TcxTextEdit
          Left = 436
          Top = 42
          Hint = 'E.R_Hui'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 5
          Width = 75
        end
        object cxTextEdit24: TcxTextEdit
          Left = 116
          Top = 68
          Hint = 'E.R_ShaiLi'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 6
          Width = 74
        end
        object cxTextEdit28: TcxTextEdit
          Left = 276
          Top = 68
          Hint = 'E.R_St_ad'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 7
          Width = 75
        end
        object cxTextEdit57: TcxTextEdit
          Left = 436
          Top = 68
          Hint = 'E.R_HuiFa'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 8
          Width = 75
        end
        object cxTextEdit19: TcxTextEdit
          Left = 116
          Top = 94
          Hint = 'E.R_YMWater'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 9
          Width = 74
        end
        object cxTextEdit27: TcxTextEdit
          Left = 276
          Top = 94
          Hint = 'E.R_Qnet_ar'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 10
          Width = 75
        end
        object cxTextEdit58: TcxTextEdit
          Left = 436
          Top = 94
          Hint = 'E.R_JJH2O'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 11
          Width = 75
        end
        object cxTextEdit22: TcxTextEdit
          Left = 116
          Top = 121
          Hint = 'E.R_SO3'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 12
          Width = 74
        end
        object cxTextEdit25: TcxTextEdit
          Left = 276
          Top = 120
          Hint = 'E.R_Loss'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 13
          Width = 75
        end
        object cxTextEdit9: TcxTextEdit
          Left = 437
          Top = 118
          Hint = 'E.R_CaO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 14
          Width = 75
        end
        object cxTextEdit20: TcxTextEdit
          Left = 116
          Top = 146
          Hint = 'E.R_FMHHXZS'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 15
          Width = 74
        end
        object cxTextEdit54: TcxTextEdit
          Left = 277
          Top = 145
          Hint = 'E.R_f_Cao'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 16
          Width = 75
        end
        object cxTextEdit10: TcxTextEdit
          Left = 437
          Top = 142
          Hint = 'E.R_MgO'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 17
          Width = 75
        end
        object cxTextEdit45: TcxTextEdit
          Left = 116
          Top = 171
          Hint = 'E.R_BiBiao'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 18
          Width = 74
        end
        object cxTextEdit53: TcxTextEdit
          Left = 276
          Top = 171
          Hint = 'E.R_AnDing'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 19
          Width = 75
        end
        object cxTextEdit11: TcxTextEdit
          Left = 437
          Top = 168
          Hint = 'E.R_LiDu'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 20
          Width = 75
        end
        object cxTextEdit18: TcxTextEdit
          Left = 116
          Top = 196
          Hint = 'E.R_CL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 21
          Width = 74
        end
        object cxTextEdit52: TcxTextEdit
          Left = 276
          Top = 198
          Hint = 'E.R_FSX'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 22
          Width = 240
        end
      end
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #21697#31181#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          AutoAligns = [aaVertical]
          Caption = #21697#31181#21517#31216':'
          Control = EditStockEx
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item8: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Item25: TdxLayoutItem
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = 'cxPageControl1'
        ShowCaption = False
        Control = wPage
        ControlOptions.AutoColor = True
        ControlOptions.ShowBorder = False
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button3'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button4'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
