local function readLink(url)
    return game:HttpGet(url):gsub('\n', '')
end

local packetVersion = readLink('https://github.com/ishaanrch/packet/raw/refs/heads/main/version')
local packetFolder = 'Packet'..packetVersion
local assetsFolder = packetFolder..'/Assets'
local gamesFolder = packetFolder..'/Games'

local cloneref = cloneref or function(obj)
    return obj
end

local virtualInput = cloneref(game:GetService('VirtualInputManager'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local coreGui = cloneref(game:GetService('CoreGui'))
local userInputService = cloneref(game:GetService('UserInputService'))
local runService = cloneref(game:GetService('RunService'))

local keyMapping = {
    ['1'] = Enum.KeyCode.One,
    ['2'] = Enum.KeyCode.Two,
    ['3'] = Enum.KeyCode.Three,
    ['4'] = Enum.KeyCode.Four,
    ['5'] = Enum.KeyCode.Five,
    ['6'] = Enum.KeyCode.Six,
    ['7'] = Enum.KeyCode.Seven,
    ['8'] = Enum.KeyCode.Eight,
    ['9'] = Enum.KeyCode.Nine,
    ['0'] = Enum.KeyCode.Zero
}

local function hitKey(key, releaseDelay)
    local keyEnum = keyMapping[tostring(key)] or key
    if keyEnum then
        virtualInput:SendKeyEvent(true,keyEnum,false,game)
        task.wait(tonumber(releaseDelay) or 0.1)
        virtualInput:SendKeyEvent(false,keyEnum,false,game)
    end
end

raldicrackhouse = {
    Remotes = replicatedStorage.Remotes
}

for _, oldKavo in ipairs(coreGui:GetChildren()) do
    if oldKavo:IsA('ScreenGui') and oldKavo:FindFirstChild('Main') then
        oldKavo:Destroy()
    end
end

if not isfile(packetFolder..'/theme.txt') then
    local themeUrl = game:HttpGet('https://github.com/ishaanrch/packet/raw/refs/heads/main/defaultTheme'):gsub('\n', '')
    writefile(packetFolder..'/theme.txt', themeUrl)
end

local theme = readfile(packetFolder..'/theme.txt')

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Packet ("..packetVersion..")",theme or 'Midnight')

local kavo
repeat
    for _, gui in ipairs(coreGui:GetChildren()) do
        if gui:IsA('ScreenGui') and gui:FindFirstChild('Main') then
            kavo = gui
            break
        end
    end
    task.wait()
until kavo

repeat
    kavo.Enabled = false
    task.wait()
until not kavo.Enabled

kavo.Name = 'Packet'

local function toggleOverlay()
    kavo.Enabled = not kavo.Enabled
end

local notificationGui = Instance.new('ScreenGui')
notificationGui.Name = 'notificationGui'
notificationGui.IgnoreGuiInset = true
notificationGui.Parent = kavo
notificationGui.Enabled = true

local notificationframe = Instance.new("Frame")
notificationframe.Name = "notificationframe"
notificationframe.Parent = notificationGui
notificationframe.BackgroundTransparency = 1
notificationframe.Size = UDim2.new(1,0,1,0)

local padding = Instance.new("UIPadding")
padding.Parent = notificationframe
padding.PaddingBottom = UDim.new(0,50)
padding.PaddingLeft = UDim.new(0,20)
padding.PaddingRight = UDim.new(0,20)
padding.PaddingTop = UDim.new(0,20)

local listlayout = Instance.new("UIListLayout")
listlayout.Parent = notificationframe
listlayout.SortOrder = Enum.SortOrder.LayoutOrder
listlayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listlayout.Padding = UDim.new(0,10)

local function notify(titleText, descriptionText, duration)
    local mainFrame = kavo:FindFirstChild('Main') or kavo:FindFirstChild('MainFrame')
    if not mainFrame then return end
    local header = mainFrame:FindFirstChild('MainHeader')
    if not header then return end

    local uistroke = Instance.new('UIStroke')

    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = header.BackgroundColor3
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0,327,0,79)
    notif.AnchorPoint = Vector2.new(0.5,0.5)
    notif.Position = UDim2.new(0,0,0.85,0)
    notif.Parent = notificationframe

    uistroke.Parent = notif

    local ucorner = Instance.new("UICorner")
    ucorner.CornerRadius = UDim.new(0,4)
    ucorner.Parent = notif

    local title = Instance.new("TextLabel")
    title.Parent = notif
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0.03,0,0,0)
    title.Size = UDim2.new(0,295,0,37)
    title.Font = Enum.Font.Gotham
    title.TextColor3 = header.title.TextColor3
    title.TextScaled = true
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = titleText

    local description = Instance.new("TextLabel")
    description.Parent = notif
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0.03,0,0.54,0)
    description.Size = UDim2.new(0,295,0,28)
    description.Font = Enum.Font.Gotham
    description.TextColor3 = header.title.TextColor3
    description.TextScaled = true
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Text = descriptionText
    description.TextTransparency = 0.3

    local bar = Instance.new("Frame")

    uistroke.Thickness = 1.5

    bar.Parent = notif
    local suc, res = pcall(function()
        bar.BackgroundColor3 = kavo.Main.MainSide.tabFrames.OverlayTabButton.BackgroundColor3
        uistroke.Color = kavo.Main.MainSide.tabFrames.OverlayTabButton.BackgroundColor3
    end)
    if not suc then
        uistroke.Color = Color3.fromRGB(255,255,255)
        bar.BackgroundColor3 = Color3.fromRGB(255,255,255)
    end
    bar.Position = UDim2.new(0,0,0.943,0)
    bar.Size = UDim2.new(1,0,0,6)

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0,4)
    barCorner.Parent = bar

    coroutine.wrap(function()
        local start = tick()
        while tick()-start < duration do
            local pct = 1-(tick()-start)/duration
            bar.Size = UDim2.new(pct,0,0,6)
            task.wait()
        end
        notif:Destroy()
    end)()
