{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      direnv.enable = true;
      nix.enable = true;
      nix-develop.enable = true;
    };
  };
}
