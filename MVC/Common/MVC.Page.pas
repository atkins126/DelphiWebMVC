{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.Page;

interface

uses
  System.SysUtils, System.Classes,
  XSuperObject, uConfig;

type
  TPage = class
  private
    url: string;
    plist: TStringList;
  public
    Page: TStringList;
    function HTML(): string;
    constructor Create(htmlfile: string; params: TStringList; _url: string);
    destructor Destroy; override;
  end;

implementation

{ TPage }

constructor TPage.Create(htmlfile: string; params: TStringList; _url: string);
begin
  Page := TStringList.Create;
  plist := params;
  if UpperCase(document_charset) = 'UTF-8' then
  begin
    Page.LoadFromFile(htmlfile, TEncoding.UTF8);
  end
  else if UpperCase(document_charset) = 'UTF-7' then
  begin
    Page.LoadFromFile(htmlfile, TEncoding.UTF7);
  end
  else if UpperCase(document_charset) = 'UNICODE' then
  begin
    Page.LoadFromFile(htmlfile, TEncoding.Unicode);
  end
  else
  begin
    Page.LoadFromFile(htmlfile, TEncoding.Default);
  end;
  url := _url;
end;

function TPage.HTML(): string;
begin
  Result := Page.Text;
end;

destructor TPage.Destroy;
begin
  Page.Clear;
  Page.Free;
  inherited;
end;


end.

