-- ============================================
-- tea.lua - Compilador Tea v0.4.0
-- ============================================
-- Suporte completo: arrays, for, strings avançadas, funções, etc
-- NOVO: Indentation-based block boundaries (Python-style)

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
    
    -- Break/Continue
    BREAK = 27, CONTINUE = 28,

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
    
    -- Garbage Collector
    GC_COLLECT = 90, GC_INIT = 91, GC_STOP = 92,
    
    -- Módulos/Imports
    REQUIRE = 95, LOAD_MODULE = 96, CALL_METHOD = 97,
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
    -- Remove comentários em bloco inline: //texto\\
    source = source:gsub("//(.-)\\", "")
    
    -- Remove comentários de linha: // até o fim da linha
    source = source:gsub("//[^\n]*", "")
    
    -- Remove comentários em bloco multi-linha: \\ texto \\
    source = source:gsub("\\.-\\", "")
    
    return source
end

-- Processa includes (@include)
local function process_includes(source, base_path)
    base_path = base_path or "."
    
    -- Procura por @include("caminho")
    source = source:gsub('@include%("([^"]+)"%)', function(path)
        -- Resolve caminho relativo
        local full_path = base_path .. "/" .. path
        
        -- Lê o arquivo
        local f = io.open(full_path, "r")
        if not f then
            error("!! Erro: Arquivo de include não encontrado: " .. full_path)
        end
        local content = f:read("*all")
        f:close()
        
        -- Retorna o conteúdo (será injetado no código)
        return "-- [INCLUDE: " .. path .. "]\n" .. content .. "\n-- [END INCLUDE]"
    end)
    
    return source
end

-- Extrai indentação de uma linha
local function get_indent(line)
    local indent = line:match("^(%s*)")
    return #indent
end

-- Remove indentação de uma linha
local function strip_indent(line)
    return line:match("^%s*(.-)%s*$") or ""
end

-- Compila expressão (suporta operações inline)
local function compile_expression(expr)
    if not expr or expr == "" then
        error("Expressão vazia")
    end
    
    expr = expr:match("^%s*(.-)%s*$")
    
    if not expr or expr == "" then
        error("Expressão vazia após trim")
    end

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
-- PARSER v0.4.0 - INDENTATION-BASED
-- ============================================

