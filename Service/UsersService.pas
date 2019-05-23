unit UsersService;

interface

uses
  UsersInterface, superobject, uTableMap, BaseService,MHashMap;

type
  TUsersService = class(TBaseService, IUsersInterface)
  public
    function checkuser(map: ISuperObject): ISuperObject;
    function getdata(var con: Integer; map: ISuperObject): ISuperObject;
    function save(map: ISuperObject): boolean;
    function delById(id: string): Boolean;
  end;



implementation

{ TUsersService }

function TUsersService.checkuser(map: ISuperObject): ISuperObject;
begin
  Result:=db.Default.FindFirst(tb_users,map);
 // Result := Db.Default.FindFirst(tb_users, 'and username='+Q(map.username)+' and pwd='+Q(map.pwd));
end;

function TUsersService.delById(id: string): Boolean;
begin
  Result := Db.Default.DeleteByKey(tb_users, 'id', id);
end;

function TUsersService.getdata(var con: Integer; map: ISuperObject): ISuperObject;
var
  list: ISuperObject;
  sql: string;
begin
  if map.S['roleid'] <> '' then
    sql := 'and roleid= ' + Q(map.S['roleid']);

  list := Db.Default.FindPage(con, tb_users, sql, 'id', map.I['page'] - 1, map.I['limit']);
  Result := list;
end;

function TUsersService.save(map: ISuperObject): Boolean;
var
  ret: ISuperObject;
  id: string;
  s: string;
begin
  id := map.S['id'];
  s := map.AsString;
  if id = '' then
  begin
    map.Delete('id');
    ret := Db.Default.FindFirst(tb_users, map);
    if ret = nil then
    begin
      with Db.Default.AddData(tb_users) do
      begin
        FieldByName('username').AsString := map.S['username'];
        FieldByName('realname').AsString := map.S['realname'];
        FieldByName('roleid').AsString := map.S['roleid'];
        FieldByName('pwd').AsString := map.S['pwd'];
        Post;
        Result := true;
      end;
    end
    else
    begin
      Result := false;
    end;
  end
  else
  begin
    ret := Db.Default.FindFirst(tb_users, 'and id<>' + id + ' and username=' + Q(map.S['username']));
    if ret = nil then
    begin
      with db.Default.EditData(tb_users, 'id', id) do
      begin
        FieldByName('username').AsString := map.S['username'];
        FieldByName('realname').AsString := map.S['realname'];
        FieldByName('roleid').AsString := map.S['roleid'];
        FieldByName('pwd').AsString := map.S['pwd'];
        Post;
        Result := true;
      end;
    end
    else
    begin
      Result := false;
    end;

  end;
end;

end.

