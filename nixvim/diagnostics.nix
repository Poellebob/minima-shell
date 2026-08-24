{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.diagnostics = {
      float = {
        border = "rounded";
      };
    };
  };
}
