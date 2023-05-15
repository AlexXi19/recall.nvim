# recall.nvim

A NeoVim plugin which remembers where you've been

This project is built on top of [memento.nvim](https://github.com/gaborvecsei/memento.nvim) and inspired by [harpoon](https://github.com/ThePrimeagen/harpoon). 

![Recall](https://tbsnhkewuwyfxowgazvr.supabase.co/storage/v1/object/public/public/recall2)

When you navigate around your project, your navigation history is saved and can be accessed via the recall menu. When the menu is open, you can also navigate by entering the number associated with the file. 

*(The plugin is mostly for my personal use, but PRs are welcome)*

# Install

```lua
use 'nvim-lua/plenary.nvim' -- if you already have this you don't need to include it again
use 'AlexXi19/recall.nvim'
```

# Usage

```lua
-- Open up history popup menu
:lua require("recall").toggle()

-- Clear history
:lua require("recall").clear_history()
```

When the popup is visible, you can **close it with `q`, `Escape`, or `Ctrl-c`** and **open up any file at any line by hitting `Enter`**

## Keybinding

```lua
nnoremap <C-e> <cmd>lua require('recall').toggle()<CR>
```

```lua 
vim.keymap.set("n", "<C-e>", "<cmd>lua require('recall').toggle()<CR>")
```

# Configuration

| Variable                | Description                                                                                                | Type   | Default |
|-------------------------|------------------------------------------------------------------------------------------------------------|--------|---------|
| `recall_history`       | Length of the history                                                                                      | `int`  | `20`    |
| `recall_window_width`  | Popup window's width                                                                                       | `int`  | `80`    |
| `recall_window_height` | Popup window's height                                                                                      | `int`  | `14`    |

```lua
vim.g.recall_history = 20
vim.g.recall_window_width = 80
vim.g.recall_window_height = 14
```

