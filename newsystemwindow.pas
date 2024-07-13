unit NewSystemWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, boxtype;

type

  { TNewSystemForm }

  TNewSystemForm = class(TForm)
    CreateBtn: TButton;
    CancelBtn: TButton;
    SystemTemplate: TComboBox;
    Label2: TLabel;
    SystemTitle: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  NewSystemForm: TNewSystemForm;

implementation

{$R *.lfm}

{ TNewSystemForm }

procedure TNewSystemForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i:=1 to High(sys_templates) do
    SystemTemplate.Items.Add(sys_templates[i].title);
end;

end.

