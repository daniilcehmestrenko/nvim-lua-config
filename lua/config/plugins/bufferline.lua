return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Указываем зависимость
    opts = {
      options = {
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
        diagnostics = "nvim_lsp",
        offsets = {{ filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 1 }},
      }
    },
    config = function(_, opts)
      require("bufferline").setup(opts)
    end
  },
  {
    "ojroques/nvim-bufdel",
    config = function()
    end
  }
}
