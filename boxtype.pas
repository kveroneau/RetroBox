unit boxtype;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PBoxInfo = ^TBoxInfo;
  TBoxInfo = record
    title: string[40];
    path: string[40]; { This will be an extension to the BasePath }
    icon: integer;
    category: string[40];
  end;

  PBoxTemplate = ^TBoxTemplate;
  TBoxTemplate = record
    title: string[40];
    cfgres: string[20];
    nvres: string[20];
    nvrFile: string[30];
  end;

var
  sys_templates: Array[1..10] of TBoxTemplate;

implementation

procedure InitSysTemplates;
begin
  with sys_templates[1] do
  begin
    title:='IBM PS/2 Model 60';
    cfgres:='TALLGRASS';
    nvres:='IBMPS2_M60';
    nvrFile:='ibmps2_m60.nvr';
  end;
  with sys_templates[2] do
  begin
    title:='ASUS 386';
    cfgres:='ASUS386';
    nvres:='ASUS386NVR';
    nvrFile:='asus386.nvr';
  end;
  with sys_templates[3] do
  begin
    title:='ALI 486';
    cfgres:='ALI486';
    nvres:='ALI1429';
    nvrFile:='ali1429.nvr';
  end;
  with sys_templates[4] do
  begin
    title:='Pentium';
    cfgres:='PENTIUM';
    nvres:='OPTI560L';
    nvrFile:='opti560l.nvr';
  end;
  with sys_templates[5] do
  begin
    title:='Aptiva AMD K-6';
    cfgres:='APTIVA';
    nvres:='P5A';
    nvrFile:='p5a.nvr';
  end;
  with sys_templates[6] do
  begin
    title:='High-end 1988';
    cfgres:='1988';
    nvres:='DESKPRO386_05_1988';
    nvrFile:='deskpro386_05_1988.nvr';
  end;
  with sys_templates[7] do
  begin
    title:='High-end 1990';
    cfgres:='1990';
    nvres:='AMI495';
    nvrFile:='ami495.nvr';
  end;
  with sys_templates[8] do
  begin
    title:='High-end 1992';
    cfgres:='1992';
    nvres:='PB410A';
    nvrFile:='pb410a.nvr';
  end;
  with sys_templates[9] do
  begin
    title:='High-end 1994';
    cfgres:='1994';
    nvres:='ACERV30';
    nvrFile:='acerv30.nvr';
  end;
  with sys_templates[10] do
  begin
    title:='High-end 1996';
    cfgres:='1996';
    nvres:='PB810';
    nvrFile:='pb810.nvr';
  end;
end;

initialization
  InitSysTemplates;
end.

