inherited FormPoundKZ: TFormPoundKZ
  Left = 479
  Top = 201
  Caption = #30917#25151#25187#37325
  ClientHeight = 414
  ClientWidth = 455
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 455
    Height = 414
    inherited BtnOK: TButton
      Left = 309
      Top = 381
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 379
      Top = 381
      TabOrder = 7
    end
    object EditD_SerialNo: TcxTextEdit [2]
      Left = 87
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditTruck: TcxTextEdit [3]
      Left = 87
      Top = 61
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditKZ: TcxTextEdit [4]
      Left = 87
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 121
    end
    object EditStockName: TcxTextEdit [5]
      Left = 87
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 121
    end
    object EditPoundKZ: TcxTextEdit [6]
      Left = 87
      Top = 136
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditJYJL: TcxMemo [7]
      Left = 87
      Top = 161
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 5
      Height = 194
      Width = 313
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #35760#24405#32534#21495#65306
          Control = EditD_SerialNo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710' '#29260' '#21495#65306
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #21442#32771#25187#37325#65306
          Visible = False
          Control = EditKZ
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216#65306
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #19968#27425#25187#37325#65306
          Control = EditPoundKZ
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #26816#39564#35760#24405#65306
          Control = EditJYJL
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
