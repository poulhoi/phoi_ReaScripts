--[[
@description phoi_Go to end of time selection or selected items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

function getItemEnd(item)
	itemEnd = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
	return itemEnd
end

function main()
	reaper.Undo_BeginBlock()
	local newEndTime
	local nameSuffix
	local tStart, tEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	if tStart == tEnd then --if time selection doesn't exist
		if reaper.CountSelectedMediaItems(0) < 1 then return end -- abort if also no items selected

		local item
		for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
			local it = reaper.GetSelectedMediaItem(0, i)
			local itEnd = getItemEnd(it)
			if i > 0 then
				local itPrev = reaper.GetSelectedMediaItem(0, i - 1)
				if itEnd > getItemEnd(itPrev) then
					item = it
				elseif getItemEnd(itPrev) > itEnd then
					item = itPrev
				end
			end
		end
		if item == nil then item = reaper.GetSelectedMediaItem(0, reaper.CountSelectedMediaItems(0) - 1) end -- get last item if no other is defined 
		newEndTime = getItemEnd(item)
		nameSuffix = "selected items"
	else
		newEndTime = tEnd
		nameSuffix = "time selection"
	end
	reaper.SetEditCurPos2( 0, newEndTime, true, false )
	scriptName = "Go to end of " .. nameSuffix
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()