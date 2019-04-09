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

	instance.allocated = {}
	instance.lastSendBrain = {}

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

	-- re-allocate/re-assign every child
	self:reset(vns)
	--[[
	for idS, childVns in pairs(vns.childrenTVns) do
		childVns.allocated = nil
	end
	--]]
end

function Maintainer:reset(vns)
	Assigner.reset(self, vns)
	self.allocated = {}
	self.lastSendBrain = {}
end

function Maintainer:deleteChild(idS)
	Assigner.deleteChild(self, idS)
	self.allocated[idS] = nil
	self.lastSendBrain[idS] = nil
end

function Maintainer:run(vns)
	Assigner.run(self, vns)

	-- about brain
	if vns.parentS == nil then vns.brainS = vns.idS end

	for _, msgM in ipairs(vns.Msg.getAM(vns.parentS, "brain")) do
		if vns.brainS ~= msgM.dataT.brainS then
			vns.brainS = msgM.dataT.brainS
		end
	end

	for idS, childVns in pairs(vns.childrenTVns) do
		if self.lastSendBrain[idS] ~= vns.brainS then
			vns.Msg.send(idS, "brain", {brainS = vns.brainS})
			self.lastSendBrain[idS] = vns.brainS
		end
	end

	for _, msgM in ipairs(vns.Msg.getAM(vns.parentS, "branch")) do
		self:setStructure(vns, vns.Msg.recoverTable(msgM.dataT.structure))
	end

	-- about structure
	
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
					if self.allocated[idS] == nil and 
					   childVns.robotType == branchT.robotType then
						branchT.actorS = idS
						self.allocated[idS] = true
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
		if self.allocated[idS] == nil and
		   self.childrenAssignTS[idS] == nil then
			childVns.rallyPoint = {
				locV3 = Vec3:create(),
				dirQ = Quaternion:create(),
			}
		end
	end
end

return Maintainer
