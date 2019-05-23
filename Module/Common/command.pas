{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit Command;

interface

uses
  System.SysUtils, System.Variants, RouleItem, System.Rtti, System.Classes,
  Web.HTTPApp, uConfig, System.DateUtils, SessionList, superobject, uInterceptor,
  uRouleMap, RedisList, LogUnit, uGlobal, System.StrUtils, SynWebConfig;

var
  RouleMap: TRouleMap = nil;
  SessionListMap: TSessionList = nil;
  SessionName: string;
  rooturl: string;
  RTTIContext: TRttiContext;
  _Interceptor: TInterceptor;
  _RedisList: TRedisList;

function OpenConfigFile(): ISuperObject;

function OpenMIMEFile(): ISuperObject;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);

function DateTimeToGMT(const ADate: TDateTime): string;

function StartServer: string;

procedure CloseServer;

procedure setDataBase(jo: ISuperObject);

function StrToParamTypeValue(AValue: string; AParamType: TTypeKind): TValue;

implementation

uses
  wnMain, DES, wnDM, ThSessionClear, FreeMemory, RedisM;

var
  sessionclear: TThSessionClear;
  FreeMemory: TFreeMemory = nil;

procedure OpenRoule(web: TWebModule; RouleMap: TRouleMap; var Handled: boolean);
var
  Action: TObject;
  ActoinClass: TRttiType;
  ActionMethod, CreateView, Interceptor: TRttiMethod;
  Response, Request, ActionPath, ActionRoule: TRttiProperty;
  url, url1: string;
  item: TRouleItem;
  tmp: string;
  methodname: string;
  k: integer;
  ret: TValue;
  s, s1: string;
  sessionid: string;
  //--------�����ṩbegin------------
  i: integer;
  ActionMethonValue: TRttiParameter;
  ActionMethonValues: TArray<TRttiParameter>;
  aValueArray: TArray<TValue>;
  sParameters: string;
  sValue: string;
  //-------�����ṩend--------------
  params: TStringList;
begin

  web.Response.ContentEncoding := document_charset;
  web.Response.Server := 'IIS/6.0';
  web.Response.Date := Now;
  url := LowerCase(web.Request.PathInfo);
  if roule_suffix.Trim <> '' then
  begin
    if RightStr(url, Length(roule_suffix)) = roule_suffix then
      url := url.Replace(roule_suffix, '');
  end;
  k := Pos('.', url);
  if k <= 0 then
  begin
    item := RouleMap.GetRoule(url, url1, methodname);
    if (item <> nil) then
    begin
      ActoinClass := RTTIContext.GetType(item.Action);
      ActionMethod := ActoinClass.GetMethod(methodname);
      CreateView := ActoinClass.GetMethod('CreateView');
      if item.Interceptor then
        Interceptor := ActoinClass.GetMethod('Interceptor');
      Request := ActoinClass.GetProperty('Request');
      Response := ActoinClass.GetProperty('Response');
      ActionPath := ActoinClass.GetProperty('ActionPath');
      ActionRoule := ActoinClass.GetProperty('ActionRoule');
      try
        if (ActionMethod <> nil) then
        begin
          try
            Action := item.Action.Create;
            Request.SetValue(Action, web.Request);
            Response.SetValue(Action, web.Response);
            ActionPath.SetValue(Action, item.path);
            ActionRoule.SetValue(Action, item.Name);
            CreateView.Invoke(Action, []);
            //--------------�����ṩbegin----------------------
            ActionMethonValues := ActionMethod.GetParameters;
            SetLength(aValueArray, Length(ActionMethonValues));
            if Length(item.Name + methodname) = Length(url) then
            begin
              for i := Low(ActionMethonValues) to High(ActionMethonValues) do
              begin
                ActionMethonValue := ActionMethonValues[i];
                sParameters := ActionMethonValue.Name;   //������
                if web.Request.MethodType = mtGet then  //��web.GET����ȡֵ
                  sValue := web.Request.QueryFields.Values[sParameters]
                else
                begin
                  sValue := web.Request.ContentFields.Values[sParameters]; //��web.POST����ȡֵ
                  if sValue = '' then
                    sValue := web.Request.QueryFields.Values[sParameters];
                end;
                aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //���ݲ����������ͣ�ת��ֵ��ֻ������
              end;
            end
            else
            begin
              params := TStringList.Create;
              try
                s1 := item.Name;
                s := Copy(url, Length(s1) + 1, Length(url) - Length(s1));

                params.Delimiter := '/';
                params.DelimitedText := s;
                for i := Low(ActionMethonValues) to High(ActionMethonValues) do
                begin
                  ActionMethonValue := ActionMethonValues[i];
                  if (i < params.Count - 1) then
                    sValue := params.Strings[i + 1]
                  else
                    sValue := '';
                  aValueArray[i] := StrToParamTypeValue(sValue, ActionMethonValue.ParamType.TypeKind); //���ݲ����������ͣ�ת��ֵ��ֻ������
                end;
              finally
                params.Free;
               // FreeAndNil(params);
              end;
            end;


            //-----------------�����ṩend------------------------
            if item.Interceptor then
            begin
              ret := Interceptor.Invoke(Action, []);
              if (not ret.AsBoolean) then
              begin
                ActionMethod.Invoke(Action, aValueArray);
              end;
            end
            else
            begin
              ActionMethod.Invoke(Action, aValueArray);
            end;
          finally
            FreeAndNil(Action);
          end;
        end
        else
        begin
          web.Response.ContentType := 'text/html; charset=' + document_charset;
          s := '<html><body><div style="text-align: left;">';
          s := s + '<div><h1>Error 404</h1></div>';
          s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
          web.Response.Content := s;
          web.Response.SendResponse;
        end;
      finally
        Handled := true;
      end;
    end
    else
    begin
      web.Response.ContentType := 'text/html; charset=' + document_charset;
      s := '<html><body><div style="text-align: left;">';
      s := s + '<div><h1>Error 404</h1></div>';
      s := s + '<hr><div>[ ' + url + ' ] Not Find Page' + '</div></div></body></html>';
      web.Response.Content := s;
      web.Response.SendResponse;
    end;
  end
  else
  begin
    if (not open_debug) and open_cache then
    begin
      web.Response.SetCustomHeader('Cache-Control', 'max-age=' + cache_max_age);
      web.Response.SetCustomHeader('Pragma', 'Pragma');
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now()));
      web.Response.SetCustomHeader('Last-Modified', tmp);
      tmp := DateTimeToGMT(TTimeZone.local.ToUniversalTime(now() + 24 * 60 * 60));
      web.Response.SetCustomHeader('Expires', tmp);
    end
    else
    begin
      web.Response.SetCustomHeader('Cache-Control', 'no-cache,no-store');
    end;
  end;
