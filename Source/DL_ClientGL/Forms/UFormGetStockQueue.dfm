inherited fFormGetStockQueue: TfFormGetStockQueue
  Left = 503
  Width = 520
  Height = 309
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeable
  Constraints.MinHeight = 220
  Constraints.MinWidth = 400
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 512
    Height = 278
    inherited BtnOK: TButton
      Left = 366
      Top = 245
      Caption = #30830#23450
      TabOrder = 2
    end
    inherited BtnExit: TButton
      Left = 436
      Top = 245
      TabOrder = 3
    end
    object ListProvider: TcxListView [2]
      Left = 23
      Top = 66
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #24207#21495
          Width = 55
        end
        item
          Caption = #36710#29260#21495
          Width = 75
        end
        item
          Caption = #21457#21345#26102#38388
          Width = 135
        end
        item
          Caption = #23458#25143#21517#31216
          Width = 100
        end
        item
          Caption = #24403#21069#29366#24577
          Width = 70
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = ListProviderDblClick
      OnKeyPress = ListProviderKeyPress
    end
    object Button1: TButton [3]
      Left = 389
      Top = 36
      Width = 100
      Height = 25
      Caption = #21047#26032
      TabOrder = 0
      OnClick = Button1Click
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = ' '#25490'  '#38431'  '#19968'  '#35272'  '#34920'                      '
          Control = Button1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26597#35810#32467#26524':'
          ShowCaption = False
          Control = ListProvider
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object Timer1: TTimer
    Interval = 15000
    OnTimer = Timer1Timer
    Left = 319
    Top = 34
  end
end
