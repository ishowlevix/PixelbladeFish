-- ============================================================
-- PB_AutoFish.lua (v12 - Pixel Blade AutoFish | Public Release)
-- ============================================================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local remotes = ReplicatedStorage:WaitForChild("_network_remotes", 5)
local pg = lp:WaitForChild("PlayerGui")
local fishingHud = pg:WaitForChild("fishing_hud", 10)
local minigame = fishingHud
    and fishingHud:WaitForChild("FishingHud", 5)
    and fishingHud.FishingHud:WaitForChild("canvas", 5):WaitForChild("minigame", 5)

-- ================= ANTI-AFK =================
lp.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    end)
end)

-- ================= GUI =================
local sg = Instance.new("ScreenGui")
sg.Name = "PB_AutoFish_UI"
sg.ResetOnSpawn = false
sg.Parent = CoreGui

-- Main window
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 340, 0, 490)
main.Position = UDim2.new(0.04, 0, 0.22, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 150, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3

-- Header bar
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(10, 20, 38)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

-- Accent line under header
local accent = Instance.new("Frame", main)
accent.Size = UDim2.new(1, 0, 0, 2)
accent.Position = UDim2.new(0, 0, 0, 38)
accent.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
accent.BorderSizePixel = 0
accent.BackgroundTransparency = 0.5

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -42, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "PB AutoFish  |  v12"

local subtitle = Instance.new("TextLabel", header)
subtitle.Size = UDim2.new(0, 120, 1, 0)
subtitle.Position = UDim2.new(1, -154, 0, 0)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(0, 170, 255)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Right
subtitle.Text = "Pixel Blade"

local xb = Instance.new("TextButton", header)
xb.Size = UDim2.new(0, 22, 0, 22)
xb.Position = UDim2.new(1, -30, 0, 8)
xb.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
xb.TextColor3 = Color3.new(1, 1, 1)
xb.Text = "✕"
xb.Font = Enum.Font.GothamBold
xb.TextSize = 11
xb.BorderSizePixel = 0
Instance.new("UICorner", xb).CornerRadius = UDim.new(1, 0)

-- Minimized bubble (appears top-right of screen when UI is hidden)
local bubble = Instance.new("TextButton", sg)
bubble.Name = "PB_Bubble"
bubble.Size = UDim2.new(0, 42, 0, 42)
bubble.Position = UDim2.new(1, -58, 0.04, 0)
bubble.BackgroundColor3 = Color3.fromRGB(10, 20, 38)
bubble.TextColor3 = Color3.fromRGB(0, 170, 255)
bubble.Text = "🐟"
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 18
bubble.BorderSizePixel = 0
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
local bubbleStroke = Instance.new("UIStroke", bubble)
bubbleStroke.Color = Color3.fromRGB(0, 150, 255)
bubbleStroke.Thickness = 1.5
bubbleStroke.Transparency = 0.25

-- ── Status section ──────────────────────────────────────────
local function makeLabel(parent, yPos, color, size)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -24, 0, size or 18)
    lbl.Position = UDim2.new(0, 12, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = ""
    return lbl
end

local stateLbl      = makeLabel(main,  46, Color3.fromRGB(255, 210,  80), 20)
stateLbl.Font       = Enum.Font.GothamBold
stateLbl.TextSize   = 12

local bobberLbl     = makeLabel(main,  68, Color3.fromRGB(150, 200, 255))
local targetLbl     = makeLabel(main,  88, Color3.fromRGB(120, 220, 120))
local bagCapacityLbl= makeLabel(main, 108, Color3.fromRGB(255, 200, 100))
local pagesLbl      = makeLabel(main, 128, Color3.fromRGB(200, 155, 255))

-- Divider
local divider = Instance.new("Frame", main)
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 150)
divider.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
divider.BorderSizePixel = 0

-- ── Toggle states & helper ──────────────────────────────────
local toggles = {
    autoSell        = true,
    autoCraft       = true,
    keepPage        = true,
    autoTp          = true,
    keepGoldenCod   = false,
    keepGoldenTooth = false,
}
local PAGE_CRAFT_THRESHOLD = 32

local function makeToggle(parent, yPos, labelText, onColor, offColor, onBg, offBg, defaultState, onChange)
    defaultState = (defaultState == nil) and true or defaultState
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -24, 0, 26)
    btn.Position = UDim2.new(0, 12, 0, yPos)
    btn.BackgroundColor3 = defaultState and onBg or offBg
    btn.TextColor3 = defaultState and onColor or offColor
    btn.Text = labelText .. (defaultState and "  ●  ON" or "  ○  OFF")
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke2 = Instance.new("UIStroke", btn)
    stroke2.Color = defaultState and onColor or offColor
    stroke2.Thickness = 1
    stroke2.Transparency = 0.65

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = labelText .. (state and "  ●  ON" or "  ○  OFF")
        btn.TextColor3 = state and onColor or offColor
        btn.BackgroundColor3 = state and onBg or offBg
        stroke2.Color = state and onColor or offColor
        if onChange then
            onChange(state)
        end
    end)

    return btn
end

-- TOGGLE 1: Auto-Sell
makeToggle(main, 158,
    "Auto-Sell (≥ 90% bag)   ",
    Color3.fromRGB(100, 255, 140), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(20, 45, 28),    Color3.fromRGB(45, 22, 22),
    true, function(val) toggles.autoSell = val end)

