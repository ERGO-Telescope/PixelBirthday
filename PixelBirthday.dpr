program PixelBirthday;

uses
  Forms,
  Birthday in 'Birthday.pas' {frmBirthday},
  uAbout in '..\About\uAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBirthday, frmBirthday);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
