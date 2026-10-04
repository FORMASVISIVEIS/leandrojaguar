-- 🍟 YAGO HUB — PATCH VISUAL v3
-- Rode YagoMAC_RESTAURADO.lua primeiro.
-- Depois rode este patch com o menu já aberto.
-- Este arquivo NÃO substitui nem modifica o payload original.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end

local taskWait = (task and task.wait) or wait

local YELLOW   = Color3.fromRGB(255, 199, 0)
local RED      = Color3.fromRGB(210, 35, 45)
local RED_DARK = Color3.fromRGB(150, 25, 30)
local RED_SOFT = Color3.fromRGB(95, 22, 28)
local CREAM    = Color3.fromRGB(255, 235, 170)
local WHITE    = Color3.fromRGB(255, 255, 255)

local function getRoots()
    local out = {}

    local pg = player:FindFirstChildOfClass("PlayerGui")
    if pg then
        table.insert(out, pg)
    end

    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg then
            table.insert(out, cg)
        end
    end)

    return out
end

local function textOf(obj)
    local ok, value = pcall(function()
        return obj.Text
    end)
    if ok and type(value) == "string" then
        return value
    end
    return ""
end

local function isTextObject(obj)
    return obj:IsA("TextLabel")
        or obj:IsA("TextButton")
        or obj:IsA("TextBox")
end

local function isVisible(obj)
    local ok, v = pcall(function() return obj.Visible end)
    return (not ok) or v
end

local function setText(obj, value, color)
    pcall(function()
        obj.Text = value
        obj.TextColor3 = color
    end)
end

local function setBg(obj, color)
    pcall(function()
        obj.BackgroundColor3 = color
        obj.BackgroundTransparency = 0
    end)
end

local function setStroke(obj, color, thickness)
    if not obj:IsA("UIStroke") then return end
    pcall(function()
        obj.Color = color
        obj.Thickness = thickness or 2
        obj.Transparency = 0
    end)
end

local function ancestors(obj, maxDepth)
    local a = {}
    local cur = obj
    for _ = 1, (maxDepth or 10) do
        if not cur or not cur.Parent then break end
        cur = cur.Parent
        table.insert(a, cur)
    end
    return a
end

local function apply()
    local foundMenu = false
    local titleObjects = {}

    for _, root in ipairs(getRoots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if isVisible(obj) and isTextObject(obj) then
                local raw = textOf(obj)
                local t = string.lower(raw:gsub("<[^>]->", "")):gsub("^%s+", ""):gsub("%s+$", "")

                -- Título: captura MENU mesmo que venha com emoji/ícone.
                if t == "menu" or t:find("menu", 1, true) then
                    foundMenu = true
                    table.insert(titleObjects, obj)
                    setText(obj, "🍟 YAGO HUB", YELLOW)
                    pcall(function() obj.Font = Enum.Font.GothamBold end)

                    -- Colore a cadeia imediata de containers do título.
                    local a = ancestors(obj, 6)
                    for i, parent in ipairs(a) do
                        if parent:IsA("Frame") then
                            if i <= 2 then
                                setBg(parent, RED_DARK)
                            elseif i <= 4 then
                                setBg(parent, RED_SOFT)
                            end
                        elseif parent:IsA("ScrollingFrame") then
                            setBg(parent, RED_SOFT)
                        end
                    end
                end

                -- Whitelist: pode ser botão OU um TextLabel dentro de um botão.
                if t:find("whitelist", 1, true) then
                    setText(obj, "👥 Whitelist", YELLOW)
                    if obj:IsA("TextButton") then
                        setBg(obj, RED)
                    end

                    local a = ancestors(obj, 4)
                    for _, parent in ipairs(a) do
                        if parent:IsA("TextButton") or parent:IsA("Frame") then
                            pcall(function()
                                parent.BackgroundColor3 = RED
                                parent.BackgroundTransparency = 0
                            end)
                            break
                        end
                    end
                end

                -- OFF/ON: pinta o controle que contém o texto.
                if t == "off" then
                    setText(obj, "OFF", WHITE)
                    setBg(obj, RED)
                    local a = ancestors(obj, 3)
                    for _, parent in ipairs(a) do
                        if parent:IsA("TextButton") then
                            setBg(parent, RED)
                            break
                        end
                    end
                elseif t == "on" then
                    setText(obj, "ON", RED_DARK)
                    setBg(obj, YELLOW)
                    local a = ancestors(obj, 3)
                    for _, parent in ipairs(a) do
                        if parent:IsA("TextButton") then
                            setBg(parent, YELLOW)
                            break
                        end
                    end
                end
            end
        end

        -- Recolore os elementos visuais do menu sem tocar em eventos/funcionalidade.
        if foundMenu then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("UIStroke") then
                    -- Somente strokes próximos do título/menu.
                    for _, title in ipairs(titleObjects) do
                        for _, p in ipairs(ancestors(title, 8)) do
                            if obj.Parent == p or obj:IsDescendantOf(p) then
                                setStroke(obj, YELLOW, 2)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    return foundMenu
end

-- Tenta por até 60 s porque o GUI pode recriar partes sozinho.
for _ = 1, 120 do
    local ok = apply()
    if ok then
        -- Reaplica algumas vezes para vencer scripts que redesenham a UI.
        for _ = 1, 8 do
            taskWait(0.5)
            apply()
        end
        break
    end
    taskWait(0.5)
end
