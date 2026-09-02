{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.autoCmd = [
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
    ] ++ map (a: {
      event = a.event;
      pattern = a.pattern;
      command = a.command;
      desc = a.desc;
    }) config.minima.vim.autocmd;
  };
}
