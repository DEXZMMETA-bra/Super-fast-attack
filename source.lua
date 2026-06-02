-- ========================================================================
-- HIGH FIELD HUB - 99 NOITES (CÓDIGO FONTE OFICIAL)
-- ========================================================================

if getgenv().HighField99NightsCarregado == true then
    return
end
getgenv().HighField99NightsCarregado = true

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "High Field Hub | 99 Noites",
   LoadingTitle = "Carregando Sobrevivência...",
   LoadingSubtitle = "by DEXZMMETA-bra",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Abas do Menu
local CombatTab = Window:CreateTab("Combate", 4483362458)
local WorldTab  = Window:CreateTab("Mundo & Itens", 4483362458)
local PlayerTab = Window:CreateTab("Jogador (LocalPlayer)", 4483362458)

-- Variáveis Globais de Controle
getgenv().KillAura99N = false
getgenv().GodMode = false
getgenv().ItemBringer = false
getgenv().DestinoItem = "Para Mim"
getgenv().FlyAtivo = false
getgenv().AutoChop = false
getgenv().LimiteArvores = 150

local Player = game:GetService("Players").LocalPlayer

-- 1. KILL AURA CLÁSSICA (Dano contínuo / Insta-Kill)
task.spawn(function()
    while task.wait(0.05) do
        if getgenv().KillAura99N and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    if v ~= Player.Character and (Player.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude < 35 then
                        local PunchRemote = game:GetService("ReplicatedStorage"):FindFirstChild("PunchRemote")
                        if PunchRemote then
                            PunchRemote:FireServer(v.HumanoidRootPart)
                        else
                            v.Humanoid.Health = 0 
                        end
                    end
                end
            end
        end
    end
end)

-- 2. GOD MODE (Imortalidade)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().GodMode and Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.MaxHealth = 999999
            Player.Character.Humanoid.Health = 999999
        end
    end
end)

-- 3. ITEM BRINGER (Puxar Recursos do Mapa por Destino)
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().ItemBringer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local destinoCFrame = nil
            
            if getgenv().DestinoItem == "Para Mim" then
                destinoCFrame = Player.Character.HumanoidRootPart.CFrame
            elseif getgenv().DestinoItem == "Mesa de Trabalho" and workspace:FindFirstChild("CraftingTable") then
                destinoCFrame = workspace.CraftingTable.CFrame
            elseif getgenv().DestinoItem == "Fogueira" and workspace:FindFirstChild("Campfire") then
                destinoCFrame = workspace.Campfire.CFrame
            else
                destinoCFrame = Player.Character.HumanoidRootPart.CFrame
            end

            for _, item in pairs(workspace:GetChildren()) do
                if item:IsA("Tool") or item:FindFirstChild("Handle") or item:IsA("SpawnedItem") then
                    local part = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
                    if part and destinoCFrame then
                        part.CFrame = destinoCFrame + Vector3.new(0, 2, 0)
                    end
                end
            end
        end
    end
end)

-- 4. AUTO FARM DE MADEIRA INTELIGENTE (Detector de Machado)
local function obterNivelMachado(character)
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return "Nenhum" end
    local name = tool.Name:lower()
    if name:find("chainsaw") or name:find("motosserra") then return "Maximo"
    elseif name:find("strong") or name:find("forte") or name:find("iron") then return "Forte"
    elseif name:find("good") or name:find("bom") or name:find("steel") then return "Bom"
    elseif name:find("old") or name:find("velho") or name:find("stone") then return "Velho" end
    return "Nenhum"
end