-- TOGGLE 2: Auto-Craft
makeToggle(main, 188,
    "Auto-Craft Book (≥ 32 Pages)   ",
    Color3.fromRGB(180, 130, 255), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(32, 22, 52),    Color3.fromRGB(45, 22, 22),
    true, function(val) toggles.autoCraft = val end)

-- TOGGLE 3: Skip Page on sell
makeToggle(main, 218,
    "Skip 'Page' when selling   ",
    Color3.fromRGB(100, 255, 200), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(20, 42, 38),    Color3.fromRGB(45, 22, 22),
    true, function(val) toggles.keepPage = val end)

-- TOGGLE 4: Teleport + Hover
makeToggle(main, 248,
    "Teleport + Hover   ",
    Color3.fromRGB(130, 200, 255), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(18, 30, 50),    Color3.fromRGB(45, 22, 22),
    true, function(val) toggles.autoTp = val end)

-- TOGGLE 5: Skip Golden Cod on sell (default OFF)
makeToggle(main, 278,
    "Skip 'Golden Cod'   ",
    Color3.fromRGB(255, 210, 80), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(45, 38, 10),   Color3.fromRGB(45, 22, 22),
    false, function(val) toggles.keepGoldenCod = val end)

-- TOGGLE 6: Skip Golden Tooth on sell (default OFF)
makeToggle(main, 308,
    "Skip 'Golden Tooth'   ",
    Color3.fromRGB(255, 210, 80), Color3.fromRGB(255, 110, 110),
    Color3.fromRGB(45, 38, 10),   Color3.fromRGB(45, 22, 22),
    false, function(val) toggles.keepGoldenTooth = val end)

-- Divider 2
local divider2 = Instance.new("Frame", main)
divider2.Size = UDim2.new(1, -24, 0, 1)
divider2.Position = UDim2.new(0, 12, 0, 340)
divider2.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
divider2.BorderSizePixel = 0

-- START / STOP button
local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(1, -24, 0, 36)
toggleBtn.Position = UDim2.new(0, 12, 0, 348)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 155, 70)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "▶   START"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 7)
local startStroke = Instance.new("UIStroke", toggleBtn)
startStroke.Color = Color3.fromRGB(0, 255, 100)
startStroke.Thickness = 1
startStroke.Transparency = 0.5

-- Footer info
local footer = Instance.new("TextLabel", main)
footer.Size = UDim2.new(1, -24, 0, 100)
footer.Position = UDim2.new(0, 12, 0, 392)
footer.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
footer.TextColor3 = Color3.fromRGB(90, 110, 140)
footer.Font = Enum.Font.Code
footer.TextSize = 10
footer.TextWrapped = true
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Text = "  ◈  Auto-Sell at 90% bag capacity (dynamic)\n  ◈  Auto-Craft: teleports to Magician when ≥32 Pages\n  ◈  All states are mutually exclusive (FSM)\n  ◈  30s no-catch watchdog auto-recasts rod\n  ◈  Anti-AFK built in  |  [RCtrl] hide/show  |  [End] exit"
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 6)

-- Footer stroke
local footerStroke = Instance.new("UIStroke", footer)
footerStroke.Color = Color3.fromRGB(30, 45, 70)
footerStroke.Thickness = 1

-- ================= ZMIENNE STANU =================
local running = false
local currentCatches = 0
local inMinigame = false
local isSellingNow = false
local isCraftingNow = false

local FINN_POS = Vector3.new(3187.8, 186.8, -72.0)
local MAGICIAN_POS = Vector3.new(3114.6, 225.2, -104.5)
local MAGICIAN_LOOK = Vector3.new(3107.7, 226.3, -104.3)

local function setState(txt)
    stateLbl.Text = "⬤  " .. txt
end

-- ================= LEWITACJA =================
local hoverVelocity = nil

local function enableHover(hrp)
    if not hoverVelocity or hoverVelocity.Parent ~= hrp then
        hoverVelocity = Instance.new("BodyVelocity")
        hoverVelocity.Name = "PB_Hover"
        hoverVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        hoverVelocity.Velocity = Vector3.zero
        hoverVelocity.Parent = hrp
    end
end

local function disableHover()
    if hoverVelocity then
        hoverVelocity:Destroy()
        hoverVelocity = nil
    end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local old = hrp:FindFirstChild("PB_Hover")
        if old then old:Destroy() end
    end
end

local function cleanup()
    running = false
    disableHover()
    sg:Destroy()
end

local function minimizeUI()
    main.Visible = false
    bubble.Visible = true
end

local function restoreUI()
    bubble.Visible = false
    main.Visible = true
end

xb.MouseButton1Click:Connect(minimizeUI)
bubble.MouseButton1Click:Connect(restoreUI)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.End then cleanup() end
    if i.KeyCode == Enum.KeyCode.RightControl then
        if main.Visible then
            minimizeUI()
        else
            restoreUI()
        end
    end
end)

-- ================= KLIKANIE GUI & POMOCNIKI =================
local function isVisible(inst)
    if not inst then return false end
    if not inst.Parent then return false end
    if inst:IsA("ScreenGui") then return inst.Enabled end
    if inst:IsA("GuiObject") then return inst.Visible end
    return true
