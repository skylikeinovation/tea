#!/bin/bash
# Instalador do Tea Language para Bash

echo "🍵 Instalando Tea Language (Bash)..."

# Verifica se Lua está instalado
LUA_CMD=""
for cmd in lua lua5.4 lua5.3 lua5.2 lua5.1; do
    if command -v "$cmd" &> /dev/null; then
        LUA_CMD="$cmd"
        break
    fi
done

if [ -z "$LUA_CMD" ]; then
    echo "❌ Erro: Lua não encontrado!"
    echo "Instale primeiro: sudo apt install lua5.4"
    exit 1
fi

echo "[+] Lua encontrado: $LUA_CMD"

# Diretório de instalação
INSTALL_DIR="$HOME/.local/bin"
TEA_HOME="$HOME/.local/lib/tea"

# Remove instalação antiga se existir
if [ -f "$INSTALL_DIR/tea" ]; then
    echo "[*] Removendo instalação antiga..."
    rm -f "$INSTALL_DIR/tea"
fi

if [ -d "$TEA_HOME" ]; then
    echo "[*] Removendo bibliotecas antigas..."
    rm -rf "$TEA_HOME"
fi

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
sed "s|TEA_HOME=\"\${TEA_HOME:-\$HOME/Documentos/skylikeProjects/tea}\"|TEA_HOME=\"\${TEA_HOME:-\$HOME/.local/lib/tea}\"|" tea > "$INSTALL_DIR/tea"
chmod +x "$INSTALL_DIR/tea"

echo "[+] Tea instalado com sucesso!"
echo ""

# Instala Cup também
echo "[*] Instalando Cup (Package Manager)..."
cp cup-official/cup "$INSTALL_DIR/cup"
chmod +x "$INSTALL_DIR/cup"
echo "[+] Cup instalado com sucesso!"
echo ""

echo "Adicionando ao PATH do Bash..."

# Adiciona ao .bashrc se ainda não estiver lá
if ! grep -q "/.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "[+] PATH adicionado ao ~/.bashrc"
else
    echo "[*] PATH já está configurado no ~/.bashrc"
fi

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
echo "  source ~/.bashrc"
echo ""
echo "Ou abra um novo terminal."
