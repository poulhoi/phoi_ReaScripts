--[[
@description phoi_Select all items after cursor
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- CONFIG
local include_length = true -- set to true to include the length of items and not only consider their start positions
local unselect = true -- set to true to overwrite current item selection

-- NAME
local scriptName = 'phoi_Select all items after cursor'

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	--unselect
	if unselect then
		while reaper.CountSelectedMediaItems(0) > 0 do
			reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
		end
	end
	local pos = reaper.GetCursorPositionEx(0)
	local items = {}
	for i = 0, reaper.CountMediaItems(0) - 1 do
		local item = reaper.GetMediaItem(0, i)
		local item_pos = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
		if include_length then
			item_end = item_pos + reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')	
		end
		if item_pos > pos then
			items[#items+1] = item
		elseif item_end then
			if item_end > pos then
				items[#items+1] = item
			end
		end
	end
	for i = 1, #items do
		reaper.SetMediaItemSelected(items[i], true)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()