task.spawn(function()
    local ChopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ChopRemote") or game:GetService("ReplicatedStorage"):FindFirstChild("TreeEvent")
    while task.wait(0.1) do
        if getgenv().AutoChop and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local machado = obterNivelMachado(Player.Character)
            if machado ~= "Nenhum" then
                local contador = 0
                for _, obj in pairs(workspace:GetChildren()) do
                    if contador >= getgenv().LimiteArvores then break end
                    
                    if obj:FindFirstChild("Humanoid") or obj.Name:lower():find("tree") then
                        local distancia = (Player.Character.HumanoidRootPart.Position - (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("BasePart")).Position).Magnitude
                        if distancia < 150 then
                            local podeQuebrar = false
                            local nome = obj.Name
                            
                            if nome == "SmallTree" or nome:lower():find("small") then
                                podeQuebrar = true
                                if machado == "Forte" or machado == "Maximo" then task.wait(0.01) else task.wait(0.2) end
                            elseif nome == "BigTree" or nome:lower():find("big") or nome:lower():find("large") then
                                if machado == "Forte" or machado == "Maximo" then
                                    podeQuebrar = true
                                    task.wait(0.01)
                                end
                            end
                            
                            if podeQuebrar and ChopRemote then
                                ChopRemote:FireServer("Chop", obj)
                                contador = contador + 1
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Loop do Noclip
game:GetService("RunService").Stepped:Connect(function()
    if getgenv().FlyAtivo and Player.Character then
        for _, part in pairs(Player.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- INTERFACE GRÁFICA ELEMENTOS
CombatTab:CreateSection("Combate")
CombatTab:CreateToggle({
   Name = "Kill Aura Clássica",
   CurrentValue = false,
   Flag = "KillAura99NFlag",
   Callback = function(Value) getgenv().KillAura99N = Value end,
})
CombatTab:CreateToggle({
   Name = "God Mode (Imortalidade)",
   CurrentValue = false,
   Flag = "GodModeFlag",
   Callback = function(Value) getgenv().GodMode = Value end,
})

WorldTab:CreateSection("Item Bringer")
WorldTab:CreateDropdown({
   Name = "Trazer Itens Para:",
   Options = {"Para Mim", "Mesa de Trabalho", "Fogueira"},
   CurrentOption = "Para Mim",
   Flag = "DestinoItemFlag",
   Callback = function(Option) getgenv().DestinoItem = Option end,
})
WorldTab:CreateToggle({
   Name = "Trazer Todos os Itens do Mapa",
   CurrentValue = false,
   Flag = "ItemBringerFlag",
   Callback = function(Value) getgenv().ItemBringer = Value end,
})

WorldTab:CreateSection("Lenhador Automático")
WorldTab:CreateSlider({
   Name = "Quantidade de Árvores",
   Range = {50, 200},
   Increment = 10,
   Suffix = " Árvores",
   CurrentValue = 150,
   Flag = "LimiteArvoresFlag",
   Callback = function(Value) getgenv().LimiteArvores = Value end,
})
WorldTab:CreateToggle({
   Name = "Auto Cortar Árvores (Inteligente)",
   CurrentValue = false,
   Flag = "AutoChopFlag",
   Callback = function(Value) getgenv().AutoChop = Value end,
})

PlayerTab:CreateSection("Modificadores")
PlayerTab:CreateSlider({
   Name = "Velocidade (WalkSpeed)",
   Range = {16, 250},
   Increment = 1,
   Suffix = " Sps",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = Value end
   end,
})
PlayerTab:CreateSlider({
   Name = "Campo de Visão (FOV)",
   Range = {70, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOVSlider",
   Callback = function(Value) workspace.CurrentCamera.FieldOfView = Value end
})
PlayerTab:CreateToggle({
   Name = "Voo + Noclip",
   CurrentValue = false,
   Flag = "FlyFlag",
   Callback = function(Value)
      getgenv().FlyAtivo = Value
      local char = Player.Character
      if Value and char and char:FindFirstChild("HumanoidRootPart") then
          local bv = Instance.new("BodyVelocity")
          bv.Name = "HighField99NFly"
          bv.MaxForce = Vector3.new(0, math.huge, 0)
          bv.Velocity = Vector3.new(0, 0.5, 0)
          bv.Parent = char.HumanoidRootPart
      else
          if char and char.HumanoidRootPart:FindFirstChild("HighField99NFly") then
              char.HumanoidRootPart.HighField99NFly:Destroy()
          end
      end
   end,
})

Rayfield:Notify({Title = "High Field Hub", Content = "Script de 99 Noites Carregado!", Duration = 4})
