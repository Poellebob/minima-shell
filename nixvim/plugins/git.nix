{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      gitignore.enable = true;

      lazygit.enable = true;

      gitsigns = {
        enable = true;
        settings = {
          numhl = false;

          current_line_blame = true;
          current_line_blame_opts = {
            delay = 500;
            ignore_blank_lines = true;
            ignore_whitespace = true;
            virt_text = true;
            virt_text_pos = "eol";
          };

          signcolumn = true;
        };
      };
    };

    programs.nixvim.keymaps =
      lib.optionals config.programs.nixvim.plugins.gitignore.enable [
        {
          mode = "n";
          key = "<leader>gi";
          action.__raw = ''require('gitignore').generate'';
          options.desc = "Gitignore generate";
        }
      ]
      ++ lib.optionals config.programs.nixvim.plugins.lazygit.enable [
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<cr>";
        }
      ]
      ++ lib.optionals config.programs.nixvim.plugins.gitsigns.enable [
        {
          mode = "n";
          key = "<leader>gs";
          action = "<cmd>Gitsigns stage_hunk<CR>";
          options.desc = "Stage hunk";
        }
        {
          mode = "n";
          key = "<leader>gr";
          action = "<cmd>Gitsigns reset_hunk<CR>";
          options.desc = "Reset hunk";
        }
        {
          mode = "n";
          key = "<leader>gp";
          action = "<cmd>Gitsigns preview_hunk<CR>";
          options.desc = "Preview hunk";
        }
        {
          mode = "n";
          key = "]h";
          action = "<cmd>Gitsigns next_hunk<CR>";
          options.desc = "Next hunk";
        }
        {
          mode = "n";
          key = "[h";
          action = "<cmd>Gitsigns prev_hunk<CR>";
          options.desc = "Prev hunk";
        }
      ];
  };
}
