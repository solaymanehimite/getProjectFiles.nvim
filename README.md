# getProjectFiles.nvim
Copy all *(or some)* current directory files into your clipboard

## Installation
- [lazy.nvim](https://github.com/folke/lazy.nvim): 
```lua
-- ./{config_folder}/lua/plugins/get_project_files.lua
return {
    "solaymanehimite/getProjectFiles.nvim",
    lazy = false,
    config = function()
        require("get_project_files").setup()
    end
}
```

## Usage
- `:GetProjectFiles <file_extensions>`
- `:GetProjectFiles lua json`

