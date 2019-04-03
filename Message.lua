-----------------------------------------------------------
-- 	Weixu Zhu
-- 		zhuweixu_harry@126.com
--
-- 	Version 1.0 : 
-- 		Packet.sendTable sends a table
-- 		Packet.getTablesAT gets an array of tables
-----------------------------------------------------------
local Message = {}
Message.Packet = require("Packet")

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

return Message
