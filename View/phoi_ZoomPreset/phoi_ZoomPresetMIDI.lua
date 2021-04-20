--[[
@description phoi_ZoomPresetMIDI
@author Poul Høi
@provides [nomain] .
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

zoomSize = reaper.TimeMap2_beatsToTime(0, 0, zoomMeasures ) -- convert zoom area to seconds

function main()

  timeSelStart, timeSelEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
  cursorPos = reaper.GetCursorPositionEx(0)
  zoomStart = cursorPos - (zoomSize / 2)
  zoomEnd = cursorPos + (zoomSize / 2)
  reaper.GetSet_LoopTimeRange2(0, true, true, zoomStart, zoomEnd, false) -- set time selection to zoom area
  reaper.MIDIEditor_LastFocused_OnCommand(40726, false) -- zoom to loop points
  reaper.GetSet_LoopTimeRange2(0, true, true, timeSelStart, timeSelEnd, false) -- reset set time selection
end

reaper.PreventUIRefresh(1)
reaper.defer(main)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()