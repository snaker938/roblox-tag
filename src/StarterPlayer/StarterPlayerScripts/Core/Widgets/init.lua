local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local ResetGameEvent = RemoteService:GetRemote("ResetGameEvent", "RemoteEvent", false)

local WidgetsCache = {}

local SystemsContainer = {}

local DEFAULT_WIDGET_IGNORE_LIST = {"EmptyWidget"}

-- // Module // --
local Module = {}

function Module.GetWidget(widgetName)
	return WidgetsCache[widgetName]
end

function Module.ToggleWidget(widgetName, enabled, ...)
	local cachedModule = WidgetsCache[widgetName]
	if not cachedModule then
		return
	end
	if enabled then
		cachedModule.OpenWidget(...)
	elseif enabled == nil then
		if cachedModule.Open then
			cachedModule.CloseWidget()
		else
			cachedModule.OpenWidget(...)
		end
	elseif not enabled then
		cachedModule.CloseWidget()
	end
end

function Module.IsWidgetOpen(widgetName)
	local cachedModule = WidgetsCache[widgetName]
	if not cachedModule then
		return
	end
	return cachedModule.Open
end

function Module.ToggleAllWidgets(enabled, WidgetIgnoreList)
	for widgetName, WidgetModule in pairs(WidgetsCache) do
		if table.find(DEFAULT_WIDGET_IGNORE_LIST, widgetName) or table.find(WidgetIgnoreList, widgetName) then
			continue
		end
		if enabled then
			if not WidgetModule.Open then
				WidgetModule.OpenWidget()
			end
		else
			WidgetModule.CloseWidget()
		end
	end
end

function Module.UpdateWidget(widgetName)
	local cachedModule = WidgetsCache[widgetName]
	if not cachedModule then
		return
	end
	cachedModule.UpdateWidget()
end

function Module.Start()
	for _, WidgetModule in pairs(WidgetsCache) do
		WidgetModule.CloseWidget()
	end
	Module.ToggleWidget("PreGameWaitingWidget", true)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	-- Cache and initialize widget modules
	for _, WidgetModule in ipairs(script:GetChildren()) do
		local Cached = require(WidgetModule)
		Cached.Init(Module, otherSystems)
		WidgetsCache[WidgetModule.Name] = Cached
	end

	print("------------ STARTING WIDGET MODULES ------------")
	-- start all modules
	for CachedModuleName, CachedModule in pairs(WidgetsCache) do

		print("Starting widget: " .. CachedModuleName)
		CachedModule.Start()
	end

	print("------------ STARTED WIDGET MODULES ------------")

	ResetGameEvent.OnClientEvent:Connect(function()
		Module.ToggleAllWidgets(false, {})
		Module.ToggleWidget("PreGameWaitingWidget", true)
	end)
end

return Module
