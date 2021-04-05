--[[
@description phoi_Render selected area of tracks, muting items - mono, post-fader
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
+ fix metadata
@noindex
--]]

-- USER CONFIG
act_id = 41718 -- render action id

-- NAME
scriptName = ({reaper. get_action_context()})[2]:match("([^/\\]+)%.lua$") -- generate default scriptName from file

-- CODE
local containingFolderPath = ({reaper.get_action_context()})[2]:gsub("(.*)([/\\]).*$","%1" .. "%2") -- extract path of containing folder of script
dofile(containingFolderPath .. "phoi_Render selected area of tracks, muting items.lua")