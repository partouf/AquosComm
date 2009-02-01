program AquosComm;

uses
  Forms,
  fMain in 'fMain.pas' {frmMain},
  uAquos in 'uAquos.pas',
  uRS232 in 'uRS232.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
