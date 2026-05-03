# 🍵 Tea Language v0.1.0-dev

Uma linguagem de programação moderna e minimalista com sintaxe inspirada em Python, compilada para bytecode e executada em uma VM stack-based escrita em Lua.

## 📦 Instalação

### 1. Instalar Lua

**Ubuntu/Debian:**
```bash
sudo apt install lua5.4
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

### 2. Instalar Tea

**Linux/macOS (Bash/Zsh):**
```bash
cd tea
bash install/install-bash.sh  # ou install-zsh.sh
```

**Fish Shell:**
```bash
fish install/install-fish.sh
```

**Windows:**
```cmd
cd tea\windows
install.bat
```

## 🚀 Como Usar

```bash
# Executar um programa
tea programa.tea

# Compilar todos .tea no diretório
tea build

# Apenas compilar (gera .teac)
tea -c programa.tea

# Executar bytecode
tea -r programa.teac

# Ver ajuda
tea help
```

## 📖 Sintaxe

### Hello World

```tea
fun main():
    print("Olá, mundo!")
```

### Variáveis

```tea
fun main():
    val nome = "João"
    val idade = 25
    val altura = 1.75
    
    print("Nome:", nome)
    print("Idade:", idade)
```

### Operações Matemáticas

```tea
fun main():
    val x = 10 + 5
    val y = x * 2
    val z = y / 3
    
    print(z)  // 10
```

### Input do Usuário

```tea
fun main():
    val nome = input("Digite seu nome: ")
    val idade = int(input("Digite sua idade: "))
    
    print("Olá,", nome, "!")
    print("Você tem", idade, "anos")
```

### Condicionais

```tea
fun main():
    val idade = int(input("Idade: "))
    
    if idade >= 18:
        print("Maior de idade")
    elif idade >= 13:
        print("Adolescente")
    else:
        print("Criança")
    endif
```

### Loops

**While:**
```tea
fun main():
    val i = 0
    while i < 5:
        print(i)
        val i = i + 1
    endwhile
```

**For (range):**
```tea
fun main():
    for i in range(10):
        print(i)
    endfor
```

**For-in (arrays):**
```tea
fun main():
    val lista = [1, 2, 3, 4, 5]
    
    for item in lista:
        print(item)
    endfor
```

### Arrays

```tea
fun main():
    val numeros = [1, 2, 3, 4, 5]
    val frutas = ["maçã", "banana", "laranja"]
    
    print(numeros[1])  // 1 (arrays são 1-indexed!)
    print(frutas[2])   // "banana"
```

### Dicionários

```tea
fun main():
    val pessoa = {nome: "João", idade: 25, cidade: "SP"}
    
    print(pessoa)
```

### Strings

```tea
fun main():
    val texto = "hello world"
    val maiusculo = texto.upper()
    val minusculo = texto.lower()
    
    print(maiusculo)  // "HELLO WORLD"
    print(minusculo)  // "hello world"
    
    val junto = "Hello" + " " + "World"
    print(junto)  // "Hello World"
```

### Try/Except

```tea
fun main():
    try:
        val num = int(input("Digite um número: "))
        print("Você digitou:", num)
    except:
        print("❌ Erro: Digite apenas números!")
    endtry
```

### Operadores Lógicos

```tea
fun main():
    val x = 10
    val y = 5
    
    if x > 5 and y < 10:
        print("Ambos verdadeiros")
    endif
    
    if x == 0 or y == 0:
        print("Pelo menos um é zero")
    endif
    
    if not x == 0:
        print("x não é zero")
    endif
```

## 📋 Características Implementadas

✅ **Básico:**
- Variáveis (`val nome = valor`)
- Print com múltiplos argumentos
- Input (`input()`, `int(input())`)
- Operações matemáticas inline
- Comentários (`//` e `\\ \\`)

✅ **Estruturas de Dados:**
- Arrays 1-indexed (`[1, 2, 3]`)
- Dicionários (`{chave: valor}`)
- Strings avançadas (`.upper()`, `.lower()`, concatenação)

✅ **Controle de Fluxo:**
- Condicionais (`if`, `elif`, `else`)
- Loops (`while`, `for in range()`, `for in array`)
- Try/Except

✅ **Operadores:**
- Aritméticos: `+`, `-`, `*`, `/`
- Comparação: `==`, `n=`, `<`, `>`, `<=`, `>=`
- Lógicos: `and`, `or`, `not`

## 🏗️ Arquitetura

```
┌─────────────┐
│  Código Tea │  (arquivo.tea)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Compilador │  (src/tea.lua)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Bytecode   │  (arquivo.teac)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Máquina VM  │  (src/vm.lua)
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
│   ├── tea.lua          # Compilador (Tea → Bytecode)
│   ├── vm.lua           # Máquina Virtual
│   └── transpiler.lua   # Transpilador (Tea → Lua) [EXPERIMENTAL]
├── examples/
│   ├── completo.tea     # Exemplo completo
│   ├── arrays.tea       # Arrays
│   ├── for-in.tea       # For-in loops
│   ├── try-except.tea   # Tratamento de erros
│   └── ...
├── install/
│   ├── install-bash.sh
│   ├── install-zsh.sh
│   └── install-fish.sh
├── tea                  # CLI principal
└── README.md
```

## 🎯 Roadmap

Veja [ROADMAP.md](ROADMAP.md) para features planejadas.

**Próximas funcionalidades:**
- Funções com parâmetros e retorno
- String interpolation (f-strings)
- Classes e OOP
- Módulos e imports

## ⚠️ Limitações Conhecidas

- **Transpilador (--trans, --build-exec)**: Está desatualizado e não suporta features recentes (try/except, for-in, etc). Use apenas o modo compilado (bytecode).
- **Funções**: Ainda não suportam parâmetros (em desenvolvimento)

## 📝 Comparação com Python

Veja [COMPARISON.md](COMPARISON.md) para comparação detalhada com Python.

## 📄 Licença

Apache 2.0 - Veja LICENSE para detalhes.

## 🤝 Contribuindo

Contribuições são bem-vindas! Abra uma issue ou pull request.

---

**Tea Language** - Uma linguagem simples e poderosa para aprender e criar! ☕
