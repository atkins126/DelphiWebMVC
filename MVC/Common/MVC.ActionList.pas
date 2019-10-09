unit MVC.ActionList;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, MVC.LogUnit,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Generics.Collections;

type
  TActionItem = class
  private
    FisStop: Integer;
    FAction: TObject;
    FActionName: string;
    FUpDate: TDateTime;
    FisDead: integer;
    Fkey: string;
    procedure SetAction(const Value: TObject);
    procedure SetisStop(const Value: Integer);
    procedure SetActionName(const Value: string);
    procedure SetUpDate(const Value: TDateTime);
    procedure SetisDead(const Value: integer);
  public
    property isStop: Integer read FisStop write SetisStop;
    property Action: TObject read FAction write SetAction;
    property ActionName: string read FActionName write SetActionName;
    property UpDate: TDateTime read FUpDate write SetUpDate;
    property isDead: integer read FisDead write SetisDead;
  end;

type
  TActionList = class
  private
    List: TDictionary<string, TActionItem>;
    function GetGUID: string;
  public
    isstop: boolean;
    function Add(Action: TObject): TActionItem;
    function Get(ActionName: string): TActionItem;
    procedure FreeAction(actionitem: TActionItem);
    constructor Create();
    destructor Destroy; override;
    procedure ClearAction;
  end;

var
  _ActionList: TActionList;

implementation

{ TActionList }
function TActionList.GetGUID: string;
var
  LTep: TGUID;
  sGUID: string;
begin
  CreateGUID(LTep);
  sGUID := GUIDToString(LTep);
  sGUID := StringReplace(sGUID, '-', '', [rfReplaceAll]);
  sGUID := Copy(sGUID, 2, Length(sGUID) - 2);
  result := sGUID;
end;

function TActionList.Add(Action: TObject): TActionItem;
var
  item: TActionItem;
  key: string;
begin
  MonitorEnter(List);
  try
    item := TActionItem.Create;
    item.Action := Action;
    item.isStop := 0;
    item.isDead := 0;
    item.ActionName := Action.ClassName;
    item.UpDate := Now + (1 / 24 / 60) * 1;
    key := GetGUID;
    try
      List.AddOrSetValue(key, item);
    except
     // log('session error2');
    end;
  finally
    MonitorExit(List);
    Result := item;
  end;
end;

procedure TActionList.ClearAction;
var
  item: TActionItem;
  k, i: integer;
  ndate: TDateTime;
  key: string;
  tmp_list: TDictionary<string, TActionItem>;
begin
  MonitorEnter(List);
  try
    tmp_list := TDictionary<string, TActionItem>.Create(List);
  finally
    MonitorExit(List);
  end;
  try
    for key in List.Keys do
    begin
      if isstop then
        break;
      List.TryGetValue(key, item);
      if item <> nil then
      begin
        if (Now() > item.UpDate) then
        begin
          if item.isDead = 0 then
          begin
            item.isDead := 1;
          end
          else if item.isStop = 1 then
          begin
            MonitorEnter(List);
            try
              item.Action.Free;
              item.Free;
              List.Remove(key);
              //log('�Ƴ�Action-'+key);
            finally
              MonitorExit(List);
            end;
          end;
        end;
      end;
      Sleep(100);
    end;
  finally
    tmp_list.Clear;
    tmp_list.Free;
  end;
end;

constructor TActionList.Create;
begin
  List := TDictionary<string, TActionItem>.Create;
end;

destructor TActionList.Destroy;
var
  key: string;
  item: TActionItem;
begin

  for key in List.Keys do
  begin
    List.TryGetValue(key, item);
    if item <> nil then
    begin
      item.Action.Free;
      item.Free;
    end;
  end;
  List.Clear;
  List.Free;

  inherited;
end;

procedure TActionList.FreeAction(actionitem: TActionItem);
begin
  MonitorEnter(List);
  try
    if actionitem <> nil then
      actionitem.isStop := 1;
  finally
    MonitorExit(List);
  end;
end;

function TActionList.Get(ActionName: string): TActionItem;
var
  key: string;
  item: TActionItem;
begin
  Result := nil;
  MonitorEnter(List);
  try
    for key in List.Keys do
    begin
      List.TryGetValue(key, item);
      if item <> nil then
      begin
        if (item.isDead = 0) and (item.isStop = 1) and (item.ActionName = ActionName) then
        begin
          item.isStop := 0;
          item.UpDate := Now + (1 / 24 / 60) * 1;
          Result := item;
          break;
        end;
      end;
    end;
  finally
    MonitorExit(List);
  end;
end;

{ TActionItem }

procedure TActionItem.SetAction(const Value: TObject);
begin
  FAction := Value;
end;

procedure TActionItem.SetActionName(const Value: string);
begin
  FActionName := Value;
end;

procedure TActionItem.SetisDead(const Value: integer);
begin
  FisDead := Value;
end;

procedure TActionItem.SetisStop(const Value: Integer);
begin
  FisStop := Value;
end;

procedure TActionItem.SetUpDate(const Value: TDateTime);
begin
  FUpDate := Value;
end;

end.

