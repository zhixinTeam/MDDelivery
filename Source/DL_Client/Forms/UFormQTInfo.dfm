inherited fFormQTInfo: TfFormQTInfo
  Left = 529
  Top = 203
  ClientHeight = 249
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 249
    inherited BtnOK: TButton
      Left = 229
      Top = 216
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 216
      TabOrder = 3
    end
    object EditMemo: TcxMemo [2]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 0
      Height = 141
      Width = 259
    end
    object EditRuZhang: TcxComboBox [3]
      Left = 81
      Top = 182
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        '1:'#26410#36824#27454' '
        '2:'#37096#20998#36824#27454
        '3:'#24050#36824#27454)
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36824#27454#29366#24577':'
          Control = EditRuZhang
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
