
--[[

PaRappa The Rapper 2 Freecam

NTSC-U

https://jmk.gg/

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

	1. "Unlock" any addresses you need in the AddressesNeeded array.
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

]]

--[[
TODO:
     - Reset camera to position its suppsoed to be
     - Automatically "Unlock" the values

]]

-- Tilt (0x21C7B520) can break in cutscenes.
-- keep the opcode write window up for the entire time and replace every opcode that shows up with a NOP to enable tilt.
-- If you do not choose to enable tilt, do not unlock 0x21C7B520.
-- If the viewport goes upside down after resetting from this, change the fov

-- These are all the addresses you need to actually unlock
local AddressesNeeded = {
      0x21C7B510, -- If you want Rotation
      0x21C7B520, -- If you want Tilt, Not reccommended. Read Lines 55 to 58
      0x21C7B500, -- If you want Position
      0x21C7B534 -- If you want FOV
}

local Version = "6"

local Addresses = {
	Rotate_Horizontal	= 0x21C7B514,
	Rotate_Vertical	        = 0x21C7B510,
        Rotate_WhateverThisIs	= 0x21C7B518,
        Rotate_Tilt		= 0x21C7B520,
        X			= 0x21C7B500,
        Y			= 0x21C7B504,
        Z		        = 0x21C7B508,
        FOV                     = 0x21C7B534,
        CityHall                = 0x20382508
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
	Move_Forward		= VK_W,
	Move_Backward		= VK_S,
	Move_Left		= VK_A,
	Move_Right		= VK_D,
	Move_Up			= VK_Q,
	Move_Down		= VK_E,

        Tilt_Up			= VK_V,
	Tilt_Down		= VK_N,
        WeirdRotUp              = VK_T,
        WeirdRotDown            = VK_G,

	Exit			= VK_X,
        ResetAllCamera          = VK_R,
        Invert_Speed            = VK_I,
        DeInvert_Speed          = VK_O,
        ResetTilt               = VK_B,

	FOV_In			= VK_Z,
	FOV_Out			= VK_C,

        Speed_Up                = VK_ADD,
        Speed_Down              = VK_SUBTRACT,
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

function clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end

Functions["Root"] = function()
	--[[

	💎 Root

	📄 Description:
	This function runs the mainloop for camera movement.

	]]

    local Speed = Options.Speed

    Functions.Log("To see camera speed ingame. go to the city hall, don't go in, just go to it")

	while(true) do

		local X, Y = getMousePos()
		X = X - Data.RootPosX
		Y = Y - Data.RootPosY
		if isKeyPressed(Controls.Exit) then
			Functions.Log("JMK Freecam Ended", LogTypes.Info)
			Threads["RootThread"]:suspend()
		end

                if isKeyPressed(Controls.Invert_Speed) then
			Speed = -math.abs(Speed)
		end

                if isKeyPressed(Controls.DeInvert_Speed) then
			Speed = math.abs(Speed)
		end

		if isKeyPressed(Controls.FOV_In) then
			writeFloat(
				Addresses.FOV,
				readFloat(Addresses.FOV) - (0.0005 * Speed)
			)
		end

		if isKeyPressed(Controls.FOV_Out) then
			writeFloat(
				Addresses.FOV,
				readFloat(Addresses.FOV) + (0.0005 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Left) then
			writeFloat(
				Addresses.X,
				readFloat(Addresses.X) - (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Right) then
			writeFloat(
				Addresses.X,
				readFloat(Addresses.X) + (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Forward) then
			writeFloat(
				Addresses.Z,
				readFloat(Addresses.Z) - (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Backward) then
			writeFloat(
				Addresses.Z,
				readFloat(Addresses.Z) + (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Up) then
			writeFloat(
				Addresses.Y,
				readFloat(Addresses.Y) + (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Move_Down) then
			writeFloat(
				Addresses.Y,
				readFloat(Addresses.Y) - (0.1 * Speed)
			)
		end

                if isKeyPressed(Controls.Tilt_Up) then
			writeFloat(
				Addresses.Rotate_Tilt,
				readFloat(Addresses.Rotate_Tilt) + (0.001 * Speed)
			)
		end

                if isKeyPressed(Controls.Tilt_Down) then
			writeFloat(
				Addresses.Rotate_Tilt,
				readFloat(Addresses.Rotate_Tilt) - (0.001 * Speed)
			)
		end

                writeString(
                    Addresses.CityHall,
                    "Cam Speed: "..string.sub(Speed,0,4)..", Freecam V"..Version.."@(Tilt buggy, read Line 62)@@@"
                )

    	        if isKeyPressed(Controls.Speed_Up) then
                   Speed = clamp(Speed + 0.005,0.002,10)
		end

                if isKeyPressed(Controls.Speed_Down) then
		   Speed = clamp(Speed - 0.005,0.002,10)
		end

		if isKeyPressed(Controls.ResetAllCamera) then
			writeFloat(Addresses.Rotate_Vertical,0)
			writeFloat(Addresses.Rotate_Horizontal,0)
                        writeFloat(Addresses.FOV,70)
                        Speed = 1
			writeFloat(Addresses.X,0)
			writeFloat(Addresses.Y,0)
			writeFloat(Addresses.Z,0)
                        writeFloat(Addresses.Rotate_WhateverThisIs,0)

		end

                if isKeyPressed(Controls.ResetTilt) then
			writeFloat(Addresses.Rotate_Tilt,0)
		end

                if isKeyPressed(Controls.WeirdRotUp) then
			writeFloat(
			        Addresses.Rotate_WhateverThisIs,
			        readFloat(Addresses.Rotate_WhateverThisIs) + (0.5 * Speed)
		        )
		end

                if isKeyPressed(Controls.WeirdRotDown) then
			writeFloat(
			        Addresses.Rotate_WhateverThisIs,
			        readFloat(Addresses.Rotate_WhateverThisIs) - (0.5 * Speed)
		        )
		end

		writeFloat(
			Addresses.Rotate_Horizontal,
			readFloat(Addresses.Rotate_Horizontal) - (Y * math.abs(Speed))
		)

	        writeFloat(
			Addresses.Rotate_Vertical,
			readFloat(Addresses.Rotate_Vertical) + (X * Speed)
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
