{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.autoCmd = [
      {
        event = "FileType";
        pattern = [ "markdown" ];
        command = "setlocal spell spelllang=en_us";
      }
    ] ++ map (a: {
      event = a.event;
      pattern = a.pattern;
      command = a.command;
      desc = a.desc;
    }) config.minima.vim.autocmd;
  };
}
