--!strict

--------------
-- Services --
--------------

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")

-----------------
-- References  --
-----------------

local loadingScreenPrefab = ReplicatedFirst:FindFirstChild("LoadingScreenPrefab")
local waitForGameLoadedAsync = require(ReplicatedFirst:WaitForChild("waitForGameLoadedAsync"))

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Utilities = Modules:WaitForChild("Utilities")
local TweenHelper = require(Utilities:WaitForChild("TweenHelper"))

-- Wait for game to load
waitForGameLoadedAsync()

local localPlayer: Player = Players.LocalPlayer
local playerGui: PlayerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local loadingScreen: ScreenGui = loadingScreenPrefab:Clone()
local guiLocalScript = loadingScreen:FindFirstChildOfClass("LocalScript")
loadingScreen.Parent = playerGui

if guiLocalScript then
	guiLocalScript.Enabled = true
end

local Network = ReplicatedStorage:WaitForChild("Network")
local Signals = Network:WaitForChild("Signals")
local DataLoadedEvent = Signals:WaitForChild("DataLoaded")

local loadingInterfaceMainFrame = loadingScreen and loadingScreen:FindFirstChild("MainFrame")
local loadingContentHolder = loadingInterfaceMainFrame and loadingInterfaceMainFrame:FindFirstChild("Holder")
local primaryLoadingStatusText = loadingContentHolder and loadingContentHolder:FindFirstChild("HeaderText")
local secondaryLoadingStatusText = loadingContentHolder and loadingContentHolder:FindFirstChild("SubText")
local loadingBackgroundImage = loadingInterfaceMainFrame and loadingInterfaceMainFrame:FindFirstChild("Background")

---------------
-- Constants --
---------------

local ASSETS_TO_PRELOAD = {
	{"Image", "rbxassetid://121480522"},
	{"Image", "rbxassetid://3926307971"},
	{"Image", "rbxassetid://14829181141"},
	{"Image", "rbxassetid://9131051542"},
	{"Image", "rbxassetid://77362651529596"},
	{"Image", "rbxassetid://17342199692"},
	{"Image", "rbxassetid://17551413159"},
	{"Image", "rbxassetid://17551410483"},

	{"Sound", "rbxassetid://16772109134"},
	{"Sound", "rbxassetid://16772080247"},
	{"Sound", "rbxassetid://16772074498"},
	{"Sound", "rbxassetid://118296674"},
	{"Sound", "rbxassetid://16772076271"},
}

local FADE_TWEEN_INFO = TweenInfo.new(
	1, -- Duration
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0, false, 0
)

local STATUS_MESSAGES = {
	LOADING_DATA = "Loading data",
	LOADING_GAME = "Loading game",
	LOADING_ASSETS = "Loading assets",
	LOADING_FINISHED = "Loading complete!",
}

local COMPLETION_DELAY = 1.5
local DELAY_ASSET_LOAD_TIME = 3.5

-----------------
-- Variables --
-----------------
local isLoadingComplete = false

--------------------
-- Initialization --
--------------------

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

---------------
-- Functions --
---------------

local function isValidUIElement(element: Instance?): boolean
	return element ~= nil and element.Parent ~= nil
end

local function safeUpdateText(textLabel: TextLabel?, text: string): ()
	if textLabel and isValidUIElement(textLabel) then
		textLabel.Text = text
	end
end

local function safeSetAttribute(instance: Instance?, attributeName: string, value: any): ()
	if instance and isValidUIElement(instance) then
		instance:SetAttribute(attributeName, value)
	end
end

local function updateLoadingStatus(statusMessage: string): ()
	if not isValidUIElement(primaryLoadingStatusText) then
		return
	end
	safeSetAttribute(primaryLoadingStatusText, "LoadingText", statusMessage)
	safeUpdateText(secondaryLoadingStatusText, statusMessage)
end

local function createFadeOutTweens(): { Tween }
	local tweens = {}
	if primaryLoadingStatusText then
		table.insert(tweens, TweenHelper.play(primaryLoadingStatusText, FADE_TWEEN_INFO, {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}))
	end
	if loadingInterfaceMainFrame then
		table.insert(tweens, TweenHelper.play(loadingInterfaceMainFrame, FADE_TWEEN_INFO, {
			BackgroundTransparency = 1,
		}))
	end
	if loadingBackgroundImage then
		table.insert(tweens, TweenHelper.play(loadingBackgroundImage, FADE_TWEEN_INFO, {
			ImageTransparency = 1,
		}))
	end
	return tweens
end

local function performFinalCleanup(): ()
	if isValidUIElement(loadingScreen) then
		loadingScreen:Destroy()
	end
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	script:Destroy()
end

local function finishLoading(): ()
	if isLoadingComplete then
		return
	end
	isLoadingComplete = true

	if isValidUIElement(secondaryLoadingStatusText) then
		secondaryLoadingStatusText.Visible = false
	end

	updateLoadingStatus(STATUS_MESSAGES.LOADING_FINISHED)
	localPlayer:SetAttribute("Loaded", true)

	task.wait(COMPLETION_DELAY)

	local fadeAnimations = createFadeOutTweens()
	local completedConnection: RBXScriptConnection? = nil
	if #fadeAnimations > 0 then
		completedConnection = fadeAnimations[1].Completed:Connect(function()
			if completedConnection and completedConnection.Connected then
				completedConnection:Disconnect()
			end
			performFinalCleanup()
		end)
		for _, animation in fadeAnimations do
			animation:Play()
		end
	else
		performFinalCleanup()
	end
end

local function preloadAssets()
	local assets: {ImageLabel | Sound} = {}

	for _, asset in ASSETS_TO_PRELOAD do
		if asset[1] == "Image" then
			local imageAsset = Instance.new("ImageLabel")
			imageAsset.Image = asset[2]
			imageAsset.Parent = script

			table.insert(assets, imageAsset)

		elseif asset[1] == "Sound" then
			local soundAsset = Instance.new("Sound")
			soundAsset.SoundId = asset[2]
			soundAsset.Parent = script

			table.insert(assets, soundAsset)
		end
	end
	ContentProvider:PreloadAsync(assets)
end

local function executeLoadingSequence(): ()
	if isLoadingComplete then
		return
	end

	-- not best practice but this is to reduce failed WaitForChild calls
	updateLoadingStatus(STATUS_MESSAGES.LOADING_GAME)
	task.wait(DELAY_ASSET_LOAD_TIME)

	-- yields until important assets are preloaded
	updateLoadingStatus(STATUS_MESSAGES.LOADING_ASSETS)
	preloadAssets()

	finishLoading()
end

----------------
-- Initialize --
----------------

local function initialize()
	updateLoadingStatus(STATUS_MESSAGES.LOADING_DATA)

	if DataLoadedEvent then
		DataLoadedEvent.OnClientEvent:Connect(executeLoadingSequence)
	end
end

initialize()