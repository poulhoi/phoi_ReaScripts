--[[
@description phoi_Trim left edge of selected items to previous item end
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local allowTrimToStart = true

-- NAME
local scriptName = "phoi_Trim left edge of selected items to previous item end"

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

function getPrevItemOnSameTrack(it)
	local itIdx = reaper.GetMediaItemInfo_Value(it, "IP_ITEMNUMBER")
	local tr = reaper.GetMediaItemTrack(it)
	local itPrev = reaper.GetTrackMediaItem( tr, itIdx - 1 )
	return itPrev
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
		local itPrev = getPrevItemOnSameTrack(it)
		if itPrev ~= nil then -- if previous item is on the same track 
			local posIt = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
			local endItPRev = reaper.GetMediaItemInfo_Value(itPrev, "D_POSITION") + reaper.GetMediaItemInfo_Value(itPrev, "D_LENGTH")
			local diff = posIt - endItPRev
			if diff > 0 then
				setItemSelected(it, true)
				reaper.ApplyNudge(0, 0, 1, 1, diff, true, 0) -- nudge left edge left by difference
			end
		elseif allowTrimToStart then
			local posIt = reaper.GetMediaItemInfo_Value(it, "D_POSITION")
			if posIt > 0 then
				setItemSelected(it, true)
				reaper.ApplyNudge(0, 0, 1, 1, posIt, true, 0) -- nudge left edge left to start
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