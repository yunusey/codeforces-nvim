--- @module codeforces-nvim.utils
--- Utility functions
local M = {}

--- @param filename string
--- @return string
--- Returns the filename without the extension
M.trim_extension = function(filename)
    return filename:match("(.+)%..+$") or filename
end

--- @param str string
--- @return string
--- Returns the string without the spaces in the beginning and the end
--- e.g. `  hello  ` -> `hello`
M.trim = function(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

M.getRidOfSpaces = function(a)
    -- This function's goal is to get rid of the spaces in the beginning and the end of each line.

    local i = 1
    while true do
        -- If there's a character that is a non-whitespaces character, then you found the beginning.
        local s = string.match(string.sub(a, i, i), "%S")
        if s ~= nil then break end
        i = i + 1
    end

    local j = #a
    while true do
        -- If there's a character that is a non-whitespaces character, then you found the end.
        local s = string.match(string.sub(a, j, j), "%S")
        if s ~= nil then break end
        j = j - 1
    end

    return string.sub(a, i, j)
end

--- @param data string[]
--- @return boolean
--- Returns `true` if the `data` is valid
--- Sometimes, the data produced by `vim.fn.jobstart` can be
--- empty (e.g. `{ "" }`) and it can be challenging to check if there is anything
--- important in it. This function aims to iterate over the `data` and check
--- if there is anything important in it
M.check_data = function(data)
    if data == nil or data == {} or data == "" then return false end

    if type(data) == "table" then
        for _, i in pairs(data) do
            if i ~= nil and i ~= {} and i ~= "" then return true end
        end
        return false
    elseif type(data) == "string" then
        return data ~= string.match(data, "%s+")
    end

    return true
end

--- @param source string
--- @param destination string
--- Copies the file from `source` to `destination`
M.copy_file = function(source, destination)
    local file = io.open(destination, "w")
    if file ~= nil then
        for i in io.lines(source) do
            file:write(i .. "\n")
        end
        file:close()
    end
end

--- @param lines string[]
--- @param output_lines string[]
--- @return boolean
--- Returns `true` if the `lines` and `output_lines` are the same
--- **NOTE**: Please notice that this is merely a very basic comparison.
--- It will only check if the lines (after trimming the spaces only from
--- the beginning and the end) are the same. There might be cases where
--- the spaces between two elements do not matter. You will need to decide
--- it in `diffview`. Also, it will ignore any empty lines
M.compare = function(lines, output_lines)
    local i = 1
    local j = 1
    while i <= #lines or j <= #output_lines do
		while i <= #lines and M.trim(lines[i]) == "" do
			i = i + 1
		end
		while j <= #output_lines and M.trim(output_lines[j]) == "" do
			j = j + 1
		end

		if i > #lines or j > #output_lines then
			return i > #lines and j > #output_lines
		end

        local lhs, rhs = M.trim(lines[i]), M.trim(output_lines[j])
		if lhs ~= rhs then
			return false
		end

		i = i + 1
		j = j + 1
    end
    return true
end

return M
