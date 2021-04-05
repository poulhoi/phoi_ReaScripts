--[[
@description phoi_Smart toggle items locked
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_Smart toggle items locked
-- Locks all selected items if at least one of them is not locked. Otherwise unlocks the items.
-- Ensures that all selected items will have the same locked state.
--]]

-- NAME
local scriptName = "phoi_Smart toggle items locked"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	local found = false
	local setting = 0
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local it = reaper.GetSelectedMediaItem(0, i)
		local lockState = reaper.GetMediaItemInfo_Value(it, "C_LOCK")
		if lockState == 0 then found = true end
	end
	if found then setting = 1 end
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local it = reaper.GetSelectedMediaItem(0, i)
		reaper.SetMediaItemInfo_Value(it, "C_LOCK", setting)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()