unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uAquos;

type
  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    FAquos: TAquosConnection;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.Button1Click(Sender: TObject);
begin
    if FAquos.Volume = C_UNKNOWNVAR then
    begin
        FAquos.ChangeVolume( 0 );
    end;

    FAquos.ChangeVolume( FAquos.Volume + 1 );
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
    if FAquos.Volume = C_UNKNOWNVAR then
    begin
        FAquos.ChangeVolume( 0 );
    end;

    FAquos.ChangeVolume( FAquos.Volume - 1 );
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
    FAquos.SetTextPage( 101 );
end;

procedure TfrmMain.Button4Click(Sender: TObject);
begin
    FAquos.SetTextPageOff;
end;

procedure TfrmMain.Button5Click(Sender: TObject);
begin
    if not FAquos.TurnOff then
    begin
        ShowMessage( 'Can''t turn off the tv' );
    end
    else
    begin
        Application.Terminate;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    FAquos := TAquosConnection.Create( 3 );

    if not FAquos.IsConnected then
    begin
        ShowMessage( 'Can''t connect to tv' );
        Application.Terminate;
    end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
    FAquos.Free;
end;

end.
