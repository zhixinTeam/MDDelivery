inherited fFormKDInfo: TfFormKDInfo
  Left = 586
  Top = 381
  ClientHeight = 132
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 132
    inherited BtnOK: TButton
      Left = 229
      Top = 99
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 99
      TabOrder = 2
    end
    object EditKDInfo: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 0
      Width = 125
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21368#36135#22320#28857':'
          Control = EditKDInfo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
