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
	
	return instance
end

function Shifter:run(vns)
	print("I am shifter run")
	Maintainer.run(self, vns)

	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "need")) do
		if msgM.fromS == vns.parentS or 
		   vns.childrenTVns[msgM.fromS] ~= nil then
			self.need[msgM.fromS] = msgM.dataT
		end
	end

	-- count unallocated branches
	local unAllocatedBranchTN = {vehicle = 0, quadcopter = 0}
	if self.structure ~= nil and
	   self.structure.children ~= nil then
		for _, branchT in ipairs(self.structure.children) do
			if branchT.actorS == nil then
				unAllocatedBranchTN[branchT.robotType] = 
					unAllocatedBranchTN[branchT.robotType] + 1
			end
		end
	end

	print("branch count")
	showTable(unAllocatedBranchTN)

	-- count more robots
	local moreRobotsTN = {vehicle = 0, quadcopter = 0}
	for idS, childVns in pairs(vns.childrenTVns) do
		if self.allocated[idS] == nil and 
		   self.childrenAssignTS[idS] == nil then
			moreRobotsTN[childVns.robotType] = 
				moreRobotsTN[childVns.robotType] + 1
		end
	end

	print("more robot")
	showTable(moreRobotsTN)
end

return Shifter
