unit scan;

interface
uses Windows, Forms, SysUtils, StrUtils, ComCtrls, Classes, WideStrings, WideStrUtils, GpLists, unit1;

const   _seg_start : widechar = #$EFFF;
        _seg_end   : wideChar = #$EF00;
        _mark1     : wideChar = #$4000;
        _mark2     : wideChar = #$4064;


type TWorker = class
        constructor create(sfn,tfn : string); overload;
        constructor create(sfn : string);    overload;

        destructor  done;
        function    LoadStringFromFile(const filename: string; encoding: TEncoding = nil): string;
        function    Fetch(var sstr,tstr : widestring) : integer;
        function    Gather(var str : widestring) : integer;

     private
       spair,tpair : TWideStringList;

       s_pp : integer;
       t_pp : integer;
     end;

function  wHash(const Key: widestring): LongWord;
procedure shrinkage(prj : PRec);
function  collapse(prj : PRec) : widestring;
procedure saveToRef(prj : PRec;dst : string);
procedure saveToSQL(prj : PRec);

implementation
uses Uni,  UniProvider,  MySQLUniProvider, DB, unit2,ALAVLBinaryTree;

// ---------------------------------

function rTags(s: widestring): widestring;  inline;
var p1,p2  : Integer;
begin
  result:='';
//  s:=WideStringReplace(s,'<TAB/>',' ',[rfReplaceAll]);

  repeat
    p1:=pos('<',s);    p2:=pos('>',s);
    if (p2>p1) and (p1<>0) then
      delete(s,p1,p2-p1+1)
    else break;
  until (1<>1);
  result:=trim(s);
//  result:=WideStringReplace(result,#$000D+#$000A,' ',[rfReplaceAll]);
end;

// ---------------------------------

destructor TWorker.done;
begin
  spair.Free; tpair.Free;
end;

// ---------------------------------

function TWorker.LoadStringFromFile(const filename: string; encoding: TEncoding = nil): string;
var
  FPreambleLength: Integer;
begin
  with TBytesStream.Create do
  try
    LoadFromFile(filename);
    FPreambleLength := TEncoding.GetBufferEncoding(Bytes, encoding);
    Result := encoding.GetString(Bytes, FPreambleLength, Size - FPreambleLength);
  finally
    Free;
  end;
end;

// ---------------------------------

constructor TWorker.create(sfn,tfn : string);
begin
  spair:=TWideStringList.Create;
  spair.delimiter        :=_seg_end;
  spair.StrictDelimiter  :=true;
  spair.sorted           :=false;
  spair.DelimitedText    :=LoadStringFromFile(sfn,TEncoding.Unicode);

  tpair:=TWideStringList.Create;
  tpair.delimiter        :=_seg_end;
  tpair.StrictDelimiter  :=true;
  tpair.sorted           :=false;
  tpair.DelimitedText    :=LoadStringFromFile(tfn,TEncoding.Unicode);

  s_pp:=0; t_pp:=0;
end;

// ---------------------------------
constructor TWorker.create(sfn : string);
begin
  spair:=TWideStringList.Create;
  spair.delimiter        :=_seg_end;
  spair.StrictDelimiter  :=true;
  spair.sorted           :=false;
  spair.DelimitedText    :=LoadStringFromFile(sfn,TEncoding.Unicode);

  s_pp:=0; t_pp:=0;
end;

// ---------------------------------
function TWorker.Fetch(var sstr,tstr : widestring) : integer;
var pp : integer;
    ss : widestring;
    fl : boolean;
begin
  result:=-1;
  sstr:='';    tstr:='';

  repeat
    ss := spair.Strings[s_pp];  pp := pos(_seg_start,ss);
    if pp<>0 then begin
      sstr := rtags(copy(ss,pp+1,length(ss)));
      ss := tpair.Strings[s_pp];  pp := pos(_seg_start,ss);
      if pp<>0 then tstr := rtags(copy(ss,pp+1,length(ss)));
    end;
    inc(s_pp);
//    if (s_pp>=spair.count) or ((sstr<>'') and (tstr<>'') and (sstr<>tstr)) then fl:=true else fl:=false;
  until (s_pp>=spair.count) or (length(sstr)+length(tstr)>6);
  if s_pp<spair.count then result:=round(100*s_pp/spair.Count);
end;


// ---------------------------------
function TWorker.Gather(var str : widestring) : integer;
var   ss : widestring;
      pp : integer;
begin
  result:=-1;
  str:='';
  repeat
    ss:=spair.Strings[s_pp];     pp:=pos(_seg_start,ss);
    if pp<>0 then begin
      str:= rtags(copy(ss,pp+1,length(ss)));
    end;

    inc(s_pp);
  until (s_pp>=spair.count) or (str<>'');
  if s_pp<spair.count then result:=round(100*s_pp/spair.Count);
end;

// ---------------------------------
function LRot32(X: LongWord; c: Byte): LongWord; inline;
begin
	Result := (X shl c) or (X shr (32-c));
end;

