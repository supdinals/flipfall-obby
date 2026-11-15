-- FLIPFALL entry point (server): build the course, create remotes, start services.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local serverFolder = ServerScriptService:WaitForChild("Server")
local CourseBuilder = require(serverFolder:WaitForChild("CourseBuilder"))
local FlipService = require(serverFolder:WaitForChild("FlipService"))
local GameService = require(serverFolder:WaitForChild("GameService"))

local flipEvent = Instance.new("RemoteEvent")
flipEvent.Name = "FlipEvent"
flipEvent.Parent = ReplicatedStorage

local gameEvent = Instance.new("RemoteEvent")
gameEvent.Name = "GameEvent"
gameEvent.Parent = ReplicatedStorage

local course = CourseBuilder.Build()
FlipService.Init(flipEvent)
GameService.Init(course, gameEvent)

print("[FLIPFALL] Course built: " .. #course:GetDescendants() .. " instances. Gravity is negotiable.")
