-- 🍟 YAGO HUB — MODERN UI
-- Design moderno separado do payload original.
-- Use depois que YagoMAC_RESTAURADO.lua tiver aberto o menu original.
--
-- IMPORTANTE:
-- Esta interface é uma camada visual/controladora. O payload original continua sendo
-- responsável pelas funções. Para preservar a estabilidade, este arquivo não altera
-- nem reescreve o código obfuscado.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
if not player then return end

local waitFn = (task and task.wait) or wait

local THEME = {
    Red = Color3.fromRGB(214, 35, 45),
    RedDark = Color3.fromRGB(115, 22, 30),
    RedSoft = Color3.fromRGB(75, 24, 30),
    Yellow = Color3.fromRGB(255, 199, 0),
    Cream = Color3.fromRGB(255, 241, 190),
    Bg = Color3.fromRGB(18, 18, 25),
    Panel = Color3.fromRGB(27, 27, 38),
    Panel2 = Color3.fromRGB(34, 34, 47),
    Text = Color3.fromRGB(245, 245, 250),
    Muted = Color3.fromRGB(155, 158, 175),
    Green = Color3.fromRGB(46, 190, 110)
}

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    if parent then o.Parent = parent end
    return o
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function tween(obj, props, duration)
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

local function getRoots()
    local roots = {}
    local pg = player:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(roots, pg) end
    pcall(function()
        local cg = game:GetService("CoreGui")
        if cg then table.insert(roots, cg) end
    end)
    return roots
end

local function normalize(text)
    text = tostring(text or ""):lower()
    text = text:gsub("<[^>]->", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

-- Encontra o menu antigo sem assumir um nome fixo.
local function findOriginalMenu()
    for _, root in ipairs(getRoots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and normalize(obj.Text):find("menu", 1, true) then
                local cur = obj
                local best = nil
                for _ = 1, 10 do
                    if not cur.Parent then break end
                    cur = cur.Parent
                    if cur:IsA("Frame") or cur:IsA("ScrollingFrame") then
                        if cur.AbsoluteSize.X >= 300 and cur.AbsoluteSize.Y >= 200 then
                            best = cur
                        end
                    end
                end
                return best or obj.Parent
            end
        end
    end
    return nil
end

-- Guarda os botões originais encontrados para tentar manter a funcionalidade.
local originalButtons = {}

local function scanOriginal()
    originalButtons = {}
    for _, root in ipairs(getRoots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextButton") then
                local t = normalize(obj.Text)
                if t ~= "" then
                    originalButtons[t] = originalButtons[t] or {}
                    table.insert(originalButtons[t], obj)
                end
            end
        end
    end
end

local function activateOriginal(text)
    local key = normalize(text)
    local list = originalButtons[key]
    if not list then return false end

    for _, btn in ipairs(list) do
        if btn and btn.Parent then
            local ok = pcall(function() btn:Activate() end)
            if ok then return true end
        end
    end
    return false
end

-- Limpa GUI anterior desta camada.
for _, root in ipairs(getRoots()) do
    local old = root:FindFirstChild("YagoModernHub")
    if old then old:Destroy() end
end

scanOriginal()

local gui = new("ScreenGui", {
    Name = "YagoModernHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, player:FindFirstChildOfClass("PlayerGui"))

if not gui then return end

local dim = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.48,
    BorderSizePixel = 0,
    ZIndex = 1
}, gui)

local main = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0, 900, 0, 575),
    BackgroundColor3 = THEME.Bg,
    BorderSizePixel = 0,
    ZIndex = 10
}, gui)
corner(main, 18)
stroke(main, THEME.Yellow, 1.5, 0.2)

-- Barra lateral.
local sidebar = new("Frame", {
    Size = UDim2.new(0, 205, 1, 0),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
    ZIndex = 11
}, main)
corner(sidebar, 18)

local sideMask = new("Frame", {
    Position = UDim2.new(1, -18, 0, 0),
    Size = UDim2.new(0, 18, 1, 0),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
    ZIndex = 12
}, sidebar)

local logo = new("TextLabel", {
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(1, -40, 0, 34),
    BackgroundTransparency = 1,
    Text = "🍟  YAGO HUB",
    TextColor3 = THEME.Yellow,
    Font = Enum.Font.GothamBold,
    TextSize = 21,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13
}, sidebar)

local sub = new("TextLabel", {
    Position = UDim2.new(0, 21, 0, 53),
    Size = UDim2.new(1, -42, 0, 22),
    BackgroundTransparency = 1,
    Text = "MODERN CONTROL",
    TextColor3 = THEME.Muted,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13
}, sidebar)