end

local function clickGui(btn)
    if not btn then return end
    local inset = GuiService:GetGuiInset()
    local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
    local x = pos.X + inset.X
    local y = pos.Y + inset.Y

    pcall(function()
        VirtualInputManager:SendMouseMoveEvent(x, y, game)
        task.wait(0.03)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(0.06)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

-- ================= DETEKCJA PLECAKA & PAGE =================
local function getBagInfo()
    local stash = pg:FindFirstChild("fishing_stash")
    if stash then
        local fig = stash:FindFirstChild("figure", true)
        if fig and fig.Text then
            local cur, maxSlots = fig.Text:match("(%d+)%s*/%s*(%d+)")
            if cur and maxSlots then
                return tonumber(cur), tonumber(maxSlots)
            end
        end
        local countFrame = stash:FindFirstChild("count", true)
        if countFrame then
            for _, d in ipairs(countFrame:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and d.Text:match("^%d+%s*/%s*%d+$") then
                    local cur, maxSlots = d.Text:match("(%d+)%s*/%s*(%d+)")
                    if cur and maxSlots then
                        return tonumber(cur), tonumber(maxSlots)
                    end
                end
            end
        end
    end
    return nil, nil
end

local function getPageCount()
    local stash = pg:FindFirstChild("fishing_stash")
    if stash then
        local cardPage = stash:FindFirstChild("card_Page", true)
        if cardPage then
            for _, d in ipairs(cardPage:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text then
                    local p = d.Text:match("^(%d+)%s*/")
                    if p then return tonumber(p) end
                    local single = d.Text:match("^(%d+)$")
                    if single then return tonumber(single) end
                end
            end
        end
    end

    local armory = pg:FindFirstChild("armory_menu")
    if armory then
        local wallet = armory:FindFirstChild("wallet", true)
        if wallet then
            local fig = wallet:FindFirstChild("figure", true)
            if fig and fig.Text and tonumber(fig.Text) then
                return tonumber(fig.Text)
            end
        end
    end

    return 0
end

local function isBagFull()
    local cur, maxSlots = getBagInfo()
    if cur and maxSlots and maxSlots > 0 then
        local pct = (cur / maxSlots) * 100
        return (cur / maxSlots) >= 0.90, cur, maxSlots, pct
    end
    -- Fallback
    local fallbackCur = currentCatches
    local fallbackMax = 45
    return fallbackCur >= fallbackMax, fallbackCur, fallbackMax, (fallbackCur / fallbackMax) * 100
end

local function updateUIStatus()
    local cur, maxSlots = getBagInfo()
    if cur and maxSlots then
        local pct = math.floor((cur / maxSlots) * 100)
        bagCapacityLbl.Text = string.format("Inventory: %d / %d  (%d%%)", cur, maxSlots, pct)
        if pct >= 90 then
            bagCapacityLbl.TextColor3 = Color3.fromRGB(255, 90, 90)
        else
            bagCapacityLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    else
        bagCapacityLbl.Text = string.format("Inventory: %d items (counter)", currentCatches)
        bagCapacityLbl.TextColor3 = Color3.fromRGB(200, 200, 255)
    end

    local pages = getPageCount()
    pagesLbl.Text = string.format("Pages: %d  (craft at ≥ %d)", pages, PAGE_CRAFT_THRESHOLD)
    if pages >= PAGE_CRAFT_THRESHOLD then
        pagesLbl.TextColor3 = Color3.fromRGB(120, 255, 120)
    else
        pagesLbl.TextColor3 = Color3.fromRGB(200, 155, 255)
    end
end

-- Petla w tle aktualizujaca stan plecaka i stron
task.spawn(function()
    while true do
        task.wait(1.0)
        pcall(updateUIStatus)
    end
end)

-- ================= WERYFIKACJA SPŁAWIKA & WĘDKI =================
local lastFishActionTime = tick()

local function getMyBobber(currentSpot)
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local rod = char:FindFirstChild("held_fishing_rod")
    if not rod then return nil end

    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Constraint") then
            local a0 = d.Attachment0
            local a1 = d.Attachment1
            local p0 = a0 and a0.Parent
            local p1 = a1 and a1.Parent
            if p0 and p0.Name == "fishing_bob" and p0:IsA("BasePart") then return p0 end
            if p1 and p1.Name == "fishing_bob" and p1:IsA("BasePart") then return p1 end
        end
    end

    local lookVec = hrp.CFrame.LookVector
    local bestBob = nil
    local bestScore = math.huge

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "fishing_bob" and obj:IsA("BasePart") then
            local toBob = obj.Position - hrp.Position
            local dist = toBob.Magnitude
            if dist >= 8 and dist <= 45 then
                local dot = lookVec:Dot(toBob.Unit)
                if dot > 0.5 then
                    local spotDist = currentSpot and (obj.Position - currentSpot.pos).Magnitude or 0
                    if not currentSpot or spotDist < 30 then
                        local score = currentSpot and spotDist or dist
                        if score < bestScore then
                            bestScore = score
                            bestBob = obj
                        end
                    end
                end
            end
        end
    end

    return bestBob
end

-- ================= STREFY LUCK =================
local function getBestFishingSpot()
    local spots = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("TextLabel") and d.Name == "TextLabel"
            and d.Parent and d.Parent.Name == "Gui" then
            local percent = d.Text:match("%+(%d+)%%")
            if percent then
                local luckVal = tonumber(percent)
                local part = d:FindFirstAncestorWhichIsA("BasePart")
                if part then
                    table.insert(spots, {
                        luck = luckVal,
                        pos = part.Position,
                        part = part,
                        name = string.format("+%d%% Luck", luckVal)
                    })
                end
            end
        end
    end
    if #spots == 0 then return nil end
    table.sort(spots, function(a, b)
        if a.luck == b.luck and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = lp.Character.HumanoidRootPart.Position
            return (a.pos - myPos).Magnitude < (b.pos - myPos).Magnitude
        end
        return a.luck > b.luck
    end)
    return spots[1]
end

local function isSpotAlive(spot)
    return spot and spot.part and spot.part.Parent
end

-- ================= MINIGRA =================
task.spawn(function()
    while true do
        task.wait(0.015)
        if running and not isSellingNow and not isCraftingNow and minigame then
            local ripple = minigame:FindFirstChild("Ripple")
            local reel   = minigame:FindFirstChild("Reel")

            if (ripple and ripple.Visible) or (reel and reel.Visible) then
                inMinigame = true
                lastFishActionTime = tick()
            end

            if ripple and ripple.Visible then
                setState("Ripple QTE!")
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                local fill = ripple:FindFirstChild("fill")
                local t = 0
                while ripple and ripple.Parent and t < 1.7 do
                    task.wait(0.02)
                    t = t + 0.02
                    if fill and fill.Size.X.Scale >= 0.86 then break end
                end
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.18)
            end

            if reel and reel.Visible then
                setState("Reel finish!")
                local btnPos = reel.AbsolutePosition + (reel.AbsoluteSize / 2)
                for _ = 1, 16 do
                    if not reel.Parent or not running then break end
                    VirtualInputManager:SendMouseButtonEvent(btnPos.X, btnPos.Y, 0, true, game, 1)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(btnPos.X, btnPos.Y, 0, false, game, 1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.03)
                end
                task.wait(0.5)
                inMinigame = false
            end
        end
    end
end)

-- OBSŁUGA WSZYSTKICH TYPÓW ŁUPÓW (RYBY, KONICZYNKI/CHARMY, ŻYCZENIA)
local function onLootCaught()
    currentCatches = currentCatches + 1
    lastFishActionTime = tick()
    inMinigame = false
    task.spawn(updateUIStatus)
end

if remotes then
    if remotes:FindFirstChild("fishing_caught_item") then
        remotes.fishing_caught_item.OnClientEvent:Connect(onLootCaught)
    end
    if remotes:FindFirstChild("fishing_caught_charm") then
        remotes.fishing_caught_charm.OnClientEvent:Connect(onLootCaught)
    end
    if remotes:FindFirstChild("fishing_caught_wish") then
        remotes.fishing_caught_wish.OnClientEvent:Connect(onLootCaught)
    end
end

-- ================= ZAMYKANIE OKIEN (Q) & WATCHDOG =================
local function isShopOpen()
    local fg = pg:FindFirstChild("fish_shop")
    if not fg or not isVisible(fg) then return false end
    local fs = fg:FindFirstChild("FishShop") or fg:FindFirstChild("strip_area", true)
    return fs ~= nil and isVisible(fs)
end

local function isArmoryOpen()
    local am = pg:FindFirstChild("armory_menu")
    if not am or not isVisible(am) then return false end
    local arm = am:FindFirstChild("ArmoryMenu") or am:FindFirstChild("enchant_stage", true)
    return arm ~= nil and isVisible(arm)
end

local function forceCloseGUI(guiType)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.06)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.2)

    if guiType == "shop" and isShopOpen() then
        local fg = pg:FindFirstChild("fish_shop")
        local close = fg and fg:FindFirstChild("close", true)
        local b = close and (close:FindFirstChild("button", true) or close:FindFirstChildWhichIsA("GuiButton", true))
        if b and isVisible(b) then clickGui(b) end
    elseif guiType == "armory" and isArmoryOpen() then
        local am = pg:FindFirstChild("armory_menu")
        local close = am and am:FindFirstChild("close", true)
        local b = close and (close:FindFirstChild("button", true) or close:FindFirstChildWhichIsA("GuiButton", true))
        if b and isVisible(b) then clickGui(b) end
    end
