@echo off
rem Lance les tests Flutter sans proxy.
rem Une variable HTTP_PROXY / http_proxy mal renseignee sous Windows fait echouer "flutter test"
rem avec "Failed host lookup: '80'" : le lanceur de tests n'arrive plus a joindre son propre canal local.
rem Les variables ne sont videes que pour cette fenetre ; la configuration du PC n'est pas modifiee.
set HTTP_PROXY=
set HTTPS_PROXY=
set ALL_PROXY=
set http_proxy=
set https_proxy=
set all_proxy=
set NO_PROXY=localhost,127.0.0.1,::1
set no_proxy=localhost,127.0.0.1,::1
cd /d "%~dp0.."
flutter test %*
