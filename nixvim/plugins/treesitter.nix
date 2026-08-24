{ config, lib, ... }:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins.treesitter = {
      enable = true;
      folding.enable = true;
      grammarPackages = config.programs.nixvim.plugins.treesitter.package.passthru.allGrammars;
      nixvimInjections = true;

      settings = {
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = true;
        };

        indent = {
          enable = true;
        };
      };
    };
  };
}
