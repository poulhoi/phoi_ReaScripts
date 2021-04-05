--[[
@description phoi_Toggle tracks hidden and deactivated
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Toggle tracks hidden and deactivated"

function main()
	reaper.Undo_BeginBlock()
	reaper.Main_OnCommandEx(41313, 0 , 0) --unlock track controls

	local tracks = {} --save track selection
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
			tracks[#tracks+1] = reaper.GetSelectedTrack(0, i)
	end

	trackSelectCount = reaper.CountSelectedTracks(0) --count selected tracks
	for i = 0, trackSelectCount - 1, 1 do
		track = reaper.GetSelectedTrack(0, i) -- get track per iteration
		numFx = reaper.TrackFX_GetCount(track)
		if numFx > 0 then	 -- if the track has any effects, no. of FX online is the parameter which decides if track is locked or unlocked
			numFxOnline = 0
			for iFx = 0, numFx - 1, 1 do
			-- get if every FX of the track is online
				if reaper.TrackFX_GetOffline(track, iFx) == false then
					numFxOnline = numFxOnline + 1
				end
			end
			reaper.Main_OnCommandEx(40297, 0 ,0) --Track: Unselect all tracks
			reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1) -- select only the current track in iteration
			-- if every fx is offline, then activate track. Else de-activate
			if numFxOnline == 0 then
				reaper.Main_OnCommandEx(reaper.NamedCommandLookup('_SWSTL_BOTH'), 0, 0) --show tracks
				reaper.Main_OnCommandEx(41313, 0 , 0) --unlock track controls
				reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0) -- unmute the current track
				reaper.Main_OnCommandEx(40536, 0 ,0) --Track: Set all FX online for selected tracks
			else
				reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1) -- mute the current track
				reaper.Main_OnCommandEx(40535, 0 ,0) --Track: Set all FX offline for selected tracks
				reaper.Main_OnCommandEx(41312, 0 , 0) --lock track controls
				reaper.Main_OnCommandEx(reaper.NamedCommandLookup('_SWSTL_HIDE'), 0, 0) --hide tracks
			end
		else --if the track has no fx, the script will decide what to do based on if the track is muted or not
			reaper.Main_OnCommandEx(40297, 0 ,0) --Track: Unselect all tracks
			reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 1) -- select only the current track in iteration
			trackMuted = reaper.GetMediaTrackInfo_Value(track, "B_MUTE") -- if track is muted, then activate track. Else de-activate
			if trackMuted == 1 then
				reaper.Main_OnCommandEx(reaper.NamedCommandLookup('_SWSTL_BOTH'), 0, 0) --show tracks
				reaper.Main_OnCommandEx(41313, 0 , 0) --unlock track controls
				reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0) -- unmute the current track
			else
				reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1) -- mute the current track
				reaper.Main_OnCommandEx(40535, 0 ,0) --Track: Set all FX offline for selected tracks
				reaper.Main_OnCommandEx(41312, 0 , 0) --lock track controls
				reaper.Main_OnCommandEx(reaper.NamedCommandLookup('_SWSTL_HIDE'), 0, 0) --hide tracks
			end
		end
        for j = 1, #tracks do -- restore saved track selection
            reaper.SetTrackSelected(tracks[j], true)
        end
    end		
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()