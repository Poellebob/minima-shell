{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.which-key = {
      enable = true;

      settings = {
        preset = "modern";
        win.border = "single";

        spec = [
          {
            __unkeyed-1 = "<leader>b";
            group = "Buffer";
          }
          {
            __unkeyed-1 = "<leader>d";
            group = "Diagnostics";
          }
          {
            __unkeyed-1 = "<leader>f";
            group = "Find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
          }
          {
            __unkeyed-1 = "<leader>i";
            group = "Inlay";
          }
          {
            __unkeyed-1 = "<leader>m";
            group = "Misc";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "Terminal";
          }
          {
            __unkeyed-1 = "<leader>u";
            group = "UI";
          }
          {
            __unkeyed-1 = "<leader>v";
            group = "Visits";
          }
          {
            __unkeyed-1 = "g";
            group = "Goto";
          }
          {
            __unkeyed-1 = "]";
            group = "Next";
          }
          {
            __unkeyed-1 = "[";
            group = "Prev";
          }
          {
            __unkeyed-1 = "s";
            group = "Surround";
            mode = [
              "n"
              "v"
            ];
          }
          {
            __unkeyed-1 = "<C-w>";
            group = "Window";
          }
        ];
      };
    };
  };
}
