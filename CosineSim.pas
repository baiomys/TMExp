unit CosineSim;

interface
uses Dialogs,Forms, DateUtils, SysUtils, StrUtils, Classes, IniFiles, WideStrings, WideStrUtils,ALAVLBinaryTree, unit1, unit2;

const del    : set of widechar = [' ',#$0D,#$0A,'!','@','#','$','%','^','*','(',')','-','=','+',':','\','/','"','''','?','.',',','[',']'];

procedure fill_Voc(voc :  TALCardinalKeyAVLBinaryTree;ss : widestring);
function cmp_Voc(voc_s,voc_t :  TALCardinalKeyAVLBinaryTree) : single;

implementation
uses scan;

var a,b,c : single;

// ------------------------------------------
procedure _Tokenize(const _in : widestring;_delims : array of widestring;fTokens : TWideStringList);
var  i, k, pPos  : Integer;
       nTok,cTok : widestring;
begin
  cTok := '';

  for i := 1 to length(_in) do begin
    cTok := cTok + _in[i];
    for k := 0 to length(_delims) - 1 do  begin
      pPos := pos(_delims[k], cTok);
      if pPos > 0 then begin
        nTok := copy(cTok, 1, pPos - 1);
        if nTok <> '' then fTokens.add(trim(nTok));
        cTok := '';
      end;
    end;
  end;

  if cTok <> '' then fTokens.Add(trim(cTok));
end;

procedure Tokenize(const _in : widestring;fTokens : TWideStringList);
var  i : Integer;
  cTok : widestring;
begin
  cTok := '';

  for i := 1 to length(_in) do begin
    if i mod 100=0 then begin
      form1.sb1.panels[2].text:=Format('%d%%',[integer(round(100*i/length(_in)))]);
      application.ProcessMessages;
    end;

    if (_in[i] in del) and (cTok <> '') then begin
        fTokens.add(trim(cTok));
        cTok := '';
    end else cTok := cTok + _in[i];
  end;
  if cTok <> '' then fTokens.Add(trim(cTok));
end;


// ------------------------------------------
procedure _cmp(aTree: TALBaseAVLBinaryTree; sNode: TALBaseAVLBinaryTreeNode; aExtData: Pointer; Var aContinue: Boolean);
var v1,v2 : integer;
      tNode : TALCardinalKeyAVLBinaryTreeNode;
begin
  v1:=TALCardinalKeyAVLBinaryTreeNode(sNode).cnt; v2:=0;

  tNode:=TALCardinalKeyAVLBinaryTree(aExtData).FindNode(TALCardinalKeyAVLBinaryTreeNode(sNode).ID);
  if tNode<>nil then begin
     v2:=tNode.cnt;
  end else v2:=0;

  a:=a+v1*v2;  b:=b+v1*v1;  c:=c+v2*v2;

  acontinue := True;
end;

// ------------------------------------------
function cmp_Voc(voc_s,voc_t :  TALCardinalKeyAVLBinaryTree) : single;
begin

  a:=0; b:=0; c:=0;
  result:=0;

  voc_s.Iterate(_cmp,true,voc_t);
  if (b<>0) and (c<>0) then
    result:=a/(sqrt(b)*sqrt(c));
end;

// ------------------------------------------
procedure fill_Voc(voc :  TALCardinalKeyAVLBinaryTree;ss : widestring);
var       i : integer;
         dw : widestring;
    nde,res : TALCardinalKeyAVLBinaryTreeNode;
      wlist : TWideStringList;
      empty : boolean;

begin
  wlist:=TWideStringList.Create;
  Tokenize(HTMLDecode(ss),wlist);

  for i:=0 to wlist.count-1 do begin
    dw:=wlist.Strings[i];
    if length(dw)<_min_word_len then continue;
    nde := TALCardinalKeyAVLBinaryTreeNode.Create;
    nde.ID := wHash(upperCase(dw));
//    nde.key:=dw;               // debug
    res := voc.AddNode(nde);
    if res<>nde then nde.Free;   // already exists
    inc(res.cnt);
  end;
  wlist.free;
//  voc.SaveToFile('c:\dbg.txt'); // debug
end;


end.
