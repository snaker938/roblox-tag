local RunService = game:GetService('RunService')

local function hasInit(tbl : table) : boolean
	return tbl.Init or (getmetatable(tbl) and getmetatable(tbl).Init)
end

local function hasStart(tbl : table) : boolean
	return tbl.Start or (getmetatable(tbl) and getmetatable(tbl).Start)
end

local CacheTable = {}

local function cacheParent( _, Parent )
	local Cache = CacheTable[Parent]
	if Cache then
		return Cache
	end
	Cache = {}
	CacheTable[Parent] = Cache

	-- Require Modules
	for _, ModuleScript in ipairs( Parent:GetChildren() ) do
		if ModuleScript:IsA('ModuleScript') then
			Cache[ModuleScript.Name] = require(ModuleScript)
		end
	end


	-- Initialize
	for preLoadedName, preLoaded in pairs(Cache) do
		if typeof(preLoaded) ~= 'table' or preLoaded.Initialised or (not hasInit(preLoaded)) then
			continue
		end
		local accessibles = { ParentSystems = CacheTable[Parent.Parent] }
		for otherLoadedName, differentLoaded in pairs(Cache) do
			if preLoadedName == otherLoadedName then
				continue
			end
			accessibles[otherLoadedName] = differentLoaded
		end
		preLoaded.Initialised = true
		preLoaded.Init(accessibles)
	end

	return Cache
end

local function startFramework()
	if RunService:IsServer() then print("------------ STARTING SERVER MODULES ------------") else print("------------ STARTING CLIENT MODULES ------------") end
	for _, cache in pairs( CacheTable ) do
		for moduleName, preLoaded in pairs(cache) do
			if typeof(preLoaded) ~= 'table' or preLoaded.Started or (not hasStart(preLoaded)) then
				continue
			end
			preLoaded.Started = true
			print("Starting module: " .. moduleName)
			preLoaded.Start()
		end
	end
	if RunService:IsServer() then print("------------ STARTED SERVER MODULES ------------") else print("------------ STARTED CLIENT MODULES ------------") end
end

-- // MAIN // --
local Table = { }
Table.__call = cacheParent
Table.Start = startFramework
return setmetatable(Table, Table)
