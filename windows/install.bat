@echo off
REM ============================================
REM Instalador do Tea Language para Windows
REM ============================================

echo Instalando Tea Language para Windows...
echo.

REM Verifica se Lua esta instalado
set LUA_CMD=
for %%L in (lua lua54 lua53 lua52 lua51) do (
    where %%L >nul 2>&1
    if not errorlevel 1 (
        set LUA_CMD=%%L
        goto :lua_found
    )
)

:lua_not_found
echo [!] Lua nao encontrado!
echo.
echo Instale o Lua primeiro:
echo   1. LuaForWindows: https://github.com/rjpcomputing/luaforwindows/releases
echo   2. Chocolatey: choco install lua
echo   3. Scoop: scoop install lua
echo.
pause
exit /b 1

:lua_found
echo [+] Lua encontrado: %LUA_CMD%

REM Define diretorios
set INSTALL_DIR=%USERPROFILE%\.tea
set TEA_BIN=%INSTALL_DIR%\bin
set TEA_LIB=%INSTALL_DIR%\lib

REM Remove instalacao antiga
if exist "%INSTALL_DIR%" (
    echo [*] Removendo instalacao antiga...
    rmdir /s /q "%INSTALL_DIR%"
)

REM Cria diretorios
echo [*] Criando diretorios...
mkdir "%TEA_BIN%"
mkdir "%TEA_LIB%"

REM Copia arquivos
echo [*] Copiando arquivos...
copy /y "..\src\tea.lua" "%TEA_LIB%\" >nul
copy /y "..\src\vm.lua" "%TEA_LIB%\" >nul
copy /y "..\src\transpiler.lua" "%TEA_LIB%\" >nul

REM Cria script tea.bat
echo [*] Criando script tea.bat...
(
echo @echo off
echo set LUA_CMD=%LUA_CMD%
echo set TEA_LIB=%%USERPROFILE%%\.tea\lib
echo.
echo if "%%~1"=="" ^(
echo     echo Uso: tea ^<arquivo.tea^>
echo     exit /b 1
echo ^)
echo.
echo if "%%~1"=="version" ^(
echo     echo Tea Language v0.3.0
echo     exit /b 0
echo ^)
echo.
echo if "%%~1"=="help" ^(
echo     echo Tea Language v0.3.0
echo     echo Uso: tea ^<arquivo.tea^>
echo     exit /b 0
echo ^)
echo.
echo if "%%~1"=="-c" ^(
echo     %%LUA_CMD%% "%%TEA_LIB%%\tea.lua" "%%~2"
echo     exit /b 0
echo ^)
echo.
echo if "%%~1"=="-r" ^(
echo     %%LUA_CMD%% "%%TEA_LIB%%\vm.lua" "%%~2"
echo     exit /b 0
echo ^)
echo.
echo if "%%~1"=="--trans" ^(
echo     %%LUA_CMD%% "%%TEA_LIB%%\transpiler.lua" "%%~2"
echo     exit /b 0
echo ^)
echo.
echo if "%%~1"=="--clear" ^(
echo     del /q "%%~2\*.teac" 2^>nul
echo     exit /b 0
echo ^)
echo.
echo REM Modo normal
echo %%LUA_CMD%% "%%TEA_LIB%%\tea.lua" "%%~1"
echo if not errorlevel 1 ^(
echo     set BASENAME=%%~n1
echo     %%LUA_CMD%% "%%TEA_LIB%%\vm.lua" "%%BASENAME%%.teac"
echo ^)
) > "%TEA_BIN%\tea.bat"

echo [+] Tea instalado com sucesso!
echo.
echo ======================================
echo IMPORTANTE: Adicione ao PATH
echo ======================================
echo.
echo Adicione este caminho ao PATH do Windows:
echo   %TEA_BIN%
echo.
echo Como adicionar:
echo   1. Pressione Win + Pause
echo   2. Clique em "Configuracoes avancadas do sistema"
echo   3. Clique em "Variaveis de Ambiente"
echo   4. Em "Variaveis do usuario", selecione "Path"
echo   5. Clique em "Editar" e adicione:
echo      %TEA_BIN%
echo   6. Clique em "OK" em todas as janelas
echo.
echo Ou execute este comando no PowerShell (como Admin):
echo   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";%TEA_BIN%", "User")
echo.
echo Depois, abra um novo CMD/PowerShell e use:
echo   tea arquivo.tea
echo.
pause
