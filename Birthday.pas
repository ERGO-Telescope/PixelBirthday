unit Birthday;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Registry, AbNumEdit, Grids, DBGrids, DB, MemDS,
  DBAccess, MyAccess, ExtCtrls, DBCtrls, _GClass, AbLED, JvExComCtrls, JvUpDown,
  Mask, JvExMask, JvSpin, pngimage, Menus, OleCtrls, SHDocVw, ShellAPI, inifiles;

const
  PixelBirthdayKey = '\SOFTWARE\ERGO\Utilities\PixelBirthday';

type
  TfrmBirthday = class(TForm)
    dsPixels: TDataSource;
    quPixels: TMyQuery;
    conDB: TMyConnection;
    gbControls: TGroupBox;
    btnConnect: TButton;
    gbMAC: TGroupBox;
    btnGenerateRandom: TButton;
    gbTypes: TGroupBox;
    lblPixelType: TLabel;
    lblShieldType: TLabel;
    gbCreateWrite: TGroupBox;
    btnCreateBirthCert: TButton;
    btnWriteToSD: TButton;
    gbDatabase: TGroupBox;
    navPixels: TDBNavigator;
    pcBirthdaySetup: TPageControl;
    tsDatabase: TTabSheet;
    tsPixels: TTabSheet;
    DBNavigator1: TDBNavigator;
    gridPixels: TDBGrid;
    lblNoMAC: TLabel;
    btnClose: TButton;
    Image1: TImage;
    dlgFileSave: TFileSaveDialog;
    menuMain: TMainMenu;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    seMAC6: TAbNumSpin;
    seMAC5: TAbNumSpin;
    seMAC4: TAbNumSpin;
    seMAC3: TAbNumSpin;
    seMAC2: TAbNumSpin;
    seMAC1: TAbNumSpin;
    gbDirectAccess: TGroupBox;
    edPassword: TEdit;
    lblPassword: TLabel;
    lblDatabase: TLabel;
    edDatabase: TEdit;
    edUser: TEdit;
    lblUser: TLabel;
    lblPort: TLabel;
    nePort: TAbNumEdit;
    edHost: TEdit;
    lblHost: TLabel;
    gbPixelPostWebSite: TGroupBox;
    edURL: TEdit;
    btnCheckWebSite: TButton;
    lblPostToWebSite: TLabel;
    mnuHints: TMenuItem;
    sbStatus: TStatusBar;
    lblNavigation: TLabel;
    edNote: TEdit;
    cbPixelType: TComboBox;
    lblNote: TLabel;
    cbShieldType: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConnectClick(Sender: TObject);
    procedure conDBAfterConnect(Sender: TObject);
    procedure conDBAfterDisconnect(Sender: TObject);
    procedure btnCreateBirthCertClick(Sender: TObject);
    procedure btnCheckWebSiteClick(Sender: TObject);
    procedure btnGenerateRandomClick(Sender: TObject);
    procedure gridPixelsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);

    procedure btnWriteToSDClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuHintsClick(Sender: TObject);
    procedure dsPixelsDataChange(Sender: TObject; Field: TField);
    function SpinnersToMAC: String;
    procedure seMAC1Change(Sender: TObject);
  private
    { Private declarations }

    ERGoReg: TRegistry;
    Host: String;
    Port: Integer;
    User: String;
    Password: String;
    Database: String;
    strMAC: string;
    function HexToDec(Str: string): Integer;
    function PasswordGen(stringsize: Integer): string;
    function ExtendedToStr(extend: extended): string;
    procedure DisplayHint(Sender: TObject);
    procedure FillMAC;

  public
    { Public declarations }

  end;

var
  frmBirthday: TfrmBirthday;

implementation

uses uAbout;

{$R *.dfm}
(* C r e a t e   F o r m *)

procedure TfrmBirthday.FormCreate(Sender: TObject);
var
  appINI: TiniFile;
  LastUser: string;
  LastDate: TDateTime;
  strPixelType: string;
  strShieldType: string;
  i: Integer;
