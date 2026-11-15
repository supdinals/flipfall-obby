-- FLIPFALL game service: leaderstats, checkpoints, kill bricks, flip pads,
-- moving platforms, run timer and the finish line.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local FlipService = require(script.Parent.FlipService)

local GameService = {}
local respawnPoint = {} -- [player] = CFrame
local padDebounce = {} -- [player] = time of last pad trigger

local function onCheckpoint(player, pad)
	local stage = pad:GetAttribute("Stage")
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end
	local stageValue = stats:FindFirstChild("Stage")
	if stageValue and stage > stageValue.Value then
		stageValue.Value = stage
		if stage == 1 and not player:GetAttribute("RunStart") then
			player:SetAttribute("RunStart", workspace:GetServerTimeNow())
		end
	end
	respawnPoint[player] = pad.CFrame * CFrame.new(0, 4, 0)
end

local function onFinish(player, gameEvent)
	local start = player:GetAttribute("RunStart")
	if not start then return end
	local elapsed = workspace:GetServerTimeNow() - start
	player:SetAttribute("RunStart", nil)
	local stats = player:FindFirstChild("leaderstats")
	local best = stats and stats:FindFirstChild("BestTime")
	if best and (best.Value == 0 or elapsed < best.Value) then
		best.Value = math.floor(elapsed)
	end
	gameEvent:FireClient(player, "win", elapsed)
end

local function wirePart(descendant, gameEvent)
	if not descendant:IsA("BasePart") then return end
	if descendant:GetAttribute("IsCheckpoint") then
		descendant.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then onCheckpoint(player, descendant) end
		end)
	elseif descendant:GetAttribute("IsKill") then
		descendant.Touched:Connect(function(hit)
			local humanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end)
	elseif descendant:GetAttribute("IsFlipPad") then
		descendant.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player then return end
			local now = os.clock()
			if padDebounce[player] and now - padDebounce[player] < 0.6 then return end
			padDebounce[player] = now
			local target = descendant:GetAttribute("FlipTarget")
			if target == "up" then
				FlipService.SetFlip(player, true)
			elseif target == "down" then
				FlipService.SetFlip(player, false)
			else
				FlipService.Toggle(player)
			end
		end)
	elseif descendant:GetAttribute("IsFinish") then
		descendant.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then onFinish(player, gameEvent) end
		end)
	end
end

local function onPlayerAdded(player, gameEvent)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Parent = stats
	local best = Instance.new("IntValue")
	best.Name = "BestTime"
	best.Parent = stats
	stats.Parent = player
	respawnPoint[player] = CFrame.new(0, 5, 0)

	player.CharacterAdded:Connect(function(character)
		FlipService.Reset(player)
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if root and respawnPoint[player] then
			task.wait(0.1)
			character:PivotTo(respawnPoint[player])
		end
	end)
end

function GameService.Init(course, gameEvent)
	for _, descendant in course:GetDescendants() do
		wirePart(descendant, gameEvent)
	end

	Players.PlayerAdded:Connect(function(player)
		onPlayerAdded(player, gameEvent)
	end)
	for _, player in Players:GetPlayers() do
		onPlayerAdded(player, gameEvent)
	end
	Players.PlayerRemoving:Connect(function(player)
		respawnPoint[player] = nil
		padDebounce[player] = nil
		FlipService.State[player] = nil
	end)

	-- Animate every part tagged as a mover in one heartbeat loop.
	local movers = {}
	for _, descendant in course:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute("MoveAxis") then
			table.insert(movers, descendant)
		end
	end
	RunService.Heartbeat:Connect(function()
		local t = os.clock()
		for _, mover in movers do
			local base = mover:GetAttribute("BaseCFrame")
			local dist = mover:GetAttribute("MoveDistance") or 10
			local speed = mover:GetAttribute("MoveSpeed") or 1
			local offset = math.sin(t * speed) * dist
			if mover:GetAttribute("MoveAxis") == "X" then
				mover.CFrame = base * CFrame.new(offset, 0, 0)
			else
				mover.CFrame = base * CFrame.new(0, 0, offset)
			end
		end
	end)
end

return GameService
