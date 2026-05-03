-- ============================================
-- tea.lua - Compilador Tea v0.3.0
-- ============================================
-- Suporte completo: arrays, for, strings avançadas, funções, etc

local input_file = arg[1] or "main.tea"
local output_file = input_file .. "c"

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

    -- Operadores lógicos
    AND = 24, OR = 25, NOT = 26,

    -- Arrays
    CREATE_ARRAY = 30, ARRAY_PUSH = 31, ARRAY_GET = 32,
    ARRAY_SET = 33, ARRAY_LEN = 34, ARRAY_APPEND = 35,

    -- Strings
    STR_CONCAT = 50, STR_UPPER = 51, STR_LOWER = 52,
    STR_SPLIT = 53, STR_LEN = 54,

    -- Funções
    CALL = 80, RETURN = 81,

    -- Dicionários
    CREATE_DICT = 40, DICT_GET = 41, DICT_SET = 42,
}

-- ============================================
-- ESTADO
-- ============================================
local bytecode = {}
local variables = {}
local var_count = 0
local labels = {}
local label_count = 0
local jumps_to_patch = {}

-- ============================================
-- FUNÇÕES AUXILIARES
-- ============================================

local function emit(opcode, value)
    table.insert(bytecode, opcode)
    if value ~= nil then
        table.insert(bytecode, value)
    end
end

local function get_var_index(name)
    if not variables[name] then
        variables[name] = var_count
        var_count = var_count + 1
    end
    return variables[name]
end

local function new_label()
    local label = "L" .. label_count
    label_count = label_count + 1
    return label
end

local function mark_label(label)
    labels[label] = #bytecode + 1
end

local function emit_jump(opcode, label)
    table.insert(jumps_to_patch, {
        position = #bytecode + 2,
        label = label
    })
    emit(opcode, 0)
end

local function patch_jumps()
    for _, jump in ipairs(jumps_to_patch) do
        local addr = labels[jump.label]
        if not addr then
            error("Label não encontrado: " .. jump.label)
        end
        bytecode[jump.position] = addr
    end
end

local function remove_comments(source)
    source = source:gsub("//[^\n]*", "")
    source = source:gsub("\\.-\\", "")
    return source
end

