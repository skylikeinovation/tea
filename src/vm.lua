-- ============================================
-- vm.lua - Máquina Virtual Tea v0.3.0
-- ============================================
-- Suporte completo para: arrays, dicts, for, operadores lógicos, OOP

local bytecode_file = arg[1] or "main.teac"

-- ============================================
-- OPCODES v0.3.0
-- ============================================
local OP = {
    -- Básicos
    PUSH = 1, ADD = 2, SUB = 3, PRINT = 4, HALT = 5,
    MULT = 6, DIV = 7, STORE = 8, LOAD = 9, INPUT = 10,
    PUSH_STR = 14, TO_NUMBER = 23,
    
    -- Comparação
    EQ = 15, NE = 16, LT = 17, GT = 18, LE = 19, GE = 20,
    
    -- Controle de fluxo
    JUMP = 21, JUMP_IF_FALSE = 22,
    
    -- Operadores lógicos (NOVOS)
    AND = 24, OR = 25, NOT = 26,
    
    -- Arrays (NOVOS)
    CREATE_ARRAY = 30,      -- Cria array vazio
    ARRAY_PUSH = 31,        -- Adiciona elemento ao array
    ARRAY_GET = 32,         -- Pega elemento por índice
    ARRAY_SET = 33,         -- Define elemento por índice
    ARRAY_LEN = 34,         -- Retorna tamanho do array
    ARRAY_APPEND = 35,      -- Append (adiciona no final)
    ARRAY_REMOVE = 36,      -- Remove elemento
    
    -- Dicionários (NOVOS)
    CREATE_DICT = 40,       -- Cria dicionário vazio
    DICT_GET = 41,          -- Pega valor por chave
    DICT_SET = 42,          -- Define valor por chave
    DICT_HAS = 43,          -- Verifica se chave existe
    
    -- Strings (NOVOS)
    STR_CONCAT = 50,        -- Concatena strings
    STR_UPPER = 51,         -- Converte para maiúsculas
    STR_LOWER = 52,         -- Converte para minúsculas
    STR_SPLIT = 53,         -- Divide string
    STR_LEN = 54,           -- Tamanho da string
    
    -- OOP (NOVOS)
    CREATE_CLASS = 60,      -- Define uma classe
    CREATE_INSTANCE = 61,   -- Cria instância
    GET_ATTR = 62,          -- Pega atributo
    SET_ATTR = 63,          -- Define atributo
    CALL_METHOD = 64,       -- Chama método
    
    -- Exceções (NOVOS)
    TRY_BEGIN = 70,         -- Início do bloco try
    TRY_END = 71,           -- Fim do bloco try
    CATCH = 72,             -- Captura exceção
    THROW = 73,             -- Lança exceção
    FINALLY = 74,           -- Bloco finally
    
    -- Funções (NOVOS)
    CALL = 80,              -- Chama função
    RETURN = 81,            -- Retorna de função
    PUSH_PARAM = 82,        -- Empilha parâmetro
    
    -- Break/Continue (NOVOS)
    BREAK = 27,             -- Sai do bloco
    CONTINUE = 28,          -- Continua próxima iteração
    
    -- Garbage Collector (NOVOS)
    GC_COLLECT = 90,        -- Força coleta de lixo
    GC_INIT = 91,           -- Inicializa GC
    GC_STOP = 92,           -- Para GC
    
    -- Módulos/Imports (NOVOS)
    REQUIRE = 95,           -- Carrega módulo Lua
    LOAD_MODULE = 96,       -- Carrega módulo Tea
    CALL_METHOD = 97,       -- Chama método de módulo
}

-- ============================================
-- ESTADO DA VM
-- ============================================
local stack = {}
local sp = 0
local variables = {}
local call_stack = {}
local call_sp = 0

-- Novos estados para v0.3
local classes = {}          -- Tabela de classes definidas
local exception_stack = {}  -- Pilha de exceções
local exception_sp = 0

-- ============================================
-- FUNÇÕES DA PILHA
-- ============================================

local function push(value)
    sp = sp + 1
    stack[sp] = value
end

local function pop()
    if sp < 1 then
        error("!! Erro: Stack Underflow")
    end
    local value = stack[sp]
    stack[sp] = nil
    sp = sp - 1
    return value
end

-- ============================================
-- CARREGADOR DE BYTECODE
-- ============================================

local function load_bytecode(filename)
    local f = io.open(filename, "rb")
    if not f then
        error("!! Erro: Arquivo '" .. filename .. "' não encontrado")
    end
    
    local bytecode = {}
    while true do
        local bytes = f:read(4)
        if not bytes then break end
        local value = string.unpack("i4", bytes)
        table.insert(bytecode, value)
    end
    f:close()
    
    return bytecode
end

