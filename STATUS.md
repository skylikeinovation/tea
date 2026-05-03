# 🍵 Tea Language - Status Atual

## ✅ MUDANÇAS RECENTES

### For-in sobre arrays implementado! 🎉 (v0.4.0)
```tea
val lista = [10, 20, 30]
for item in lista:
    print(item)  // 10, 20, 30
endfor
```

### Arrays agora começam em 1! 🎉
```tea
val lista = [10, 20, 30, 40, 50]
val primeiro = lista[1]  // 10
val ultimo = lista[5]    // 50
```

**Mais intuitivo e natural!**

---

## 📊 Nível Atual: **~45% do Python** ⬆️

### ✅ O QUE FUNCIONA (v0.3.0)

#### 1. **Variáveis e Tipos**
```tea
val nome = "João"
val idade = 25
val altura = 1.75
```

#### 2. **Arrays (1-indexed)**
```tea
val lista = [1, 2, 3, 4, 5]
val primeiro = lista[1]  // 1
val ultimo = lista[5]    // 5
```

#### 3. **Dicionários**
```tea
val pessoa = {nome: "João", idade: 25}
print(pessoa)  // {nome: João, idade: 25}
```

#### 4. **Condicionais**
```tea
if x > 5:
    print("maior")
elif x == 5:
    print("igual")
else:
    print("menor")
endif
```

#### 5. **Operadores Lógicos**
```tea
if x > 5 and y < 10:
    print("OK")
endif

if not condicao:
    print("Falso")
endif
```

#### 6. **Loops**
```tea
// While
while i < 10:
    print(i)
    val i = i + 1
endwhile

// For com range
for i in range(10):
    print(i)
endfor
```

#### 7. **Strings**
```tea
val texto = "hello"
val maiusculo = texto.upper()
val minusculo = texto.lower()
val junto = "Hello" + " " + "World"
```

#### 8. **Matemática Inline**
```tea
val soma = a + b
val mult = a * b
val div = a / b
```

#### 9. **Input/Output**
```tea
val nome = input("Digite seu nome: ")
val idade = int(input("Digite sua idade: "))
print("Olá,", nome, "!")
```

---

## ❌ O QUE FALTA

### Prioridade ALTA (v0.4.0)

#### 1. **For-in sobre arrays** ✅ IMPLEMENTADO!
```tea
val lista = [1, 2, 3]
for item in lista:
    print(item)
endfor
```

#### 2. **Funções com parâmetros** ⏳
```tea
fun soma(a, b):
    return a + b
endfun

val resultado = soma(10, 5)
```

#### 3. **Métodos de array**
```tea
val lista = [1, 2, 3]
lista.append(4)      // Adiciona no final
lista.remove(2)      // Remove elemento
val tam = lista.length()  // Tamanho
```

#### 4. **Acesso a dicionários**
```tea
val pessoa = {nome: "João", idade: 25}
val nome = pessoa.get("nome")
pessoa.set("cidade", "SP")
```

#### 5. **String interpolation**
```tea
val nome = "João"
print(f"Olá, {nome}!")
```

---

### Prioridade MÉDIA (v0.5.0)

#### 6. **Classes e OOP**
```tea
class Pessoa:
    fun __init__(self, nome):
        self.nome = nome
    endfun
    
    fun falar(self):
        print("Olá, sou " + self.nome)
    endfun
endclass

val p = Pessoa("João")
p.falar()
```

#### 7. **Try/Except**
```tea
try:
    val x = 10 / 0
except:
    print("Erro!")
finally:
    print("Fim")
endtry
```

#### 8. **Métodos de dict**
```tea
val pessoa = {nome: "João"}
val tem = pessoa.has("idade")
val chaves = pessoa.keys()
val valores = pessoa.values()
```

#### 9. **String split**
```tea
val texto = "a,b,c"
val partes = texto.split(",")  // ["a", "b", "c"]
```

---

### Prioridade BAIXA (v1.0.0+)

- Imports/Módulos
- List comprehension
- Lambda functions
- Slicing
- Operador `in`
- Múltiplas atribuições
- Operador ternário
- Decorators
- Generators
- Context managers

---

## 🎯 Roadmap

