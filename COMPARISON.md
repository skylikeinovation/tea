# 🍵 Tea vs 🐍 Python - Comparação

## 📊 O que Tea JÁ TEM (v0.3.0)

| Funcionalidade | Python | Tea | Status |
|----------------|--------|-----|--------|
| **Variáveis** | `x = 10` | `val x = 10` | ✅ |
| **Print** | `print("olá", nome)` | `print("olá", nome)` | ✅ |
| **Input** | `input("Digite: ")` | `input("Digite: ")` | ✅ |
| **Input numérico** | `int(input())` | `int(input())` | ✅ |
| **Arrays/Listas** | `[1, 2, 3]` | `[1, 2, 3]` | ✅ |
| **Acesso array** | `lista[1]` | `lista[1]` | ✅ (1-indexed) |
| **Dicionários** | `{"nome": "João"}` | `{nome: "João"}` | ✅ |
| **If/elif/else** | `if x > 5:` | `if x > 5:` | ✅ |
| **While** | `while x < 10:` | `while x < 10:` | ✅ |
| **For range** | `for i in range(10):` | `for i in range(10):` | ✅ |
| **Operadores lógicos** | `and`, `or`, `not` | `and`, `or`, `not` | ✅ |
| **Concatenação** | `"a" + "b"` | `"a" + "b"` | ✅ |
| **String upper** | `texto.upper()` | `texto.upper()` | ✅ |
| **String lower** | `texto.lower()` | `texto.lower()` | ✅ |
| **Comentários** | `# comentário` | `// comentário` | ✅ |
| **Matemática inline** | `x = a + b` | `val x = a + b` | ✅ |

---

## ❌ O que Tea AINDA NÃO TEM

### 1. **For-in sobre listas**
```python
# Python
lista = [1, 2, 3]
for item in lista:
    print(item)
```
```tea
// Tea (ainda não funciona)
val lista = [1, 2, 3]
for item in lista:
    print(item)
endfor
```
**Status**: ⏳ Planejado para v0.4.0

---

### 2. **Funções com parâmetros**
```python
# Python
def soma(a, b):
    return a + b

resultado = soma(10, 5)
```
```tea
// Tea (ainda não funciona)
fun soma(a, b):
    return a + b
endfun

val resultado = soma(10, 5)
```
**Status**: ⏳ Planejado para v0.4.0

---

### 3. **String interpolation (f-strings)**
```python
# Python
nome = "João"
print(f"Olá, {nome}!")
```
```tea
// Tea (ainda não funciona)
val nome = "João"
print(f"Olá, {nome}!")
```
**Status**: ⏳ Planejado para v0.4.0

---

### 4. **Métodos de lista**
```python
# Python
lista = [1, 2, 3]
lista.append(4)
lista.remove(2)
tamanho = len(lista)
```
```tea
// Tea (ainda não funciona)
val lista = [1, 2, 3]
lista.append(4)
lista.remove(2)
val tamanho = lista.length()
```
**Status**: ⏳ Planejado para v0.4.0

---

### 5. **Acesso a dicionários**
```python
# Python
pessoa = {"nome": "João", "idade": 25}
nome = pessoa["nome"]
pessoa["cidade"] = "SP"
```
```tea
// Tea (ainda não funciona)
val pessoa = {nome: "João", idade: 25}
val nome = pessoa["nome"]
pessoa["cidade"] = "SP"
```
**Status**: ⏳ Planejado para v0.4.0

---

### 6. **Classes e OOP**
```python
# Python
class Pessoa:
    def __init__(self, nome):
        self.nome = nome
    
    def falar(self):
        print(f"Olá, sou {self.nome}")

p = Pessoa("João")
p.falar()
```
```tea
// Tea (ainda não funciona)
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
**Status**: ⏳ Planejado para v0.5.0

---

### 7. **Try/Except**
```python
# Python
try:
    x = 10 / 0
except ZeroDivisionError:
    print("Erro!")
finally:
    print("Fim")
```
```tea
// Tea (ainda não funciona)
try:
    val x = 10 / 0
except:
    print("Erro!")
finally:
    print("Fim")
