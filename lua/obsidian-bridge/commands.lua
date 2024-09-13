local config = require("obsidian-bridge.config")
local network = require("obsidian-bridge.network")

local M = {}

M.register = function(configuration, api_key)
	function ObsidianBridgeDailyNote()
		if config.on then
			network.execute_command(configuration, api_key, "POST", "daily-notes")
			-- would be neat if it also opened daily note
		end
	end
	vim.cmd("command! ObsidianBridgeDailyNote lua ObsidianBridgeDailyNote()")
	function ObsidianBridgeTelescopeCommand()
		if config.on then
			network.telescope_command(configuration, api_key)
		end
	end
	vim.cmd("command! ObsidianBridgeTelescopeCommand lua ObsidianBridgeTelescopeCommand()")

	function ObsidianBridgeOpenGraph()
		if config.on then
			network.execute_command(configuration, api_key, "POST", "graph:open")
		end
	end
	vim.cmd("command! ObsidianBridgeOpenGraph lua ObsidianBridgeOpenGraph()")

	function ObsidianBridgeOpenVaultMenu()
		if config.on then
			network.execute_command(configuration, api_key, "POST", "app:open-vault")
		end
	end
	vim.cmd("command! ObsidianBridgeOpenVaultMenu lua ObsidianBridgeOpenVaultMenu()")

	function ObsidianBridgeOn()
		config.on = true
	end
	vim.cmd("command! ObsidianBridgeOn lua ObsidianBridgeOn()")

	function ObsidianBridgeOff()
		config.on = false
	end
	vim.cmd("command! ObsidianBridgeOff lua ObsidianBridgeOff()")

	function ObsidianBridgeToggle()
		config.on = not config.on
	end
	vim.cmd("command! ObsidianBridgeToggle lua ObsidianBridgeToggle()")
end

return M
