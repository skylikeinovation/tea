-- ============================================
-- tea.lua - Compilador Tea (v0.2.0)
-- ============================================

local input_file = arg[1] or "main.tea"
local output_file = input_file .. "c"

-- ============================================
-- OPCODES
-- ============================================
local OP = {
    PUSH = 1, ADD = 2, SUB = 3, PRINT = 4, HALT = 5,
    MULT = 6, DIV = 7, STORE = 8, LOAD = 9, INPUT = 10,
    PUSH_STR = 14, EQ = 15, NE = 16, LT = 17, GT = 18,
    LE = 19, GE = 20, JUMP = 21, JUMP_IF_FALSE = 22,
    TO_NUMBER = 23  -- Converte string para número
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

-- Compila uma condição
local function compile_condition(condition)
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
        error("Operador inválido: " .. condition)
    end
    
    -- Carrega operandos
    local num1 = tonumber(var1)
    if num1 then
        emit(OP.PUSH, num1)
    else
        emit(OP.LOAD, get_var_index(var1))
    end
    
    local num2 = tonumber(var2)
    if num2 then
        emit(OP.PUSH, num2)
    else
        emit(OP.LOAD, get_var_index(var2))
    end
    
    emit(op)
end

-- ============================================
-- PARSER
-- ============================================

local function parse(source)
    source = remove_comments(source)
    
    local lines = {}
    for line in source:gmatch("[^\n]+") do
        table.insert(lines, line:match("^%s*(.-)%s*$"))
    end
    
    local if_stack = {}
    local in_function = false
    
    for _, line in ipairs(lines) do
        if line == "" then
            -- Ignora linha vazia
            
        elseif line:match("^fun%s+") then
            in_function = true
            
        elseif line:match("^print%(") then
            local content = line:match("print%((.+)%)")
            
            if content:match('^".*"$') then
                local str = content:match('^"(.*)"$')
                emit(OP.PUSH_STR, #str)
                for i = 1, #str do
                    emit(string.byte(str, i))
                end
            else
                emit(OP.LOAD, get_var_index(content))
            end
            emit(OP.PRINT)
            
        elseif line:match("^val%s+") then
            local var_name, rest = line:match("^val%s+([%w%-_]+)%s*=%s*(.+)$")
            
            -- Verifica se é int(input(...))
            if rest:match("^int%(input%(") then
                local prompt = rest:match('int%(input%("(.-)"%)%)') or ""
                emit(OP.PUSH_STR, #prompt)
                for i = 1, #prompt do
                    emit(string.byte(prompt, i))
                end
                emit(OP.INPUT)
                emit(OP.TO_NUMBER)  -- Converte para número
            elseif rest:match("^input%(") then
                local prompt = rest:match('input%("(.-)"%)') or ""
                emit(OP.PUSH_STR, #prompt)
                for i = 1, #prompt do
                    emit(string.byte(prompt, i))
                end
                emit(OP.INPUT)
            elseif rest:match('^".*"$') then
                local str = rest:match('^"(.*)"$')
                emit(OP.PUSH_STR, #str)
                for i = 1, #str do
                    emit(string.byte(str, i))
                end
            else
                local num = tonumber(rest)
                if num then
                    emit(OP.PUSH, num)
                else
                    error("Valor inválido: " .. rest)
                end
            end
            
            emit(OP.STORE, get_var_index(var_name))
            
        elseif line:match("^val_num%s+") then
            -- val_num converte input para número
            local var_name, rest = line:match("^val_num%s+([%w%-_]+)%s*=%s*(.+)$")
            
            if rest:match("^input%(") then
                local prompt = rest:match('input%("(.-)"%)') or ""
                emit(OP.PUSH_STR, #prompt)
                for i = 1, #prompt do
                    emit(string.byte(prompt, i))
                end
                emit(OP.INPUT)
                -- Marca para conversão na VM (adicionar opcode TO_NUMBER depois)
            end
            
            emit(OP.STORE, get_var_index(var_name))
            
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
            
        elseif line:match("^mult%s+") then
            local var1, var2 = line:match("^mult%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            emit(OP.LOAD, get_var_index(var1))
            emit(OP.LOAD, get_var_index(var2))
            emit(OP.MULT)
            
        elseif line:match("^div%s+") then
            local var1, var2 = line:match("^div%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            emit(OP.LOAD, get_var_index(var1))
            emit(OP.LOAD, get_var_index(var2))
            emit(OP.DIV)
            
        -- CONDICIONAIS
        elseif line:match("^if%s+") then
            local condition = line:match("^if%s+(.+):")
            compile_condition(condition)
            
            local else_label = new_label()
            local end_label = new_label()
            
            emit_jump(OP.JUMP_IF_FALSE, else_label)
            
            table.insert(if_stack, {
                else_label = else_label,
                end_label = end_label,
                has_else = false
            })
            
        elseif line:match("^elif%s+") then
            if #if_stack == 0 then error("elif sem if") end
            
            local condition = line:match("^elif%s+(.+):")
            local block = if_stack[#if_stack]
            
            emit_jump(OP.JUMP, block.end_label)
            mark_label(block.else_label)
            
            compile_condition(condition)
            
            block.else_label = new_label()
            emit_jump(OP.JUMP_IF_FALSE, block.else_label)
            
        elseif line:match("^else:") then
            if #if_stack == 0 then error("else sem if") end
            
            local block = if_stack[#if_stack]
            emit_jump(OP.JUMP, block.end_label)
            mark_label(block.else_label)
            block.has_else = true
            
        elseif line:match("^endif") then
            if #if_stack == 0 then error("endif sem if") end
            
            local block = table.remove(if_stack)
            
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
            
            table.insert(if_stack, {
                type = "while",
                start_label = start_label,
                end_label = end_label
            })
            
        elseif line:match("^endwhile") then
            if #if_stack == 0 then error("endwhile sem while") end
            
            local block = table.remove(if_stack)
            if block.type ~= "while" then error("endwhile sem while") end
            
            emit_jump(OP.JUMP, block.start_label)
            mark_label(block.end_label)
        end
    end
    
    if #if_stack > 0 then
        error("if sem endif")
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
for _, v in ipairs(bytecode) do
    out:write(string.pack("i4", v))
end
out:close()

print("[+] Sucesso! '" .. output_file .. "' gerado.")
print("[*] Variáveis: " .. var_count)