endtry
```
**Status**: ⏳ Planejado para v0.5.0

---

### 8. **List comprehension**
```python
# Python
quadrados = [x**2 for x in range(10)]
```
**Status**: ❓ Não planejado ainda

---

### 9. **Múltiplos retornos**
```python
# Python
def minmax(lista):
    return min(lista), max(lista)

a, b = minmax([1, 2, 3])
```
**Status**: ❓ Não planejado ainda

---

### 10. **Imports/Módulos**
```python
# Python
import math
print(math.sqrt(16))
```
**Status**: ❓ Não planejado ainda

---

### 11. **Lambda/Funções anônimas**
```python
# Python
dobro = lambda x: x * 2
```
**Status**: ❓ Não planejado ainda

---

### 12. **Slicing**
```python
# Python
lista = [1, 2, 3, 4, 5]
sublista = lista[1:3]  # [2, 3]
```
**Status**: ❓ Não planejado ainda

---

### 13. **Operador in**
```python
# Python
if "João" in lista:
    print("Encontrado")
```
**Status**: ❓ Não planejado ainda

---

### 14. **Múltiplas atribuições**
```python
# Python
a, b = 10, 20
a, b = b, a  # swap
```
**Status**: ❓ Não planejado ainda

---

### 15. **Operador ternário**
```python
# Python
x = 10 if condicao else 20
```
**Status**: ❓ Não planejado ainda

---

## 📈 Nível Atual: **~40% do Python**

### ✅ O que funciona bem:
- Sintaxe básica
- Estruturas de controle (if, while, for)
- Estruturas de dados básicas (arrays, dicts)
- Operadores lógicos
- Strings básicas
- I/O básico

### ⏳ Próximas prioridades (v0.4.0):
1. **For-in sobre arrays** (essencial)
2. **Funções com parâmetros** (essencial)
3. **Métodos de array** (append, remove, length)
4. **Acesso a dicionários** (essencial)
5. **String interpolation** (qualidade de vida)

### 🎯 Para chegar a 70% do Python (v0.5.0):
- Classes e OOP
- Try/Except
- Métodos de dict
- String split
- Mais métodos de string

### 🚀 Para chegar a 90% do Python (v1.0.0):
- Imports/Módulos
- List comprehension
- Lambda functions
- Slicing
- Operador in
- Múltiplas atribuições

---

## 🎨 Diferenças de Sintaxe

| Aspecto | Python | Tea |
|---------|--------|-----|
| **Declaração** | `x = 10` | `val x = 10` |
| **Comentário** | `# texto` | `// texto` |
| **Fim de bloco** | Indentação | `endif`, `endwhile`, `endfor` |
| **Diferente** | `!=` | `n=` |
| **Função** | `def nome():` | `fun nome():` |
| **Array index** | 0-indexed | 1-indexed |
| **Dict keys** | `{"nome": "x"}` | `{nome: "x"}` |

---

## 💡 Vantagens do Tea

1. **Explícito**: `val` deixa claro que é uma variável
2. **Blocos claros**: `endif`, `endwhile` são mais explícitos que indentação
3. **1-indexed**: Mais intuitivo para iniciantes
4. **Simples**: Menos features = mais fácil de aprender

---

## 🎯 Conclusão

**Tea v0.3.0 está em ~40% do Python**, mas com as funcionalidades essenciais:
- ✅ Variáveis e tipos básicos
- ✅ Estruturas de controle
- ✅ Arrays e dicts
- ✅ Operadores lógicos
- ✅ I/O básico

**Com v0.4.0 (funções + for-in + métodos)**, Tea chegará a **~60% do Python**.

**Com v0.5.0 (OOP + exceções)**, Tea chegará a **~70% do Python**.

**Tea é perfeito para**:
- Aprender programação
- Scripts simples
- Automação básica
- Projetos educacionais

**Tea ainda não é ideal para**:
- Projetos grandes e complexos
- Bibliotecas e frameworks
- Programação avançada
- Aplicações profissionais

---

**Mas Tea v0.3.0 já é uma linguagem funcional e divertida de usar!** 🎉