local nav = new("Frame", {
    Position = UDim2.new(0, 12, 0, 102),
    Size = UDim2.new(1, -24, 0, 245),
    BackgroundTransparency = 1,
    ZIndex = 13
}, sidebar)

local navLayout = new("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, nav)

local content = new("Frame", {
    Position = UDim2.new(0, 205, 0, 0),
    Size = UDim2.new(1, -205, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 11
}, main)

local topTitle = new("TextLabel", {
    Position = UDim2.new(0, 28, 0, 23),
    Size = UDim2.new(1, -170, 0, 32),
    BackgroundTransparency = 1,
    Text = "Whitelist",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 24,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13
}, content)

local status = new("TextLabel", {
    Position = UDim2.new(0, 29, 0, 53),
    Size = UDim2.new(1, -58, 0, 20),
    BackgroundTransparency = 1,
    Text = "Gerencie a lista com uma interface nova.",
    TextColor3 = THEME.Muted,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13
}, content)

local close = new("TextButton", {
    Position = UDim2.new(1, -50, 0, 18),
    Size = UDim2.new(0, 32, 0, 32),
    BackgroundColor3 = THEME.Panel2,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = THEME.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    AutoButtonColor = false,
    ZIndex = 14
}, main)
corner(close, 9)

local search = new("TextBox", {
    Position = UDim2.new(0, 28, 0, 86),
    Size = UDim2.new(1, -56, 0, 42),
    BackgroundColor3 = THEME.Panel,
    BorderSizePixel = 0,
    PlaceholderText = "Pesquisar jogador...",
    PlaceholderColor3 = THEME.Muted,
    Text = "",
    TextColor3 = THEME.Text,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    ClearTextOnFocus = false,
    ZIndex = 13
}, content)
corner(search, 11)
stroke(search, THEME.Yellow, 1, 0.75)

local list = new("ScrollingFrame", {
    Position = UDim2.new(0, 28, 0, 142),
    Size = UDim2.new(1, -56, 1, -170),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.Yellow,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 13
}, content)

local listLayout = new("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, list)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end)

-- Botões de navegação.
local pages = {}

local function makeNav(name, icon)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Text = "   " .. icon .. "  " .. name,
        TextColor3 = THEME.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 14
    }, nav)
    corner(b, 10)
    pages[name] = b
    return b
end

local whitelistNav = makeNav("Whitelist", "👥")
local combatNav = makeNav("Combat", "⚔")
local visualNav = makeNav("Visual", "◈")
local movementNav = makeNav("Movement", "➜")
local settingsNav = makeNav("Settings", "⚙")

local footer = new("TextLabel", {
    Position = UDim2.new(0, 21, 1, -42),
    Size = UDim2.new(1, -42, 0, 24),
    BackgroundTransparency = 1,
    Text = "●  ONLINE",
    TextColor3 = THEME.Green,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 13
}, sidebar)

-- Abas. A whitelist usa os controles encontrados no menu original.
local currentPage = "Whitelist"

local function clearList()
    for _, child in ipairs(list:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function addInfo(text)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = THEME.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ZIndex = 14
    }, list)
    local card = list:GetChildren()[#list:GetChildren()]
    corner(card, 12)
end

local function addCard(label, oldButton)
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        ZIndex = 14
    }, list)
    corner(card, 12)

    local avatar = new("Frame", {
        Position = UDim2.new(0, 10, 0.5, -17),
        Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = THEME.RedDark,
        BorderSizePixel = 0,
        ZIndex = 15
    }, card)
    corner(avatar, 10)

    new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "●",
        TextColor3 = THEME.Yellow,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 16
    }, avatar)

    new("TextLabel", {
        Position = UDim2.new(0, 56, 0, 0),
        Size = UDim2.new(1, -165, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 15
    }, card)

    local toggle = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 88, 0, 34),
        BackgroundColor3 = THEME.Red,
        BorderSizePixel = 0,
        Text = "OFF",
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        ZIndex = 15
    }, card)
    corner(toggle, 9)

    local function sync()
        if oldButton and oldButton.Parent then
            local t = normalize(oldButton.Text)
            if t == "on" then
                toggle.Text = "ON"
                tween(toggle, {BackgroundColor3 = THEME.Yellow, TextColor3 = THEME.RedDark}, 0.14)
            else
                toggle.Text = "OFF"
                tween(toggle, {BackgroundColor3 = THEME.Red, TextColor3 = THEME.Text}, 0.14)
            end
        end
    end

    toggle.MouseButton1Click:Connect(function()
        if oldButton and oldButton.Parent then
            pcall(function() oldButton:Activate() end)
            waitFn(0.08)
            sync()
        end
    end)

    sync()
