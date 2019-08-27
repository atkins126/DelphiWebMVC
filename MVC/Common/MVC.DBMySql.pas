{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.DBMySql;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, XSuperObject, MVC.DBBase, Data.DB;

type
  TDBMySql = class(TDBBase)
  private
    function GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
  public
    function FindFirst(tablename: string; where: string = ''): ISuperObject; overload; override;
    function QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject; override;
    function QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string; override;
    procedure StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant); overload;
  end;

implementation


{ TDBSQLite }

function TDBMySql.FindFirst(tablename: string; where: string = ''): ISuperObject;
var
  sql: string;
begin
  Result := nil;
  if (Trim(tablename) = '') then
    Exit;
  if Fields = '' then
    Fields := '*';
  sql := 'select ' + Fields + ' from ' + tablename + ' where 1=1 ' + where + ' limit 1';
  Result := QueryFirst(sql);
end;

function TDBMySql.GetSQL(tp: Boolean; var dataset: TFDQuery; var count: Integer; select, from, order: string; pageindex, pagesize: Integer): Boolean;
var
  sql: string;
begin
  Result := true;
  if (not TryConnDB) or (Trim(select) = '') or (Trim(from) = '') then
    Exit;
  if Trim(order) <> '' then
    order := 'order by ' + Trim(order);
  try
    try
      sql := 'select count(1) as N from ' + from;
      sql := filterSQL(sql);
      count :=condb.ExecSQLScalar(sql);
      sql := 'select ' + Trim(select) + ' from ' + Trim(from) + ' ' + Trim(order) + ' limit ' + inttostr(pageindex * pagesize) + ',' + inttostr(pagesize);
      Result := Query(sql, dataset);
    except
      on e: Exception do
      begin
        DBlog(e.ToString);
        Result := False;
      end;

    end;
  finally
  //  CDS.Free;
  end;

end;

function TDBMySql.QueryPage(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): ISuperObject;

begin

  try
    if GetSQL(True, TMP_CDS, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONArray(TMP_CDS);
    end
    else
      Result := SA().AsObject;
  finally

  end;
end;

function TDBMySql.QueryPageT(var count: Integer; select, from, order: string; pageindex, pagesize: Integer): string;

begin

  try
    if GetSQL(false, TMP_CDS, count, select, from, order, pageindex, pagesize) then
    begin
      Result := CDSToJSONText(TMP_CDS);
    end
    else
      Result := '[]';
  finally

  end;
end;

procedure TDBMySql.StoredProcAddParams(DisplayName_: string; DataType_: TFieldType; ParamType_: TParamType; Value_: Variant);
begin
  inherited;
  with StoredProc.Params.Add do
  begin
    DisplayName := DisplayName_;
    Name := DisplayName_;
    DataType := DataType_;
    Value := Value_;
    ParamType := ParamType_;
  end;
end;

end.

