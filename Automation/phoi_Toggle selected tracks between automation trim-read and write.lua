--[[
@description phoi_Toggle selected tracks between automation trim-read and write
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
	--[[
	Automation modes: 
		0: trim/read
		1: read
		2: touch
		3: write
		4: latch
		5: latch preview
	]]

local offMode = 0 -- "default mode" when toggle is off.
local onMode = 3 -- "target mode" when is toggle is on

-- NAME
local scriptName = "phoi_Toggle selected tracks between automation trim-read and write"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS

function main()
	reaper.Undo_BeginBlock()
	local tCount = reaper.CountSelectedTracks(0)
	local tracks = {}
	local targetMode
	local found = false
	for i = 1, tCount do
		local tr = reaper.GetSelectedTrack(0, i-1)
		tracks[i] = tr
		local autoMode = reaper.GetMediaTrackInfo_Value(tr, "I_AUTOMODE")
		if not found and autoMode ~= onMode then
			found = true
		end
	end

	if found then  -- if any one track is not in latch, set all selected to latch
		targetMode = onMode
	else -- else set all selected to trim/read
		targetMode = offMode
	end

	for i = 1, tCount do
		local tr = tracks[i]
		reaper.SetMediaTrackInfo_Value(tr, "I_AUTOMODE", targetMode)
	end

	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()