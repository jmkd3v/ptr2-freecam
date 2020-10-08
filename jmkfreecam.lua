--[[

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

Join the PaRappa The Rapper 2 Discord Server at https://discord.gg/xpvVnYd

]]

local Version = "b0"

local Addresses = {
	Rotate_X	= 0x21C7B514,
	Rotate_Z	= 0x21C7B510,
	Rotate_Tilt	= 0x21C7B520,
	FOV			= 0x21C7B508
}

local Options = {
 	Speed_Delay	= 0.1,
	Speed_Run	= 10000,
	Speed_FOV	= 0.5
}

local Controls = {
	Rotate_Forward	= VK_I,
	Rotate_Backward	= VK_K,
	Rotate_Left		= VK_J,
	Rotate_Right	= VK_L,
	Exit			= VK_U,
    MouseSet        = VK_O,
	FOV_In			= VK_ADD,
	FOV_Out			= VK_SUBTRACT
}

local LogTypes = {
	Info = "JMK_INFO",
	Warning = "JMK_WARNING",
	Error = "JMK_ERROR"
}

local Data = {
	RootPosX = 700,
    RootPosY = 700
}

local Functions = {}
local Threads = {}

Functions["Log"] = function(LogString, LogType)
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

Functions["Root"] = function()
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
		readFloat(Addresses.FOV) + Options.Speed_FOV
	   )
	end

	if isKeyPressed(Controls.FOV_Out) then
	   writeFloat(
		Addresses.FOV,
		readFloat(Addresses.FOV) - Options.Speed_FOV
	   )
	end

	writeFloat(
	  Addresses.Rotate_X,
	  readFloat(Addresses.Rotate_X) - (Y)
	)

	 writeFloat(
	   Addresses.Rotate_Z,
	   readFloat(Addresses.Rotate_Z) + (X)
	 )
	sleep(Options.Speed_Delay)
	setMousePos(Data.RootPosX, Data.RootPosY)
	end
end

Functions["InitializeThreads"] = function()
	Threads["RootThread"] = createThreadSuspended(Functions["Root"])
end

Functions["RunThreads"] = function()
	Threads["RootThread"]:resume()
end

Functions["Main"] = function()
	Functions.Log("JMK PTR2 Freecam Started", LogTypes.Info)
	Functions.Log("Version " .. Version, LogTypes.Info)
	Functions["InitializeThreads"]()
	Functions["RunThreads"]()
end

Functions["Main"]()