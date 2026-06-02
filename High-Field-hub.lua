-- ========================================================
-- SCRIPT: BLOX FRUITS - SUPER FAST ATTACK UNIVERSAL
-- ========================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "High Field Hub | Blox Fruits",
   LoadingTitle = "Iniciando Super Fast Attack...",
   LoadingSubtitle = "by Developer",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local CombatTab = Window:CreateTab("Combate", 4483362458)

-- Variável de controle
local SuperFastAttackAtivo = false

-- Função para verificar se o item na mão NÃO é uma fruta
local function podeAplicarNoAnim(character)
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return false end
    
    -- Blox Fruits categoriza ou nomeia frutas de forma específica.
    -- Vamos filtrar para ignorar se o item for uma Fruta (Blox Fruit)
    local toolName = tool.Name:lower()
    if toolName:find("fruit") or toolName:find("fruta") then
        return false -- É fruta, então NÃO tira a animação
    end
    
    return true -- É estilo de luta, espada ou arma, então PODE aplicar o Fast Attack
end

-- Monitor universal de animações
local function IniciarFastAttackUniversal()
    local Player = game:GetService("Players").LocalPlayer
    
    local function MonitorarAnimacoes(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        local animator = humanoid and humanoid:WaitForChild("Animator", 5)
        
        if animator then
            animator.AnimationPlayed:Connect(function(track)
                -- Só corta a animação se o toggle estiver ativo E não for uma fruta na mão
                if SuperFastAttackAtivo and podeAplicarNoAnim(character) then
                    local animId = track.Animation and track.Animation.AnimationId
                    
                    -- Filtro universal: corta qualquer animação de uso, ataque, corte ou tiro
                    if animId and (animId:find("attack") or animId:find("slash") or animId:find("shoot") or animId:find("combat") or animId:find("dual") or animId:find("use")) then
                        track:Stop() -- Zera a animação na hora
                    end
                    track:AdjustSpeed(9999) -- Deixa o tempo de resposta instantâneo
                end
            end)
        end
    end

    if Player.Character then MonitorarAnimacoes(Player.Character) end
    Player.CharacterAdded:Connect(MonitorarAnimacoes)
end

task.spawn(IniciarFastAttackUniversal)

-- Loop do Auto-Click "Sobre-Humano" na velocidade da luz
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Player = game:GetService("Players").LocalPlayer
    
    while true do
        task.wait() -- Roda no limite máximo do motor do jogo
        if SuperFastAttackAtivo and Player.Character and podeAplicarNoAnim(Player.Character) then
            -- Dispara o clique ultra-rápido para triturar os mobs/players
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

-- ==========================================
-- INTERFACE RAYFIELD
-- ==========================================

local Section = CombatTab:CreateSection("Fast Attack Settings")

local Toggle = CombatTab:CreateToggle({
   Name = "Super Fast Attack Universal (Menos Frutas)",
   CurrentValue = false,
   Flag = "SuperFastAttackFlag", 
   Callback = function(Value)
      SuperFastAttackAtivo = Value
      
      if SuperFastAttackAtivo then
          Rayfield:Notify({
             Title = "High Field",
             Content = "Super Fast Attack ATIVADO para Estilos, Espadas e Armas!",
             Duration = 3,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Title = "High Field",
             Content = "Fast Attack DESATIVADO.",
             Duration = 3,
             Image = 4483362458,
          })
      end
   end,
})
