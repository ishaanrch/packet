local function readLink(url)
    return game:HttpGet(url):gsub('\n', '')
end

local packetVersion = readLink('https://github.com/ishaanrch/packet/raw/refs/heads/main/version')
local packetFolder = 'Packet'..packetVersion
local assetsFolder = packetFolder..'/Assets'
local gamesFolder = packetFolder..'/Games'

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

local function notify(title, description, icon)
    cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {Title = title, Text = description, Duration = 5, Icon = icon})
end

local function packetLauncher(placeId)
    local path = gamesFolder..'/'..placeId..'.lua'
    local url = 'https://github.com/ishaanrch/packet/raw/refs/heads/main/'..placeId..'.lua'
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

    loadstring(readfile(path))()
end

if gameScript then
    notify('Supported game!', 'Packet supports this game, running...', 'rbxassetid://14562122532')
    packetLauncher(game.PlaceId)
else
    notify('Game isn\'t supported!', 'Packet doesn\'t support this game, running universal...', 'rbxassetid://18797440055')
    packetLauncher('universal')
end