begin
  (* REGISTRY ENTRIES *)
  ERGoReg := TRegistry.Create;
  ERGoReg.LazyWrite := False;
  try
    ERGoReg.RootKey := HKEY_CURRENT_User;
    if ERGoReg.KeyExists(PixelBirthdayKey) then
    begin // Key Exists
      if ERGoReg.OpenKey(PixelBirthdayKey, False) then
      // OpenKey will create the key if the second parameter is TRUE and the key does not already exist
      // This one will NOT create the key
      begin // N O R M A L   R E G   E N T R I E S
        try // open key
          with ERGoReg do
          begin // Setup the GUI here - All of it
            edHost.Text := ReadString('Host');
            nePort.value := ReadInteger('Port');
            edUser.Text := ReadString('User');
            edPassword.Text := ReadString('Password');
            edDatabase.Text := ReadString('Database');
            edURL.Text := ReadString('PostToWebSite');

          end // with SETINetReg
        except // an exception is raised if there isn't an   entry
          ShowMessage('An Exception so deleating the whole key');
          ERGoReg.DeleteKey(PixelBirthdayKey);
          // If the version value didn't exist delete the whole key
        end; // Open Key
      end; // Open key
    end; // SETINetExamplekey exists

    if not ERGoReg.KeyExists(PixelBirthdayKey) then
    // D E F A U L T   R E G   E N T R I E S
    begin // New User or incomplete registry entries so rebuild.
      with ERGoReg do
      begin
        OpenKey(PixelBirthdayKey, True);
        // OpenKey will create the key if the second parameter is true and the key does not already exist
        ShowMessage('Doing Default setup setup');
        edHost.Text := '<www.server.com>';
        nePort.value := 3306;
        edUser.Text := '<UserName>';
        edPassword.Text := '<Password>';
        edDatabase.Text := '<Database>';
        edURL.Text := '<Post to web site>';
      end;
    end; // Key exists
  finally // Setup Example
    ERGoReg.Free;
  end; // Finished with Reg
  pcBirthdaySetup.ActivePage := tsDatabase;
  // Assign the application’s OnHint event handler at runtime because the Application is not available in the Object Inspector at design time
  Application.OnHint := DisplayHint;

  strPixelType := 'xxx';
  appINI := TiniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  i := 1;
  begin
    try
      while (strPixelType <> '') do
      begin
        strPixelType := appINI.ReadString('PixelType', IntToStr(i), ''); // Read one entry
        cbPixelType.AddItem(strPixelType, nil);
        i := i + 1;
      end;
      i := 1;
      strShieldType := 'xxx';
      while (strShieldType <> '') do
      begin
        strShieldType := appINI.ReadString('ShieldType', IntToStr(i), ''); // Read one entry
        cbShieldType.AddItem(strShieldType, nil);
        i := i + 1;
      end;
    finally
      appINI.Free;
    end;
  end;
end;

procedure TfrmBirthday.FillMAC;
var
  strMAC: string;
  Hexers: string;
begin

  with gridPixels do
  begin
    if (Columns[0].Field.value <> null) then
    begin
      strMAC := Columns[0].Field.value;
      seMAC6.ValueAsHex := Copy(strMAC, 1, 2);
      seMAC5.ValueAsHex := Copy(strMAC, 4, 2);
      seMAC4.ValueAsHex := Copy(strMAC, 7, 2);
      seMAC3.ValueAsHex := Copy(strMAC, 10, 2);
      seMAC2.ValueAsHex := Copy(strMAC, 13, 2);
      seMAC1.ValueAsHex := Copy(strMAC, 16, 2);
    end;
    if (Columns[1].Field.value <> null) then
    begin
      cbPixelType.Text := Columns[1].Field.value;
    end;
    if (Columns[2].Field.value <> null) then
    begin
      cbShieldType.Text := Columns[2].Field.value;
    end;
    if (Columns[5].Field.value <> null) then
    begin
      edNote.Text := Columns[5].Field.value;
    end;

  end;

end;

procedure TfrmBirthday.DisplayHint(Sender: TObject);
begin
  sbStatus.Panels[0].Text := GetLongHint(Application.Hint);
end;

procedure TfrmBirthday.dsPixelsDataChange(Sender: TObject; Field: TField);
begin
  FillMAC;
end;

procedure TfrmBirthday.gridPixelsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);

var
  grid: TDBGrid;
  row: Integer;
begin

  grid := Sender as TDBGrid;
  row := grid.DataSource.DataSet.RecNo;
  if odd(row) then
    grid.Canvas.Brush.Color := clWhite
  else
    grid.Canvas.Brush.Color := clCream;
  grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);

end;

procedure TfrmBirthday.btnCloseClick(Sender: TObject);
begin
  conDB.Connected := False;
  // close;
end;

procedure TfrmBirthday.btnConnectClick(Sender: TObject);
begin
  if not conDB.Connected then
  begin
    conDB.Server := edHost.Text;
    conDB.Port := nePort.ValueAsInt;
    conDB.Username := edUser.Text;
    conDB.Database := edDatabase.Text;
    conDB.Password := edPassword.Text;
    conDB.Connected := True;
    quPixels.Active := True;
    pcBirthdaySetup.ActivePage := tsPixels;
  end
  else
  begin
    conDB.Connected := False;
    pcBirthdaySetup.ActivePage := tsDatabase;
  end;

end;

function TfrmBirthday.PasswordGen(stringsize: Integer): string;
const
  ss: string = '0123456789ABCDEF';
var
  n: Integer;
  s: string;
