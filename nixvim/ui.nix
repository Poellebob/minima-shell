{ config, lib, ... }:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      web-devicons.enable = true;

      which-key = {
        enable = true;
        settings = {
          delay = 300;
          spec = [
            { __unkeyed-1 = "<leader>b"; group = "Buffers"; }
            { __unkeyed-1 = "<leader>f"; group = "Find"; }
            { __unkeyed-1 = "<leader>g"; group = "Git"; }
            { __unkeyed-1 = "<leader>S"; group = "Sessions"; }
            { __unkeyed-1 = "<leader>t"; group = "Terminal"; }
            { __unkeyed-1 = "<leader>u"; group = "UI"; }
            { __unkeyed-1 = "<leader>x"; group = "Lists"; }
          ];
        };
      };

      indent-blankline = {
        enable = true;
        settings = {
          indent.char = "▏";
          scope.enabled = false;
        };
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem.follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
          window.mappings = {
            "l".__raw = ''
              function(state)
                local node = state.tree:get_node()
                if node.type == "directory" then
                  if not node:is_expanded() then
                    require("neo-tree.sources.filesystem.commands").open(state)
                  end
                  return
                end
                require("neo-tree.sources.filesystem.commands").open(state)
              end
            '';
            "h".__raw = ''
              function(state)
                local node = state.tree:get_node()
                if node.type == "directory" and node:is_expanded() then
                  require("neo-tree.sources.filesystem.commands").close_node(state)
                  return
                end
                local parent_id = node:get_parent_id()
                if not parent_id then return end
                local parent = state.tree:get_node(parent_id)
                if not parent then return end
                if parent:is_expanded() then
                  require("neo-tree.sources.filesystem.commands").close_node(state)
                  require("neo-tree.ui.renderer").focus_node(state, parent_id)
                end
              end
            '';
          };
        };
      };

      bufferline = {
        enable = true;
        settings.options = {
          numbers = "none";
          close_command = "bdelete! %d";
          diagnostics = "nvim_lsp";
          diagnostics_indicator.__raw = ''
            function(count, level)
              local icons = { error = " ", warning = " " }
              return icons[level] and (icons[level] .. count) or tostring(count)
            end
          '';
          separator_style = "slant";
          show_buffer_close_icons = true;
          show_close_icon = false;
          offsets = [
            {
              filetype = "neo-tree";
              text = "File Explorer";
              text_align = "center";
              separator = true;
            }
          ];
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            globalstatus = true;
            component_separators = {
              left = "";
              right = "";
            };
            section_separators = {
              left = "";
              right = "";
            };
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "branch" "diff" "diagnostics" ];
            lualine_c = [ "filename" ];
            lualine_x = [ "filetype" ];
            lualine_y = [ "progress" ];
            lualine_z = [ "location" ];
          };
        };
      };

      telescope = {
        enable = true;
        settings.defaults = {
          prompt_prefix = "   ";
          selection_caret = "  ";
          border = true;
          borderchars = [ "─" "│" "─" "│" "╭" "╮" "╯" "╰" ];
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

      noice = {
        enable = true;
        settings = {
          lsp.override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
            "cmp.entry.get_documentation" = true;
          };
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = false;
          };
        };
      };

      notify = {
        enable = true;
        settings = {
          render = "compact";
          stages = "fade";
          timeout = 3000;
        };
      };

      snacks = {
        enable = true;
        settings = {
          dashboard = {
            preset = {
              header = ''
                                                                         
                              ██            ██                           
                                                                         
              █████████████   ██ ████████   ██ █████████████    ██████   
              ██    ██    ██  ██ ██     ██  ██ ██    ██    ██        ██  
              ██    ██    ██  ██ ██     ██  ██ ██    ██    ██   ███████  
              ██    ██    ██  ██ ██     ██  ██ ██    ██    ██  ██    ██  
              ██    ██    ██  ██ ██     ██  ██ ██    ██    ██   █████ ██ 
              '';
              keys = [
                {
                  icon = "  ";
                  key = "f";
                  desc = "Find file";
                  action = ":lua require('telescope.builtin').find_files()";
                }
                {
                  icon = "  ";
                  key = "n";
                  desc = "New file";
                  action = ":ene | startinsert";
                }
                {
                  icon = "  ";
                  key = "r";
                  desc = "Recent files";
                  action = ":lua require('telescope.builtin').oldfiles()";
                }
                {
                  icon = "  ";
                  key = "q";
                  desc = "Quit";
                  action = ":qa";
                }
              ];
            };
          };
          terminal = {
            enabled = true;
            win.style = "terminal";
          };
          notifier.enabled = true;
        };
      };

      dressing = {
        enable = true;
        settings = {
          input = {
            enabled = true;
            default_prompt = "Input:";
            win_options.winblend = 0;
          };
          select = {
            enabled = true;
            backend = [ "telescope" "builtin" ];
          };
        };
      };
    };
  };
}
