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

implementation

end.

