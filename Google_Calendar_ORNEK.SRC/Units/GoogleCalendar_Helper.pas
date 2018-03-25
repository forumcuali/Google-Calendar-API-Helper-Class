{***************************************************************************}
{                                                                           }
{                         Google Calendar API Class                         }
{                                                                           }
{                    Copyright (C) 2018 Muharrem ARMAN                      }
{                         muharrem.arman@trt.net.tr                         }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Google Calendar API Servisinden Yard�m alarak                            }
{  Yayg�nla�an Mobil cihazlar�n Takvim varsay�lan� olan Google Takvim       }
{  otomatik Event olu�turmak / silmek / g�ncellemek vb. i�lemler i�in       }
{  kullan�lmaktad�r.                                                        }
{                                                                           }
{  USES listesine bu UNIT'in eklenmesi yeterlidir.                          }
{  Ekstra bir tan�mlamaya gerek yoktur.                                     }
{  kendili�inden nesneyi Create edecek, ��karken de FREE edecektir          }
{                                                                           }
{  Kullan�m� :                                                              }
{ (1) Formunuzun OnCreate olay�na da a�a��daki size �zel tan�mlar� yap�n�z. }
{                                                                           }
{                                                                           }
{  xGoogleCal.Api_Key       := 'AIzaSy...........................uPW5lM';   }
{  xGoogleCal.Client_Id     := '705649...........................umcrfnb0fam}
{  xGoogleCal.Client_secret := 'gMhN.................GtX';                  }
{  xGoogleCal.Scopes        := 'https://www.googleapis.com/auth/calendar';  }
{  xGoogleCal.Auth_Uri      := 'https://accounts.google.com/o/oauth2/auth'; }
{  xGoogleCal.Token_Uri     := 'https://accounts.google.com/o/oauth2/token';}
{  xGoogleCal.Redirect_Uris := 'urn:ietf:wg:oauth:2.0:oob';                 }
{  xGoogleCal.CalendarID    := 'delphicanapi@gmail.com';                    }
{                                                                           }
{  xGoogleCal.Log           := Memo1.Lines; // LOG Kayd� Laz�m olursa       }
{                                                                           }
{  �zerinde de�i�iklik yapmak serbesttir ancak l�tfen bu etiket blo�u       }
{  i�ine yapt���n�z de�i�ikli�i ve k�nyenizi yazmay� ihmal etmeyiniz.       }
{                                                                           }
{***************************************************************************}
{  De�i�ikli�i Yapan,  Yap�lan Ekleme/De�i�iklik bilgisi :                  }
{                                                                           }
{                                                                           }
{                                                                           }
{***************************************************************************}
//{$DEFINE SSL_DLLs_inResourceMode}
unit GoogleCalendar_Helper;

interface
Uses
//  ShareMem, // Indy Bile�en olmayan ama varm�� gibi rapor edilen Memory Leak
              // Sorununa k�kten ��z�m oluyordu...
              // Ancak bilgisayarlarda "Borlndmm.dll" ihtiyac� do�uyor ondan kald�rd�m.
    Windows, Forms, Graphics, Controls, GifImg, Dialogs, SysUtils, Classes, Variants,
    ShellApi, SHDocVw, DateUtils, MSHTML, ComObj,
    IdHttp, IdGlobal, IdSSLOpenSSL, IdAntiFreeze, IdThread;

Type
  pAPIClientInfo = ^tAPIClientInfo;
  tAPIClientInfo = Record
      Api_Key                      : String;
      Client_Id                    : String;
      Project_Id                   : String;
      Client_Secret                : String;
      Scopes                       : String;
      Auth_Uri                     : String;
      Token_Uri                    : String;
      Redirect_Uris                : String;
end;

Type
  pAttendeesRecord = ^tAttendeesRecord;
  tAttendeesRecord = Record
      attEmail     : String;
      attDispName  : String;
      attComment   : String;
    //attId        : String;
    //attOrganizer : Boolean;
      attResponses : String;
end;

Type
  pCalEventRecord = ^tCalEventRecord;
  tCalEventRecord = Record
     EventId     : string;
     BasTar      : TDateTime;
     BitTar      : TDateTime;
     TimeZone    : String;
     boolTumGun  : Boolean;
     description : String;
     colorId     : Integer;
     location    : String;
     summary     : String;
     creaDispName: String;
     creaEmail   : String;
     creaId      : String;
     Attendees   : Array of pAttendeesRecord;
     EventStatus : String;
end;

Type
  TSorguTipi = ( stGET, stPOST, stDELETE, stGET_KEYParam, stPOST_KEYParam, stDELETE_KEYParam, stPUT_KEYParam );

Type
  TGoogleCal_Helper = Class(TObject)
  private
    Const
      FCalendarUri  = 'https://www.googleapis.com/calendar/v3/calendars/';
    Var
      Fapi_Key                      : String;
      Fclient_id                    : String;
      Fclient_secret                : String;
      FScopes                       : String;
      Fauth_uri                     : String;
      Ftoken_uri                    : String;
      Fredirect_uris                : String;

      FAuth20_Code                  : String;
      FLog                          : TStrings;
      FAccess_Token                 : String;
      FExpires_In                   : String;
      FRefresh_Token                : String;
      FToken_Type                   : String;
      FCalendarID                   : String;
      FLoginGmail                   : string;
      FLoginPass                    : string;
      FDebugMode                    : boolean;

    function  EncodeURI(const ASrc: string): UTF8String;
    function  WEBIslemler( aType: TSorguTipi; aUrl : String; boolJSON:boolean = false; slParam: TStringList = nil ): String;
    procedure LOGla( strIcerik: String );
  public
    constructor Create;
    destructor  Destroy; Override;
    function    GoogleOAUTH_01: string;
    function    GoogleOAUTH_02: string;
    property    CalendarID    : string read FCalendarID Write FCalendarID;
    property    Api_Key       : string read FApi_Key Write FApi_Key;
    property    Client_Id     : string read Fclient_id Write Fclient_id;
    property    Client_Secret : string read FClient_Secret Write FClient_Secret;
    property    Scopes        : string read FScopes Write FScopes;
    property    Auth_Uri      : string read FAuth_Uri Write FAuth_Uri;
    property    Token_Uri     : string read FToken_Uri Write FToken_Uri;
    property    Redirect_Uris : string read FRedirect_Uris Write FRedirect_Uris;
    property    LoginGmail    : string read FLoginGmail Write FLoginGmail;
    property    LoginPass     : string read FLoginPass Write FLoginPass;
    property    DebugMode     : boolean read FDebugMode Write FDebugMode;
    function    ReferansKontol: String;
    property    Log           : TStrings read FLog Write FLog;
    property    AccessToken   : string read FAccess_Token;
    function    CalEventList  ( boolDeleted:boolean=false; aBasTar:TDateTime=0; aBitTar: TDateTime=0; aTimeZone:String='+03:00' ): String;
    procedure   CalEventIDs   ( Liste : TStrings; aBasTar:TDateTime=0; aBitTar: TDateTime=0; boolDeleted:boolean=false );
    function    CalEventEkle  ( aEvent: pCalEventRecord ): String;
    function    CalEventUpdate( strEventID:String; aEvent: pCalEventRecord ): String;
    function    CalEventSil( aEventId: String ): String;
    function    CalEventFromID(aEventId: String): String;
    function    ParseEvent(strIcerik: String): pCalEventRecord;
    function    AradanSec(var strIcerik: String; strBas, strSon: String; boolTrim:boolean=false ): string;
    function    APIClientInfo( strJSON:String ): pAPIClientInfo;
  end;

type
{ TIdHTTP } // DoRequest() TIdHttp s�n�f�n�n "Private" alanda oldu�undan
            // bu �ekilde kullanabildik. Public yeni bir procedure elde ettik.
  TIdHTTP = class(IdHTTP.TIdHTTP)
  public
    procedure DeleteEx(AURL: string; AResponseContent: TStream);
  end;


Var
  xGoogleCal : TGoogleCal_Helper;

implementation

{$IFDEF SSL_DLLs_inResourceMode}
   {$R RES\RES.RES} // SSL DLL'leri Resource olarak sakland���nda laz�m...
                    // Lisans sorunu olmas�n diye projeden ��kard�m....
                    // OpenSSL k�t�phanesi sonu�ta nette her yerde var.
{$ENDIF}

{ TIdHTTP } // DoRequest() TIdHttp s�n�f�n�n "Private" alanda oldu�undan
            // bu �ekilde kullanabildik. Public yeni bir procedure elde ettik.
procedure TIdHTTP.DeleteEx(AURL: string; AResponseContent: TStream);
begin      // Ne i�in ekledik, GET, POST, PUT gibi bir de DELETE metodunu istiyoruz.
  DoRequest(Id_HTTPMethodDelete, AURL, nil, AResponseContent, []);
end;

function TGoogleCal_Helper.ReferansKontol(): String;
begin
  Result := '';
  if FLoginGmail     = ''  then Result := Result + #13 + 'LoginGmail bilgisi Tan�mlanmam��';
  if FLoginPass      = ''  then Result := Result + #13 + 'LoginPass bilgisi Tan�mlanmam��';
  if FApi_Key        = ''  then Result := Result + #13 + 'Api_Key bilgisi Tan�mlanmam��';
  if Fclient_id      = ''  then Result := Result + #13 + 'Client_Id     bilgisi Tan�mlanmam��';
  if Fclient_secret  = ''  then Result := Result + #13 + 'Client_Secret bilgisi Tan�mlanmam��';
  if FScopes         = ''  then Result := Result + #13 + 'Scopes        bilgisi Tan�mlanmam��';
  if Fauth_uri       = ''  then Result := Result + #13 + 'Auth_Uri      bilgisi Tan�mlanmam��';
  if Ftoken_uri      = ''  then Result := Result + #13 + 'Token_Uri     bilgisi Tan�mlanmam��';
  if Fredirect_uris  = ''  then Result := Result + #13 + 'Redirect_Uris bilgisi Tan�mlanmam��';
end;

constructor TGoogleCal_Helper.Create;
begin
  Inherited;  // Create'de  daima ba�ta call edicez...
  //...
  FCalendarID := 'primary'; // Varsay�lan Takvim
end;

destructor TGoogleCal_Helper.Destroy;
begin
  //...
  // Indy paketi asl�nda MemoryLeak OLMAYAN Leak Warning i�in... Ref: "Remy Lebeau"
  if GThreadCount <> Nil then GThreadCount.Free;
  Inherited;  // Destroy'da daima sonda call edicez...
end;

function TGoogleCal_Helper.EncodeURI(const ASrc: string): UTF8String;
const
  HexMap: UTF8String = '0123456789ABCDEF';
  function IsSafeChar(ch: Integer): Boolean;
  begin
         if (ch >= 48) and (ch <=  57) then Result := True  // 0-9
    else if (ch >= 65) and (ch <=  90) then Result := True  // A-Z
    else if (ch >= 97) and (ch <= 122) then Result := True  // a-z
    else if (ch =  33) then Result := True // !
    else if (ch >= 39) and (ch <=  42) then Result := True  // '()*
    else if (ch >= 45) and (ch <=  46) then Result := True  // -.
    else if (ch =  95) then Result := True // _
    else if (ch = 126) then Result := True // ~
    else Result := False;
  end;
var
  I, J    : Integer;
  ASrcUTF8: UTF8String;
begin
  Result := '';
  ASrcUTF8 := UTF8Encode(ASrc);
  // UTF8Encode gerekli de�il, d�n��t�rme uyar�s�n� vermesin diye eklendi

  I := 1; J := 1;
  SetLength(Result, Length(ASrcUTF8) * 3); // her byte i�in %xx yer ayr�l�yor

  while I <= Length(ASrcUTF8) do
  begin
    if IsSafeChar(Ord(ASrcUTF8[I])) then
    begin
      Result[J] := ASrcUTF8[I];
      Inc(J);
    end
    else if ASrcUTF8[I] = ' ' then
    begin
      Result[J] := '+';
      Inc(J);
    end
    else
    begin
      Result[J  ] := '%';
      Result[J+1] := HexMap[(Ord(ASrcUTF8[I]) shr  4) + 1];
      Result[J+2] := HexMap[(Ord(ASrcUTF8[I]) and 15) + 1];
      Inc(J,3);
    end;
    Inc(I);
  end;

  SetLength(Result, J-1);
end;

function SetDllDirectory(lpPathName:PWideChar): Bool; stdcall; external 'kernel32.dll' name 'SetDllDirectoryW';

function TGoogleCal_Helper.WEBIslemler( aType: TSorguTipi; aUrl : String; boolJSON:boolean = false; slParam: TStringList = nil ): String;
  function GetTempDir: string;
  var
    TempDir:     DWORD;
  begin
    SetLength(Result, MAX_PATH);
    TempDir := GetTempPath(MAX_PATH, PChar(Result));
    SetLength(Result, TempDir);
  end;

  function IsFileInUse(fName: string) : boolean;
  var
    HFileRes: HFILE;
  begin
    Result := False;
    if not FileExists(fName) then begin
      Exit;
    end;

    HFileRes := CreateFile(PChar(fName)
      ,GENERIC_READ or GENERIC_WRITE
      ,0
      ,nil
      ,OPEN_EXISTING
      ,FILE_ATTRIBUTE_NORMAL
      ,0);

    Result := (HFileRes = INVALID_HANDLE_VALUE);

    if not(Result) then begin
      CloseHandle(HFileRes);
    end;
  end;
Const
  E400 = '400: �a�r� ge�ersiz, parametreleri kontrol ediniz...';
  E401 = '401: �nce Login olmal�s�n�z...';
  E409 = '409: Ayn� id ile event kayd� ekleyemezsiniz...';
  E410 = '410: Verilen id''ye ili�kin event bulunamad�...';

Var
  OpenSSL          : TIdSSLIOHandlerSocketOpenSSL;
  IdHttp           : TIdHttp;
  AResponseContent : TStringStream;
  Req_Json         : TStream;
{$IFDEF SSL_DLLs_inResourceMode}
  a,b : Integer;
{$ENDIF}
begin
  Result := '';
  if (aType = stPost) and (slParam = nil) then Exit;

  if Pos('https', aUrl ) > 0  then
  begin // HTTPS eri�im yap�lacak...
        // OpenSSL k�t�phaneleri Gerekli.

{$IFDEF SSL_DLLs_inResourceMode}
 // SSL K�t�phaneleri lisans sorunu yaratmas�n diye RESOURCE alt�ndan ��kard�m.
    {$IF CompilerVersion >= 22.0} a := 3; b := 4;  // XE
    {$ELSE}                       a := 1; b := 2;  // D7 = 15.0
    {$IFEND}
      if NOT IsFileInUse( GetTempDir + 'ssleay32.dll' ) then
      With TResourceStream.Create(HInstance, Format('ssl_%.2d', [a]), RT_RCDATA) do
      begin
        Try
          SaveToFile( GetTempDir + 'ssleay32.dll' );
        Except
          // Dosya A��k
        End;
        Free;
      end;

    //if NOT FileExists(GetTempDir + 'libeay32.dll') then
      if NOT IsFileInUse( GetTempDir + 'libeay32.dll' ) then
      With TResourceStream.Create(HInstance, Format('ssl_%.2d', [b]), RT_RCDATA) do
      begin
        Try
          SaveToFile( GetTempDir + 'libeay32.dll' );
        Except
          // Dosya A��k
        End;
        Free;
      end;
 // Bendeki Indy s�r�m� ile uyumsuzdu... Alttaki �ekilde de�i�tirdim...
 // IdSSLOpenSSLHeaders.IdOpenSSLSetLibPath( GetTempDir );
 // IdSSLOpenSSLHeaders.Load;

 // SSL DLL'lerini RES i�inden TempDir'e ald�k...
    SetDllDirectory( StringToOLEStr(GetTempDir) );
{$ENDIF}


  end;

  OpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);
  With OpenSSL do begin
    MaxLineAction          := IdGlobal.maSplit;
    ConnectTimeout         := 15000;
    SSLOptions.Method      := sslvSSLv23;
    SSLOptions.Mode        := sslmUnassigned;
    SSLOptions.VerifyMode  := [];
    SSLOptions.VerifyDepth := 0;
  end;

  IdHttp  := TIdHttp.Create(nil);
  With IdHTTP do begin
    ConnectTimeout         := 10000;
    ReadTimeout            := 10000;
    IOHandler              := OpenSSL;
    Request.ContentType    := 'application/x-www-form-urlencoded';
    Request.Accept         := 'Accept=text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    Request.UserAgent      := 'Mozilla/3.0 (compatible; Indy Library)';
    Request.BasicAuthentication     := False;
    ProxyParams.BasicAuthentication := False;
    ProxyParams.ProxyPort  := 0;
    HTTPOptions            := [hoForceEncodeParams];
    HandleRedirects        := True;
  end;

  AResponseContent := TStringStream.Create('');
  Try
    if aType in [stGET_KEYParam, stPOST_KEYParam, stDELETE_KEYParam, stPUT_KEYParam] then
    begin
      IdHttp.Request.CustomHeaders.Values['Authorization'] := 'Bearer' + ' ' + FAccess_Token;

      if boolJSON then With IdHttp do
      begin
        HTTPOptions                         := [hoForceEncodeParams];
        AllowCookies                        := True;
        HandleRedirects                     := True;
        ProxyParams.BasicAuthentication     := False;
        ProxyParams.ProxyPort               := 0;
        Request.ContentLength               := -1;
        Request.ContentRangeEnd             := 0;
        Request.ContentRangeStart           := 0;
        Request.ContentRangeInstanceLength  := 0;
        Request.ContentType         := 'application/json';
        Request.Accept              := 'application/json;odata=verbose;';
        Request.BasicAuthentication := False;
        Request.UserAgent           := 'Mozilla/3.0 (compatible; Indy Library)';
        Request.CustomHeaders.Values['DataServiceVersion'] := '2.0';
      end;
    end;

    case aType of
    stDELETE, stDELETE_KEYParam:
      begin
        try
          IdHttp.DeleteEx( aUrl, AResponseContent );
        except on E: EIdHTTPProtocolException do
          case E.ErrorCode of
          400: MessageDlg( E400, mtError, [mbOk], 0 );
          401: MessageDlg( E401, mtError, [mbOk], 0 );
          410: MessageDlg( E410, mtError, [mbOk], 0 );
          else InputBox('stDELETE','Hata ' + IntToStr(E.ErrorCode), E.Message );
          end;// Case
        end;
      end;
    stGET, stGET_KEYParam:
      begin
        Try
          LOGLa( 'stGET, stGET_KEYParam : ' + aURL );
          IdHttp.Get( aUrl, AResponseContent );
        except on E: EIdHTTPProtocolException do
          case E.ErrorCode of
          400: MessageDlg( E400, mtError, [mbOk], 0 );
          401: MessageDlg( E401, mtError, [mbOk], 0 );
          else InputBox('stGET','Hata ' + IntToStr(E.ErrorCode), E.Message );
          end;// Case
        end;
      end;
    stPOST, stPOST_KEYParam:
      begin
        if boolJSON
        then begin
          Req_Json := TStringStream.Create( slParam.Text );
          try
            Req_Json.Position := 0;
            FLog.LoadFromStream( Req_Json );
            Req_Json.Position := 0;
            try
              IdHttp.Post( aUrl, Req_Json, AResponseContent );
            except on E: EIdHTTPProtocolException do
              case E.ErrorCode of
              400: MessageDlg( E400, mtError, [mbOk], 0 );
              401: MessageDlg( E401, mtError, [mbOk], 0 );
              409: MessageDlg( E409, mtError, [mbOk], 0 );
              410: MessageDlg( E410, mtError, [mbOk], 0 );
              else InputBox('stPOST','Hata ' + IntToStr(E.ErrorCode), E.Message );
              end;// Case
            end;
          finally
            Req_Json.Free;
          end;
        end
        else begin
          try
            IdHttp.Post( aUrl, slParam, AResponseContent );
          except on E: EIdHTTPProtocolException do
            case E.ErrorCode of
            400: MessageDlg( E400, mtError, [mbOk], 0 );
            401: MessageDlg( E401, mtError, [mbOk], 0 );
            else InputBox('stPOST_ELSE','Hata', E.Message );
            end;// Case
          end;
        end;
      end;
    stPUT_KEYParam :
      begin
        //https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
        if boolJSON
        then begin
          Req_Json      := TStringStream.Create( slParam.Text );
          try
            Req_Json.Position := 0;
            FLog.LoadFromStream( Req_Json );
            Req_Json.Position := 0;
            Try
              IdHttp.Put( aUrl, Req_Json, AResponseContent );
            except on E: EIdHTTPProtocolException do
              case E.ErrorCode of
              400: MessageDlg( E400, mtError, [mbOk], 0 );
              401: MessageDlg( E401, mtError, [mbOk], 0 );
              else InputBox('stPUT_KeyParam','Hata', E.Message );
              end;// Case
            end;
          finally
            Req_Json.Free;
          end;
        end
        else begin
          Req_Json      := TStringStream.Create( slParam.Text );
          try
            Req_Json.Position := 0;
            FLog.LoadFromStream( Req_Json );
            Req_Json.Position := 0;
            try
              IdHttp.Put( aUrl, Req_Json, AResponseContent );
              except on E: EIdHTTPProtocolException do
                case E.ErrorCode of
                400: MessageDlg( E400, mtError, [mbOk], 0 );
                401: MessageDlg( E401, mtError, [mbOk], 0 );
                else InputBox('stPUT','Hata', E.Message );
                end;// Case
              end;
          finally
            Req_Json.Free;
          end;
        end;
      end;
    end; // case
    Result := AResponseContent.DataString;
  Finally
    IdHttp.Free;
    IdHttp.IOHandler := nil;
    OpenSSL.Free;
    AResponseContent.Free;
  End;
end;

function TGoogleCal_Helper.GoogleOAUTH_01(): String;
// Uses SHDocVw, MSHTML;
  function IEButonaBas( IEBrowser : SHDocVw.InternetExplorer; strButtonId: String ):boolean;
  Var
    Browser      : IWebBrowser2;
    Doc          : MSHTML.IHtmlDocument2;
    Document     : IHTMLDocument3;
    Element      : IHTMLElement;
  begin
    Result := False;
    if Supports( IEBrowser , IWebBrowser2, Browser ) then
    begin
      Browser.Document.QueryInterface(IHtmlDocument2, Doc);
      Document := Browser.Document as IHTMLDocument3;
      Element  := Document.GetElementById( strButtonID ) as IHTMLElement;
      LOGLa( Format('%s : %s', [ Element.tagName, Element.Id ]) );
      if Assigned( Element ) then
      if Element.Id = strButtonId then
      begin
        Element.Click;
        Result := True;
      end;
    end;
  end;

  function IEVeriGir( IEBrowser : SHDocVw.InternetExplorer; strInputNameOrId, strVeri: String ):boolean;
  Var
    Browser      : IWebBrowser2;
    Doc          : MSHTML.IHtmlDocument2;
    Document     : IHTMLDocument3;
    Element      : IHTMLElement;
    Collection   : IHTMLElementCollection;
    i            : Integer;
  begin
    Result := False;
    if Supports( IEBrowser , IWebBrowser2, Browser ) then
    begin
      Browser.Document.QueryInterface(IHtmlDocument2, Doc);
      Document := Browser.Document as IHTMLDocument3;
      Collection := Document.getElementsByTagName( 'INPUT' );
      i := 0;
      while (NOT Result) and (i < Collection.length) do
      begin
        Element := Collection.item(i, Variants.EmptyParam) as IHTMLElement;
        LOGLa( Format('%s : %s', [ Element.tagName, (Element as IHTMLInputElement).name ]) );
        if ( (Element as IHTMLInputElement).name = strInputNameOrId )
        or ( Element.id = strInputNameOrId )
        then
        begin
          (Element as IHTMLInputElement).value := strVeri;
          Result := True;
        end;
        inc(i);
      end;
    end;
  end;

var
  IE                : IWebBrowser2;
  Flags,
  TargetFrameName,
  PostData, Headers : Olevariant;
  aURL              : String;
  Zaman             : Cardinal;
  sil, str          : String;
begin
  Result := '';
  aURL := ''
          + FAuth_Uri
          +'?'
          +'response_type=code'
          +'&scope='        + FScopes
          +'&redirect_uri=' + FRedirect_Uris
          +'&client_id='    + FClient_Id
          +'&user_id='      + FLoginGmail
          ;

  LOGla( aURL );
  Flags           := 0;
  TargetFrameName := 0;
  Postdata        := 0;
  Headers         := 0;


  IE := CreateOleObject('InternetExplorer.Application') as IWebBrowser2;
LogLa( 'MainUrl: ' + aUrl );
  IE.Navigate( aURL, Flags, TargetFrameName, PostData, Headers );

  IE.Visible := FDebugMode;

  // 2 saniye Butonun aktifle�mesini bekliyoruz...
  Zaman := GetTickCount + 2000;
  while GettickCount < Zaman do begin
    Application.ProcessMessages;
    Sleep(10);
  end;

  while IE.Busy do begin
    Application.ProcessMessages;
    Sleep(10);
  end;

  str := ( IE.Document as iHTMLDocument2).body.innerHTML;
  if Pos('submit_approve_access', str) <= 0 then
  begin // Login Ekran� Gelmi� Demektir.

    if Pos('identifierNext', str) > 0 then
    begin // eposta isteniyor Demektir.
      if IEVeriGir  ( IE, 'identifier', FLoginGmail )
        then IEButonaBas( IE, 'identifierNext' );

      // 2 saniye Butonun aktifle�mesini bekliyoruz...
      Zaman := GetTickCount + 2000;
      while GettickCount < Zaman do begin
        Application.ProcessMessages;
        Sleep(10);
      end;
    end;

    str := ( IE.Document as iHTMLDocument2).body.innerHTML;
    if Pos('passwordNext', str) > 0 then
    begin // Password isteniyor Demektir.
      if IEVeriGir( IE, 'password', FLoginPass )
        then IEButonaBas( IE, 'passwordNext' );

      // 2 saniye Butonun aktifle�mesini bekliyoruz...
      Zaman := GetTickCount + 2000;
      while GettickCount < Zaman do begin
        Application.ProcessMessages;
        Sleep(10);
      end;
    end;
  end;

  str := ( IE.Document as iHTMLDocument2).body.innerHTML;
  if Pos('submit_approve_access', str) > 0 then
  begin
    if NOT IEButonaBas( IE, 'submit_approve_access' ) then
    begin
      ShowMessage('Login Ba�ar�s�z.');
      Exit;
    end;
  end else begin
    ShowMessage('Login Ba�ar�s�z.');
    Exit;
  end;

  Zaman := GetTickCount + 2000;
  while GettickCount < Zaman do begin
    Application.ProcessMessages;
    Sleep(10);
  end;

  while (IE.Busy) do
  begin
    Sleep(1);
    Application.ProcessMessages;
    LOGLa( TimeToStr(now));
  end;

  str := ( IE.Document as iHTMLDocument2).body.innerHTML;

  if ( Pos('id="code"', str) > 0 ) // Pos('Bu kodu kopyalay�n', str ) > 0
  then begin
    sil := 'value="';
      System.Delete(str, 1, Pos(sil, str) + Length( sil )-1 );
    FAuth20_Code := Copy( str, 1, pos('"', str)-1 );
      LOGla( 'OAuth 2.0 i�lemi Ba�ar�l�...' );
      LOGla( 'Token Almak i�in AuthCode = ' + FAuth20_Code );
  end;
  IE.Quit;
  IE := nil;
  GoogleOAUTH_02();
end;

function TGoogleCal_Helper.GoogleOAUTH_02(): string;
Var
  slParam  : TStringList;
  strGelen, str, sil : String;
begin
  slParam := TStringList.create;
  Try
    slParam.Add('grant_type=authorization_code'      );
    slParam.Add('code='         + FAuth20_Code );
    slParam.Add('client_id='    + FClient_Id          );
    slParam.Add('client_secret='+ FClient_Secret      );
    slParam.Add('redirect_uri=' + FRedirect_Uris      );

    LOGla( slParam.text );
    LOGla( 'Access Token i�in Ba�vuru A�amas�nday�z...' );
    strGelen := WEBIslemler( stPOST, FToken_uri, false, slParam );

    str := strGelen;
    sil := '"access_token" : "';
      System.Delete(str, 1, pos(sil, str) + length(sil)-1 );
      FAccess_Token := trim( Copy(str, 1, pos('"', str)-1) );
    sil := '"expires_in" : ';
      System.Delete(str, 1, pos(sil, str) + length(sil)-1 );
      Fexpires_in   := trim( Copy(str, 1, pos(',', str)-1) );
    sil := '"refresh_token" : "';
      System.Delete(str, 1, pos(sil, str) + length(sil)-1 );
      Frefresh_token:=  trim( Copy(str, 1, pos('"', str)-1) );
    sil := '"token_type" : "';
      System.Delete(str, 1, pos(sil, str) + length(sil)-1 );
      Ftoken_type   := trim( Copy(str, 1, pos('"', str)-1) );
    Result := strGelen;
  Finally
    slParam.Free;
    LOGla('Access_Token Geldi : ' + FAccess_Token );
  End;
end;

procedure TGoogleCal_Helper.LOGla( strIcerik: String );
begin
  if (FLog = nil) then Exit;
  if strIcerik = '!!!! TEM�ZLE !!!!' then
  begin
    FLog.Clear;
    Exit;
  end;
  FLog.Add( strIcerik );
end;

function TGoogleCal_Helper.AradanSec(var strIcerik: String; strBas, strSon: String; boolTrim:boolean=false ): string;
Var
  strOrjKaynak : String;
begin
  Result := '';
  strOrjKaynak := strIcerik;
  if Pos( strBas, strIcerik ) > 0 then
  begin
    System.Delete( strIcerik, 1, Pos( strBas, strIcerik )+ Length( strBas )-1 );
    if strSon <> ''
      then Result := Trim( Copy(strIcerik, 1, Pos( strSon, StrIcerik ) -1) )
      else Result := Trim( strIcerik );
  end;
  if NOT boolTrim then strIcerik := strOrjKaynak;
end;

function TGoogleCal_Helper.CalEventEkle(aEvent: pCalEventRecord ): String;
const
  jsonDateFmt   = '  "dateTime": "%.4d-%.2d-%.2dT%.2d:%.2d:00.000"';
  jsonAllDayFmt = '  "date": "%.4d-%.2d-%.2d"';
Var
  strEkle  : String;
  slParam  : TStringList;
  i        : Integer;
begin
  slParam := TStringList.Create;

  With slParam do begin
    Add( '{'                                          );
    if aEvent.EventId <> ''
    then
    Add( '  "id": "'+aEvent.EventId+'",'        );

    Add( '  "start": {'                                );

    if aEvent.TimeZone <> ''
    then
    Add( '  "timeZone": "'+aEvent.TimeZone+'",'        );

    if aEvent.boolTumGun then begin
      strEkle := Format( jsonAllDayFmt, [ YearOf(aEvent.BasTar), MonthOf(aEvent.BasTar), DayOf(aEvent.BasTar) ] );
    end else begin
      strEkle := Format( jsonDateFmt, [ YearOf(aEvent.BasTar), MonthOf(aEvent.BasTar), DayOf(aEvent.BasTar), HourOf(aEvent.BasTar), MinuteOf(aEvent.BasTar) ] );
    end;

    Add( strEkle                                      );

    Add( ' },'                                        );
    Add( '  "end": {'                                  );
    if aEvent.TimeZone <> ''
    then
    Add( '  "timeZone": "'+aEvent.TimeZone+'",'        );

    if aEvent.boolTumGun then begin
      aEvent.BitTar := incDay( aEvent.BitTar, +1 ); // Google 1 g�n eksik hesapl�yor, talfisini ekliyoruz. Okurken de ��kart�caz...
      strEkle := Format( jsonAllDayFmt, [ YearOf(aEvent.BitTar), MonthOf(aEvent.BitTar), DayOf(aEvent.BitTar) ] );
    end else begin
      strEkle := Format( jsonDateFmt,   [ YearOf(aEvent.BitTar), MonthOf(aEvent.BitTar), DayOf(aEvent.BitTar), HourOf(aEvent.BitTar), MinuteOf(aEvent.BitTar) ] );
    end;
    Add( strEkle                                      );
    Add( ' },'                                        );

    if aEvent.description <> ''
    then
    begin
      if Pos( #13#10, aEvent.description) > 0 then aEvent.description := StringReplace(aEvent.description, #13#10, '\n', [rfReplaceAll] );
      if Pos( #13,    aEvent.description) > 0 then aEvent.description := StringReplace(aEvent.description, #13,    '\n', [rfReplaceAll] );
      Add( ' "description": "'+ UTF8Encode( aEvent.description )+'",'  );
    end;
    if aEvent.colorId > 0
    then
    Add( ' "colorId": "'+IntToStr(aEvent.colorId)+'",'             );
    if aEvent.location <> ''
    then
    Add( ' "location": "'+ UTF8Encode(aEvent.location) + '",'      );
    if aEvent.summary <> ''
    then
    Add( ' "summary": "'+ UTF8Encode(aEvent.summary) + '",'        );
    if aEvent.creaDispName <> ''
    then begin // Blok t�m�yle en az bir creator varsa ge�erli.
      Add( ' "creator": {'                                          );
      Add( '  "displayName": "'+ UTF8Encode(aEvent.creaDispName)+'",');
      if aEvent.creaId <> ''
      then
      Add( '  "id": "'+ UTF8Encode(aEvent.creaId)+'",'               );
      if aEvent.creaEmail <> ''
      then begin
      Add( '  "email": "'+ UTF8Encode(aEvent.creaEmail)+'",'         );
      Add( '  "self": false'         );
      end;
      Add( ' },'                                                    );
    end;
    Add( ' "attendees": ['                                        );
    for i := low(aEvent.Attendees) to high(aEvent.Attendees) do
    begin
      Add( '  {'                                                                    );
      if aEvent.Attendees[i].attDispName <> ''
      then
      Add( '   "displayName": "'+ UTF8Encode( aEvent.Attendees[i].attDispName )+'",' );
      if aEvent.Attendees[i].attComment <> ''
      then
      Add( '   "comment": "'+ UTF8Encode( aEvent.Attendees[i].attComment )+'",'      );
      if aEvent.Attendees[i].attEmail <> ''
      then
      Add( '   "email": "'+aEvent.Attendees[i].attEmail+'"'                        );
//      if aEvent.Attendees[i].attId <> ''
//      then
//      Add( '   "id": "'+ UTF8Encode( aEvent.Attendees[i].attId )+'",'                );
//      if aEvent.Attendees[i].attOrganizer
//        then Add( '   "organizer": true'                     )
//        else Add( '   "organizer": false'                    );
      Add( '  }'                                             );

      if i < high(aEvent.Attendees)
        then Add( '  ,'                                      );

      Dispose( aEvent.Attendees[i] ) // Haf�zadan u�urduk
    end;
    Add( ' ],'                                               );
    Add( '"visibility": "default"'                           );
    Add( '}'                                                    );
  end;

  Dispose( aEvent ); // Haf�zadan u�urduk
  try
    Result := WEBIslemler( stPOST_KEYParam,  FCalendarUri
                                          +  EncodeURI( FCalendarID )
                                          + '/events'
                                          + '?key='
                                          +  EncodeURI( FApi_Key ), True, slParam );
  finally
    slParam.Free;
  end;
end;

procedure TGoogleCal_Helper.CalEventIDs( Liste : TStrings; aBasTar:TDateTime=0; aBitTar: TDateTime=0; boolDeleted:boolean=false);
var
  strGelen : String;
begin
  strGelen := CalEventList();
  if pos( '"items":', strGelen ) <= 0 then Exit;
  AradanSec( strGelen, '', '"kind": "calendar#event"', True );
  while Pos('"id": "', strGelen) > 0 do begin
    Liste.Add( AradanSec( strGelen, '"id": "', '"', True ) );
  end;
end;

function TGoogleCal_Helper.CalEventList( boolDeleted:boolean=false; aBasTar:TDateTime=0; aBitTar: TDateTime=0; aTimeZone:String='+03:00' ): String;
Const
  TimeFmt     = '%.4d-%.2d-%.2dT00:00:00Z';
  TimeFmtZone = '%.4d-%.2d-%.2dT00:00:00'; // + aTimeZone
Var
  strRes : String;
  aURL   : String;
begin
  aURL   :=  FCalendarUri
          +  EncodeURI( FCalendarID )
          + '/events'
          + '?key='
          + EncodeURI( FApi_Key );
  if aBasTar > 0 then
  begin
    aBitTar := DateUtils.IncDay( aBitTar, 1 ); // ilgili g�n hari� tutuluyor, telafi i�in (1) g�n ekledik.
    if Pos('+', aTimeZone) > 1 then system.Delete( aTimeZone, 1, Pos('+', aTimeZone)-1); // "GMT+03:00" gibi ise parametre olarak sadece "+03:00" k�sm� laz�m.
    if Pos('-', aTimeZone) > 1 then system.Delete( aTimeZone, 1, Pos('-', aTimeZone)-1); // "GMT-03:00" gibi ise parametre olarak sadece "-03:00" k�sm� laz�m.

    aURL := aURL
    + '&timeMin='  + EncodeURI( Format( TimeFmtZone, [YearOf(aBasTar), MonthOf(aBasTar), DayOf(aBasTar)] ) )
    +  EncodeURI( aTimeZone ) // aTimeZone: '+03:00' vb.
    + '&timeMax='  + EncodeURI( Format( TimeFmtZone, [YearOf(aBitTar), MonthOf(aBitTar), DayOf(aBitTar)] ) )
    +  EncodeURI( aTimeZone ) // aTimeZone: '+03:00' vb.
  end;
  aURL := aURL
    + '&singleEvents=true'
    + '&orderBy=startTime'; // veya 'updated';

  if boolDeleted
    then aURL := aURL + '&showDeleted=true'
    else aURL := aURL + '&showDeleted=false';
    
  LOGla(  aURL );
  strRes := UTF8Decode( WEBIslemler( stGET_KEYParam, aURL ));

  Result := strRes;
end;

function TGoogleCal_Helper.CalEventSil(aEventId: String): String;
begin
  Result := WEBIslemler( stDELETE_KEYParam,  FCalendarUri
                                          +  EncodeURI( FCalendarID )
                                          + '/events'
                                          + '/' + aEventId
                                          +'?sendNotifications=false&key='
                                          + FApi_Key )
end;

function TGoogleCal_Helper.CalEventUpdate( strEventID:String; aEvent: pCalEventRecord): String;
const
  jsonDateFmt   = '  "dateTime": "%.4d-%.2d-%.2dT%.2d:%.2d:00.000"';
  jsonAllDayFmt = '  "date": "%.4d-%.2d-%.2d"';
Var
  strEkle  : String;
  slParam  : TStringList;
  i : Integer;
begin
  slParam := TStringList.Create;

  With slParam do begin
    Add( '{'                                          );
    if aEvent.EventId <> ''
    then
    Add( '  "id": "'+aEvent.EventId+'",'        );

    Add( '  "start": {'                                );

    if aEvent.TimeZone <> ''
    then
    Add( '  "timeZone": "'+aEvent.TimeZone+'",'        );

    if aEvent.boolTumGun then begin
      strEkle := Format( jsonAllDayFmt, [ YearOf(aEvent.BasTar), MonthOf(aEvent.BasTar), DayOf(aEvent.BasTar) ] );
    end else begin
      strEkle := Format( jsonDateFmt, [ YearOf(aEvent.BasTar), MonthOf(aEvent.BasTar), DayOf(aEvent.BasTar), HourOf(aEvent.BasTar), MinuteOf(aEvent.BasTar) ] );
    end;

    Add( strEkle                                      );

    Add( ' },'                                        );
    Add( '  "end": {'                                  );
    if aEvent.TimeZone <> ''
    then
    Add( '  "timeZone": "'+aEvent.TimeZone+'",'        );

    if aEvent.boolTumGun then begin
      aEvent.BitTar := incDay( aEvent.BitTar, +1 ); // Google 1 g�n eksik hesapl�yor, talfisini ekliyoruz. Okurken de ��kart�caz...
      strEkle := Format( jsonAllDayFmt, [ YearOf(aEvent.BitTar), MonthOf(aEvent.BitTar), DayOf(aEvent.BitTar) ] );
    end else begin
      strEkle := Format( jsonDateFmt,   [ YearOf(aEvent.BitTar), MonthOf(aEvent.BitTar), DayOf(aEvent.BitTar), HourOf(aEvent.BitTar), MinuteOf(aEvent.BitTar) ] );
    end;
    Add( strEkle                                      );
    Add( ' },'                                        );

    if aEvent.description <> ''
    then
    begin
      if Pos( #13#10, aEvent.description) > 0 then aEvent.description := StringReplace(aEvent.description, #13#10, '\n', [rfReplaceAll] );
      if Pos( #13,    aEvent.description) > 0 then aEvent.description := StringReplace(aEvent.description, #13,    '\n', [rfReplaceAll] );
      Add( ' "description": "'+ UTF8Encode( aEvent.description )+'",'  );
    end;
    if aEvent.colorId > 0
    then
    Add( ' "colorId": "'+IntToStr(aEvent.colorId)+'",'             );
    if aEvent.location <> ''
    then
    Add( ' "location": "'+ UTF8Encode(aEvent.location) + '",'      );
    if aEvent.summary <> ''
    then
    Add( ' "summary": "'+ UTF8Encode(aEvent.summary) + '",'        );
    if aEvent.creaDispName <> ''
    then begin // Blok t�m�yle en az bir creator varsa ge�erli.
      Add( ' "creator": {'                                          );
      Add( '  "displayName": "'+ UTF8Encode(aEvent.creaDispName)+'",');
      if aEvent.creaId <> ''
      then
      Add( '  "id": "'+ UTF8Encode(aEvent.creaId)+'",'               );
      if aEvent.creaEmail <> ''
      then begin
      Add( '  "email": "'+ UTF8Encode(aEvent.creaEmail)+'",'         );
      Add( '  "self": false'         );
      end;
      Add( ' },'                                                    );
    end;
    Add( ' "attendees": ['                                        );
    for i := low(aEvent.Attendees) to high(aEvent.Attendees) do
    begin
      Add( '  {'                                                                    );
      if aEvent.Attendees[i].attDispName <> ''
      then
      Add( '   "displayName": "'+ UTF8Encode( aEvent.Attendees[i].attDispName )+'",' );
      if aEvent.Attendees[i].attComment <> ''
      then
      Add( '   "comment": "'+ UTF8Encode( aEvent.Attendees[i].attComment )+'",'      );
      if aEvent.Attendees[i].attEmail <> ''
      then
      Add( '   "email": "'+aEvent.Attendees[i].attEmail+'"'                        );
//      if aEvent.Attendees[i].attId <> ''
//      then
//      Add( '   "id": "'+ UTF8Encode( aEvent.Attendees[i].attId )+'",'                );
//      if aEvent.Attendees[i].attOrganizer
//        then Add( '   "organizer": true'                     )
//        else Add( '   "organizer": false'                    );
      Add( '  }'                                             );

      if i < high(aEvent.Attendees)
        then Add( '  ,'                                      );

      Dispose( aEvent.Attendees[i] ) // Haf�zadan u�urduk
    end;
    Add( ' ],'                                               );
    Add( '"visibility": "default"'                           );
    Add( '}'                                                    );
  end;

  Dispose( aEvent ); // Haf�zadan u�urduk
  try
    Result := WEBIslemler( stPUT_KEYParam,  FCalendarUri
                                         +  EncodeURI( FCalendarID )
                                         + '/events'
                                         + '/'
                                         +  strEventID
                                         //+ '?key='
                                         //+  EncodeURI( FApi_Key )
                                         , True, slParam );
  finally
    slParam.Free;
  end;
end;

function TGoogleCal_Helper.CalEventFromID(aEventId: String): String;
begin
  Result := WEBIslemler( stGET_KEYParam,  FCalendarUri
                                          +  EncodeURI( FCalendarID )
                                          + '/events'
                                          + '/' + aEventId );

end;

function TGoogleCal_Helper.ParseEvent( strIcerik : String ): pCalEventRecord;
Var
  str: String;
  aEvent    : pCalEventRecord;
  aKisiList : pAttendeesRecord;
  strBlok, dummy   : String;
  CId       : String;
  Tar1, Tar2: String;
  i         : Integer;
  cDateSep, cTimeSep : Char;
begin
  {$IF CompilerVersion >= 22.0}
    cDateSep := FormatSettings.DateSeparator;
    cTimeSep := FormatSettings.TimeSeparator;
  {$ELSE}
    // D7 = 15.0
    cDateSep := DateSeparator;
    cTimeSep := TimeSeparator;
  {$IFEND}

  Result := nil;
  strBlok := strIcerik;
  if pos('"id": "', strBlok) > 0 then
  begin // Event gelmi�... :)
    CId    := xGoogleCal.AradanSec( strBlok, '"id": "'     , '"', True  );
    new( aEvent );
    aEvent.summary      := UTF8Decode( xGoogleCal.AradanSec( strBlok, '"summary": "', '"', False ) );
    aEvent.location     := UTF8Decode( xGoogleCal.AradanSec( strBlok, '"location": "', '"', False ) );
    aEvent.description  := UTF8Decode(
      StringReplace( xGoogleCal.AradanSec( strBlok, '"description": "', '"', False ), '\n', #13#10, [rfReplaceAll] )
       );
    aEvent.EventStatus  := xGoogleCal.AradanSec( strBlok, '"status": "', '"', False );

    str := strBlok;
    xGoogleCal.AradanSec( str, '"start": {', '"date', True );
    Tar1 := xGoogleCal.AradanSec( str, '": "', '"' , True );
    if Pos('T', Tar1) > 0 then
    begin // DateTime 2018-03-23T17:00:00+03:00
      aEvent.boolTumGun := False;
      Tar2 := Copy(Tar1, 9, 2) + cDateSep
            + Copy(Tar1, 6, 2) + cDateSep
            + Copy(Tar1, 1, 4)
            + ' '
            + Copy(Tar1, 12, 2) + cTimeSep
            + Copy(Tar1, 15, 2)
    end else
    begin // Date     1111-11-11
      aEvent.boolTumGun := True;
      Tar2 := Copy(Tar1, 9, 2) + cDateSep
            + Copy(Tar1, 6, 2) + cDateSep
            + Copy(Tar1, 1, 4);
    end;
    aEvent.BasTar := StrToDateTime( Tar2 );

    str := strBlok;
    xGoogleCal.AradanSec( str, '"end": {', '"date', True );
    Tar1 := xGoogleCal.AradanSec( str, '": "', '"' , True );
    if Pos('T', Tar1) > 0 then
    begin // DateTime
      aEvent.boolTumGun := False;
      Tar2 := Copy(Tar1, 9, 2) + cDateSep
            + Copy(Tar1, 6, 2) + cDateSep
            + Copy(Tar1, 1, 4)
            + ' '
            + Copy(Tar1, 12, 2) + cTimeSep
            + Copy(Tar1, 15, 2)
    end else
    begin // Date
      aEvent.boolTumGun := True;
      Tar2 := Copy(Tar1, 9, 2) + cDateSep
            + Copy(Tar1, 6, 2) + cDateSep
            + Copy(Tar1, 1, 4);
    end;
    aEvent.BitTar := StrToDateTime( Tar2 );
    if aEvent.boolTumGun then // 1 g�n eksik hesapl�yor eklemi�izdir. ��kart�yoruz ...
       aEvent.BitTar := incDay( aEvent.BitTar, -1 );

    str := strBlok;
    xGoogleCal.AradanSec( str, '"attendees":', '[', True );
    i := -1;
    while pos('"email": "', str) > 0 do
    begin
      inc(i);
      New(aKisiList);
      aKisiList.attEmail    := xGoogleCal.AradanSec( str, '"email": "',       '"', True  );
      Dummy := Copy( str, 1, Pos( '}', str )-1); // olmayan ba�l�k i�in di�er epostaya sarkmas�n diye
        aKisiList.attDispName := UTF8Decode( xGoogleCal.AradanSec( Dummy, '"displayName": "', '"', False ) );
        aKisiList.attComment  := UTF8Decode( xGoogleCal.AradanSec( Dummy, '"comment": "',     '"', False ) );
        //aKisiList.attId       := UTF8Decode( xGoogleCal.AradanSec( Dummy, '"id": "',          '"', False ) );
        aKisiList.attResponses:= UTF8Decode( xGoogleCal.AradanSec( Dummy, '"responseStatus": "', '"', False ) );

//        if xGoogleCal.AradanSec( Dummy, '"organizer": ',   '}', False ) = 'true'
//          then aKisiList.attOrganizer := True
//          else aKisiList.attOrganizer := False;
      SetLength( aEvent.Attendees, i+1 );
      aEvent.Attendees[i] := aKisiList;
    end;
    Result := aEvent;
  end;
end;

function TGoogleCal_Helper.APIClientInfo(strJSON: String): pAPIClientInfo;
Var
  aAPIClientInfo : pAPIClientInfo;
  strBlok        : String;
begin
  Result := nil;
  strBlok := strJSON;
  if pos('"client_id":"', strBlok) > 0 then
  begin // JSON Do�ru (varsayal�m) :)
    New( aAPIClientInfo );
    aAPIClientInfo.Client_Id     := xGoogleCal.AradanSec( strBlok, '"client_id":"',      '"', False );
    aAPIClientInfo.Project_Id    := xGoogleCal.AradanSec( strBlok, '"project_id":"',     '"', False );
    aAPIClientInfo.Auth_Uri      := xGoogleCal.AradanSec( strBlok, '"auth_uri":"',       '"', False );
    aAPIClientInfo.Token_Uri     := xGoogleCal.AradanSec( strBlok, '"token_uri":"',      '"', False );
    aAPIClientInfo.Client_Secret := xGoogleCal.AradanSec( strBlok, '"client_secret":"',  '"', False );
    aAPIClientInfo.Redirect_Uris := xGoogleCal.AradanSec( strBlok, '"redirect_uris":["', '"', False );
    Result := aAPIClientInfo;
  end;
end;

initialization
  xGoogleCal := TGoogleCal_Helper.Create;

finalization
  FreeAndNil(xGoogleCal);

end.


// EVENT //
{
  "kind": "calendar#event",
  "etag": etag,
  "id": string,
  "status": string,
  "htmlLink": string,
  "created": datetime,
  "updated": datetime,
  "summary": string,
  "description": string,
  "location": string,
  "colorId": string,
  "creator": {
    "id": string,
    "email": string,
    "displayName": string,
    "self": boolean
  },
  "organizer": {
    "id": string,
    "email": string,
    "displayName": string,
    "self": boolean
  },
  "start": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "end": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "endTimeUnspecified": boolean,
  "recurrence": [
    string
  ],
  "recurringEventId": string,
  "originalStartTime": {
    "date": date,
    "dateTime": datetime,
    "timeZone": string
  },
  "transparency": string,
  "visibility": string,
  "iCalUID": string,
  "sequence": integer,
  "attendees": [
    {
      "id": string,
      "email": string,
      "displayName": string,
      "organizer": boolean,
      "self": boolean,
      "resource": boolean,
      "optional": boolean,
      "responseStatus": string,
      "comment": string,
      "additionalGuests": integer
    }
  ],
  "attendeesOmitted": boolean,
  "extendedProperties": {
    "private": {
      (key): string
    },
    "shared": {
      (key): string
    }
  },
  "hangoutLink": string,
  "conferenceData": {
    "createRequest": {
      "requestId": string,
      "conferenceSolutionKey": {
        "type": string
      },
      "status": {
        "statusCode": string
      }
    },
    "entryPoints": [
      {
        "entryPointType": string,
        "uri": string,
        "label": string,
        "pin": string,
        "accessCode": string,
        "meetingCode": string,
        "passcode": string,
        "password": string
      }
    ],
    "conferenceSolution": {
      "key": {
        "type": string
      },
      "name": string,
      "iconUri": string
    },
    "conferenceId": string,
    "signature": string,
    "notes": string
  },
  "gadget": {
    "type": string,
    "title": string,
    "link": string,
    "iconLink": string,
    "width": integer,
    "height": integer,
    "display": string,
    "preferences": {
      (key): string
    }
  },
  "anyoneCanAddSelf": boolean,
  "guestsCanInviteOthers": boolean,
  "guestsCanModify": boolean,
  "guestsCanSeeOtherGuests": boolean,
  "privateCopy": boolean,
  "locked": boolean,
  "reminders": {
    "useDefault": boolean,
    "overrides": [
      {
        "method": string,
        "minutes": integer
      }
    ]
  },
  "source": {
    "url": string,
    "title": string
  },
  "attachments": [
    {
      "fileUrl": string,
      "title": string,
      "mimeType": string,
      "iconLink": string,
      "fileId": string
    }
  ]
}
