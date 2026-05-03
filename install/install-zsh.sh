#!/bin/zsh
# Instalador do Tea Language para Zsh

echo "🍵 Instalando Tea Language (Zsh)..."

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

# Diretório de instalação
INSTALL_DIR="$HOME/.local/bin"
TEA_LIB_DIR="$HOME/.local/lib/tea"

# Remove instalação antiga se existir
if [ -f "$INSTALL_DIR/tea" ]; then
    echo "[*] Removendo instalação antiga..."
    rm -f "$INSTALL_DIR/tea"
fi

if [ -d "$TEA_LIB_DIR" ]; then
    echo "[*] Removendo bibliotecas antigas..."
    rm -rf "$TEA_LIB_DIR"
fi

# Cria diretórios
mkdir -p "$INSTALL_DIR"
mkdir -p "$TEA_LIB_DIR"

# Copia os arquivos
echo "[*] Copiando arquivos..."
cp src/tea.lua "$TEA_LIB_DIR/"
cp src/vm.lua "$TEA_LIB_DIR/"

# Cria o script tea
cat > "$INSTALL_DIR/tea" << 'EOF'
#!/bin/bash
LUA_CMD=""
for cmd in lua lua5.4 lua5.3 lua5.2 lua5.1; do
    if command -v "$cmd" &> /dev/null; then
        LUA_CMD="$cmd"
        break
    fi
done

TEA_LIB="$HOME/.local/lib/tea"

if [ -z "$1" ]; then
    echo "Uso: tea <arquivo.tea>           (compila e executa)"
    echo "      tea -c <arquivo.tea>       (apenas compila)"
    echo "      tea -r <arquivo.teac>      (executa bytecode)"
    exit 1
fi

if [ "$1" == "-c" ]; then
    [ -z "$2" ] && echo "Uso: tea -c <arquivo.tea>" && exit 1
    [ ! -f "$2" ] && echo "❌ Erro: Arquivo '$2' não encontrado!" && exit 1
    echo "🍵 Tea Language - Compilando"
    echo "======================================"
    $LUA_CMD "$TEA_LIB/tea.lua" "$2"
elif [ "$1" == "-r" ]; then
    [ -z "$2" ] && echo "Uso: tea -r <arquivo.teac>" && exit 1
    [ ! -f "$2" ] && echo "❌ Erro: Arquivo '$2' não encontrado!" && exit 1
    $LUA_CMD "$TEA_LIB/vm.lua" "$2"
else
    PROGRAM="$1"
    BASENAME="${PROGRAM%.tea}"
    [ ! -f "$PROGRAM" ] && echo "❌ Erro: Arquivo '$PROGRAM' não encontrado!" && exit 1
    echo "🍵 Tea Language - Compilando e Executando"
    echo "=========================================="
    $LUA_CMD "$TEA_LIB/tea.lua" "$PROGRAM"
    if [ $? -eq 0 ]; then
        echo ""
        $LUA_CMD "$TEA_LIB/vm.lua" "${BASENAME}.teac"
    fi
fi
EOF

chmod +x "$INSTALL_DIR/tea"

echo "[+] Tea instalado com sucesso!"
echo ""
echo "Adicionando ao PATH do Zsh..."

# Adiciona ao .zshrc se ainda não estiver lá
if ! grep -q "/.local/bin" "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    echo "[+] PATH adicionado ao ~/.zshrc"
else
    echo "[*] PATH já está configurado no ~/.zshrc"
fi

echo ""
echo "✅ Instalação completa!"
echo ""
echo "Execute para ativar agora:"
echo "  source ~/.zshrc"
echo ""
echo "Ou abra um novo terminal e use:"
echo "  tea arquivo.tea"