-- Compila expressão (suporta operações inline)
local function compile_expression(expr)
    expr = expr:match("^%s*(.-)%s*$")

    -- Concatenação/Operação com + (VERIFICAR PRIMEIRO!)
    if expr:match("%+") then
        local parts = {}
        local current = ""
        local in_string = false

        for i = 1, #expr do
            local char = expr:sub(i, i)
            if char == '"' then
                in_string = not in_string
                current = current .. char
            elseif char == "+" and not in_string then
                local trimmed = current:match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    table.insert(parts, trimmed)
                end
                current = ""
            else
                current = current .. char
            end
        end

        local trimmed = current:match("^%s*(.-)%s*$")
        if trimmed ~= "" then
            table.insert(parts, trimmed)
        end

        if #parts > 1 then
            -- Se tem strings literais, usa STR_CONCAT
            local has_string = expr:match('"')

            compile_expression(parts[1])
            for i = 2, #parts do
                compile_expression(parts[i])
                if has_string then
                    emit(OP.STR_CONCAT)
                else
                    emit(OP.ADD)
                end
            end
            return
        end
    end

    -- String literal simples
    if expr:match('^"[^"]*"$') then
        local str = expr:match('^"([^"]*)"$')
        emit(OP.PUSH_STR, #str)
        for i = 1, #str do
            emit(string.byte(str, i))
        end
        return
    end

    -- Número
    local num = tonumber(expr)
    if num then
        emit(OP.PUSH, num)
        return
    end

    -- Array literal: [1, 2, 3]
    if expr:match("^%[.*%]$") then
        emit(OP.CREATE_ARRAY)
        local content = expr:match("^%[(.*)%]$")
        if content and content ~= "" then
            for item in content:gmatch("[^,]+") do
                compile_expression(item)
                emit(OP.ARRAY_PUSH)
            end
        end
        return
    end

    -- Dict literal: {nome: "João", idade: 25}
    if expr:match("^{.*}$") then
        emit(OP.CREATE_DICT)
        local content = expr:match("^{(.*)}$")
        if content and content ~= "" then
            for pair in content:gmatch("[^,]+") do
                local key, value = pair:match("([%w_%-]+)%s*:%s*(.+)")
                if key and value then
                    emit(OP.PUSH_STR, #key)
                    for i = 1, #key do
                        emit(string.byte(key, i))
                    end
                    compile_expression(value)
                    emit(OP.DICT_SET)
                end
            end
        end
        return
    end

    -- Operação matemática: a - b, a * b, a / b
    if expr:match("[%-*/]") then
        local a, op, b = expr:match("([%w_%-]+)%s*([%-*/])%s*([%w_%-]+)")
        if a and op and b then
            compile_expression(a)
            compile_expression(b)

            if op == "-" then emit(OP.SUB)
            elseif op == "*" then emit(OP.MULT)
            elseif op == "/" then emit(OP.DIV)
            end
            return
        end
    end

    -- Acesso a array: lista[0]
    if expr:match("%[%d+%]") then
        local var, index = expr:match("([%w_%-]+)%[(%d+)%]")
        if var and index then
            emit(OP.LOAD, get_var_index(var))
            emit(OP.PUSH, tonumber(index))
            emit(OP.ARRAY_GET)
            return
        end
    end

    -- Método de string: texto.upper()
    if expr:match("%.upper%(%)") then
        local var = expr:match("([%w_%-]+)%.upper%(%)") 
        emit(OP.LOAD, get_var_index(var))
        emit(OP.STR_UPPER)
        return
    end

    if expr:match("%.lower%(%)") then
        local var = expr:match("([%w_%-]+)%.lower%(%)") 
        emit(OP.LOAD, get_var_index(var))
        emit(OP.STR_LOWER)
        return
    end

    -- int(input(...))
    if expr:match("^int%(input%(") then
        local prompt = expr:match('int%(input%("(.-)"%)%)') or ""
        emit(OP.PUSH_STR, #prompt)
        for i = 1, #prompt do
            emit(string.byte(prompt, i))
        end
        emit(OP.INPUT)
        emit(OP.TO_NUMBER)
        return
    end

    -- input(...)
    if expr:match("^input%(") then
        local prompt = expr:match('input%("(.-)"%)') or ""
        emit(OP.PUSH_STR, #prompt)
        for i = 1, #prompt do
            emit(string.byte(prompt, i))
        end
        emit(OP.INPUT)
        return
    end

    -- Variável simples
    emit(OP.LOAD, get_var_index(expr))
end

-- Compila condição
local function compile_condition(condition)
    -- Operadores lógicos: and, or, not
    if condition:match(" and ") then
        local a, b = condition:match("(.+)%s+and%s+(.+)")
        compile_condition(a)
        compile_condition(b)
        emit(OP.AND)
        return
    end

    if condition:match(" or ") then
        local a, b = condition:match("(.+)%s+or%s+(.+)")
        compile_condition(a)
        compile_condition(b)
        emit(OP.OR)
        return
    end

    if condition:match("^not ") then
        local expr = condition:match("^not%s+(.+)")
        compile_condition(expr)
        emit(OP.NOT)
        return
    end

    -- Comparações normais
    local var1, op, var2

    if condition:match("==") then
        var1, var2 = condition:match("([%w%-_]+)%s*==%s*([%w%-_]+)")
        op = OP.EQ
    elseif condition:match("n=") then
        var1, var2 = condition:match("([%w%-_]+)%s*n=%s*([%w%-_]+)")
        op = OP.NE
    elseif condition:match("<=") then
        var1, var2 = condition:match("([%w%-_]+)%s*<=%s*([%w%-_]+)")
        op = OP.LE
    elseif condition:match(">=") then
        var1, var2 = condition:match("([%w%-_]+)%s*>=%s*([%w%-_]+)")
        op = OP.GE
    elseif condition:match("<") then
        var1, var2 = condition:match("([%w%-_]+)%s*<%s*([%w%-_]+)")
        op = OP.LT
    elseif condition:match(">") then
        var1, var2 = condition:match("([%w%-_]+)%s*>%s*([%w%-_]+)")
        op = OP.GT
    else
        -- Expressão booleana simples (variável)
        compile_expression(condition)
        return
    end

    compile_expression(var1)
    compile_expression(var2)
    emit(op)
end

-- ============================================
-- PARSER v0.3.0
-- ============================================

local function parse(source)
    source = remove_comments(source)

    local lines = {}
    for line in source:gmatch("[^\n]+") do
        table.insert(lines, line:match("^%s*(.-)%s*$"))
    end

    local block_stack = {}
    local in_function = false

    for _, line in ipairs(lines) do
        if line == "" then
            -- Ignora

        elseif line:match("^fun%s+") then
            in_function = true

        elseif line:match("^return") then
            if line:match("^return%s+") then
                local expr = line:match("^return%s+(.+)")
                compile_expression(expr)
            end
            emit(OP.RETURN)

        -- Print com múltiplos argumentos
        elseif line:match("^print%(") then
            local content = line:match("print%((.+)%)")

            -- Separa por vírgulas (fora de strings)
            local args = {}
            local current = ""
            local in_string = false
            local in_brackets = 0

            for i = 1, #content do
                local char = content:sub(i, i)
                if char == '"' then
                    in_string = not in_string
                    current = current .. char
                elseif char == "[" or char == "{" then
                    in_brackets = in_brackets + 1
                    current = current .. char
                elseif char == "]" or char == "}" then
                    in_brackets = in_brackets - 1
                    current = current .. char
                elseif char == "," and not in_string and in_brackets == 0 then
                    table.insert(args, current:match("^%s*(.-)%s*$"))
                    current = ""
                else
                    current = current .. char
                end
            end
            table.insert(args, current:match("^%s*(.-)%s*$"))

            -- Se tem apenas 1 argumento, imprime direto
            if #args == 1 then
                compile_expression(args[1])
                emit(OP.PRINT)
            else
                -- Múltiplos argumentos: converte tudo para string e concatena
                compile_expression(args[1])
                emit(OP.PUSH_STR, 0)  -- String vazia para forçar conversão
                emit(OP.STR_CONCAT)

                for i = 2, #args do
                    compile_expression(args[i])
                    emit(OP.PUSH_STR, 0)  -- String vazia para forçar conversão
                    emit(OP.STR_CONCAT)
                    emit(OP.STR_CONCAT)
                end

                emit(OP.PRINT)
            end

        elseif line:match("^val%s+") then
            local var_name, rest = line:match("^val%s+([%w%-_]+)%s*=%s*(.+)$")
            compile_expression(rest)
            emit(OP.STORE, get_var_index(var_name))

        -- Operações matemáticas antigas (compatibilidade)
        elseif line:match("^add%s+") then
            local var1, var2 = line:match("^add%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            emit(OP.LOAD, get_var_index(var1))
            emit(OP.LOAD, get_var_index(var2))
            emit(OP.ADD)

        elseif line:match("^sub%s+") then
            local var1, var2 = line:match("^sub%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            emit(OP.LOAD, get_var_index(var1))
            emit(OP.LOAD, get_var_index(var2))
            emit(OP.SUB)

        -- CONDICIONAIS
        elseif line:match("^if%s+") then
            local condition = line:match("^if%s+(.+):")
            compile_condition(condition)

            local else_label = new_label()
            local end_label = new_label()

            emit_jump(OP.JUMP_IF_FALSE, else_label)

            table.insert(block_stack, {
                type = "if",
                else_label = else_label,
                end_label = end_label,
                has_else = false
            })

        elseif line:match("^elif%s+") then
            if #block_stack == 0 then error("elif sem if") end

            local condition = line:match("^elif%s+(.+):")
            local block = block_stack[#block_stack]

            emit_jump(OP.JUMP, block.end_label)
            mark_label(block.else_label)

            compile_condition(condition)

            block.else_label = new_label()
            emit_jump(OP.JUMP_IF_FALSE, block.else_label)

        elseif line:match("^else:") then
            if #block_stack == 0 then error("else sem if") end

            local block = block_stack[#block_stack]
            emit_jump(OP.JUMP, block.end_label)
            mark_label(block.else_label)
            block.has_else = true

        elseif line:match("^endif") then
            if #block_stack == 0 then error("endif sem if") end

            local block = table.remove(block_stack)

            if not block.has_else then
                mark_label(block.else_label)
            end

            mark_label(block.end_label)

        -- LOOPS
        elseif line:match("^while%s+") then
            local condition = line:match("^while%s+(.+):")

            local start_label = new_label()
            local end_label = new_label()

            mark_label(start_label)
            compile_condition(condition)
            emit_jump(OP.JUMP_IF_FALSE, end_label)

            table.insert(block_stack, {
                type = "while",
                start_label = start_label,
                end_label = end_label
            })

        elseif line:match("^for%s+") then
            -- for i in range(10):
            if line:match("in%s+range%(") then
                local var, max = line:match("^for%s+([%w_%-]+)%s+in%s+range%((%d+)%):")

                -- Inicializa variável
                emit(OP.PUSH, 0)
                emit(OP.STORE, get_var_index(var))

                local start_label = new_label()
                local end_label = new_label()

                mark_label(start_label)

                -- Verifica condição
                emit(OP.LOAD, get_var_index(var))
                emit(OP.PUSH, tonumber(max))
                emit(OP.LT)
                emit_jump(OP.JUMP_IF_FALSE, end_label)

                table.insert(block_stack, {
                    type = "for",
                    var = var,
                    start_label = start_label,
                    end_label = end_label
                })
            
            -- for item in lista: (NOVO!)
            elseif line:match("in%s+[%w_%-]+:") then
                local var, array_var = line:match("^for%s+([%w_%-]+)%s+in%s+([%w_%-]+):")
                
                -- Cria variável de índice temporária
                local index_var = "__index_" .. var
                
                -- Inicializa índice em 1 (Tea é 1-indexed)
                emit(OP.PUSH, 1)
                emit(OP.STORE, get_var_index(index_var))
                
                local start_label = new_label()
                local end_label = new_label()
                
                mark_label(start_label)
                
                -- Verifica se índice <= tamanho do array
                emit(OP.LOAD, get_var_index(index_var))
                emit(OP.LOAD, get_var_index(array_var))
                emit(OP.ARRAY_LEN)
                emit(OP.LE)
                emit_jump(OP.JUMP_IF_FALSE, end_label)
                
                -- Carrega item atual: var = array[index]
                emit(OP.LOAD, get_var_index(array_var))
                emit(OP.LOAD, get_var_index(index_var))
                emit(OP.ARRAY_GET)
                emit(OP.STORE, get_var_index(var))
                
                table.insert(block_stack, {
                    type = "for-in",
                    var = var,
                    index_var = index_var,
                    start_label = start_label,
                    end_label = end_label
                })
            end

        elseif line:match("^endwhile") or line:match("^endfor") then
            if #block_stack == 0 then error("end sem loop") end

            local block = table.remove(block_stack)

            if block.type == "for" then
                -- Incrementa variável (for range)
                emit(OP.LOAD, get_var_index(block.var))
                emit(OP.PUSH, 1)
                emit(OP.ADD)
                emit(OP.STORE, get_var_index(block.var))
            elseif block.type == "for-in" then
                -- Incrementa índice (for-in)
                emit(OP.LOAD, get_var_index(block.index_var))
                emit(OP.PUSH, 1)
                emit(OP.ADD)
                emit(OP.STORE, get_var_index(block.index_var))
            end

            emit_jump(OP.JUMP, block.start_label)
            mark_label(block.end_label)
        end
    end

    if #block_stack > 0 then
        error("Bloco não fechado")
    end

    if not in_function then
        error("Função 'main' não encontrada")
    end

    emit(OP.HALT)
    patch_jumps()
end

-- ============================================
-- EXECUÇÃO
-- ============================================

local f = io.open(input_file, "r")
if not f then
    print("!! Erro: Arquivo não encontrado!")
    os.exit(1)
end
local source = f:read("*all")
f:close()

print("[*] Compilando: " .. input_file)

local success, err = pcall(parse, source)
if not success then
    print("!! " .. err)
    os.exit(1)
end

local out = io.open(output_file, "wb")
if not out then
    print("!! Erro: Não foi possível criar arquivo de saída!")
    os.exit(1)
end
for _, v in ipairs(bytecode) do
    out:write(string.pack("i4", v))
end
out:close()

print("[+] Sucesso! '" .. output_file .. "' gerado.")
print("[*] Variáveis: " .. var_count)
