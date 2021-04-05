--[[
@description phoi_Set all mono tracks to mono pan mode
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local chanTarget = 1 -- number of channels of items that should be included
local allowEmpty = true -- allow tracks containing empty items to have their pan modes changed
local allowMidi = true -- allow tracks containing MIDI items to have their pan modes changed
local preventEmptyOnly = false --disallow tracks containing only empty items to have their pan modes changed
local preventMidiOnly = true --disallow tracks containing only MIDI items to have their pan modes changed

-- NAME
local scriptName = "phoi_Set all mono tracks to mono pan mode"

-- FOR DEBUG
local function msg(s)
	reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

--- FUNCTIONS

local function setTracksPanModeMono (tracksT) -- zero-indexed table of tracks as input
	for i = 0, #tracksT do
		local track = tracksT[i]
		if reaper.ValidatePtr(track, "MediaTrack*") then
			reaper.SetMediaTrackInfo_Value(track, "I_PANMODE", 3)
		end
	end
end
	
----- END OF FUNCTIONS

function main()
	reaper.Undo_BeginBlock()
	local targetTracks = {}
	local x = 0
	for i = 0, reaper.CountTracks(0) - 1 do
	    local tr = reaper.GetTrack(0, i)
	    local found = false
    	local emptyOnly = true
    	local midiOnly = true
	    if reaper.CountTrackMediaItems(tr) == 0 then -- do not add empty tracks to table
	    	found = true
	    end
	    if not found then
		    for j = 0, reaper.CountTrackMediaItems(tr) - 1 do 
		        local it = reaper.GetTrackMediaItem(tr, j)
		        local tk = reaper.GetActiveTake(it)
			    if tk then
			    	emptyOnly = false
			    	if not reaper.TakeIsMIDI(tk) then 
			    		midiOnly = false
			    	elseif not allowMidi then
			    		found = true
			    	end
			        local src = reaper.GetMediaItemTake_Source(tk)
			        local srcChans = reaper.GetMediaSourceNumChannels(src)
			        if srcChans > chanTarget then -- do not add track to table if source channels of any one item is greater than target
			        	found = true
			        	break
			        end
			    elseif not allowEmpty then
			    	found = true
			    	break
			    end
		    end
		end
		if (preventEmptyOnly and emptyOnly) or (preventMidiOnly and midiOnly) then
			found = true
		end
	    if not found then
        	targetTracks[x] = tr
        	x = x + 1
        end
	end
    setTracksPanModeMono(targetTracks)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()