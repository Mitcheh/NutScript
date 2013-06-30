--[[
	Purpose: Library for console and chat command adding and proccessing.
--]]

nut.command = nut.command or {}
nut.command.buffer = nut.command.buffer or {}

if (SERVER) then
	--[[
		Purpose: Checks if the command exists and determines what should be returned to the
		PlayerSay hook.
	--]]
	function nut.command.RunCommand(client, action, arguments)
		local commandTable = nut.command.buffer[action]
		local echo = false

		if (commandTable) then
			if (commandTable.OnRun) then
				if (commandTable.superAdminOnly) then
					if (!client:IsSuperAdmin()) then
						nut.util.Notify(nut.lang.Get("no_perm", client:Name()), client)

						return
					end
				elseif (commandTable.adminOnly) then
					if (!client:IsAdmin()) then
						nut.util.Notify(nut.lang.Get("no_perm", client:Name()), client)

						return
					end
				end

				local result = commandTable:OnRun(client, arguments)

				if (result == false) then
					echo = true
				end

				if (#arguments > 0) then
					print(client:Name().." has ran command '/"..action.." "..table.concat(arguments, " ").."'")
				else
					print(client:Name().." has ran command '/"..action.."'")
				end
			end
		else
			nut.util.Notify("That command does not exist.", client)
		end

		if (!echo) then
			return ""
		end
	end

	--[[
		Purpose: A console command as an alternative to the chat commands.
	--]]
	concommand.Add("nut", function(client, command, arguments)
		local action = string.lower(arguments[1] or "")
		table.remove(arguments, 1)

		for k, v in pairs(arguments) do
			if (type(v) == "string") then
				v = string.gsub(v, "\\", "")
				v = string.gsub(v, "'", "\"")
			end
		end

		if (!nut.command.buffer[action]) then
			nut.util.Notify("That command does not exist.", client)
		else
			nut.command.RunCommand(client, action, arguments)
		end
	end)

	--[[
		Purpose: Parses a command using various regular expressions which supports arguments
		that are enclosed in quotes. It also takes all the arguments and packs them into a
		table. This function calls nut.command.RunCommand and returns its return value.
	--]]
	function nut.command.ParseCommand(client, text)
		if (string.sub(text, 1, 1) == "/") then
			local arguments = {}
			local text2 = string.sub(text, 2)
			local quote = (string.sub(text2, 1, 1) != "\"")

			for chunk in string.gmatch(text2, "[^\"]+") do
				quote = !quote

				if (quote) then
					table.insert(arguments, chunk)
				else
					for chunk in string.gmatch(chunk, "[^ ]+") do
						table.insert(arguments, chunk)
					end
				end
			end

			local command = string.lower(arguments[1] or "")
			
			if (command) then
				table.remove(arguments, 1)

				local value = nut.command.RunCommand(client, command, arguments)

				if (value) then
					return value
				end
			end
		end
	end

	--[[
		Purpose: Makes an attempt to find a player based off the givens tring with
		nut.util.FindPlayer, otherwise it notifies the given player that the person
		could not be found.
	--]]
	function nut.command.FindPlayer(client, name)
		local fault = nut.lang.Get("no_ply")

		if (!name) then
			nut.util.Notify(fault, client)

			return
		end

		local target = nut.util.FindPlayer(name)

		if (!IsValid(target)) then
			nut.util.Notify(fault, client)
		end

		return target
	end
end

--[[
	Purpose: A function that inserts a command into the command system.
--]]
function nut.command.Register(commandTable, command)
	nut.command.buffer[command] = commandTable
end