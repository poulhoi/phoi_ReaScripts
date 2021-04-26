--[[
@description phoi_Toggle selected midi notes muted
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]


function main()
	reaper.Undo_BeginBlock()
	take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
	if take then
  		retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)
  		for k = 0, notes-1 do
	  		retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, k)
	  		if sel == true then
	  			reaper.MIDI_SetNote( take, k, true, not muted )	
	  		end
	  	end
	end
	reaper.Undo_EndBlock("phoi_Toggle selected midi notes muted", 0)
end

main()

reaper.UpdateArrange()