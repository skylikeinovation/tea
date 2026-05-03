# 🍵 Tea Language - Funcionalidades v0.3.0

## 📋 Índice
1. [Variáveis e Tipos](#variáveis-e-tipos)
2. [Operações Matemáticas](#operações-matemáticas)
3. [Strings](#strings)
4. [Arrays](#arrays)
5. [Dicionários](#dicionários)
6. [Condicionais](#condicionais)
7. [Loops](#loops)
8. [Input/Output](#inputoutput)
9. [Comentários](#comentários)

---

## Variáveis e Tipos

### Declaração de Variáveis
```tea
val nome = "João"
val idade = 25
val altura = 1.75
val ativo = 1  // 1 = true, 0 = false
```

### Tipos Suportados
- **Números**: inteiros e decimais
- **Strings**: texto entre aspas duplas
- **Arrays**: listas de valores
- **Dicionários**: pares chave-valor

---

## Operações Matemáticas

### Operações Inline
```tea
val a = 10
val b = 5

val soma = a + b        // 15
val subtracao = a - b   // 5
val multiplicacao = a * b  // 50
val divisao = a / b     // 2.0
```

### Operações Antigas (Compatibilidade)
```tea
val x = 10
val y = 5
add x, y  // Soma x + y
sub x, y  // Subtrai x - y
```

---

## Strings

### Concatenação
```tea
val nome = "Tea"
val versao = "0.3.0"
val mensagem = "Linguagem " + nome + " v" + versao
// Resultado: "Linguagem Tea v0.3.0"
```

### Métodos de String
```tea
val texto = "hello world"

val maiusculo = texto.upper()  // "HELLO WORLD"
val minusculo = texto.lower()  // "hello world"
```

---

## Arrays

### Criação e Acesso
```tea
val numeros = [1, 2, 3, 4, 5]
val primeiro = numeros[0]  // 1
val terceiro = numeros[2]  // 3

print(numeros)  // [1, 2, 3, 4, 5]
```

### Arrays Vazios
```tea
val lista = []
```

---

## Dicionários

### Criação
```tea
val pessoa = {nome: "João", idade: 25, cidade: "SP"}
print(pessoa)  // {nome: João, idade: 25, cidade: SP}
```

### Dicionários Vazios
```tea
val dados = {}
```

---

## Condicionais

### If/Elif/Else
```tea
val x = 10

if x > 15:
    print("maior que 15")
elif x > 5:
    print("maior que 5")
else:
    print("menor ou igual a 5")
endif
```

### Operadores de Comparação
- `==` : igual
- `n=` : diferente (not equal)
- `<`  : menor
- `>`  : maior
- `<=` : menor ou igual
- `>=` : maior ou igual

### Operadores Lógicos
```tea
val a = 10
val b = 5

// AND
if a > 5 and b < 10:
    print("ambos verdadeiros")
endif

// OR
if a < 5 or b < 10:
    print("pelo menos um verdadeiro")
endif

// NOT
val condicao = 0
if not condicao:
    print("condicao é falsa")
endif
```

---

## Loops

### While Loop
```tea
val i = 0
while i < 5:
    print(i)
    val i = i + 1
endwhile
```

### For Loop com Range
```tea
for i in range(10):
    print(i)  // 0, 1, 2, ..., 9
endfor
```

---

## Input/Output

### Print
```tea
// Print simples
print("Hello, World!")

// Print com múltiplos argumentos
val nome = "João"
print("Olá,", nome, "!")  // Olá, João !

// Print de arrays e dicts
val lista = [1, 2, 3]
print(lista)  // [1, 2, 3]
```

### Input
```tea
// Input de texto
val nome = input("Digite seu nome: ")

// Input numérico
val idade = int(input("Digite sua idade: "))
```

---

## Comentários

### Comentário de Linha
```tea
// Este é um comentário de linha
val x = 10  // Comentário no final da linha
```

### Comentário de Bloco
```tea
\\
Este é um comentário
de múltiplas linhas
\\
```

---

## Estrutura de Programa

### Função Main (Obrigatória)
```tea
fun main():
    // Seu código aqui
    print("Hello, Tea!")
```

**Nota**: Todo programa Tea deve ter uma função `main()`.

---

## Exemplos Completos

### Exemplo 1: Calculadora Simples
```tea
fun main():
    val a = int(input("Digite o primeiro número: "))
    val b = int(input("Digite o segundo número: "))
    
    val soma = a + b
    val mult = a * b
    
    print("Soma:", soma)
    print("Multiplicação:", mult)
```

### Exemplo 2: Contagem com For
```tea
fun main():
    print("Contando até 5:")
    for i in range(5):
        print("Número:", i)
    endfor
```

### Exemplo 3: Verificação de Idade
```tea
fun main():
    val idade = int(input("Digite sua idade: "))
    
    if idade >= 18:
        print("Você é maior de idade")
    else:
        print("Você é menor de idade")
    endif
```

### Exemplo 4: Lista de Nomes
```tea
fun main():
    val nomes = ["João", "Maria", "Pedro"]
    print("Lista de nomes:", nomes)
    
    val primeiro = nomes[0]
    print("Primeiro nome:", primeiro)
```

---

## Comandos CLI

### Compilar e Executar
```bash
tea arquivo.tea
```

### Apenas Compilar
```bash
tea -c arquivo.tea
```

### Executar Bytecode
```bash
tea -r arquivo.teac
```

### Transpilar para Lua
```bash
tea --trans arquivo.tea
```

### Gerar Executável
```bash
tea --build-exec arquivo.tea
tea --build-exec -o meuapp arquivo.tea
```

### Limpar Arquivos Compilados
```bash
tea --clear diretorio/
```

### Ajuda e Versão
```bash
tea help
tea version
```

---

## Próximas Funcionalidades (v0.4.0)

- For-in sobre arrays
- Funções com parâmetros
- String interpolation (f-strings)
- Métodos de array (append, remove, length)
- Métodos de dict (has, keys, values)
- Classes e OOP
- Try/Except

---

**Documentação completa em**: [README.md](README.md)
