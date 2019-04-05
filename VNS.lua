------------------------------------------------------
--	Weixu Zhu, Tutti mi chiamano Harry.
--		zhuweixu_harry@126.com
--
--	Version 2.0:
--		rearrange everything, try modular
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Msg = require("Message")
local Linar = require("Linar")

local Modules = {}
Modules.VehicleConnector = require("VehicleConnector")
Modules.QuadcopterConnector = require("QuadcopterConnector")
Modules.ParentWaitor = require("ParentWaitor")
Modules.ParentWaitorDeny = require("ParentWaitorDeny")
Modules.LostCounter = require("LostCounter")
Modules.RandomWalker = require("RandomWalker")
Modules.Assigner = require("Assigner")
Modules.Driver = require("Driver")

local VNS = {VNSCLASS = true}
VNS.__index = VNS

VNS.Modules = Modules
VNS.Msg = Msg

function VNS:new(option)
	return self:create(option)
end

function VNS:create(option)
	local instance = {}
	setmetatable(instance, self)

	instance.idS = option.idS
	instance.locV3 = option.locV3 or Vec3:create()
	instance.dirQ = option.dirQ or Quaternion:create()
	instance.parentS = nil

	instance.childrenTVns = {}

	instance.modules = {}
	for i, ModuleM in ipairs(self.EnableModules) do
		instance.modules[i] = ModuleM:new()
	end

	-- implicit module value: 
	--[[
	instance.rallyPoint = {	
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
	}
		-- used by driver module
	
	instance.updated
		-- used by connector and lostcount module

	instance.myAssignParent = nil
	instance.childrenAssignTS = {}
		-- used by Assigner
	--]]

	return instance
end

function VNS:reset()
	self.locV3 = Vec3:create()
	self.dirQ = Quaternion:create()

	self.parentS = nil
	self.rallyPoint = {	
		-- used by driver module
		locV3 = Vec3:create(),
		dirQ = Quaternion:create(),
	}
	self.childrenTVns = {}

	for i, moduleM in pairs(self.modules) do
		if type(moduleM.reset) == "function" then 
			moduleM:reset() 
		end
	end
end

function VNS:run(paraT)
	for i, moduleM in ipairs(self.modules) do
		moduleM:run(self, paraT)
	end
end

function VNS:deleteChild(idS)
	self.childrenTVns[idS] = nil

	if self.childrenAssignTS ~= nil then
		self.childrenAssignTS[idS] = nil
	end
end

return VNS
