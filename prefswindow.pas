unit PrefsWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, XMLPropStorage,
  StdCtrls, EditBtn, Buttons;

type

  { TPrefsForm }

  TPrefsForm = class(TForm)
    BasePath: TDirectoryEdit;
    TermOnClose: TCheckBox;
    EmulatorPath: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    CategoryList: TListBox;
    AddCategoryBtn: TSpeedButton;
    DelCategoryBtn: TSpeedButton;
    EditCategoryBtn: TSpeedButton;
    Label3: TLabel;
    XMLPropStorage: TXMLPropStorage;
    procedure AddCategoryBtnClick(Sender: TObject);
    procedure DelCategoryBtnClick(Sender: TObject);
    procedure EditCategoryBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  PrefsForm: TPrefsForm;

implementation

{$R *.lfm}

{ TPrefsForm }

procedure TPrefsForm.FormCreate(Sender: TObject);
begin
  if EmulatorPath.Text = 'EmulatorPath' then
  {$IFDEF UNIX}
    EmulatorPath.Text:='/usr/bin/86Box';
  EmulatorPath.Filter:='86Box Emulator|86Box';
  {$ELSE}
    EmulatorPath.Text:='';
  EmulatorPath.Filter:='86Box Emulator|86Box.exe'
  {$ENDIF}
end;

procedure TPrefsForm.AddCategoryBtnClick(Sender: TObject);
var
  s: string;
begin
  s:=InputBox(ApplicationName, 'Category Name:', '');
  if s <> '' then
    CategoryList.Items.Add(s);
end;

procedure TPrefsForm.DelCategoryBtnClick(Sender: TObject);
begin
  if CategoryList.ItemIndex = -1 then
    Exit;
  CategoryList.Items.Delete(CategoryList.ItemIndex);
end;

procedure TPrefsForm.EditCategoryBtnClick(Sender: TObject);
var
  s: string;
begin
  if CategoryList.ItemIndex = -1 then
    Exit;
  s:=InputBox(ApplicationName, 'Category Name:', CategoryList.GetSelectedText);
  if s <> CategoryList.GetSelectedText then
    CategoryList.Items.Strings[CategoryList.ItemIndex]:=s;
end;

end.