end;

function StrToParamTypeValue(AValue: string; AParamType: TTypeKind): TValue;
begin

  case AParamType of
    tkInteger, tkInt64:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToInt(AValue);
        except
          Result := 0;
        end;
      end;
    tkFloat:
      begin
        try
          if AValue.Trim = '' then
            AValue := '0';
          Result := StrToFloat(AValue);
        except
          Result := 0;
        end;
      end;
    tkString, tkChar, tkWChar, tkLString, tkWString, tkUString, tkVariant:
      begin
        Result := AValue;
      end;
  else
    begin
      Result := AValue;
      //����������ʱ�ò������Ȳ�����ת��
    end;
//    tkUnknown:;
//    tkEnumeration:;
//    tkSet:;
//    tkClass:;
//    tkMethod:;
//    tkArray:;
//    tkRecord:;
//    tkInterface:;
//    tkDynArray:;
//    tkClassRef:;
//    tkPointer:;
//    tkProcedure:;
//    tkMRecord:;
  end;
end;

function OpenConfigFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
  key: string;
begin
  key := password_key;
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + config);
      txt := f.Text.Trim;
      if Trim(key) = '' then
      begin
        txt := f.Text;
      end
      else
      begin
        txt := string(DeCryptStr(AnsiString(txt), AnsiString(key)));
      end;
      jo := SO(txt);
      jo.O['Server'].s['Port'];
    except
      log(config + '�����ļ�����');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

function OpenMIMEFile(): ISuperObject;
var
  f: TStringList;
  jo: ISuperObject;
  txt: string;
begin
  f := TStringList.Create;
  try
    try
      f.LoadFromFile(WebApplicationDirectory + mime);
      txt := f.Text.Trim;
      jo := SO(txt);
    except
      log(mime + '�����ļ�����');
      jo := nil;
    end;
  finally
    f.Free;
  end;

  Result := jo;
end;

function DateTimeToGMT(const ADate: TDateTime): string;
const
  WEEK: array[1..7] of PChar = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  MonthDig: array[1..12] of PChar = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
