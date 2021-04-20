--[[
@description phoi_ZoomPresetMIDI_4
@author Poul Høi
@provides [nomain] .
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_ZoomPresetMIDI_4
To create and edit zoom presets, duplicate this file and change the number at the end to the desired zoom size in bars.
Only whole bars are supported atm.
--]]

local zoomscriptName = "phoi_ZoomPresetMIDI.lua"
local _, fileName, section, cmd, _, _, _ = reaper.get_action_context()
local scriptName = fileName:match("([^/\\]+)%.lua$") -- generate default scriptName from file
zoomMeasures = scriptName:gsub("(phoi_ZoomPresetMIDI_)(0*.?%d+)", "%2") -- get zoom size in bars from name
local path = fileName:gsub(scriptName .. ".lua", '')
local zoomScriptPath = path .. zoomScriptName
dofile(zoomScriptPath)