end

-- Watchdog: co 4 sekundy sprawdza czy okno sklepu lub kowala nie zostalo przypadkowo otwarte podczas lowienia
task.spawn(function()
    while true do
        task.wait(4)
        if running and not isSellingNow and not isCraftingNow then
            if isShopOpen() then
                forceCloseGUI("shop")
            end
            if isArmoryOpen() then
                forceCloseGUI("armory")
            end
        end
    end
end)

-- ================= AUTO-SELL =================
local function _performAutoSellInternal()
    setState("Sell: Cancelling cast...")

    if remotes and remotes:FindFirstChild("fishing_cancel") then
        pcall(function() remotes.fishing_cancel:FireServer() end)
    end
    task.wait(0.35)

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    disableHover()

    -- 1. Teleport do budki sprzedazy
    setState("Sell: Teleporting to shop...")
    hrp.CFrame = CFrame.new(FINN_POS)
    task.wait(0.65)

    -- 2. Otworz sklep (E)
    setState("Sell: Opening shop (E)...")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

    -- Czekaj na FishShop GUI
    setState("Sell: Waiting for shop UI...")
    local fishShop = nil
    local waitStart = tick()
    while tick() - waitStart < 3.5 do
        local fg = pg:FindFirstChild("fish_shop")
        if fg and isVisible(fg) then
            local fs = fg:FindFirstChild("FishShop") or fg:FindFirstChild("strip_area", true)
            if fs then
                fishShop = fg:FindFirstChild("FishShop") or fg
                break
            end
        end
        task.wait(0.2)
    end

    if not fishShop then
        setState("Sell: Shop UI not found â€” returning.")
        task.wait(0.8)
        return
    end

    task.wait(0.4)

    -- ── Pomocnik rozpoznawania kart przedmiotow ───────────────
    local function cardMatches(card, words)
        local function normalize(s)
            return (s or ""):lower():gsub("[%s_%-%(%)%[%]%d]", "")
        end

        local cName = normalize(card.Name)
        local nameMatch = true
        for _, w in ipairs(words) do
            if not cName:find(w) then
                nameMatch = false
                break
            end
        end
        if nameMatch then return true end

        local okAttr, attrs = pcall(function() return card:GetAttributes() end)
        if okAttr and attrs then
            for _, attrVal in pairs(attrs) do
                local sAttr = normalize(tostring(attrVal))
                local attrMatch = true
                for _, w in ipairs(words) do
                    if not sAttr:find(w) then
                        attrMatch = false
                        break
                    end
                end
                if attrMatch then return true end
            end
        end

        for _, d in ipairs(card:GetDescendants()) do
            local dName = normalize(d.Name)
            local dMatch = true
            for _, w in ipairs(words) do
                if not dName:find(w) then
                    dMatch = false
                    break
                end
            end
            if dMatch then return true end

            if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text and d.Text ~= "" then
                local dText = normalize(d.Text)
                local textMatch = true
                for _, w in ipairs(words) do
                    if not dText:find(w) then
                        textMatch = false
                        break
                    end
                end
                if textMatch then return true end
            end

            if (d:IsA("ImageLabel") or d:IsA("ImageButton")) and d.Image and d.Image ~= "" then
                local dImg = normalize(d.Image)
                local imgMatch = true
                for _, w in ipairs(words) do
                    if not dImg:find(w) then
                        imgMatch = false
                        break
                    end
                end
                if imgMatch then return true end
            end
        end

        return false
    end

    local function isPageCard(card)
        return cardMatches(card, {"page"})
    end

    local function isGoldenCodCard(card)
        if cardMatches(card, {"golden", "cod"}) then return true end
        if cardMatches(card, {"goldencod"}) then return true end
        if cardMatches(card, {"cod"}) then return true end
        return false
    end

    local function isGoldenToothCard(card)
        if cardMatches(card, {"golden", "tooth"}) then return true end
        if cardMatches(card, {"goldentooth"}) then return true end
        if cardMatches(card, {"tooth"}) then return true end
        return false
    end

    -- Pomocnik: Karty ryb w strip_area posortowane OD LEWEJ DO PRAWEJ
    local function getCards()
        local result = {}
        local stripArea = fishShop:FindFirstChild("strip_area", true)
        if stripArea then
            for _, ch in ipairs(stripArea:GetDescendants()) do
                if ch.Name:sub(1, 5) == "card_" and ch:IsA("GuiButton") and isVisible(ch) then
                    local skip = false
                    if toggles.keepPage and isPageCard(ch) then skip = true end
                    if toggles.keepGoldenCod and isGoldenCodCard(ch) then skip = true end
                    if toggles.keepGoldenTooth and isGoldenToothCard(ch) then skip = true end
                    if not skip then
                        table.insert(result, ch)
                    end
                end
            end
        end
        table.sort(result, function(a, b)
            return a.AbsolutePosition.X < b.AbsolutePosition.X
        end)
        return result
    end

    local function getCardCount(card)
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local n = (d.Text or ""):match("^x(%d+)")
                if n then return tonumber(n) end
            end
        end
        return 1
    end

    local function findSellButton(qty)
        local startT = tick()
        while tick() - startT < 1.0 do
            local actionAll = fishShop:FindFirstChild("action_sell_all", true)
            local actionOne = fishShop:FindFirstChild("action_sell", true)

            local btnAll = actionAll and (actionAll:FindFirstChild("body", true) or actionAll:FindFirstChildWhichIsA("GuiButton", true))
            local btnOne = actionOne and (actionOne:FindFirstChild("body", true) or actionOne:FindFirstChildWhichIsA("GuiButton", true))

            if qty > 1 then
                if btnAll and isVisible(btnAll) and isVisible(actionAll) then
                    return btnAll, "SELL ALL"
                elseif btnOne and isVisible(btnOne) and isVisible(actionOne) then
                    return btnOne, "SELL"
                end
            else
                if btnOne and isVisible(btnOne) and isVisible(actionOne) then
                    return btnOne, "SELL"
                end
            end
            task.wait(0.08)
        end
        return nil, nil
    end

    local function checkConfirm()
        local t0 = tick()
        while tick() - t0 < 0.35 do
            local sc = pg:FindFirstChild("sell_confirm", true)
            if sc and sc.Visible then
                setState("Sell: Confirming...")
                task.wait(0.06)

                local confirmFrame = sc:FindFirstChild("confirm", true)
                local confirmBtn = confirmFrame and (confirmFrame:FindFirstChild("body", true) or confirmFrame:FindFirstChildWhichIsA("TextButton", true))

                if confirmBtn then
                    clickGui(confirmBtn)
                    task.wait(0.12)
                    if sc.Visible then
                        clickGui(confirmBtn)
                        task.wait(0.12)
                    end
                end

                local hideT = tick()
                while sc.Visible and tick() - hideT < 0.8 do
                    task.wait(0.04)
                end
                return true
            end
            task.wait(0.04)
        end
        return false
    end

    -- 3. Glowna petla sprzedazy
    local maxIters = 80
    local iter = 0

    while iter < maxIters do
        iter = iter + 1
        local cards = getCards()
        if #cards == 0 then
            setState("Sell: All items sold!")
            break
        end

        local card = cards[1]
        local cardName = card.Name
        local qty = getCardCount(card)
        local cleanName = cardName:gsub("card_", "")
        setState(string.format("Sell: %s (x%d)", cleanName, qty))

        clickGui(card)
        task.wait(0.15)

        local sellBtn, sellMode = findSellButton(qty)
        if not sellBtn then
            clickGui(card)
            task.wait(0.15)
            sellBtn, sellMode = findSellButton(qty)
        end

        if sellBtn then
            setState(string.format("Sell: %s â€” %s", sellMode, cleanName))
            clickGui(sellBtn)
            task.wait(0.08)

            checkConfirm()

            local waitSoldT = tick()
            while tick() - waitSoldT < 0.8 do
                if not card.Parent or not card:IsDescendantOf(fishShop) then
                    break
                end
                task.wait(0.04)
            end
        else
            setState("Sell: No button found for " .. cleanName)
            task.wait(0.2)
            break
        end
    end

    -- 4. Zamknij sklep (klawisz Q)
    setState("Sell: Closing shop (Q)...")
    local closeTries = 0
    while isShopOpen() and closeTries < 5 do
        closeTries = closeTries + 1
        forceCloseGUI("shop")
        task.wait(0.25)
    end
    task.wait(0.2)

    currentCatches = 0
    updateUIStatus()
    setState("Sell: Done â€” resuming fishing.")
    task.wait(0.2)
