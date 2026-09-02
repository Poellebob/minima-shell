{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim = {
      enable = true;

      luaLoader.enable = true;

      clipboard = {
        register = "unnamedplus";
      };

      highlight.ExtraWhitespace.bg = "red";
      match.ExtraWhitespace = "\\s\\+$";

      colorschemes.${config.minima.vim.theme.name} = {
        enable = true;
        settings.flavour = config.minima.vim.theme.flavour;
      };

      globals = {
        vimtex_syntax_enabled = 1;
        loaded_ruby_provider = 0;
        loaded_perl_provider = 0;
        loaded_python_provider = 0;

        disable_diagnostics = false;
        disable_autoformat = false;
        spell_enabled = true;
        colorizing_enabled = 1;
        first_buffer_opened = false;
      };

      opts = {
        updatetime = 100;

        relativenumber = true;
        number = true;
        hidden = true;
        mouse = "a";
        mousemodel = "extend";
        splitbelow = true;
        splitright = true;

        swapfile = false;
        modeline = true;
        modelines = 100;
        undofile = true;
        incsearch = true;
        ignorecase = true;
        smartcase = true;
        cursorline = true;
        signcolumn = "yes";
        colorcolumn = "100";
        laststatus = 3;
        fileencoding = "utf-8";
        termguicolors = true;
        spelllang = lib.mkDefault [ "en_us" ];
        spell = true;
        wrap = false;

        tabstop = 2;
        shiftwidth = 2;
        softtabstop = 2;
        expandtab = true;
        autoindent = true;

        foldlevel = 99;
        foldcolumn = "1";
        foldenable = true;
        foldlevelstart = -1;
        fillchars = {
          horiz = "━";
          horizup = "┻";
          horizdown = "┳";
          vert = "┃";
          vertleft = "┫";
          vertright = "┣";
          verthoriz = "╋";

          eob = " ";
          diff = "╱";

          fold = " ";
          foldopen = "";
          foldclose = "";

          msgsep = "‾";
        };

        lazyredraw = false;
        synmaxcol = 240;
        showmatch = true;
        matchtime = 1;
        startofline = true;
        report = 9001;

        statuscolumn = "%{%v:lua.MinimaStatusColumn()%}";
      };
    };

    programs.nixvim.extraConfigLuaPre = ''
      function _G.MinimaStatusColumn()
        local lnum = vim.v.lnum
        local cur = vim.fn.line(".")

        local fold = " "
        if vim.fn.foldlevel(lnum) > 0 then
          if vim.fn.foldclosed(lnum) == lnum then
            fold = "\u{f460}"
          elseif vim.fn.foldlevel(lnum - 1) < vim.fn.foldlevel(lnum) then
            fold = "\u{f47c}"
          else
            fold = "│"
          end
        end

        local show_num = vim.wo.number or vim.wo.relativenumber
        local n = lnum
        if vim.wo.relativenumber and lnum ~= cur then
          n = math.abs(lnum - cur)
        end
        local digits = show_num and tostring(n) or ""
        local pad = string.rep(" ", math.max(0, vim.wo.numberwidth - #digits - 1))
        local hl = (lnum == cur and show_num) and "%#CursorLineNr#" or "%#LineNr#"

        return fold .. " %=" .. hl .. pad .. digits .. "%* %s "
      end
    '';
  };
}
