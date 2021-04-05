--[[
@description phoi_Trim right edge of selected items to edit cursor without changing fade-out start times
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Trim right edge of selected items to edit cursor without changing fade-out start times"
local actionId = 41311 -- id of trim action
--Item edit: Trim right edge of item to edit cursor


function main()
	reaper.Undo_BeginBlock()
	
	local items = {}
	local itemCount = reaper.CountSelectedMediaItems(0)
	local pos = reaper.GetCursorPosition()
	local fadeLens = {}

	for i = 0, itemCount - 1, 1 do -- first set necessary fade lengths for each item; late trim the edges
	
		items[i] = reaper.GetSelectedMediaItem(0, i)
		local item = items[i]
		local itemEnd = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		local fadeLen = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
		local fadeStart = itemEnd - fadeLen -- find start point of fade
		local newFadeLen = pos - fadeStart
		
		if newFadeLen <= 0 or fadeLen == 0 then newFadeLen = 0 end --prevent negative fade lengths
		fadeLens[i] = newFadeLen
		 
	end

	reaper.Main_OnCommandEx(actionId, 0, 0) --Item edit: Trim right edge of item to edit cursor

	for i = 0, itemCount - 1, 1 do -- apply fade lengths
		reaper.SetMediaItemInfo_Value(items[i], "D_FADEOUTLEN", fadeLens[i])
	end
	
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()