--[[
@description phoi_Set next item to use same take as current item and select it
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = 'phoi_Set next item to use same take as current item and select it'

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		local item = reaper.GetSelectedMediaItem(0, i)
		if not item then 
			no_undo = true
			return 
		end
		local item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
		local track = reaper.GetMediaItem_Track(item)
		local next_item = reaper.GetTrackMediaItem(track, item_id + 1)
		if next_item then
			reaper.SetMediaItemSelected(item, false)
			reaper.SetMediaItemSelected(next_item, true)
			local item_take_idx = reaper.GetMediaItemInfo_Value(item, 'I_CURTAKE')
			reaper.SetMediaItemInfo_Value(next_item, 'I_CURTAKE', item_take_idx)
		else
			no_undo = true
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

local no_undo = false
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
if no_undo then reaper.defer(function() end) end  -- Prevent undo if necessary