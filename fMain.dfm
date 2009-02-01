object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Aquos LC-26D44x Communicator'
  ClientHeight = 169
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 256
    Top = 48
    Width = 57
    Height = 25
    Caption = 'Volume +'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 256
    Top = 79
    Width = 57
    Height = 25
    Caption = 'Volume -'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 136
    Width = 75
    Height = 25
    Caption = 'TEXT 101'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 89
    Top = 136
    Width = 75
    Height = 25
    Caption = 'TEXT Off'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'TV Off'
    TabOrder = 4
    OnClick = Button5Click
  end
end
