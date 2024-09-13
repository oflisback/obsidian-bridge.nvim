local M = {}

M.api_key_env_var_name = "OBSIDIAN_REST_API_KEY"

M.on = true

M.get_final_config = function(user_config)
	local default_config = {
		obsidian_server_address = "http://localhost:27123",
		scroll_sync = false,
	}
	return vim.tbl_extend("keep", user_config or {}, default_config)
end

M.get_api_key = function()
	local api_key = os.getenv(M.api_key_env_var_name)
	if api_key == nil then
		vim.api.nvim_err_writeln("Error: " .. M.api_key_env_var_name .. " environment variable is not set.")
		vim.api.nvim_out_write(
			"Please set the "
				.. M.api_key_env_var_name
				.. " environment variable to use the obsidian-bridge.nvim plugin.\n"
		)
	end
	return api_key
end

return M
