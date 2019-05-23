{*******************************************************}
{                                                       }
{       DelphiWebMVC                                    }
{                                                       }
{       ��Ȩ���� (C) 2019 ����ӭ(PRSoft)                }
{                                                       }
{*******************************************************}
unit LogUnit;

interface

uses
  System.SysUtils, System.Rtti, System.Classes, Web.HTTPApp, uConfig,
  System.DateUtils, Vcl.StdCtrls;

procedure log(msg: string);

function readlog(var str: TMemo; var msg: string): boolean;

type
  TLogTh = class(TThread)
  public
    procedure writelog(msg: string);
  protected
    procedure Execute; override;
  end;

var
  _LogList: TStringList = nil;
  _logThread: TLogTh = nil;

implementation

uses
  command;

function readlog(var str: TMemo; var msg: string): boolean;
var
  logfile: string;
begin
  Result := false;
  if open_log then
  begin
    logfile := WebApplicationDirectory + 'log\';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';
    if FileExists(logfile) then
    begin
      str.Lines.LoadFromFile(logfile);
      Result := true;
    end
    else
    begin
      msg := logfile + 'δ�ҵ���־�ļ�';
      Result := false;
    end;
  end
  else
  begin
    msg := '��־����δ����';
    Result := false;
  end;
end;

procedure log(msg: string);
begin
  if open_log then
  begin
    _LogList.Add(msg);
  end;
end;

{ TLogTh }

procedure TLogTh.Execute;
var
  k: Integer;
begin
  k := 0;
  while not Terminated do
  begin
    Sleep(10);
    Inc(k);
    if k >= 50 then
    begin
      k := 0;
      if _LogList.Count > 0 then
      begin
        writelog(_LogList.Strings[0]);
        _LogList.Delete(0);
      end;
    end;

  end;
end;

procedure TLogTh.writelog(msg: string);
var
  log: string;
  logfile: string;
  tf: TextFile;
  fi: THandle;
begin
  try
    log := FormatDateTime('yyyy-MM-dd hh:mm:ss', Now) + '  ' + msg;
    logfile := WebApplicationDirectory + 'log\';
    if not DirectoryExists(logfile) then
    begin
      CreateDir(logfile);
    end;
    logfile := logfile + 'log_' + FormatDateTime('yyyyMMdd', Now) + '.txt';

    AssignFile(tf, logfile);
    if FileExists(logfile) then
    begin
      Append(tf);
    end
    else
    begin
      fi := FileCreate(logfile);
      FileClose(fi);
      Rewrite(tf);
    end;
    Writeln(tf, log);
    Flush(tf);
    CloseFile(tf);
  finally
   //   CoUnInitialize;
  end;
end;

end.

