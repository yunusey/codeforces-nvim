local M = {}

-- Paths & Directories
M.home_dir = vim.fn.expand("~")
M.install_path = M.home_dir .. "/.local/share/nvim/site/pack/packer/start/codeforces-extractor/"
M.cf_path = M.home_dir .. "/codeforces/contests/"
M.cf_tc_path = M.home_dir .. "/codeforces/contests/test/"
M.cf_program_path = M.home_dir .. "/codeforces/contests/solutions/"
M.python_path = "python3"

-- Buffer settings
M.write_to_buffer = false
M.keep_buf = false

-- Explorer Settings & Paths (Just for Windows)
local convertToWindowsPath = function (path)
	local a = string.gsub(path, "/", "\\")
	a = string.sub(a, 0, #a - 1)
	return a
end

M.linux_path = "\\wsl.localhost\\Ubuntu-20.04"
M.linux_cf_path = "\\wsl.localhost\\Ubuntu-20.04" .. convertToWindowsPath(M.cf_path)
M.linux_test_path = "\\wsl.localhost\\Ubuntu-20.04" .. convertToWindowsPath(M.cf_tc_path)
M.linux_program_path = "\\wsl.localhost\\Ubuntu-20.04" .. convertToWindowsPath(M.cf_program_path)
M.use_contest_number = true

-- notify.nvim
M.notify_nvim = true

-- Coding settings
M.extension = 'cpp'
M.lines = {
	cpp = 6,
	py = 3
}

-- Templates
M.templates = {
	py  = M.home_dir .. "/codeforces/templates/template.py",
	cpp = M.home_dir .. "/codeforces/templates/template.cpp"
}

-- Commands
-- '@' should be thought as the lower cased problem name ex: 
-- Problem A -> f 
-- Problem A1 -> a1
M.compiler = {
	py = {},
	cpp = {"g++", "@.cpp", "-o", "@"}
}

M.run = {
	py = "python3 @.py < #",
	cpp = "@ < #"
}

-- This is for program to be executed in the terminal.
M.run_terminal = {
	py = "python @.py",
	cpp = "@"
}

-- Terminal Settings
M.termToggle = true

M.highlights = {

	CodeforcesErrorMsg = {fg="#ff3333"},
	CodeforcesSection  = {fg="#00c0ff"},
	CodeforcesOutput   = {fg="#a0ff00"}

}

M.test_window_ns = vim.api.nvim_create_namespace("TestCaseNamespace")
vim.api.nvim_set_hl(M.test_window_ns, "Normal", {bg = "#000000"})

for key, value in pairs(M.highlights) do
	vim.api.nvim_set_hl(0, key, value)
end

-- Setup function
M.setup = function (config)
	vim.fn.system { 'git', 'clone', 'https://github.com/yunusey/codeforces-extractor.git', M.install_path }
	for key, value in pairs(config) do
		M[key] = value
	end
end

return M
