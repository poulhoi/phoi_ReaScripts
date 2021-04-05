--[[
@description phoi_Scroll track left in mixer if mixer is open, otherwise up in arrange
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local mixerDist = 12

function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. '\n')
end

function varMsg(var, name)
	msg(tostring(name) .. " : " .. tostring(var))
end

function ScrollArrangeUp()
	local arrangeAct_id = reaper.NamedCommandLookup("_XENAKIOS_TVPAGEUP")
	reaper.Main_OnCommand(arrangeAct_id, 0)
end

function ScrollMixerLeft(dist)
	local t = {}
	local tr_count = reaper.CountTracks(0)-1
	for i = 0, tr_count do
		local track = reaper.GetTrack(0,i)
		if track and reaper.IsTrackVisible(track, true) then -- true = MCP, false = TCP 
			t[#t+1] = track 
		end
	end 
	local tr = reaper.GetMixerScroll()
	local scroll = false
	for i = #t, mixerDist+1, -1 do
		if tr == t[i] then 
			scroll = true
			reaper.SetMixerScroll(t[i-mixerDist])
			break
		end
	end
	if not scroll then
		reaper.SetMixerScroll(t[1])
	end
end

function IsMixerOpen()
	local ret = false
	local state = reaper.GetToggleCommandState(40078)
	if state > 0 then ret = true end
	return ret
end

if IsMixerOpen() then
	ScrollMixerLeft(mixerDist)
else
	ScrollArrangeUp()
end
reaper.defer(function () end)