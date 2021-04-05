--[[
@description phoi_Select only empty non-parent tracks with no receives
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local name_exclusions = {"vca", "note", "ref", "mix", "sep"}-- table of keywords to be excluded from selection; case-insensitive

-- NAME
local scriptName = "phoi_Select only empty non-parent tracks with no receives"


--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

--- FUNCTIONS

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
		local track_no_receives
		if not ({reaper.GetTrackReceiveName( track, 0, '' )})[1] then
			track_no_receives = true
		end
		local _, name = reaper.GetTrackName(track)
		local excluded
		for i = 1, #name_exclusions do
			if name:lower():find(name_exclusions[i]:lower()) then
				excluded = true
				break
			end
		end

		if reaper.CountTrackMediaItems(track) < 1 and not track_is_folder and track_no_receives and	not excluded then
			reaper.SetTrackSelected(track, true)
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()