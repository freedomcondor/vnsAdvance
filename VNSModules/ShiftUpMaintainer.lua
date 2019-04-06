-- Shift Up Maintainer -------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")
local Assigner = require("Assigner")

local ShiftUpMaintainer = {VNSMODULECLASS = true}
setmetatable(ShiftUpMaintainer, Assigner)
ShiftUpMaintainer.__index = ShiftUpMaintainer

function ShiftUpMaintainer:new()
	local instance = Assigner:new()
	setmetatable(instance, self)

	local dis = 100
	instance.structure = {
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
		children = {
			{	locV3 = Vec3:create(-dis, -dis, 0),
				dirQ = Quaternion:create(0,0,1, -math.pi*3/4),
			},

			{	locV3 = Vec3:create(dis, -dis, 0),
				dirQ = Quaternion:create(0,0,1, -math.pi*3/4),
			},
		},
	}

	return instance
end

function ShiftUpMaintainer:setStructure(vns, structure)
	self.structure = structure
end

function ShiftUpMaintainer:run(vns)
	Assigner.run(self, vns)

	for _, msgM in ipairs(vns.Msg.getAM(vns.parentS, "branch")) do
		self:setStructure(vns, msgM.dataT.structure)
	end

	-- allocate branch
	if self.structure ~= nil and
	   self.structure.children ~= nil then
		for _, branchT in ipairs(self.structure.children) do
			-- some branch is lost
			if branchT.actorS ~= nil and
			   vns.childrenTVns[branchT.actorS] == nil then
					branchT.actorS = nil
			end

			-- some branch is not fulfill
			if branchT.actorS == nil then
				for idS, childVns in pairs(vns.childrenTVns) do
					if childVns.allocated == nil then
						childVns.rallyPoint = {
							locV3 = branchT.locV3,
							dirQ = branchT.dirQ,
						}
						branchT.actorS = idS
						childVns.allocated = true
						break
					end
				end
			end
		end
	end

	-- more children go to parent
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.allocated == nil then
			self:assign(idS, vns.parentS, vns)
		end
	end
end

return ShiftUpMaintainer
