unit uRS232;

interface

uses
    classes;

type
    TRS232Parity = ( rspNone, rspEven, rspOdd );

    { TRS232 }
    TRS232 = class(TObject)
    protected
        FPort: integer;
        FBaudrate: integer;
        FDatabits: integer;
        FStopbits: integer;
        FParity: TRS232Parity;

        FCommFile: THandle;

        function GetCommStr: string;
    public
        constructor Create( iPort: integer; iBaudrate: integer = 9600; iDatabits: integer = 8; iStopbits: integer = 1; aParity: TRS232Parity = rspNone );
        destructor Destroy; override;

        function IsConnected: boolean;

        function Open: boolean;
        procedure Close;
        function Read: string;
        function Write( const s: string ): boolean;
    end;

implementation

uses
    Windows, Math, SysUtils;

{ TRS232 }

constructor TRS232.Create( iPort: integer; iBaudrate: integer; iDatabits: integer; iStopbits: integer; aParity: TRS232Parity );
begin
    FCommFile := INVALID_HANDLE_VALUE;

    FPort     := iPort;
    FBaudrate := iBaudrate;
    FDatabits := iDatabits;
    FStopbits := iStopbits;
    FParity   := aParity;
end;

destructor TRS232.Destroy;
begin
    Close;

    inherited;
end;

function TRS232.GetCommStr: string;
var
    cParity: char;
begin
    cParity := 'N';
    case FParity of
        rspNone:   cParity := 'N';
        rspEven:   cParity := 'E';
        rspOdd:    cParity := 'O';
    end;

    Result := IntToStr( FBaudrate ) + ',' + cParity + ',' + IntToStr( FDataBits ) + ',' + IntToStr( FStopbits );
end;

function TRS232.IsConnected: boolean;
begin
    Result := (FCommFile <> INVALID_HANDLE_VALUE);
end;

function TRS232.Open: Boolean;
var
    tCfg     : TCommConfig;
    tTimeout : TCommTimeouts;
    nSize    : Cardinal;
begin
    Result := False;

    FCommFile := CreateFile( PChar('COM' + IntToStr(FPort)), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 );
    if FCommFile <> INVALID_HANDLE_VALUE then
    begin
        nSize := sizeof( tCfg );
        if GetCommConfig( FCommFile, tCfg, nSize ) then
        begin
            if BuildCommDCB( PChar( GetCommStr ), tCfg.dcb ) then
            begin
                if SetCommConfig( FCommFile, tCfg, nSize ) then
                begin
                    tTimeout.ReadIntervalTimeout         := MAXDWORD;
                    tTimeout.ReadTotalTimeoutMultiplier  := 0;
                    tTimeout.ReadTotalTimeoutConstant    := 0;
                    tTimeout.WriteTotalTimeoutMultiplier := 0;
                    tTimeout.WriteTotalTimeoutConstant   := 0;

                    if SetCommTimeouts( FCommFile, tTimeout ) then
                    begin
                        Result := True;
                    end;
                end;
            end;
        end;
    end;

    if not Result then
    begin
        Close;
    end;
end;

procedure TRS232.Close;
begin
    if FCommFile <> INVALID_HANDLE_VALUE then
    begin
        CloseHandle( FCommFile );

        FCommFile := INVALID_HANDLE_VALUE;
    end;
end;

function TRS232.Read: String;
var
   pBuffer: array[0..1024] of byte;
   dwRead:  DWord;
   i:       integer;
begin
    Result := '';
    dwRead := 0;

    ReadFile( FCommFile, pBuffer, 1024, dwRead, nil );
    while dwRead <> 0 do
    begin
        for i := 0 to Integer( dwRead ) - 1 do
        begin
            Result := Result + Char(pBuffer[i]);
        end;

        ReadFile( FCommFile, pBuffer, 1024, dwRead, nil );
    end;
end;

function TRS232.Write(const s: String): Boolean;
var
    dwWritten: DWord;
    iLen: DWord;
    pArrStr: array[0..1024] of byte;
    iTotalLen: DWord;
    i: DWord;
    iBytesDone: DWord;
begin
    iTotalLen := Length(s);
    pArrStr[1024] := 0;

    iBytesDone := 0;
    iLen := Min( iTotalLen, 1024 );
    while iLen > 0 do
    begin
        for i := 0 to iLen - 1 do
        begin
          pArrStr[i] := byte(s[1+iBytesDone+i]);
        end;
        pArrStr[iLen] := 0;

        dwWritten := 0;
        WriteFile( FCommFile, pArrStr, iLen, dwWritten, nil );

        if dwWritten <> iLen then
        begin
          Result := False;
          Exit;
        end;

        iBytesDone := iBytesDone + dwWritten;
        iLen := Min( iTotalLen - iBytesDone, 1024 );
    end;

    Result := true;
end;

end.
