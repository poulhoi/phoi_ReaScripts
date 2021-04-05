--[[
@description phoi_Trim left edge of selected items to edit cursor without changing fade-in end times
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Trim left edge of selected items to edit cursor without changing fade-in end times"
local actionId = 41305 -- id of trim action
-- Item edit: Trim left edge of item to edit cursor


function main()
	reaper.Undo_BeginBlock()
	local items = {}
	local itemCount = reaper.CountSelectedMediaItems(0)
	local pos = reaper.GetCursorPosition()
	local fadeLens = {}

	for i = 0, itemCount - 1, 1 do -- store necessary fade lengths for each item

		items[i] = reaper.GetSelectedMediaItem(0, i)
		local item = items[i]
		local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		local fadeLen = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
		local fadeEnd = itemStart + fadeLen -- find end point of fade
		local newFadeLen = fadeEnd - pos 
		
		if newFadeLen <= 0 or fadeLen == 0 then newFadeLen = 0 end --prevent negative fade lengths or adding fades that didn't already exist
		fadeLens[i] = newFadeLen

	end

	reaper.Main_OnCommandEx(actionId, 0, 0) -- Perform trim action

	for i = 0, itemCount - 1, 1 do -- apply fade lengths
		reaper.SetMediaItemInfo_Value(items[i], "D_FADEINLEN", fadeLens[i])
	end

	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()