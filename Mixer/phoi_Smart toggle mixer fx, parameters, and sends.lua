--[[
@description phoi_Smart toggle mixer fx, parameters, and sends
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_Smart toggle mixer fx, parameters, and sends
-- If any of the listed options are enabled they are all disabled. Else, they are all enabled.
-- For toggling between a full mixer channel layout and a long fader layout.
--]]

-- NAME
local scriptName = "phoi_Smart toggle mixer fx, parameters, and sends"


--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function toggleStateAccum(t)
	local acc = 0
	for i = 1, #t do
		local state = reaper.GetToggleCommandStateEx(0, t[i])
		if state == 1 then acc = acc + 1 end
	end
	return acc
end

function setToggles(ids, enable)
	local function action(cmd) reaper.Main_OnCommand(cmd, 0) end
	for i = 1, #ids do
		local id = ids[i]
		local state = reaper.GetToggleCommandStateEx(0, id)
		if enable and state == 0 then
			action(id)
		elseif not enable and state > 0 then
			action(id)
		end
	end
end


function main()
	reaper.Undo_BeginBlock()
	local opts = {40549, 40910, 40557} -- toggle show inserts, parameters and sends
	local enable = false
	if toggleStateAccum(opts) < 1 then -- if no options are enabled
		enable = true
	end
	setToggles(opts, enable)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
-- reaper.defer(function() end)	 -- Prevent undo if necessary