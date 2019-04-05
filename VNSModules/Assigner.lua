-- Assigner --------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local Assigner = {VNSMODULECLASS = true}
Assigner.__index = Assigner

function Assigner:new()
	local instance = {}
	setmetatable(instance, self)

	instance.parentLocV3 = Vec3:create()

	return instance
end

function Assigner:run(vns)
	-- Shoule happens before connector
	-------------
	--  recruit from myAssignParent --> ack
	--  							--> bye
	--
	
	for _, msgM in ipairs(vns.Msg.getAM(vns.myAssignParent, "recruit")) do
		vns.Msg.send(msgM.fromS, "ack")
		if vns.myAssignParent ~= vns.parentS then
			vns.Msg.send(vns.parentS, "assign_bye") end
		vns.parentS = msgM.fromS
		break
	end

	for _, msgM in ipairs(vns.Msg.getAM("ALLMSG", "assign_bye")) do
		if vns.childrenTVns[msgM.fromS] ~= nil then
			vns:deleteChild(msgM.fromS)
		end
	end

	for _, msgM in ipairs(vns.Msg.getAM(vns.parentS, "assign")) do
		vns.myAssignParent = msgM.dataT.assignToS
	end

	-- allcate children
	if vns.childrenAssignTS == nil then return end

	for idS, childVns in pairs(vns.childrenTVns) do
		if vns.childrenAssignTS[idS] ~= nil then
			local assignToS = vns.childrenAssignTS[idS]
			if vns.childrenTVns[assignToS] ~= nil then
				childVns.rallyPoint = {
					locV3 = vns.childrenTVns[assignToS].locV3,
					--dirQ = vns.childrenTVns[assignToS].dirQ,
					dirQ = Quaternion:create()
				}
			elseif vns.parentS == assignToS then
				-- update parentLoc by drive message
				for _,msgM in ipairs(vns.parentS, "drive") do
					local yourLocV3 = vns.Msg.recoverV3(msgM.dataT.yourLocV3)
					local yourDirQ = vns.Msg.recoverQ(msgM.dataT.yourDirQ)
					self.parentLocV3 = Linar.myVecToYou(Vec3:create(), yourLocV3, yourDirQ)
					break
				end
				childVns.rallyPoint = {
					locV3 = vns.childrenTVns[assignToS].locV3,
					dirQ = Quaternion:create()
				}
			end
		end
	end
end

function Assigner:assign(_childidS, _assignToIds, vns)
	if vns.childrenAssignTS == nil then
		vns.childrenAssignTS = {} end
	vns.childrenAssignTS[_childidS] = _assignToIds
	vns.Msg.send(_childidS, "assign", {assignToS = _assignToIds})
end

return Assigner