### v0.3.0 ✅
- ✅ Arrays (1-indexed)
- ✅ Dicionários
- ✅ For loops com range
- ✅ Operadores lógicos
- ✅ Strings avançadas
- ✅ Matemática inline
- ✅ Print com múltiplos args

### v0.4.0 (EM ANDAMENTO) ⏳
- ✅ For-in sobre arrays
- ⏳ Funções com parâmetros
- ⏳ Métodos de array
- ⏳ Acesso a dicionários
- ⏳ String interpolation

### v0.5.0 (FUTURO) 📅
- 📅 Classes e OOP
- 📅 Try/Except
- 📅 Métodos de dict
- 📅 String split
- 📅 Mais métodos de string

### v1.0.0 (META) 🚀
- 🚀 Imports/Módulos
- 🚀 List comprehension
- 🚀 Lambda functions
- 🚀 Linguagem completa

---

## 📈 Progresso

```
v0.1.0: ████░░░░░░░░░░░░░░░░ 20% - Básico
v0.2.0: ████████░░░░░░░░░░░░ 30% - Condicionais e loops
v0.3.0: ████████████░░░░░░░░ 40% - Arrays, dicts, strings
v0.4.0: █████████████░░░░░░░ 45% - For-in ✅ ATUAL
v0.5.0: ██████████████████░░ 70% - OOP e exceções
v1.0.0: ████████████████████ 90% - Linguagem completa
```

---

## 💡 Diferenças do Python

| Aspecto | Python | Tea |
|---------|--------|-----|
| **Declaração** | `x = 10` | `val x = 10` |
| **Comentário** | `# texto` | `// texto` |
| **Fim de bloco** | Indentação | `endif`, `endwhile`, `endfor` |
| **Diferente** | `!=` | `n=` |
| **Função** | `def nome():` | `fun nome():` |
| **Array index** | 0-indexed | **1-indexed** ⭐ |
| **Dict keys** | `{"nome": "x"}` | `{nome: "x"}` |

---

## 🎨 Filosofia do Tea

1. **Explícito é melhor que implícito**
   - `val` deixa claro que é uma variável
   - `endif`, `endwhile` são mais explícitos

2. **Simples é melhor que complexo**
   - Menos features = mais fácil de aprender
   - Sintaxe clara e direta

3. **Intuitivo para iniciantes**
   - Arrays começam em 1 (mais natural)
   - Blocos explícitos (não depende de indentação)

4. **Inspirado no Python, mas com identidade própria**
   - Mantém o que funciona bem
   - Melhora o que pode ser mais claro

---

## 🎯 Para quem é o Tea?

### ✅ Ideal para:
- **Iniciantes em programação**
- **Aprender conceitos básicos**
- **Scripts simples**
- **Automação básica**
- **Projetos educacionais**
- **Prototipagem rápida**

### ❌ Ainda não ideal para:
- Projetos grandes e complexos
- Bibliotecas e frameworks
- Aplicações profissionais
- Programação avançada

---

## 📚 Documentação

- **[README.md](README.md)** - Documentação principal
- **[FEATURES.md](FEATURES.md)** - Guia completo de funcionalidades
- **[ROADMAP.md](ROADMAP.md)** - Roadmap detalhado
- **[COMPARISON.md](COMPARISON.md)** - Comparação com Python
- **[SUMMARY.md](SUMMARY.md)** - Resumo da implementação

---

## 🧪 Exemplos

Execute os exemplos para ver Tea em ação:

```bash
tea examples/completo.tea        # Exemplo completo
tea examples/nivel-python.tea    # Comparação com Python
tea examples/arrays.tea          # Arrays (1-indexed)
tea examples/for-loop.tea        # For loops
tea examples/logicos.tea         # Operadores lógicos
tea examples/strings.tea         # Strings avançadas
tea examples/matematica.tea      # Matemática inline
```

---

## 🎉 Conclusão

**Tea v0.3.0 é uma linguagem funcional e divertida!**

- ✅ Sintaxe clara e intuitiva
- ✅ Arrays começam em 1 (mais natural)
- ✅ Estruturas de dados básicas
- ✅ Controle de fluxo completo
- ✅ Operadores lógicos
- ✅ Strings avançadas

**Tea está em ~40% do Python, mas com as funcionalidades essenciais para aprender programação!**

---

**Próximo passo**: Implementar v0.4.0 com funções, for-in e métodos! 🚀
