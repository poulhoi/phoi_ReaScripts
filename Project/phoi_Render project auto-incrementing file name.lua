--[[
@description phoi_Render project auto-incrementing file name
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- Finds the number at the end of the render pattern and automatically increments it.

-- NAME
local scriptName = 'phoi_Render project auto-incrementing file name'

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function countDigits(string)
	local sub = string:match('%d+')
	return sub:len()
end

function addLeadingZeros(int, leadingZeros) -- returns as string
	local int_str = tostring(int)
	for i = 1, leadingZeros do
		if math.abs(int) < (10 ^ leadingZeros) then
			int = int * 10
			if int >= 0 then
				int_str = "0" .. int_str
			else
				int_str = "-0" .. int_str:gsub('-', '')
			end
		end
	end
	return int_str
end

function removeDecimalPoint(str)
	local decPoint = str:find("%.")
	if decPoint then str = str:sub(0, decPoint - 1) end
	return str
end

function main()
	local retval, pattern = reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', '', false)
	if not retval then reaper.MB("Render pattern could not be retrieved.", "Error", 0) end
	local pattern_number = pattern:match('%d*$')
	if pattern_number == '' then return end
	local pattern_str = pattern:gsub('%d+$', '')
	local len = countDigits(pattern_number)
	local pattern_number_int = tonumber(pattern_number)
	pattern_number_int = pattern_number_int + 1
	if len > 0 then
		pattern_number = addLeadingZeros(pattern_number_int, len-1)
	else
		pattern_number = tostring(pattern_number_int)
	end
	pattern_number = removeDecimalPoint(pattern_number)
	reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', pattern_str .. pattern_number, true)
end

main()
reaper.Main_OnCommand(41824, 0)