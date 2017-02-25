function extend_rec(nData, xData)
	
	for name, d in pairs(nData) do
		
		if xData[name] ~= nil then
		
			if type(nData[name]) == "table" then
				nData[name] = extend_rec(nData[name], xData[name])
			else
				nData[name] = xData[name]
			end
		end
		
	end
	
	return nData
end

function extend_data(extend)
	local extended = {}
	
	for cat, _ in pairs(extend) do

		if data.raw[cat] ~= nil and extend[cat] ~= nil then
	
			for extName, extData in pairs(extend[cat]) do
				local nData = table.deepcopy(data.raw[cat][extName])
				
				if nData ~= nil then
					if extData.func ~= nil then
						nData = extData.func(cat, extName, nData)						
					end
					
					if nData ~= nil then
						nData = extend_rec(nData, extData)
					end
					
					if nData ~= nil then
						table.insert(extended, nData)
					end
				end
				
				
			end
		end
	
	end
	
	return extended
end