begin
  s := '';
  for n := 1 to stringsize do
    s := s + ss[random(length(ss)) + 1];
  result := s;
end;

procedure TfrmBirthday.seMAC1Change(Sender: TObject);
begin
  btnCreateBirthCert.Enabled := True;
end;

function TfrmBirthday.HexToDec(Str: string): Integer;
var
  i, M: Integer;
begin
  result := 0;
  M := 1;
  Str := AnsiUpperCase(Str);
  for i := length(Str) downto 1 do
  begin
    case Str[i] of
      '1' .. '9':
        result := result + (Ord(Str[i]) - Ord('0')) * M;
      'A' .. 'F':
        result := result + (Ord(Str[i]) - Ord('A') + 10) * M;
    end;
    M := M shl 4;
  end;
end;

procedure TfrmBirthday.mnuAboutClick(Sender: TObject);
begin
  frmAbout.ShowVersion;
end;

procedure TfrmBirthday.mnuHintsClick(Sender: TObject);
begin
  if mnuHints.Checked then
  begin
    frmBirthday.ShowHint := mnuHints.Checked;
    pcBirthdaySetup.ShowHint := mnuHints.Checked;
    gbControls.ShowHint := mnuHints.Checked;
  end
  else
  begin
    // sbStatus.Panels[1].Text := 'Hints are off...';
  end;
end;

procedure TfrmBirthday.btnGenerateRandomClick(Sender: TObject);

begin
  edNote.Text := ''; // Clear the note field
  cbPixelType.ItemIndex := -1;
  cbPixelType.Text := '<select Pixel Type>';
  cbShieldType.ItemIndex := -1;
  cbShieldType.Text := '<select Shield Type>';
  // 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED
  seMAC1.value := random(256);

  // if seMAC1.ValueAsInt < seMAC1.Text := '0' + seMAC1.ValueAsHex;

  seMAC2.value := random(256);
  seMAC3.value := random(256);
  seMAC4.ValueAsHex := '89';
  seMAC5.ValueAsHex := '2F';
  seMAC6.ValueAsHex := '54';

  seMAC1Change(Sender);
end;

function TfrmBirthday.SpinnersToMAC: String;

var
  buttonSelected: Integer;
begin
  // FillMAC;
  if (seMAC3.value > 16) then
    strMAC := strMAC + seMAC3.Text
  else
  begin
    strMAC := strMAC + '0' + seMAC3.Text;
    seMAC3.Text := '0' + seMAC3.ValueAsHex;
  end;
  strMAC := strMAC + '-';

  if (seMAC2.value > 16) then
  begin
    strMAC := strMAC + seMAC2.Text;
  end
  else
  begin
    strMAC := strMAC + '0' + seMAC2.Text;
    seMAC2.Text := '0' + seMAC2.ValueAsHex;
  end;
  strMAC := strMAC + '-';

  if (seMAC1.value > 16) then
  begin
    strMAC := strMAC + seMAC1.Text;
    seMAC1.Text := '0' + seMAC1.ValueAsHex;
  end
  else
  begin
    strMAC := strMAC + '0' + seMAC1.Text;
    seMAC1.Text := '0' + seMAC1.ValueAsHex;
  end;

  result := strMAC;
end;

procedure TfrmBirthday.btnCreateBirthCertClick(Sender: TObject);
var
  buttonSelected: Integer;
begin
   sbStatus.Panels[1].Text :='';
  btnCreateBirthCert.Enabled := False;
  // FillMAC;
  strMAC := '54';
  strMAC := strMAC + '-';
  strMAC := strMAC + '2F';
  strMAC := strMAC + '-';
  strMAC := strMAC + '89';
  strMAC := strMAC + '-';

  if (seMAC3.value > 9) then
    strMAC := strMAC + seMAC3.Text
  else
    strMAC := strMAC + '0' + seMAC3.Text;
  strMAC := strMAC + '-';

  if (seMAC2.value > 9) then
    strMAC := strMAC + seMAC2.Text
  else
    strMAC := strMAC + '0' + seMAC2.Text;
  strMAC := strMAC + '-';

  if (seMAC1.value > 9) then
    strMAC := strMAC + seMAC1.Text
  else
    strMAC := strMAC + '0' + seMAC1.Text;

  // try

  if not conDB.Connected then
  begin
    conDB.Server := edHost.Text;
    conDB.Port := nePort.ValueAsInt;
    conDB.Username := edUser.Text;
    conDB.Database := edDatabase.Text;
    conDB.Password := edPassword.Text;
    conDB.Connected := True;
    quPixels.Active := True;
    // pcBirthdaySetup.ActivePage := tsPixels;
  end;
  try
    with quPixels do
    begin
      insert;

      FieldByName('birthday').AsDatetime := now;
      FieldByName('mac').AsString := strMAC;
      FieldByName('pixelType').AsString := cbPixelType.Text;
      FieldByName('shieldType').AsString := cbShieldType.Text;
      FieldByName('note').AsString := edNote.Text;
      Post;
      Sleep(1000); // Wait for the connection to complete
    end;
  Except
   sbStatus.Panels[1].Text :='Duplicate entry. Please try again.';
     quPixels.Delete;
  end;