-- ============================================
-- EXECUTOR v0.3.0
-- ============================================

local function execute(bytecode)
    local ip = 1
    
    while ip <= #bytecode do
        local opcode = bytecode[ip]
        ip = ip + 1
        
        -- ========================================
        -- OPERAÇÕES BÁSICAS
        -- ========================================
        
        if opcode == OP.PUSH then
            push(bytecode[ip])
            ip = ip + 1
            
        elseif opcode == OP.PUSH_STR then
            local len = bytecode[ip]
            ip = ip + 1
            local str = ""
            for i = 1, len do
                str = str .. string.char(bytecode[ip])
                ip = ip + 1
            end
            push(str)
            
        elseif opcode == OP.ADD then
            local b, a = pop(), pop()
            push(a + b)
            
        elseif opcode == OP.SUB then
            local b, a = pop(), pop()
            push(a - b)
            
        elseif opcode == OP.MULT then
            local b, a = pop(), pop()
            push(a * b)
            
        elseif opcode == OP.DIV then
            local b, a = pop(), pop()
            if b == 0 then error("!! Erro: Divisão por zero") end
            push(a / b)
            
        elseif opcode == OP.STORE then
            local var_idx = bytecode[ip]
            ip = ip + 1
            variables[var_idx] = pop()
            
        elseif opcode == OP.LOAD then
            local var_idx = bytecode[ip]
            ip = ip + 1
            if variables[var_idx] == nil then
                error("!! Erro: Variável não inicializada")
            end
            push(variables[var_idx])
            
        elseif opcode == OP.INPUT then
            local prompt = pop()
            io.write(prompt)
            push(io.read())
            
        elseif opcode == OP.PRINT then
            local value = pop()
            
            -- Formata arrays e dicts para impressão legível
            if type(value) == "table" then
                if value.__type == "instance" then
                    print("<instância de " .. value.__class .. ">")
                elseif value.__class then
                    print("<classe " .. value.__class .. ">")
                else
                    -- Array ou dict
                    local is_array = true
                    for k, v in pairs(value) do
                        if type(k) ~= "number" then
                            is_array = false
                            break
                        end
                    end
                    
                    if is_array then
                        local items = {}
                        for i = 1, #value do
                            table.insert(items, tostring(value[i]))
                        end
                        print("[" .. table.concat(items, ", ") .. "]")
                    else
                        local items = {}
                        for k, v in pairs(value) do
                            table.insert(items, tostring(k) .. ": " .. tostring(v))
                        end
                        print("{" .. table.concat(items, ", ") .. "}")
                    end
                end
            else
                print(value)
            end
            
        elseif opcode == OP.TO_NUMBER then
            local value = pop()
            local num = tonumber(value)
            if not num then
                error("!! Erro: Não foi possível converter para número")
            end
            push(num)
            
        -- ========================================
        -- COMPARAÇÕES
        -- ========================================
        
        elseif opcode == OP.EQ then
            local b, a = pop(), pop()
            push(a == b and 1 or 0)
            
        elseif opcode == OP.NE then
            local b, a = pop(), pop()
            push(a ~= b and 1 or 0)
            
        elseif opcode == OP.LT then
            local b, a = pop(), pop()
            push(a < b and 1 or 0)
            
        elseif opcode == OP.GT then
            local b, a = pop(), pop()
            push(a > b and 1 or 0)
            
        elseif opcode == OP.LE then
            local b, a = pop(), pop()
            push(a <= b and 1 or 0)
            
        elseif opcode == OP.GE then
            local b, a = pop(), pop()
            push(a >= b and 1 or 0)
            
        -- ========================================
        -- OPERADORES LÓGICOS (NOVOS)
        -- ========================================
        
        elseif opcode == OP.AND then
            local b, a = pop(), pop()
            push((a ~= 0 and b ~= 0) and 1 or 0)
            
        elseif opcode == OP.OR then
            local b, a = pop(), pop()
            push((a ~= 0 or b ~= 0) and 1 or 0)
            
        elseif opcode == OP.NOT then
            local a = pop()
            push(a == 0 and 1 or 0)
            
        -- ========================================
        -- ARRAYS (NOVOS)
        -- ========================================
        
        elseif opcode == OP.CREATE_ARRAY then
            push({})  -- Cria array vazio
            
        elseif opcode == OP.ARRAY_PUSH then
            local value = pop()
            local arr = pop()
            table.insert(arr, value)
            push(arr)
            
        elseif opcode == OP.ARRAY_GET then
            local index = pop()
            local arr = pop()
            if type(arr) ~= "table" then
                error("!! Erro: Não é um array")
            end
            push(arr[index] or nil)  -- Tea agora é 1-indexed como Lua
            
        elseif opcode == OP.ARRAY_SET then
            local value = pop()
            local index = pop()
            local arr = pop()
            arr[index] = value  -- Tea agora é 1-indexed como Lua
            push(arr)
            
        elseif opcode == OP.ARRAY_LEN then
            local arr = pop()
            push(#arr)
            
        elseif opcode == OP.ARRAY_APPEND then
            local value = pop()
            local arr = pop()
            table.insert(arr, value)
            push(arr)
            
        elseif opcode == OP.ARRAY_REMOVE then
            local index = pop()
            local arr = pop()
            table.remove(arr, index)  -- Tea agora é 1-indexed como Lua
            push(arr)
            
        -- ========================================
        -- DICIONÁRIOS (NOVOS)
        -- ========================================
        
        elseif opcode == OP.CREATE_DICT then
            push({})  -- Cria dict vazio
            
        elseif opcode == OP.DICT_GET then
            local key = pop()
            local dict = pop()
            push(dict[key])
            
        elseif opcode == OP.DICT_SET then
            local value = pop()
            local key = pop()
            local dict = pop()
            dict[key] = value
            push(dict)
            
        elseif opcode == OP.DICT_HAS then
            local key = pop()
            local dict = pop()
            push(dict[key] ~= nil and 1 or 0)
            
        -- ========================================
        -- STRINGS (NOVOS)
        -- ========================================
        
        elseif opcode == OP.STR_CONCAT then
            local b, a = pop(), pop()
            
            -- Converte arrays/dicts para string legível
            local function to_string(value)
                if type(value) ~= "table" then
                    return tostring(value)
                end
                
                if value.__type == "instance" then
                    return "<instância de " .. value.__class .. ">"
                elseif value.__class then
                    return "<classe " .. value.__class .. ">"
                end
                
                -- Verifica se é array
                local is_array = true
                for k, v in pairs(value) do
                    if type(k) ~= "number" then
                        is_array = false
                        break
                    end
                end
                
                if is_array then
                    local items = {}
                    for i = 1, #value do
                        table.insert(items, tostring(value[i]))
                    end
                    return "[" .. table.concat(items, ", ") .. "]"
                else
                    local items = {}
                    for k, v in pairs(value) do
                        table.insert(items, tostring(k) .. ": " .. tostring(v))
                    end
                    return "{" .. table.concat(items, ", ") .. "}"
                end
            end
            
            push(to_string(a) .. to_string(b))
            
        elseif opcode == OP.STR_UPPER then
            local str = pop()
            push(string.upper(tostring(str)))
            
        elseif opcode == OP.STR_LOWER then
            local str = pop()
            push(string.lower(tostring(str)))
            
        elseif opcode == OP.STR_SPLIT then
            local sep = pop()
            local str = pop()
            local result = {}
            for part in string.gmatch(str, "([^" .. sep .. "]+)") do
                table.insert(result, part)
            end
            push(result)
            
        elseif opcode == OP.STR_LEN then
            local str = pop()
            push(#tostring(str))
            
        -- ========================================
        -- OOP (NOVOS)
        -- ========================================
        
        elseif opcode == OP.CREATE_CLASS then
            local class_name = pop()
            local methods = pop()
            classes[class_name] = {
                methods = methods,
                __type = "class"
            }
            
        elseif opcode == OP.CREATE_INSTANCE then
            local class_name = pop()
            local class = classes[class_name]
            if not class then
                error("!! Erro: Classe não encontrada: " .. class_name)
            end
            local instance = {
                __class = class_name,
                __type = "instance"
            }
            push(instance)
            
        elseif opcode == OP.GET_ATTR then
            local attr_name = pop()
            local obj = pop()
            push(obj[attr_name])
            
        elseif opcode == OP.SET_ATTR then
            local value = pop()
            local attr_name = pop()
            local obj = pop()
            obj[attr_name] = value
            push(obj)
            
        elseif opcode == OP.CALL_METHOD then
            local method_name = pop()
            local obj = pop()
            local class = classes[obj.__class]
            local method = class.methods[method_name]
            if not method then
                error("!! Erro: Método não encontrado: " .. method_name)
            end
            -- Chama método (simplificado)
            push(obj)
            
        -- ========================================
        -- EXCEÇÕES (NOVOS)
        -- ========================================
        
        elseif opcode == OP.TRY_BEGIN then
            local catch_addr = bytecode[ip]
            ip = ip + 1
            exception_sp = exception_sp + 1
            exception_stack[exception_sp] = {
                catch_addr = catch_addr,
                stack_size = sp
            }
            
        elseif opcode == OP.TRY_END then
            if exception_sp > 0 then
                exception_stack[exception_sp] = nil
                exception_sp = exception_sp - 1
            end
            
        elseif opcode == OP.THROW then
            local error_msg = pop()
            if exception_sp > 0 then
                local handler = exception_stack[exception_sp]
                sp = handler.stack_size
                push(error_msg)
                ip = handler.catch_addr
            else
                error("!! Exceção não tratada: " .. tostring(error_msg))
            end
            
        -- ========================================
        -- CONTROLE DE FLUXO
        -- ========================================
        
        elseif opcode == OP.JUMP then
            ip = bytecode[ip]
            
        elseif opcode == OP.JUMP_IF_FALSE then
            local addr = bytecode[ip]
            ip = ip + 1
            if pop() == 0 then
                ip = addr
            end
            
        elseif opcode == OP.CALL then
            local addr = bytecode[ip]
            ip = ip + 1
            call_sp = call_sp + 1
            call_stack[call_sp] = ip
            ip = addr
            
        elseif opcode == OP.RETURN then
            if call_sp < 1 then
                error("!! Erro: RETURN sem CALL")
            end
            ip = call_stack[call_sp]
            call_stack[call_sp] = nil
            call_sp = call_sp - 1
            
        elseif opcode == OP.BREAK then
            -- Break sai do loop/bloco
            -- O compilador deve gerar um JUMP para o label de fim do bloco
            -- Se chegou aqui sem JUMP, é um erro
            error("!! Erro: BREAK sem contexto de loop")
            
        -- ========================================
        -- GARBAGE COLLECTOR (NOVOS)
        -- ========================================
        
        elseif opcode == OP.GC_INIT then
            -- Inicializa GC (modo incremental)
            collectgarbage("restart")
            collectgarbage("setpause", 100)
            collectgarbage("setstepmul", 200)
            
        elseif opcode == OP.GC_COLLECT then
            -- Força coleta completa
            collectgarbage("collect")
            
        elseif opcode == OP.GC_STOP then
            -- Para o GC
            collectgarbage("stop")
            
        -- ========================================
        -- MÓDULOS/IMPORTS (NOVOS)
        -- ========================================
        
        elseif opcode == OP.REQUIRE then
            -- Pega o caminho do módulo da pilha
            local path = pop()
            
            -- Tenta carregar módulo Tea (.teac) ou Lua (.lua)
            local success, module = pcall(function()
                local chunk, err
                
                -- Tenta .teac primeiro (bytecode Tea)
                if io.open(path .. ".teac", "rb") then
                    -- Carrega bytecode Tea
                    local f = io.open(path .. ".teac", "rb")
                    local bytecode_data = {}
                    while true do
                        local bytes = f:read(4)
                        if not bytes then break end
                        local value = string.unpack("i4", bytes)
                        table.insert(bytecode_data, value)
                    end
                    f:close()
                    
                    -- Executa o bytecode em uma sub-VM
                    -- Por enquanto, retorna uma tabela vazia
                    -- (implementação completa seria complexa)
                    return {}
                
                -- Tenta .lua (módulo Lua)
                elseif io.open(path .. ".lua", "rb") then
                    chunk, err = loadfile(path .. ".lua")
                    if not chunk then
                        error("Erro ao carregar módulo: " .. err)
                    end
                    return chunk()
                
                -- Tenta sem extensão (pode ser .lua ou .teac)
                else
                    chunk, err = loadfile(path)
                    if not chunk then
                        error("Erro ao carregar módulo: " .. err)
                    end
                    return chunk()
                end
            end)
            
            if not success then
                error("!! Erro ao importar módulo: " .. tostring(module))
            end
            
            -- Empilha o módulo (tabela Lua)
            push(module)
            
        elseif opcode == OP.CALL_METHOD then
            -- Número de argumentos
            local arg_count = bytecode[ip]
            ip = ip + 1
            
            -- Pega argumentos da pilha
            local args = {}
            for i = 1, arg_count do
                table.insert(args, 1, pop())  -- Inverte ordem
            end
            
            -- Pega nome do método
            local method_name = pop()
            
            -- Pega o módulo (tabela)
            local module = pop()
            
            if type(module) ~= "table" then
                error("!! Erro: Tentando chamar método de não-módulo")
            end
            
            -- Pega a função do módulo
            local func = module[method_name]
            if type(func) ~= "function" then
                error("!! Erro: Método não encontrado: " .. tostring(method_name))
            end
            
            -- Chama a função Lua
            local result = func(table.unpack(args))
            
            -- Se retornar algo, empilha
            if result ~= nil then
                push(result)
            end
            
        elseif opcode == OP.HALT then
            break
            
        else
            error("!! Erro: Opcode desconhecido: " .. opcode)
        end
    end
end

-- ============================================
-- EXECUÇÃO
-- ============================================

local success, bytecode = pcall(load_bytecode, bytecode_file)
if not success then
    print(bytecode)
    os.exit(1)
end

success, err = pcall(execute, bytecode)
if not success then
    print(err)
    os.exit(1)
end
