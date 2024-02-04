local OverlaysCache = {}

local SystemsContainer = {}

local DEFAULT_OVERLAY_IGNORE_LIST = {"EmptyOverlay"}

-- // Module // --
local Module = {}

function Module.GetOverlay(overlayName)
	return OverlaysCache[overlayName]
end

function Module.ToggleOverlay(overlayName, enabled, ...)
	local cachedModule = OverlaysCache[overlayName]
	if not cachedModule then
		return
	end
	if enabled then
		cachedModule.OpenOverlay(...)
	elseif enabled == nil then
		if cachedModule.Open then
			cachedModule.CloseOverlay()
		else
			cachedModule.OpenOverlay(...)
		end
	elseif not enabled then
		cachedModule.CloseOverlay()
	end
end

function Module.IsOverlayOpen(overlayName)
	local cachedModule = OverlaysCache[overlayName]
	if not cachedModule then
		return
	end
	return cachedModule.Open
end

function Module.ToggleAllOverlays(enabled)
	for overlayName, OverlayModule in pairs(OverlaysCache) do
		if table.find(DEFAULT_OVERLAY_IGNORE_LIST, overlayName) then
			continue
		end
		if enabled then
			if not OverlayModule.Open then
				OverlayModule.OpenOverlay()
			end
		else
			OverlayModule.CloseOverlay()
		end
	end
end

function Module.UpdateOverlay(overlayName)
	local cachedModule = OverlaysCache[overlayName]
	if not cachedModule then
		return
	end
	cachedModule.UpdateOverlay()
end

function Module.Start()
	for OverlayName, OverlayModule in pairs(OverlaysCache) do
		OverlayModule.CloseOverlay()
	end
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems

	-- Cache and initialize overlay modules
	for _, OverlayModule in ipairs(script:GetChildren()) do
		local Cached = require(OverlayModule)
		Cached.Init(Module, otherSystems)
		OverlaysCache[OverlayModule.Name] = Cached
	end

	print("------------ STARTING OVERLAY MODULES ------------")
	for CachedModuleName, CachedModule in pairs(OverlaysCache) do

		print("Starting overlay: " .. CachedModuleName)
		CachedModule.Start()
	end
	print("------------ STARTED OVERLAY MODULES ------------")
end

return Module
