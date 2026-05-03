-- ============================================
-- transpiler.lua - Transpilador Tea → Lua
-- ============================================
-- Converte código Tea para código Lua equivalente

local input_file = arg[1] or "main.tea"
local output_file = arg[2] or (input_file:gsub("%.tea$", ".lua"))

-- Estado do transpilador
local lua_code = {}
local indent_level = 0
local variables = {}

-- Adiciona linha de código Lua
local function emit(line)
    local indent = string.rep("    ", indent_level)
    table.insert(lua_code, indent .. line)
end

-- Remove comentários
local function remove_comments(source)
    source = source:gsub("//[^\n]*", "")
    source = source:gsub("\\.-\\", "")
    return source
end

-- Transpila o código Tea para Lua
local function transpile(source)
    source = remove_comments(source)
    
    -- Cabeçalho do arquivo Lua
    emit("-- Código gerado automaticamente pelo Tea")
    emit("-- Não edite este arquivo diretamente!")
    emit("")
    
    local in_function = false
    
    for line in source:gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")  -- Trim
        
        if line == "" then
            emit("")
            
        elseif line:match("^fun%s+") then
            -- fun main(): → function main()
            local func_name = line:match("^fun%s+([%w%-_]+)")
            emit("function " .. func_name .. "()")
            indent_level = indent_level + 1
            in_function = true
            
        elseif line:match("^endfun") then
            -- endfun → end
            indent_level = indent_level - 1
            emit("end")
            emit("")
            
        elseif line:match("^print%(") then
            -- print("texto") → print("texto")
            -- print(variavel) → print(variavel)
            local content = line:match("print%((.+)%)")
            emit("print(" .. content .. ")")
            
        elseif line:match("^val%s+") then
            -- val nome = valor → local nome = valor
            local var_name, rest = line:match("^val%s+([%w%-_]+)%s*=%s*(.+)$")
            
            -- Converte hífens em underscores (Lua não aceita hífens em nomes)
            local lua_var = var_name:gsub("%-", "_")
            variables[var_name] = lua_var
            
            if rest:match("^input%(") then
                -- val x = input("prompt") → local x = io.read()
                local prompt = rest:match('input%("(.-)"%)') or ""
                if prompt ~= "" then
                    emit('io.write("' .. prompt .. '")')
                end
                emit("local " .. lua_var .. " = io.read()")
            else
                -- val x = valor → local x = valor
                emit("local " .. lua_var .. " = " .. rest)
            end
            
        elseif line:match("^add%s+") then
            -- add var1, var2 → print(var1 + var2)
            local var1, var2 = line:match("^add%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            local lua_var1 = variables[var1] or var1:gsub("%-", "_")
            local lua_var2 = variables[var2] or var2:gsub("%-", "_")
            emit("print(" .. lua_var1 .. " + " .. lua_var2 .. ")")
            
        elseif line:match("^sub%s+") then
            -- sub var1, var2 → print(var1 - var2)
            local var1, var2 = line:match("^sub%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            local lua_var1 = variables[var1] or var1:gsub("%-", "_")
            local lua_var2 = variables[var2] or var2:gsub("%-", "_")
            emit("print(" .. lua_var1 .. " - " .. lua_var2 .. ")")
            
        elseif line:match("^mult%s+") then
            -- mult var1, var2 → print(var1 * var2)
            local var1, var2 = line:match("^mult%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            local lua_var1 = variables[var1] or var1:gsub("%-", "_")
            local lua_var2 = variables[var2] or var2:gsub("%-", "_")
            emit("print(" .. lua_var1 .. " * " .. lua_var2 .. ")")
            
        elseif line:match("^div%s+") then
            -- div var1, var2 → print(var1 / var2)
            local var1, var2 = line:match("^div%s+([%w%-_]+)%s*,%s*([%w%-_]+)")
            local lua_var1 = variables[var1] or var1:gsub("%-", "_")
            local lua_var2 = variables[var2] or var2:gsub("%-", "_")
            emit("print(" .. lua_var1 .. " / " .. lua_var2 .. ")")
            
        elseif line:match("^if%s+") then
            -- if condição: → if condição then
            local condition = line:match("^if%s+(.+):")
            -- Converte operadores Tea para Lua
            condition = condition:gsub("n=", "~=")  -- n= → ~=
            -- Converte nomes de variáveis
            for tea_var, lua_var in pairs(variables) do
                condition = condition:gsub(tea_var, lua_var)
            end
            emit("if " .. condition .. " then")
            indent_level = indent_level + 1
            
        elseif line:match("^elif%s+") then
            -- elif condição: → elseif condição then
            indent_level = indent_level - 1
            local condition = line:match("^elif%s+(.+):")
            condition = condition:gsub("n=", "~=")
            for tea_var, lua_var in pairs(variables) do
                condition = condition:gsub(tea_var, lua_var)
            end
            emit("elseif " .. condition .. " then")
            indent_level = indent_level + 1
            
        elseif line:match("^else:") then
            -- else: → else
            indent_level = indent_level - 1
            emit("else")
            indent_level = indent_level + 1
            
        elseif line:match("^endif") then
            -- endif → end
            indent_level = indent_level - 1
            emit("end")
        end
    end
    
    -- Fecha a função se ainda estiver aberta
    if in_function and indent_level > 0 then
        indent_level = indent_level - 1
        emit("end")
    end
    
    -- Chama a função main no final
    emit("")
    emit("-- Executa o programa")
    emit("main()")
end

-- Execução
local f = io.open(input_file, "r")
if not f then
    print("!! Erro: Arquivo não encontrado!")
    os.exit(1)
end
local source = f:read("*all")
f:close()

print("[*] Transpilando: " .. input_file .. " → " .. output_file)

local success, err = pcall(transpile, source)
if not success then
    print("!! " .. err)
    os.exit(1)
end

-- Salva o código Lua
local out = io.open(output_file, "w")
out:write(table.concat(lua_code, "\n"))
out:close()

print("[+] Sucesso! Arquivo Lua gerado: " .. output_file)
