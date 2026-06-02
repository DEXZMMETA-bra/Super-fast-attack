-- Variáveis de controle para o sistema de Árvores (getgenv)
getgenv().AutoChop = false
getgenv().LimiteArvores = 150 -- Média entre 100 e 200 árvores

-- Função para identificar o nível do Machado na mão
local function obterNivelMachado(character)
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return "Nenhum" end
    
    local name = tool.Name:lower()
    if name:find("chainsaw") or name:find("motosserra") then
        return "Maximo"
    elseif name:find("strong") or name:find("forte") or name:find("iron") then
        return "Forte"
    elseif name:find("good") or name:find("bom") or name:find("steel") then
        return "Bom"
    elseif name:find("old") or name:find("velho") or name:find("stone") then
        return "Velho"
    end
    return "Nenhum"
end

-- Thread do Auto Cortar Árvores Inteligente
task.spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    -- Localiza o Remote que o jogo usa para registrar a machadada
    local ChopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ChopRemote") or game:GetService("ReplicatedStorage"):FindFirstChild("TreeEvent")

    while task.wait(0.1) do -- Velocidade de varredura
        if getgenv().AutoChop and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local machado = obterNivelMachado(Player.Character)
            
            if machado ~= "Nenhum" then
                local contadorArvores = 0
                
                -- Procura as árvores no Workspace (geralmente ficam em uma pasta ou direto no Workspace)
                for _, objeto in pairs(workspace:GetChildren()) do
                    if contadorArvores >= getgenv().LimiteArvores then break end -- Trava o grupo entre 100 e 200
                    
                    -- Verifica se o objeto é uma árvore viva
                    if objeto:FindFirstChild("Humanoid") or objeto.Name:lower():find("tree") then
                        local nomeArvore = objeto.Name
                        local distancia = (Player.Character.HumanoidRootPart.Position - (objeto:FindFirstChild("HumanoidRootPart") or objeto:FindFirstChildOfClass("BasePart")).Position).Magnitude
                        
                        -- Raio de alcance do farm
                        if distancia < 150 then 
                            local podeQuebrar = false
                            
                            -- LÓGICA INTELIGENTE DE VERIFICAÇÃO:
                            if nomeArvore == "SmallTree" or nomeArvore:lower():find("small") then
                                -- Árvore pequena quebra com qualquer um, respeitando a velocidade do machado
                                podeQuebrar = true
                                if machado == "Forte" or machado == "Maximo" then
                                    task.wait(0.01) -- Quebra instantâneo (1 Hit)
                                else
                                    task.wait(0.2) -- Velocidade normal para machado velho
                                end
                            elseif nomeArvore == "BigTree" or nomeArvore:lower():find("big") or nomeArvore:lower():find("large") then
                                -- Árvore grande SÓ quebra se for Machado Forte ou Motosserra
                                if machado == "Forte" or machado == "Maximo" then
                                    podeQuebrar = true
                                    task.wait(0.01) -- Força o Insta-Kill de 1 Hit na árvore grande
                                end
                            end
                            
                            -- Se passou no teste do machado, envia o dano direto para a árvore
                            if podeQuebrar and ChopRemote then
                                ChopRemote:FireServer("Chop", objeto)
                                contadorArvores = contadorArvores + 1
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ========================================================================
-- ELEMENTO PARA ADICIONAR NA SUA ABA DE ITENS (RAYFIELD)
-- ========================================================================

-- Você vai colar isso dentro da sua "ItemTab" no script principal:

ItemTab:CreateSection("Auto Farm de Madeira Inteligente")

ItemTab:CreateSlider({
   Name = "Quantidade de Árvores por Grupo",
   Range = {50, 200},
   Increment = 10,
   Suffix = " Árvores",
   CurrentValue = 150,
   Flag = "LimiteArvoresFlag",
   Callback = function(Value)
      getgenv().LimiteArvores = Value
   end,
})

ItemTab:CreateToggle({
   Name = "Auto Cortar Árvores (Aura Inteligente)",
   CurrentValue = false,
   Flag = "AutoChopFlag",
   Callback = function(Value)
      getgenv().AutoChop = Value
      if Value then
          Rayfield:Notify({
             Title = "High Field Hub",
             Content = "Auto Cortar Ativado! Segure um Machado compatível.",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})
