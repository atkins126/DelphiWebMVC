unit uGlobal;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.Generics.Collections;

type
  TGlobal = class
  public
    test: string;
    // ������Դ洢һЩȫ�ֱ�����ȫ����
  //  list: TList;
    constructor Create();
    destructor Destroy; override;
  end;

var
  Global: TGlobal;

implementation

{ TGlobal }

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

