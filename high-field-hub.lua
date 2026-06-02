-- ========================================================
-- SCRIPT: BLOX FRUITS - DAMAGE AURA UNIVERSAL (NO CLICK)
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "High Field Hub | Blox Fruits",
   LoadingTitle = "Iniciando Sistema de Dano...",
   LoadingSubtitle = "by Developer",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("Combate", 4483362458)

-- Variáveis de controle
local DanoSobreHumanoAtivo = false
local DistanciaMaxima = 25 -- Limitado para segurança contra o Anti-Cheat (evitar ban automático)

-- Função para verificar se o item na mão NÃO é uma fruta
local function obterItemValido(character)
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    
    local toolName = tool.Name:lower()
    -- Se for fruta, ignora
    if toolName:find("fruit") or toolName:find("fruta") then
        return nil
    end
    
    return tool -- Retorna o estilo de luta, espada ou arma equipado
end

-- Função para achar o inimigo (Mob ou Player) mais próximo dentro do alcance seguro
local function obterInimigoProximo()
    local Player = game:GetService("Players").LocalPlayer
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local menorDistancia = DistanciaMaxima
    local alvoMaisProximo = nil
    
    -- Varre os inimigos no mapa (geralmente ficam na pasta de NPCs ou no Workspace)
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and npc.Humanoid.Health > 0 then
            if npc ~= character then
                local distancia = (character.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distancia < menorDistancia then
                    menorDistancia = distancia
                    alvoMaisProximo = npc
                end
            end
        end
    end
    return alvoMaisProximo
end

-- Loop de Dano Direto (Sem cliques, sem animação)
task.spawn(function()
    local Player = game:GetService("Players").LocalPlayer
    
    -- Localiza o Remote oficial de ataque do Blox Fruits (geralmente fica no ReplicatedStorage)
    local CombatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RigControllerEvent") or game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    
    while true do
        task.wait(0.1) -- Delay seguro para o servidor registrar o dano sem te dar Kick
        
        if DanoSobreHumanoAtivo and Player.Character then
            local itemEquipado = obterItemValido(Player.Character)
            
            -- Só funciona se tiver com o estilo/espada/arma na mão
            if itemEquipado then
                local inimigo = obterInimigoProximo()
                
                if inimigo then
                    -- Aqui o script simula o dano direto enviando o pacote ao servidor
                    -- Passando o item usado e o alvo que vai tomar o dano sobre-humano
                    if CombatRemote then
                        -- Exemplo do disparo de Remote padrão usado em combat/farm
                        CombatRemote:FireServer("Attack", inimigo.HumanoidRootPart)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- INTERFACE RAYFIELD
-- ==========================================

local Section = CombatTab:CreateSection("Aura de Dano")

local Toggle = CombatTab:CreateToggle({
   Name = "Dano Sobre-Humano Automático (Ao Equipar)",
   CurrentValue = false,
   Flag = "DanoSobreHumanoFlag", 
   Callback = function(Value)
      DanoSobreHumanoAtivo = Value
      
      if DanoSobreHumanoAtivo then
          Rayfield:Notify({
             Title = "High Field",
             Content = "Aura de Dano ATIVADA! Segure o item para derreter os alvos.",
             Duration = 3,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Title = "High Field",
             Content = "Aura de Dano DESATIVADA.",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})
