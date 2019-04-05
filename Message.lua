-----------------------------------------------------------
-- 	Weixu Zhu
-- 		zhuweixu_harry@126.com
--
-- 	Version 1.0 : 
-- 		Packet.sendTable sends a table
-- 		Packet.getTablesAT gets an array of tables
-- 	Version 1.1 : 
-- 		add function for Vector3 and Quaternion recover
-----------------------------------------------------------
local Message = {}
Message.Packet = require("Packet")
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")

function Message.myIDS()
	print("Message.myIDS() needs to be implement")
end

function Message.send(toIDS, cmdS, dataT)
	Message.Packet.sendTable{
		toS = toIDS,
		fromS = Message.myIDS(),
		cmdS = cmdS,
		dataT = dataT,
	}
end

function Message.getAM(fromS, cmdS)
	local listAM = {}
	local i = 0
	for iN, msgM in ipairs(Message.Packet.getTablesAT()) do
		if msgM.toS == Message.myIDS() then
		if fromS == "ALLMSG" or fromS == msgM.fromS then
		if cmdS == "ALLMSG" or cmdS == msgM.cmdS then
			i = i + 1
			listAM[i] = msgM
		end end end
	end

	return listAM
end

function Message.recoverV3(v3T)
	if type(v3T.x) == "number" and 
	   type(v3T.y) == "number" and 
	   type(v3T.z) == "number" then
		return Vec3:create(v3T.x, v3T.y, v3T.z)
	else
		return nil
	end
end

function Message.recoverQ(qT)
	qT.v = Message.recoverV3(qT.v)
	if qT.v ~= nil and 
	   type(qT.w) == "number" then
		return Quaternion:createFromHardValue(qT.v.x, qT.v.y, qT.v.z, qT.w)
	else
		return nil
	end
end

return Message
