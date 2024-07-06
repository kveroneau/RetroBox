unit MainWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, PairSplitter,
  ComCtrls, StdCtrls, PrefsWindow;

type

  { TRetroBoxForm }

  TRetroBoxForm = class(TForm)
    Button1: TButton;
    ImageList: TImageList;
    PairSplitter: TPairSplitter;
    TreePane: TPairSplitterSide;
    InfoPane: TPairSplitterSide;
    MachineTree: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PairSplitterResize(Sender: TObject);
    procedure TreePaneResize(Sender: TObject);
  private
    FProcesses: array of TProcess;
    procedure RenderTree;
  public

  end;

var
  RetroBoxForm: TRetroBoxForm;

implementation

{$R *.lfm}

{ TRetroBoxForm }

procedure TRetroBoxForm.FormResize(Sender: TObject);
begin
  PairSplitter.Width:=ClientWidth;
  PairSplitter.Height:=ClientHeight;
end;

procedure TRetroBoxForm.FormShow(Sender: TObject);
begin
  RenderTree;
end;

procedure TRetroBoxForm.FormCreate(Sender: TObject);
begin

end;

procedure TRetroBoxForm.Button1Click(Sender: TObject);
begin
  PrefsForm.ShowModal;
end;

procedure TRetroBoxForm.FormDestroy(Sender: TObject);
begin

end;

procedure TRetroBoxForm.PairSplitterResize(Sender: TObject);
begin
  MachineTree.Width:=TreePane.ClientWidth;
  MachineTree.Height:=TreePane.ClientHeight;
end;

procedure TRetroBoxForm.TreePaneResize(Sender: TObject);
begin
  PairSplitterResize(Sender);
end;

procedure TRetroBoxForm.RenderTree;
var
  node, vm: TTreeNode;
  i: integer;
begin
  with PrefsForm.CategoryList.Items do
    for i:=0 to Count-1 do
    begin
      node:=MachineTree.Items.Add(Nil, Strings[i]);
      node.ImageIndex:=0;
      node.SelectedIndex:=0;
    end;
end;

end.