end

local function showWhitelist()
    clearList()
    topTitle.Text = "Whitelist"
    status.Text = "Lista encontrada no menu original."

    local entries = {}

    -- Procura pares "nome + OFF/ON" no menu original.
    for _, root in ipairs(getRoots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextButton") then
                local bt = normalize(obj.Text)
                if bt == "off" or bt == "on" then
                    local parent = obj.Parent
                    local candidate = nil

                    if parent then
                        for _, child in ipairs(parent:GetDescendants()) do
                            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child ~= obj then
                                local tx = tostring(child.Text or "")
                                local n = normalize(tx)
                                if n ~= "" and n ~= "off" and n ~= "on" and not n:find("whitelist", 1, true) and #tx <= 64 then
                                    candidate = tx
                                    break
                                end
                            end
                        end
                    end

                    if candidate then
                        table.insert(entries, {name = candidate, button = obj})
                    end
                end
            end
        end
    end

    local seen = {}
    for _, e in ipairs(entries) do
        local key = normalize(e.name)
        if not seen[key] then
            seen[key] = true
            addCard(e.name, e.button)
        end
    end

    if #entries == 0 then
        addInfo("Nenhuma entrada da Whitelist foi encontrada ainda.")
    end
end

local function showFeatures(pageName, keywords)
    clearList()
    topTitle.Text = pageName
    status.Text = "Controles detectados no menu original."

    local found = {}
    for _, root in ipairs(getRoots()) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextButton") then
                local t = tostring(obj.Text or "")
                local n = normalize(t)
                if n ~= "" and n ~= "off" and n ~= "on" then
                    for _, kw in ipairs(keywords) do
                        if n:find(kw, 1, true) then
                            table.insert(found, {name = t, button = obj})
                            break
                        end
                    end
                end
            end
        end
    end

    local seen = {}
    for _, e in ipairs(found) do
        local key = normalize(e.name)
        if not seen[key] then
            seen[key] = true
            addCard(e.name, e.button)
        end
    end

    if #found == 0 then
        addInfo("Nenhum controle compatível foi detectado nessa categoria.")
    end
end

local function setActive(name)
    currentPage = name

    for page, btn in pairs(pages) do
        if page == name then
            btn.BackgroundColor3 = THEME.Red
            btn.TextColor3 = THEME.Cream
        else
            btn.BackgroundColor3 = THEME.Panel
            btn.TextColor3 = THEME.Muted
        end
    end
end

whitelistNav.MouseButton1Click:Connect(function()
    setActive("Whitelist")
    showWhitelist()
end)

combatNav.MouseButton1Click:Connect(function()
    setActive("Combat")
    showFeatures("Combat", {"trigger", "camlock", "hitbox", "aim"})
end)

visualNav.MouseButton1Click:Connect(function()
    setActive("Visual")
    showFeatures("Visual", {"esp", "visual", "box", "name"})
end)

movementNav.MouseButton1Click:Connect(function()
    setActive("Movement")
    showFeatures("Movement", {"spider", "speed", "fly", "movement", "switch"})
end)

settingsNav.MouseButton1Click:Connect(function()
    setActive("Settings")
    clearList()
    topTitle.Text = "Settings"
    status.Text = "Configurações da interface."

    addInfo("Insert — abre/fecha o YAGO HUB")
    addInfo("Arraste pela barra superior para mover o painel.")
    addInfo("O payload original não é reescrito por esta camada.")
end)

close.MouseButton1Click:Connect(function()
    tween(main, {Size = UDim2.new(0, 820, 0, 0)}, 0.18)
    tween(dim, {BackgroundTransparency = 1}, 0.18)
    waitFn(0.2)
    gui.Enabled = false
end)

-- Abre/fecha com Insert.
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
    end
end)

-- Drag da janela.
local dragging = false
local dragStart
local startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = normalize(search.Text)
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then
            local label = child:FindFirstChildWhichIsA("TextLabel")
            local name = label and normalize(label.Text) or ""
            child.Visible = (q == "" or name:find(q, 1, true) ~= nil)
        end
    end
end)

-- Entrada inicial.
setActive("Whitelist")
showWhitelist()

-- Pequena animação inicial.
local targetSize = main.Size
main.Size = UDim2.new(0, 900, 0, 0)
tween(main, {Size = targetSize}, 0.25)
