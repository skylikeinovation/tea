-- ============================================
-- lib-cmd.lua - Biblioteca de comandos Tea
-- ============================================
-- Funções utilitárias para linha de comando

return {
    -- Executa comando do sistema
    exe = function(command)
        local result = os.execute(command)
        return result
    end,
    
    -- Executa comando e captura output
    exec = function(command)
        local handle = io.popen(command)
        local result = handle:read("*a")
        handle:close()
        return result
    end,
    
    -- Limpa a tela
    clear = function()
        os.execute("clear || cls")
    end,
    
    -- Pausa e espera Enter
    pause = function(msg)
        io.write(msg or "Pressione Enter para continuar...")
        io.read()
    end,
    
    -- Pega input do usuário
    input = function(prompt)
        io.write(prompt or "")
        return io.read()
    end,
    
    -- Pega input numérico
    input_number = function(prompt)
        io.write(prompt or "")
        local value = io.read()
        return tonumber(value)
    end,
    
    -- Valida se é número
    is_number = function(value)
        return tonumber(value) ~= nil
    end,
    
    -- Menu simples
    menu = function(title, options)
        print(title)
        print(string.rep("=", #title))
        print("")
        for i, opt in ipairs(options) do
            print(i .. " - " .. opt)
        end
        print("")
    end,
    
    -- Cores ANSI (Linux/Mac)
    colors = {
        reset = "\27[0m",
        red = "\27[31m",
        green = "\27[32m",
        yellow = "\27[33m",
        blue = "\27[34m",
        magenta = "\27[35m",
        cyan = "\27[36m",
        white = "\27[37m",
    },
    
    -- Print colorido
    print_color = function(text, color)
        local colors = {
            reset = "\27[0m",
            red = "\27[31m",
            green = "\27[32m",
            yellow = "\27[33m",
            blue = "\27[34m",
            magenta = "\27[35m",
            cyan = "\27[36m",
            white = "\27[37m",
        }
        print((colors[color] or "") .. text .. colors.reset)
    end,
    
    -- Mensagens de sucesso/erro
    success = function(msg)
        print("\27[32m✓ " .. msg .. "\27[0m")
    end,
    
    error = function(msg)
        print("\27[31m✗ " .. msg .. "\27[0m")
    end,
    
    warning = function(msg)
        print("\27[33m⚠ " .. msg .. "\27[0m")
    end,
    
    info = function(msg)
        print("\27[34mℹ " .. msg .. "\27[0m")
    end,
}
