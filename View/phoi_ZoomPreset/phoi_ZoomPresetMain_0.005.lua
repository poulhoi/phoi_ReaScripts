--[[
@description phoi_ZoomPresetMain_0.005
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_ZoomPresetMain_0.005
To create and edit zoom presets, duplicate this file and change the number at the end to the desired zoom size in seconds.
--]]

local zoomscriptName = ""phoi_ZoomPresetMain.lua""
local _, fileName, section, cmd, _, _, _ = reaper.get_action_context()
local scriptName = fileName:match("([^/\\]+)%.lua$") -- generate default scriptName from file
zoomSize = scriptName:gsub("(phoi_ZoomPresetMain_)(0*.?%d+)", "%2") -- get zoom size in seconds from name
local path = fileName:gsub(scriptName .. ".lua", '')
local zoomScriptPath = path .. zoomScriptName
dofile(zoomScriptPath)