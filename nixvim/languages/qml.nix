{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      lsp.servers.qmlls.enable = true;

      conform-nvim.settings.formatters_by_ft.qml = [ "qmlformat" ];
      conform-nvim.settings.formatters.qmlformat.command =
        "${pkgs.kdePackages.qtdeclarative}/bin/qmlformat";
    };

    programs.nixvim.extraPackages = [ pkgs.kdePackages.qtdeclarative ];

    programs.nixvim.autoCmd = [
      {
        event = "FileType";
        pattern = "qml";
        command = "set indentexpr=";
        desc = "Disable broken treesitter indent for QML";
      }
    ];
  };
}
