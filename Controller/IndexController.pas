unit IndexController;

interface

uses
  System.SysUtils, System.Classes, superobject, View, BaseController;

type
  TIndexController = class(TBaseController)
  public
    procedure Index(num: Double);
    procedure check;
    procedure verifycode;
    procedure setdata;
    procedure home(value1, value2, value3, value4, value5: string);
  end;

implementation

uses
  UsersService, UsersInterface, uGlobal, MHashMap;


{ TIndexController }

procedure TIndexController.check;
var
  map, ret: ISuperObject;
  code: string;
  user_service: IUsersInterface;
 // m:TMHashMap;
begin
  
  user_service := TUsersService.Create(View.Db);
  with view do
  begin
    map := SO();
    map.S['username'] := Input('username');
    map.S['pwd'] := Input('pwd');
//	MHashMapNew(m);
//    m.username:=Input('username');
//    m.pwd:=Input('pwd');
    code := Input('vcode');
    if code.ToLower = SessionGet('vcode').ToLower then
    begin

      ret := user_service.checkuser(map);
      if ret <> nil then
      begin
        SessionSet('user', ret.AsString);
        Success(0, '��¼�ɹ�');
      end
      else
      begin
        Fail(-1, '��¼ʧ��,�����û�������');
      end;
    end
    else
    begin
      Fail(-1, '��֤�����');
    end;
  end;
end;

procedure TIndexController.home(value1, value2, value3, value4, value5: string);
var
  s: string;
begin
//http://localhost:8004/home/ddd/12/32/eee/333.html
//http://localhost:8004/home/ddd/12/32/eee/333
//http://localhost:8004/home/ddd/12/32/eee/333?name=admin
 //α��̬��Rest���
  with view do
  begin
    s := InputByIndex(2);
    s := Input('name');
    ShowText(s + ' ' + value1 + ' ' + value2 + ' ' + value3 + ' ' + value4 + ' ' + value5);
  end;
end;

procedure TIndexController.Index(num: Double);

begin
  with View do
  begin
   // Plugin.Wechat.checktoken();
   // Global.test:='ok'; //ȫ�ֱ���ʹ��

//    jo := SO();
//    jo.S['msg'] := '���ѽ';
//    RedisSetKeyJSON('name', jo);
//    RedisRemove('name');
//    s := RedisGetKeyJSON('name').AsString;
//    RedisSetKeyText('sex', '��');
//    s := RedisGetKeyText('sex');

    SessionRemove('user');
    ShowHTML('login');
  end;
end;

procedure TIndexController.setdata;
var
  s: string;
begin
  s := Request.Content;
end;

procedure TIndexController.verifycode;
var
  code: string;
  i: integer;
const
  str = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
begin

  with view do
  begin
    for i := 0 to 3 do
    begin
      code := code + Copy(str, Random(Length(str)), 1);
    end;
    SessionSet('vcode', code);
    if Length(code) <> 4 then
    begin
      ShowText('error');
    end
    else
      ShowVerifyCode(code);
  end;
end;

end.

