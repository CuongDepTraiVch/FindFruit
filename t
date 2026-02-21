-- [[ DUC CUONG MODDER (Find Fruit) - V61 SUPREME ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- === ⚙️ CẤU HÌNH TELEGRAM ===
local BOT_TOKEN = "8485723489:AAH0MVMn1Niy9BapjUr7FeFpLBeIXtYybQU" 
local CHAT_ID = "-1003608887450"

-- Hàm request tương thích mọi Executor (Delta, Codex, Arceus, Fluxus...)
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- === 1. GIAO DIỆN UI 250x250 ===
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 250)
Main.Position = UDim2.new(0.5, -125, 0.4, -125)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 127)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Duc Cuong Modder\n(Find Fruit)"
Title.TextColor3 = Color3.fromRGB(0, 255, 127)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1

local PlayerName = Instance.new("TextLabel", Main)
PlayerName.Size = UDim2.new(1, 0, 0, 30)
PlayerName.Position = UDim2.new(0, 0, 0.25, 0)
PlayerName.Text = "👤 Player: " .. LocalPlayer.Name
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.Font = Enum.Font.GothamMedium
PlayerName.TextSize = 12
PlayerName.BackgroundTransparency = 1

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(0.9, 0, 0, 100)
Status.Position = UDim2.new(0.05, 0, 0.45, 0)
Status.Text = "Statue: ⚙️ Đang khởi động..."
Status.TextColor3 = Color3.fromRGB(0, 255, 255)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 13
Status.TextWrapped = true
Status.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 8)

-- === 2. AUTO JOIN PIRATES ===
task.spawn(function()
    Status.Text = "Statue: 🏴‍☠️ Đang chọn phe Hải Tặc..."
    pcall(function()
        if not LocalPlayer.Team or LocalPlayer.Team.Name ~= "Pirates" then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
        end
    end)
    task.wait(1)
end)

-- === 3. GỬI TELEGRAM (SỬ DỤNG EXECUTOR REQUEST) ===
local function SendToTelegram(fruitName)
    if not httprequest or BOT_TOKEN == "" or CHAT_ID == "" then return end
    local msg = "🍎 **DUC CUONG MODDER**\n👤 Player: `" .. LocalPlayer.Name .. "`\n✨ Vừa nhặt được: **" .. fruitName .. "**"
    
    pcall(function()
        httprequest({
            Url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                chat_id = CHAT_ID,
                text = msg,
                parse_mode = "Markdown"
            })
        })
    end)
end

-- === 4. RANDOM FAST HOP ===
local function FastHop()
    Status.Text = "Statue: 🚀 Đang Random Hop Server..."
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    pcall(function()
        local ApiUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local Response = game:HttpGet(ApiUrl)
        local Servers = HttpService:JSONDecode(Response).data
        
        local validServers = {}
        for _, s in pairs(Servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(validServers, s.id)
            end
        end
        
        if #validServers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, validServers[math.random(1, #validServers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

-- === 5. TÌM VÀ CẤT TRÁI ===
local function HuntFruit()
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") and (item.Name:find("Fruit") or item.Name:find("Trái")) then
            local handle = item:FindFirstChild("Handle")
            if handle then
                local fName = item.Name
                Status.Text = "Statue: ✨ Bắt được " .. fName .. "!"
                Status.TextColor3 = Color3.fromRGB(0, 255, 127)
                
                local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local Root = Char:WaitForChild("HumanoidRootPart")
                
                -- Ép vị trí liên tục để nhặt (Bypass Anti-cheat)
                for i = 1, 15 do
                    Root.CFrame = handle.CFrame
                    task.wait(0.1)
                end
                
                -- Gửi Telegram và cất kho
                SendToTelegram(fName)
                Status.Text = "Statue: 📦 Đang cất kho " .. fName .. "..."
                task.wait(0.5)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", fName, item)
                
                task.wait(1)
                return true
            end
        end
    end
    return false
end

-- === VÒNG LẶP CHÍNH ===
task.spawn(function()
    while task.wait(2) do
        local found = HuntFruit()
        if not found then
            Status.Text = "Statue: ⌛ Server không có trái. Chuẩn bị Hop..."
            Status.TextColor3 = Color3.fromRGB(200, 200, 200)
            task.wait(1.5)
            FastHop()
            break -- Dừng script ở server cũ để chờ Teleport
        end
    end
end)
