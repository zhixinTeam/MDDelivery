object fFormYCLHYRecord: TfFormYCLHYRecord
  Left = 272
  Top = 182
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 411
  ClientWidth = 597
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
    Width = 597
    Height = 411
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlTabOrders = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 441
      Top = 377
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 0
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 516
      Top = 377
      Width = 70
      Height = 23
      Caption = #21462#28040
      TabOrder = 1
      OnClick = BtnExitClick
    end
    object EditStock: TcxComboBox
      Left = 81
      Top = 61
      Hint = 'E.R_PID'
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 15
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 3
      Width = 128
    end
    object wPanel: TPanel
      Left = 23
      Top = 143
      Width = 415
      Height = 262
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 2
      object Label19: TLabel
        Left = 2
        Top = 109
        Width = 54
        Height = 12
        Caption = #19977#27687#21270#30827':'
        Transparent = True
      end
      object Label20: TLabel
        Left = 200
        Top = 31
        Width = 54
        Height = 12
        Caption = #20108#27687#21270#30789':'
        Transparent = True
      end
      object Label21: TLabel
        Left = 2
        Top = 135
        Width = 78
        Height = 12
        Caption = #24378#24230#27963#24615#25351#25968':'
        Transparent = True
      end
      object Label22: TLabel
        Left = 2
        Top = 83
        Width = 78
        Height = 12
        Caption = #36827#21378#21407#29028#27700#20998':'
        Transparent = True
      end
      object Label23: TLabel
        Left = 2
        Top = 187
        Width = 54
        Height = 12
        Caption = #27695' '#31163' '#23376':'
        Transparent = True
      end
      object Label24: TLabel
        Left = 0
        Top = 4
        Width = 66
        Height = 12
        Caption = #19977#27687#21270#20108#38081':'
        Transparent = True
      end
      object Label27: TLabel
        Left = 200
        Top = 57
        Width = 36
        Height = 12
        Caption = 'St.ad:'
        Transparent = True
      end
      object Label28: TLabel
        Left = 201
        Top = 83
        Width = 48
        Height = 12
        Caption = 'Qnet.ar:'
        Transparent = True
      end
      object Label29: TLabel
        Left = 200
        Top = 5
        Width = 54
        Height = 12
        Caption = #27700'    '#20998':'
        Transparent = True
      end
      object Label30: TLabel
        Left = 199
        Top = 109
        Width = 30
        Height = 12
        Caption = 'Loss:'
        Transparent = True
      end
      object Label31: TLabel
        Left = 2
        Top = 31
        Width = 66
        Height = 12
        Caption = #19977#27687#21270#20108#38109':'
      end
      object Label32: TLabel
        Left = 2
        Top = 57
        Width = 102
        Height = 12
        Caption = '26.5mm'#26631#20934#31579#31890#24230':'
      end
      object Label34: TLabel
        Left = 2
        Top = 160
        Width = 54
        Height = 12
        Caption = #27604#34920#38754#31215':'
        Transparent = True
      end
      object Label38: TLabel
        Left = 200
        Top = 187
        Width = 54
        Height = 12
        Caption = #25918' '#23556' '#24615':'
        Transparent = True
      end
      object Label39: TLabel
        Left = 200
        Top = 160
        Width = 54
        Height = 12
        Caption = #23433' '#23450' '#24615':'
        Transparent = True
      end
      object Label40: TLabel
        Left = 200
        Top = 134
        Width = 36
        Height = 12
        Caption = 'f-Cao:'
        Transparent = True
      end
      object Label41: TLabel
        Left = 364
        Top = 4
        Width = 54
        Height = 12
        Caption = #30897' '#21547' '#37327':'
        Transparent = True
      end
      object Label42: TLabel
        Left = 364
        Top = 31
        Width = 48
        Height = 12
        Caption = #28784'   '#20221':'
      end
      object Label43: TLabel
        Left = 364
        Top = 57
        Width = 54
        Height = 12
        Caption = #25381' '#21457' '#20221':'
      end
      object Label44: TLabel
        Left = 364
        Top = 83
        Width = 54
        Height = 12
        Caption = #32467' '#26230' '#27700':'
        Transparent = True
      end
      object Label1: TLabel
        Left = 364
        Top = 107
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38041':'
        Transparent = True
      end
      object Label2: TLabel
        Left = 364
        Top = 131
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38209':'
        Transparent = True
      end
      object Label3: TLabel
        Left = 364
        Top = 156
        Width = 54
        Height = 12
        Caption = #31890'    '#24230':'
        Transparent = True
      end
      object cxTextEdit17: TcxTextEdit
        Left = 100
        Top = 0
        Hint = 'E.R_Fe2O3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 0
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit18: TcxTextEdit
        Left = 100
        Top = 180
        Hint = 'E.R_CL'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 7
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit19: TcxTextEdit
        Left = 100
        Top = 78
        Hint = 'E.R_YMWater'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 3
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit20: TcxTextEdit
        Left = 100
        Top = 130
        Hint = 'E.R_FMHHXZS'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 5
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit21: TcxTextEdit
        Left = 261
        Top = 26
        Hint = 'E.R_SiO2'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 9
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit22: TcxTextEdit
        Left = 100
        Top = 105
        Hint = 'E.R_SO3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 4
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit23: TcxTextEdit
        Left = 100
        Top = 25
        Hint = 'E.R_Al2O3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 1
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit24: TcxTextEdit
        Left = 100
        Top = 52
        Hint = 'E.R_ShaiLi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 2
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit25: TcxTextEdit
        Left = 260
        Top = 104
        Hint = 'E.R_Loss'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 12
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit26: TcxTextEdit
        Left = 260
        Top = 0
        Hint = 'E.R_Water'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 8
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit27: TcxTextEdit
        Left = 260
        Top = 78
        Hint = 'E.R_Qnet_ar'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 11
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit28: TcxTextEdit
        Left = 260
        Top = 52
        Hint = 'E.R_St_ad'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 10
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit45: TcxTextEdit
        Left = 100
        Top = 155
        Hint = 'E.R_BiBiao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 6
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit52: TcxTextEdit
        Left = 260
        Top = 182
        Hint = 'E.R_FSX'
        ParentFont = False
        Properties.MaxLength = 100
        TabOrder = 15
        OnKeyPress = cxTextEdit17KeyPress
        Width = 280
      end
      object cxTextEdit53: TcxTextEdit
        Left = 260
        Top = 155
        Hint = 'E.R_AnDing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 14
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit54: TcxTextEdit
        Left = 261
        Top = 129
        Hint = 'E.R_f_Cao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 13
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit55: TcxTextEdit
        Left = 420
        Top = 0
        Hint = 'E.R_Jian'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 16
        Width = 75
      end
      object cxTextEdit56: TcxTextEdit
        Left = 420
        Top = 26
        Hint = 'E.R_Hui'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 17
        Width = 75
      end
      object cxTextEdit57: TcxTextEdit
        Left = 420
        Top = 52
        Hint = 'E.R_HuiFa'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 18
        Width = 75
      end
      object cxTextEdit58: TcxTextEdit
        Left = 420
        Top = 78
        Hint = 'E.R_JJH2O'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 19
        Width = 75
      end
      object cxTextEdit1: TcxTextEdit
        Left = 421
        Top = 102
        Hint = 'E.R_CaO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 20
        Width = 75
      end
      object cxTextEdit2: TcxTextEdit
        Left = 421
        Top = 126
        Hint = 'E.R_MgO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 21
        Width = 75
      end
      object cxTextEdit3: TcxTextEdit
        Left = 421
        Top = 152
        Hint = 'E.R_LiDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 22
        Width = 75
      end
    end
    object EditDate: TcxDateEdit
      Left = 81
      Top = 86
      Hint = 'E.R_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 4
      Width = 155
    end
    object EditMan: TcxTextEdit
      Left = 287
      Top = 86
      Hint = 'E.R_Man'
      ParentFont = False
      TabOrder = 5
      Width = 120
    end
    object EditID: TcxTextEdit
      Left = 81
      Top = 36
      Hint = 'E.R_SerialNo'
      TabOrder = 9
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #35760#24405#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25152#23646#21697#31181':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #21462#26679#26085#26399':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #24405#20837#20154':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26816#39564#25968#25454
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'Panel1'
          ShowCaption = False
          Control = wPanel
          ControlOptions.AutoColor = True
          ControlOptions.ShowBorder = False
        end
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
