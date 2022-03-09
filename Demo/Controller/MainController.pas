unit MainController;

interface

uses
  System.SysUtils, System.Classes, MVC.DataSet, BaseController, MainService;

type
  [MURL('main', 'main')]  //����·�ɵ�ַ����ͼ��ַ
  TMainController = class(TBaseController)
  public
    [MURL('index')]  // testΪindex�����ķ��ʵ�ַ �����÷��ʵ�ַ�� index �������޷��ٷ���
    procedure index;
    procedure menu; //��ȡ�˵���Ϣ
  end;

implementation

{ TMainController }

procedure TMainController.index;
var
  ds: Idataset;
begin
  SetAttr('realname', Session.getValue('username'));
  ds := Service.Main.getmenu;
  SetAttr('menuls', ds.toJSONArray);
  Show('main');
end;

procedure TMainController.menu;
var
  ds: Idataset;
begin
  ds := Service.Main.getmenu;
  ShowJSON(ds);
end;

end.

