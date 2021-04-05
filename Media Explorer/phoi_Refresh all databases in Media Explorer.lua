--[[
@description phoi_Refresh all databases in Media Explorer
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]


-- USER CONFIG
local scriptName = "phoi_Refresh all databases in Media Explorer"

--FUNCTIONS FOR DEBUG
function msg(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

----- END OF FUNCTIONS


function main()
	reaper.Undo_BeginBlock()
	local prompt = reaper.ShowMessageBox("Refresh all databases? It may take some time.", scriptName, 1)
	if prompt == 1 then
		local explorerHWND = reaper.OpenMediaExplorer("", false)
		reaper.JS_Window_OnCommand(explorerHWND, 42087) -- Remove missing files from all databases
		reaper.JS_Window_OnCommand(explorerHWND, 42086) -- Rescan all files in all databases
		reaper.JS_Window_OnCommand(explorerHWND, 42085) -- Scan all databases for new files
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

main()