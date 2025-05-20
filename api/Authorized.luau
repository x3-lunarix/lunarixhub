
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer


local webhook_url = "https://discord.com/api/webhooks/1374227193634226187/_6RBMiT2ZzbJ-60bqmM67MReoHCuK3P5Uoxmoq1sTqDDuv19lLvxmOuIBM1yTLHv7hcQ" 
if not getfenv or not pcall(function() return getfenv(0) end) then
    Player:Kick("Tampering Detected - Environment Access Blocked")
    return
end

local integrityCheck = "lunarix"
if integrityCheck ~= "lunarix" then
    while true do end 
end

for i = 0, 100, math.random(5, 8) do
    task.wait(0.03)
    print("Verifying Devices ///// " .. i .. "%")
end

local function getExecutor()
    if identifyexecutor then return identifyexecutor()
    elseif getexecutor then return getexecutor()
    elseif syn then return nil
    else return "Unknown" end
end

local function getHWID()
    local http_request = syn and syn.request or request or http_request
    if not http_request then return "Unavailable" end

    local success, response = pcall(function()
        return http_request({ Url = "https://httpbin.org/get", Method = "GET" })
    end)

    if success and response and response.Body then
        local data = HttpService:JSONDecode(response.Body)
        return data.headers and data.headers["Syn-Fingerprint"] or "No Fingerprint"
    else
        return "Request Failed"
    end
end
local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

if not game:FindFirstChild("__LOADER_ENV") then
    Player:Kick("Unauthorized Access – Loader Missing")
    return
end

local username = Player.Name
local executor = getExecutor()
local hwid = getHWID()
local time = os.date("%Y-%m-%d %H:%M:%S")

print("╔══════════════════════════════════════════════╗")
print("║            Lunarix Verification              ║")
print("╠══════════════════════════════════════════════╣")
print("║ User       : " .. username)
print("║ Game       : " .. gameName)
print("║ HWID       : " .. hwid)
print("║ Status     : Verification Successful         ║")
print("╚══════════════════════════════════════════════╝")

if webhook_url and syn and syn.request then
    pcall(function()
        local data = {
            content = "**Lunarix Execution Log**",
            embeds = {{
                title = "Lunarix Execution Report",
                color = tonumber(0x5b6aff),
                fields = {
                    { name = "Username", value = username, inline = true },
                    { name = "Executor", value = executor, inline = true },
                    { name = "HWID", value = hwid, inline = false },
                    { name = "Game", value = gameName, inline = true },
                    { name = "Time", value = time, inline = true },
                },
                footer = { text = "Protected by Lunarix API" }
            }}
        }

        syn.request({
            Url = webhook_url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end
