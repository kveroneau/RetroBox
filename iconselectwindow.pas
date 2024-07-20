unit IconSelectWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls;

type

  { TIconSelectForm }

  TIconSelectForm = class(TForm)
    IconList: TListView;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure IconListDblClick(Sender: TObject);
  private

  public
    IconIndex: integer;
  end;

var
  IconSelectForm: TIconSelectForm;

implementation

{$R *.lfm}

{ TIconSelectForm }

procedure TIconSelectForm.FormResize(Sender: TObject);
begin
  IconList.Width:=ClientWidth;
  IconList.Height:=ClientHeight;
end;

procedure TIconSelectForm.FormShow(Sender: TObject);
begin
  IconIndex:=-1;
end;

procedure TIconSelectForm.IconListDblClick(Sender: TObject);
begin
  IconIndex:=IconList.Selected.ImageIndex;
  Close;
end;

end.

