-- lua/plugins/narrowing.lua
-- Neovim plugin spec for lazy.nvim.
-- Plugin: tkancf/narrowing-nvim
-- We disable the plugin's default keymaps because we define our own.

return {
  "tkancf/narrowing-nvim",
  config = function()
    require("narrowing").setup({
      keymaps = { enabled = false },

      -- Keep defaults explicit for readability.
      window = {
        type = "float",       -- "float" or "split"
        position = "center",  -- "center", "left", "right", "top", "bottom"
        width = 0.95,
        height = 0.9,
        vertical = true,      -- For split windows only
      },

      sync_on_write = true,        -- :w syncs back to original
      protect_original = true,     -- original becomes read-only while narrowed
      highlight_region = true,     -- highlight narrowed region in original
      highlight_group = "Visual",  -- highlight style
    })
  end,
}

