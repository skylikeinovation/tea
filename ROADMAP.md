# 🍵 Tea Language - Roadmap v0.3.0

## ✅ Implementado (v0.3.0)

### **Funcionalidades Básicas**
- [x] Variáveis (`val nome = "valor"`)
- [x] Operações matemáticas inline (`val x = 10 + 5`)
- [x] Print com múltiplos argumentos (`print("olá,", nome, "!")`)
- [x] Input (`val nome = input("Digite: ")`)
- [x] Input numérico (`val num = int(input("Número: "))`)
- [x] Comentários (`//` e `\\ \\`)

### **1. Arrays/Listas** ✅
```tea
val lista = [1, 2, 3, 4, 5]
val item = lista[0]
print(lista)  // [1, 2, 3, 4, 5]
```

### **2. For Loops** ✅
```tea
for i in range(10):
    print(i)
endfor
```

### **3. Operadores Lógicos** ✅
```tea
if x > 5 and y < 10:
    print("OK")
endif

if not condicao:
    print("Falso")
endif

if a or b:
    print("Um é verdadeiro")
endif
```

### **4. Dicionários** ✅
```tea
val pessoa = {nome: "João", idade: 25}
print(pessoa)  // {nome: João, idade: 25}
```

### **5. Strings Avançadas** ✅
```tea
val texto = "hello world"
val maiusculo = texto.upper()
val minusculo = texto.lower()
val junto = "Hello" + " " + "World"
```

### **6. Condicionais** ✅
```tea
if x > 5:
    print("maior")
elif x == 5:
    print("igual")
else:
    print("menor")
endif
```

### **7. While Loops** ✅
```tea
val i = 0
while i < 10:
    print(i)
    val i = i + 1
endwhile
```

## 🚧 Próximas Funcionalidades (v0.4.0)

### **1. For-in sobre Arrays** ✅ IMPLEMENTADO!
```tea
val lista = [1, 2, 3]
for item in lista:
    print(item)
endfor
```

### **2. Funções com Parâmetros** ⏳
```tea
fun soma(a, b):
    return a + b
endfun

val resultado = soma(10, 5)
```

### **3. String Interpolation (f-strings)**
```tea
val nome = "João"
print(f"Olá, {nome}!")
```

### **4. Classes/OOP** 🏗️
```tea
class Pessoa:
    fun __init__(self, nome, idade):
        self.nome = nome
        self.idade = idade
    endfun
    
    fun apresentar(self):
        print("Olá, sou " + self.nome)
    endfun
endclass

val p = Pessoa("João", 25)
p.apresentar()
```

### **5. Try/Except** 🛡️
```tea
try:
    val x = 10 / 0
except:
    print("Erro de divisão!")
finally:
    print("Sempre executa")
endtry
```

### **6. Métodos de Array**
```tea
val lista = [1, 2, 3]
lista.append(4)
lista.remove(1)
val tamanho = lista.length()
```

### **7. Métodos de Dict**
```tea
val pessoa = {nome: "João"}
val tem_idade = pessoa.has("idade")
val chaves = pessoa.keys()
```

## 📅 Timeline
- **v0.3.0** (CONCLUÍDO): Arrays, For range, Operadores Lógicos, Dicts, Strings
- **v0.4.0** (EM ANDAMENTO): ✅ For-in, ⏳ Funções com params, ⏳ f-strings
- **v0.5.0** (Futuro): Classes/OOP, Try/Except
- **v1.0.0** (Meta): Linguagem completa estilo Python

## 🎯 Meta Final
**Tea = Python simplificado com sintaxe própria!**

## 📊 Progresso Atual
- ✅ Sintaxe básica
- ✅ Estruturas de dados (arrays, dicts)
- ✅ Controle de fluxo (if, while, for)
- ✅ Operadores lógicos
- ✅ Strings avançadas
- ⏳ Funções avançadas
- ⏳ OOP
- ⏳ Exceções
