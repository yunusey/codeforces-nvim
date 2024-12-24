local M = require("codeforces-nvim.setup")
local utils = require("codeforces-nvim.utils")

--- @type string | nil
M.current_contest = nil
--- @type integer
M.current_problem = 0
--- @type string[]
M.problems = {}

--- @param problem string
--- @param extension string | nil
--- @return string
--- Returns the file path of the solution to the problem with the given `extension`
--- if the `extension` is `nil`, the file path is returned without **any** extension
--- which can be used for executables (e.g. `*.cpp` -> `*`)
M.get_solution_file = function(problem, extension)
    local filename = string.lower(problem)
    if extension ~= nil then filename = filename .. "." .. extension end
    return vim.fs.joinpath(M.paths.solutions, M.current_contest, filename)
end

--- @param problem string
--- @param test_name string
--- @param extension string | nil
--- @return string
--- Returns the file path of the test case: `/path/to/contest/<contest_id>/<problem>/<test_name>`
--- Then, the user just needs to add the appropriate extension (`.in` or `.out`)
M.get_test_file = function(problem, test_name, extension)
    local filename = test_name
    if extension ~= nil then filename = filename .. extension end
    return vim.fs.joinpath(M.paths.tests, M.current_contest, problem, filename)
end

--- @param cont string | nil
--- Fetches the `cont` contest and sets the `current_contest`
M.enter_contest = function(cont)
    M.current_contest = cont
    if M.current_contest == nil or M.current_contest == "" then
        M.current_contest = vim.fn.input({
            prompt = "Please enter the contest: ",
            default = "17",
        })
    end

    local test_directory = vim.fs.joinpath(M.paths.tests, M.current_contest)
    local found_contest = vim.fn.isdirectory(test_directory) == 1

    local exit_function = function()
        M.create_contest(M.current_contest)
        M.current_problem = 1

        if #M.problems == 0 then return end

        local solution_file = M.get_solution_file(M.problems[M.current_problem], M.options.extension)
        vim.fn.chdir(vim.fs.joinpath(M.paths.solutions, M.current_contest))
        vim.cmd(":tabnew " .. solution_file)
        vim.api.nvim_win_set_cursor(0, { M.options.lines[M.options.extension], 0 })
    end

    if found_contest == false then
        M.fetch_problems(M.current_contest, test_directory, exit_function)
    else
        exit_function()
    end
end

--- @param contest string
--- @param save_dir string
--- @param exit_function function
--- Fetches the problems for the `contest` using `codeforces-extractor`
--- and calls the `exit_function`
M.fetch_problems = function(contest, save_dir, exit_function)
    vim.fn.jobstart({ M.options.extractor_path, contest, "--save-path", save_dir }, {
        on_stdout = function(_, data) end,
        on_stderr = function(_, data)
            if utils.check_data(data) == false then return end
            M.options.notify("Codeforces Extractor", vim.inspect(data), "error")
        end,
        on_exit = function(_, _)
            exit_function()
        end,
    })
end

--- @param contest string
--- Creates the corresponding folder for the current `contest`, copies the
--- template files accordingly and sets the `problems` variable for further use
M.create_contest = function(contest)
    local template_path =
        vim.fs.joinpath(M.paths.templates, string.format("template.%s", M.options.extension))
    local sol_folder = vim.fs.joinpath(M.paths.solutions, contest)
    local test_folder = vim.fs.joinpath(M.paths.tests, contest)

    if vim.fn.filereadable(template_path) == 0 then
        M.options.notify(
            string.format("Template for `%s` language not found", M.options.extension),
            string.format("Please add a template for the current language at: %s", template_path),
            "error"
        )
        return
    end

    vim.fn.mkdir(sol_folder, "p")

    local problems = {}
    for problem in vim.fs.dir(test_folder) do
        table.insert(problems, problem)
        local solution_path = M.get_solution_file(problem, M.options.extension)
        if vim.fn.filereadable(solution_path) == 0 then utils.copy_file(template_path, solution_path) end
    end

    M.problems = problems
end

--- @return string
--- Returns the id of the current contest
M.get_current_contest = function()
    return M.current_contest
end

return M
