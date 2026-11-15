-- FLIPFALL shared config: palette + physics constants.
local Config = {}

Config.GRAVITY = 196.2 -- workspace gravity (studs/s^2)
Config.FLIP_ACCEL = 392.4 -- 2x gravity: cancels gravity and pulls the other way

Config.Colors = {
	Floor = Color3.fromRGB(28, 30, 46),
	Platform = Color3.fromRGB(52, 56, 84),
	Ceiling = Color3.fromRGB(38, 34, 66),
	Accent = Color3.fromRGB(0, 255, 200), -- neon cyan
	AccentAlt = Color3.fromRGB(255, 0, 170), -- neon magenta
	Checkpoint = Color3.fromRGB(0, 255, 200),
	Kill = Color3.fromRGB(255, 40, 60),
	Lava = Color3.fromRGB(255, 90, 0),
	FlipPad = Color3.fromRGB(170, 0, 255),
	Crate = Color3.fromRGB(255, 170, 0),
	Finish = Color3.fromRGB(255, 215, 0),
	Sign = Color3.fromRGB(16, 16, 26),
}

return Config
