# 🍵 Tea Language - Windows

## 📦 Instalação

### 1. Instalar Lua

Escolha uma opção:

**Opção 1: LuaForWindows (Recomendado)**
- Download: https://github.com/rjpcomputing/luaforwindows/releases
- Instale o executável

**Opção 2: Chocolatey**
```cmd
choco install lua
```

**Opção 3: Scoop**
```cmd
scoop install lua
```

### 2. Instalar Tea

Execute o instalador:
```cmd
cd windows
install.bat
```

### 3. Adicionar ao PATH

**Método 1: Manual**
1. Pressione `Win + Pause`
2. Clique em "Configurações avançadas do sistema"
3. Clique em "Variáveis de Ambiente"
4. Em "Variáveis do usuário", selecione "Path"
5. Clique em "Editar" e adicione: `%USERPROFILE%\.tea\bin`
6. Clique em "OK"

**Método 2: PowerShell (Admin)**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\.tea\bin", "User")
```

### 4. Testar

Abra um novo CMD/PowerShell:
```cmd
tea version
tea help
tea ..\examples\hello.tea
```

## 🚀 Uso

```cmd
tea arquivo.tea              REM Compila e executa
tea -c arquivo.tea           REM Apenas compila
tea -r arquivo.teac          REM Executa bytecode
tea --trans arquivo.tea      REM Transpila para Lua
tea --build-exec arquivo.tea REM Gera executável .bat
tea --clear examples         REM Limpa .teac
tea version                  REM Mostra versão
tea help                     REM Mostra ajuda
```

## 📝 Notas

- O Tea funciona perfeitamente no Windows!
- Executáveis gerados são `.bat` (não `.exe`)
- Para `.exe` verdadeiros, use `luastatic` (opcional)
- Funciona no CMD, PowerShell e Git Bash

## 🐛 Problemas Comuns

**"Lua não encontrado"**
- Instale o Lua (veja passo 1)
- Verifique se está no PATH: `where lua`

**"tea não é reconhecido"**
- Adicione `%USERPROFILE%\.tea\bin` ao PATH
- Abra um novo terminal

**"Arquivo não encontrado"**
- Use caminhos relativos ou absolutos
- Exemplo: `tea ..\examples\hello.tea`
