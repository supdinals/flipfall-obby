-- FLIPFALL gravity service: the core mechanic.
-- Each character carries a VectorForce. Unflipped it is zero and world gravity
-- rules. Flipped it applies mass * 2g upward, so the character falls UP, and
-- the character model is rolled 180 degrees so its feet land on ceilings.
-- Every loose crate in the course carries the same force, so flipping throws
-- the course's physics props to the ceiling with you.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local FlipService = {}
FlipService.State = {} -- [player] = true when flipped

local function ensureForce(root, owner)
	local force = root:FindFirstChild("FlipForce")
	if not force then
		force = Instance.new("VectorForce")
		force.Name = "FlipForce"
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.ApplyAtCenterOfMass = true
		local att = root:FindFirstChildOfClass("Attachment")
		if not att then
			att = Instance.new("Attachment")
			att.Name = "FlipAttachment"
			att.Parent = root
		end
		force.Attachment0 = att
		force.Parent = root
	end
	return force
end

local function setForce(model, flipped)
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildOfClass("Part")
	if not root then return end
	local force = ensureForce(root)
	local mass = model:GetMass()
	force.Force = flipped and Vector3.new(0, mass * Config.FLIP_ACCEL, 0) or Vector3.zero
end

local function flipCrates(flipped)
	local course = workspace:FindFirstChild("Course")
	local crates = course and course:FindFirstChild("Crates")
	if not crates then return end
	for _, crate in crates:GetChildren() do
		if crate:IsA("BasePart") and crate:GetAttribute("IsCrate") then
			setForce(crate, flipped)
		end
	end
end

function FlipService.SetFlip(player, flipped)
	local character = player.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local current = FlipService.State[player] == true
	if current == flipped then return end
	FlipService.State[player] = flipped
	setForce(character, flipped)
	-- Roll the character 180 degrees around its facing axis so feet meet the ceiling.
	root.CFrame = root.CFrame * CFrame.Angles(0, 0, math.pi)
	flipCrates(flipped)
	player:SetAttribute("Flipped", flipped)
end

function FlipService.Toggle(player)
	FlipService.SetFlip(player, not (FlipService.State[player] == true))
end

function FlipService.Reset(player)
	FlipService.State[player] = false
	player:SetAttribute("Flipped", false)
	local character = player.Character
	if character then setForce(character, false) end
end

function FlipService.Init(flipEvent)
	flipEvent.OnServerEvent:Connect(function(player)
		FlipService.Toggle(player)
	end)
end

return FlipService
