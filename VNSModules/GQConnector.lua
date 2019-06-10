-- vehicle Connector --------------------------------
------------------------------------------------------
local Connector = require("Connector")
local VehicleConnector = {VNSMODULECLASS = true}
setmetatable(VehicleConnector, Connector)
VehicleConnector.__index = VehicleConnector

function VehicleConnector:new()
	local instance = Connector:new()
	setmetatable(instance, self)
	instance.robotType = "vehicle"
	return instance
end

function VehicleConnector:run(vns, paraT)
	-- quadcopter
	if vns.robotType == "quadcopter" then
	-- vehicle 
	elseif vns.robotType == "vehicle" then
		if vns.parentS != nil then
			for _, msgM in pairs(vns.Msg.getAM("ALLMSG", "recruit")) do
				vns.parentS = msgM.fromS
				vns.Msg.send(msgM.fromS, "deny")
				vns.Msg.send(msgM.fromS, "recruit")
				break
			end
		end
	end
end

return VehicleConnector