local function parse(source)
    -- Processa includes primeiro
    local base_path = input_file:match("(.*/)")  or "."
    source = process_includes(source, base_path)
    
    source = remove_comments(source)

    -- Converte linhas preservando indentação
    local lines = {}
    for line in source:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local block_stack = {}
    local in_function = false
    local const_vars = {}   -- Variáveis const (imutáveis)
    local i = 1

    -- Função para processar bloco com indentação
    local function process_block(start_indent)
        while i <= #lines do
            local line = lines[i]
            local indent = get_indent(line)
            local stripped = strip_indent(line)

            -- Linha vazia ou comentário: ignora
            if stripped == "" or stripped:match("^//") then
                i = i + 1
                goto continue
            end

            -- Se indentação diminuiu, fim do bloco
            if indent < start_indent then
                return
            end

            -- Se indentação é igual ao nível do bloco, processa
            if indent == start_indent then
                i = i + 1

                -- USE (imports)
                if stripped:match("^use%s+") then
                    local var_name, path = stripped:match('^use%s+([%w%-_]+)%s*=%s*"([^"]+)"')
                    if not var_name or not path then
                        var_name, path = stripped:match('^use%s+([%w%-_]+)%s*=%s*([%w%./%-_]+)$')
                    end
                    if var_name and path then
                        emit(OP.PUSH_STR, #path)
                        for j = 1, #path do
                            emit(string.byte(path, j))
                        end
                        emit(OP.REQUIRE)
                        emit(OP.STORE, get_var_index(var_name))
                    else
                        error("Sintaxe inválida: use nome = \"path\" ou use nome = path")
                    end

                elseif stripped:match("^fun%s+") then
                    local func_name = stripped:match("^fun%s+([%w%-_]+)")
                    
                    -- Valida: kebab-case OU snake_case (não camelCase)
                    if func_name and func_name:match("[A-Z]") then
                        error("Erro: Use kebab-case ou snake_case! '" .. func_name .. "' contém maiúsculas.")
                    end
                    
                    in_function = true
                    -- Processa o bloco da função
                    process_block(indent + 4)
                    -- Após processar o bloco, retorna ao nível anterior

                elseif stripped:match("^return") then
                    if stripped:match("^return%s+") then
                        local expr = stripped:match("^return%s+(.+)")
                        compile_expression(expr)
                    end
                    emit(OP.RETURN)

                elseif stripped:match("^close") then
                    -- Close - encerra o programa inteiro
                    emit(OP.HALT)

                -- Chamadas de função simples: func()
                elseif stripped:match("^[%w_%-]+%(%)$") then
                    local func_name = stripped:match("^([%w_%-]+)%(%)$")
                    if func_name then
                        -- Valida: kebab-case OU snake_case (não camelCase)
                        if func_name:match("[A-Z]") then
                            error("Erro: Use kebab-case ou snake_case! '" .. func_name .. "' contém maiúsculas.")
                        end
                        
                        -- Emite chamada de função
                        emit(OP.CALL, get_var_index(func_name))
                    end

                -- Chamadas de método: cmd.exe("...")
                elseif stripped:match("^[%w_%-]+%.[%w_%-]+%(") then
                    local module, method, args = stripped:match("^([%w_%-]+)%.([%w_%-]+)%((.*)%)$")
                    if module and method then
                        emit(OP.LOAD, get_var_index(module))
                        emit(OP.PUSH_STR, #method)
                        for j = 1, #method do
                            emit(string.byte(method, j))
                        end
                        
                        local arg_count = 0
                        if args and args ~= "" then
                            if args:match('^".*"$') then
                                local str = args:match('^"(.*)"$')
                                emit(OP.PUSH_STR, #str)
                                for j = 1, #str do
                                    emit(string.byte(str, j))
                                end
                                arg_count = 1
                            else
                                compile_expression(args)
                                arg_count = 1
                            end
                        end
                        
                        emit(OP.CALL_METHOD, arg_count)
                    end

                -- Print com múltiplos argumentos
                elseif stripped:match("^print%(") then
                    local content = stripped:match("print%((.+)%)")

                    local args = {}
                    local current = ""
                    local in_string = false
                    local in_brackets = 0

                    for j = 1, #content do
                        local char = content:sub(j, j)
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

                    if #args == 1 then
                        compile_expression(args[1])
                        emit(OP.PRINT)
                    else
                        compile_expression(args[1])
                        emit(OP.PUSH_STR, 0)
                        emit(OP.STR_CONCAT)

                        for j = 2, #args do
                            compile_expression(args[j])
                            emit(OP.PUSH_STR, 0)
                            emit(OP.STR_CONCAT)
                            emit(OP.STR_CONCAT)
                        end

                        emit(OP.PRINT)
                    end

                elseif stripped:match("^val%s+") then
                    local var_name, rest = stripped:match("^val%s+([%w%-_]+)%s*=%s*(.+)$")
                    
                    -- Valida: kebab-case OU snake_case (não camelCase, não palavras juntas)
                    if var_name then
                        if var_name:match("[A-Z]") then
                            error("Erro: Use kebab-case ou snake_case! '" .. var_name .. "' contém maiúsculas.")
                        elseif var_name:match("_") then
                            -- Warning: snake_case detectado
                            print("[!] Aviso: Se quiser uma experiência melhor use kebab-case! (em vez de '" .. var_name .. "')")
                        end
                    end
                    
                    compile_expression(rest)
                    emit(OP.STORE, get_var_index(var_name))

                elseif stripped:match("^const%s+") then
                    local var_name, rest = stripped:match("^const%s+([%w%-_]+)%s*=%s*(.+)$")
                    if var_name then
                        -- Valida: kebab-case OU snake_case (não camelCase)
                        if var_name:match("[A-Z]") then
                            error("Erro: Use kebab-case ou snake_case! '" .. var_name .. "' contém maiúsculas.")
                        elseif var_name:match("_") then
                            -- Warning: snake_case detectado
                            print("[!] Aviso: Se quiser uma experiência melhor use kebab-case! (em vez de '" .. var_name .. "')")
                        end
                        
                        const_vars[var_name] = true
                        compile_expression(rest)
                        emit(OP.STORE, get_var_index(var_name))
                    else
                        error("Sintaxe inválida: const nome = valor")
                    end

                -- Reatribuição de variável
                elseif stripped:match("^[%w%-_]+%s*=%s*") and not stripped:match("^val%s+") and not stripped:match("^const%s+") then
                    local var_name, rest = stripped:match("^([%w%-_]+)%s*=%s*(.+)$")
                    if var_name then
                        if const_vars[var_name] then
                            error("Erro: Não é possível reatribuir variável const '" .. var_name .. "'")
                        end
                        compile_expression(rest)
                        emit(OP.STORE, get_var_index(var_name))
                    end

                -- Garbage Collector
                elseif stripped:match("^gc%.init%(%)") then
                    emit(OP.GC_INIT)
                    
                elseif stripped:match("^gc%.collect%(%)") then
                    emit(OP.GC_COLLECT)
                    
                elseif stripped:match("^gc%.stop%(%)") then
                    emit(OP.GC_STOP)

                -- Operações matemáticas antigas
                elseif stripped:match("^add%s+") then
                    local var1, var2 = stripped:match("^add%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
                    emit(OP.LOAD, get_var_index(var1))
                    emit(OP.LOAD, get_var_index(var2))
                    emit(OP.ADD)

                elseif stripped:match("^sub%s+") then
                    local var1, var2 = stripped:match("^sub%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
                    emit(OP.LOAD, get_var_index(var1))
                    emit(OP.LOAD, get_var_index(var2))
                    emit(OP.SUB)

                -- IF STATEMENT
                elseif stripped:match("^if%s+") then
                    local condition = stripped:match("^if%s+(.+):")
                    if not condition then
                        error("Sintaxe inválida: if condition:")
                    end
                    
                    compile_condition(condition)

                    local else_label = new_label()
                    local end_label = new_label()

                    emit_jump(OP.JUMP_IF_FALSE, else_label)

                    table.insert(block_stack, {
                        type = "if",
                        else_label = else_label,
                        end_label = end_label,
                        has_else = false,
                        indent = indent
                    })

                    -- Processa bloco if
                    process_block(indent + 4)

                    -- Verifica elif/else
                    while i <= #lines do
                        local next_line = lines[i]
                        local next_indent = get_indent(next_line)
                        local next_stripped = strip_indent(next_line)

                        if next_stripped == "" then
                            i = i + 1
                            goto continue_elif
                        end

                        if next_indent < indent then
                            break
                        end

                        if next_indent == indent then
                            if next_stripped:match("^elif%s+") then
                                i = i + 1
                                local block = block_stack[#block_stack]
                                
                                emit_jump(OP.JUMP, block.end_label)
                                mark_label(block.else_label)

                                local elif_condition = next_stripped:match("^elif%s+(.+):")
                                if not elif_condition then
                                    error("Sintaxe inválida: elif condition:")
                                end
                                
                                compile_condition(elif_condition)

                                block.else_label = new_label()
                                emit_jump(OP.JUMP_IF_FALSE, block.else_label)

                                process_block(indent + 4)
                            elseif next_stripped:match("^else:") then
                                i = i + 1
                                local block = block_stack[#block_stack]
                                
                                emit_jump(OP.JUMP, block.end_label)
                                mark_label(block.else_label)
                                block.has_else = true

                                process_block(indent + 4)
                                -- After processing else block, i should be pointing to the next line
                                -- If there are no more lines at this indent level, we should break
                                break
                            else
                                break
                            end
                        else
                            break
                        end

                        ::continue_elif::
                    end

                    -- Fecha bloco if
                    local block = table.remove(block_stack)
                    if not block.has_else then
                        mark_label(block.else_label)
                    end
                    mark_label(block.end_label)

                -- WHILE LOOP
                elseif stripped:match("^while%s+") then
                    local condition = stripped:match("^while%s+(.+):")
                    if not condition then
                        error("Sintaxe inválida: while condition:")
                    end

                    local start_label = new_label()
                    local end_label = new_label()

                    mark_label(start_label)
                    compile_condition(condition)
                    emit_jump(OP.JUMP_IF_FALSE, end_label)

                    table.insert(block_stack, {
                        type = "while",
                        start_label = start_label,
                        end_label = end_label,
                        indent = indent
                    })

                    process_block(indent + 4)

                    emit_jump(OP.JUMP, start_label)
                    mark_label(end_label)

                    table.remove(block_stack)

                -- FOR LOOP
                elseif stripped:match("^for%s+") then
                    if stripped:match("in%s+range%(") then
                        local var, max = stripped:match("^for%s+([%w_%-]+)%s+in%s+range%((%d+)%):")
                        if not var or not max then
                            error("Sintaxe inválida: for var in range(n):")
                        end

                        emit(OP.PUSH, 0)
                        emit(OP.STORE, get_var_index(var))

                        local start_label = new_label()
                        local end_label = new_label()

                        mark_label(start_label)

                        emit(OP.LOAD, get_var_index(var))
                        emit(OP.PUSH, tonumber(max))
                        emit(OP.LT)
                        emit_jump(OP.JUMP_IF_FALSE, end_label)

                        table.insert(block_stack, {
                            type = "for",
                            var = var,
                            start_label = start_label,
                            end_label = end_label,
                            indent = indent
                        })

                        process_block(indent + 4)

                        emit(OP.LOAD, get_var_index(var))
                        emit(OP.PUSH, 1)
                        emit(OP.ADD)
                        emit(OP.STORE, get_var_index(var))

                        emit_jump(OP.JUMP, start_label)
                        mark_label(end_label)

                        table.remove(block_stack)
                    
                    elseif stripped:match("in%s+[%w_%-]+:") then
                        local var, array_var = stripped:match("^for%s+([%w_%-]+)%s+in%s+([%w_%-]+):")
                        if not var or not array_var then
                            error("Sintaxe inválida: for item in array:")
                        end
                        
                        local index_var = "__index_" .. var
                        
                        emit(OP.PUSH, 1)
                        emit(OP.STORE, get_var_index(index_var))
                        
                        local start_label = new_label()
                        local end_label = new_label()
                        
                        mark_label(start_label)
                        
                        emit(OP.LOAD, get_var_index(index_var))
                        emit(OP.LOAD, get_var_index(array_var))
                        emit(OP.ARRAY_LEN)
                        emit(OP.LE)
                        emit_jump(OP.JUMP_IF_FALSE, end_label)
                        
                        emit(OP.LOAD, get_var_index(array_var))
                        emit(OP.LOAD, get_var_index(index_var))
                        emit(OP.ARRAY_GET)
                        emit(OP.STORE, get_var_index(var))
                        
                        table.insert(block_stack, {
                            type = "for-in",
                            var = var,
                            index_var = index_var,
                            start_label = start_label,
                            end_label = end_label,
                            indent = indent
                        })

                        process_block(indent + 4)

                        emit(OP.LOAD, get_var_index(index_var))
                        emit(OP.PUSH, 1)
                        emit(OP.ADD)
                        emit(OP.STORE, get_var_index(index_var))

                        emit_jump(OP.JUMP, start_label)
                        mark_label(end_label)

                        table.remove(block_stack)
                    else
                        error("Sintaxe inválida: for statement")
                    end
                end

            elseif indent > start_indent then
                -- Indentação maior que esperado - pode ser continuação de linha ou erro
                -- Por enquanto, ignoramos (pode ser tratado como erro em versões futuras)
                i = i + 1
            end

            ::continue::
        end
    end

    -- Processa o programa principal
    process_block(0)

    if #block_stack > 0 then
        error("Bloco não fechado")
    end

    if not in_function then
        error("Função 'main' não encontrada")
    end

    emit(OP.HALT)
    patch_jumps()
end

-- Função auxiliar para validar indentação
local function validate_indentation(lines)
    for idx, line in ipairs(lines) do
        local stripped = strip_indent(line)
        if stripped ~= "" and not stripped:match("^//") then
            -- Linha não vazia e não é comentário
            local indent = get_indent(line)
            if indent % 4 ~= 0 then
                -- Aviso: indentação não é múltiplo de 4
                -- Mas não é erro fatal
            end
        end
    end
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
    -- Print stack trace for debugging
    if err:match("Expressão vazia") then
        print("DEBUG: Empty expression error - check the last statement before this error")
    end
    os.exit(1)
end

local out = io.open(output_file, "wb")
if not out then
    print("!! Erro: Não foi possível criar arquivo de saída!")
    os.exit(1)
end
for _, v in ipairs(bytecode) do
    out:write(string.pack("i4", math.floor(tonumber(v) or 0)))
end
out:close()

print("[+] Sucesso! '" .. output_file .. "' gerado.")
print("[*] Variáveis: " .. var_count)
