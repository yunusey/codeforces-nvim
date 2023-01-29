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

-- Coding settings
M.extension = 'cpp'
M.line = 6

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

-- Terminal Settings
M.termToggle = true


-- Setup function
M.setup = function ()
	vim.fn.system { 'git', 'clone', 'https://github.com/yunusey/codeforces-extractor.git', M.install_path }
end

return M
