local M = require('codeforces-nvim.setup')

M.current_contest = nil
M.problems = {}
M.current_problem = nil

M.getFile = function (problem)
	return M.cf_program_path .. M.current_contest .. '/' .. string.lower(problem) .. '.' .. M.extension
end

M.file_exists = function (name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

M.enterContest = function (cont)

	local contest = cont
	if contest == nil or contest == "" then
		contest = vim.fn.input(
			{
				prompt = "Please enter the contest: ",
				default = "17"
			}
		)
	end

	M.current_contest = contest

	local contest_names = io.popen("ls " .. M.cf_tc_path)
	local found_contest = false
	if contest_names ~= nil then
		for i in contest_names:lines() do
			if i == contest then
				found_contest = true
				break
			end
		end
	end

	local exit_function = function ()
		M.getProgram(contest)
		M.current_problem = 1
		vim.cmd(":cd " .. M.cf_program_path .. M.current_contest .. '/') -- Set the cwd to your solutions dir.
		vim.cmd(":tabnew " .. M.getFile(M.problems[M.current_problem]))
		vim.cmd(":" .. M.lines[M.extension])
	end
	if found_contest == false then
		M.getTest(contest, exit_function)
	else
		exit_function()
	end
end

M.getTest = function (contest, exit_function)
	local buffer = nil
	if M.write_to_buffer then
		buffer = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_set_current_buf(buffer)
	end
	local main = M.install_path .. "main.py"
	local path = M.cf_tc_path
	if M.use_contest_number == true then
		path = path .. contest .. '/'
	end
	vim.fn.jobstart({"python3", main, contest, path}, {
		on_stdout = function (_, data)
			if M.write_to_buffer and data then
				vim.api.nvim_buf_set_lines(buffer, -1, -1, false, data)
			end
		end,
		on_stderr = function (_, data)
			if M.write_to_buffer and data then
				vim.api.nvim_buf_set_lines(buffer, -1, -1, false, data)
			end
		end,
		on_exit = function (_, _)
			if not M.keep_buf and M.write_to_buffer then
				vim.api.nvim_buf_delete(buffer, {force = true})
			end
			exit_function()
		end
	})
end

M.getProgram = function (contest)
	local template_path = M.templates[M.extension]
	local sol_folder = M.cf_program_path .. contest .. '/'
	os.execute("mkdir -p " .. sol_folder)
	local pdirs = io.popen("ls " .. M.cf_tc_path .. contest .. '/')
	local problems = {}
	if pdirs ~= nil then
		for problem in pdirs:lines() do
			table.insert(problems, problem)
			local file_path = sol_folder .. string.lower(problem) .. "." .. M.extension
			if M.file_exists(file_path) == false then
				local file = io.open(file_path, "w")
				if file ~= nil then
					for i in io.lines(template_path) do
						file:write(i .. '\n')
					end
					file:close()
				else
					print("Problem occured in creating file...")
				end
			end
		end
	else
		print("No directories found in the /test/" .. contest .. "directory!")
	end
	M.problems = problems
end

M.getCurrentContest = function ()
	return M.current_contest
end

return M
