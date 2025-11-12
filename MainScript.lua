local function readLink(url)
    return game:HttpGet(url):gsub('\n','')
end

local function deleteNotificationFrames()
    pcall(function()
        for _, v in ipairs(cloneref(game:GetService('CoreGui')):GetChildren()) do
            if v.Name == 'notificationGui' and v:IsA('ScreenGui') then
                v:Destroy()
            end
        end
    end)
end

deleteNotificationFrames()

local notificationGui = Instance.new('ScreenGui')
notificationGui.Name = 'notificationGui'
notificationGui.IgnoreGuiInset = true
notificationGui.Parent = cloneref(game:GetService('CoreGui'))
notificationGui.Enabled = true

local notificationframe = Instance.new('Frame')
notificationframe.Name = 'notificationframe'
notificationframe.Parent = notificationGui
notificationframe.BackgroundTransparency = 1
notificationframe.Size = UDim2.new(1,0,1,0)

local padding = Instance.new('UIPadding')
padding.Parent = notificationframe
padding.PaddingBottom = UDim.new(0,50)
padding.PaddingLeft = UDim.new(0,20)
padding.PaddingRight = UDim.new(0,20)
padding.PaddingTop = UDim.new(0,20)

local listlayout = Instance.new('UIListLayout')
listlayout.Parent = notificationframe
listlayout.SortOrder = Enum.SortOrder.LayoutOrder
listlayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listlayout.Padding = UDim.new(0,10)

local function notify(titleText, descriptionText, duration)
    local notif = Instance.new('Frame')
    notif.BackgroundColor3 = Color3.fromRGB(25,25,25)
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0,327,0,79)
    notif.AnchorPoint = Vector2.new(0.5,0.5)
    notif.Position = UDim2.new(0,0,0.85,0)
    notif.Parent = notificationframe

    local ucorner = Instance.new('UICorner')
    ucorner.CornerRadius = UDim.new(0,4)
    ucorner.Parent = notif

    local title = Instance.new('TextLabel')
    title.Parent = notif
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0.03,0,0,0)
    title.Size = UDim2.new(0,295,0,37)
    title.Font = Enum.Font.Gotham
    title.TextColor3 = Color3.fromRGB(255,0,0)
    title.TextScaled = true
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = titleText

    local description = Instance.new('TextLabel')
    description.Parent = notif
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0.03,0,0.54,0)
    description.Size = UDim2.new(0,295,0,28)
    description.Font = Enum.Font.Gotham
    description.TextColor3 = Color3.fromRGB(240,240,240)
    description.TextScaled = true
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Text = descriptionText
    description.TextTransparency = 0.3

    local bar = Instance.new('Frame')
    bar.Parent = notif
    bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
    bar.BackgroundTransparency = 0.4
    bar.Position = UDim2.new(0,0,0.924,0)
    bar.Size = UDim2.new(1,0,0,6)

    local barCorner = Instance.new('UICorner')
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

local packetVersion = readLink('https://github.com/ishaanrch/packet/raw/refs/heads/main/version')
local packetFolder = 'Packet'..packetVersion
local assetsFolder = packetFolder..'/Assets'
local gamesFolder = packetFolder..'/Games'

for _, folder in ipairs(listfiles('')) do
    if folder:find('Packet') then
        if not folder:find(packetVersion) then
            if not isfile(folder..'/INVALID_VERSION.TXT') then
                writefile(folder..'/INVALID_VERSION.TXT', game:HttpGet('https://github.com/ishaanrch/packet/raw/refs/heads/main/invalidations/INVALID_ERROR.TXT'))
            end
        end
    end
end

local packetFiles = {
    ['Assets/Packet.png'] = game:HttpGet('https://github.com/ishaanrch/packet/blob/main/Assets/Packet.png?raw=true')
}

for _, folder in ipairs({packetFolder, assetsFolder, gamesFolder}) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

for fileName, fileContents in pairs(packetFiles) do
    local filePath = packetFolder..'/'..fileName
    if not isfile(filePath) or readfile(filePath) ~= fileContents then
        writefile(filePath, fileContents)
    end
end

if not isfile(packetFolder..'/keybind.txt') then
    writefile(packetFolder..'/keybind.txt', 'T')
end

local success, result = pcall(function()
    return game:HttpGet('https://github.com/ishaanrch/packet/raw/refs/heads/main/'..tostring(game.PlaceId)..'.lua')
end)

local gameScript = success and result or nil

local function notifySys(title, description, icon)
    cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {Title = title, Text = description, Duration = 5, Icon = icon})
end

local run = function(fn, dur)
    local s, e = pcall(fn)
    if not s then
        notify('Runtime Error', tostring(e), dur or 60)
    end
end

local function packetLauncher(placeId)
    local path = gamesFolder..'/'..placeId..'.lua'
    local url = 'https://github.com/ishaanrch/packet/raw/refs/heads/main/Games/'..placeId..'.lua'
    local watermark = '--This watermark is here for this file to automatically update if any changes are made to it on the github, if deleted, this watermark will no longer update this file.\n'
    local shouldUpdate = false
    if isfile(path) then
        local content = readfile(path)
        if content:find('^%-%-This watermark is here for this file to automatically update') then
            shouldUpdate = true
        end
    else
        shouldUpdate = true
    end
    if shouldUpdate then
        local newData = watermark..game:HttpGet(url)
        writefile(path, newData)
    end
    run(function()
        loadstring(readfile(path))()
    end)
end

if gameScript then
    notifySys('Supported game!', 'Packet supports this game, running...', 'rbxassetid://14562122532')
    packetLauncher(game.PlaceId)
else
    notifySys('Game isn\'t supported!', 'Packet doesn\'t support this game, running universal...', 'rbxassetid://18797440055')
    packetLauncher('universal')
end
