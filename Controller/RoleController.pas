unit RoleController;

interface

uses
  System.SysUtils, System.Classes, XSuperObject, MVC.BaseController, RoleService;

type
  TRoleController = class(TBaseController)
  private
    role_service: TRoleService;
  public
    procedure Index;
    procedure add;
    procedure edit;
    procedure save;
    procedure getData;
    procedure getAllData;
    procedure getMenu;
    procedure del;
    procedure addmenu;
    procedure delmenu;
    procedure addmenuview;
    procedure getselmenu;
    procedure CreateView; override;
    destructor Destroy; override;
  end;

implementation


{ TRoleController }

procedure TRoleController.add;
begin
  with view do
  begin
    ShowHTML('add');
  end;
end;

procedure TRoleController.addmenu;
var
  roleid, menuid: string;
begin
  with view do
  begin
    roleid := Input('roleid');
    menuid := Input('menuid');
    if role_service.addmenu(roleid, menuid) then
      Success(0, '��ӳɹ�')
    else
      Fail(-1, '���ʧ��');
  end;
end;

procedure TRoleController.addmenuview;
begin
  with view do
  begin
    ShowHTML('addmenu');
  end;
end;

procedure TRoleController.CreateView;
begin
  inherited;
  role_service := TRoleService.Create(View.Db);
end;

procedure TRoleController.del;
var
  id: Integer;
begin

  with view do
  begin
    id := InputInt('id');
    if role_service.del(IntToStr(id)) then
      Success(0, 'ɾ���ɹ�')
    else
      Fail(-1, 'ɾ��ʧ��');
  end;
end;

procedure TRoleController.delmenu;
var
  roleid, menuid: string;
begin
  with view do
  begin
    roleid := Input('roleid');
    menuid := Input('menuid');
    if role_service.delmenu(roleid, menuid) then
      Success(0, 'ɾ���ɹ�')
    else
      Fail(-1, 'ɾ��ʧ��');
  end;
end;

destructor TRoleController.Destroy;
begin
  role_service.Free;
  inherited;
end;

procedure TRoleController.edit;
begin
  with view do
  begin
    ShowHTML('edit');
  end;
end;

procedure TRoleController.getAllData;
begin
  with view do
  begin
    ShowJSON(role_service.getAlldata());
  end;
end;

procedure TRoleController.getData;
var
  con: Integer;
  ret: ISuperObject;
  map: ISuperObject;
  s: string;
begin
  with View do
  begin
    map := SO();
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    ret := role_service.getdata(con, map);
    s := ret.AsJSON();
    ShowPage(con, ret);
  end;
end;

procedure TRoleController.getMenu;
var
  ret, map: ISuperObject;
  con: integer;
begin
  with view do
  begin
    map := SO();
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    map.I['roleid'] := InputInt('roleid');
    ret := role_service.getMenu(con, map);
    ShowPage(con, ret);
  end;
end;

procedure TRoleController.getselmenu;
var
  roleid: string;
  con: integer;
  map, ret: ISuperObject;
begin
  with view do
  begin
    map := SO();
    roleid := Input('roleid');
    map.I['page'] := InputInt('page');
    map.I['limit'] := InputInt('limit');
    map.S['roleid'] := roleid;
    ret := role_service.getSelMenu(con, map);
    ShowJSON(Plugin.Layui.getPage(con, ret));
  end;
end;

procedure TRoleController.Index;
begin
  with View do
  begin
    ShowHTML('index');
  end;
end;

procedure TRoleController.save;
var
  map: ISuperObject;
begin
  with view do
  begin
    map := SO();
    map.S['rolename'] := Input('rolename');
    map.S['id'] := Input('id');
    if role_service.save(map) then
    begin
      Success(0, '����ɹ�');
    end
    else
    begin
      Fail(-1, '����ʧ��');
    end;
  end;
end;

end.

