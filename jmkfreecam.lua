--[[
    _           _          __
   (_)         | |        / _|
    _ _ __ ___ | | __    | |_ _ __ ___  ___  ___ __ _ _ __ ___
   | | '_ ` _ \| |/ /    |  _| '__/ _ \/ _ \/ __/ _` | '_ ` _ \
   | | | | | | |   <     | | | | |  __/  __/ (_| (_| | | | | | |
   | |_| |_| |_|_|\_\    |_| |_|  \___|\___|\___\__,_|_| |_| |_|
  _/ |
 |__/

JMK Freecam
for PaRappa The Rapper 2

NTSC-U

© Copyright 2020 JMK

https://jmksite.dev/

Requirements:
	- PCSX2
	- Cheat Engine

License:
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.	If not, see <https://www.gnu.org/licenses/>.

How To Use:
	tl;dr: You just NOP the addresses and then press the Execute Script button.
	
	1. "Unlock" all addresses used below in the Addresses array.
		To do this, repeat the following steps for every address listed:
		View the address in Cheat Engine, right click on each one,
		press the "F6" key or click "Find out what writes to this address".
		If you see a popup asking to attach a debugger, click "OK" or "Yes".
		Once you have done that, check if you see anything in the white box
		on the top left. If you don't see anything, you don't need to do anything
		to that address. If you do see something, right click everything in the
		white box and click "Replace with NOP", which will cause that code to
		no longer function.
	2. Configure the program in the Options array below this.
	3. Run the program with the Execute Script button at the bottom of the
		Cheat Table window.
	4. Done! To use the program, read the controls listed in the Controls array.

Join the PaRappa The Rapper 2 Modding Discord Server at https://discord.gg/xpvVnYd

]]

local Version = "b3"

local Addresses = {
	Rotate_Horizontal	= 0x21C7B514,
	Rotate_Vertical		= 0x21C7B510,
	Rotate_Tilt			= 0x21C7B520,
	FOV					= 0x21C7B508
}

--[[
local Opcodes = {
	Rotate				= {
		Address			= "301283F7",
		Length			= 8
	},
	Tilt				= {
		Address			= "30158025",
		Length			= 4
	},
	FOV					= {
		Address			= "3012828B",
		Length			= 4
	}
}
]]

local Options = {
	Speed				= 1
}

local Controls = {
	Rotate_Forward		= VK_I,
	Rotate_Backward		= VK_K,
	Rotate_Left			= VK_J,
	Rotate_Right		= VK_L,
	
	Exit				= VK_U,
	MouseSet			= VK_O,
	
	FOV_In				= VK_ADD,
	FOV_Out				= VK_SUBTRACT,
}

local Messages = {
	Startup = "JMK PTR2 Freecam Loaded",
	VersionPrefix = "Version ",
}

local LogTypes = {
	Info = "JMK_INFO",
	Warning = "JMK_WARNING",
	Error = "JMK_ERROR"
}

local Data = {
	--[[
		By default the mouse's RootPos is set to the exact center of the screen.
		If you are playing PTR2 in Windowed mode, you may want to set this to somewhere
		within the window.
	]]
	
	RootPosX = getScreenWidth() / 2,
	RootPosY = getScreenHeight() / 2
}

local Functions = {}
local Threads = {}

Functions["Log"] = function(LogString, LogType)
	--[[
	
	📃 Log
	
	📄 Description:
	This function outputs "styled" text to the console.
	
	]]
	
	if LogType == LogTypes.Info then
		print("ℹ️ " .. LogString)
	elseif LogType == LogTypes.Warning then
		print("⚠  " .. LogString)
	elseif LogType == LogTypes.Error then
		error("🛑  " .. LogString)
	else
		return false
	end
end

Functions["Nop"] = function(Address, Length)
	--[[
	
	🚫 Nop
	
	📄 Description:
	This function NOPs specific opcodes.
	
	]]
	
	local OpcodeAsm = [[
	]] .. Address .. [[:
	nop ]] .. tostring(Length) .. [[
	]]
	autoAssemble(OpcodeAsm)
end

Functions["Root"] = function()
	--[[
	
	💎 Root
	
	📄 Description:
	This function runs the mainloop for camera movement.
	
	]]
	
	while(true) do
		local X, Y = getMousePos()
		X = X - Data.RootPosX
		Y = Y - Data.RootPosY
		if isKeyPressed(Controls.Exit) then
			Functions.Log("JMK Freecam Ended", LogTypes.Info)
			Threads["RootThread"]:suspend()
		end

		if isKeyPressed(Controls.FOV_In) then
			writeFloat(
				Addresses.FOV,
				readFloat(Addresses.FOV) + (0.05 * Options.Speed)
			)
		end

		if isKeyPressed(Controls.FOV_Out) then
			writeFloat(
				Addresses.FOV,
				readFloat(Addresses.FOV) - (0.05 * Options.Speed)
			)
		end
		
		writeFloat(
			Addresses.Rotate_Horizontal,
			readFloat(Addresses.Rotate_Horizontal) - (Y * Options.Speed)
		)

		writeFloat(
			Addresses.Rotate_Vertical,
			readFloat(Addresses.Rotate_Vertical) + (X * Options.Speed)
		)
		
		sleep(0.5)
		
		setMousePos(
			Data.RootPosX,
			Data.RootPosY
		)
	end
end

Functions["InitializeOpcodes"] = function()
	--[[
	
	👨‍💻 InitializeOpcodes (Opcodes)
	
	📄 Description:
	This function NOPs all the opcodes for you to skip "How To Use: Part 1".
	
	]]
	
	for OpcodeName, OpcodeItem in pairs(Opcodes) do
		Functions.Nop(
			OpcodeItem.Address,
			OpcodeItem.Length
		)
	end
end

Functions["InitializeThreads"] = function()
	--[[
	
	🔌 InitializeThreads (Threading)
	
	📄 Description:
	This function initializes the threads to be run by RunThreads.
	
	]]
	
	Threads["RootThread"] = createThreadSuspended(Functions["Root"])
end

Functions["RunThreads"] = function()
	--[[
	
	🔌 RunThreads (Threading)
	
	📄 Description:
	This function runs threads created by InitializeThreads.
	
	]]
	
	Threads["RootThread"]:resume()
end

Functions["Main"] = function()
	--[[
	
	☀ Main
	
	📄 Description:
	This function starts the freecam.
	
	]]
	
	Functions.Log(
		Messages.Startup,
		LogTypes.Info
	)
	
	Functions.Log(
		Messages.VersionPrefix .. Version,
		LogTypes.Info
	)
	
	--[[
	
	🎛 Initialization
	
	]]	
	Functions["InitializeThreads"]()
	-- This has been disabled due to address changes.
	-- Functions["InitializeOpcodes"]()
	Functions["RunThreads"]()
end

Functions["Main"]()