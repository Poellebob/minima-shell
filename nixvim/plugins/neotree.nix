{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.neo-tree = {
      enable = true;

      settings = {
        close_if_last_window = true;
        default_component_configs = {
          indent = {
            with_expanders = true;
          };
        };
        filesystem = {
          follow_current_file.enabled = true;
          hijack_netrw_behavior = "open_default";
          filtered_items = {
            visible = true;
            hide_dotfiles = false;
            hide_gitignored = false;
          };
          window = {
            mappings = {
              "l" = {
                __raw = ''
                  function(state)
                    local node = state.tree:get_node()
                    if node.type == "directory" then
                      if node:is_expanded() then
                        require("neo-tree.ui.renderer").focus_node(state, node.id)
                        vim.cmd("normal! j")
                      else
                        require("neo-tree.sources.filesystem.commands").open(state)
                      end
                    else
                      require("neo-tree.sources.filesystem.commands").open(state)
                      vim.cmd("Neotree close")
                    end
                  end
                '';
              };
              "h" = {
                __raw = ''
                  function(state)
                    local node = state.tree:get_node()
                    local parent_id = node:get_parent_id()
                    if node.type == "directory" and node:is_expanded() then
                      require("neo-tree.sources.filesystem.commands").close_node(state)
                    elseif parent_id then
                      require("neo-tree.ui.renderer").focus_node(state, parent_id)
                    else
                      local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
                      local root = vim.fn.fnamemodify(state.path, ":p")
                      if root ~= cwd and root:sub(1, #cwd) == cwd then
                        require("neo-tree.sources.filesystem.commands").navigate_up(state)
                      end
                    end
                  end
                '';
              };
              "<esc>" = "close_window";
            };
          };
        };
        window = {
          mappings = {
            "<esc>" = "close_window";
          };
        };
      };
    };

    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
      }
    ];

    programs.nixvim.autoCmd = [
      {
        event = "FileType";
        pattern = [
          "neo-tree"
          "neo-tree-popup"
        ];
        callback.__raw = ''
          function(args)
            vim.schedule(function()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == args.buf then
                  local wo = vim.wo[win]
                  wo.statuscolumn = ""
                  wo.foldcolumn = "0"
                  wo.signcolumn = "no"
                  wo.number = false
                  wo.relativenumber = false
                  wo.colorcolumn = ""
                end
              end
            end)
          end
        '';
        desc = "Clear gutter options in neo-tree windows";
      }
    ];
  };
}
