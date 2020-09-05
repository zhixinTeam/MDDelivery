inherited fFormTruck: TfFormTruck
  Left = 368
  Top = 152
  ClientHeight = 448
  ClientWidth = 375
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 448
    inherited BtnOK: TButton
      Left = 229
      Top = 415
      TabOrder = 15
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 415
      TabOrder = 16
    end
    object EditTruck: TcxTextEdit [2]
      Left = 117
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 0
      Width = 116
    end
    object EditOwner: TcxTextEdit [3]
      Left = 117
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 1
      Width = 125
    end
    object EditPhone: TcxTextEdit [4]
      Left = 117
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object CheckValid: TcxCheckBox [5]
      Left = 23
      Top = 330
      Caption = #36710#36742#20801#35768#24320#21333'.'
      ParentFont = False
      TabOrder = 10
      Transparent = True
      Width = 80
    end
    object CheckVerify: TcxCheckBox [6]
      Left = 23
      Top = 382
      Caption = #39564#35777#36710#36742#24050#21040#20572#36710#22330'.'
      ParentFont = False
      TabOrder = 13
      Transparent = True
      Width = 165
    end
    object CheckUserP: TcxCheckBox [7]
      Left = 23
      Top = 356
      Caption = #36710#36742#20351#29992#39044#32622#30382#37325'.'
      ParentFont = False
      TabOrder = 11
      Transparent = True
      Width = 165
    end
    object CheckVip: TcxCheckBox [8]
      Left = 193
      Top = 356
      Caption = 'VIP'#36710#36742
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 100
    end
    object CheckGPS: TcxCheckBox [9]
      Left = 193
      Top = 382
      Caption = #24050#23433#35013'GPS'
      ParentFont = False
      TabOrder = 14
      Transparent = True
      Width = 100
    end
    object EditXTNum: TcxTextEdit [10]
      Left = 117
      Top = 111
      ParentFont = False
      TabOrder = 3
      Text = '0'
      Width = 121
    end
    object EditPrePValue: TcxTextEdit [11]
      Left = 117
      Top = 136
      ParentFont = False
      TabOrder = 4
      Text = '0'
      Width = 121
    end
    object EditMaxBillNum: TcxTextEdit [12]
      Left = 117
      Top = 161
      ParentFont = False
      TabOrder = 5
      Text = '0'
      Width = 121
    end
    object EditYYZH: TcxTextEdit [13]
      Left = 117
      Top = 186
      TabOrder = 6
      Width = 121
    end
    object EditCSQY: TcxTextEdit [14]
      Left = 117
      Top = 211
      TabOrder = 7
      Width = 121
    end
    object EditXCZZCRQ: TcxTextEdit [15]
      Left = 117
      Top = 236
      TabOrder = 8
      Width = 121
    end
    object EditMemo: TcxTextEdit [16]
      Left = 117
      Top = 261
      TabOrder = 9
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36710#20027#22995#21517':'
            Control = EditOwner
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32852#31995#26041#24335':'
            Control = EditPhone
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #26368#22823#24320#21333#37327':'
          Control = EditXTNum
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #39044#32622#30382#37325':'
          Control = EditPrePValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #27611#37325#19978#38480':'
          Control = EditMaxBillNum
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          Caption = #33829#36816#35777#21495':'
          Control = EditYYZH
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = #36710#23646#20225#19994':'
          Control = EditCSQY
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = #34892#36710#35777#27880#20876#26085#26399':'
          Control = EditXCZZCRQ
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem
          Caption = #22791'     '#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #36710#36742#21442#25968
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            ShowCaption = False
            Control = CheckUserP
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckVip
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = 'cxCheckBox2'
            ShowCaption = False
            Control = CheckVerify
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckGPS
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
