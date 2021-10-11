unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure WMActivate(var msg: TWMActivate);
    message WM_ACTIVATE;
  public
    { Public declarations }
  end;

var
 Form1: TForm1;

implementation

{$R *.DFM}

function ForceForeground(AppHandle: HWND): boolean;
const
 SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
 SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
 ForegroundThreadID: DWORD;
 ThisThreadID      : DWORD;
 timeout           : DWORD;
 OSVersionInfo     : TOSVersionInfo;
 Win32Platform     : Integer;
begin
 if IsIconic(AppHandle)
 then ShowWindow(AppHandle, SW_RESTORE);

 if (GetForegroundWindow = AppHandle)
 then Result := true
 else
  begin
   Win32Platform := 0;
   OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);

   if GetVersionEx(OSVersionInfo)
   then Win32Platform := OSVersionInfo.dwPlatformId;

   // Windows 98/2000 ne veulement pas mettre une fenêtre en 1er plan quand d'autre fenêtre ont le focus

   if ((Win32Platform = VER_PLATFORM_WIN32_NT)
    and (OSVersionInfo.dwMajorVersion > 4))
    or ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS)
    and ((OSVersionInfo.dwMajorVersion > 4)
    or ((OSVersionInfo.dwMajorVersion = 4)
    and (OSVersionInfo.dwMinorVersion > 0))))
   then
    begin
     Result := false;
     ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow,nil);
     ThisThreadID := GetWindowThreadPRocessId(AppHandle,nil);

     if AttachThreadInput(ThisThreadID, ForegroundThreadID, true)
     then
      begin
       BringWindowToTop(AppHandle);
       SetForegroundWindow(AppHandle);
       AttachThreadInput(ThisThreadID, ForegroundThreadID, false);
       Result := (GetForegroundWindow = AppHandle);
      end;

    if not Result
    then
     begin
      SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
      SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0), SPIF_SENDCHANGE);
      BringWindowToTop(AppHandle);
      SetForegroundWindow(AppHandle);
      SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
      Result := (GetForegroundWindow = AppHandle);

      if not Result
      then
       begin
        ShowWindow(AppHandle,SW_HIDE);
        ShowWindow(AppHandle,SW_SHOWMINIMIZED);
        ShowWindow(AppHandle,SW_SHOWNORMAL);
        BringWindowToTop(AppHandle);
        SetForegroundWindow(AppHandle);
       end;
     end;
    end
   else
    begin
     BringWindowToTop(AppHandle);
     SetForegroundWindow(AppHandle);
    end;
   Result := (GetForegroundWindow = AppHandle);
  end;
end;

procedure TForm1.WMActivate(var msg: TWMActivate);
begin
 if msg.Active = WA_INACTIVE
 then ForceForeground(handle);

 inherited;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Application.Title:='Test focus';
end;

end.
