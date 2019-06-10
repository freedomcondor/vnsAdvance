-- quadcopter-vehicle Connector --------------------------------
------------------------------------------------------
local Connector = require("Connector")
local QGConnector = {VNSMODULECLASS = true}
setmetatable(QGConnector, Connector)
QGConnector.__index = QGConnector

function QGConnector:new()
	local instance = Connector:new()
	setmetatable(instance, self)
	instance.robotType = "vehicle" -- child type
	return instance
end

function QGConnector:run(vns, paraT)
	-- Quadcopter part
	if vns.robotType == "quadcopter" then
		self:step(vns, paraT.vehiclesTR)
	-- Vehicle part
	elseif vns.robotType == "vehicle" then
		if vns.parentS == nil then
			for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
				vns.parentS = msgM.fromS
				vns.Msg.send(msgM.fromS, "ack")
				break
			end
		end
	end
end

return QGConnector
