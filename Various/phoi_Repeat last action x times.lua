--[[
@description phoi_Repeat last action x times
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local no_undo = false

function main()
	reaper.Undo_BeginBlock()
	local last_act = reaper.Undo_CanUndo2(0)
	local script_name
	if last_act:find("phoi_Repeat") then 
		no_undo = true
		return 
	end

	local retval, repeats = reaper.GetUserInputs("Repeat last action x times", 1, "Number of repeats:", "1")
	if retval then
		for i = 1, repeats do
			reaper.Main_OnCommand(3000, 0) -- repeat last
		end
	end

	if last_act then
		script_name = "phoi_Repeat '" .. last_act .. "' " .. repeats .. " times"
	else
		script_name = "phoi_Repeat last action " .. repeats .. " times"
	end 
	reaper.Undo_EndBlock(script_name, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
if no_undo then reaper.defer(function() end) end  -- Prevent undo if necessary