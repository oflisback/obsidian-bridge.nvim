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
		if not config.on then
			vim.api.nvim_echo({ { "obsidian-bridge activated", "InfoMsg" } }, false, {})
			config.on = true
		end
	end
	vim.cmd("command! ObsidianBridgeOn lua ObsidianBridgeOn()")

	function ObsidianBridgeOff()
		if config.on then
			vim.api.nvim_echo({ { "obsidian-bridge deactivated", "InfoMsg" } }, false, {})
			config.on = false
		end
	end
	vim.cmd("command! ObsidianBridgeOff lua ObsidianBridgeOff()")

	function ObsidianBridgeToggle()
		if config.on then
			ObsidianBridgeOff()
		else
			ObsidianBridgeOn()
		end
	end
	vim.cmd("command! ObsidianBridgeToggle lua ObsidianBridgeToggle()")
end

return M
