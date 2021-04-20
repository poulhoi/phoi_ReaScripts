--[[
@description phoi_Move edit cursor to first of selected items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
+ fix error when no item selected
--]]

-- NAME
local scriptName = "phoi_Move edit cursor to first of selected items"

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	local first_item_pos
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local item = reaper.GetSelectedMediaItem(0, i)
		local item_pos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
		if i == 0 then
			first_item_pos = item_pos
		else
			first_item_pos = math.min(first_item_pos, item_pos)
		end
	end
	if not first_item_pos then return end
	reaper.SetEditCurPos2(0, first_item_pos, true, false)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()