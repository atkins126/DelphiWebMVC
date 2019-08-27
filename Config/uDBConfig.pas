unit uDBConfig;

interface

uses
  MVC.DBSQLite, MVC.DBMySql;

type
  TDBConfig = class
  public
    Default: TDBSQLite;   //������Default��Ա������
   // Default: TDBMySql;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDBConfig }

constructor TDBConfig.Create;
begin
  Default := TDBSQLite.Create('SQLite');
 // Default := TDBMySql.Create('MYSQL');
end;

destructor TDBConfig.Destroy;
begin
  Default.Free;
 // MYSQL.Free;
  inherited;
end;

end.

