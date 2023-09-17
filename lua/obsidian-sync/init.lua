local api = vim.api

local M = {}

local api_env_var_name = "OBSIDIAN_REST_API_KEY"

local default_config = {
	obsidian_server_address = "http://localhost:27123",
}

api.nvim_create_augroup("obsidian-sync.nvim", {
	clear = true,
})

function M.setup(config)
	local final_config = vim.tbl_extend("keep", config or {}, default_config)

	api.nvim_create_autocmd("BufEnter", {
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local filename_incl_path = vim.api.nvim_buf_get_name(bufnr)
			local api_key = os.getenv(api_env_var_name)
			if api_key == nil then
				vim.api.nvim_err_writeln("Error: " .. api_env_var_name .. " environment variable is not set.")
				vim.api.nvim_out_write(
					"Please set the "
						.. api_env_var_name
						.. " environment variable to use the obsidian-sync.nvim plugin.\n"
				)
			end
			if filename_incl_path == nil or string.sub(filename_incl_path, -3) ~= ".md" then
				-- Silently ignore files without .md extension.
				return
			end

			local server_address = final_config.obsidian_server_address
			local filename = string.match(filename_incl_path, ".+/(.+)$")
			local url = server_address .. "/open/" .. filename
			local authToken = "Bearer " .. api_key
			local request = 'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: '
				.. authToken
				.. '" '
				.. url
				.. " >/dev/null"
			local handle = io.popen(request)
			if handle ~= nil then
				local result = handle:read("*a")
				handle:close()
				if result ~= nil and result ~= "" then
					local decoded = vim.json.decode(result)
					-- Ignore other errors for now, for instance if we can't contact obsidian server it's
					-- not running, that's often times probably intentional.
					if decoded.errorCode == 40101 then
						vim.api.nvim_err_writeln(
							"Error: authentication error, please check your " .. api_env_var_name .. " value."
						)
					end
				end
			end
		end,
		pattern = "*",
		group = "obsidian-sync.nvim",
	})

	return M
end

return M
