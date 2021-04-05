--[[
@description phoi_Reposition items - advanced
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Reposition items - advanced"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function getSelectedItems()
	local items = {}
	local iCount = reaper.CountSelectedMediaItems(0)
	for i = 1, iCount do
		items[i] = reaper.GetSelectedMediaItem(0, i - 1)
	end
	return items
end

function getSelectedItemsOnTrack(track)
	local items = {}
	for i = 0, reaper.CountTrackMediaItems(track) - 1 do
		local it = reaper.GetTrackMediaItem(track, i)
		if reaper.IsMediaItemSelected(it) then items[#items+1] = it end
	end
	return items
end

function toCSV(tt)
-- Convert from table to CSV string
	
	local function escapeCSV(s) --Used to escape "'s by toCSV
		if string.find(s, '[,"]') then
				s = '"' .. string.gsub(s, '"', '""') .. '"'
		end
		return s
	end
			
	local s = ""

	for _,p in ipairs(tt) do	
		s = s .. "," .. escapeCSV(p)
	end

	return string.sub(s, 2)			-- remove first comma
end
	
function fromCSV(vals_csv, outputTypes)
	local t = {}
	local i = 0
	for line in vals_csv:gmatch("[^" .. "," .. "]*") do
		i = i + 1	
		if #outputTypes == 1 and outputTypes[1] == "number" then
			t[i] = tonumber(line)
		elseif outputTypes[i] == "number" then
			t[i] = tonumber(line)
		else
			t[i] = line
		end
	end
	return t
end

function multiUserInput(outputTypes, windowName, numberOfParams, paramNames, defaultVals, saveVals, valsPersist, valsKeySuffix) 
--[[ returns retval, input values as a table
Examples:

retval, inputs = multiUserInput({"number"}, "Test", 3, {"Threshold", "Ratio", "Output"}, {-18, 4, 6}, true, false, "")
if retval then msg(inputs[1]) end

Note: outputTypes can take a 1-element table, which will apply that value type to all inputs.
Otherwise specify output type for each value
--]]
	
	paramNames_csv = toCSV(paramNames)

	
	if saveVals and reaper.HasExtState(scriptName, scriptName .. "_Vals" .. valsKeySuffix) then -- restore previous values on run if saveVals is true and the values exist
		defaultVals_csv = reaper.GetExtState(scriptName, scriptName .. "_Vals" .. valsKeySuffix)
	else
		defaultVals_csv = toCSV(defaultVals)
	end



	retval, retvals_csv = reaper.GetUserInputs(tostring(windowName), numberOfParams, paramNames_csv, defaultVals_csv)

	if retval and saveVals then
		reaper.SetExtState(scriptName, scriptName .. "_Vals" .. valsKeySuffix, retvals_csv, valsPersist) -- save new defaults
	end

	if retval then
		vals = fromCSV(retvals_csv, outputTypes)
	else
		vals = nil
	end

	return retval, vals
end

function reposition(items, dist, fromStart, offset) -- fromStart and offset 0/1
	local times = {}
	for j = 1, #items do
		local it = items[j]
		if j > 1 then -- if this is not first iteration
			reaper.SetMediaItemPosition(it, times[j - 1] + dist, false)
		end
		local p = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
		if fromStart <= 0 then p = p + reaper.GetMediaItemInfo_Value(it, "D_LENGTH") end
		if offset > 0 then p = p + reaper.GetMediaItemInfo_Value(it, "D_SNAPOFFSET") end
		times[j] = p
	end
end

function main()
	reaper.Undo_BeginBlock()
	local retval, inputs = multiUserInput(
		{"number"}, 
		scriptName, 
		5, 
		{"Distance", "Seconds / Beats (0/1)", "From end / start of prev. item (0/1)", "Per track (0/1)", "Include snap offset (0/1)"}, 
		{"1", "0", "0", "1", "1"}, 
		true, 
		true, 
		'') 
	if not retval then return end
	local input_dist, input_beats, input_fromStart, input_perTrack, input_offset = inputs[1], inputs[2], inputs[3], inputs[4], inputs[5]
	--msg(tostring(input_beats) .. " " ..	tostring(input_dist) .. " " ..	tostring(input_fromStart) .. " " .. tostring(input_perTrack) .. " " ..	tostring(input_offset))
	if input_beats > 0 then input_dist = reaper.TimeMap2_beatsToTime(0, input_dist) end
	if input_perTrack > 0 then
		local tracks = {} 
		for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
			local it = reaper.GetSelectedMediaItem(0, i)
			local tr = reaper.GetMediaItemTrack(it)
			if tr ~= tracks[#tracks] then tracks[#tracks+1] = tr end
		end
		for i = 1, #tracks do
			local tr = tracks[i]
			local items = getSelectedItemsOnTrack(tr)
			reposition(items, input_dist, input_fromStart, input_offset)
		end
	else
		items = getSelectedItems()
		reposition(items, input_dist, input_fromStart, input_offset)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()