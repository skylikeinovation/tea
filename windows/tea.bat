@echo off
REM ============================================
REM tea.bat - Tea Language para Windows
REM ============================================

REM Detecta Lua
set LUA_CMD=
for %%L in (lua lua54 lua53 lua52 lua51) do (
    where %%L >nul 2>&1
    if not errorlevel 1 (
        set LUA_CMD=%%L
        goto :lua_found
    )
)

:lua_not_found
echo Erro: Lua nao encontrado!
echo.
echo Instale o Lua primeiro:
echo   https://github.com/rjpcomputing/luaforwindows/releases
echo   ou
echo   choco install lua
exit /b 1

:lua_found

REM Verifica argumentos
if "%~1"=="" (
    echo Uso: tea ^<arquivo.tea^>                     ^(compila e executa^)
    echo       tea -c ^<arquivo.tea^>                 ^(apenas compila^)
    echo       tea -r ^<arquivo.teac^>                ^(executa bytecode^)
    echo       tea --trans ^<arquivo.tea^>            ^(transpila para Lua^)
    echo       tea --build-exec ^<arquivo.tea^>       ^(gera executavel^)
    echo       tea --clear ^<diretorio^>              ^(limpa arquivos .teac^)
    echo       tea version                           ^(mostra versao^)
    echo       tea help                              ^(mostra ajuda^)
    exit /b 1
)

REM Comandos especiais
if "%~1"=="help" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-h" goto :help
if "%~1"=="version" goto :version
if "%~1"=="--version" goto :version
if "%~1"=="-v" goto :version

REM Modo de limpeza
if "%~1"=="--clear" (
    if "%~2"=="" (
        set DIR=.
    ) else (
        set DIR=%~2
    )
    
    echo Limpando arquivos .teac em: %DIR%
    del /q "%DIR%\*.teac" 2>nul
    if errorlevel 1 (
        echo [*] Nenhum arquivo .teac encontrado
    ) else (
        echo [+] Arquivos .teac removidos
    )
    exit /b 0
)

REM Modo de transpilacao
if "%~1"=="--trans" (
    if "%~2"=="" (
        echo Uso: tea --trans ^<arquivo.tea^>
        exit /b 1
    )
    
    if not exist "%~2" (
        echo Erro: Arquivo '%~2' nao encontrado!
        exit /b 1
    )
    
    echo Tea -^> Lua Transpiler
    echo ======================================
    %LUA_CMD% src\transpiler.lua "%~2"
    exit /b 0
)

REM Modo de build executavel
if "%~1"=="--build-exec" (
    if "%~2"=="" (
        echo Uso: tea --build-exec ^<arquivo.tea^>
        exit /b 1
    )
    
    if not exist "%~2" (
        echo Erro: Arquivo '%~2' nao encontrado!
        exit /b 1
    )
    
    set BASENAME=%~n2
    
    echo Gerando executavel standalone...
    echo ======================================
    %LUA_CMD% src\transpiler.lua "%~2" "%BASENAME%.lua"
    
    echo.
    echo Criando executavel batch...
    echo @echo off > "%BASENAME%.bat"
    echo %LUA_CMD% "%%~dp0%BASENAME%.lua" %%* >> "%BASENAME%.bat"
    
    echo [+] Executavel gerado: %BASENAME%.bat
    echo [*] Execute com: %BASENAME%.bat
    exit /b 0
)

REM Modo de compilacao
if "%~1"=="-c" (
    if "%~2"=="" (
        echo Uso: tea -c ^<arquivo.tea^>
        exit /b 1
    )
    
    if not exist "%~2" (
        echo Erro: Arquivo '%~2' nao encontrado!
        exit /b 1
    )
    
    echo Tea Language - Compilando
    echo ======================================
    %LUA_CMD% src\tea.lua "%~2"
    exit /b 0
)

REM Modo de execucao
if "%~1"=="-r" (
    if "%~2"=="" (
        echo Uso: tea -r ^<arquivo.teac^>
        exit /b 1
    )
    
    if not exist "%~2" (
        echo Erro: Arquivo '%~2' nao encontrado!
        exit /b 1
    )
    
    %LUA_CMD% src\vm.lua "%~2"
    exit /b 0
)

REM Modo normal: compila e executa
if not exist "%~1" (
    echo Erro: Arquivo '%~1' nao encontrado!
    exit /b 1
)

set BASENAME=%~n1

echo Tea Language - Compilando e Executando
echo ==========================================
%LUA_CMD% src\tea.lua "%~1"

if not errorlevel 1 (
    echo.
    %LUA_CMD% src\vm.lua "%BASENAME%.teac"
)

exit /b 0

:help
echo Tea Language v0.3.0
echo ======================================
echo.
echo Uso:
echo   tea ^<arquivo.tea^>                     Compila e executa
echo   tea -c ^<arquivo.tea^>                  Apenas compila
echo   tea -r ^<arquivo.teac^>                 Executa bytecode
echo   tea --trans ^<arquivo.tea^>             Transpila para Lua
echo   tea --build-exec ^<arquivo.tea^>        Gera executavel
echo   tea --clear ^<diretorio^>               Limpa arquivos .teac
echo   tea version                           Mostra versao
echo   tea help                              Mostra ajuda
echo.
echo Exemplos:
echo   tea programa.tea
echo   tea -c programa.tea
echo   tea --trans programa.tea
echo   tea --build-exec programa.tea
echo.
exit /b 0

:version
echo Tea Language v0.3.0
echo Compilador e VM para a linguagem Tea
echo Licenca: MIT
exit /b 0