// ---------------------------------
function HashData32(const Key; KeyLen: LongWord; const Seed: LongWord): LongWord;  inline;
var	hash,len,k : LongWord;
           	 i : Integer;
     	keyBytes : PByteArray;

const
	c1 = $cc9e2d51;	c2 = $1b873593;
  r1 = 15;	      r2 = 13;
  m = 5;	        n = $e6546b64;
begin
	keyBytes := PByteArray(@Key);

	hash := seed;
	len := KeyLen;

	i := 0;
	while(len >= 4) do begin
		k := PLongWord(@(keyBytes[i]))^;
		k := k*c1;		k := LRot32(k, r1);		k := k*c2;
		hash := hash xor k;		hash := LRot32(hash, r2);		hash := hash*m + n;
		Inc(i, 4);
		Dec(len, 4);
	end;

	if len > 0 then	begin
		Assert(len <= 3);
		k := 0;
		if len = 3 then  k := k or (keyBytes[i+2] shl 16);
		if len >= 2 then k := k or (keyBytes[i+1] shl 8);
		k := k or (keyBytes[i]);
		k := k*c1; 		k := LRot32(k, r1);		k := k*c2;
		hash := hash xor k;
	end;

	hash := hash xor keyLen;
	hash := hash xor (hash shr 16);	hash := hash * $85ebca6b;
	hash := hash xor (hash shr 13);	hash := hash * $c2b2ae35;
	hash := hash xor (hash shr 16);
	Result := hash;
end;

function ToUtf8(const Source: PWideChar; nChars: Integer): AnsiString;  inline;
var strLen: Integer;
begin
	if nChars = 0 then begin
		Result := ''; Exit;
	end;

	strLen := WideCharToMultiByte(CP_UTF8, 0, Source, nChars, nil, 0, nil, nil);
	if strLen = 0 then RaiseLastOSError;
	SetLength(Result, strLen);
	strLen := WideCharToMultiByte(CP_UTF8, 0, Source, nChars, PAnsiChar(Result), strLen, nil, nil);
	if strLen = 0 then RaiseLastOSError;
end;


// ----------------------------------
function WHash(const Key: widestring): LongWord;  inline;
var s: AnsiString;

begin
  s := ToUtf8(PWideChar(Key), Length(Key));
  Result := HashData32(Pointer(s)^, Length(s)*SizeOf(AnsiChar), _myseed);
end;

// ----------------------------------
function collapse(prj : PRec) : widestring;
var   i,r : integer;
    se,pa : string;
       ss : widestring;
  nde,res : TALInt64KeyAVLBinaryTreeNode;
