--[[
@description phoi_Set reference track
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local muteItems = true
local muteTrack = true
local lockRef = true

-- NAME
local scriptName = "phoi_Set reference track"


--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

----- END OF FUNCTIONS

local extname = "phoi_"
local key = "reference"

function main()
	reaper.Undo_BeginBlock()
	 -- deactivate old reference if it exists
	local retval, cur_ref_name = reaper.GetProjExtState(0, extname, key)
	if retval > 0 then
		local function saveSelectedTracks()
			local t = {}
			for i = 0, reaper.CountSelectedTracks(0) - 1 do
				local tr = reaper.GetSelectedTrack(0, i)
				t[#t+1] = tr
			end
			return t
		end

		local function unselectAllTracks()
			while (reaper.CountSelectedTracks(0) > 0) do
				reaper.SetTrackSelected(reaper.GetSelectedTrack(0, 0), false)
			end
		end

		local function setTracksSelected(tracksT, unselectOthers) -- zero-indexed table of tracks as input
			if unselectOthers then unselectAllTracks() end

			for i = 0, #tracksT do
				local track = tracksT[i]
				if reaper.ValidatePtr(track, "MediaTrack*") then
					reaper.SetTrackSelected(track, true)
				end
			end
		end
		local t_sel, cur_ref
		t_sel = saveSelectedTracks()
		for i = 0, reaper.CountTracks(0) - 1 do
			local tr = reaper.GetTrack(0, i)
			local _, tr_name = reaper.GetTrackName(tr)
			if tr_name == cur_ref_name then
				cur_ref = tr
				break
			end
		end
		if not cur_ref then return end
		setTracksSelected({cur_ref}, true)
		reaper.Main_OnCommand(41313, 0) -- unlock
		reaper.SetMediaTrackInfo_Value(cur_ref, "I_SOLO", 0)

		if muteItems then
			for i = 0, reaper.CountTrackMediaItems(cur_ref) - 1 do
				local it = reaper.GetTrackMediaItem(cur_ref, i)
				reaper.SetMediaItemInfo_Value(it, "B_MUTE_ACTUAL", 1)
			end
		end

		if muteTrack then
			reaper.SetMediaTrackInfo_Value(cur_ref, "B_MUTE", 1)
		end

		if lockRef then
			reaper.Main_OnCommand(41312, 0) -- lock
		end
		setTracksSelected(t_sel, true)
	end

	local tr = reaper.GetSelectedTrack(0, 0)
	if not tr then reaper.ShowMessageBox("Please select a reference track.", "Error", 1) end
	local _, name = reaper.GetTrackName(tr)
	if name == '' then reaper.ShowMessageBox("Please name your reference track.", "Error", 1) end
	reaper.SetProjExtState(0, extname, key, name)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
reaper.defer(function() end)   -- Prevent undo if necessary