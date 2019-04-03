Vec3 = require("Vector3")
Quad = require("Quaternion")

Linar = {}
function Linar.myVecToYou(myVec, yourLocation, yourQuaternion)
	local relativeLoc = myVec - yourLocation
	return yourQuaternion:inv():toRotate(relativeLoc)
end

function Linar.myQuadToYou(myQuad, yourQuaternion)
	return myQuad * yourQuaternion:inv()
end

function Linar.yourVecToMe(yourVec, yourLocation, yourQuaternion)
	return yourQuaternion:toRotate(yourVec) + yourLocation
end

return Linar