end

local function performAutoSell()
    isSellingNow = true
    local ok, err = pcall(_performAutoSellInternal)
    if not ok then
        warn("[AutoFish] SELL ERROR: " .. tostring(err))
        setState("BŁĄD SELL: " .. tostring(err):sub(1, 35))
        task.wait(1.5)
    end
    isSellingNow = false
    lastFishActionTime = tick() -- Reset licznika czasu lowienia po sprzedazy
end

-- ================= AUTO-CRAFTING (PAGE -> BOOK) =================
local function findUnveilButton(armoryMenu)
    if not armoryMenu then return nil end
    local roll = armoryMenu:FindFirstChild("roll", true)
    if roll then
        local b = roll:FindFirstChild("body", true)
            or roll:FindFirstChildWhichIsA("GuiButton", true)
            or (roll:IsA("GuiButton") and roll)
        if b and isVisible(b) then return b end
    end
    -- Fallback: szukanie po tekscie
    for _, d in ipairs(armoryMenu:GetDescendants()) do
        if d:IsA("GuiButton") and isVisible(d) then
            local txt = (d:IsA("TextButton") and d.Text or "")
            for _, ch in ipairs(d:GetChildren()) do
                if ch:IsA("TextLabel") and ch.Text then
                    txt = txt .. " " .. ch.Text
                end
            end
            if txt:upper():find("UNVEIL") or txt:upper():find("BOOK") then
                return d
            end
        end
    end
    return nil
