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
  sys_templates: Array[1..2] of TBoxTemplate;

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
end;

initialization
  InitSysTemplates;
end.

