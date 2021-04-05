--[[
@description phoi_Trim right edge of selected items to next item start
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local allowTrimToEnd = true

-- NAME
local scriptName = "phoi_Trim right edge of selected items to next item start"

--FUNCTIONS FOR DEBUG
function msg(s)
	reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

--- FUNCTIONS

function getSelectedItems()
	local items = {}
	for i = 1, reaper.CountSelectedMediaItems(0) do
		items[i] = reaper.GetSelectedMediaItem(0, i - 1)
	end
	return items
end

function getNextItemOnSameTrack(it)
	local itIdx = reaper.GetMediaItemInfo_Value(it, "IP_ITEMNUMBER")
	local tr = reaper.GetMediaItemTrack(it)
	local itNext = reaper.GetTrackMediaItem( tr, itIdx + 1 )
	return itNext
end

local function restoreSelectedItemsFromTable (table)
  for _, item in ipairs(table) do
    if reaper.ValidatePtr(item, "MediaItem*") then
      reaper.SetMediaItemInfo_Value(item, "B_UISEL", 1)
    end
  end
end

local function unselectAllItems ()
  while (reaper.CountSelectedMediaItems(0) > 0) do
    reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
  end
end

local function setItemSelected (item, unselectOthers)
  if unselectOthers then unselectAllItems() end
  if reaper.ValidatePtr(item, "MediaItem*") then
    reaper.SetMediaItemSelected(item, true)
  end
end

----- END OF FUNCTIONS


function main()
	reaper.Undo_BeginBlock()
	local items = getSelectedItems()

	for i = 1, #items do
		local it = items[i]
		local itNext = getNextItemOnSameTrack(it)
		if itNext ~= nil then -- if next item is on the same track 
			local endIt = reaper.GetMediaItemInfo_Value(it, "D_POSITION") + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
			local posItNext = reaper.GetMediaItemInfo_Value(itNext, "D_POSITION")
			local diff = posItNext - endIt
			if diff > 0 then
				setItemSelected(it, true)
				reaper.ApplyNudge(0, 0, 3, 1, diff, false, 0) -- nudge right edge by difference
			end
		elseif allowTrimToEnd then
			local endIt = reaper.GetMediaItemInfo_Value(it, "D_POSITION") + reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
			local endProj = reaper.GetProjectLength( 0 )
			local diff = endProj - endIt
			if diff > 0 then
				setItemSelected(it, true)
				reaper.ApplyNudge(0, 0, 3, 1, diff, false, 0) -- nudge right edge by difference
			end
		end
	end
	restoreSelectedItemsFromTable(items)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()