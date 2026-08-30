{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.telescope = {
      enable = true;

      extensions.fzf-native = {
        enable = true;
        settings = {
          fuzzy = true;
          case_mode = "smart_case";
          override_generic_sorter = true;
          override_file_sorter = true;
        };
      };

      settings.defaults = {
        prompt_prefix = "   ";
        selection_caret = "  ";
        border = true;
        borderchars = [
          "─"
          "│"
          "─"
          "│"
          "┌"
          "┐"
          "┘"
          "└"
        ];
        layout_config = {
          horizontal = {
            preview_width = 0.55;
            results_width = 0.8;
          };
          width = 0.87;
          height = 0.80;
          preview_cutoff = 120;
        };
      };
    };

    programs.nixvim.keymaps = lib.mkIf config.programs.nixvim.plugins.telescope.enable [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fF";
        action = "<cmd>Telescope find_files hidden=true<CR>";
        options.desc = "Find files (hidden)";
      }
      {
        mode = "n";
        key = "<leader>fw";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Find buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options.desc = "Help tags";
      }
      {
        mode = "n";
        key = "<leader>fk";
        action = "<cmd>Telescope keymaps<CR>";
        options.desc = "Keymaps";
      }
      {
        mode = "n";
        key = "<leader>fo";
        action = "<cmd>Telescope oldfiles<CR>";
        options.desc = "Recent files";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>Telescope registers<CR>";
        options.desc = "Registers";
      }
      {
        mode = "n";
        key = "<leader>fC";
        action = "<cmd>Telescope commands<CR>";
        options.desc = "Commands";
      }
      {
        mode = "n";
        key = "<leader>f<CR>";
        action = "<cmd>Telescope resume<CR>";
        options.desc = "Resume search";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Telescope git_branches<CR>";
        options.desc = "Git branches";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Telescope git_commits<CR>";
        options.desc = "Git commits (repo)";
      }
      {
        mode = "n";
        key = "<leader>gC";
        action = "<cmd>Telescope git_bcommits<CR>";
        options.desc = "Git commits (file)";
      }
      {
        mode = "n";
        key = "<leader>gt";
        action = "<cmd>Telescope git_status<CR>";
        options.desc = "Git status";
      }
    ];
  };
}
