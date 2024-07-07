program RetroBox;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainWindow, boxtype, PrefsWindow;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='86Box Manager';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TRetroBoxForm, RetroBoxForm);
  Application.CreateForm(TPrefsForm, PrefsForm);
  Application.Run;
end.