end

for _, kavoElement in ipairs(kavo:GetDescendants()) do
    pcall(function()
        if kavoElement.Modal ~= nil or not kavoElement.Modal then
            kavoElement.Modal = true
        end
    end)
end

local function reloadGui()
    loadstring(tostring(readfile(packetFolder..'/MainScript.lua')))()
end

if userInputService.TouchEnabled then
    local function addUIScaling(target, scaling)
        local uiscale = Instance.new('UIScale')
        uiscale.Parent = target
        uiscale.Scale = scaling
    end

    addUIScaling(notificationframe,0.8)
    local mainFrame = kavo:FindFirstChild('Main') or kavo:FindFirstChild('MainFrame')
    if mainFrame then
        mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
        mainFrame.Position = UDim2.new(0.5,0,0.5,0)
        addUIScaling(mainFrame,0.65)
    end

    local mobileGui = Instance.new('ScreenGui')
    mobileGui.Name = 'mobileGui'
    mobileGui.Parent = kavo

    local packetToggle = Instance.new("ImageButton")
    local corners = Instance.new("UICorner")

    packetToggle.Name = "packetToggle"
    packetToggle.Draggable = true
    packetToggle.Active = true
    packetToggle.Parent = mobileGui
    if mainFrame and mainFrame:FindFirstChild('MainHeader') then
        packetToggle.BackgroundColor3 = mainFrame.MainHeader.BackgroundColor3
    end
    packetToggle.BorderColor3 = Color3.fromRGB(0,0,0)
    packetToggle.BorderSizePixel = 0
    packetToggle.Position = UDim2.new(0.3,0,0.5,0)
    packetToggle.Size = UDim2.new(0,100,0,100)
    packetToggle.AutoButtonColor = false
    packetToggle.Modal = true
    packetToggle.Image = getcustomasset(assetsFolder..'/packet.png')

    packetToggle.MouseButton1Up:Connect(toggleOverlay)

    corners.CornerRadius = UDim.new(0,4)
    corners.Parent = packetToggle
    addUIScaling(packetToggle,0.6)

    task.spawn(function() repeat task.wait() until kavo.Main.MainSide.tabFrames.OverlayTabButton notify('Packet loaded!','Toggle gui overlay with the packet button',7) end)
    kavo.Enabled = true
else
    local keybind = tostring(readfile(packetFolder..'/keybind.txt'))
    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode[keybind] then
            pcall(function()
                toggleOverlay()
            end)
        end
    end)
    task.spawn(function() repeat task.wait() until kavo.Main.MainSide.tabFrames.OverlayTabButton notify('Packet loaded!','Toggle gui overlay with '..keybind,7) end)
    kavo.Enabled = true
end

local uistroke = Instance.new('UIStroke')
uistroke.Thickness = 1.5
uistroke.Parent = kavo.Main

task.spawn(function()
    repeat
        pcall(function()
            uistroke.Color = kavo.Main.infoContainer:GetChildren()[3].BackgroundColor3
        end)
        task.wait()
    until uistroke.Color == kavo.Main.infoContainer:GetChildren()[3].BackgroundColor3
end)

local universalTab = Window:NewTab("Universal")
local overlayTab = Window:NewTab("Overlay")

local universal = universalTab:NewSection("All universal exploits in one tab")
local overlay = overlayTab:NewSection("Change how the packet gui looks to your liking")

overlay:NewDropdown("Theme", "Chooses your liking of theme.", {
    "LightTheme",
    "DarkTheme",
    "GrapeTheme",
    "BloodTheme",
    "Ocean",
    "Midnight",
    "Sentinel",
    "Synapse"
}, function(theme)
    pcall(function()
        if not isfolder(packetFolder) then
            makefolder(packetFolder)
        end
        writefile(packetFolder..'/theme.txt', theme)
        notify('Theme changed!', 'Restart packet for the chosen theme', 8)
    end)
end)

local function isMobile()
    if userInputService.TouchEnabled then
        return true
    else
        return false
    end
end

if not isMobile() then
    universal:NewTextBox("Change Keybind", "Changes the overlay toggle keybind", function(val)
        local key = tostring(string.upper(val:sub(0,1)))
	    writefile(packetFolder..'/keybind.txt', key)
        keybind = key
        notify('Changed keybind! (Restart)', 'Toggle the overlay with: '..key)
    end)
end

universal:NewButton('Reload Packet', 'Restarts packet (make sure modules are off!)', function()
    reloadGui()
end)
