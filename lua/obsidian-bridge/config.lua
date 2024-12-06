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

-- This function checks for SSL misconfigurations
-- and warns the user
local function check_for_cert_errors(final)
	local https_url = string.find(final.obsidian_server_address, "^https") ~= nil
	if https_url == true and final.cert_path == nil then
		vim.notify("Error: You have provided an HTTPS url without a CA certificate!", vim.log.levels.ERROR)
	end
	if https_url == false and final.cert_path ~= nil then
		vim.notify(
			"obsidian-bridge.nvim: You provided a CA certificate with an HTTP URL. Are you sure you didn't mean to use an HTTPS URL?",
			vim.log.levels.WARN
		)
	end
	if final.cert_path ~= nil and not (vim.uv or vim.loop).fs_stat(final.cert_path) then
		-- User did not provide a valid path!
		vim.notify("obsidian-bridge.nvim: You did not provide a valid cert path!", vim.log.levels.ERROR)
	end
end

M.create_final_config = function(user_config)
	local default_config = {
		obsidian_server_address = "http://localhost:27123",
		scroll_sync = false,
		-- Do not require cert by default
		cert_path = nil,
	}
	local final = vim.tbl_extend("keep", user_config or {}, default_config)
	-- normalize the user input
	final.cert_path = normalize_certpath(final.cert_path)
	-- check for misconfigurations, warn the user if found
	check_for_cert_errors(final)
	-- empty table if cert_path == nil
	-- extendable, other curl args can go here
	final.raw_args = construct_raw_args({
		["--cacert"] = final.cert_path,
	})
	M.final_config = final
end

M.get_api_key = function()
	local api_key = os.getenv(M.api_key_env_var_name)
	if api_key == nil then
		vim.notify("Error: " .. M.api_key_env_var_name .. " environment variable is not set.", vim.log.levels.ERROR)
		vim.notify(
			"Please set the "
				.. M.api_key_env_var_name
				.. " environment variable to use the obsidian-bridge.nvim plugin.",
			vim.log.levels.WARN
		)
	end
	return api_key
end

return M
