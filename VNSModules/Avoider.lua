-- Avoider --------------------------------------
------------------------------------------------------
local Vec3 = require("Vector3")
local Quaternion = require("Quaternion")
local Linar = require("Linar")

local Avoider = {VNSMODULECLASS = true}
Avoider.__index = Avoider

function Avoider:new()
	local instance = {}
	setmetatable(instance, self)
	return instance
end

function Avoider:run(vns, paraT)
	for idS, childVns in pairs(vns.childrenTVns) do
		if childVns.avoiderSpeed == nil then
			childVns.avoiderSpeed = {
				locV3 = Vec3:create(),
				dirV3 = Vec3:create(),
			}
		end
		childVns.avoiderSpeed.locV3 = Vec3:create()

		if childVns.robotType == "quadcopter" then
			-- avoid my self
			childVns.avoiderSpeed.locV3 =
				Avoider.add(childVns.locV3, Vec3:create(), Quaternion:create(),
				            childVns.avoiderSpeed.locV3,
				            60)

			-- avoid children
			for jidS, jchildVns in pairs(vns.childrenTVns) do
				if jchildVns.robotType == childVns.robotType then -- else continue
				if idS ~= jidS then -- else continue
	
				childVns.avoiderSpeed.locV3 =
					Avoider.add(childVns.locV3, jchildVns.locV3, jchildVns.dirQ,
					            childVns.avoiderSpeed.locV3,
					            60)
			end end end
		end

		if childVns.robotType == "vehicle" then
			for jidS, robotR in pairs(paraT.vehiclesTR) do
				if jidS ~= idS then
					childVns.avoiderSpeed.locV3 =
						Avoider.add(childVns.locV3, robotR.locV3, robotR.dirQ,
						            childVns.avoiderSpeed.locV3,
						            60)
				end
			end
		end
	end
end

function Avoider.add(myLocV3, obLocV3, obDirQ, accumulatorV3, threshold)
	local dV3 = myLocV3 - obLocV3
	local d = dV3:len()
	local ans = accumulatorV3
	if d < threshold then
		local transV3 = 0.2 / d * dV3:nor()
		local rotatedDV3 = Linar.myVecToYou(dV3, obLocV3, obDirQ)
		local roundV3 = 2 / d * dV3:nor()
		local q
		if rotatedDV3.x < 0 then
			q = Quaternion:create(0, 0, 1, math.pi/2) --* d/threshold)
		else
			q = Quaternion:create(0, 0, 1, math.pi/2) --* d/threshold)
		end
		ans = ans + transV3 + q:toRotate(roundV3)
	end

	return ans
end

return Avoider

