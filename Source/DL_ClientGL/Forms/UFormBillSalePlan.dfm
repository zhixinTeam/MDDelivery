inherited fFormBillSalePlan: TfFormBillSalePlan
  Left = 633
  Top = 413
  Caption = #21378#20869#38646#21806
  ClientHeight = 354
  ClientWidth = 337
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 337
    Height = 354
    inherited BtnOK: TButton
      Left = 191
      Top = 321
      Caption = #30830#23450
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 261
      Top = 321
      TabOrder = 4
    end
    object EditCard: TcxTextEdit [2]
      Left = 81
      Top = 240
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 1
      OnKeyPress = EditCardKeyPress
      Width = 121
    end
    object EditTruck: TcxTextEdit [3]
      Left = 81
      Top = 265
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      Width = 121
    end
    object ListTruck: TcxListView [4]
      Left = 23
      Top = 36
      Width = 335
      Height = 167
      Columns = <
        item
          Caption = #21697#31181#21517#31216
          Width = 110
        end
        item
          Caption = #36710#29260#21495#30721
          Width = 80
        end
        item
          Caption = #25552#36135#37327
          Width = 70
        end>
      ParentFont = False
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      object dxGroup2: TdxLayoutGroup [0]
        Caption = '*.'#35831#36873#25321#38144#21806#35745#21010
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxListView1'
          ShowCaption = False
          Control = ListTruck
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxGroup1: TdxLayoutGroup
        Caption = '*.'#38646#21806#23458#25143#35831#21047#21345
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30913#21345#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalMultiplier = 10
    Timeouts.ReadTotalConstant = 100
    OnRxChar = ComPort1RxChar
    Left = 24
    Top = 64
  end
end