end

local function _performAutoCraftPagesInternal()
    setState("Craft: Cancelling cast...")

    if remotes and remotes:FindFirstChild("fishing_cancel") then
        pcall(function() remotes.fishing_cancel:FireServer() end)
    end
    task.wait(0.35)

    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    disableHover()

    -- 1. Teleport do NPC Magika
    setState("Craft: Teleporting to Magician...")
    hrp.CFrame = CFrame.new(MAGICIAN_POS, MAGICIAN_LOOK)
    task.wait(0.65)

    -- 2. Otworz dialog (E)
    setState("Craft: Opening menu (E)...")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.08)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

    -- Czekaj na ArmoryMenu
    setState("Craft: Waiting for Armory UI...")
    local armoryMenu = nil
    local waitStart = tick()
    while tick() - waitStart < 3.5 do
        local am = pg:FindFirstChild("armory_menu")
        if am and isVisible(am) then
            local arm = am:FindFirstChild("ArmoryMenu") or am:FindFirstChild("enchant_stage", true)
            if arm then
                armoryMenu = am:FindFirstChild("ArmoryMenu") or am
                break
            end
        end
        task.wait(0.2)
    end

    if not armoryMenu then
        setState("Craft: Armory UI not found â€” returning.")
        task.wait(0.8)
        return
    end

    task.wait(0.4)

    -- Pomocnik: odczyt stron bezposrednio z wallet w otwartym armory_menu
    -- (fishing_stash moze byc ukryty gdy armory jest otwarte)
    local function getPagesFromArmory()
        -- Priorytet: wallet.figure w otwartym armory
        local wallet = armoryMenu:FindFirstChild("wallet", true)
        if wallet then
            local fig = wallet:FindFirstChild("figure", true)
            if fig and fig.Text and tonumber(fig.Text) then
                return tonumber(fig.Text)
            end
            -- czasem jest w .label lub .value
            for _, d in ipairs(wallet:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text and tonumber(d.Text) then
                    return tonumber(d.Text)
                end
            end
        end
        -- Fallback: globalna funkcja
        return getPageCount()
    end

    -- 3. Petla zamiany stron na ksiazki (kazda ksiazka wymaga 8 stron)
    local craftIters = 0
    local maxCrafts = 30 -- Ograniczenie bezpieczenstwa

    while craftIters < maxCrafts do
        -- Odczytaj strony z GUI armory (nie ze stashu)
        local pagesLeft = getPagesFromArmory()
        setState(string.format("Craft: Pages remaining: %d", pagesLeft))

        if pagesLeft < 8 then
            setState(string.format("Craft: Only %d pages left (< 8) â€” done!", pagesLeft))
            break
        end

        craftIters = craftIters + 1
        setState(string.format("Craft: Making book #%d  (%d pages left)", craftIters, pagesLeft))

        local unveilBtn = findUnveilButton(armoryMenu)
        if not unveilBtn then
            task.wait(0.3)
            unveilBtn = findUnveilButton(armoryMenu)
        end

        if not unveilBtn then
            setState("Craft: Unveil Book button not found!")
            task.wait(0.4)
            break
        end

        -- Klikniecie 1: UNVEIL BOOK
        clickGui(unveilBtn)
        task.wait(0.4)

        -- Klikniecie 2: potwierdzenie UNVEIL BOOK (przycisk moze sie odswiezac)
        local unveilBtn2 = findUnveilButton(armoryMenu) or unveilBtn
        clickGui(unveilBtn2)

        -- Czekaj az gra przetworzy craft (liczba stron powinna spasc)
        local prevPages = pagesLeft
        local waitCraft = tick()
        while tick() - waitCraft < 3.0 do
            task.wait(0.15)
            local nowPages = getPagesFromArmory()
            if nowPages < prevPages then
                break -- craft sie udal, strony sie zmniejszyly
            end
        end

        task.wait(0.2)
    end

    -- 4. Zamknij ArmoryMenu (klawisz Q)
    setState("Craft: Closing menu (Q)...")
    local closeTries = 0
    while isArmoryOpen() and closeTries < 5 do
        closeTries = closeTries + 1
        forceCloseGUI("armory")
        task.wait(0.25)
    end
    task.wait(0.2)

    updateUIStatus()
    setState("Craft: Done â€” resuming fishing.")
    task.wait(0.2)
end

local function performAutoCraftPages()
    isCraftingNow = true
    local ok, err = pcall(_performAutoCraftPagesInternal)
    if not ok then
        warn("[AutoFish] CRAFT ERROR: " .. tostring(err))
        setState("BŁĄD CRAFT: " .. tostring(err):sub(1, 35))
        task.wait(1.5)
    end
    isCraftingNow = false
    lastFishActionTime = tick() -- Reset licznika czasu lowienia po craftingu
end

-- ================= RZUT WEDKA =================
local function doCast()
    local cam = Workspace.CurrentCamera
    local vp = cam.ViewportSize
    local midX = math.floor(vp.X / 2)
    local midY = math.floor(vp.Y / 2)
    setState("Casting rod...")
    VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, true, game, 1)
    task.wait(0.62)
    VirtualInputManager:SendMouseButtonEvent(midX, midY, 0, false, game, 1)
    lastFishActionTime = tick()
