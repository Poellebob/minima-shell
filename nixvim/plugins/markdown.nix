{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      render-markdown.enable = true;

      image = {
        enable = true;
        backend = "kitty";
      };

      clipboard-image = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        clipboardPackage = pkgs.pngpaste;
      };
    };
  };
}
