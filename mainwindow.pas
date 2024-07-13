unit MainWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, PairSplitter,
  ComCtrls, StdCtrls, Menus, ExtCtrls, PrefsWindow, boxtype;

type

  { TRetroBoxForm }

  TRetroBoxForm = class(TForm)
    AddMenu: TMenuItem;
    ImageList: TImageList;
    ImportMenu: TMenuItem;
    ConfigData: TMemo;
    OpenDialog: TOpenDialog;
    TabControl: TPageControl;
    PairSplitter: TPairSplitter;
    StatusBar: TStatusBar;
    InfoTab: TTabSheet;
    ConfigTab: TTabSheet;
    Timer: TTimer;
    TreeMenu: TPopupMenu;
    TreePane: TPairSplitterSide;
    InfoPane: TPairSplitterSide;
    MachineTree: TTreeView;
    procedure AddMenuClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ConfigTabResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImportMenuClick(Sender: TObject);
    procedure MachineTreeClick(Sender: TObject);
    procedure MachineTreeDblClick(Sender: TObject);
    procedure PairSplitterResize(Sender: TObject);
    procedure TabControlResize(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TreePaneResize(Sender: TObject);
  private
    FProcesses: array of TProcess;
    procedure RenderTree;
    procedure AddSystem(node: TTreeNode; title, path: string);
    procedure SaveSystems;
    procedure LoadSystems;
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
  PairSplitter.Height:=ClientHeight-StatusBar.Height;
end;

procedure TRetroBoxForm.FormShow(Sender: TObject);
begin
  if PrefsForm.BasePath.Text = 'BasePath' then
    PrefsForm.ShowModal;
  RenderTree;
  LoadSystems;
  StatusBar.SimpleText:='Ready.';
end;

procedure TRetroBoxForm.ImportMenuClick(Sender: TObject);
var
  tmp: string;
begin
  if MachineTree.Selected = Nil then
  begin
    ShowMessage('Select a category node to import to.');
    Exit;
  end;
  OpenDialog.Title:='Import System...';
  OpenDialog.InitialDir:=PrefsForm.BasePath.Directory;
  if not OpenDialog.Execute then
    Exit;
  tmp:=ExtractFileDir(OpenDialog.FileName);
  AddSystem(MachineTree.Selected, ExtractFileName(tmp), ExtractFileName(tmp));
end;

procedure TRetroBoxForm.MachineTreeClick(Sender: TObject);
begin
  if MachineTree.Selected.Data = Nil then
    Exit;
  ConfigData.Lines.LoadFromFile(PrefsForm.BasePath.Directory+'/'+MachineTree.Selected.Text+'/86box.cfg');
end;

procedure TRetroBoxForm.MachineTreeDblClick(Sender: TObject);
var
  i: integer;
  p: PBoxInfo;
begin
  if MachineTree.Selected.Data = Nil then
    Exit;
  p:=MachineTree.Selected.Data;
  i:=Length(FProcesses);
  SetLength(FProcesses, i+1);
  FProcesses[i]:=TProcess.Create(Self);
  FProcesses[i].Executable:=PrefsForm.EmulatorPath.FileName;
  FProcesses[i].CurrentDirectory:=PrefsForm.BasePath.Directory+'/'+p^.path;
  FProcesses[i].Active:=True;
  StatusBar.SimpleText:='Systems runnings: '+IntToStr(Length(FProcesses));
end;

procedure TRetroBoxForm.FormCreate(Sender: TObject);
begin

end;

procedure TRetroBoxForm.Button1Click(Sender: TObject);
begin
  PrefsForm.ShowModal;
end;

procedure TRetroBoxForm.ConfigTabResize(Sender: TObject);
begin
  ConfigData.Width:=ConfigTab.ClientWidth;
  ConfigData.Height:=ConfigTab.ClientHeight;
end;

procedure TRetroBoxForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
var
  i: integer;
begin
  if PrefsForm.TermOnClose.Checked then
  begin
    for i:=0 to Length(FProcesses)-1 do
    begin
      FProcesses[i].Active:=False;
      FProcesses[i].WaitOnExit;
    end;
  end;
  CloseAction:=caFree;
end;

procedure TRetroBoxForm.AddMenuClick(Sender: TObject);
begin

end;

procedure TRetroBoxForm.FormDestroy(Sender: TObject);
var
  i: integer;
  p: PBoxInfo;
begin
  for i:=0 to MachineTree.Items.Count-1 do
    if MachineTree.Items.Item[i].Data <> Nil then
    begin
      p:=MachineTree.Items.Item[i].Data;
      Dispose(p);
    end;
end;

procedure TRetroBoxForm.PairSplitterResize(Sender: TObject);
begin
  MachineTree.Width:=TreePane.ClientWidth;
  MachineTree.Height:=TreePane.ClientHeight;
  TabControl.Width:=InfoPane.ClientWidth;
  TabControl.Height:=InfoPane.ClientHeight;
end;

procedure TRetroBoxForm.TabControlResize(Sender: TObject);
begin
  ConfigTab.Width:=TabControl.ClientWidth;
  ConfigTab.Height:=TabControl.ClientHeight;
end;

procedure TRetroBoxForm.TimerTimer(Sender: TObject);
var
  i: integer;
begin
  { #todo : Dynamic Arrays will be interesting to purge out old processes }
  for i:=0 to Length(FProcesses)-1 do
    if not FProcesses[i].Running then
    begin
      FProcesses[i].Free;
      FProcesses[i]:=Nil;
    end;
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

procedure TRetroBoxForm.AddSystem(node: TTreeNode; title, path: string);
var
  vm: TTreeNode;
  p: PBoxInfo;
begin
  vm:=MachineTree.Items.AddChild(node, title);
  vm.ImageIndex:=1;
  vm.SelectedIndex:=1;
  New(p);
  p^.title:=title;
  p^.path:=path;
  p^.icon:=1;
  p^.category:=node.Text;
  vm.Data:=p;
  SaveSystems;
end;

procedure TRetroBoxForm.SaveSystems;
var
  i: integer;
  f: TMemoryStream;
begin
  f:=TMemoryStream.Create;
  try
    for i:=0 to MachineTree.Items.Count-1 do
      if MachineTree.Items.Item[i].Data <> Nil then
        f.Write(PBoxInfo(MachineTree.Items.Item[i].Data)^, SizeOf(TBoxInfo));
    f.SaveToFile('machines.dat');
  finally
    f.Free;
  end;
end;

procedure TRetroBoxForm.LoadSystems;
var
  i: integer;
  f: TMemoryStream;
  m: PBoxInfo;
  cat, vm: TTreeNode;
begin
  f:=TMemoryStream.Create;
  try
    f.LoadFromFile('machines.dat');
    for i:=0 to (f.Size div SizeOf(TBoxInfo))-1 do
    begin
      New(m);
      f.Read(m^, SizeOf(TBoxInfo));
      cat:=MachineTree.Items.FindNodeWithText(m^.category);
      vm:=MachineTree.Items.AddChild(cat, m^.title);
      vm.ImageIndex:=m^.icon;
      vm.SelectedIndex:=m^.icon;
      vm.Data:=m;
    end;
  finally
    f.Free;
  end;
end;

end.

