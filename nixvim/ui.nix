{ config, lib, ... }:
{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          background = { light = "macchiato"; dark = "mocha"; };
          flavour = "macchiato";
          transparent_background = true;
          no_bold = false;
          no_italic = false;
          no_underline = false;
          custom_highlights = ''
            function(highlights)
              return {
                CursorLineNr = { fg = highlights.peach, style = {} },
                NavicText = { fg = highlights.text },
              }
            end
          '';
          integrations = {
            cmp = true;
            notify = true;
            gitsigns = true;
            neotree = true;
            which_key = true;
            illuminate = { enabled = true; lsp = true; };
            navic = { enabled = true; custom_bg = "NONE"; };
            treesitter = true;
            telescope.enabled = true;
            indent_blankline.enabled = true;
            mini = { enabled = true; indentscope_color = "rosewater"; };
            native_lsp = {
              enabled = true;
              inlay_hints = { background = true; };
              virtual_text = {
                errors = [ "italic" ];
                hints = [ "italic" ];
                information = [ "italic" ];
                warnings = [ "italic" ];
                ok = [ "italic" ];
              };
              underlines = {
                errors = [ "underline" ];
                hints = [ "underline" ];
                information = [ "underline" ];
                warnings = [ "underline" ];
              };
            };
          };
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
          use_libuv_file_watcher = true;
          filesystem = {
            follow_current_file = {
              enabled = true;
              leave_dirs_open = true;
            };
            filtered_items = {
              hide_hidden = true;
            };
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
          diagnostics = "nvim_lsp";
          mode = "buffers";
          close_icon = " ";
          buffer_close_icon = "󰱝 ";
          modified_icon = "󰔯 ";
          offsets = [
            {
              filetype = "neo-tree";
              text = "Neo-tree";
              highlight = "Directory";
              text_align = "left";
            }
          ];
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            globalstatus = true;
            extensions = [ "fzf" "neo-tree" ];
            disabledFiletypes = {
              statusline = [ "startup" "alpha" ];
            };
            theme = "catppuccin";
          };
          sections = {
            lualine_a = [ { "mode" = "mode"; icon = ""; } ];
            lualine_b = [
              { "branch" = "branch"; icon = ""; }
              {
                "diff" = "diff";
                symbols = {
                  added = " ";
                  modified = " ";
                  removed = " ";
                };
              }
            ];
            lualine_c = [
              {
                "diagnostics" = "diagnostics";
                sources = [ "nvim_lsp" ];
                symbols = {
                  error = " ";
                  warn = " ";
                  info = " ";
                  hint = "󰝶 ";
                };
              }
              { "navic" = "navic"; }
            ];
            lualine_x = [
              {
                "filetype" = "filetype";
                icon_only = true;
                separator = "";
                padding = { left = 1; right = 0; };
              }
              {
                "filename" = "filename";
                path = 1;
              }
              {
                __raw = ''
                  function()
                    local icon = " "
                    local status = require("copilot.api").status.data
                    return icon .. (status.message or " ")
                  end,
                  cond = function()
                   local ok, clients = pcall(vim.lsp.get_clients, { name = "copilot", bufnr = 0 })
                   return ok and #clients > 0
                  end,
                '';
              }
            ];
            lualine_y = [ { "progress" = "progress"; } ];
            lualine_z = [ { "location" = "location"; } ];
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
        autoLoad = true;
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

      bufdelete = {
        enable = true;
      };

      web-devicons.enable = true;
    };
  };
}
