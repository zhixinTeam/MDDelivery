inherited fFormStockQueue: TfFormStockQueue
  Left = 270
  Top = 173
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 228
  ClientWidth = 231
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 231
    Height = 228
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnExit: TButton
      Left = 145
      Top = 193
      Width = 75
      Height = 22
      Caption = #20851#38381
      ModalResult = 2
      TabOrder = 6
      OnClick = BtnExitClick
    end
    object BtnOK: TButton
      Left = 65
      Top = 193
      Width = 75
      Height = 22
      Caption = #30830#23450
      TabOrder = 5
      Visible = False
      OnClick = BtnOKClick
    end
    object Button1: TButton
      Left = 23
      Top = 36
      Width = 75
      Height = 25
      Caption = '1-2'#25490#38431#19968#35272#34920
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 23
      Top = 66
      Width = 75
      Height = 25
      Caption = '1-25'#25490#38431#19968#26639#34920
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 23
      Top = 96
      Width = 75
      Height = 25
      Caption = '3-6'#25490#38431#19968#35272#34920
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 23
      Top = 126
      Width = 75
      Height = 25
      Caption = '0-5'#25490#38431#19968#35272#34920
      TabOrder = 3
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 23
      Top = 156
      Width = 75
      Height = 25
      Caption = #26426#21046#30722#25490#38431#19968#35272#34920
      TabOrder = 4
      OnClick = Button5Click
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        object dxLayoutControl1Item9: TdxLayoutItem
          Caption = 'Button1'
          ShowCaption = False
          Control = Button1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = 'Button2'
          ShowCaption = False
          Control = Button2
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = 'Button3'
          ShowCaption = False
          Control = Button3
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          Caption = 'Button4'
          ShowCaption = False
          Control = Button4
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = 'Button5'
          ShowCaption = False
          Control = Button5
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaVertical]
        AlignHorz = ahRight
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item8: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button2'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          AutoAligns = []
          AlignHorz = ahRight
          AlignVert = avBottom
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
