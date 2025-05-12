--[[
Configuration file for Conky
V 1.0
Copyright (C) 2025  Lurgainn
12 May 2025

Linux only! Only tested on Xubuntu 24.10 and with conky
version 'conky-ubuntu-24.04-x86_64-v1.22.1.AppImage'!
All files/dir must be put into the standard
dir '~/.config/conky/'.
It requires the commands:
	'uname'
	'nproc'
	'lsb_release'
	'df'
	'ls'
and the LUA libraries:
    'Lua File System'

LICENSE:
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

--[[
***** IMPORTANT *****
The temperatures of CPU and harddisks, and the RPM of fans
are collected using the '/sys/class/hwmon' filesystem.
The kernel drivers put there all these values, but they
are highly variable because each driver (which is used
depending of your hasrdware) will use their own rules.
So to adapt this configuration file to your hardware
you have to analyze your 'hwmon' directory and then modify
accordingly the 'HWMON CONSTANTS' section.
]]

-- DEBUG only
DEBUG = false

-- ***** FILE SYSTEMS MONITORED *****
NO_EXTERNAL_FS = '${color2}${font1}   NONE:\n'
MOUNT_POINTS_SEPARATOR = '§@ç°'

-- ***** COMMANDS CONSTANTS *****
FIND_FILESYSTEMS = 'df -t ext2 -t ext3 -t ext4 -t vfat -t ntfs -t ntfs3 -t cifs -t nfs -t nfs4 --output=target'

-- Module's variables
local internal_mount_points = {}	-- {mount point}

-- Get a table with all mounted points
local function findMountPoints()
	local f
	local file_systems = ''
	local first = true
	local mounted_paths = {}

	--***** DEBUG
	if DEBUG then print('DEBUG conky.lua: Function findMountPoints() executed.') end
	-- Get all real filesystems
	f = io.popen(FIND_FILESYSTEMS)
	if f ~= nil then
		file_systems = f:read('*a')
		f:close()
		-- Get all important lines but first
		for line in string.gmatch(file_systems, "[^\n]+") do
			if first then
				first = false
			elseif line ~= "" then
				table.insert(mounted_paths, line)
			end
		end
	end
	return mounted_paths
end

function conky_getFsExternalString(fs_internal)
	local updated_mount_points = {}
	local new_mount_points = {}
	local found = false
	local last_dir = ''
	local output = ''

	--***** DEBUG
	if DEBUG then print('DEBUG conky.lua: function conky_getFsExternalString(path) executed.') end
	-- Load the internal mountpoints
	for line in string.gmatch(fs_internal, '[^§@ç°]+') do
		if line ~= '' then
			table.insert(internal_mount_points, line)
		end
	end
	-- Now look for actual mountpoints
	updated_mount_points = findMountPoints()
	-- Find if new
	for _, row1 in ipairs(updated_mount_points) do
		found = false
		for _, row2 in ipairs(internal_mount_points) do
			if row1 == row2 then
				found = true
				break
			end
		end
		-- Add new mount point
		if not found then
			table.insert(new_mount_points, row1)
		end
	end
	-- Display new mount points
	for _, row1 in ipairs(new_mount_points) do
		-- Extract the substring after the last "/"
		last_dir = row1:match('.*/([^/]+)$')
		output = output .. '${color2}' .. last_dir .. ':${alignc}${color0} ${fs_free ' .. row1 .. '} on ${fs_size ' .. row1 .. '} ${alignr}${color3}${fs_bar_free 8,150 ' .. row1 .. '}\n'
	end
	-- Now returns
	if output == '' then
		output = NO_EXTERNAL_FS
	end
	return output
end
