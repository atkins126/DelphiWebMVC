unit uGlobal;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Generics.Collections,
  Vcl.Graphics;

type
  TGlobal = class
  private
  public
    test: string;
    function QRCode_Create(value: string; filename: string; bType: Integer): Boolean;
    // ������Դ洢һЩȫ�ֱ�����ȫ����
  //  list: TList;
    constructor Create();
    destructor Destroy; override;
  end;

function BarCodeMake(value: string; filename: string; bType: Integer): Boolean; stdcall; external 'qrcode.dll';

var
  Global: TGlobal;

implementation

{ TGlobal }
function TGlobal.QRCode_Create(value: string; filename: string; bType: Integer): Boolean;
begin
  Result := BarCodeMake(value, filename, bType);
end;

constructor TGlobal.Create();
begin
  //��Ĵ���
 // list := TList.Create;
end;

destructor TGlobal.Destroy;
begin
  //����ͷ�
 // list.Clear;
 // list.Free;
  inherited;
end;

end.

