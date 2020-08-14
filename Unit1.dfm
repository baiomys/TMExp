object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TMExplorer'
  ClientHeight = 675
  ClientWidth = 874
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnShow = FormShow
  DesignSize = (
    874
    675)
  PixelsPerInch = 96
  TextHeight = 13
  object TabControl1: TTabControl
    Left = -2
    Top = 8
    Width = 876
    Height = 647
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 0
    TabPosition = tpBottom
    Tabs.Strings = (
      'Projects'
      'References')
    TabIndex = 0
    OnChange = TabControl1Change
    object Panel3: TPanel
      Left = 4
      Top = 4
      Width = 868
      Height = 621
      Align = alClient
      TabOrder = 2
      Visible = False
      object SQL_cmbo: TComboBox
        Left = 8
        Top = 8
        Width = 854
        Height = 21
        BevelInner = bvNone
        BevelKind = bkFlat
        Style = csDropDownList
        Color = clBtnFace
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
        OnChange = SQL_cmboChange
      end
      object Cmd_mmo: TMemo
        Left = 8
        Top = 36
        Width = 737
        Height = 113
        BevelEdges = []
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 1
      end
      object Button1: TButton
        Left = 751
        Top = 36
        Width = 111
        Height = 113
        Caption = 'Execute'
        TabOrder = 2
        OnClick = Button1Click
      end
      object Res_mmo: TMemo
        Left = 8
        Top = 160
        Width = 854
        Height = 94
        BevelEdges = []
        Color = clBtnFace
        Ctl3D = False
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 3
      end
      object Button2: TButton
        Left = 8
        Top = 585
        Width = 854
        Height = 25
        Caption = 'Clear'
        TabOrder = 4
        OnClick = Button2Click
      end
      object log_mmo: TMemo
        Left = 8
        Top = 260
        Width = 854
        Height = 319
        BevelEdges = []
        Color = clBtnFace
        Ctl3D = False
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 5
      end
    end
    object Panel2: TPanel
      Left = 4
      Top = 4
      Width = 868
      Height = 621
      Align = alClient
      TabOrder = 1
      Visible = False
      DesignSize = (
        868
        621)
      object p1_cust: TComboBox
        AlignWithMargins = True
        Left = 3
        Top = 6
        Width = 228
        Height = 21
        BevelEdges = []
        BevelInner = bvLowered
        BevelOuter = bvSpace
        Style = csDropDownList
        Color = clBtnFace
        Ctl3D = False
        DropDownCount = 20
        ParentCtl3D = False
        TabOrder = 0
        OnChange = p1_CustChange
      end
      object p1_src: TListBox
        AlignWithMargins = True
        Left = 3
        Top = 36
        Width = 347
        Height = 581
        TabStop = False
        Anchors = [akLeft, akTop, akBottom]
        Color = clBtnFace
        Ctl3D = False
        ItemHeight = 13
        MultiSelect = True
        ParentCtl3D = False
        Sorted = True
        TabOrder = 1
        TabWidth = 30
      end
      object p1_dst: TListBox
        AlignWithMargins = True
        Left = 517
        Top = 36
        Width = 347
        Height = 580
        TabStop = False
        Anchors = [akTop, akRight, akBottom]
        Color = clBtnFace
        Ctl3D = False
        ItemHeight = 13
        MultiSelect = True
        ParentCtl3D = False
        Sorted = True
        TabOrder = 2
        TabWidth = 30
      end
      object p1_gen: TButton
        Left = 517
        Top = 5
        Width = 345
        Height = 25
        Caption = 'Buld reference material'
        Enabled = False
        TabOrder = 3
        OnClick = p1_gena
      end
      object p1_RL: TButton
        Left = 400
        Top = 305
        Width = 69
        Height = 33
        Anchors = [akLeft, akTop, akRight]
        Caption = '<'
        TabOrder = 4
        OnClick = p1_RLClick
      end
      object p1_RRL: TButton
        Left = 400
        Top = 352
        Width = 69
        Height = 33
        Anchors = [akLeft, akTop, akRight]
        Caption = '<<'
        TabOrder = 5
        OnClick = p1_RRLClick
      end
      object p1_LLR: TButton
        Left = 399
        Top = 159
        Width = 69
        Height = 33
        Anchors = [akLeft, akTop, akRight]
        Caption = '>>'
        TabOrder = 6
        OnClick = p1_LLRClick
      end
      object p1_LR: TButton
        Left = 400
        Top = 208
        Width = 69
        Height = 33
        Anchors = [akLeft, akTop, akRight]
        Caption = '>'
        TabOrder = 7
        OnClick = p1_LRClick
      end
      object p1_refr: TButton
        Left = 237
        Top = 5
        Width = 113
        Height = 25
        Caption = 'Reset'
        TabOrder = 8
        OnClick = p1_refrClick
      end
    end
    object Panel1: TPanel
      Left = 4
      Top = 4
      Width = 868
      Height = 621
      Align = alClient
      TabOrder = 0
      DesignSize = (
        868
        621)
      object p0_gbox_pair: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 0
        Width = 503
        Height = 616
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' Pair '
        TabOrder = 1
        Visible = False
        DesignSize = (
          503
          616)
        object TabControl2: TTabControl
          Left = 8
          Top = 19
          Width = 488
          Height = 588
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          Tabs.Strings = (
            'ENG'
            'RUS')
          TabIndex = 0
          OnChange = TabControl2Change
          object p0_mmo: TMemo
            AlignWithMargins = True
            Left = 7
            Top = 27
            Width = 474
            Height = 554
            Align = alClient
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            Color = clBtnFace
            Ctl3D = False
            Lines.Strings = (
              'Memo1')
            ParentCtl3D = False
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 0
            WordWrap = False
          end
        end
      end
      object p0_lv: TTreeView
        Tag = -1
        AlignWithMargins = True
        Left = 3
        Top = 5
        Width = 347
        Height = 610
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clBtnFace
        Ctl3D = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Indent = 19
        MultiSelect = True
        ParentCtl3D = False
        ParentFont = False
        ParentShowHint = False
        ReadOnly = True
        ShowButtons = False
        ShowHint = True
        SortType = stText
        TabOrder = 0
        OnChange = p0_lvChange
        OnClick = p0_tvEnter
        OnDblClick = p0_lvDblClick
        OnDeletion = p0_lvDeletion
        OnEnter = p0_tvEnter
        OnExit = p0_lvExit
        OnHint = p0_lvHint
      end
      object p0_rv: TTreeView
        Tag = 1
        AlignWithMargins = True
        Left = 517
        Top = 6
        Width = 347
        Height = 610
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clBtnFace
        Ctl3D = False
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Indent = 19
        MultiSelect = True
        ParentCtl3D = False
        ParentFont = False
        ParentShowHint = False
        ReadOnly = True
        ShowButtons = False
        ShowHint = True
        SortType = stText
        TabOrder = 2
        OnChange = p0_lvChange
        OnClick = p0_tvEnter
        OnDblClick = p0_lvDblClick
        OnDeletion = p0_lvDeletion
        OnEnter = p0_tvEnter
        OnHint = p0_lvHint
      end
      object p0_btns: TPanel
        Left = 350
        Top = 101
        Width = 165
        Height = 516
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 3
        OnDblClick = p0_btnsDblClick
        object p0_del: TButton
          Left = 87
          Top = 484
          Width = 74
          Height = 25
          Caption = 'Delete'
          TabOrder = 0
          Visible = False
          OnClick = p0_delClick
        end
        object p0_bckp: TButton
          AlignWithMargins = True
          Left = 30
          Top = 89
          Width = 115
          Height = 64
          Caption = 'To achive >>'
          Enabled = False
          TabOrder = 1
          OnClick = p0_bckpClick
        end
        object p0_mag: TButton
          Left = 6
          Top = 368
          Width = 155
          Height = 33
          Caption = 'Fuzzy match'
          Enabled = False
          TabOrder = 2
          OnClick = p0_magicClick
        end
        object p0_ZIP: TButton
          Left = 87
          Top = 407
          Width = 74
          Height = 25
          Caption = 'ToZIP'
          TabOrder = 3
          OnClick = p0_ZIPClick
        end
        object p0_ref: TButton
          Left = 6
          Top = 407
          Width = 75
          Height = 25
          Caption = 'ToREF'
          TabOrder = 4
          OnClick = p0_refClick
        end
        object p0_rest: TButton
          AlignWithMargins = True
          Left = 30
          Top = 205
          Width = 115
          Height = 64
          Caption = '<< Restore'
          Enabled = False
          TabOrder = 5
          OnClick = p0_restClick
        end
        object p0_sql: TButton
          Left = 6
          Top = 484
          Width = 75
          Height = 25
          Caption = 'ToSQL'
          TabOrder = 6
          Visible = False
          OnClick = p0_sqlClick
        end
      end
    end
  end
  object sb1: TStatusBar
    Left = 0
    Top = 656
    Width = 874
    Height = 19
    Panels = <
      item
        Width = 250
      end
      item
        Width = 300
      end
      item
        Width = 50
      end>
  end
  object pb1: TProgressBar
    Left = 128
    Top = 639
    Width = 738
    Height = 7
    Anchors = [akLeft, akBottom]
    Smooth = True
    Step = 5
    TabOrder = 2
    Visible = False
  end
  object p0_qry: TButton
    AlignWithMargins = True
    Left = 361
    Top = 85
    Width = 152
    Height = 22
    TabOrder = 3
    OnClick = p0_qryClick
  end
  object p0_tren: TTrackBar
    Tag = 1
    Left = 352
    Top = 22
    Width = 166
    Height = 20
    Ctl3D = False
    Max = 48
    ParentCtl3D = False
    ShowSelRange = False
    TabOrder = 4
    OnChange = p0_trChange
  end
  object p0_trst: TTrackBar
    Tag = -1
    Left = 352
    Top = 48
    Width = 166
    Height = 20
    Ctl3D = False
    Max = 48
    ParentCtl3D = False
    ShowSelRange = False
    TabOrder = 5
    OnChange = p0_trChange
  end
  object CANCEL: TButton
    Left = 361
    Top = 272
    Width = 152
    Height = 39
    Caption = 'Cancel'
    TabOrder = 6
    Visible = False
    OnClick = CANCELClick
  end
  object pb2: TProgressBar
    Left = 128
    Top = 648
    Width = 738
    Height = 7
    Anchors = [akLeft, akBottom]
    Smooth = True
    Step = 5
    TabOrder = 7
    Visible = False
  end
  object ZF1: TZipForge
    ExtractCorruptedFiles = False
    CompressionLevel = clFastest
    CompressionMode = 1
    CurrentVersion = '6.92 '
    SpanningMode = smNone
    SpanningOptions.AdvancedNaming = False
    SpanningOptions.VolumeSize = vsAutoDetect
    Options.FlushBuffers = True
    Options.OEMFileNames = True
    ExclusionMasks.Strings = (
      '')
    InMemory = False
    OnOverallProgress = ZF1OverallProgress
    Zip64Mode = zmDisabled
    UnicodeFilenames = False
    EncryptionMethod = caPkzipClassic
    Left = 880
    Top = 128
  end
  object ucon: TUniConnection
    ProviderName = 'MySQL'
    Database = 'mysql'
    SpecificOptions.Strings = (
      'MySQL.UseUnicode=True')
    Username = 'transit'
    Server = '192.168.200.5'
    Left = 776
    Top = 176
    EncryptedPassword = '8BFF8DFF9EFF91FF8CFF96FF8BFF'
  end
end
