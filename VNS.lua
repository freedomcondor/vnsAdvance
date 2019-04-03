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

local VNS = {CLASSVNS = true}
VNS.__index = VNS

function VNS:new(option)
	return self:create(option)
end

function VNS:create(option)
	local instance = {}
	setmetatable(instance, self)

	instance.idS = option.idS
	instance.locV3 = option.locV3 or Vec3:create()
	instance.dirQ = option.dirQ or Quaternion:create()

	instance.childrenTVns = {}

	return instance
end

function VNS:run(paraT)
	for i, moduleM in ipairs(self.modules) do
		moduleM:run(self, paraT)
	end
end

VNS.Msg = Msg

------------------------------------------------------
--	Modules
------------------------------------------------------
VNS.modules = {}

-- define modules

-- connector -----------------------------------------
VNS.modules.connector = { 
	countTN = {},	-- father class data, not used if inherited
	waitingTVns = {},
}
function VNS.modules.connector:step(vns, robotListR)
	self:update(robotListR, vns)
	self:lostCount(robotListR)
	-- recruit new
	for idS, robotR in pairs(robotListR) do
		if vns.childrenTVns[idS] == nil and self.waitingTVns[idS] == nil then
			self:recruit(robotR, vns)
		end
	end

	-- check ack
	for _, msgM in ipairs(VNS.Msg.getAM("ALLMSG", "ack")) do
		if self.waitingTVns[msgM.fromS] ~= nil then
			vns.childrenTVns[msgM.fromS] = self.waitingTVns[msgM.fromS]
			self.waitingTVns[msgM.fromS] = nil
			self.countTN[msgM.fromS] = nil
		end
	end
end

function VNS.modules.connector:recruit(robotR, vns)
	VNS.Msg.send(robotR.idS, "recruit", {math.random()}) 
		--TODO: give vns status in the future
	self.countTN[robotR.idS] = 0
	self.waitingTVns[robotR.idS] = VNS:new{
		idS = robotR.idS,
		locV3 = robotR.locV3,
		dirQ = robotR.dirQ,
	}
end
function VNS.modules.connector:update(robotListR, vns)
	if type(robotListR) ~= "table" then return end

	-- update waiting list
	for idS, robotR in pairs(robotListR) do
		if self.waitingTVns[idS] ~= nil then
			self.waitingTVns[idS].locV3 = robotR.locV3
			self.waitingTVns[idS].dirQ = robotR.dirQ
		end
	end

	-- update vns children list
	for idS, robotR in pairs(robotListR) do
		if vns.childrenTVns[idS] ~= nil then
			vns.childrenTVns[idS].locV3 = robotR.locV3
			vns.childrenTVns[idS].dirQ = robotR.dirQ
		end
	end
end
function VNS.modules.connector:lostCount(robotListR)
	-- lost count
	for idS, _ in pairs(self.waitingTVns) do
		self.countTN[idS] = self.countTN[idS] + 1
		if self.countTN[idS] == 3 then
			self.countTN[idS] = nil
			self.waitingTVns[idS] = nil
		end
	end
end

-- vehicle Connector --------------------------------
VNS.modules.vehicleConnector = { 
	countTN = {},
	waitingTVns = {},
}
setmetatable(VNS.modules.vehicleConnector, {__index = VNS.modules.connector})
function VNS.modules.vehicleConnector:run(vns, paraT)
	self:step(vns, paraT.vehiclesTR)
end

-- parent waitor --------------------------------
VNS.modules.parentwaitor = {
	run = function(self, vns, paraT)
		if vns.parent == nil then
			for _, msgM in pairs(VNS.Msg.getAM("ALLMSG", "recruit")) do
				vns.parent = msgM.fromS
				VNS.Msg.send(msgM.fromS, "ack")
			end
		end
	end,
}

-- driver -----------------------------------------
VNS.modules.driver = {
	run = function(self, vns, paraT)
		-- listen to drive
		local velocityV3, dirQ
		for _, msgM in pairs(VNS.Msg.getAM(vns.parent, "drive")) do
			-- a drive message data is:
			--	{	yourLocV3, yourDirQ,
			--		targetVelocityV3, targetDirQ
			--	}
			local targetVelocityV3 = Linar.myVecToYou(
				msgM.dataAN.targetVelocityV3,
				msgM.dataAN.yourLocV3,
				msgM.dataAN.yourDirQ,
			)
			local targetDirQ = Linar.myQuadToYou(
				msgM.dataAN.targetDirQ,
				msgM.dataAN.yourDirQ,
			)

			-- set velocity
		end

		--for each children
		--fly to rally point
	end,
}

-- running sequence of modules
--[[
VNS.modules = {
	VNS.modules.vehicleConnector,
	VNS.modules.driver,
}
--]]

return VNS
