--[[
@description phoi_Select only tracks of selected items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local exclusive = true -- to select only the tracks of selected items, not add to selection

-- NAME
local scriptName = "phoi_Select only tracks of selected items"

function unselectAllTracks()
	while reaper.CountSelectedTracks(0) > 0 do
		local tr = reaper.GetSelectedTrack(0, 0)
		reaper.SetTrackSelected(tr, false)
	end
end


function main()
	reaper.Undo_BeginBlock()
	if exclusive then unselectAllTracks() end
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local it = reaper.GetSelectedMediaItem(0, i)
		local it_track = reaper.GetMediaItem_Track(it)
		reaper.SetTrackSelected(it_track, true)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()