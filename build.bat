set work=%cd%

set build_option=/Build
set build_data=0
set build_hant=0
set build_rime=0

:parse_cmdline_options
if "%1" == "" goto end_parsing_cmdline_options
if "%1" == "rebuild" set build_option=/Rebuild
if "%1" == "data" set build_data=1
if "%1" == "hant" set build_hant=1
if "%1" == "rime" set build_rime=1
if "%1" == "librime" set build_rime=1
if "%1" == "all" (
  set build_data=1
  set build_hant=1
  set build_rime=1
)
shift
goto parse_cmdline_options
:end_parsing_cmdline_options

cd %work%
if exist output\weaselserver.exe (
  output\weaselserver.exe /q
)

if %build_rime% == 1 (
  cd %work%\librime
  call vcbuild.bat
  cd %work%
  copy /Y librime\thirdparty\lib\*.lib lib\
  copy /Y librime\thirdparty\bin\*.dll output\
  copy /Y librime\vcbuild\lib\Release\rime.dll output\
)

if %build_data% == 1 (
  call :build_data
) else if not exist output\data\essay.kct (
  call :build_data
)

if %build_hant% == 1 (
  devenv weasel.sln %build_option% "ReleaseHant|x64"
  if errorlevel 1 goto error
  devenv weasel.sln %build_option% "ReleaseHant|Win32"
  if errorlevel 1 goto error
)

devenv weasel.sln %build_option% "Release|x64"
if errorlevel 1 goto error
devenv weasel.sln %build_option% "Release|Win32"
if errorlevel 1 goto error
goto end

:build_data
call :build_essay
copy %work%\LICENSE.txt output\
copy %work%\README.txt output\
copy %work%\brise\essay.kct output\data\
copy %work%\brise\default.yaml output\data\
copy %work%\brise\symbols.yaml output\data\
copy %work%\brise\preset\*.yaml output\data\
copy %work%\brise\supplement\*.yaml output\data\
copy %work%\brise\extra\*.yaml output\expansion\
exit /b

:build_essay
copy %work%\librime\thirdparty\bin\kctreemgr.exe %work%\brise\
copy %work%\librime\thirdparty\bin\zlib1.dll %work%\brise\
cd %work%\brise
call make_essay.bat
cd %work%
exit /b

:error
echo error building weasel...

:end
cd %work%
