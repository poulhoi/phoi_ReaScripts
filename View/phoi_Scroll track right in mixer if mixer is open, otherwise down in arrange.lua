--[[
@description phoi_Scroll track right in mixer if mixer is open, otherwise down in arrange
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
	+ fixed error when project has no tracks
--]]

local mixerDist = 12

function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. '\n')
end

function varMsg(var, name)
	msg(tostring(name) .. " : " .. tostring(var))
end

function ScrollArrangeDown()
	local arrangeAct_id = reaper.NamedCommandLookup("_XENAKIOS_TVPAGEDOWN")
	reaper.Main_OnCommand(arrangeAct_id, 0)
end

function ScrollMixerRight(dist)
	local t = {}
	local tr_count = reaper.CountTracks(0)-1
  	if tr_count < 1 then return end
	for i = 0, tr_count do
		local track = reaper.GetTrack(0,i)
		if track and reaper.IsTrackVisible(track, true) then -- true = MCP, false = TCP 
			t[#t+1] = track 
		end
	end 
	local tr = reaper.GetMixerScroll()
	for i = 1, #t-mixerDist do
		if tr == t[i] then 
			reaper.SetMixerScroll(t[i+mixerDist])
			break
		end
	end
end

function IsMixerOpen()
	local ret = false
	local state = reaper.GetToggleCommandState(40078)
	if state > 0 then ret = true end
	return ret
end

if IsMixerOpen() then
	ScrollMixerRight(mixerDist)
else
	ScrollArrangeDown()
end
reaper.defer(function () end)