end

-- ================= GLOWNA PETLA (FSM) =================
local TARGET_CAST_DISTANCE = 20

local function autoFishLoop()
    -- Na starcie sprawdz stan plecaka i stron
    updateUIStatus()
    lastFishActionTime = tick()

    if toggles.autoSell then
        local full = isBagFull()
        if full then performAutoSell() end
    end

    local currentFarmedSpot = nil

    while running do
        task.wait(0.12)

        -- Jesli trwa minigra, sprzedawanie lub crafting - nie rob nic
        if inMinigame or isSellingNow or isCraftingNow then
            continue
        end

        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- 1. Sprawdz czy nasz wlasny splawik jest w wodzie
        local myBob = getMyBobber(currentFarmedSpot)
        local inWater = (myBob ~= nil)

        if inWater then
            -- Watchdog: jesli przez 30s nie zlowi zadnej ryby, uznaj ze splawik nie jest zarzucony!
            local elapsedNoFish = tick() - lastFishActionTime
            if elapsedNoFish > 30 then
                setState("No bite for 30s â€” resetting & reteleporting...")
                bobberLbl.Text = "Wedka w wodzie: NIE (Timeout 30s - reTP)"
                bobberLbl.TextColor3 = Color3.fromRGB(255, 140, 0)

                -- Anuluj zarzucenie
                if remotes and remotes:FindFirstChild("fishing_cancel") then
                    pcall(function() remotes.fishing_cancel:FireServer() end)
                end
                task.wait(0.4)

                -- Wymus ponowne odszukanie i teleport do najlepszej strefy Luck
                currentFarmedSpot = getBestFishingSpot()
                if currentFarmedSpot and toggles.autoTp then
                    setState("Timeout â€” reteleporting to: " .. currentFarmedSpot.name)
                    local char2 = lp.Character
                    local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
                    if hrp2 then
                        local spotPos = currentFarmedSpot.pos
                        local offsetDir = Vector3.new(0, 0, 1)
                        local diff = hrp2.Position - spotPos
                        if diff.Magnitude > 2 then
                            offsetDir = Vector3.new(diff.X, 0, diff.Z).Unit
                        end
                        local hoverPos = spotPos + offsetDir * TARGET_CAST_DISTANCE
                        hoverPos = Vector3.new(hoverPos.X, spotPos.Y + 2.5, hoverPos.Z)
                        hrp2.CFrame = CFrame.new(hoverPos, spotPos)
                        enableHover(hrp2)
                        pcall(function()
                            local cam = Workspace.CurrentCamera
                            local camEye = hoverPos + Vector3.new(0, 3.5, 0) - offsetDir * 4.5
                            cam.CFrame = CFrame.new(camEye, spotPos)
                        end)
                    end
                    task.wait(0.3)
                end

                lastFishActionTime = tick()
                continue
            end

            bobberLbl.Text = string.format("Rod in water: YES  (%ds / 30s)", math.floor(elapsedNoFish))
            bobberLbl.TextColor3 = Color3.fromRGB(120, 255, 120)
            setState(string.format("Waiting for bite...  %ds", math.floor(elapsedNoFish)))
            continue
        else
            bobberLbl.Text = "Rod in water: NO"
            bobberLbl.TextColor3 = Color3.fromRGB(255, 120, 120)
        end

        -- ═══════════════ DECISION POINT (rod out of water) ═══════════════
        -- Rod is reeled in, no minigame active. Check if a side-action is needed.

        -- PRIORITY 1: Craft Pages → Books (Pages ≥ 32)
        if toggles.autoCraft and not isCraftingNow and not isSellingNow then
            local pages = getPageCount()
            if pages >= PAGE_CRAFT_THRESHOLD then
                performAutoCraftPages()
                currentFarmedSpot = nil
                continue
            end
        end

        -- PRIORITY 2: Auto-Sell when bag ≥ 90%
        if toggles.autoSell and not isSellingNow and not isCraftingNow then
            local full = isBagFull()
            if full then
                performAutoSell()
                currentFarmedSpot = nil
                continue
            end
        end

        -- 2. Wyszukaj i ustaw strefe z najlepszym Luckiem
        if not isSpotAlive(currentFarmedSpot) then
            currentFarmedSpot = getBestFishingSpot()
        end

        if currentFarmedSpot then
            targetLbl.Text = "Zone: " .. currentFarmedSpot.name

            if toggles.autoTp then
                local spotPos = currentFarmedSpot.pos
                local offsetDir = Vector3.new(0, 0, 1)
                local diff = hrp.Position - spotPos
                if diff.Magnitude > 2 then
                    offsetDir = Vector3.new(diff.X, 0, diff.Z).Unit
                end
                local hoverPos = spotPos + offsetDir * TARGET_CAST_DISTANCE
                hoverPos = Vector3.new(hoverPos.X, spotPos.Y + 2.5, hoverPos.Z)
                hrp.CFrame = CFrame.new(hoverPos, spotPos)
                enableHover(hrp)

                -- Nakieruj kamere DOKLADNIE w srodek strefy Luck w wodzie
                pcall(function()
                    local cam = Workspace.CurrentCamera
                    local camEye = hoverPos + Vector3.new(0, 3.5, 0) - offsetDir * 4.5
                    cam.CFrame = CFrame.new(camEye, spotPos)
                end)
            end
        end

        task.wait(0.2)

        -- 3. Upewnij sie, ze wedka jest wyposazona
        local hasRod = char:FindFirstChild("held_fishing_rod")
        if not hasRod then
            local fishSlot = pg:FindFirstChild("toolbar")
                and pg.toolbar:FindFirstChild("ToolbarHUD", true)
                and pg.toolbar.ToolbarHUD:FindFirstChild("slot_fish", true)
            if fishSlot and fishSlot:IsA("GuiButton") then
                clickGui(fishSlot)
            end
            task.wait(0.3)
        end

        -- 4. Rzut wedka prosto w strefe Luck
        doCast()
        task.wait(1.4)
    end

    disableHover()
end

-- START / STOP
toggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
        startStroke.Color = Color3.fromRGB(255, 80, 80)
        setState("Running")
        task.spawn(autoFishLoop)
    else
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 155, 70)
        startStroke.Color = Color3.fromRGB(0, 255, 100)
        setState("Stopped")
        disableHover()
    end
end)