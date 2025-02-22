local M = {}

local function read_file_content(filename)
	local file = io.open(filename, "r")
	if not file then
		return nil, "Error opening file: " .. filename
	end
	local content = file:read("*a")
	file:close()
	return content, nil
end

local function get_project_files(root_dir, extensions, exclude_dirs)
	local files_content = {}

	local function is_excluded_dir(dir)
		local default_excluded_dirs = { "node_modules", ".git" } -- Add default excluded directories
		local all_excluded_dirs = vim.list_extend(exclude_dirs or {}, default_excluded_dirs)

		if all_excluded_dirs then
			for _, exclude_dir in ipairs(all_excluded_dirs) do
				if string.find(dir, exclude_dir, 1, true) then
					return true
				end
			end
		end
		return false
	end

	local function traverse_directory(dir)
		if is_excluded_dir(dir) then
			return
		end

		for entry in vim.fs.dir(dir) do
			local full_path = dir .. "/" .. entry
			local file_info = vim.loop.fs_stat(full_path)
			if file_info then
				if file_info.type == "file" then
					-- Check file extension
					local file_extension = vim.fn.fnamemodify(entry, ":e")
					local include_file = false
					if extensions and #extensions > 0 then
						for _, ext in ipairs(extensions) do
							if file_extension == ext then
								include_file = true
								break
							end
						end
					else
						-- If no extensions are specified, include all files
						include_file = true
					end

					if include_file then
						local content, err = read_file_content(full_path)
						if content then
							table.insert(files_content, entry .. ": " .. content)
						else
							print("Error reading " .. full_path .. ": " .. err)
						end
					end
				elseif file_info.type == "directory" and entry ~= "." and entry ~= ".." then
					traverse_directory(full_path)
				end
			else
				print("Error stating " .. full_path)
			end
		end
	end

	traverse_directory(root_dir)
	return table.concat(files_content, " ")
end

function M.get_and_copy(args)
	local root_dir = vim.fn.getcwd()
	local extensions = {}
	local exclude_dirs = {}

	if args and args.fargs then
		local i = 1
		while i <= #args.fargs do
			if args.fargs[i] == "--exclude" then
				i = i + 1
				if i <= #args.fargs then
					table.insert(exclude_dirs, args.fargs[i])
				else
					print("Error: --exclude requires a directory name")
				end
			else
				table.insert(extensions, args.fargs[i])
			end
			i = i + 1
		end
	end

	local content = get_project_files(root_dir, extensions, exclude_dirs)

	vim.fn.setreg("+", content) -- "+" register is the clipboard
	print("Project files content copied to clipboard.")
end

vim.api.nvim_create_user_command(
	"GetProjectFiles",
	M.get_and_copy,
	{ nargs = "*", desc = "Get project files content", complete = "file" }
)

return M
