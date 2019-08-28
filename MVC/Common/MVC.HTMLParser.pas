{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{       E-Mail:pearroom@yeah.net                        }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit MVC.HTMLParser;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, FireDAC.Comp.Client, MVC.Page,
  xsuperobject, uConfig, System.RegularExpressions, uDBConfig;

type
  THTMLParser = class
  private
    FDb: TDBConfig;

    procedure foreachother(var text: string);
    procedure foreachinclude(var text: string; param: TStringList; url: string);
    procedure foreachclear(var text: string);
    function foreachvalue(text: string; key: string; value: string; var isok: Boolean): string;
    function foreach(text: string; param: TStringList): string;
    function foreachjson(text: string; key: string; json: ISuperObject; var isok: Boolean): string;
    function foreachsubjson(text: string; key: string; json: ISuperObject; var isok: Boolean): string;
    function foreachlist(text: string; key: string; json: ISuperObject; var isok: boolean): string;
    function foreachsublist(text: string; key: string; json: ISuperObject; var isok: boolean): string;
    function foreachif(text: string; key: string; value: string; var isok: boolean): string;
    function foreachsetif(text: string): string;
    function foreachelseif(text: string): string;
    function checkifwhere(where: string): boolean;
    procedure SetDb(const Value: TDBConfig);
  public
    property Db: TDBConfig read FDb write SetDb;
    procedure Parser(var text: string; param: TStringList; url: string);
    constructor Create();
  end;

implementation

uses
  XSuperJSON;

function THTMLParser.foreachvalue(text, key, value: string; var isok: Boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
begin
  //matchs := TRegEx.Matches(text, '#\{(([\s\S])*?)\}');
  isok := false;
  s := '#{' + key + '}';
  matchs := TRegEx.Matches(text, s);
  for match in matchs do
  begin
    if match.Value = s then
    begin
      text := text.Replace(match.Value, value);
      isok := true;
    end;
  end;
  Result := text;
end;

procedure THTMLParser.Parser(var text: string; param: TStringList; url: string);
begin

  foreachinclude(text, param, url);
  text := foreach(text, param);
  foreachclear(text);
  foreachother(text);
end;

procedure THTMLParser.SetDb(const Value: TDBConfig);
begin
  FDb := Value;
end;

function THTMLParser.checkifwhere(where: string): boolean;
var
  sn: Integer;
begin
  where := where.Replace('neq', ' != ');
  where := where.Replace('eq', ' = ');
  where := where.Replace('and', ' and ');
  where := where.Replace('or', ' or ');
  where := where.Replace('gte', ' >= ').Replace('ge', ' >= ');
  where := where.Replace('gt', ' >= ');
  where := where.Replace('lte', ' <= ').Replace('le', ' <= ');
  where := where.Replace('lt', ' < ');
  where := where.Replace('==', ' = ');
  try
    Db.Default.TMP_CDS.Open('select ' + where + ' as sn');
    sn := Db.Default.TMP_CDS.FieldByName('sn').AsInteger;
    Result := sn = 1;
  except
    Result := false;
  end;
end;

constructor THTMLParser.Create();
begin
end;

function THTMLParser.foreach(text: string; param: TStringList): string;
var
  i: Integer;
  key, value: string;
  jo: ISuperObject;
  html: string;
  isok: boolean;
  tmpstr: TStringList;
begin
  html := text;
  tmpstr := TStringList.Create;
  try
    for i := 0 to param.Count - 1 do
    begin
      key := param.Names[i];
      value := param.ValueFromIndex[i];
      try
   //     jo := SO(value);
        if (pos('{', value) > 0) and (pos('}', value) > 0) then
          isok := true
        else
          isok := false;
      except
        isok := false;
      end;
      if not isok then
      begin
        html := foreachvalue(html, key, value, isok);
        if isok then
        begin
          tmpstr.Add(key);
        end;
      end;
    end;
    for i := 0 to tmpstr.Count - 1 do
    begin
      param.Delete(param.IndexOfName(tmpstr.Strings[i]));
    end;
    tmpstr.Clear;
    for i := 0 to param.Count - 1 do
    begin
      key := param.Names[i];
      value := param.ValueFromIndex[i];
      jo := SO(value);
      if jo.DataType = TDataType.dtObject then
      begin
        html := foreachjson(html, key, jo, isok);
        if isok then
        begin
          tmpstr.Add(key);
        end;
      end
      else if jo.DataType = TDataType.dtArray then
      begin
        html := foreachlist(html, key, jo, isok);
        if isok then
        begin
          tmpstr.Add(key);
        end;
      end
      else
      begin
        html := foreachif(html, key, value, isok);
      end;
    end;
    for i := 0 to tmpstr.Count - 1 do
    begin
      param.Delete(param.IndexOfName(tmpstr.Strings[i]));
    end;
  finally
    tmpstr.Clear;
    tmpstr.Free;
  end;
  param.Clear;

  html := foreachsetif(html);
  Result := html;
end;

procedure THTMLParser.foreachclear(var text: string);
var
  matchs: TMatchCollection;
  match: TMatch;
begin
  matchs := TRegEx.Matches(text, '#\{[\s\S]*?\}');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
  matchs := TRegEx.Matches(text, '<#list[\s\S]*?</#list>');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
  matchs := TRegEx.Matches(text, '<#if[\s\S]*?</#if>');
  for match in matchs do
  begin
    text := TRegEx.Replace(text, match.Value, '');
  end;
end;

function THTMLParser.foreachelseif(text: string): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue: string;
  strls: TStringList;
  html: string;
  isok: Boolean;
begin
  isok := False;
  strls := TStringList.Create;
  try
    matchs := TRegEx.Matches(text, 'if[\s\S]*?<#else');
    for match in matchs do
    begin
      strls.Text := match.Value;
      s := TRegEx.Replace(strls.Text, 'if.*?>', '');
      s := TRegEx.Replace(s, '<#else', '');
      html := s;
      datavalue := Trim(TRegEx.Match(strls.Text, 'if.*?>').value);
      datavalue := datavalue.Replace('if', '');
      datavalue := datavalue.Replace('>', '');
      datavalue := datavalue.Replace(' ', '');
      datavalue := datavalue.Replace('''', '');
      if checkifwhere(datavalue) then
      begin
        text := html;
        isok := true;
        break;
      end;
    end;

    if not isok then
    begin
      matchs := TRegEx.Matches(text, 'if(([\s\S])*?)</#if>');
      for match in matchs do
      begin
        if match.Value.IndexOf('else') < 0 then
        begin
          strls.Text := match.Value;
          s := TRegEx.Replace(strls.Text, 'if.*?>', '');
          s := TRegEx.Replace(s, '</#', '');
          html := s;
          datavalue := Trim(TRegEx.Match(strls.Text, 'if.*?>').value);
          datavalue := datavalue.Replace('if', '');
          datavalue := datavalue.Replace('>', '');
          datavalue := datavalue.Replace(' ', '');
          datavalue := datavalue.Replace('''', '');
          if checkifwhere(datavalue) then
          begin
            text := html;
            isok := true;
            break;
          end;
        end;
      end;
    end;
    if not isok then
    begin
      matchs := TRegEx.Matches(text, '<#else>[\s\S]*?</#if>');
      for match in matchs do
      begin
        strls.Text := match.Value;
        s := TRegEx.Replace(strls.Text, '<#else>', '');
        s := TRegEx.Replace(s, '</#if>', '');
        text := s;
        isok := true;
        Break;
      end;
    end;
    if not isok then
    begin
      text := '';
    end;
    Result := text;
  finally
    strls.Free;
  end;
end;

function THTMLParser.foreachif(text, key, value: string; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
begin

  s := text;
  isok := false;

  matchs := TRegEx.Matches(text, '<#if.*' + key + '[\s\S]*?>');
  for match in matchs do
  begin
    s := TRegEx.Replace(text, key, value);
    text := s;
    isok := true;
  end;
  Result := text;
end;

procedure THTMLParser.foreachinclude(var text: string; param: TStringList; url: string);
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
  htmlfile: string;
  page: TPage;
begin
  matchs := TRegEx.Matches(text, '<#include.*file=[\s\S]*?\>');

  for match in matchs do
  begin
    s := match.Value;
    s := s.Replace('__APP__', '');
    begin
      htmlfile := Trim(TRegEx.Match(s, 'file=.*?>').value);
      htmlfile := Copy(htmlfile, Pos('=', htmlfile) + 1, Pos('>', htmlfile) - Pos('=', htmlfile) - 1);
      htmlfile := Trim(htmlfile);
      if htmlfile[htmlfile.Length] = '/' then
      begin
        htmlfile := Copy(htmlfile, 0, htmlfile.Length - 1);
        htmlfile := Trim(htmlfile);
      end;
      htmlfile := htmlfile.Replace('''', '').Replace('"', '');
      if (htmlfile.IndexOf('/') = 0) then
        htmlfile := WebApplicationDirectory + template + htmlfile
      else
        htmlfile := url + htmlfile;
      if (Trim(htmlfile) <> '') then
      begin
        if (not FileExists(htmlfile)) then
        begin
          text := '';
        end
        else
        begin
          try
            page := TPage.Create(htmlfile, param, url);
            text := TRegEx.Replace(text, match.Value, page.HTML);
          finally
            FreeAndNil(page);
          end;
          foreachinclude(text, param, url);
        end;
      end;
    end;
  end;
end;

function THTMLParser.foreachjson(text, key: string; json: ISuperObject; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, html: string;
begin
  html := text;
  isok := false;
//  if json.IsType(TSuperType.stObject) then
  begin
    json.First;
    while not json.EoF do
    begin
      if json.DataType <> TDataType.dtArray then
      begin
        html := foreachif(html, key + '.' + json.CurrentKey, json.CurrentValue.AsVariant, isok);
        s := '#{' + key + '.' + json.CurrentKey + '}';
        matchs := TRegEx.Matches(html, s);
        for match in matchs do
        begin
          if match.Value = s then
          begin
            html := html.Replace(match.Value, json.CurrentValue.AsVariant);
            isok := true;
          end;
        end;
      end
      else
      begin
        html := foreachsublist(html, key + '.' + json.CurrentKey, so(json.CurrentValue.AsVariant), isok);
      end;
      json.Next;
    end;

  end;

  Result := html;
end;

function THTMLParser.foreachlist(text, key: string; json: ISuperObject; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue, itemvalue: string;
  strls: TStringList;
  html, html1: string;
  arr: ISuperArray;
  I: Integer;
begin
  strls := TStringList.Create;

  arr := json.AsArray;
  isok := false;
  matchs := TRegEx.Matches(text, '<#list.*data=' + key + ' [\s\S]*?</#list>');
  try
    for match in matchs do
    begin
      strls.Text := match.Value;

      s := TRegEx.Replace(strls.Text, '<#list.*?>', '');
      s := TRegEx.Replace(s, '</#list>', '');
      html1 := s;
      s := Trim(TRegEx.Match(strls.Text, '<#list.*?>').value);
      datavalue := Trim(TRegEx.Match(s, 'data=.*? ').value);
      itemvalue := Trim(TRegEx.Match(s, 'item=.*?>').value.Replace('>', ''));
      datavalue := Copy(datavalue, 6, Length(datavalue) - 5);
      itemvalue := Copy(itemvalue, 6, Length(itemvalue) - 5);
      if datavalue = key then
      begin
        for I := 0 to arr.Length - 1 do
        begin
          html := html + foreachjson(html1, itemvalue, arr.O[I].AsObject, isok);
        end;
        html := foreachsetif(html);
        text := text.Replace(match.Value, html);
        isok := true;
      end;
    end;

    Result := text;
  finally
    strls.Clear;
    strls.Free;
  end;
end;

procedure THTMLParser.foreachother(var text: string);
var
  matchs: TMatchCollection;
  match: TMatch;
begin

  matchs := TRegEx.Matches(text, '__APP__');
  for match in matchs do
  begin
    if __APP__.Trim = '' then
      text := TRegEx.Replace(text, match.Value, '')
    else
      text := TRegEx.Replace(text, match.Value, '/' + __APP__)

  end;
end;

function THTMLParser.foreachsetif(text: string): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s: string;
  html: string;
begin

  matchs := TRegEx.Matches(text, '<#if[\s\S]*?</#if>');
  for match in matchs do
  begin
    html := foreachelseif(match.Value);
    s := text.Replace(match.Value, html);
    text := s;
  end;

  Result := text;
end;

function THTMLParser.foreachsubjson(text, key: string; json: ISuperObject; var isok: Boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, html: string;
begin
  html := text;
  isok := false;
 // if json.IsType(TSuperType.stObject) then
  begin
    json.First;
    while not json.EoF do
    begin

      html := foreachif(html, key + '.' + json.CurrentKey, json.CurrentValue.AsVariant, isok);
      s := '#{' + key + '.' + json.CurrentKey + '}';
      matchs := TRegEx.Matches(html, s);
      for match in matchs do
      begin
        if match.Value = s then
        begin
          html := html.Replace(match.Value, json.CurrentValue.AsVariant);
          isok := true;
        end;
      end;
    end;
  end;

  Result := html;
end;

function THTMLParser.foreachsublist(text, key: string; json: ISuperObject; var isok: boolean): string;
var
  matchs: TMatchCollection;
  match: TMatch;
  s, datavalue, itemvalue: string;
  strls: TStringList;
  html, html1: string;
  arr: ISuperArray;
  I: Integer;
begin
  strls := TStringList.Create;

  arr := json.AsArray;
  isok := false;
  matchs := TRegEx.Matches(text, '<#sublist.*data=' + key + ' [\s\S]*?</#sublist>');
  try
    for match in matchs do
    begin
      strls.Text := match.Value;

      s := TRegEx.Replace(strls.Text, '<#sublist.*?>', '');
      s := TRegEx.Replace(s, '</#sublist>', '');
      html1 := s;
      s := Trim(TRegEx.Match(strls.Text, '<#sublist.*?>').value);
      datavalue := Trim(TRegEx.Match(s, 'data=.*? ').value);
      itemvalue := Trim(TRegEx.Match(s, 'item=.*?>').value.Replace('>', ''));
      datavalue := Copy(datavalue, 6, Length(datavalue) - 5);
      itemvalue := Copy(itemvalue, 6, Length(itemvalue) - 5);
      if datavalue = key then
      begin
        for I := 0 to arr.Length - 1 do
        begin
          html := html + foreachsubjson(html1, itemvalue, arr.O[I], isok);
        end;
        html := foreachsetif(html);
        text := text.Replace(match.Value, html);
        isok := true;
      end;
    end;

    Result := text;
  finally
    strls.Clear;
    strls.Free;
  end;
end;

end.

