--[[
@description phoi_Toggle floating window open for selected items' take FX slot _
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
@metapackage
@provides
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 1.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 2.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 3.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 4.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 5.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 6.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 7.lua
	[main] . > phoi_Toggle floating window open for selected items' take FX slot 8.lua
--]]

-- NAME
local scriptName = ({reaper.get_action_context()})[2]:match("([^/\\]+)%.lua$") -- get script name
local fx = tonumber(scriptName:match("%d+")) -- extract number from script name

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end


function main()
	reaper.Undo_BeginBlock()
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local it = reaper.GetSelectedMediaItem(0, i)
		local tk = reaper.GetActiveTake(it)
		if reaper.TakeFX_GetCount( tk ) >= fx then
			fx = fx - 1
			if not reaper.TakeFX_GetOpen(tk, fx) then
				reaper.TakeFX_Show( tk, fx, 3 )
			else
				reaper.TakeFX_Show( tk, fx, 2 )
			end
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()