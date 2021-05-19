--[[
@description phoi_Dropdown menu_Example
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@provides
	phoi_Dropdown menu_data.txt
@changelog Initial release
+ Rewrite documentation
--]]

--[[
-- # phoi_Dropdown menu_Example

Based heavily on bFooz's Dropdown menu script (https://forums.cockos.com/showthread.php?t=210482)

Creates a dropdown toolbar from a textfile.
This text file must be formatted like reaper-menu.ini, be named the same as the variable menuDataFileName in this script and located in the same folder as this script.
Menus are named within the data file; to open a menu of a specific name, duplicate this file (phoi_Dropdown menu_Example.lua) and change the name after the last underscore the name of the menu you want to call.
For instance, a script named "phoi_Dropdown menu_Toolbar 1.lua" will look for a menu within "phoi_Dropdown menu_data.txt" (or whatever the variable menuDataFileName is set to) named "Toolbar 1"
The name of a menu is the header enclosed in [], not the "title" of the toolbar.
That means both icons and titles can safely be deleted from the menu data file.

	IMPORTANT NOTE 1: The toolbar name cannot contain underscores.
	
	IMPORTANT NOTE 2: If the toolbar name contains the word "MIDI", the context of the actions will be the Midi Editor.
	Otherwise, it's the main context

In practice:
- Create a toolbar in reaper and populate it with actions.
- Export it. Copy the contents of this newly exported .ReaperMenu file and paste it into the menu data file.
- Duplicate this script file and name it "phoi_Dropdown menu_Menuname.lua", replacing "Menuname" with the header of your new menu.
- This script will now launch a dropdown menu formatted according to the toolbar, without using up a toolbar.

-- TIPS FOR EDITING THE MENU DATA FILE --

No empty lines within each menu section. Empty lines will stop the menu from being generated.

For each line, the script looks at everything after the "=" sign. 
That means that the "item_0" etc. portions do not matter, so actions can easily be inserted.

	HOWEVER: bugs can occur if there is no text before = sign. So start every line with '0=', for example.

Also, all text after the space following the action ID will be the menu entry, so that's also easily edited.

	The structure of the data file is essentially:
	[Menu name] -- as called by the script by its filename
	=ACTION_ID MENU_ENTRY NAME

	example:
	[My locking menu]
	=1135 Toggle lock

EXTRA FEATURES

You can add separators with "=-1"
You can add submenus with "=-2"
You can end the last submenus with "=-3"
Nested submenus are also supported.
If you copy a menu from reaper-menu.ini, this is already set up correctly.

You can chain a series of actions by putting them into the same line separated by commas.
This saves you from making custom actions for specific workflows.
All actions in a chain must belong to the same context,though.

]]

-- USER CONFIG

menuDataFileName = "phoi_Dropdown menu_data.txt" 

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end


function findInTable(name, lines, startFrom)
		local name = name
		local lines = lines
		local startFrom = startFrom
		for key,value in pairs(lines) do
				if string.find(value,name)~=nil and key>=startFrom then
						return key
				end
		end
		return -1
		
end

function executeChain(chain_csv, context) -- copy this function for use in other scripts

	local function fromCSV(vals_csv)
		local t = {}
		local i = 0
		for line in vals_csv:gmatch("[^" .. "," .. "]*") do
			i = i + 1
			t[i] = line
		end
		return t
	end

	chain = fromCSV(chain_csv)

	if #chain > 0 then -- if there is at least one action in chain

		for i = 1, #chain do

			local id = reaper.NamedCommandLookup(chain[i])

			if context == "MAIN" then
				reaper.Main_OnCommand(id, 0)
			elseif context == "MIDI" then
				reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), id)
			end

		end

	end
end

function drawMenu()

			gfx.init("", 0, 0)
			
			gfx.x = gfx.mouse_x
			gfx.y = gfx.mouse_y

			--get names and paths
			local basePath = ({reaper.get_action_context()})[2] -- get script path
			local baseName =	basePath:match("([^/\\]+)%.lua$")
			local containingFolderPath = basePath:gsub("(.*)([/\\]).*$","%1" .. "%2") -- extract path of containing folder of script

			local menuName = baseName:gsub("(.*_)([^_]+)", "%2") -- extract any string after last underscore

			filePath = containingFolderPath.. menuDataFileName

			file = io.open(filePath, "r")
			if not file then return end
			io.close(file)
			
			--get lines
			lines = {}
			for line in io.lines(filePath) do 
				lines[#lines + 1] = line
			end
						
			name = "^%[" .. menuName .. "%]$"
			offsetStart = 1 + findInTable(name, lines, 0)			

			menu = {}
			showString = ""
			i = offsetStart
			while lines[i]~="" and lines[i]~=nil do
					
					if string.find(lines[i],"title") then
								title = string.sub(lines[i],7)
					else		
						id = string.sub(lines[i], string.find(lines[i],"%d+") )
						value = string.sub(lines[i],string.find(lines[i],"=")+1 )
											
						if string.find(value," ")==nil then
								action = value
								if action=="-1" then
										showString = showString .. "|" --separator
								elseif action=="-2" then
										showString = showString .. ">|"
								elseif action=="-3" then
										showString = showString .. "<|" 
								end
								name = ""
						else
								action = string.sub(value, 1, string.find(value," ")-1 )
								name = string.sub(value, string.find(value," ")+1 )
								if action=="-1" then
										showString = showString .. "|" .. name --separator
								elseif action=="-2" then
										showString = showString .. ">".. name .."|"
								elseif action=="-3" then
										showString = showString .. "<".. name .. "|"
								else
										if string.find(menuName,"MIDI") then
													toggleState = reaper.GetToggleCommandStateEx( 32060, reaper.NamedCommandLookup(action,0) )
										else
													toggleState =	reaper.GetToggleCommandState( reaper.NamedCommandLookup(action,0))
										end
										if toggleState==1 then
												showString = showString .. "!" .. name .. "|"
										else
												showString = showString .. name .. "|"
										end
										menu[#menu+1] = {action, name}
								end
						end								
					end --else
					i = i+1
			end --for
			
			retval = gfx.showmenu(showString)
			
			if retval>0 then
					if string.find(menuName,"MIDI") then
							exec = menu[retval][1]
							if exec:find(",") then
								executeChain(exec, "MIDI")
							else
								reaper.MIDIEditor_OnCommand(reaper.MIDIEditor_GetActive(), reaper.NamedCommandLookup(exec))
							end
					else
							exec = menu[retval][1]
							if exec:find(",") then
								executeChain(exec, "MAIN")
							else
								reaper.Main_OnCommand(reaper.NamedCommandLookup(exec),0)
							end
					end
					--reaper.ShowConsoleMsg(reaper.NamedCommandLookup(menu[retval][1]))
			end
		 
			gfx.quit()
end	--function main

drawMenu()