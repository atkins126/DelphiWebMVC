unit uRouleMap;

interface

uses
  MVC.Roule;

type
  TRouleMap = class(TRoule)
  public
    constructor Create(); override;
  end;

implementation

uses
  IndexController;

constructor TRouleMap.Create;
begin
  inherited;
  //·��,������,��ͼĿ¼,������(Ĭ������)
  SetRoule('', TIndexController, '', False);


end;

end.

