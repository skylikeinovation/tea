-- ============================================
-- vm.lua - A Máquina Virtual Tea
-- ============================================
-- Este arquivo executa o bytecode gerado pelo compilador
-- A VM é uma "máquina de pilha" (stack machine)

-- Pega o nome do arquivo bytecode (ou usa "main.teac" como padrão)
local bytecode_file = arg[1] or "main.teac"

-- ============================================
-- TABELA DE OPCODES
-- ============================================
-- Mesma tabela do compilador - cada número representa uma operação
local OP = {
    PUSH = 1,      -- Empilha um número
    ADD = 2,       -- Soma
    SUB = 3,       -- Subtração
    PRINT = 4,     -- Imprime
    HALT = 5,      -- Para
    MULT = 6,      -- Multiplicação
    DIV = 7,       -- Divisão
    STORE = 8,     -- Armazena em variável
    LOAD = 9,      -- Carrega de variável
    INPUT = 10,    -- Lê input do usuário
    CALL = 11,     -- Chama função (não usado ainda)
    RETURN = 12,   -- Retorna de função (não usado ainda)
    JUMP = 13,     -- Pula para endereço (não usado ainda)
    PUSH_STR = 14, -- Empilha string
    -- Operadores de comparação
    EQ = 15,       -- Igual (==)
    NE = 16,       -- Diferente (n=)
    LT = 17,       -- Menor que (<)
    GT = 18,       -- Maior que (>)
    LE = 19,       -- Menor ou igual (<=)
    GE = 20,       -- Maior ou igual (>=)
    -- Controle de fluxo
    JUMP = 21,     -- Pula para endereço
    JUMP_IF_FALSE = 22,  -- Pula se o topo da stack for falso (0)
    TO_NUMBER = 23 -- Converte string para número
}

-- ============================================
-- ESTADO DA VM
-- ============================================
local stack = {}       -- A pilha (stack) - onde os valores ficam temporariamente
local sp = 0           -- Stack Pointer - aponta para o topo da pilha
local variables = {}   -- Array de variáveis (índice -> valor)
local call_stack = {}  -- Pilha de chamadas de função (não usado ainda)
local call_sp = 0      -- Ponteiro da call stack

-- ============================================
-- FUNÇÕES DA PILHA (STACK)
-- ============================================

-- Empilha um valor (adiciona no topo)
-- Exemplo: push(5) -> stack = [5]
--          push(3) -> stack = [5, 3]
local function push(value)
    sp = sp + 1
    stack[sp] = value
end

-- Desempilha um valor (remove do topo)
-- Exemplo: stack = [5, 3]
--          pop() -> retorna 3, stack = [5]
local function pop()
    if sp < 1 then
        error("!! Erro: Stack Underflow (tentou desempilhar de pilha vazia)")
    end
    local value = stack[sp]
    stack[sp] = nil
    sp = sp - 1
    return value
end

-- ============================================
-- CARREGADOR DE BYTECODE
-- ============================================
-- Lê o arquivo .teac e transforma em array de números
local function load_bytecode(filename)
    local f = io.open(filename, "rb")
    if not f then
        error("!! Erro: Arquivo '" .. filename .. "' não encontrado")
    end
    
    local bytecode = {}
    -- Lê o arquivo em blocos de 4 bytes (cada número é um inteiro de 32 bits)
    while true do
        local bytes = f:read(4)
        if not bytes then break end
        -- Desempacota os 4 bytes em um número inteiro
        local value = string.unpack("i4", bytes)
        table.insert(bytecode, value)
    end
    f:close()
    
    return bytecode
end