begin
  result:='';
  form1.pb2.show;
  with TALInt64KeyAVLBinaryTree.create do begin
    form1.pb2.Max:=prj.node.Count*100;
    se:='.'+cLangs[GetCode(prj.sLang)].ext;
    for i:=0 to prj.node.Count-1 do begin
      if abort then break;
      pa:=prj.node.Item[i].Text;
      form1.sb1.Panels[2].Text:=pa;
      if (not FileExists(prj.pPath+'\'+pa+se)) then continue;
      with TWorker.create(prj.pPath+'\'+pa+se) do begin
        repeat
          r:=gather(ss);
          if r mod 10=0  then begin
            form1.pb2.Position:=(i+1)*100+r;
            application.ProcessMessages;
          end;
          nde:=TALInt64KeyAVLBinaryTreeNode.Create;
          nde.id:=wHash(ss);
          res := AddNode(nde);
          if res=nde then result:=result+ss+' ' else nde.free;
        until (r<0) or abort;
        done;
      end;
    end;
    Free;
  end;
  form1.pb2.hide;
end;

// ----------------------------------
procedure shrinkage(prj : PRec);
var   i,r : integer;
 se,te,pa : string;
    ss,ts : widestring;
    c1,c2 : UInt64;
  nde,res : TALInt64KeyAVLBinaryTreeNode;
begin
  form1.pb2.show;
  prj.swl.Clear;    prj.twl.Clear;
  with TALInt64KeyAVLBinaryTree.create do begin
    form1.pb2.Max:=prj.node.Count*100;
    se:='.'+cLangs[GetCode(prj.sLang)].ext;  te:='.'+cLangs[GetCode(prj.tLang)].ext;
    for i:=0 to prj.node.Count-1 do begin
      if abort then break;
      pa:=prj.node.Item[i].Text;
      form1.sb1.Panels[2].Text:=pa;
      if (not FileExists(prj.pPath+'\'+pa+se)) or (not FileExists(prj.pPath+'\'+pa+te)) then continue;
      with TWorker.create(prj.pPath+'\'+pa+se,prj.pPath+'\'+pa+te) do begin
        repeat
          r:=Fetch(ss,ts);
          if r mod 10=0  then begin
            form1.pb2.Position:=(i+1)*100+r;
            application.ProcessMessages;
          end;
          if (ss='') or (ts='') or (ss=ts) then continue;
          c1:=wHash(ss);  c2:=wHash(ts);
          nde:=TALInt64KeyAVLBinaryTreeNode.Create;
          nde.id:=c1 shl 32 or c2;
          res := AddNode(nde);
          if res=nde then begin
            prj.swl.AddObject(ss,pointer(c1));
            prj.twl.AddObject(ts,pointer(c2));
          end else nde.free;
        until (r<0) or abort;
        done;
      end;
    end;
    Free;
  end;
  form1.pb2.hide;
  if prj.swl.Count<>prj.twl.Count then Log('Unsync.'+prj.pPath+'\'+pa+se);
end;

// ----------------------------------
procedure saveToRef(prj : PRec;dst : string);
var i : integer;
    tfile : string;
    sStr,tStr : TStreamWriter;
begin
  if (prj.swl.Count=0) or (prj.twl.Count=0) then exit;

  if dst='' then begin
    case TTreeView(form1.Tag).Tag of
      1 : tfile := cr_refs;
     -1 : tfile := cl_refs;
    end
  end else
    tfile := dst;

  tfile:=tfile+'\'+prj.pCust+'\'+leftstr(cLangs[GetCode(prj.sLang)].LongID,2)+'-'+
                                 leftstr(cLangs[GetCode(prj.tLang)].LongID,2)+'\'+
                                 FormatDateTime('YYYYMMDD',prj.pDT)+'-'+prj.pTitle;

  form1.sb1.Panels[2].Text:=extractfilename(tfile);

  if not ForceDirectories(extractfilepath(tfile)) then begin
    Log('Reference extract error, invalid path '+tfile);
    exit;
  end;

  sStr:=TStreamWriter.Create(tfile+'.'+cLangs[GetCode(prj.sLang)].ext, false, TEncoding.Unicode);
  tStr:=TStreamWriter.Create(tfile+'.'+cLangs[GetCode(prj.tLang)].ext, false, TEncoding.Unicode);

  sStr.Write(pheader);      tStr.Write(pheader);

  form1.pb2.Max:=prj.swl.Count;
  form1.pb2.show;

  for i:=0 to prj.swl.Count-1 do begin
    if abort then Break;
    if i mod 50=0 then begin
      form1.pb2.Position:=i+1;
      application.ProcessMessages;
    end;

    sStr.Write(psegstart+prj.swl.Strings[i]+psegend);
    tStr.Write(psegstart+prj.twl.Strings[i]+psegend);
  end;

  sStr.Write(psegstart+psegend+ptail);    sStr.Close;
  tStr.Write(psegstart+psegend+ptail);    tStr.Close;

  form1.pb2.hide;
end;


// ----------------------------------
procedure saveToSQL(prj : PRec);
var    myQ : TuniQuery;
       myS : TuniSql;
  i,lastid : integer;
     c1,c2 : UInt64;
begin

  myQ:=TUniQuery.Create(nil);  myQ.Connection:=form1.Ucon;
  myS:=TUniSQL.Create(nil);    myS.Connection:=form1.Ucon;

  myQ.SQL.Text:='INSERT INTO transit.tmx (CRC,PID,SRC,DST,TS) VALUES (:CRC,:PID,:SRC,:DST,:TS)';
  myQ.Params[0].DataType := ftLargeInt;     myQ.Params[1].DataType := ftInteger;
  myQ.Params[2].DataType := ftWideString;   myQ.Params[3].DataType := ftWideString;
  myQ.Params[4].DataType := ftDateTime;

  myS.SQL.Text :='INSERT INTO transit.projects (CUST,PROJ,TS,SLCD,DLCD) VALUES (:CUST,:PROJ,:TS,:SLCD,:DLCD)';
  myS.ParamByName('CUST').AsWideString := prj.pCust;  myS.ParamByName('PROJ').AsWideString := prj.pTitle;
  myS.ParamByName('TS').AsDateTime     := prj.pDT;    myS.ParamByName('SLCD').AsInteger    := prj.sLang;
  myS.ParamByName('DLCD').AsInteger    := prj.tLang;
  form1.pb2.show;
  try
    myS.Execute;
    lastid:=myS.LastInsertId;

    form1.pb2.Max:=prj.swl.Count;


    myQ.Params.ValueCount := prj.swl.Count;

    for i:=0 to prj.swl.Count-1 do begin
      if i mod 50=0 then begin
        form1.pb2.Position:=i+1;
        application.ProcessMessages;
      end;

      c1:=Uint64(prj.swl.objects[i]);       c2:=Uint64(prj.twl.objects[i]);

      myQ.Params[0][i].AsLargeInt   := (c1 shl 32) or c2;
      myQ.Params[1][i].AsInteger    := lastid;
      myQ.Params[2][i].AsWideString := leftstr(prj.swl.Strings[i],_maxsnl);
      myQ.Params[3][i].AsWideString := leftstr(prj.twl.Strings[i],_maxsnl);
      myQ.Params[4][i].AsDateTime   := prj.pDT;
    end;

    if i>0 then myQ.Execute(prj.swl.Count);
  except
     on E : exception do ;//Log('saveToSQL.'+e.message);
  end;
  form1.pb2.hide;
  myQ.Free; myS.Free
end;


end.
