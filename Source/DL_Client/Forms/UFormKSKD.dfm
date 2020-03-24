inherited fFormKSKD: TfFormKSKD
  Left = 586
  Top = 381
  ClientHeight = 157
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 157
    inherited BtnOK: TButton
      Left = 229
      Top = 124
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 124
      TabOrder = 4
    end
    object EditNum1: TcxTextEdit [2]
      Left = 93
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 0
      Width = 125
    end
    object EditNum2: TcxTextEdit [3]
      Left = 93
      Top = 61
      TabOrder = 1
      Width = 121
    end
    object EditNum3: TcxTextEdit [4]
      Left = 93
      Top = 86
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #20928#37325#36229#36807':'
          Control = EditNum1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #40664#35748#20928#37325':'
          Control = EditNum2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #20854#20313#25187#21544#25968':'
          Control = EditNum3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