end;

procedure TfrmBirthday.btnCheckWebSiteClick(Sender: TObject);
var
  strURLCheck: string;

begin
  strURLCheck := 'http://' + edURL.Text + '/php/getStatus.htm';
  ShellExecute(0, 'OPEN', PChar(strURLCheck), '', '', SW_SHOWNORMAL);
end;

procedure TfrmBirthday.btnWriteToSDClick(Sender: TObject);
var
  myFile: TextFile;
  Text: string;
  mac: string;
  Pixel_ID: Integer;
  i: Integer;
begin

  dlgFileSave.FileName := 'cert.ini';
  If dlgFileSave.Execute then
  begin

    AssignFile(myFile, dlgFileSave.FileName);
    ReWrite(myFile);
    Write(myFile, ';   This cert was generated by Happy Birthday Pixel on:');
    WriteLn(myFile, DateTimeToStr(now));
    WriteLn(myFile, '[network]');
    WriteLn(myFile, 'host = ' + edHost.Text);
    WriteLn(myFile, 'port = ' + IntToStr(nePort.ValueAsInt));
    WriteLn(myFile, 'User = ' + edUser.Text);
    WriteLn(myFile, 'Database = ' + edDatabase.Text);
    WriteLn(myFile, 'password = ' + edPassword.Text);

    WriteLn(myFile, '[Pixel]');
    WriteLn(myFile, 'PostWebSite = ', 'http://' + edURL.Text);
    WriteLn(myFile, 'mac = ', SpinnersToMAC);
    WriteLn(myFile, 'mac0 = ', seMAC6.ValueAsInt);
    WriteLn(myFile, 'mac1 = ', seMAC5.ValueAsInt);
    WriteLn(myFile, 'mac2 = ', seMAC4.ValueAsInt);
    WriteLn(myFile, 'mac3 = ', seMAC3.ValueAsInt);
    WriteLn(myFile, 'mac4 = ', seMAC2.ValueAsInt);
    WriteLn(myFile, 'mac5 = ', seMAC1.ValueAsInt);

    WriteLn(myFile, 'pixelType =' + quPixels.FieldByName('pixeltype').AsString);
    WriteLn(myFile, 'shieldType =' + quPixels.FieldByName('shieldType').AsString);
    WriteLn(myFile, 'note =' + edNote.Text);

    Reset(myFile);

    // while not Eof(myFile) do
    // begin
    // ReadLn(myFile, Text);
    // ShowMessage(Text);
    // end;
    CloseFile(myFile);
  end;

end;

function TfrmBirthday.ExtendedToStr(extend: extended): string;
begin
  result := IntToHex(strToInt(FloatToStr(extend)), 2)
end;

procedure TfrmBirthday.conDBAfterConnect(Sender: TObject);
begin
  btnConnect.Caption := 'Connected';
  gbMAC.Enabled := True;
  gbTypes.Enabled := True;
  gbCreateWrite.Enabled := True;
  btnClose.Enabled := True;
  navPixels.Enabled := True;
  dsPixels.Edit;
end;

procedure TfrmBirthday.conDBAfterDisconnect(Sender: TObject);
begin
  btnConnect.Caption := 'Disconnected';
  gbMAC.Enabled := False;
  gbTypes.Enabled := False;
  gbCreateWrite.Enabled := False;
  btnClose.Enabled := False;
end;

(* C l o s e   F o r m *)
procedure TfrmBirthday.FormClose(Sender: TObject; var Action: TCloseAction);

begin
  conDB.Connected := False;
  ERGoReg := TRegistry.Create; // S A V E  R E G   E N T R I E S
  try
    with ERGoReg do
    begin
      RootKey := HKEY_CURRENT_User;
      DeleteKey(PixelBirthdayKey);
      // Kill the whole key every time.
      OpenKey(PixelBirthdayKey, True); // Then write it back
      // OpenKey will create the key if the second parameter is true and the key does not already exist
      WriteString('Host', edHost.Text);
      WriteInteger('Port', nePort.ValueAsInt);
      WriteString('User', edUser.Text);
      WriteString('Password', edPassword.Text);
      WriteString('Database', edDatabase.Text);
      WriteString('PostToWebSite', edURL.Text);
      CloseKey;
    end; // SETINetReg
  finally
    ERGoReg.Free;
  end; // try..finally
end;

end.
