unit MVC.RouteMap;

interface

uses
  MVC.Route;

type
  TRouteMap = class(TRoute)
  public
    constructor Create(); override;
  end;

implementation

constructor TRouteMap.Create;
begin
  inherited;
  //·��,������,��ͼĿ¼,������(Ĭ������)


end;

end.

