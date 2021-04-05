--[[
@description phoi_ZoomPresetMain
@author Poul Høi
@provides [nomain] .
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

function main()
	timeSelStart, timeSelEnd = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	cursorPos = reaper.GetCursorPositionEx(0)
	zoomStart = cursorPos - (zoomSize / 2)
	zoomEnd = cursorPos + (zoomSize / 2)
	reaper.GetSet_LoopTimeRange2(0, true, false, zoomStart, zoomEnd, false) -- set time selection to zoom area
	reaper.Main_OnCommandEx(40031, 0, 0)
	reaper.GetSet_LoopTimeRange2(0, true, false, timeSelStart, timeSelEnd, false) -- set time selection to zoom area
end

reaper.PreventUIRefresh(1)
reaper.defer(main)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()