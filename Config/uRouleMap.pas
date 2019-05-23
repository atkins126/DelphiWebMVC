unit uRouleMap;

interface

uses
  Roule;

type
  TRouleMap = class(TRoule)
  public
    constructor Create(); override;
  end;

implementation

uses
  IndexController, MainController, RoleController, UserController, VIPController,
  PayController;

constructor TRouleMap.Create;
begin
  inherited;
  //·��,������,��ͼĿ¼
  SetRoule('', TIndexController, '', False);
  SetRoule('Main', TMainController, '');
  SetRoule('User', TUserController, 'User');
  SetRoule('Role', TRoleController, 'Role');
  SetRoule('VIP', TVIPController, 'VIP');
  SetRoule('Pay', TPayController, 'Pay');

end;

end.

