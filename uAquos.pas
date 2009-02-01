unit uAquos;

interface

uses
    uRS232;

type
    TInputAType = ( iaUnknown,
                    iaTV, iaDTV,
                    iaExt1, iaExt2, iaExt3, iaExt4, iaExt5, iaExt6, iaExt7 );
    TInputBType = ( ibUnknown = 0,
                    ibExt1YC = 10, ibExt1CVBS = 11, ibExt1RGB = 12,
                    ibExt2YC = 20, ibExt2CVBS = 21, ibExt2RGB = 22,
                    ibExt3 = 30,
                    ibExt4 = 40,
                    ibExt5 = 50,
                    ibExt6 = 60,
                    ibExt7 = 70 );

    { TAquosConnection }
    TAquosConnection = class(TObject)
    protected
        FRS232: TRS232;

        FCurrentTVChannel: integer;
        FCurrentDTVChannel: integer;
        FCurrentVolume: integer;

        FIsTextmode: boolean;
        FCurrentTextPage: integer;

        FCurrentInputA: TInputAType;
        FCurrentInputB: TInputBType;

        function WaitForResponse: string;
        function IsOk( const s: string ): boolean;

        procedure SendCmd( const s: string );
    public
        property InputA: TInputAType
            read FCurrentInputA;
        property InputB: TInputBType
            read FCurrentInputB;
        property TVChannel: integer
            read FCurrentTVChannel;
        property DTVChannel: integer
            read FCurrentDTVChannel;
        property Volume: integer
            read FCurrentVolume;
        property TextPage: integer
            read FCurrentTextPage;
        property IsTextmode: boolean
            read FIsTextmode;

        constructor Create( iPort: integer );
        destructor Destroy; override;

        function IsConnected: boolean;

        function TurnOff: boolean;
        function ChangeTVChannel( iChannel: integer ): boolean;
        function ChangeDTVChannel( iChannel: integer ): boolean;
        function ChangeVolume( iVolume: integer ): boolean;

        function SetInputTV: boolean;
        function SetInputDTV: boolean;
        function SetInputExt( iExtIndex: integer ): boolean;

        function ChangeInputB( anInput: TInputBType ): boolean;

        function SetTextPage( iPage: integer ): boolean;
        function SetTextPageOn: boolean;
        function SetTextPageOff: boolean;
    end;

const
    C_UNKNOWNVAR = -1;

implementation

uses
    SysUtils, StrUtils;


{ TAquosConnection }

function TAquosConnection.ChangeDTVChannel(iChannel: integer): boolean;
begin
    SendCmd( 'DTVD' + IntToStr(iChannel) );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentDTVChannel  := iChannel;
    end;
end;

function TAquosConnection.ChangeInputB(anInput: TInputBType): boolean;
begin
    SendCmd( 'INP' + IntToStr(Ord(anInput)) );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentInputB  := anInput;
    end;
end;

function TAquosConnection.ChangeTVChannel(iChannel: integer): boolean;
begin
    SendCmd( 'DCCH' + IntToStr(iChannel) );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentTVChannel  := iChannel;
    end;
end;

function TAquosConnection.ChangeVolume(iVolume: integer): boolean;
begin
    SendCmd( 'VOLM' + IntToStr(iVolume) );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentVolume  := iVolume;
    end;
end;

constructor TAquosConnection.Create( iPort: integer );
begin
    FRS232 := TRS232.Create( iPort );

    FCurrentTVChannel   := C_UNKNOWNVAR;
    FCurrentDTVChannel  := C_UNKNOWNVAR;
    FCurrentVolume      := C_UNKNOWNVAR;
    FIsTextmode         := False;
    FCurrentTextPage    := C_UNKNOWNVAR;
    FCurrentInputA      := iaUnknown;
    FCurrentInputB      := ibUnknown;

    FRS232.Open;
end;

destructor TAquosConnection.Destroy;
begin
    FRS232.Free;

    inherited;
end;

function TAquosConnection.IsConnected: boolean;
begin
    Result := FRS232.IsConnected;
end;

function TAquosConnection.IsOk(const s: string): boolean;
var
    s2: string;
begin
    s2 := Trim( s );
    Result := SameText( 'OK', s2 );
end;

procedure TAquosConnection.SendCmd(const s: string);
begin
    // the spaces aren't really needed, but we'll humor the manual
    FRS232.Write( s + StringOfChar(' ', 8 - Length(s)) + #$0D )
end;

function TAquosConnection.SetInputDTV: boolean;
begin
    SendCmd( 'IDTV' );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentInputA      := iaDTV;
        FCurrentInputB      := ibUnknown;
        FCurrentTVChannel   := C_UNKNOWNVAR;
        FCurrentDTVChannel  := C_UNKNOWNVAR;
    end;
end;

function TAquosConnection.SetInputExt(iExtIndex: integer): boolean;
begin
    SendCmd( 'IAVD' + IntToStr(iExtIndex) );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentInputA      := TInputAType( Ord(iaExt1) + (iExtIndex - 1) );
        FCurrentInputB      := ibUnknown;
        FCurrentTVChannel   := C_UNKNOWNVAR;
        FCurrentDTVChannel  := C_UNKNOWNVAR;
    end;
end;

function TAquosConnection.SetInputTV: boolean;
begin
    SendCmd( 'ITVD' );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FCurrentInputA      := iaDTV;
        FCurrentInputB      := ibUnknown;
        FCurrentTVChannel   := C_UNKNOWNVAR;
        FCurrentDTVChannel  := C_UNKNOWNVAR;
    end;
end;

function TAquosConnection.SetTextPage(iPage: integer): boolean;
begin
    Result := False;
    if not FIsTextmode then
    begin
        SetTextPageOn;
    end;

    if FIsTextmode then
    begin
        SendCmd( 'DCPG' + IntToStr(iPage) );

        Result := IsOk( WaitForResponse );
        if Result then
        begin
            FCurrentTextPage    := iPage;
        end;
    end;
end;

function TAquosConnection.SetTextPageOff: boolean;
begin
    SendCmd( 'TEXT0' );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FIsTextmode       := False;
        FCurrentTextPage  := C_UNKNOWNVAR;
    end;
end;

function TAquosConnection.SetTextPageOn: boolean;
begin
    SendCmd( 'TEXT1' );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        FIsTextmode       := True;
        FCurrentTextPage  := C_UNKNOWNVAR;
    end;
end;

function TAquosConnection.TurnOff: boolean;
begin
    SendCmd( 'POWR0' );

    Result := IsOk( WaitForResponse );
    if Result then
    begin
        // you can't switch the tv on anymore now
    end;
end;

function TAquosConnection.WaitForResponse: string;
begin
    Result := '';

    Result := Result + FRS232.Read;
    while Pos( #$0D, Result ) <= 0 do
    begin
        Result := Result + FRS232.Read;
    end;
end;



end.
