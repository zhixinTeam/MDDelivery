inherited fFramePurchByMonth: TfFramePurchByMonth
  inherited dxLayout1: TdxLayoutControl
    object editYearStart: TcxComboBox [0]
      Left = 57
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 0
      Width = 67
    end
    object editMonthStart: TcxComboBox [1]
      Left = 187
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12')
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 1
      Width = 67
    end
    object editMonthEnd: TcxComboBox [2]
      Left = 317
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12')
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 2
      Width = 67
    end
    object Button1: TButton [3]
      Left = 389
      Top = 36
      Width = 75
      Height = 25
      Caption = #32479#35745
      TabOrder = 3
      OnClick = Button1Click
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #24180#24230':'
          Control = editYearStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36215#22987#26376#20221':'
          Control = editMonthStart
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #32467#26463#26376#20221':'
          Control = editMonthEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Control = Button1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #26376#37319#36141#32479#35745#34920
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
