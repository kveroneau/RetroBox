unit MainWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, PairSplitter,
  ComCtrls, StdCtrls, Menus, ExtCtrls, Buttons, PrefsWindow, boxtype,
  NewSystemWindow, IconSelectWindow;

type

  EInvalidNode = class(Exception);

  { TRetroBoxForm }

  TRetroBoxForm = class(TForm)
    AddMenu: TMenuItem;
    BoxTitle: TEdit;
    BoxSettingBtn: TButton;
    ImageList: TImageList;
    ImportMenu: TMenuItem;
    ConfigData: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    BoxPath: TLabel;
    DeleteMenu: TMenuItem;
    Label3: TLabel;
    PrefsMenu: TMenuItem;
    OpenDialog: TOpenDialog;
    BoxSettings: TProcess;
    Separator1: TMenuItem;
    BoxIcon: TSpeedButton;
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
    procedure BoxIconClick(Sender: TObject);
    procedure BoxSettingBtnClick(Sender: TObject);
    procedure ConfigTabResize(Sender: TObject);
    procedure DeleteMenuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImportMenuClick(Sender: TObject);
    procedure MachineTreeClick(Sender: TObject);
    procedure MachineTreeDblClick(Sender: TObject);
    procedure PairSplitterResize(Sender: TObject);
    procedure PrefsMenuClick(Sender: TObject);
    procedure TabControlResize(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TreePaneResize(Sender: TObject);
  private
    FProcesses: array of TProcess;
    procedure RenderTree;
    procedure AddSystem(node: TTreeNode; title, path: string);
    procedure SaveSystems;
    procedure LoadSystems;
    procedure ExtractConfig(cfgres, nvres, target, nvrFile: string);
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
    raise EInvalidNode.Create('Select a category node to import to.');
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
  ConfigData.Lines.LoadFromFile(PrefsForm.BasePath.Directory+DirectorySeparator+MachineTree.Selected.Text+DirectorySeparator+'86box.cfg');
  BoxTitle.Text:=MachineTree.Selected.Text;
  BoxPath.Caption:=PrefsForm.BasePath.Directory+DirectorySeparator+MachineTree.Selected.Text;
  BoxIcon.ImageIndex:=PBoxInfo(MachineTree.Selected.Data)^.icon;
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
  FProcesses[i].CurrentDirectory:=PrefsForm.BasePath.Directory+DirectorySeparator+p^.path;
  FProcesses[i].Active:=True;
  StatusBar.SimpleText:='Systems runnings: '+IntToStr(Length(FProcesses));
end;

procedure TRetroBoxForm.FormCreate(Sender: TObject);
begin
  {$IFNDEF DEBUG}
  Application.ExceptionDialog:=aedOkMessageBox;
  {$ENDIF}
end;

procedure TRetroBoxForm.ConfigTabResize(Sender: TObject);
begin
  ConfigData.Width:=ConfigTab.ClientWidth;
  ConfigData.Height:=ConfigTab.ClientHeight;
end;

procedure TRetroBoxForm.DeleteMenuClick(Sender: TObject);
var
  p: PBoxInfo;
begin
  if MachineTree.Selected.Data = Nil then
    Exit;
  if MessageDlg(Application.Title, 'Are you sure you want to remove '+MachineTree.Selected.Text+'?', mtConfirmation, mbYesNo, '') = mrYes then
  begin
    p:=MachineTree.Selected.Data;
    Dispose(p);
    MachineTree.Items.Delete(MachineTree.Selected);
    SaveSystems;
  end;
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
var
  tmp: string;
  frm: TNewSystemForm;
  tmpl: PBoxTemplate;
begin
  if MachineTree.Selected = Nil then
    raise EInvalidNode.Create('Select a category node to add system to.');
  frm:=TNewSystemForm.Create(Nil);
  try
    if frm.ShowModal <> mrOK then
      Exit;
    tmp:=PrefsForm.BasePath.Directory+DirectorySeparator+frm.SystemTitle.Text;
    CreateDir(tmp);
    if frm.SystemTemplate.ItemIndex > 0 then
    begin
      CreateDir(tmp+DirectorySeparator+'nvr');
      tmpl:=@sys_templates[frm.SystemTemplate.ItemIndex];
      ExtractConfig(tmpl^.cfgres, tmpl^.nvres, tmp, tmpl^.nvrFile);
    end;
    AddSystem(MachineTree.Selected, frm.SystemTitle.Text, frm.SystemTitle.Text);
  finally
    frm.Free;
  end;
  BoxSettings.Executable:=PrefsForm.EmulatorPath.FileName;
  BoxSettings.CurrentDirectory:=tmp;
  BoxSettings.Active:=True;
  BoxSettings.WaitOnExit;
  BoxSettings.Active:=False;
end;

procedure TRetroBoxForm.BoxIconClick(Sender: TObject);
begin
  IconSelectForm.ShowModal;
  if IconSelectForm.IconIndex > -1 then
  begin
    PBoxInfo(MachineTree.Selected.Data)^.icon:=IconSelectForm.IconList.Selected.ImageIndex;
    MachineTree.Selected.ImageIndex:=IconSelectForm.IconIndex;
    MachineTree.Selected.SelectedIndex:=IconSelectForm.IconIndex;
    BoxIcon.ImageIndex:=MachineTree.Selected.ImageIndex;
    SaveSystems;
  end;
end;

procedure TRetroBoxForm.BoxSettingBtnClick(Sender: TObject);
begin
  if MachineTree.Selected.Data = Nil then
    Exit;
  BoxSettings.Executable:=PrefsForm.EmulatorPath.FileName;
  BoxSettings.CurrentDirectory:=PrefsForm.BasePath.Directory+DirectorySeparator+PBoxInfo(MachineTree.Selected.Data)^.path;
  BoxSettings.Active:=True;
  BoxSettings.WaitOnExit;
  BoxSettings.Active:=False;
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

procedure TRetroBoxForm.PrefsMenuClick(Sender: TObject);
begin
  PrefsForm.ShowModal;
  FormDestroy(Sender);
  MachineTree.Items.Clear;
  RenderTree;
  LoadSystems;
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
  node: TTreeNode;
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

procedure TRetroBoxForm.ExtractConfig(cfgres, nvres, target, nvrFile: string);
var
  res: TResourceStream;
begin
  res:=TResourceStream.Create(HINSTANCE, cfgres, RT_RCDATA);
  try
    res.SaveToFile(target+DirectorySeparator+'86box.cfg');
  finally
    res.Free;
  end;
  res:=TResourceStream.Create(HINSTANCE, nvres, RT_RCDATA);
  try
    res.SaveToFile(target+DirectorySeparator+'nvr'+DirectorySeparator+nvrFile);
  finally
    res.Free;
  end;
end;

end.

