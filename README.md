# 🍵 Tea Language

Uma linguagem de programação minimalista baseada em pilha (stack-based), escrita em Lua.

## 📦 Instalação

### Instalar Lua

**Ubuntu/Debian:**
```bash
sudo apt install lua5.3
```

**Fedora:**
```bash
sudo dnf install lua
```

**Arch Linux:**
```bash
sudo pacman -S lua
```

**macOS:**
```bash
brew install lua
```

## 📋 Características

- **Sintaxe simples**: Notação polonesa reversa (RPN)
- **Baseada em pilha**: Todas as operações usam uma stack
- **Compilada**: Gera bytecode antes da execução
- **Extensível**: Fácil adicionar novos opcodes

## 🚀 Como Usar

### Compilar e Executar

```bash
# Tornar o script executável (primeira vez)
chmod +x tea

# Executar um programa
./tea examples/hello.tea
```

### Manualmente

```bash
# 1. Compilar (gera arquivo.teac)
lua src/tea.lua examples/hello.tea

# 2. Executar o bytecode
lua src/vm.lua examples/hello.teac
```

## 📖 Sintaxe

### Comandos Disponíveis

| Comando | Descrição |
|---------|-----------|
| `PUSH <num>` | Empilha um número (automático ao escrever números) |
| `ADD` | Soma os dois valores do topo da pilha |
| `SUB` | Subtrai (a - b) |
| `MULT` | Multiplica |
| `DIV` | Divide (a / b) |
| `PRINT` | Imprime o valor do topo da pilha |
| `HALT` | Para a execução (automático no final) |

### Comentários

Use `#` para comentários:

```tea
# Isto é um comentário
5 3 ADD PRINT  # Calcula 5 + 3
```

## 💡 Exemplos

### Hello World (Matemático)

```tea
# examples/hello.tea
5 3 ADD PRINT
```

**Saída**: `8`

### Calculadora

```tea
# examples/calc.tea
10 5 ADD    # Stack: [15]
2 MULT      # Stack: [30]
3 SUB       # Stack: [27]
PRINT       # Imprime: 27
```

**Saída**: `27`

### Divisão

```tea
# examples/division.tea
100 4 DIV PRINT
```

**Saída**: `25.0`

## 🏗️ Arquitetura

```
┌─────────────┐
│  Código Tea │  (arquivo.tea)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Compilador │  (tea.lua)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Bytecode   │  (arquivo.teac)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Máquina VM  │  (vm.lua)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Resultado │
└─────────────┘
```

## 🔧 Estrutura do Projeto

```
tea/
├── src/
│   ├── tea.lua      # Compilador (source → bytecode)
│   └── vm.lua       # Máquina Virtual (executa bytecode)
├── examples/
│   ├── hello.tea    # Exemplo básico
│   ├── calc.tea     # Calculadora
│   └── division.tea # Divisão
├── tea              # Script de execução
└── README.md
```

## 🎯 Como Funciona

### 1. Compilação (tea.lua)

Transforma código Tea em bytecode:

```tea
5 3 ADD PRINT
```

Vira:

```
[PUSH, 5, PUSH, 3, ADD, PRINT, HALT]
```

### 2. Execução (vm.lua)

A VM processa cada instrução usando uma pilha:

```
PUSH 5    → Stack: [5]
PUSH 3    → Stack: [5, 3]
ADD       → Stack: [8]
PRINT     → Imprime: 8
```

## 🚀 Próximas Funcionalidades

- [ ] Variáveis (`SET`, `GET`)
- [ ] Condicionais (`IF`, `ELSE`)
- [ ] Loops (`WHILE`, `FOR`)
- [ ] Funções definidas pelo usuário
- [ ] Strings e I/O
- [ ] Operações lógicas (`AND`, `OR`, `NOT`)

## 📝 Licença

Projeto educacional - Use como quiser! ☕
