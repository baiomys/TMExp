program TMExplorer;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas',
  scan in 'scan.pas',
  CosineSim in 'CosineSim.pas',
  ALAVLBinaryTree in 'ALAVLBinaryTree.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
