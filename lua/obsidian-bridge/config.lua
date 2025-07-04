local M = {}

M.api_key_env_var_name = "OBSIDIAN_REST_API_KEY"

M.on = true

M.final_config = nil

-- Function constructs the table that should be
-- passed to curl's raw option
-- Allows for an arbitrary number of argument pairs
local function construct_raw_args(args)
	local raw = {}
	for arg, value in pairs(args) do
		if value then
			table.insert(raw, arg)
			table.insert(raw, value)
		end
	end
	return raw
end

-- function normalizes the user provided
-- certpath, treating "" like nil
-- or expanding it to a full path
local function normalize_certpath(cert_path)
	-- treat empty string as nil
	if cert_path == "" then
		return nil
	elseif cert_path == nil then
		return nil
	else
		-- expand full path
		local full = vim.fn.expand(cert_path)
		return full
	end
end

-- This function checks whether the server URL
-- ends with a trailing slash
local function check_url(final)
	local trailing_slash = string.sub(final.obsidian_server_address, -1) == "/"
	if trailing_slash then
		vim.notify("Stripping trailing '/' from Obsidian server URL.", vim.log.levels.DEBUG)
		final.obsidian_server_address = string.sub(final.obsidian_server_address, 1, -2)
	end
end

-- This function checks for SSL misconfigurations
-- and warns the user
local function check_for_ssl_errors(final)
	local https_url = string.find(final.obsidian_server_address, "^https") ~= nil
	local localhost_url = string.find(final.obsidian_server_address, "localhost") ~= nil
	if https_url and localhost_url then
		vim.notify("'localhost' will not work with SSL. Please use '127.0.0.1' instead!", vim.log.levels.ERROR)
	end
	if https_url == true and final.cert_path == nil then
		vim.notify("You have provided an HTTPS url without a CA certificate!", vim.log.levels.ERROR)
	end
	if https_url == false and final.cert_path ~= nil then
		vim.notify(
			"You provided a CA certificate with an HTTP URL. Are you sure you didn't mean to use an HTTPS URL?",
			final.WARN
		)
	end
	if final.cert_path ~= nil and not (vim.uv or vim.loop).fs_stat(final.cert_path) then
		-- User did not provide a valid path!
		vim.notify("Cert path is not valid!", vim.log.levels.ERROR)
	end
end

local function check_picker(final)
	local network = require("obsidian-bridge.network")
	if not network.pickers[final.picker] then
		vim.notify('Invalid picker: "' .. final.picker .. '"', vim.log.levels.ERROR)
	end
end

M.create_final_config = function(user_config)
	local default_config = {
		obsidian_server_address = "http://localhost:27123",
		scroll_sync = false,
		-- Do not require cert by default
		cert_path = nil,
		-- Show configuration warnings
		warnings = true,
		picker = "telescope",
	}
	local final = vim.tbl_extend("keep", user_config or {}, default_config)
	-- Set warning suppression if requested by the user
	if final.warnings then
		final.WARN = vim.log.levels.WARN
	else
		final.WARN = vim.log.levels.OFF
	end
	-- normalize the user input
	final.cert_path = normalize_certpath(final.cert_path)
	-- check for misconfigurations, warn the user if found
	check_for_ssl_errors(final)
	-- check for the selected picker
	check_url(final)
	-- empty table if cert_path == nil
	-- extendable, other curl args can go here
	final.raw_args = construct_raw_args({
		["--cacert"] = final.cert_path,
	})
	check_picker(final)
	M.final_config = final
end

M.get_api_key = function()
	local api_key = os.getenv(M.api_key_env_var_name)
	if api_key == nil then
		vim.notify(
			M.api_key_env_var_name
			.. " environment variable is not set. Please set "
			.. M.api_key_env_var_name
			.. " in your shell configuration.",
			vim.log.levels.ERROR
		)
	end
	return api_key
end

return M
