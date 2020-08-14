unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DateUtils,WideStrUtils, strutils, GpLists,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, IniFiles, IOUtils, Types, WideStrings, ShellAPI, ZipForge, DBAccess, Uni, DB,
  MemDS, Spin, CheckLst;

const  WM_AFTER_SHOW = WM_USER + 300; // custom message 

      _back_months = -24;                 // safety boundary
      _maxsnl : integer = 4000;        // maximum segment length in sql database
//      _min_hit : single = 0.5;         // min fuzzy match ratio to include in reflist
      _min_word_len = 5;               // min word length to include in vocabulary
      _myseed : longword = $0002F804;  // seed for hash function

      pheader   : widestring = #$F800+#$F802+'{00000000-0001-0005-0000-000000000000}'+#$F803+#$0002+#$F804+'20151212'+#$F805+'000000'+#$F8FF+'ROBOT'+#$EF00;
      psegstart : widestring = #$E90A+#$EA02+#$EE02+#$EF03+#$0030+#$EF04+'20151212'+#$EF05+'000000'+#$EF06+'ROBOT'+#$EF10+#$4000+#$EFFF;
      psegend   : widestring = #$EF00;

      ptail : widestring = #$EFFF;

type
  TState  = (toZip,toRef,toSQL);
  TStates = set of TState;

  TForm1 = class(TForm)
    TabControl1: TTabControl;
    Panel1: TPanel;
    p0_lv: TTreeView;
    p0_qry: TButton;
    p0_gbox_pair: TGroupBox;
    p0_tren: TTrackBar;
    sb1: TStatusBar;
    ZF1: TZipForge;
    ucon: TUniConnection;
    Panel2: TPanel;
    p1_cust: TComboBox;
    p1_src: TListBox;
    p1_dst: TListBox;
    p1_gen: TButton;
    p1_RL: TButton;
    p1_RRL: TButton;
    p1_LLR: TButton;
    p1_LR: TButton;
    TabControl2: TTabControl;
    p0_mmo: TMemo;
    pb1: TProgressBar;
    p1_refr: TButton;
    p0_del: TButton;
    p0_bckp: TButton;
    p0_ZIP: TButton;
    p0_ref: TButton;
    p0_mag: TButton;
    p0_rv: TTreeView;
    p0_btns: TPanel;
    p0_trst: TTrackBar;
    CANCEL: TButton;
    Panel3: TPanel;
    SQL_cmbo: TComboBox;
    Cmd_mmo: TMemo;
    Button1: TButton;
    Res_mmo: TMemo;
    Button2: TButton;
    p0_rest: TButton;
    p0_sql: TButton;
    log_mmo: TMemo;
    pb2: TProgressBar;
    procedure p0_trChange(Sender: TObject);
    procedure p0_bckpClick(Sender: TObject);
    procedure p0_delClick(Sender: TObject);
    procedure p0_refClick(Sender: TObject);
    procedure ZF1OverallProgress(Sender: TObject; Progress: Double; Operation: TZFProcessOperation;
      ProgressPhase: TZFProgressPhase; var Cancel: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure p1_DateChange(Sender: TObject);
    procedure p1_CustChange(Sender: TObject);
    procedure p1_LRClick(Sender: TObject);
    procedure p1_LLRClick(Sender: TObject);
    procedure p1_gena(Sender: TObject);
    procedure p1_RRLClick(Sender: TObject);
    procedure p1_RLClick(Sender: TObject);
    procedure p0_ZIPClick(Sender: TObject);
    procedure p0_magicClick(Sender: TObject);
    procedure TabControl2Change(Sender: TObject);
    procedure p0_lvDeletion(Sender: TObject; Node: TTreeNode);
    procedure p1_refrClick(Sender: TObject);
    procedure p0_qryClick(Sender: TObject);
    procedure p0_tvEnter(Sender: TObject);
    procedure p0_lvHint(Sender: TObject; const Node: TTreeNode; var Hint: string);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CANCELClick(Sender: TObject);
    procedure p0_lvChange(Sender: TObject; Node: TTreeNode);
    procedure FormDblClick(Sender: TObject);
    procedure SQL_cmboChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure p0_restClick(Sender: TObject);
    procedure p0_sqlClick(Sender: TObject);
    procedure p0_btnsDblClick(Sender: TObject);
    procedure p0_lvExit(Sender: TObject);
    procedure p0_lvDblClick(Sender: TObject);
  private
    mylog : TStringlist;
    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
    { Private declarations }
  public
    procedure SQL_connect;
    procedure unlock(fl : boolean);
    function  viola(node : TTreeNode;tv : TTreeView) : boolean;
    procedure Alpha(act : integer);
    procedure Omega(act : integer);
    procedure browse(pane : integer;st,en : TDate);
    { Public declarations }
  end;

  PRec = ^Trec;
  TRec = packed record
           pFN, pPath,
           pToFN,pToPath,
           pTitle, pCust : string;
           sLang, tLang  : integer;
           pDT     : TDateTime;
           swl,twl : TWideStringList;
           node    : TTreeNode;
         end;

var  Form1       : TForm1;
     Abort       : boolean;
     bn_st,bn_en : TDateTime;

     acp,app,
     cl_cust, cl_proj, cl_refs, arc_dir,
     cr_cust, cr_proj, cr_refs : string;
     min_hit : single;

     sql_ip,sql_login,sql_pass,ini  : string;
     safemode : boolean;  // do not delete project files
     states  : array [0..100] of boolean;
     pstates : array of string;

procedure log(msg : string);
function  myMessage(const msg: string;	dlgType: TMsgDlgType;	buttons: TMsgDlgButtons) : integer;
procedure DelDir(const DirName: string);
procedure MoveDir(const FromName,toName: string);
function _isshift : boolean;

implementation

uses unit2,scan,ALAVLBinaryTree,CosineSim;
{$R *.dfm}

const TST : array[1 .. 2] of Integer = (100,120);

// ---------------------------
function  TForm1.viola(node : TTreeNode;tv : TTreeView) : boolean;
const delims : array [0..0] of string = ('|');

var    prj : PRec;
 pna,ss,ts : string;
      i,pp : integer;
        md : TDateTime;
     pairs : TStringList;
       nde : TTreeNode;

begin
  result:=false;

  // invalid call
  if (node.Level<>2) or (tv=nil) then exit;
  
  // valid call, but already processed
  if node.data<>nil then begin
    result:=true;
    exit;
  end;

  new(prj);

  prj.swl:=TWideStringList.Create;     
  prj.twl:=TWideStringList.Create;

  node.Data  := prj;  
  prj.node   := node;     // back reference
  
  case tv.tag of
   -1 :  begin 
           prj.pFN   := cl_cust+'\'+node.parent.text+'\'+node.text;
           prj.pToFN := cr_cust+'\'+node.parent.text+'\'+node.text;
         end;
    1 :  begin 
           prj.pFN   := cr_cust+'\'+node.parent.text+'\'+node.text;
           prj.pToFN := cl_cust+'\'+node.parent.text+'\'+node.text;
         end;
    else exit;
  end;

  fileage(prj.pFN+'.prj',prj.pDT);
  
  with TMemIniFile.create(prj.pFN+'.prj') do begin
    pna  := ReadString('WorkingDir','WorkingDir','');

    case tv.Tag of
      -1 : begin 
             prj.pPath   := ExcludeTrailingPathDelimiter(cl_proj+copy(pna,length(app)+1,length(pna)));   // sic (!) transit use absolute path
             prj.pToPath := ExcludeTrailingPathDelimiter(cr_proj+copy(pna,length(app)+1,length(pna)));   // sic (!) transit use absolute path
           end;

       1 : begin 
             prj.pPath   := ExcludeTrailingPathDelimiter(cr_proj+copy(pna,length(app)+1,length(pna)));   // sic (!) transit use absolute path
             prj.pToPath := ExcludeTrailingPathDelimiter(cl_proj+copy(pna,length(app)+1,length(pna)));   // sic (!) transit use absolute path
           end;
    end;

    if not directoryexists(prj.pPath) then begin
      Log('Missing workdir for ['+prj.pFN+']');
      DeleteFile(prj.pFN+'.prj');
      DeleteFile(prj.pFN+'.ist');
      nde:=node.Parent; node.Delete; if nde.Count=0 then nde.Delete;
      exit;
    end;

    prj.pTitle := ReadString('Admin','ProjectName','');
    prj.pCust  := node.parent.text;   // just in case
    prj.sLang  := ReadInteger('Languages','SourceLanguage',0);
    prj.tLang  := ReadInteger('Languages','TargetLanguage',0);

    node.Text  := prj.pTitle;

    pairs:=TStringlist.Create;
    ReadSectionValues('Files',pairs);

    ss:='.'+cLangs[GetCode(prj.sLang)].ext;     ts:='.'+cLangs[GetCode(prj.tLang)].ext;
    for i:=0 to pairs.count-1 do begin
      pna:=leftstr(pairs.strings[i],length(pairs.strings[i])-2);  // cut trailing flag
      pna[LastDelimiter('|',pna)]:=#0;                            // we need last-1 param
      pp:=LastDelimiter('|',pna)+1;
      pna:=copy(pna,pp,pos(#0,pna)-pp);
      if (FileExists(prj.pPath+'\'+pna+ss)) and (FileExists(prj.pPath+'\'+pna+ts)) then begin
        tv.items.AddChildObject(node,pna,prj);
        result:=true;
      end;
    end;

    if not result then begin
      nde:=node.Parent; node.Delete; if nde.Count=0 then nde.Delete;
    end;

    Free;
  end;
end;

// -----------------------------

procedure TForm1.p0_trChange(Sender: TObject);
var dt : TDateTime;
    ss : string;
begin
//  bndry:=encodedate(yearof(now),monthof(now),15);
  if (sender is TControl) then begin
    case TTrackBar(Sender).Tag of
      // start of range
      -1 : if p0_trst.Position>=p0_tren.Position then p0_trst.Position:=p0_tren.Position;
       1 : if p0_tren.Position<=p0_trst.Position then p0_tren.Position:=p0_trst.Position;
    end;
  end;

  dt:=IncMonth(now,p0_tren.Position);
  bn_en:=endofamonth(yearof(dt),monthof(dt));

  dt:=IncMonth(now,p0_trst.Position);
  if p0_trst.Position=p0_trst.min then
    bn_st:=startofamonth(2000,1)
  else
    bn_st:=startofamonth(yearof(dt),monthof(dt));

  ss:=FormatDateTime('YYYY-MM-DD',bn_st)+' - '+FormatDateTime('YYYY-MM-DD',bn_en);

  p0_qry.Caption:=ss;
  sb1.Panels[1].Text:='['+ss+']';
end;

// --- scan projects
procedure TForm1.browse(pane : integer;st,en : TDate);
var    tv : TTreeView;
fext,root,dir : string;

procedure scan(dir : string;f_ext : string;node : TTreenode;tree : TTreeView);
var sr : TSearchrec;
   res : integer;
   nn  : TTreenode;
   dt  : TDateTime;
begin
  res := FindFirst(Dir+'\*.*', faAnyFile, sr);
  while res=0 do begin
    application.ProcessMessages;
    if (sr.Name<>'.') and (sr.Name<>'..') Then Begin
      if ((sr.Attr and faDirectory)<>0) and (node.Level=0) then begin
          nn:=tree.items.AddChild(node,sr.name);
          scan(Dir+'\'+sr.Name,f_ext,nn,tree);
      end else begin
        if (UpperCase(ExtractFileExt(sr.Name))=UpperCase(f_ext)) then begin
          FileAge(Dir+'\'+sr.Name,dt);
          if (dt>st) and (dt<en) then begin
            tree.items.AddChildObject(node,leftstr(sr.name,length(sr.Name)-4),nil);
//            viola(tree.items.AddChildObject(node,leftstr(sr.name,length(sr.Name)-4),nil),tree);
          end;
        end;
      end;
    end;
    res:=FindNext(sr);
  end;
  if (node.Count=0) and (node.level>0) then node.Delete;  // remove empty nodes
  FindClose(sr);
end;

begin
  case pane of
    -1 : begin
          tv:=p0_lv;
          fext:='.prj';
          root:='working_set';
          dir:=cl_cust;
         end;
     1 : begin
          tv:=p0_rv;
          fext:='.ist';
          root:='archive_set';
          dir:=cr_cust;
         end;
     else exit;    
  end;
  
  tv.Items.BeginUpdate;        
  tv.Items.Clear;
  tv.Items.Add(nil, root);  

  scan(dir,fext,tv.Items[0],tv);  

  tv.Items.AlphaSort(true);          
  tv.Items.EndUpdate; 
  tv.items[0].Expand(false);    
//  tv.items[0].Selected:=true;
end;

procedure TForm1.CANCELClick(Sender: TObject);
begin
  Abort:=true;
end;

// --- lock/unlock buttons
procedure TForm1.unlock(fl : boolean);
var i : integer;
begin
  abort:=false;
  if not fl then screen.cursor:=crHourglass else screen.cursor:=crArrow;

  if fl=false then begin

    SetLength(pstates,sb1.Panels.count);
    for i:=0 to sb1.Panels.count-1 do
      pstates[i]:=sb1.Panels[i].Text;

    states[0]:=p0_btns.visible;    p0_btns.hide;
    states[1]:=p0_lv.Enabled;      p0_lv.Enabled   := false;
    states[2]:=p0_rv.Enabled;      p0_rv.Enabled   := false;
    states[3]:=p0_qry.Enabled;     p0_qry.Enabled  := false;
    states[4]:=p1_refr.Enabled;    p1_refr.Enabled := false;
    states[5]:=p1_gen.Enabled;     p1_gen.Enabled  := false;

    p1_LLR.Enabled  := false;      p1_LR.Enabled   := false;    p1_RRL.Enabled  := false;      p1_RL.Enabled   := false;

  end else begin
    for i:=0 to sb1.Panels.count-1 do
      sb1.Panels[i].Text:=pstates[i];

    p0_btns.visible :=states[0];    
    p0_lv.Enabled   :=states[1];    
    p0_rv.Enabled   :=states[2];
    p0_qry.Enabled  :=states[3];    
    p1_refr.Enabled :=states[4];
    p1_gen.Enabled  :=states[5];

    p1_LLR.Enabled  := true;        p1_LR.Enabled   := true;
    p1_RRL.Enabled  := true;        p1_RL.Enabled   := true;
  end;
end;

// --------------------------
procedure TForm1.p0_btnsDblClick(Sender: TObject);
begin
  if _isshift then begin
    p0_sql.visible:=not p0_sql.visible;
//    p0_zip.visible:=not p0_zip.visible;
//    p0_ref.visible:=not p0_ref.visible;
    p0_del.visible:=not p0_del.visible;
  end;
end;

// --- update archiver progress
procedure TForm1.ZF1OverallProgress(Sender: TObject; Progress: Double; Operation: TZFProcessOperation;
  ProgressPhase: TZFProgressPhase; var Cancel: Boolean);
begin
  pb2.Position:=trunc(progress);
  application.ProcessMessages;
end;

// --- backup project
procedure TForm1.p0_bckpClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(100);
end;

// --- restoreproject
procedure TForm1.p0_restClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(110);
end;

// --- relevance check
procedure TForm1.p0_magicClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(120); 
end;

// --- archive
procedure TForm1.p0_ZIPClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(20); 
end;

// --- reference extract from project
procedure TForm1.p0_refClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(30); 
end;

// --- delete project
procedure TForm1.p0_delClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(10);
end;

// --- save project to sql
procedure TForm1.p0_sqlClick(Sender: TObject);
begin
  if TTreeView(form1.Tag).Selected<>nil then Alpha(40);
end;


// --- browse panes
procedure Tform1.p0_qryClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0 : begin
          unlock(false);
          if not _isshift then begin
            Browse(-1,bn_st,bn_en);
            Browse(1,startofamonth(yearof(now),monthof(now)),endofamonth(yearof(now),monthof(now)));
          end else begin
            Browse(1,bn_st,bn_en);
          end;
          unlock(true);
        end;
    1 : Omega(10);
  end;
end;

// -----------------------------
procedure TForm1.WmAfterShow(var Msg: TMessage); 
begin
  TabControl1Change(nil);
  p0_qryClick(nil);
end;

// -----------------------------
procedure TForm1.FormShow(Sender: TObject);
begin
  sql_connect;
  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0)  
end;


// -----------------------------
procedure TForm1.p1_refrClick(Sender: TObject);
begin
  Omega(0);
end;

// -----------------------------
procedure TForm1.p1_DateChange(Sender: TObject);
begin
  Omega(10);
end;

// -----------------------------
procedure TForm1.p1_CustChange(Sender: TObject);
begin
  Omega(20);
end;

// -------------------------
procedure TForm1.p1_RRLClick(Sender: TObject);
begin
  Omega(80);
end;

// -------------------------
procedure TForm1.p1_RLClick(Sender: TObject);
begin
  Omega(70);
end;

// -------------------------
procedure TForm1.p1_LRClick(Sender: TObject);
begin
  Omega(60);
end;

// -------------------------
procedure TForm1.p1_LLRClick(Sender: TObject);
begin
  Omega(50);
end;

// -------------------------
procedure TForm1.p1_gena(Sender: TObject);
begin
  Omega(100);
end;


// --- main tab switch
procedure TForm1.TabControl1Change(Sender: TObject);
begin
  p0_tren.Show;  p0_trst.Show; p0_qry.Show;
  case TabControl1.TabIndex of
    0 : begin
          panel3.hide;
          panel2.hide;
          panel1.show;
          p0_lv.SetFocus;
        end;
    1 : begin
          panel1.hide;
          panel3.hide;
          panel2.show;
          if (p1_src.Items.count=0) or (p1_src.Tag<>0) then Omega(0);
        end;
  end;
end;


// --- treeview change
procedure TForm1.p0_lvChange(Sender: TObject; Node: TTreeNode);
var i : integer;
begin
  if (node.level<>3) then begin
     p0_gbox_pair.hide;
     p0_rv.Show;     
     p0_lv.Show;
     p0_tren.Show;     
     p0_trst.Show;   
     p0_qry.Show;
     p0_btns.show;

     case TTreeView(form1.Tag).tag of
       -1 : begin
              p0_bckp.Enabled:=true;
              p0_rest.Enabled:=false;
            end;
        1 : begin
              p0_bckp.Enabled:=false;
              p0_rest.Enabled:=true;
            end;
     end;
  end;

  case node.Level of
    1 : if (node.Count=0) then node.Delete;
    2 : begin 
          if node.Data=nil then viola(node,TTreeView(sender));      // node not preloaded
        end;
    3 : begin 
          if TTreeView(Sender).Tag<=0 then begin
            p0_gbox_pair.Left:=360;  p0_rv.Hide;
          end else begin
            p0_gbox_pair.Left:=8;    p0_lv.Hide;
          end;
          p0_btns.hide;
          p0_gbox_pair.show;
          p0_tren.Hide;     
          p0_trst.Hide;   
          p0_qry.Hide;
          TabControl2.Tag:=integer(node);
          TabControl2.TabIndex:=0;
          TabControl2Change(nil);
        end;
  end;
end;

procedure TForm1.p0_lvDblClick(Sender: TObject);
var dir : string;
begin
  if not _isshift then exit;

  if TTreeView(Sender).Tag=-1 then
    dir:=cl_proj+'\..'
  else
    dir:=cr_proj+'\..';

  ShellExecute(Application.Handle,nil,'explorer.exe',PChar(dir),  nil, SW_NORMAL);
end;

procedure TForm1.p0_lvDeletion(Sender: TObject; Node: TTreeNode);
begin
  if (node.Level=2) and (node.data<>nil) then begin
    PRec(node.Data).swl.Free;  
    PRec(node.Data).twl.Free;  
    Dispose(PRec(node.Data));
  end;
end;


procedure TForm1.p0_lvExit(Sender: TObject);
begin
//  form1.Tag:=0;
//  p0_bckp.Enabled:=false;
//  p0_rest.Enabled:=false;
//  p0_btns.Visible:=false;
end;

procedure TForm1.p0_lvHint(Sender: TObject; const Node: TTreeNode; var Hint: string);
begin
  if (node.Level=3) and (node.data<>nil) then
    Hint:=FormatDateTime('YYYY-MM-DD',Prec(node.data).pDT)+' ['+
                        leftstr(cLangs[GetCode(Prec(node.data).sLang)].LongID,2)+'-'+
                        leftstr(cLangs[GetCode(Prec(node.data).tLang)].LongID,2)+']'
  else
    Hint:='';
end;

procedure TForm1.p0_tvEnter(Sender: TObject);
begin
  form1.Tag:=integer(sender);
  case TTreeView(form1.Tag).tag of
  -1 : begin
          p0_bckp.Enabled:=true;
          p0_rest.Enabled:=false;
          p0_mag.Enabled :=true;
       end;
   1 : begin
         p0_bckp.Enabled:=false;
         p0_rest.Enabled:=true;
         p0_mag.Enabled :=false;
       end;
  end;
end;

// --- pair switch
procedure TForm1.TabControl2Change(Sender: TObject);
var   ss  : widestring;
      nde : TTreeNode;
        r : integer;
begin
  nde:=TTreeNode(TabControl2.Tag);

  if nde.Level<>3 then exit;
  ss:=PRec(nde.data).pPath+'\'+nde.Text;

  TabControl2.Tabs[0]:=cLangs[GetCode(PRec(nde.Data).sLang)].ext;
  TabControl2.Tabs[1]:=cLangs[GetCode(PRec(nde.Data).tLang)].ext;

  case TabControl2.TabIndex of
    0 : ss:=ss+'.'+cLangs[GetCode(PRec(PRec(nde.data)).sLang)].ext;
    1 : ss:=ss+'.'+cLangs[GetCode(PRec(PRec(nde.data)).tLang)].ext;
  end;

  if not fileexists(ss) then begin
    MyMessage('File not found',mtError,[mbOk]);
    exit;
  end;

  p0_mmo.Lines.BeginUpdate;
  p0_mmo.Clear;
  screen.cursor:=crHourglass;

  with TWorker.create(ss) do begin
    repeat
      r:=Gather(ss);
      p0_mmo.Lines.Add(HTMLDecode(ss));
//        p0_mmo.Lines.Add(ss);
    until (r<0);
    done;
  end;
  p0_mmo.Lines.EndUpdate;
  screen.cursor:=crArrow;  
end;

// -----------------------------

procedure TForm1.Alpha(act : integer);
var      tv : TTreeView;
      i,cnt : integer;
        lst : array of TTreeNode;
        msg : string;

procedure join(nde : TTreeNode;var idx : integer);
begin
  case nde.Level of
  0,1 : begin
          nde := nde.GetFirstChild;
          if nde = nil then exit;
          repeat
            join(nde,idx);
            nde := nde.GetNextSibling;
          until nde = nil;
        end;
    2 : begin
          if nde.stateindex=0 then begin
            lst[idx]:=nde;
            inc(idx);
            nde.stateindex:=-1;       // inclide node only once     
          end;
        end;
  end;
end;

function clc(warn : string) : integer;
var ii : integer;
begin
  result:=0;
  SetLength(lst,tv.Items.Count);
  for ii:=0 to tv.Items.Count-1 do 
    if tv.Items[ii].level=2 then tv.Items[ii].stateindex:=0;  // one more dirty hack
  
  for ii:=0 to tv.Items.Count-1 do begin
    if tv.Items[ii].Selected then Join(tv.Items[ii],result);
  end;

  if (warn<>'') and (result>0) then 
    if (MyMessage(Format(warn,[result]),mtWarning,[mbOk,mbCancel])<>mrOk) then
      result:=0;
end;

// -----------------------
procedure ZIP(prj : PRec);
var ss : string;
begin
  ss:=arc_dir+'\'+prj.pCust+'\'+inttostr(yearof(prj.pDT));  // final path for archive file
  if not ForceDirectories(ss) then begin
    Log('Invalid target path '+ss);
    exit;
  end;

  ss := ss+'\'+FormatDateTime('YYYYMMDD',prj.pDT)+'-'+ExtractFileName(prj.pFN)+'.zip';

  sb1.Panels[2].Text:=extractfilename(ss);
  application.processmessages;

  pb2.Max:=100;   pb2.position:=0; pb2.show;
  with ZF1 do begin
    FileMasks.text:='*.*';
    ExclusionMasks.text:='*.bak'+#$0D+'*.bas'+#$0D+'*.mtx'+#$0D+'*.mts'+#$0D+'*.sub'+#$0D+'REFS\*.*';
    FileName:=ss;
    OpenArchive(fmCreate);
    BaseDir:=prj.pPath;
    AddFiles;
    BaseDir:=ExtractFilePath(prj.pFN);
    AddFiles(ExtractFileName(prj.pFN)+'.*');
    CloseArchive;
  end;
  pb2.hide;
end;

// ----------------------
procedure SQL(prj : Prec;reload : boolean);
var i,id : integer;
     hit : boolean;
     pdt : TDateTime;
begin
  // all cuntomer_name+project_name records should be unique
  try
    with TUniQuery.Create(nil) do begin
      Connection:=Ucon; hit:=false;
      Sql.Text:='select id,cust,proj,ts from transit.projects where cust=:mycust and proj=:myproj';
      ParamByName('mycust').AsString:= prj.pCust;  ParamByName('myproj').AsString:= prj.pTitle;
      Open; First;
      while not Eof do begin
        if DateOf(FieldByName('ts').AsDateTime)=DateOf(prj.pdt) then begin
          hit:=true;   // alreay there
        end else begin
          id:=FieldByName('id').AsInteger;
          with TUniSQL.Create(nil) do begin
            Connection:=Ucon;
            Sql.Text:='delete from transit.projects where id=:myid'; ParamByName('myid').AsInteger:=id; Execute;
            Sql.Text:='delete from transit.tmx where pid=:myid';     ParamByName('myid').AsInteger:=id; Execute;
            Free;
          end;
        end;
        Next;
      end;
      Close;
      Free;
    end;
  except
    on E : exception do Log('Action.SQL.'+e.message);
  end;

  if hit then exit;  // data already in sql database
  if reload then begin
    shrinkage(prj);
    saveToSQL(prj);
    prj.swl.clear;  prj.twl.clear;
  end else 
    saveToSQL(prj);
end;

// ----------------------
procedure REF(prj : Prec);
begin
  shrinkage(prj);
  saveToRef(prj,'');
  SQL(prj,false);
  prj.swl.clear;  prj.twl.clear;
end;


// ----------------------
procedure DEL(prj : Prec);
var   nde : TTreeNode;
begin
  try
    DelDir(prj.pPath);
    DeleteFile(prj.pFN+'.prj');
    DeleteFile(prj.pFN+'.ist');
    nde:=prj.node.Parent;  prj.node.Delete; if nde.Count=0 then nde.Delete;prj.node.Delete;
  except
    on E : exception do Log(e.Message);
  end;
end;

// ----------------------
procedure MOV(prj : Prec);
var dtv : TTreeView;
      i : integer;
    nde : TTreeNode;
begin
  if ForceDirectories(extractfilepath(prj.pToFN)) then begin
    try
      if CopyFile(PChar(prj.pFN+'.prj'),PChar(prj.pToFN+'.prj'),true) then begin
        FileCreate(prj.pToFN+'.ist');

        DelDir(prj.pToPath);             // clear target
        MoveDir(prj.pPath,prj.pToPath);  // move source to target
        DelDir(prj.pPath);               // clear source

        DeleteFile(prj.pFN+'.prj');      // remove project from source
        DeleteFile(prj.pFN+'.ist');

        if tv.Tag=-1 then dtv:=p0_rv else dtv:=p0_lv;
        nde:=nil;
        // seacrh for customer in destination tree
        for i:=0 to dtv.Items[0].Count-1 do begin
          if dtv.Items[0].item[i].Text=prj.pCust then begin
            nde:=dtv.Items[0].item[i];
            break;
          end;
        end;
        if nde=nil then nde:=dtv.Items.AddChild(dtv.Items[0],prj.pCust);
        dtv.Items.AddChild(nde,prj.pTitle);
        nde:=prj.node.Parent;  prj.node.Delete; if nde.Count=0 then nde.Delete;prj.node.Delete;
        dtv.Items.AlphaSort(true);
        dtv.Items[0].Expand(false);
      end else Log('Action.MOV.Project exists :'+prj.pToFN);
   except
     on E : exception do Log('Action.MOV.Relocate error :'+prj.pToFN+' : '+e.Message);
   end;
  end else Log ('Action.MOV.Forcedir error :'+prj.pToFN);
end;

// ----------------------
function gather(id : integer) : widestring;  
begin
  with TUniQuery.Create(nil) do begin
    Connection:=Ucon;
    Sql.Text:='select GROUP_CONCAT(src,'''' '''') from transit.tmx where pid=:myid';
    ParamByName('myid').AsInteger := id;
    Open;
    result:=Fields[0].AsString;
    Close;
    Free;
  end;
end;

// ----------------------
procedure MAG(prj : Prec);
var  voc_s,voc_t : TALCardinalKeyAVLBinaryTree;
     res : double;
    Uqry : TUniQuery;
       i : integer;
     xcx : TMemorystream;
      ss : string;
begin
  voc_s:=TALCardinalKeyAVLBinaryTree.Create;
  sb1.panels[1].text:=prj.pCust+' : '+prj.pTitle;
  fill_Voc(voc_s,collapse(prj));
  try
    Uqry:=TUniQuery.Create(nil);
    Uqry.Connection:=Ucon;
    Uqry.Sql.Text:='select * from transit.projects where (cust=:mycast and slcd=:slang and dlcd=:tlang) order by id';
    Uqry.ParamByName('mycast').AsString := prj.pCust;
    Uqry.ParamByName('slang').AsInteger := prj.sLang;
    Uqry.ParamByName('tlang').AsInteger := prj.tLang;

    Uqry.Open;  Uqry.First;
    pb2.max:=Uqry.RecordCount;
    pb2.Show;
    p1_src.Tag:=0;
    for i:=0 to Uqry.recordcount-1 do begin
      pb2.Position:=i+1;
      form1.sb1.Panels[2].Text:=Uqry.FieldByName('cust').AsString+':'+Uqry.FieldByName('proj').AsString;
      application.ProcessMessages;
      if abort then Break;

      voc_t:=TALCardinalKeyAVLBinaryTree.Create;
      xcx:=TMemorystream.Create;
      // --- grab project data to compare
      if Uqry.FieldByName('BTREE').IsNull then begin
        sb1.panels[1].text:=prj.pCust+' : '+prj.pTitle;
        fill_Voc(voc_t,gather(Uqry.FieldByName('id').AsInteger));
        voc_t.SaveToStream(xcx);
        with TUniQuery.Create(nil) do begin
          Connection:=Ucon;
          Sql.Text:='update transit.projects SET btree = :bt where id=:myid';
          ParamByName('myid').AsInteger := Uqry.FieldByName('id').AsInteger;
          ParamByName('bt').LoadFromStream(xcx,ftBlob);
          Execute; Free;
        end;
      end else begin
        TBlobField(Uqry.FieldByName('btree')).SaveToStream(xcx);
        xcx.position:=0;
        voc_t.loadfromstream(xcx);
      end;

      res:=cmp_Voc(voc_s,voc_t);
      voc_t.Free;
      xcx.Free;

      if (res>=min_hit) and (Uqry.FieldByName('proj').AsString<>prj.pTitle) then begin
        if p1_src.Tag=0 then begin
          p1_src.Tag:=integer(prj);
          p1_src.Clear;  p1_dst.Clear;
        end;
        p1_src.AddItem(Format('%d%% %s',[integer(trunc(res*100)),Uqry.FieldByName('proj').asstring]),pointer(Uqry.FieldByName('id').asInteger));
      end;
      Uqry.Next;
    end;
    pb2.Hide;
    Uqry.Close; Uqry.Free;

    voc_s.Free;
  except
    on E : exception do Log('Action.MAG.'+e.message);
  end;
end;

begin
  tv:=TTreeView(form1.Tag);
  if tv.Selected=nil then exit;

  case act of
    // relevance search
    120 : if (tv.Selected.Level=2) then begin
            CANCEL.show;  unlock(false);
            if viola(tv.Selected,tv) then
              MAG(Prec(tv.Selected.data));
            CANCEL.hide;  unlock(true);
            if p1_src.Tag<>0 then begin
              panel2.Visible:=true;    panel1.Visible:=false;
              TabControl1.TabIndex:=1;
            end else MyMessage('Sorry, no matches were found.',mtInformation,[mbOk]);
          end;
     else
       if (tv.Selected.Level in [0..2]) then begin
         unlock(false);
         case act of
            10 : msg:='Permanently delete %d projects ?';
            20 : msg:='Make archives from %d projects ?';
            30 : msg:='Make reference extract from %d projects ?';
            40 : msg:='Save %d projects to SQL database ?';
           100 : msg:='Relocate %d projects to archive ?';
           110 : msg:='Restore %d projects from archive ?';
         end;
         cnt:=clc(msg);   pb1.Max:=cnt;
         p0_lv.Items.BeginUpdate;   p0_rv.Items.BeginUpdate;
         CANCEL.show;   pb1.Show;
         for i:=0 to cnt-1 do begin
           if abort then Break;
           if viola(lst[i],tv) then begin
             pb1.Position:=i+1;
             sb1.Panels[1].Text:=Prec(lst[i].Data).pCust+' : '+Prec(lst[i].Data).pTitle;
             application.ProcessMessages;
             case act of
                10 : DEL(Prec(lst[i].Data));
                20 : ZIP(Prec(lst[i].Data));
                30 : REF(Prec(lst[i].Data));
                40 : SQL(Prec(lst[i].Data),true);
           100,110 : MOV(Prec(lst[i].Data));
             end;
           end;
         end;
         pb1.Hide;      CANCEL.Hide;
         p0_rv.Items.EndUpdate;    p0_lv.Items.EndUpdate;
         unlock(true);
       end;
  end;
  if panel1.Visible then tv.SetFocus;
end;


// ----------------------------
procedure TForm1.Omega(act : integer);
var  j : integer;

procedure CUST;
begin
  try
    p1_cust.Items.BeginUpdate;
    with TUniQuery.Create(nil) do begin
      Connection:=Ucon;
      Sql.Text:='select distinct cust from transit.projects where ts>:st and ts<:en order by cust';
      ParamByName('st').AsDateTime := bn_st;
      ParamByName('en').AsDateTime := bn_en;

      Open;  First;
      p1_cust.clear;
      p1_cust.Items.Add('All customers');
      while not Eof do begin
        p1_cust.Items.Add(FieldByName('cust').AsString);
        Next;
      end;
      Close;  Free;
    end;
  finally
    p1_cust.Items.EndUpdate;
    p1_cust.ItemIndex:=0;
  end;
end;

// --------------------------
procedure SELECT;
begin
  p1_src.Perform(LB_SETTABSTOPS,high(TST),LongInt(@TST));   p1_dst.Perform(LB_SETTABSTOPS,high(TST),LongInt(@TST));

  p1_src.Clear;
  p1_src.Tag:=0;
  try
    p1_src.Items.BeginUpdate;
    with TUniQuery.Create(nil) do begin
      Connection:=Ucon;
      if p1_cust.ItemIndex=0 then
        Sql.Text:='select * from transit.projects where ts>:st and ts<:en order by proj'
      else begin
        Sql.Text:='select * from transit.projects where cust=:mycust and ts>:st and ts<:en order by proj';
        ParamByName('mycust').AsWideString := p1_cust.text;
      end;
      ParamByName('st').AsDateTime:=bn_st;
      ParamByName('en').AsDateTime:=bn_en;
      Open; First;
      while not Eof do begin
        p1_src.AddItem(FieldByName('proj').AsString+#9+
                       cLangs[GetCode(FieldByName('slcd').AsInteger)].LongID+' -> '+
                       cLangs[GetCode(FieldByName('dlcd').AsInteger)].LongID+#9+
                       FormatDateTime('MM-YYYY',FieldByName('ts').AsDateTime),pointer(FieldByName('id').asInteger));

        Next;
      end;
      Close; Free;
    end;
  finally
    p1_src.Items.EndUpdate;
  end;
end;

procedure MKREF;
var  ss : string;
    prj : PRec;
     ii : integer;
    lst : TStringList;
begin
  if (p1_src.Tag<>0) and (MyMessage('Attch references to project ?',mtWarning,[mbYes,mbNo])=mrYes) then begin
    prj:=PRec(p1_src.Tag);
    ss:=prj.pPath+'\REFS';
    with TiniFile.Create(PRec(p1_src.Tag).pFN+'.prj') do begin
      lst:=TStringList.Create;
      ReadSection('References',lst);
      WriteString('References','File'+inttostr(lst.count+1),'1|1|1|0|2|'+app+'\'+prj.pCust+'\'+prj.pTitle+'\REFS\*.*|||0|1|0');
      lst.Free; prj:=nil;
      Free;
    end;
  end else ss:='';
  New(prj);
  prj.swl:=TWideStringList.Create;
  prj.twl:=TWideStringList.Create;

  pb1.show; pb1.max:=p1_dst.Count;
  for ii := 0 to p1_dst.Count-1 do begin
    pb1.position:=ii+1;
    application.processmessages;
    prj.swl.Clear;   prj.twl.Clear;
    with TUniQuery.Create(nil) do begin
      Connection:=Ucon;
      SQL.Text:='select * from transit.projects where id=:pid';
      ParamByName('pid').AsInteger:=integer(p1_dst.items.objects[ii]);
      Open; First;
      prj.pTitle := FieldByName('Proj').AsString;   prj.pCust  := FieldByName('Cust').AsString;
      prj.sLang  := FieldByName('SLCD').AsInteger;  prj.tLang  := FieldByName('DLCD').AsInteger;
      prj.pDT    := FieldByName('TS').AsDateTime;
      Close;

      SQL.Text:='select * from transit.tmx where pid=:pid order by id';
      ParamByName('pid').AsInteger:=integer(p1_dst.items.objects[ii]);
      Open; First;
      while not Eof do begin
        prj.swl.Add(FieldByName('SRC').AsString);
        prj.twl.Add(FieldByName('DST').AsString);
        Next;
      end;
      Close; Free;
    end;
    saveToRef(prj,ss);
  end;
  pb1.Hide;
  prj.swl.free;     prj.twl.free;
  Dispose(prj);
end;

begin
  unlock(false);

  case act of
     0 : begin
           p0_trEN.position:=p0_trEn.Max;
           p0_trSt.position:=p0_trSt.Min;
           p1_src.Clear;          
           p1_dst.Clear;
           CUST;
           SELECT;
         end;
    10 : begin
           CUST;
           SELECT;
         end;
    20 : SELECT;

 50,60 : begin
           try
             p1_dst.Items.BeginUpdate;   p1_src.Items.BeginUpdate;
             if act=50 then p1_src.SelectAll;
             for j := 0 to p1_src.Count - 1 do
               if p1_src.Selected[j] and (p1_dst.Items.IndexOf(p1_src.items.Strings[j])<0) then p1_dst.Items.AddObject(p1_src.items.Strings[j],p1_src.items.Objects[j]);
             p1_src.ClearSelection;  
           finally
             p1_dst.Items.EndUpdate;     p1_src.Items.EndUpdate;
           end;
         end;

    70 : begin
           p1_dst.DeleteSelected;
         end;

    80 : begin
           p1_dst.Clear;
         end;

   100 : if (p1_dst.Count>0) and (MyMessage(Format('Start buliding references from %d projects ?',[p1_dst.Count]),mtWarning,[mbOk,mbCancel])=mrOk) then begin
           MKREF;
         end;
  end;
  unlock(true);

  if p1_dst.Items.Count>0 then
    p1_gen.Enabled:=true
  else
    p1_gen.Enabled:=false;
end;

// ----------------------------------
procedure TForm1.SQL_cmboChange(Sender: TObject);
begin
  cmd_mmo.text:=sql_cmbo.Text;
end;

// ----------------------
procedure TForm1.Button1Click(Sender: TObject);
var  Usql: TUniSQL;
begin
  Usql:=TUniSQL.Create(nil);
  Usql.Connection:=Ucon;
  Usql.SQL.Text:=cmd_mmo.text;
  try
    Usql.Execute;
    res_mmo.lines.add(Format('Rows affected: %d',[Usql.RowsAffected]));
  except
    on e : exception do res_mmo.lines.add(e.message);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  cmd_mmo.Clear;
  res_mmo.Clear;
  log_mmo.Clear;
  mylog.Clear;
end;

// ------------------------------------
procedure TForm1.SQL_connect;
var  Usql: TUniSQL;
begin
  Ucon.server   := sql_ip;  Ucon.username := sql_login;  Ucon.Password := sql_pass;
  try
    Ucon.Connect;
  except
    on E : exception do begin 
      MyMessage('Fatal error - SQL server',mtError,[mbOk]);
      Application.terminate;
    end;
  end;

  Usql:=TUniSQL.Create(nil);
  Usql.Connection:=Ucon;
     
  try
    Usql.SQL.Text:='create database transit DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci';
    Usql.Execute;
  except
    on E : exception do Log(e.message);
  end;

  Ucon.Disconnect;       Ucon.Database:='transit';     UCon.Connect;

  try
    Usql.SQL.Text:='CREATE TABLE transit.projects (ID MEDIUMINT NOT NULL AUTO_INCREMENT, CUST VARCHAR(32), PROJ VARCHAR(32),'+
                    ' TS DATETIME, SLCD INT, DLCD INT, BTREE MEDIUMBLOB, PRIMARY KEY (ID),UNIQUE KEY X2(CUST,PROJ,TS)) ENGINE=InnoDB CHARACTER SET=utf8';
    Usql.Execute;
  except
    on E : exception do Log(e.message);
  end;

  try
    Usql.SQL.Text:='CREATE TABLE transit.tmx (ID MEDIUMINT NOT NULL AUTO_INCREMENT, PID MEDIUMINT NOT NULL, CRC BIGINT NOT NULL,'+
                    ' SRC VARCHAR(:FLEN), DST VARCHAR(:FLEN), TS DATETIME, PRIMARY KEY (ID)) ENGINE=InnoDB CHARACTER SET=utf8';

    Usql.ParamByName('FLEN').AsInteger := _maxsnl;
    Usql.Execute;
  except
    on E : exception do Log(e.message);
  end;

  sb1.Panels[0].Text:='Connected to '+Ucon.Server;
  Usql.Free;
end;

// -------------------------
function myMessage(const msg: string;	dlgType: TMsgDlgType;	buttons: TMsgDlgButtons) : integer;
var MesDlg:TForm;
begin
//  Log(msg);
  with form1 do begin
    MesDlg:=CreateMessageDialog(msg,dlgType,buttons);
    MesDlg.Left:=Left+Width div 2-MesDlg.Width div 2;
    MesDlg.Top:=Top+Height div 2-MesDlg.Height div 2;
    //showing
    result:=MesDlg.ShowModal;
    MesDlg.Close;
    MesDlg.Free;
  end;
end;

// --- delete non empty directory
procedure DelDir(const DirName: string);
var
  FileFolderOperation: TSHFileOpStruct;
begin
  FillChar(FileFolderOperation, SizeOf(FileFolderOperation), 0);
  FileFolderOperation.wFunc := FO_DELETE;
  FileFolderOperation.pFrom := PChar(ExcludeTrailingPathDelimiter(DirName) + #0);
  FileFolderOperation.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION;
  SHFileOperation(FileFolderOperation);
end;

// --- move directory
procedure MoveDir(const FromName,toName: string);
var
  FileFolderOperation: TSHFileOpStruct;
begin
  FillChar(FileFolderOperation, SizeOf(FileFolderOperation), 0);
  FileFolderOperation.wFunc := FO_MOVE;
  FileFolderOperation.pFrom := PChar(IncludeTrailingPathDelimiter(FromName)+'*.*' + #0);
  FileFolderOperation.pTo   := PChar(ExcludeTrailingPathDelimiter(ToName) + #0);
  FileFolderOperation.fFlags := FOF_SILENT or FOF_NOERRORUI or FOF_NOCONFIRMATION; //FOF_ALLOWUNDO or FOF_SIMPLEPROGRESS;
  SHFileOperation(FileFolderOperation);
end;


// -----------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  mylog.SaveToFile(leftstr(Application.ExeName,length(Application.ExeName)-3)+'log');
  mylog.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i : integer;
begin
  mylog:=TStringList.Create;

  p0_trEn.Max :=  0;     p0_trEn.Min :=_back_months;    p0_trEN.position:=p0_trEn.Max;
  p0_trSt.Max :=  0;     p0_trSt.Min :=_back_months;    p0_trSt.position:=p0_trSt.Min;

  ini:=leftstr(Application.ExeName,length(Application.ExeName)-3)+'ini';
  if FileExists(ini) then begin
    with TMemIniFile.Create(ini) do begin
      try
        safemode := ReadBool('common','safemode',true);

        acp := ExcludeTrailingPathDelimiter(ReadString('common','acp',''));
        app := ExcludeTrailingPathDelimiter(ReadString('common','app',''));
        
        cl_cust := ExcludeTrailingPathDelimiter(ReadString('common','l_cust','\config\customers'));
        cl_proj := ExcludeTrailingPathDelimiter(ReadString('common','l_proj','\projects'));
        cl_refs := ExcludeTrailingPathDelimiter(ReadString('common','l_refs','\TMX'));

        cr_cust := ExcludeTrailingPathDelimiter(ReadString('common','r_cust','\arch\config\customers'));
        cr_proj := ExcludeTrailingPathDelimiter(ReadString('common','r_proj','\arch\projects'));
        cr_refs := ExcludeTrailingPathDelimiter(ReadString('common','r_refs','\arch\TMX'));

        arc_dir := ExcludeTrailingPathDelimiter(ReadString('common','arcdir','\ZIP'));
        min_hit := ReadFloat('common','minHit',0.5);

        sql_ip    := ReadString('sql','serverip','127.0.0.1');
        sql_login := ReadString('sql','login','transit');
        sql_pass  := ReadString('sql','password','transit');
        //sql_ip:='10.0.0.254';  sql_pass  := sql_login+rightstr(sql_login,3);

        ReadSectionValues('scripts',sql_cmbo.items);
        for i:=0 to sql_cmbo.items.Count-1 do
          sql_cmbo.items[i]:=copy(sql_cmbo.items[i],pos('=',sql_cmbo.items[i])+1,length(sql_cmbo.items[i]));
        sql_cmbo.itemindex:=0;

     except
       on e : exception do begin 
         MyMessage('Check ini file:'+ini+' : '+e.Message,mtWarning,[mbOk]);
         application.terminate;
       end;
     end;
     free;
    end;
  end else begin
    MessageDlg('Settings file '+ini+' missing',mtError,[mbOk],0);
    application.terminate;
  end;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  if _isshift then begin
    panel1.Hide;   panel2.Hide;   panel3.Show;
    p0_tren.Hide;  p0_trst.Hide;  p0_qry.Hide;
    log_mmo.Text:=mylog.Text;
  end;
end;

// -----------------------------
function _isshift : boolean;
var State: TKeyboardState;
begin
  GetKeyboardState(State);
  result:=((State[vk_Shift] and 128)<>0);
end;

// -----------------------------
procedure log(msg : string);
begin
  form1.sb1.panels[0].Text:=msg;
  form1.mylog.Add(FormatDateTime('YYYY-MM-DD HH:MM:SS',now)+' - '+msg);
end;


end.
