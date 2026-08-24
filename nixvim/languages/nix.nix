{
  config,
  lib,
  pkgs,
  minimaFlakeSrc,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.nixd = {
        enable = true;
        settings =
          let
            flake = ''(builtins.getFlake "${minimaFlakeSrc}")'';
          in
          {
            nixpkgs = {
              expr = "import ${flake}.inputs.nixpkgs { }";
            };
            formatting = {
              command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
            };
          };
      };

      lint.linters.deadnix.cmd = lib.getExe pkgs.deadnix;
      lint.lintersByFt.nix = [ "deadnix" ];

      conform-nvim.settings.formatters_by_ft.nix = [ "nixfmt-rfc-style" ];
      conform-nvim.settings.formatters."nixfmt-rfc-style".command = lib.getExe pkgs.nixfmt-rfc-style;
    };
  };
}
