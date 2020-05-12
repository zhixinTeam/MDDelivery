inherited fFramePayingUnit: TfFramePayingUnit
  inherited ToolBar1: TToolBar
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Visible = False
  end
  inherited cxSplitter1: TcxSplitter
    Visible = False
  end
  inherited TitlePanel1: TZnBitmapPanel
    inherited TitleBar: TcxLabel
      Caption = #20132#27454#21333#20301#32500#25252
      Style.IsFontAssigned = True
      AnchorX = 301
      AnchorY = 11
    end
  end
end
