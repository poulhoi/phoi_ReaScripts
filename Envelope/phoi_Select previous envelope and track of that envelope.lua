--[[
@description phoi_Select previous envelope and track of that envelope
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

reaper.PreventUIRefresh(1)
reaper.Main_OnCommand(41863, 0) -- Select previous envelope
local env = reaper.GetSelectedEnvelope( 0 )
if env then 
	local track, _, _ = reaper.Envelope_GetParentTrack( env )
	reaper.SetOnlyTrackSelected(track)
	reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
	reaper.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
end
reaper.PreventUIRefresh(-1)