object fFormHYRecord: TfFormHYRecord
  Left = 301
  Top = 6
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 679
  ClientWidth = 644
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
    Width = 644
    Height = 679
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlTabOrders = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 488
      Top = 645
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 0
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 563
      Top = 645
      Width = 70
      Height = 23
      Caption = #21462#28040
      TabOrder = 1
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'E.R_SerialNo'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      Width = 121
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
      TabOrder = 4
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
      TabOrder = 3
      object Label17: TLabel
        Left = 6
        Top = 253
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label18: TLabel
        Left = 6
        Top = 222
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Label25: TLabel
        Left = 205
        Top = 253
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label26: TLabel
        Left = 205
        Top = 222
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Bevel2: TBevel
        Left = 6
        Top = 205
        Width = 400
        Height = 7
        Shape = bsBottomLine
      end
      object Label19: TLabel
        Left = 2
        Top = 109
        Width = 54
        Height = 12
        Caption = #30897' '#21547' '#37327':'
        Transparent = True
      end
      object Label20: TLabel
        Left = 144
        Top = 31
        Width = 54
        Height = 12
        Caption = #19981' '#28342' '#29289':'
        Transparent = True
      end
      object Label21: TLabel
        Left = 2
        Top = 135
        Width = 54
        Height = 12
        Caption = #31264'    '#24230':'
        Transparent = True
      end
      object Label22: TLabel
        Left = 2
        Top = 83
        Width = 54
        Height = 12
        Caption = #32454'    '#24230':'
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
        Left = 2
        Top = 5
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38209':'
        Transparent = True
      end
      object Label27: TLabel
        Left = 144
        Top = 57
        Width = 54
        Height = 12
        Caption = #21021#20957#26102#38388':'
        Transparent = True
      end
      object Label28: TLabel
        Left = 144
        Top = 83
        Width = 54
        Height = 12
        Caption = #32456#20957#26102#38388':'
        Transparent = True
      end
      object Label29: TLabel
        Left = 144
        Top = 5
        Width = 54
        Height = 12
        Caption = #27604#34920#38754#31215':'
        Transparent = True
      end
      object Label30: TLabel
        Left = 144
        Top = 109
        Width = 54
        Height = 12
        Caption = #23433' '#23450' '#24615':'
        Transparent = True
      end
      object Label31: TLabel
        Left = 2
        Top = 31
        Width = 54
        Height = 12
        Caption = #19977#27687#21270#30827':'
      end
      object Label32: TLabel
        Left = 2
        Top = 57
        Width = 54
        Height = 12
        Caption = #28903' '#22833' '#37327':'
      end
      object Label34: TLabel
        Left = 2
        Top = 160
        Width = 54
        Height = 12
        Caption = #28216' '#31163' '#38041':'
        Transparent = True
      end
      object Label38: TLabel
        Left = 144
        Top = 187
        Width = 54
        Height = 12
        Caption = #30789' '#37240' '#30416':'
        Transparent = True
      end
      object Label39: TLabel
        Left = 144
        Top = 160
        Width = 54
        Height = 12
        Caption = #38041' '#30789' '#27604':'
        Transparent = True
      end
      object Label40: TLabel
        Left = 144
        Top = 134
        Width = 54
        Height = 12
        Caption = #20445' '#27700' '#29575':'
        Transparent = True
      end
      object Label41: TLabel
        Left = 292
        Top = 5
        Width = 54
        Height = 12
        Caption = #30707#33167#31181#31867':'
        Transparent = True
      end
      object Label42: TLabel
        Left = 292
        Top = 31
        Width = 54
        Height = 12
        Caption = #30707' '#33167' '#37327':'
      end
      object Label43: TLabel
        Left = 292
        Top = 57
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#31867':'
      end
      object Label44: TLabel
        Left = 292
        Top = 83
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#37327':'
        Transparent = True
      end
      object Label1: TLabel
        Left = 292
        Top = 107
        Width = 54
        Height = 12
        Caption = #31881' '#29028' '#28784':'
        Transparent = True
      end
      object Label2: TLabel
        Left = 292
        Top = 131
        Width = 54
        Height = 12
        Caption = #29123#29028#28809#28195':'
        Transparent = True
      end
      object Label3: TLabel
        Left = 292
        Top = 156
        Width = 54
        Height = 12
        Caption = #30719'    '#31881':'
        Transparent = True
      end
      object Label4: TLabel
        Left = 292
        Top = 183
        Width = 54
        Height = 12
        Caption = #21161' '#30952' '#21058':'
        Transparent = True
      end
      object Label48: TLabel
        Left = 428
        Top = 5
        Width = 66
        Height = 12
        Caption = #28216#31163#27687#21270#38041':'
        Transparent = True
      end
      object Label49: TLabel
        Left = 428
        Top = 29
        Width = 72
        Height = 12
        Caption = #29087#26009'C3A'#21547#37327':'
        Transparent = True
      end
      object cxTextEdit29: TcxTextEdit
        Left = 76
        Top = 217
        Hint = 'E.R_3DZhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 16
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit30: TcxTextEdit
        Left = 76
        Top = 242
        Hint = 'E.R_3DYa1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 19
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit31: TcxTextEdit
        Left = 284
        Top = 217
        Hint = 'E.R_28Zhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 25
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit32: TcxTextEdit
        Left = 284
        Top = 242
        Hint = 'E.R_28Ya1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 28
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit33: TcxTextEdit
        Left = 324
        Top = 217
        Hint = 'E.R_28Zhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 26
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit34: TcxTextEdit
        Left = 363
        Top = 217
        Hint = 'E.R_28Zhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 27
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit35: TcxTextEdit
        Left = 324
        Top = 242
        Hint = 'E.R_28Ya2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 29
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit36: TcxTextEdit
        Left = 363
        Top = 242
        Hint = 'E.R_28Ya3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 30
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit37: TcxTextEdit
        Left = 116
        Top = 217
        Hint = 'E.R_3DZhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 17
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit38: TcxTextEdit
        Left = 116
        Top = 242
        Hint = 'E.R_3DYa2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 20
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit39: TcxTextEdit
        Left = 156
        Top = 217
        Hint = 'E.R_3DZhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 18
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit40: TcxTextEdit
        Left = 156
        Top = 242
        Hint = 'E.R_3DYa3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 21
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit41: TcxTextEdit
        Left = 76
        Top = 259
        Hint = 'E.R_3DYa4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 22
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit42: TcxTextEdit
        Left = 116
        Top = 259
        Hint = 'E.R_3DYa5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 23
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit43: TcxTextEdit
        Left = 156
        Top = 259
        Hint = 'E.R_3DYa6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 24
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit47: TcxTextEdit
        Left = 284
        Top = 259
        Hint = 'E.R_28Ya4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 31
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit48: TcxTextEdit
        Left = 324
        Top = 259
        Hint = 'E.R_28Ya5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 32
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit49: TcxTextEdit
        Left = 363
        Top = 259
        Hint = 'E.R_28Ya6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 33
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit17: TcxTextEdit
        Left = 60
        Top = 0
        Hint = 'E.R_MgO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 0
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit18: TcxTextEdit
        Left = 60
        Top = 180
        Hint = 'E.R_CL'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 7
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit19: TcxTextEdit
        Left = 60
        Top = 78
        Hint = 'E.R_XiDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 3
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit20: TcxTextEdit
        Left = 60
        Top = 130
        Hint = 'E.R_ChouDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 5
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit21: TcxTextEdit
        Left = 204
        Top = 26
        Hint = 'E.R_BuRong'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 9
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit22: TcxTextEdit
        Left = 60
        Top = 104
        Hint = 'E.R_Jian'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 4
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit23: TcxTextEdit
        Left = 60
        Top = 26
        Hint = 'E.R_SO3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 1
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit24: TcxTextEdit
        Left = 60
        Top = 52
        Hint = 'E.R_ShaoShi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 2
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit25: TcxTextEdit
        Left = 204
        Top = 104
        Hint = 'E.R_AnDing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 12
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit26: TcxTextEdit
        Left = 204
        Top = 0
        Hint = 'E.R_BiBiao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 8
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit27: TcxTextEdit
        Left = 204
        Top = 78
        Hint = 'E.R_ZhongNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 11
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit28: TcxTextEdit
        Left = 204
        Top = 52
        Hint = 'E.R_ChuNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 10
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit45: TcxTextEdit
        Left = 60
        Top = 155
        Hint = 'E.R_YLiGai'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 6
        OnKeyPress = cxTextEdit17KeyPress
        Width = 74
      end
      object cxTextEdit52: TcxTextEdit
        Left = 204
        Top = 182
        Hint = 'E.R_KuangWu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 15
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit53: TcxTextEdit
        Left = 204
        Top = 155
        Hint = 'E.R_GaiGui'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 14
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit54: TcxTextEdit
        Left = 204
        Top = 129
        Hint = 'E.R_Water'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 13
        OnKeyPress = cxTextEdit17KeyPress
        Width = 75
      end
      object cxTextEdit55: TcxTextEdit
        Left = 348
        Top = 0
        Hint = 'E.R_SGType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 34
        Width = 75
      end
      object cxTextEdit56: TcxTextEdit
        Left = 348
        Top = 26
        Hint = 'E.R_SGValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 35
        Width = 75
      end
      object cxTextEdit57: TcxTextEdit
        Left = 348
        Top = 52
        Hint = 'E.R_HHCType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 36
        Width = 75
      end
      object cxTextEdit58: TcxTextEdit
        Left = 348
        Top = 78
        Hint = 'E.R_HHCValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 37
        Width = 75
      end
      object cxTextEdit1: TcxTextEdit
        Left = 349
        Top = 102
        Hint = 'E.R_FMH'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 38
        Width = 75
      end
      object cxTextEdit2: TcxTextEdit
        Left = 349
        Top = 126
        Hint = 'E.R_RMLZ'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 39
        Width = 75
      end
      object cxTextEdit3: TcxTextEdit
        Left = 349
        Top = 152
        Hint = 'E.R_KF'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 40
        Width = 75
      end
      object cxTextEdit4: TcxTextEdit
        Left = 349
        Top = 180
        Hint = 'E.R_ZMJ'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 41
        Width = 75
      end
      object cxGroupBox1: TcxGroupBox
        Left = 0
        Top = 288
        Caption = #31881#29028#28784#29305#23450#26816#39564#25968#25454
        ParentFont = False
        TabOrder = 42
        Height = 44
        Width = 550
        object Label5: TLabel
          Left = 4
          Top = 21
          Width = 54
          Height = 12
          Caption = #38656#27700#37327#27604':'
          Transparent = True
        end
        object Label6: TLabel
          Left = 138
          Top = 21
          Width = 54
          Height = 12
          Caption = #23494'    '#24230':'
          Transparent = True
        end
        object Label7: TLabel
          Left = 276
          Top = 21
          Width = 54
          Height = 12
          Caption = #36136#37327#20998#25968':'
          Transparent = True
        end
        object Label8: TLabel
          Left = 412
          Top = 20
          Width = 54
          Height = 12
          Caption = #27963#24615#25351#25968':'
          Transparent = True
        end
        object cxTextEdit5: TcxTextEdit
          Left = 62
          Top = 16
          Hint = 'E.R_FMHXSLB'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit6: TcxTextEdit
          Left = 195
          Top = 16
          Hint = 'E.R_FMHMD'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit7: TcxTextEdit
          Left = 335
          Top = 16
          Hint = 'E.R_FMHZLFS'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit8: TcxTextEdit
          Left = 471
          Top = 16
          Hint = 'E.R_FMHHXZS'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
      end
      object cxGroupBox2: TcxGroupBox
        Left = 0
        Top = 341
        Caption = #26426#21046#30722#29305#23450#26816#39564#25968#25454
        ParentFont = False
        TabOrder = 43
        Height = 150
        Width = 550
        object Label9: TLabel
          Left = 4
          Top = 22
          Width = 54
          Height = 12
          Caption = 'MB    '#20540':'
          Transparent = True
        end
        object Label10: TLabel
          Left = 138
          Top = 21
          Width = 54
          Height = 12
          Caption = #30707#31881#21547#37327':'
          Transparent = True
        end
        object Label11: TLabel
          Left = 276
          Top = 21
          Width = 54
          Height = 12
          Caption = #27877#22359#21547#37327':'
          Transparent = True
        end
        object Label12: TLabel
          Left = 412
          Top = 20
          Width = 66
          Height = 12
          Caption = #22362#22266#24615#25351#26631':'
          Transparent = True
        end
        object Label13: TLabel
          Left = 4
          Top = 45
          Width = 54
          Height = 12
          Caption = #21387#30862#25351#26631':'
          Transparent = True
        end
        object Label14: TLabel
          Left = 138
          Top = 45
          Width = 54
          Height = 12
          Caption = #34920#35266#23494#24230':'
          Transparent = True
        end
        object Label15: TLabel
          Left = 276
          Top = 45
          Width = 78
          Height = 12
          Caption = #26494#25955#22534#31215#23494#24230':'
          Transparent = True
        end
        object Label16: TLabel
          Left = 428
          Top = 44
          Width = 42
          Height = 12
          Caption = #23380#38553#29575':'
          Transparent = True
        end
        object Label33: TLabel
          Left = 4
          Top = 76
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'4.75:'
          Transparent = True
        end
        object Label35: TLabel
          Left = 148
          Top = 76
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'2.36:'
          Transparent = True
        end
        object Label36: TLabel
          Left = 292
          Top = 76
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'1.18:'
          Transparent = True
        end
        object Label37: TLabel
          Left = 4
          Top = 100
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'0.6 :'
          Transparent = True
        end
        object Label45: TLabel
          Left = 148
          Top = 100
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'0.3 :'
          Transparent = True
        end
        object Label46: TLabel
          Left = 292
          Top = 100
          Width = 66
          Height = 12
          Caption = #26041#23380#31579'0.15:'
          Transparent = True
        end
        object Label47: TLabel
          Left = 4
          Top = 124
          Width = 66
          Height = 12
          Caption = #32454#24230#27169#25968'  :'
          Transparent = True
        end
        object cxTextEdit9: TcxTextEdit
          Left = 62
          Top = 16
          Hint = 'E.R_JZSMBZ'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 0
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit10: TcxTextEdit
          Left = 195
          Top = 16
          Hint = 'E.R_JZSSFHL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 1
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit11: TcxTextEdit
          Left = 335
          Top = 16
          Hint = 'E.R_JZSNKHL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 2
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit12: TcxTextEdit
          Left = 478
          Top = 16
          Hint = 'E.R_JZSJGXZB'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 3
          OnKeyPress = cxTextEdit17KeyPress
          Width = 65
        end
        object cxTextEdit13: TcxTextEdit
          Left = 62
          Top = 40
          Hint = 'E.R_JZSYSZB'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 4
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit14: TcxTextEdit
          Left = 195
          Top = 40
          Hint = 'E.R_JZSBGMD'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 5
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit15: TcxTextEdit
          Left = 353
          Top = 40
          Hint = 'E.R_JZSSSDJMD'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 6
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit16: TcxTextEdit
          Left = 477
          Top = 40
          Hint = 'E.R_JZSKXL'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 7
          OnKeyPress = cxTextEdit17KeyPress
          Width = 65
        end
        object cxTextEdit44: TcxTextEdit
          Left = 70
          Top = 72
          Hint = 'E.R_JZSFKS475'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 8
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit46: TcxTextEdit
          Left = 214
          Top = 72
          Hint = 'E.R_JZSFKS236'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 9
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit50: TcxTextEdit
          Left = 358
          Top = 72
          Hint = 'E.R_JZSFKS118'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 10
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit51: TcxTextEdit
          Left = 70
          Top = 96
          Hint = 'E.R_JZSFKS060'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 11
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit59: TcxTextEdit
          Left = 214
          Top = 96
          Hint = 'E.R_JZSFKS030'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 12
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit60: TcxTextEdit
          Left = 358
          Top = 96
          Hint = 'E.R_JZSFKS015'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 13
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
        object cxTextEdit61: TcxTextEdit
          Left = 70
          Top = 120
          Hint = 'E.R_JZSXDMS'
          ParentFont = False
          Properties.MaxLength = 20
          TabOrder = 14
          OnKeyPress = cxTextEdit17KeyPress
          Width = 74
        end
      end
      object cxTextEdit62: TcxTextEdit
        Left = 502
        Top = 3
        Hint = 'E.R_Gao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 44
        Width = 75
      end
      object cxTextEdit63: TcxTextEdit
        Left = 502
        Top = 27
        Hint = 'E.R_C3A'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 45
        Width = 75
      end
    end
    object EditDate: TcxDateEdit
      Left = 81
      Top = 86
      Hint = 'E.R_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 5
      Width = 155
    end
    object EditMan: TcxTextEdit
      Left = 287
      Top = 86
      Hint = 'E.R_Man'
      ParentFont = False
      TabOrder = 6
      Width = 120
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
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
