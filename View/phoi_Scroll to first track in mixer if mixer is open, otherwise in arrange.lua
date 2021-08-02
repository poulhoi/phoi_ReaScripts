--[[
@description phoi_Scroll to first track in mixer if mixer is open, otherwise in arrange
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
	+ fixed error when project has no tracks
--]]

function ScrollArrangeHome()
	local arrangeAct_id = reaper.NamedCommandLookup("_XENAKIOS_TVPAGEHOME")
	reaper.Main_OnCommand(arrangeAct_id, 0)
end

function ScrollMixerHome()
	local dest
	local tr_count = reaper.CountTracks(0)-1
  	if tr_count < 1 then return end
	for i = 0, tr_count do
		local track = reaper.GetTrack(0,i)
		if track and reaper.IsTrackVisible(track, true) then -- true = MCP, false = TCP 
			dest = track
			break
		end
	end 
	reaper.SetMixerScroll(dest)
end

function IsMixerOpen()
	local ret = false
	local state = reaper.GetToggleCommandState(40078)
	if state > 0 then ret = true end
	return ret
end

if IsMixerOpen() then
	ScrollMixerHome()
else
	ScrollArrangeHome()
end
reaper.defer(function () end)