var
  wWeek, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec: Word;
  sWeek, sMonth: string;
begin
  DecodeDateTime(ADate, wYear, wMonth, wDay, wHour, wMin, wSec, wMilliSec);
  wWeek := DayOfWeek(ADate);
  sWeek := WEEK[wWeek];
  sMonth := MonthDig[wMonth];
  Result := Format('%s, %.2d %s %d %.2d:%.2d:%.2d GMT', [sWeek, wDay, sMonth, wYear, wHour, wMin, wSec]);
end;

function StartServer: string;
var
  FPort: string;
  jo: ISuperObject;
begin
  _LogList := TStringList.Create;
  _logThread := TLogTh.Create(false);
  FPort := '0000';
  jo := OpenConfigFile();
  try
    try
      if jo <> nil then
      begin
      //����������SynWebApp��ѯ
        SessionName := '__guid_session';
        FPort := jo.O['Server'].s['Port'];
        //////////////////////////////////////////
        syn_Port:=FPort;
        syn_Compress := jo.O['Server'].s['Compress'];
        syn_HTTPQueueLength := jo.O['Server'].i['HTTPQueueLength'];
        syn_ChildThreadCount := jo.O['Server'].i['ChildThreadCount'];
        ////////////////////////////////////////////////////
        _RedisList := nil;
        if jo.O['Redis'] <> nil then
        begin
          Redis_IP := jo.O['Redis'].s['Host'];
          Redis_Port := jo.O['Redis'].i['Port'];
          Redis_PassWord := jo.O['Redis'].s['PassWord'];
          Redis_InitSize := jo.O['Redis'].i['InitSize'];
          Redis_TimeOut := jo.O['Redis'].i['TimeOut'];
          Redis_ReadTimeOut := jo.O['Redis'].i['ReadTimeOut'];
          if redis_ip <> '' then
          begin
            _RedisList := TRedisList.Create(Redis_InitSize);
          end;
        end;

        if auto_free_memory then
          FreeMemory := TFreeMemory.Create(False);
        Global := TGlobal.Create;
        RouleMap := TRouleMap.Create;
        SessionListMap := TSessionList.Create;
        sessionclear := TThSessionClear.Create(false);
        _Interceptor := TInterceptor.Create;
        setDataBase(jo);
      end
      else
      begin
        log('��������ʧ��');
      end;
    except
      on e: Exception do
      begin
        log('��������ʧ��:' + e.Message);
      end;
    end;
  finally
    Result := FPort;
  end;
end;

procedure CloseServer;
begin
  if _RedisList <> nil then
    _RedisList.Free;
  if Global <> nil then
    Global.Free;
  if _Interceptor <> nil then
    _Interceptor.Free;
  if SessionListMap <> nil then
    SessionListMap.Free;
  if RouleMap <> nil then
    RouleMap.Free;
  if DM <> nil then
    DM.Free;
  if _LogList <> nil then
  begin
    _LogList.Clear;
    _LogList.Free;
  end;
  if _logThread <> nil then
  begin
    _logThread.Terminate;
    Sleep(50);
    _logThread.Free;
  end;
  if sessionclear <> nil then
  begin
    sessionclear.Terminate;
    Sleep(50);
    sessionclear.Free;
  end;
  if auto_free_memory and (FreeMemory <> nil) then
  begin
    FreeMemory.Terminate;
    Sleep(50);
    FreeMemory.Free;
  end;
end;

procedure setDataBase(jo: ISuperObject);
var
  oParams: TStrings;
  dbjo, jo1: ISuperObject;
  dbitem, item: TSuperAvlEntry;
  value: string;
begin
  DM := TDM.Create(nil);
  DM.DBManager.Active := false;

  try
    dbjo := jo.O['DBConfig'];
    if dbjo <> nil then
    begin

      for dbitem in dbjo.AsObject do
      begin
        oParams := TStringList.Create;
        jo1 := dbjo.O[dbitem.Name];
        for item in jo1.AsObject do
        begin
          value := item.Name + '=' + item.Value.AsString;
          oParams.Add(value);
        end;
        DM.DBManager.AddConnectionDef(dbitem.Name, dbitem.Name, oParams);
        if open_debug then
          log('���ݿ�����:' + oParams.Text);
        oParams.Free;
      end;
    end;
  finally
    DM.DBManager.Active := true;
  end;
end;

end.

