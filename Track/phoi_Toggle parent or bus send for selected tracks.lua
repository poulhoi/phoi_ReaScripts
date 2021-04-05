--[[
@description phoi_Toggle parent or bus send for selected tracks
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_Toggle parent or bus send for selected tracks
-- An alternative to muting tracks which will defeat solo. It will also retain all other sends.
-- Toggles either the parent send or the send to a bus if the track has such a send. 
-- Recognition of such is based on the name of the bus track.
-- I.e. the script assumes that any track will only ever send to one bus, eg. a track whose name contains 'bus'.
--]]

--CONFIG
local bus_name = "bus" -- string to look for in bus track; case-insensitive

-- NAME
local scriptName = "phoi_Toggle parent or bus send for selected tracks"

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		local found
		local track = reaper.GetSelectedTrack(0, i)
		local num_hw_outs = reaper.GetTrackNumSends(track, 1)
		for j = 0, reaper.GetTrackNumSends(track, 0) - 1 do
			send_idx = num_hw_outs + j
			local retval, name = reaper.GetTrackSendName(track, send_idx, '')
			if name:lower():find(bus_name:lower()) then
				reaper.ToggleTrackSendUIMute(track, send_idx)
				found = true
				break
			end
		end
		if not found then
			local b_parent_send = reaper.GetMediaTrackInfo_Value(track, 'B_MAINSEND')
			b_parent_send = 1 - b_parent_send -- invert 1/0
			reaper.SetMediaTrackInfo_Value(track, 'B_MAINSEND', b_parent_send)
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()