{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.mini = {
      enable = true;
      mockDevIcons = true;

      modules = {
        basics = {
          options.extra_ui = true;
          mappings.windows = true;
        };
        ai = { };
        icons = { };
        bracketed = { };
        pairs = { };
        surround = { };
        bufremove = { };
        visits = { };
        extra = { };
        move = {
          mappings = {
            left = "<C-M-h>";
            right = "<C-M-l>";
            down = "<C-M-j>";
            up = "<C-M-k>";

            line_left = "<C-M-h>";
            line_right = "<C-M-l>";
            line_down = "<C-M-j>";
            line_up = "<C-M-k>";
          };
        };
        cursorword = { };
        jump = { };
        jump2d = { };
        files = {
          windows = {
            preview = true;
            width_preview = 65;
          };
        };
        indentscope = {
          symbol = "▏";
          options = {
            try_as_border = true;
          };
        };
      };
    };

    programs.nixvim.keymaps =
      lib.optionals
        (
          config.programs.nixvim.plugins.mini.enable
          && lib.hasAttr "files" config.programs.nixvim.plugins.mini.modules
        )
        [
          {
            mode = "n";
            key = "<leader>e";
            action.__raw = "MiniFiles.open";
          }
        ]
      ++
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "bufremove" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>x";
              action.__raw = "MiniBufremove.delete";
            }
          ]
      ++
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "visits" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>v";
              action.__raw = "MiniVisits.select_path";
            }
          ]
      ++
        lib.optionals
          (
            config.programs.nixvim.plugins.mini.enable
            && lib.hasAttr "extra" config.programs.nixvim.plugins.mini.modules
          )
          [
            {
              mode = "n";
              key = "<leader>ms";
              action.__raw = "MiniExtra.pickers.spellsuggest";
            }
          ];

    programs.nixvim.autoCmd = [
      {
        event = "User";
        pattern = "MiniFilesBufferCreate";
        callback.__raw = ''
          function(args)
            local MiniFiles = require("mini.files")
            local map = function(lhs, rhs)
              vim.keymap.set("n", lhs, rhs, { buffer = args.data.buf_id })
            end
            map("l", function()
              local entry = MiniFiles.get_fs_entry()
              if entry == nil then
                return
              end
              MiniFiles.go_in()
              if entry.fs_type == "file" then
                MiniFiles.close()
              end
            end)
            map("h", function()
              MiniFiles.go_out()
            end)
            map("<esc>", function()
              MiniFiles.close()
            end)
          end
        '';
      }
    ];
  };
}
