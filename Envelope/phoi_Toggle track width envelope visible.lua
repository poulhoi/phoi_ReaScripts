--[[
@description phoi_Toggle track width envelope visible
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local targetEnv = "Width" -- name of envelope to toggle hidden/shown
local act_id = 41870 -- id of action to show envelope if it does not exist

-- NAME
local scriptName = "phoi_Toggle track width envelope visible"

function msg(s) reaper.ShowConsoleMsg(s..'\n') end

function toggleEnvelopeHidden(env)
	local br_env = reaper.BR_EnvAlloc( env, false )
	local active, visible, armed, inLane, laneHeight, defaultShape, _, _, _, _, faderScaling, _ = reaper.BR_EnvGetProperties( br_env )
	visible = not visible
	reaper.BR_EnvSetProperties( br_env, active, visible, armed, inLane, laneHeight, defaultShape, faderScaling )
	reaper.BR_EnvFree( br_env, true )
end

function main()
	reaper.Undo_BeginBlock()
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		local tr = reaper.GetSelectedTrack(0, i)
		local env
		local found = false
		for j = 0, reaper.CountTrackEnvelopes(tr) - 1 do
			local e = reaper.GetTrackEnvelope(tr, j)
			local retval, name = reaper.GetEnvelopeName(e)
			if name == targetEnv then
				env = e
				found = true
				break
			end
		end
		if found then
			toggleEnvelopeHidden(env)
		else
			reaper.Main_OnCommand(act_id, 0)
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()