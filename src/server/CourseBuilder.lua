-- FLIPFALL course builder: the whole obby is generated from code at runtime.
-- No hand-placed parts: every platform, checkpoint, crate and sign is built here,
-- so the Luau source in this repo IS the level design.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local C = Config.Colors

local CourseBuilder = {}

local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(parent, cf, size, text, textColor)
	local s = part(parent, "Sign", size, cf, C.Sign, Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = s
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or C.Accent
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	return s
end

local function checkpoint(parent, stage, cf)
	local pad = part(parent, "Checkpoint" .. stage, Vector3.new(8, 1, 8), cf, C.Checkpoint, Enum.Material.Neon)
	pad:SetAttribute("Stage", stage)
	pad:SetAttribute("IsCheckpoint", true)
	return pad
end

local function killBrick(parent, name, size, cf)
	local k = part(parent, name, size, cf, C.Kill, Enum.Material.Neon)
	k:SetAttribute("IsKill", true)
	return k
end

local function flipPad(parent, name, cf, targetState)
	local pad = part(parent, name, Vector3.new(7, 1, 7), cf, C.FlipPad, Enum.Material.Neon)
	pad:SetAttribute("IsFlipPad", true)
	pad:SetAttribute("FlipTarget", targetState) -- "up", "down" or "toggle"
	return pad
end

function CourseBuilder.Build()
	local course = Instance.new("Folder")
	course.Name = "Course"
	course.Parent = workspace

	local crates = Instance.new("Folder")
	crates.Name = "Crates"
	crates.Parent = course

	-- ===== Stage 0: spawn plaza =====
	part(course, "SpawnPlatform", Vector3.new(26, 2, 26), CFrame.new(0, -1, 0), C.Floor)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 0.5, 0)
	spawn.Color = C.Accent
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = course
	sign(course, CFrame.new(0, 5, -11) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(20, 6, 1),
		"FLIPFALL\nPress F (or tap FLIP) to reverse YOUR gravity!\nCrates flip with you. Good luck!", C.Accent)
	checkpoint(course, 0, CFrame.new(0, 0.5, 8))

	-- ===== Stage 1: first steps (plain jumps) =====
	for i = 1, 4 do
		part(course, "Step" .. i, Vector3.new(8, 1, 8), CFrame.new(0, i * 1.5, 15 + i * 10), C.Platform)
	end
	part(course, "Stage1End", Vector3.new(16, 2, 14), CFrame.new(0, 6, 64), C.Floor)
	checkpoint(course, 1, CFrame.new(0, 7.5, 64))

	-- ===== Stage 2: ceiling walk =====
	-- Floor stops. A long ceiling slab runs overhead; hanging ledges under it are
	-- walked on their underside after flipping. End platform is back on the floor.
	part(course, "CeilingSlab", Vector3.new(18, 2, 74), CFrame.new(0, 22, 112), C.Ceiling)
	for i = 0, 4 do
		-- hanging ledge: top touches the slab, underside at y = 19 is the floor when flipped
		part(course, "HangLedge" .. i, Vector3.new(8, 2, 8), CFrame.new((i % 2 == 0) and -4 or 4, 20, 84 + i * 14), C.Platform)
	end
	sign(course, CFrame.new(0, 12, 76) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(16, 5, 1),
		"No floor? FLIP and walk the ceiling!", C.AccentAlt)
	part(course, "Stage2End", Vector3.new(16, 2, 14), CFrame.new(0, 6, 156), C.Floor)
	checkpoint(course, 2, CFrame.new(0, 7.5, 156))

	-- ===== Stage 3: lava floor, mixed route =====
	local lava = part(course, "LavaFloor", Vector3.new(40, 1, 62), CFrame.new(0, 0, 196), C.Lava, Enum.Material.Neon)
	lava:SetAttribute("IsKill", true)
	part(course, "LavaCeiling", Vector3.new(18, 2, 62), CFrame.new(0, 24, 196), C.Ceiling)
	for i = 0, 3 do
		part(course, "LavaIsland" .. i, Vector3.new(7, 1, 7), CFrame.new((i % 2 == 0) and -8 or 8, 4 + i, 172 + i * 15), C.Platform)
		part(course, "LavaHang" .. i, Vector3.new(7, 2, 7), CFrame.new((i % 2 == 0) and 8 or -8, 22, 179 + i * 15), C.Platform)
	end
	part(course, "Stage3End", Vector3.new(16, 2, 14), CFrame.new(0, 8, 236), C.Floor)
	checkpoint(course, 3, CFrame.new(0, 9.5, 236))

	-- ===== Stage 4: moving platform over a pit =====
	local pit = part(course, "PitLava", Vector3.new(44, 1, 40), CFrame.new(0, 2, 266), C.Lava, Enum.Material.Neon)
	pit:SetAttribute("IsKill", true)
	local mover = part(course, "MovingPlatform", Vector3.new(10, 1, 10), CFrame.new(0, 10, 266), C.AccentAlt, Enum.Material.Neon)
	mover:SetAttribute("MoveAxis", "X")
	mover:SetAttribute("MoveDistance", 14)
	mover:SetAttribute("MoveSpeed", 0.7)
	mover:SetAttribute("BaseCFrame", mover.CFrame)
	part(course, "Stage4End", Vector3.new(16, 2, 14), CFrame.new(0, 8, 294), C.Floor)
	checkpoint(course, 4, CFrame.new(0, 9.5, 294))

	-- ===== Stage 5: crate gate =====
	-- A wall blocks the path at ground level. Three loose crates jam the doorway;
	-- flip gravity and the crates fall UP to the ceiling, clearing the way.
	part(course, "GateFloor", Vector3.new(22, 2, 26), CFrame.new(0, 8, 314), C.Floor)
	part(course, "GateWallL", Vector3.new(7, 14, 2), CFrame.new(-7.5, 16, 326), C.Platform)
	part(course, "GateWallR", Vector3.new(7, 14, 2), CFrame.new(7.5, 16, 326), C.Platform)
	part(course, "GateWallTop", Vector3.new(22, 3, 2), CFrame.new(0, 24.5, 326), C.Platform)
	part(course, "GateCeiling", Vector3.new(22, 2, 26), CFrame.new(0, 30, 314), C.Ceiling)
	for i = 1, 3 do
		local crate = part(crates, "Crate" .. i, Vector3.new(3.4, 3.4, 3.4),
			CFrame.new(-2 + (i - 1) * 2, 10.8, 326), C.Crate, Enum.Material.Wood)
		crate.Anchored = false
		crate:SetAttribute("IsCrate", true)
	end
	sign(course, CFrame.new(0, 13, 320) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(16, 4, 1),
		"Crates in the way? FLIP them to the ceiling!", C.Crate)
	part(course, "Stage5End", Vector3.new(16, 2, 14), CFrame.new(0, 8, 340), C.Floor)
	checkpoint(course, 5, CFrame.new(0, 9.5, 340))

	-- ===== Stage 6: flip pad alley =====
	part(course, "AlleyFloor", Vector3.new(16, 2, 20), CFrame.new(0, 8, 356), C.Floor)
	part(course, "AlleyCeiling", Vector3.new(16, 2, 58), CFrame.new(0, 26, 380), C.Ceiling)
	flipPad(course, "PadUp1", CFrame.new(0, 9.5, 362), "up")
	for i = 0, 2 do
		part(course, "AlleyHang" .. i, Vector3.new(8, 2, 8), CFrame.new(0, 24, 372 + i * 12), C.Platform)
		part(course, "AlleyStep" .. i, Vector3.new(8, 1, 8), CFrame.new(0, 10, 378 + i * 12), C.Platform)
	end
	flipPad(course, "PadDown1", CFrame.new(0, 25.5, 402) * CFrame.Angles(0, 0, math.pi), "down")
	part(course, "Stage6End", Vector3.new(16, 2, 14), CFrame.new(0, 8, 416), C.Floor)
	checkpoint(course, 6, CFrame.new(0, 9.5, 416))

	-- ===== Stage 7: the shaft (fall up, ledge to ledge) =====
	part(course, "ShaftFloor", Vector3.new(18, 2, 18), CFrame.new(0, 8, 434), C.Floor)
	part(course, "ShaftWallL", Vector3.new(2, 44, 18), CFrame.new(-10, 30, 434), C.Platform)
	part(course, "ShaftWallR", Vector3.new(2, 44, 18), CFrame.new(10, 30, 434), C.Platform)
	for i = 0, 3 do
		part(course, "ShaftLedge" .. i, Vector3.new(7, 1, 7), CFrame.new((i % 2 == 0) and -5 or 5, 14 + i * 10, 434), C.Platform)
	end
	part(course, "ShaftTop", Vector3.new(18, 2, 18), CFrame.new(0, 54, 434), C.Ceiling)
	flipPad(course, "PadShaft", CFrame.new(0, 9.5, 434), "toggle")
	part(course, "Stage7End", Vector3.new(16, 2, 14), CFrame.new(0, 54, 452), C.Floor)
	checkpoint(course, 7, CFrame.new(0, 55.5, 452))

	-- ===== Stage 8: gauntlet =====
	part(course, "GauntletFloor", Vector3.new(16, 2, 56), CFrame.new(0, 54, 486), C.Floor)
	part(course, "GauntletCeiling", Vector3.new(16, 2, 56), CFrame.new(0, 74, 486), C.Ceiling)
	for i = 0, 3 do
		killBrick(course, "GauntletBar" .. i, Vector3.new(16, 2, 2), CFrame.new(0, 57, 468 + i * 12))
		killBrick(course, "GauntletBarTop" .. i, Vector3.new(16, 2, 2), CFrame.new(0, 71, 474 + i * 12))
	end
	checkpoint(course, 8, CFrame.new(0, 55.5, 512))

	-- ===== Stage 9: finish =====
	part(course, "FinishPlatform", Vector3.new(22, 2, 22), CFrame.new(0, 54, 532), C.Floor)
	local finish = part(course, "FinishPad", Vector3.new(12, 1, 12), CFrame.new(0, 55.5, 532), C.Finish, Enum.Material.Neon)
	finish:SetAttribute("IsFinish", true)
	sign(course, CFrame.new(0, 60, 522) * CFrame.Angles(0, math.rad(180), 0), Vector3.new(18, 5, 1),
		"FINISH!\nYou beat FLIPFALL!", C.Finish)

	return course
end

return CourseBuilder
