--[[
@description phoi_Select only mono items on selected tracks
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local chanTarget = 1 -- number of channels of items that should be selected

-- NAME
local scriptName = "phoi_Select only mono items on selected tracks"

-- FUNCTIONS
local function msg(s)
	reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

local function unselectAllItems ()
	while (reaper.CountSelectedMediaItems(0) > 0) do
		reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
	end
end

local function setItemsSelected (itemsT, unselectOthers) -- zero-indexed table of items as input
	if unselectOthers then unselectAllItems() end

	for i = 0, #itemsT do
		local item = itemsT[i]
		if reaper.ValidatePtr(item, "MediaItem*") then
			reaper.SetMediaItemSelected(item, true)
		end
	end
end

function main()
	reaper.Undo_BeginBlock()
	local targetItems = {}
	local x = 0
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
	    local tr = reaper.GetSelectedTrack(0, i)
	    for j = 0, reaper.CountTrackMediaItems(tr) - 1 do
	        local it = reaper.GetTrackMediaItem(tr, j)
	        local tk = reaper.GetActiveTake(it)
	        if tk and not reaper.TakeIsMIDI(tk) then
		        local src = reaper.GetMediaItemTake_Source(tk)
		        local srcChans = reaper.GetMediaSourceNumChannels(src)
		        if srcChans == chanTarget then -- add item to table if source channels equal to target
		        	targetItems[x] = it
		        	x = x + 1
		        end
		    end
	    end
	end
    setItemsSelected(targetItems, true)
    reaper.SetCursorContext( 1, nil ) -- focus arrange
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()