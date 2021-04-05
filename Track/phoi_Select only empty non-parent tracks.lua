--[[
@description phoi_Select only empty non-parent tracks
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = "phoi_Select only empty non-parent tracks"


-- FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function UnselectAllTracks()
	while reaper.CountSelectedTracks(0) > 0 do
		local track = reaper.GetSelectedTrack(0, 0)
		reaper.SetTrackSelected(track, false)
	end
end

function main()
	reaper.Undo_BeginBlock()
	UnselectAllTracks()
	for i = 0, reaper.CountTracks(0) - 1 do
		local sel
		local track = reaper.GetTrack(0, i)
		local track_is_folder = reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH" ) == 1
		if reaper.CountTrackMediaItems(track) < 1 and not track_is_folder then
			reaper.SetTrackSelected(track, true)
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()