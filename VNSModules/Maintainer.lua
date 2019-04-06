-- VNS Tree Maintainer -------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")
local Assigner = require("Assigner")

local Maintainer = {VNSMODULECLASS = true}
setmetatable(Maintainer, Assigner)
Maintainer.__index = Maintainer

function Maintainer:new()
	local instance = Assigner:new()
	setmetatable(instance, self)

	--[[
	local structure = {
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
		children = {
			{	locV3 = Vec3:create(-dis, -dis, 0),
				dirQ = Quaternion:create(0,0,1, 0),
				robotType = "vehicle",
			},

			{	locV3 = Vec3:create(dis, -dis, 0),
				dirQ = Quaternion:create(0,0,1, 0),
				robotType = "vehicle",
			},
		}
	}
	--]]

	return instance
end

function Maintainer:setStructure(vns, structure)
	self.structure = structure

	-- re allocate every child
	for idS, childVns in pairs(vns.childrenTVns) do
		childVns.allocated = nil
	end
end

function Maintainer:run(vns)
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

			-- some branch is not fulfilled
			if branchT.actorS == nil then
				for idS, childVns in pairs(vns.childrenTVns) do
					if childVns.allocated == nil and 
					   childVns.robotType == branchT.robotType then
						branchT.actorS = idS
						childVns.allocated = true
						childVns.rallyPoint = {
							locV3 = branchT.locV3,
							dirQ = branchT.dirQ,
						}
						vns.Msg.send(idS, "branch", {structure = branchT})
						break
					end
				end
			end
		end
	end

	-- more children set rallypoint to 0
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.allocated == nil then
			--self:assign(idS, vns.parentS, vns)
			childVns.rallyPoint = {
				locV3 = Vec3:create(),
				dirQ = Quaternion:create(),
			}
		end
	end
end

return Maintainer
