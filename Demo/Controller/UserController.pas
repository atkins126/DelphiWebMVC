unit UserController;

interface

uses
  System.SysUtils, System.Classes, MVC.DataSet, MVC.JSON, BaseController,
  UserService, RoleService;

type
  [MURL('user', 'user')]
  TUserController = class(TBaseController)
  public
    procedure index;
    //
    [MURL('getData', TMethod.sGET)]
    procedure getData;
    procedure getrole;
    procedure add;
    procedure edit;

//    [MURL('del/:id', TMethod.sGET)]
    procedure del(id: string);

    [MURL('save', TMethod.sPOST)]
    procedure save;
    procedure print;

  end;

implementation


{ TMainController }

procedure TUserController.add;
begin

  SetAttr('role', Service.Role.getData);

end;

procedure TUserController.del(id: string);
begin
  if Service.User.Del(id) then
    Success(0, 'ɾ���ɹ�')
  else
    Fail(-1, 'ɾ��ʧ��');
end;

procedure TUserController.edit;
begin
  SetAttr('role', Service.Role.getData);
end;

procedure TUserController.getData;
begin
  var ds: Idataset := Service.User.getData(InputToJSON);
  ShowPage(ds);
end;

procedure TUserController.getrole;
begin
  ShowJSON(Service.Role.getData);
end;

procedure TUserController.index;
begin
  SetAttr('role', Service.Role.getData);
  show('index');
end;

procedure TUserController.print;
var
  nowdate: string;
begin
  SetAttr('list', Service.User.getAllData(InputToJSON));
  nowdate := FormatDateTime('yyyy��MM��dd��', Now);
  setAttr('nowdate', nowdate);
end;

procedure TUserController.save;
begin
  if Service.User.save(InputToJSON) then
    Success(0, '����ɹ�')
  else
    Fail(-1, '����ʧ��');
end;

end.

