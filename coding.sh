vim coding.sh -c "
	tabnew testing/shifterTest.argos
	tabnew testing/shifterTest_vehicle.lua
	vsp testing/shifterTest_quadcopter.lua

	tabnew VNS.lua

	tabnew VNSModules/ShiftUpper.lua
	vsp VNSModules/Shifter.lua

	tabnew VNSModules/Assigner.lua
	vsp VNSModules/Maintainer.lua

	tabnew VNSModules/Driver.lua

	tabnew VNSModules/VehicleConnector.lua
	vsp VNSModules/QuadcopterConnector.lua

	tabnew VNSModules/ParentWaitor.lua
	vsp VNSModules/ParentWaitorDeny.lua

	tabnew VNSModules/LostCounter.lua
	vsp VNSModules/Connector.lua
"

#	tabnew testing/lostTest.argos
#	tabnew testing/lostTest_vehicle.lua
#	vsp testing/lostTest_quadcopter.lua

#	tabnew testing/connectorTest.argos
#	tabnew testing/connectorTest_vehicle.lua
#	vsp testing/connectorTest_quadcopter.lua

#	tabnew testing/driver_quadconnectorTest.argos
#	tabnew testing/driverTest_vehicle.lua
#	vsp testing/driverTest_quadcopter.lua

#	tabnew testing/assignTest.argos
#	tabnew testing/assignTest_vehicle.lua
#	vsp testing/assignTest_quadcopter.lua

#	tabnew testing/shifterTest.argos
#	tabnew testing/shifterTest_vehicle.lua
#	vsp testing/shifterTest_quadcopter.lua

#	tabnew testing/maintainerTest.argos
#	tabnew testing/maintainerTest_vehicle.lua
#	vsp testing/maintainerTest_quadcopter.lua

