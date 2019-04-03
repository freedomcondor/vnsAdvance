function showTable(table, number)
	if number == nil then number = 0 end
	if type(table) ~= "table" then return nil end

	local xyz = nil
	if table.x ~= nil and table.y ~= nil and table.z ~= nil then
		xyz = "x"
	end

	for i, v in pairs(table) do
		if i == "x" or i == "y" or i == "z" then
			if xyz == "x" then
				i = "x"  v = table.x
				xyz = "y"
			elseif xyz == "y" then
				i = "y"  v = table.y
				xyz = "z"
			elseif xyz == "z" then
				i = "z"  v = table.z
				xyz = nil
			end
		end

		local str = ""
		for j = 1, number do
			str = str .. "\t"
		end

		str = str .. tostring(i) .. "\t"

		if type(v) == "table" then
			print(str)
			showTable(v, number + 1)
		else
			str = str .. tostring(v)
			print(str)
		end
	end
end

