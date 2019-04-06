-- Shifter: up and down -------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")
local Maintainer = require("Maintainer")

local Shifter = {VNSMODULECLASS = true}
setmetatable(Shifter, Maintainer)
Shifter.__index = Shifter

function Shifter:new()
	local instance = Maintainer:new()
	setmetatable(instance, self)

	instance.need = {}
	-- instance.need[id] = {vehicle = 4, quadcopter = 5}
	
	instance.childrenAssignTarget = {}
	-- instance.assigning[childid] = "id"
	
	return instance
end

function Shifter:run(vns)
	Maintainer.run(self, vns)

	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "need")) do
		if msgM.fromS == vns.parentS or 
		   vns.childrenTVns[msgM.fromS] ~= nil then
			self.need[msgM.fromS] = msgM.dataT
		end

		--[[
		-- for branches
		if vns.childrenTVns[msgM.fromS] ~= nil then
			for _,robotType in ipairs({"vehicle","quadcopter"}) do
				-- count already assigned robots, if more, call back
				for idS, childVns in pairs(vns.childrenTVns) do
					if self.childrenAssignTarget[idS] == msgM.fromS and
					   vns.childrenTVns[idS].robotType == robotType then
						if self.need[msgM.fromS][robotType] > 0 then
							self.need[msgM.fromS][robotType] = self.need[msgM.fromS][robotType] - 1
						else
							self.childrenAssignTarget[idS] = nil
							self:unsign(idS)
						end
					end
				end

				-- assign more
				for idS, childVns in pairs(vns.childrenTVns) do
					if self.need[msgM.fromS][robotType] <= 0 then break end
					if self.childrenAssignTarget[idS] == nil and 
					   childVns.allocated == nil then
						self:assign(idS, msgM.fromS, vns) 
							-- TODO: assign and unsign in the same time may cause problems
						self.childrenAssignTarget[idS] = msgM.fromS
						self.need[msgM.fromS][robotType] = self.need[msgM.fromS][robotType] - 1
					end
				end
			end
		end
		--]]
	end

	-- count unallocated branches
	local unAllocatedBranchTN = {vehicle = 0, quadcopter = 0}
	if self.structure ~= nil and
	   self.structure.children ~= nil then
		for _, branchT in ipairs(self.structure.children) do
			if branchT.actorS == nil then
				unAllocatedBranchTN[branchT.robotType] = unAllocatedBranchTN[branchT.robotType] + 1
			end
		end
	end

	-- count more robots
	local moreRobotsTN = {vehicle = 0, quadcopter = 0}
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.allocated == nil and instance.childrenAssignTarget[idS] == nil then
		end
	end
end

return Shifter
