local setup    = require("codeforces-nvim.setup")
local codeforces = require("codeforces-nvim.codeforces")

local M = {}

local getFileWithoutExtenstion = function (problem)
	-- So, what this function does is:
	-- Let's say you are a C++ user. When you compile your program, you want it to create an executable.
	-- Your file name's format is this -> @.cpp 
	-- Your executable's name's format is this -> @.out or @
	-- ex: a.cpp -> a.out or a 
	-- So, this function returns you: /path/to/where/your/programs/are/{problem}
	return setup.cf_program_path .. codeforces.getCurrentContest() .. '/' .. string.lower(problem)
end

local getTestPath = function (problem, test_name)
	-- Basically, this function's mission is to get the file path from the testcase-containing directory.
	-- It works for both input and output. 
	-- PS: It actually works for everything under the testcase directory with given test_name
	return setup.cf_tc_path .. codeforces.getCurrentContest() .. '/' .. problem .. '/' .. test_name
end

local getLines = function (file_path)

	local lines = {}
	local file = io.open(file_path, 'r')
	if file == nil then
		return nil
	end

	for i in file:lines() do
		table.insert(lines, i)
	end

	return lines

end

local error_buffer = nil

local createCompileCommand = function (problem)

	local program_file = getFileWithoutExtenstion(problem)
	local command = setup.compiler[setup.extension]
	local new_command = {}

	for _, i in ipairs(command) do
		-- Change all '@' to program_file
		local x = string.gsub(i, '@', program_file)
		table.insert(new_command, x)
	end

	return new_command

end

local createRunCommand = function (problem, test_file)

	local program_file = getFileWithoutExtenstion(problem)

	local command = setup.run[setup.extension]
	local x = string.gsub(command, '@', program_file)
	x = string.gsub(x, '#', test_file)
	return x

end

local createTerminalRun = function (problem)

	local program_file = getFileWithoutExtenstion(problem)

	local command = setup.run_terminal[setup.extension]
	local x = string.gsub(command, '@', program_file)
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

M.notifyUser = function (message, type)

	if setup.notify_nvim then
		require("notify")(message, type, {
			render = 'minimal'
		})

	else
		print(type .. ': ' .. message)
	end

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
				M.notifyUser("Compilation Failed x", "error")

			else

				M.notifyUser("Compilation Successful ✓", "success")
				exit_function()

			end

		end

	})

end

local getRidOfSpaces = function (a)

	-- This function's goal is to get rid of the spaces in the beginning and the end of each line.

	local i = 1
	while true do
		-- If there's a character that is a non-whitespaces character, then you found the beginning.
		local s = string.match(string.sub(a, i, i), "%S")
		if s ~= nil then
			break
		end
		i = i + 1
	end

	local j = #a
	while true do
		-- If there's a character that is a non-whitespaces character, then you found the end.
		local s = string.match(string.sub(a, j, j), "%S")
		if s ~= nil then
			break
		end
		j = j - 1
	end

	return string.sub(a, i, j)

end

M.compare = function (lines, output_lines)

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
		return {lines, output_lines}
	end
	for i = 1, #normal_lines, 1 do
		if normal_lines[i] ~= output_normal_lines[i] then
			return {lines, output_lines}
		end
	end

	return true

end

M.handleErrors = function (errors)

	local buffer = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buffer, "Analysis")
	vim.api.nvim_set_current_buf(buffer)
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {"ERRORS FOUND!"})

	local length = 1
	vim.api.nvim_buf_add_highlight(buffer, -1, "CodeforcesErrorMsg", 0, 0, -1)
	for _, i in pairs(errors) do
		local tc, user_output, output = i[1], i[2], i[3]
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {"------------------------------"})
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {"Test Case #" .. tc .. ": "})
		length = length + 2
		vim.api.nvim_buf_add_highlight(buffer, -1, "CodeforcesSection", length - 1, 0, -1)
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {"Your output: "})
		length = length + 1
		vim.api.nvim_buf_add_highlight(buffer, -1, "CodeforcesOutput", length - 1, 0, -1)
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, user_output)
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, {"Answer: "})
		length = length + #user_output + 1
		vim.api.nvim_buf_add_highlight(buffer, -1, "CodeforcesOutput", length - 1, 0, -1)
		vim.api.nvim_buf_set_lines(buffer, -1, -1, false, output)
		length = length + #output
	end

	vim.api.nvim_buf_set_option(buffer, "modifiable", false)

end

M.testProblem = function (problem)

	local compiler = createCompileCommand(problem)

	if error_buffer ~= nil then
		vim.api.nvim_buf_delete(error_buffer, {force = true})
	end

	local run = function ()

		local tests = io.popen("ls " .. setup.cf_tc_path .. codeforces.getCurrentContest() .. '/' .. problem .. '/')
		if tests == nil then
			return
		end

		local errors = {}
		for i in tests:lines() do

			if string.sub(i, 1, 1) == 'I' then

				local test_case = string.sub(i, 2, #i - 4)
				local output = getTestPath(problem, 'O' .. string.sub(i, 2))

				local run_command = createRunCommand(problem, getTestPath(problem, i))
				local handler = io.popen(run_command)
				if handler == nil then
					return
				end
				local lines = {}
				for j in handler:lines() do
					table.insert(lines, j)
				end
				handler:close()

				local same = M.compare(lines, getLines(output))
				local message = ""
				local type = nil
				if same == true then
					message = "Test Case #" .. test_case .. " success ✓"
					type = "success"
				else
					local error = {test_case, same[1], same[2]}
					table.insert(errors, error)
					message = "Test Case #" .. test_case .. " failed x"
					type = "error"
				end

				M.notifyUser(message, type)

			end
		end

		if isValidData(errors) then
			-- If there are errors, then handle them!
			M.handleErrors(errors)
		else
			-- Notify user one more time!
			M.notifyUser("All tests passed!", "success")
		end

	end

	if isValidData(compiler) then
		-- If program needs compilation, compile first! (ex: C++)
		M.compile(compiler, run)
	else
		-- If program doesn't need compilation, then just run! (ex: Python)
		run()
	end

end

M.runNormally = function (problem)

	local command = '"' .. createTerminalRun(problem) .. '"'
	if setup.termToggle == true then
		vim.cmd(":TermExec cmd=" .. command)
	else
		vim.cmd(":terminal ")
		vim.cmd(":set number!")
		vim.cmd(":set relativenumber!")
		vim.api.nvim_paste(command, true, 3)
	end

end

M.createTestCase = function (problem)

	local buffer = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buffer, "Your Test Case For Problem #" .. problem)

	local x, y = math.ceil(vim.api.nvim_win_get_height(0) / 2 - 10), math.ceil(vim.api.nvim_win_get_width(0) / 2 - 50)
	local win = vim.api.nvim_open_win(buffer, true,
		{relative='editor', width=100, height=20, row=x, col=y, anchor="NW", border="rounded"}
	)

	vim.api.nvim_win_set_hl_ns(win, setup.test_window_ns)
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

	local command = '"' .. createRunCommand(problem, file_path) .. '"'

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
	local command = '"' .. createRunCommand(problem, file_path) .. '"'

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
