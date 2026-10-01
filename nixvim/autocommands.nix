{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.autoCmd = [
      {
        event = [
          "VimEnter"
          "DirChanged"
        ];
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
    ]
    ++ map (a: {
      event = a.event;
      pattern = a.pattern;
      command = a.command;
      desc = a.desc;
    }) config.minima.vim.autocmd;
  };
}
