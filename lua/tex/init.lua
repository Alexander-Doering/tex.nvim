local M = {}

--- @class tex.Autocmd
--- @field cmd string[]
--- @field opts vim.SystemOpts
--- @field handler function(vim.SystemCompleted)

---@param content string buffer content
local open_window = function(content)
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		border = "single",
		col = 1,
		row = 1,
		height = vim.o.lines,
		width = vim.o.columns,
		relative = "editor",
		style = "minimal", -- NOTE: Look at options
	})
	local lines = {}
	for line in content:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	return { buf = buf, win = win }
end

--- @param file_dir string
--- @return tex.Autocmd | nil
local open_workspace = function(file_dir)
	if vim.uv.fs_stat(file_dir) then
		return {
			cmd = {
				"latexmk",
				vim.api.nvim_buf_get_name(0),
				"-pdf",
				"-output-directory=./output", -- NOTE: Modularize
				"-interaction=nonstopmode",
			},
			--- @type vim.SystemOpts
			opts = { text = true, cwd = file_dir },
			--- @param obj vim.SystemCompleted
			handler = function(obj)
				if obj.code ~= 0 then
					vim.schedule(function()
						open_window(obj.stdout)
					end)
				else
					vim.schedule(function()
						vim.notify("Your latex file has successfully compiled!", vim.diagnostic.severity.INFO)
						-- NOTE: Open compiled file here (optional)
					end)
				end
			end,
		}
	end
end

M.setup = function(opts)
	local file_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	print(file_dir)
	if string.len(file_dir) == 0 then
		return
	end
	local autocmd_config = open_workspace(file_dir)
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		pattern = { "*.tex" },
		callback = function()
			if string.match(vim.api.nvim_buf_get_name(0), "structure%a.tex") or autocmd_config == nil then
				return
			end
			vim.system(autocmd_config.cmd, autocmd_config.opts, autocmd_config.handler)
		end,
	})
end

return M
