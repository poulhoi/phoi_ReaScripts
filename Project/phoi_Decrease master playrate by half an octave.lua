--[[
@description phoi_Decrease master playrate by half an octave
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

reaper.Undo_BeginBlock()
local playrate = reaper.Master_GetPlayRate( project )
local st = -6
local new_rate = playrate * (2^(st/12))
reaper.CSurf_OnPlayRateChange( new_rate )
reaper.Undo_EndBlock( "Adjust master playrate by " .. st .. " semitones", -1 )