-- 🍟 YAGO HUB — PATCH VISUAL SEPARADO
-- Execute o YagoMAC_RESTAURADO.lua primeiro.
-- Depois execute este arquivo. Ele só altera a aparência do menu já criado.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end

local waitFn = (task and task.wait) or wait

local YELLOW = Color3.fromRGB(255, 199, 0)
local RED = Color3.fromRGB(198, 40, 40)
local DARK_RED = Color3.fromRGB(120, 25, 25)
local WHITE = Color3.fromRGB(255, 255, 255)
local FRIES = string.char(240, 159, 141, 159)

local function roots()
    local r = {}

    local pg = player:FindFirstChildOfClass("PlayerGui")
    if pg then
        table.insert(r, pg)
    end

    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg then
            table.insert(r, cg)
        end
    end)

    return r
end

local function findTitle()
    for _, root in ipairs(roots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                local t = tostring(obj.Text or "")
                local low = string.lower(t)

                if low == "menu"
                    or low == "⚡ menu"
                    or low:find("menu", 1, true) then
                    return obj
                end
            end
        end
    end

    return nil
end

local function largestFrameAncestor(obj)
    local best = nil
    local bestArea = -1
    local cur = obj

    for _ = 1, 12 do
        if not cur or not cur.Parent then break end
        cur = cur.Parent

        if cur:IsA("Frame") or cur:IsA("ScrollingFrame") then
            local area = cur.AbsoluteSize.X * cur.AbsoluteSize.Y
            if area > bestArea then
                best = cur
                bestArea = area
            end
        end
    end

    return best
end

local function paint(root)
    if not root then return false end

    local title = findTitle()
    if not title then return false end

    -- Título
    pcall(function()
        title.Text = FRIES .. " YAGO HUB"
        title.TextColor3 = YELLOW
        title.Font = Enum.Font.GothamBold
    end)

    -- Painel principal: somente o maior Frame ancestral do título.
    local panel = largestFrameAncestor(title)
    if panel then
        pcall(function()
            panel.BackgroundColor3 = DARK_RED
            panel.BorderColor3 = YELLOW
            panel.BorderSizePixel = 2
        end)
    end

    -- Elementos visuais do menu.
    for _, obj in ipairs(root:GetDescendants()) do
        pcall(function()
            if obj:IsA("TextButton") then
                local t = string.lower(tostring(obj.Text or ""))

                if t == "off" then
                    obj.BackgroundColor3 = RED
                    obj.TextColor3 = WHITE
                elseif t == "on" then
                    obj.BackgroundColor3 = YELLOW
                    obj.TextColor3 = DARK_RED
                elseif t:find("whitelist", 1, true) then
                    obj.BackgroundColor3 = YELLOW
                    obj.TextColor3 = DARK_RED
                    obj.Font = Enum.Font.GothamBold
                end

            elseif obj:IsA("TextLabel") then
                local t = string.lower(tostring(obj.Text or ""))

                if t:find("whitelist", 1, true) then
                    obj.TextColor3 = YELLOW
                end

            elseif obj:IsA("UIStroke") then
                obj.Color = YELLOW
            end
        end)
    end

    return true
end

-- Espera o menu existir sem alterar a execução do script original.
for _ = 1, 120 do
    local ok = false

    for _, root in ipairs(roots()) do
        if paint(root) then
            ok = true
        end
    end

    if ok then
        break
    end

    waitFn(0.5)
end
