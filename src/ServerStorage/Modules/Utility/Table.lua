local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.DeepCopy(passed_table)
	local clonedTable = {}
	if typeof(passed_table) == "table" then
		for k,v in pairs(passed_table) do
			clonedTable[Module.DeepCopy(k)] = Module.DeepCopy(v)
		end
	else
		clonedTable = passed_table
	end
	return clonedTable
end

function Module.Start()
    
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems
end

return Module