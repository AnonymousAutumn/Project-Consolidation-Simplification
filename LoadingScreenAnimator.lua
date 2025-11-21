--!strict

--------------
-- Services --
--------------

local RunService = game:GetService("RunService")

-----------------
-- References --
-----------------

local self = script.Parent
local mainFrame: Frame = self:FindFirstChild("MainFrame") :: Frame
local contentHolder: Frame = mainFrame and mainFrame:FindFirstChild("Holder") :: Frame
local headerText: TextLabel = contentHolder and contentHolder:FindFirstChild("HeaderText") :: TextLabel
local subText: TextLabel = contentHolder and contentHolder:FindFirstChild("SubText") :: TextLabel

---------------
-- Constants --
---------------

local MAX_DOTS = 3
local COMPLETION_MESSAGE = "Loading complete!"
local FINISHED_TEXT = "COMPLETE"
local FADE_DURATION = 0.1
local HOLD_DURATION = 0.05
local FADE_DURATION_INVERSE = 1 / FADE_DURATION
local DOT_FORMAT = '<font transparency="%.2f"> .</font>'
local BASE_LOADING_TEXT = "LOADING"

-----------------
-- Variables --
-----------------
local isAnimating = true
local animationThread: thread? = nil
local dotOpacities = table.create(MAX_DOTS, 1)
local activeConnections: {RBXScriptConnection} = {}

-----------------
-- Helpers --
-----------------
local function trackConnection(connection: RBXScriptConnection): RBXScriptConnection
	table.insert(activeConnections, connection)
	return connection
end

local function disconnectAllConnections(): ()
	for _, connection in activeConnections do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(activeConnections)
end

local function cancelAnimationThread(): ()
	if animationThread then
		task.cancel(animationThread)
		animationThread = nil
	end
end

local function isValidUIElement(element: Instance?): boolean
	return element ~= nil and element.Parent ~= nil
end

local function safeUpdateText(textLabel: TextLabel?, text: string): ()
	if textLabel and isValidUIElement(textLabel) then
		textLabel.Text = text
	end
end

local function getCurrentLoadingText(): string
	if headerText and isValidUIElement(headerText) then
		return headerText:GetAttribute("LoadingText") or BASE_LOADING_TEXT
	end
	return BASE_LOADING_TEXT
end

local function createAnimatedText(opacities: {number}): string
	local parts = table.create(MAX_DOTS + 1)
	parts[1] = BASE_LOADING_TEXT
	for i = 1, MAX_DOTS do
		parts[i + 1] = string.format(DOT_FORMAT, opacities[i])
	end
	return table.concat(parts)
end

local function isLoadingComplete(): boolean
	return getCurrentLoadingText() == COMPLETION_MESSAGE
end

local function cleanupAllResources(): ()
	isAnimating = false
	disconnectAllConnections()
	cancelAnimationThread()
end

local function finishAnimation(): ()
	if not isAnimating then
		return
	end
	isAnimating = false
	safeUpdateText(headerText, FINISHED_TEXT)
	cleanupAllResources()
end

local function updateDisplay(opacities: {number}): boolean
	if not isValidUIElement(headerText) then
		finishAnimation()
		return false
	end
	safeUpdateText(headerText, createAnimatedText(opacities))
	safeUpdateText(subText, string.lower(getCurrentLoadingText()))
	return true
end

local function resetDotOpacities(opacities: {number}): ()
	for i = 1, MAX_DOTS do
		opacities[i] = 1
	end
end

local function calculateFadeProgress(startTime: number): number
	local elapsed = os.clock() - startTime
	return math.min(elapsed * FADE_DURATION_INVERSE, 1)
end

local function updateDotOpacity(opacities: {number}, dotIndex: number, progress: number, fadeIn: boolean): ()
	opacities[dotIndex] = if fadeIn then (1 - progress) else progress
end

local function performFadePhase(dotIndex: number, opacities: {number}, fadeIn: boolean): boolean
	local startTime = os.clock()
	while true do
		if not isAnimating then
			return false
		end
		if isLoadingComplete() then
			finishAnimation()
			return false
		end
		local progress = calculateFadeProgress(startTime)
		updateDotOpacity(opacities, dotIndex, progress, fadeIn)
		if not updateDisplay(opacities) then
			return false
		end
		if progress >= 1 then
			break
		end
		RunService.RenderStepped:Wait()
	end
	return true
end

local function performHoldPhase(): boolean
	local holdStart = os.clock()
	while os.clock() - holdStart < HOLD_DURATION do
		if not isAnimating then
			return false
		end
		if isLoadingComplete() then
			finishAnimation()
			return false
		end
		RunService.Heartbeat:Wait()
	end
	return true
end

local function animateDot(dotIndex: number, opacities: {number}, fadeIn: boolean): boolean
	if not performFadePhase(dotIndex, opacities, fadeIn) then
		return false
	end
	return performHoldPhase()
end

local function fadeDotsIn(opacities: {number}): boolean
	for i = 1, MAX_DOTS do
		if not animateDot(i, opacities, true) then
			return false
		end
	end
	return true
end

local function fadeDotsOut(opacities: {number}): boolean
	for i = 1, MAX_DOTS do
		if not animateDot(i, opacities, false) then
			return false
		end
	end
	return true
end

local function performAnimationCycle(): boolean
	if isLoadingComplete() then
		finishAnimation()
		return false
	end
	resetDotOpacities(dotOpacities)
	if not fadeDotsIn(dotOpacities) then
		return false
	end
	if not fadeDotsOut(dotOpacities) then
		return false
	end
	return true
end

local function runLoadingAnimation(): ()
	while isAnimating do
		if not performAnimationCycle() then
			return
		end
	end
end

local function handleLoadingTextChange(): ()
	if isLoadingComplete() then
		finishAnimation()
	end
end

local function handleUIDestruction(): ()
	if not script.Parent.Parent then
		cleanupAllResources()
	end
end

--------------------
-- Initialization --
--------------------
resetDotOpacities(dotOpacities)
animationThread = task.spawn(runLoadingAnimation)

if script.Parent then
	trackConnection(script.Parent.AncestryChanged:Connect(handleUIDestruction))
end

if headerText then
	trackConnection(headerText:GetAttributeChangedSignal("LoadingText"):Connect(handleLoadingTextChange))
end