-- ============================================
-- EXECUTOR - O Coração da VM
-- ============================================
-- Processa cada instrução do bytecode
local function execute(bytecode)
    local ip = 1  -- Instruction Pointer - posição atual no bytecode
    
    -- Loop principal: executa instrução por instrução
    while ip <= #bytecode do
        local opcode = bytecode[ip]
        ip = ip + 1
        
        -- ========================================
        -- PUSH - Empilha um número
        -- ========================================
        if opcode == OP.PUSH then
            local value = bytecode[ip]
            ip = ip + 1
            push(value)
            
        -- ========================================
        -- PUSH_STR - Empilha uma string
        -- ========================================
        elseif opcode == OP.PUSH_STR then
            local len = bytecode[ip]  -- Tamanho da string
            ip = ip + 1
            local str = ""
            -- Reconstrói a string byte por byte
            for i = 1, len do
                str = str .. string.char(bytecode[ip])
                ip = ip + 1
            end
            push(str)
            
        -- ========================================
        -- ADD - Soma os dois valores do topo
        -- ========================================
        elseif opcode == OP.ADD then
            local b = pop()  -- Segundo operando
            local a = pop()  -- Primeiro operando
            push(a + b)      -- Empilha o resultado
            
        -- ========================================
        -- SUB - Subtração (a - b)
        -- ========================================
        elseif opcode == OP.SUB then
            local b = pop()
            local a = pop()
            push(a - b)
            
        -- ========================================
        -- MULT - Multiplicação
        -- ========================================
        elseif opcode == OP.MULT then
            local b = pop()
            local a = pop()
            push(a * b)
            
        -- ========================================
        -- DIV - Divisão (a / b)
        -- ========================================
        elseif opcode == OP.DIV then
            local b = pop()
            local a = pop()
            if b == 0 then
                error("!! Erro: Divisão por zero")
            end
            push(a / b)
            
        -- ========================================
        -- STORE - Armazena valor em variável
        -- ========================================
        elseif opcode == OP.STORE then
            local var_idx = bytecode[ip]  -- Índice da variável
            ip = ip + 1
            local value = pop()           -- Valor a armazenar
            variables[var_idx] = value    -- Salva na tabela de variáveis
            
        -- ========================================
        -- LOAD - Carrega valor de variável
        -- ========================================
        elseif opcode == OP.LOAD then
            local var_idx = bytecode[ip]
            ip = ip + 1
            local value = variables[var_idx]
            if value == nil then
                error("!! Erro: Variável não inicializada (índice " .. var_idx .. ")")
            end
            push(value)  -- Empilha o valor da variável
            
        -- ========================================
        -- INPUT - Lê input do usuário
        -- ========================================
        elseif opcode == OP.INPUT then
            local prompt = pop()  -- Pega o prompt da pilha
            io.write(prompt)      -- Mostra o prompt
            local input = io.read()  -- Lê a entrada do usuário
            push(input)           -- Empilha o input
            
        -- ========================================
        -- PRINT - Imprime o valor do topo
        -- ========================================
        elseif opcode == OP.PRINT then
            local value = pop()
            print(value)
            
        -- ========================================
        -- CALL - Chama uma função (não implementado ainda)
        -- ========================================
        elseif opcode == OP.CALL then
            local addr = bytecode[ip]
            ip = ip + 1
            -- Salva endereço de retorno na call stack
            call_sp = call_sp + 1
            call_stack[call_sp] = ip
            ip = addr  -- Pula para o endereço da função
            
        -- ========================================
        -- RETURN - Retorna de uma função (não implementado ainda)
        -- ========================================
        elseif opcode == OP.RETURN then
            if call_sp < 1 then
                error("!! Erro: RETURN sem CALL correspondente")
            end
            ip = call_stack[call_sp]  -- Volta para onde estava
            call_stack[call_sp] = nil
            call_sp = call_sp - 1
            
        -- ========================================
        -- OPERADORES DE COMPARAÇÃO
        -- ========================================
        elseif opcode == OP.EQ then
            -- Igual (==)
            local b = pop()
            local a = pop()
            push(a == b and 1 or 0)  -- 1 = true, 0 = false
            
        elseif opcode == OP.NE then
            -- Diferente (n=)
            local b = pop()
            local a = pop()
            push(a ~= b and 1 or 0)
            
        elseif opcode == OP.LT then
            -- Menor que (<)
            local b = pop()
            local a = pop()
            push(a < b and 1 or 0)
            
        elseif opcode == OP.GT then
            -- Maior que (>)
            local b = pop()
            local a = pop()
            push(a > b and 1 or 0)
            
        elseif opcode == OP.LE then
            -- Menor ou igual (<=)
            local b = pop()
            local a = pop()
            push(a <= b and 1 or 0)
            
        elseif opcode == OP.GE then
            -- Maior ou igual (>=)
            local b = pop()
            local a = pop()
            push(a >= b and 1 or 0)
            
        -- ========================================
        -- CONTROLE DE FLUXO
        -- ========================================
        elseif opcode == OP.JUMP then
            -- Pula incondicionalmente para um endereço
            local addr = bytecode[ip]
            ip = addr
            
        elseif opcode == OP.JUMP_IF_FALSE then
            -- Pula se o topo da stack for falso (0)
            local addr = bytecode[ip]
            ip = ip + 1
            local condition = pop()
            if condition == 0 then
                ip = addr  -- Pula
            end
            -- Se não, continua normalmente
            
        -- ========================================
        -- TO_NUMBER - Converte string para número
        -- ========================================
        elseif opcode == OP.TO_NUMBER then
            local value = pop()
            local num = tonumber(value)
            if not num then
                error("!! Erro: Não foi possível converter '" .. tostring(value) .. "' para número")
            end
            push(num)
            
        -- ========================================
        -- HALT - Para a execução
        -- ========================================
        elseif opcode == OP.HALT then
            break  -- Sai do loop principal
            
        -- ========================================
        -- Opcode desconhecido - erro!
        -- ========================================
        else
            error("!! Erro: Opcode desconhecido: " .. opcode)
        end
    end
end

-- ============================================
-- FLUXO DE EXECUÇÃO DA VM
-- ============================================

-- Carrega o bytecode do arquivo
local success, bytecode = pcall(load_bytecode, bytecode_file)

if not success then
    print(bytecode)  -- Imprime a mensagem de erro
    os.exit(1)
end

-- Executa o bytecode (protegido contra erros)
success, err = pcall(execute, bytecode)

if not success then
    print(err)  -- Imprime a mensagem de erro
    os.exit(1)
end
