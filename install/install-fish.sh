#!/usr/bin/env fish
# Instalador do Tea Language para Fish Shell

echo "🍵 Instalando Tea Language (Fish)..."

# Verifica se Lua está instalado
set LUA_CMD ""
for cmd in lua lua5.4 lua5.3 lua5.2 lua5.1
    if command -v $cmd &> /dev/null
        set LUA_CMD $cmd
        break
    end
end

if test -z "$LUA_CMD"
    echo "❌ Erro: Lua não encontrado!"
    echo "Instale primeiro: sudo apt install lua5.4"
    exit 1
end

# Diretórios
set INSTALL_DIR "$HOME/.local/bin"
set TEA_LIB_DIR "$HOME/.local/lib/tea"

# Remove instalação antiga se existir
if test -f "$INSTALL_DIR/tea"
    echo "[*] Removendo instalação antiga..."
    rm -f "$INSTALL_DIR/tea"
end

if test -d "$TEA_LIB_DIR"
    echo "[*] Removendo bibliotecas antigas..."
    rm -rf "$TEA_LIB_DIR"
end

# Cria diretórios
mkdir -p "$INSTALL_DIR"
mkdir -p "$TEA_LIB_DIR"

# Copia os arquivos
echo "[*] Copiando arquivos..."
cp src/tea.lua "$TEA_LIB_DIR/"
cp src/vm.lua "$TEA_LIB_DIR/"
cp src/transpiler.lua "$TEA_LIB_DIR/"

# Copia o script tea principal
echo "[*] Instalando script tea..."
cp tea "$INSTALL_DIR/tea"

# Ajusta os caminhos no script para usar TEA_LIB
sed -i 's|src/tea.lua|$HOME/.local/lib/tea/tea.lua|g' "$INSTALL_DIR/tea"
sed -i 's|src/vm.lua|$HOME/.local/lib/tea/vm.lua|g' "$INSTALL_DIR/tea"
sed -i 's|src/transpiler.lua|$HOME/.local/lib/tea/transpiler.lua|g' "$INSTALL_DIR/tea"

chmod +x "$INSTALL_DIR/tea"

echo "[+] Tea instalado com sucesso!"
echo ""
echo "Adicionando ao PATH do Fish..."

# Adiciona ao PATH do Fish
fish_add_path "$INSTALL_DIR"

echo ""
echo "✅ Instalação completa!"
echo ""
echo "Você já pode usar:"
echo "  tea arquivo.tea"
