--[[
@description phoi_Go to start of time selection or selected items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = ""Go to start of time selection or selected items""

function main()
	reaper.Undo_BeginBlock()
	local newStartTime
	local tStart, tEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	if tStart == tEnd then --if time selection doesn't exist
		if reaper.CountSelectedMediaItems(0) < 1 then return end -- abort if also no items selected

		-- find earliest item
		local item
		local earliestPos = reaper.GetProjectLength(0)
		for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
			local it = reaper.GetSelectedMediaItem(0, i)
			local itPos = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
			if itPos < earliestPos then
				item = it
				earliestPos = itPos
			end
		end
		if item == nil then item = reaper.GetSelectedMediaItem(0, 0) end -- get first item if no other is defined 
		newStartTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		nameSuffix = "selected items"
	else
		newStartTime = tStart
		nameSuffix = "time selection"
	end
	reaper.SetEditCurPos2( 0, newStartTime, true, false )
	scriptName = "Go to start of " .. nameSuffix
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()