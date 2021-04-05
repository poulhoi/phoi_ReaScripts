--[[
@description phoi_Toggle reference
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
local scriptName = "phoi_Toggle reference"


--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS

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

----- END OF FUNCTIONS

local extname = "phoi_"
local key = "reference"

function main()
	reaper.Undo_BeginBlock()
	local retval, name = reaper.GetProjExtState(0, extname, key)
	if retval then
		local ref
		for i = 0, reaper.CountTracks(0) - 1 do
			local tr = reaper.GetTrack(0, i)
			local _, tr_name = reaper.GetTrackName(tr)
			if tr_name == name then
				ref = tr
				break
			end
		end
		if not ref then return end
		local soloed = reaper.GetMediaTrackInfo_Value(ref, "I_SOLO")
		local val
		if soloed > 0 then val = 1 else val = 0 end
		local sel = saveSelectedTracks()
		setTracksSelected({ref}, true)
		reaper.Main_OnCommand(41313, 0) -- unlock
		reaper.Main_OnCommand(40340, 0) -- unsolo all tracks
		reaper.SetMediaTrackInfo_Value(ref, "I_SOLO", 1-val)

		if muteItems then
			for i = 0, reaper.CountTrackMediaItems(ref) - 1 do
				local it = reaper.GetTrackMediaItem(ref, i)
				reaper.SetMediaItemInfo_Value(it, "B_MUTE_ACTUAL", val)
			end
		end

		if muteTrack then
			reaper.SetMediaTrackInfo_Value(ref, "B_MUTE", val)
		end

		if lockRef and val > 0 then
			reaper.Main_OnCommand(41312, 0) -- lock
		end
		
		setTracksSelected(sel, true)
	else -- if no extstate
		reaper.ShowMessageBox("Please set a track to be a reference track with the script 'phoi_Set reference track.lua'.", "No reference track found", 0)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()