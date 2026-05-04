#!/usr/bin/env fish
# Instalador do Tea Language para Fish Shell

echo "🍵 Instalando Tea Language (Fish)..."

# Verifica se Lua está instalado
set LUA_CMD ""
for cmd in lua lua5.4 lua5.3 lua5.2 lua5.1
    if command -v $cmd > /dev/null 2>&1
        set LUA_CMD $cmd
        break
    end
end

if test -z "$LUA_CMD"
    echo "❌ Erro: Lua não encontrado!"
    echo "Instale primeiro: sudo apt install lua5.4"
    exit 1
end

echo "[+] Lua encontrado: $LUA_CMD"

# Diretório de instalação
set INSTALL_DIR "$HOME/.local/bin"
set TEA_HOME "$HOME/.local/lib/tea"

# Remove instalação antiga se existir
if test -f "$INSTALL_DIR/tea"
    echo "[*] Removendo instalação antiga..."
    rm -f "$INSTALL_DIR/tea"
end

if test -d "$TEA_HOME"
    echo "[*] Removendo bibliotecas antigas..."
    rm -rf "$TEA_HOME"
end

# Cria diretórios
mkdir -p "$INSTALL_DIR"
mkdir -p "$TEA_HOME/src"

# Copia os arquivos
echo "[*] Copiando arquivos..."
cp src/tea.lua "$TEA_HOME/src/"
cp src/vm.lua "$TEA_HOME/src/"
cp src/transpiler.lua "$TEA_HOME/src/"

# Copia o script tea principal e configura TEA_HOME
echo "[*] Instalando script tea..."
sed "s|TEA_HOME=\"\\\${TEA_HOME:-\\\$HOME/Documentos/skylikeProjects/tea}\"|TEA_HOME=\"\\\${TEA_HOME:-\\\$HOME/.local/lib/tea}\"|" tea > "$INSTALL_DIR/tea"
chmod +x "$INSTALL_DIR/tea"

echo "[+] Tea instalado com sucesso!"
echo ""

# Instala Cup também
echo "[*] Instalando Cup (Package Manager)..."
cp cup-official/cup "$INSTALL_DIR/cup"
chmod +x "$INSTALL_DIR/cup"
echo "[+] Cup instalado com sucesso!"
echo ""

echo "Adicionando ao PATH do Fish..."

# Adiciona ao config.fish se ainda não estiver lá
set FISH_CONFIG "$HOME/.config/fish/config.fish"
mkdir -p (dirname "$FISH_CONFIG")

if not grep -q "/.local/bin" "$FISH_CONFIG" 2>/dev/null
    echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$FISH_CONFIG"
    echo "[+] PATH adicionado ao $FISH_CONFIG"
else
    echo "[*] PATH já está configurado no $FISH_CONFIG"
end

echo ""
echo "✅ Instalação completa!"
echo ""
echo "Comandos Tea:"
echo "  tea <arquivo.tea>        # Compila e executa"
echo "  tea build                # Compila todos .tea no diretório"
echo "  tea -c <arquivo.tea>     # Apenas compila"
echo "  tea -r <arquivo.teac>    # Executa bytecode"
echo "  tea help                 # Ver ajuda completa"
echo ""
echo "Comandos Cup:"
echo "  cup update               # Atualiza repositório de extensões"
echo "  cup list                 # Lista pacotes disponíveis"
echo "  cup install <pacote>     # Instala um pacote"
echo "  cup remove <pacote>      # Remove um pacote"
echo "  cup info <pacote>        # Informações do pacote"
echo ""
echo "Execute para ativar agora:"
echo "  source $FISH_CONFIG"
echo ""
echo "Ou abra um novo terminal."
