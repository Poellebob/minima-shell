{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.which-key = {
      enable = true;
      settings = {
        delay = 300;
        win.border = "rounded";
        expand = 1;
        icons = {
          breadcrumb = "»";
          separator = "➜";
          group = "+";
          rules = false;
        };
        plugins.marks = true;
        plugins.registers = true;
        plugins.spelling = {
          enabled = true;
          suggestions = 20;
        };
        sort = [
          "group"
          "alphanum"
          "mod"
        ];
        spec = [
          { __unkeyed-1 = "<leader>"; group = "Leader"; }
          { __unkeyed-1 = "<leader>f"; group = "File"; }
          { __unkeyed-1 = "<leader>t"; group = "Terminal"; }
          { __unkeyed-1 = "<leader>u"; group = "UI"; }
          { __unkeyed-1 = "<leader>x"; group = "List"; }
          { __unkeyed-1 = "<leader>w"; desc = "Save File"; }
          { __unkeyed-1 = "<leader>q"; desc = "Quit"; }
          { __unkeyed-1 = "<leader>n"; desc = "New file"; }
          { __unkeyed-1 = "<leader>c"; desc = "Close buffer"; }
          { __unkeyed-1 = "<leader>ff"; desc = "Find files"; }
          { __unkeyed-1 = "<leader>fF"; desc = "Find files (hidden)"; }
          { __unkeyed-1 = "<leader>fw"; desc = "Live grep"; }
          { __unkeyed-1 = "<leader>gs"; desc = "Stage hunk"; }
          { __unkeyed-1 = "<leader>gr"; desc = "Reset hunk"; }
          { __unkeyed-1 = "<leader>gp"; desc = "Preview hunk"; }
          { __unkeyed-1 = "<leader>tf"; desc = "Floating terminal"; }
          { __unkeyed-1 = "<leader>th"; desc = "Horizontal terminal"; }
          { __unkeyed-1 = "<leader>tv"; desc = "Vertical terminal"; }
          { __unkeyed-1 = "<leader>tl"; desc = "Lazygit"; }
          { __unkeyed-1 = "<leader>xq"; desc = "Open quickfix"; }
          { __unkeyed-1 = "<leader>xl"; desc = "Open local list"; }
          { __unkeyed-1 = "<leader>uw"; desc = "Toggle wrap"; }
          { __unkeyed-1 = "<leader>us"; desc = "Toggle spellcheck"; }
          { __unkeyed-1 = "<leader>un"; desc = "Toggle relative numbers"; }
          { __unkeyed-1 = "<leader>ud"; desc = "Toggle diagnostics"; }
          { __unkeyed-1 = "<leader>ub"; desc = "Toggle background"; }
          { __unkeyed-1 = "<leader>uD"; desc = "Dismiss notifications"; }
        ];
      };
    };
  };
}
