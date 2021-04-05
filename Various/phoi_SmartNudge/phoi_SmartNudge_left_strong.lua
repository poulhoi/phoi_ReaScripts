--[[
@noindex
@description phoi_SmartNudge_left_strong
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
settingReverse = true --set true to nudge left, otherwise right
settingValMult = 4 --multiplier for nudge value
-- END CONFIG

local nudgescriptName = "phoi_SmartNudge.lua"

local _, fileName, section, cmd, _, _, _ = reaper.get_action_context()
local scriptName = "fileName:match("([^/\\]+)%.lua$") -- generate default scriptName from file"
local path = fileName:gsub(scriptName .. ".lua", '')
local nudgeScriptPath = path .. nudgeScriptName
dofile(nudgeScriptPath)