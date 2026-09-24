{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.autoCmd = [
      {
        event = [ "VimEnter" "DirChanged" ];
        callback = {
          __raw = ''
            function()
              local cwd = vim.fn.getcwd()
              local title = vim.fn.fnamemodify(cwd, ":~")

              local ok, out = pcall(vim.fn.system, { "git", "-C", cwd, "rev-parse", "--show-toplevel" })
              if ok and vim.v.shell_error == 0 then
                local root = vim.trim(out)
                if root ~= "" then
                  title = vim.fs.basename(root)
                end
              end

              vim.opt.titlestring = "nvim - " .. title
            end
          '';
        };
        desc = "Set window title to nvim - <project|pwd>";
      }
      {
        event = "FileType";
        pattern = [ "markdown" ];
        command = "setlocal spell spelllang=en_us";
      }
      {
        event = [ "VimEnter" "DirChanged" ];
        callback = {
          __raw = ''
            function()
              -- look for platformio.ini in cwd (project root)
              local root = vim.fn.getcwd()
              local pio_ini = root .. "/platformio.ini"
  
              if vim.fn.filereadable(pio_ini) == 1 then
                vim.schedule(function()
                  vim.cmd("LspStop")
                end)
              end
            end
          '';
        };
      }
      {
        event = [ "CursorHold" "CursorHoldI" ];
        callback.__raw = ''
          function()
            vim.diagnostic.open_float(nil, {
              focusable = false,
              border = "single",
              scope = "line",
              close_events = { "BufLeave", "CursorMoved", "CursorMovedI", "InsertEnter", "FocusLost" },
            })
          end
        '';
        desc = "Show line diagnostics on hover";
      }
    ] ++ map (a: {
      event = a.event;
      pattern = a.pattern;
      command = a.command;
      desc = a.desc;
    }) config.minima.vim.autocmd;
  };
}
