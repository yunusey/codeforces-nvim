local setup    = require("codeforces-nvim.setup")
local codeforces = require("codeforces-nvim.codeforces")

local getFileWithoutExtenstion = function (problem)
	return setup.cf_program_path .. codeforces.getCurrentContest() .. '/' .. string.lower(problem)
end

local M = {}

local error_buffer = nil

local createCompileCommand = function (problem)
	local program_file = getFileWithoutExtenstion(problem)
	local command = setup.compiler[setup.extension]
	local new_command = {}
	for _, i in ipairs(command) do
		local x = string.gsub(i, '@', program_file)
		table.insert(new_command, x)
	end
	return new_command
end

local createRunCommand = function (problem, test)
	local program_file = getFileWithoutExtenstion(problem)
	local test_file = setup.cf_tc_path .. codeforces.getCurrentContest() .. '/' .. string.upper(problem) .. '/' .. test
	local command = setup.run[setup.extension]
	local x = string.gsub(command, '@', program_file)
	x = string.gsub(x, '#', test_file)
	return x
end

local isValidData = function (data)
	if data == nil or data == {} or data == '' then
		return false
	end
	if type(data) == "table" then
		for _, i in pairs(data) do
			if i ~= nil and i ~= {} and i ~= '' then
				return true
			end
		end
		return false
	elseif type(data) == "string" then
		return data ~= string.match(data, "%s+")
	end
	return true
end

M.compile = function (compiler, exit_function)
	local errors = false
	local all_data = {}
	vim.fn.jobstart(compiler, {
		on_stderr = function (_, data)
			if isValidData(data) == false then
				return
			end
			errors = true
			for _, i in pairs(data) do
				table.insert(all_data, i)
			end
		end,
		on_exit = function (_, _)
			if errors then
				error_buffer = vim.api.nvim_create_buf(true, false)
				vim.api.nvim_buf_set_name(error_buffer, "Error Buffer")
				vim.api.nvim_buf_set_lines(error_buffer, 0, -1, false, all_data)
				vim.api.nvim_set_current_buf(error_buffer)
			else
				print("Compilation Successful ✓")
				exit_function()
			end
		end
	})
end

local getRidOfSpaces = function (a)
	local i = 1
	while true do
		local s = string.match(string.sub(a, i, i), "%S")
		if s ~= nil then
			break
		end
		i = i + 1
	end
	local j = #a
	while true do
		local s = string.match(string.sub(a, j, j), "%S")
		if s ~= nil then
			break
		end
		j = j - 1
	end
	return string.sub(a, i, j)
end

M.compare = function (lines, output_file)
	local output_line_function = io.open(output_file, "r"):lines()
	local output_lines = {}
	for i in output_line_function do
		table.insert(output_lines, i)
	end
	local normal_lines = {}
	for _, i in pairs(lines) do
		if isValidData(i) == true then
			local modified = getRidOfSpaces(i)
			table.insert(normal_lines, modified)
		end
	end
	local output_normal_lines = {}
	for _, i in pairs(output_lines) do
		if isValidData(i) == true then
			local modified = getRidOfSpaces(i)
			table.insert(output_normal_lines, modified)
		end
	end
	if #normal_lines ~= #output_normal_lines then
		return false
	end
	for i = 1, #normal_lines, 1 do
		if normal_lines[i] ~= output_normal_lines[i] then
			return false
		end
	end
	return true
end

M.testProblem = function (problem)
	local probleml = string.lower(problem)
	local compiler = createCompileCommand(probleml)
	if error_buffer ~= nil then
		vim.api.nvim_buf_delete(error_buffer, {force = true})
	end
	local run = function ()
		local tests = io.popen("ls " .. setup.cf_tc_path .. codeforces.getCurrentContest() .. '/' .. problem .. '/')
		if tests == nil then
			return
		end
		for i in tests:lines() do
			if string.sub(i, 1, 1) == 'I' then
				local output = setup.cf_tc_path .. codeforces.getCurrentContest() .. '/' .. problem .. '/' .. 'O' .. string.sub(i, 2)
				local test_case = string.sub(i, 2, #i - 4)
				local run_command = createRunCommand(probleml, i)
				local lines_function = io.popen(run_command):lines()
				local lines = {}
				for j in lines_function do
					table.insert(lines, j)
				end
				local same = M.compare(lines, output)
				local message = ""
				if same then
					message = "Test Case #" .. test_case .. " success ✓"
				else
					message = "Test Case #" .. test_case .. " failed x"
				end
				require("notify")(message, "info", {
					render = 'minimal'
				})
			end
		end
	end
	if isValidData(compiler) then
		M.compile(compiler, function ()
			run()
		end)
	else
		run()
	end
end

M.runNormally = function (problem)
	local file_path = getFileWithoutExtenstion(string.lower(problem))
	if setup.termToggle == true then
		vim.cmd(":TermExec cmd=" .. file_path)
	else
		vim.cmd(":terminal ")
		vim.cmd(":set number!")
		vim.cmd(":set relativenumber!")
		vim.api.nvim_paste(file_path, true, 3)
	end
end

M.createTestCase = function (problem)
	local buffer = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buffer, "Your Test Case For Problem #" .. problem)
	local x, y = math.ceil(vim.api.nvim_win_get_height(0) / 2 - 10), math.ceil(vim.api.nvim_win_get_width(0) / 2 - 50)
	local win = vim.api.nvim_open_win(buffer, true,
		{relative='editor', width=100, height=20, row=x, col=y, anchor="NW", border="rounded"}
	)
	local ns = vim.api.nvim_create_namespace("Transparent")
	vim.api.nvim_set_hl(ns, "Normal", {bg = "#000000"})
	vim.api.nvim_win_set_hl_ns(win, ns)
	vim.api.nvim_buf_set_keymap(buffer, "n", "<CR>",
		":lua require'codeforces-nvim.commands'.getTestCase('" .. problem .. "', " .. buffer .. ", " .. win .. ")<CR>",
	{})
end

M.getTestCase = function (problem, buf, win)
	local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local file_path = setup.cf_program_path .. codeforces.getCurrentContest() .. "/user_input.txt"
	local file = io.open(file_path, 'w')
	if file == nil then
		return
	end
	for _, i in pairs(input) do
		file:write(i .. '\n')
	end
	file:close()
	local exec_name = getFileWithoutExtenstion(string.lower(problem))
	local command = "\"" .. exec_name .. ' < ' .. file_path .. "\""
	if setup.termToggle == true then
		vim.cmd(":TermExec cmd=" .. command)
	else
		vim.cmd(":terminal ")
		vim.cmd(":set number!")
		vim.cmd(":set relativenumber!")
		vim.api.nvim_paste(command, true, 3)
	end
	vim.api.nvim_win_close(win, true)
	vim.api.nvim_buf_delete(buf, {force = true})
end

M.retrieveLastTestCase = function (problem)
	local file_path = setup.cf_program_path .. codeforces.getCurrentContest() .. "/user_input.txt"
	local exec_name = getFileWithoutExtenstion(string.lower(problem))
	local command = "\"" .. exec_name .. ' < ' .. file_path .. "\""
	if setup.termToggle == true then
		vim.cmd(":TermExec cmd=" .. command)
	else
		vim.cmd(":terminal ")
		vim.cmd(":set number!")
		vim.cmd(":set relativenumber!")
		vim.api.nvim_paste(command, true, 3)
	end
end

return M
