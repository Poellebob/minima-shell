{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.minima.vim.enable {
    programs.nixvim.plugins = {
      markdown-preview.enable = true;

      image = {
        enable = true;
        settings = {
          backend = "kitty";
          processor = "magick_cli";
          integrations.markdown.enabled = true;
          window_overlap_clear_enabled = true;
        };
      };

      clipboard-image = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        clipboardPackage = pkgs.pngpaste;
      };
    };

    programs.nixvim.extraPackages = [ pkgs.imagemagick ];
    programs.nixvim.keymaps = [
      {
        mode = "n";
        key = "<leader>ui";
        action.__raw = ''
          function()
            local image = require("image")
            if image.is_enabled() then image.disable() else image.enable() end
          end
        '';
        options.desc = "Toggle images";
      }
      {
        mode = "n";
        key = "<leader>um";
        action = "<cmd>MarkdownPreviewToggle<CR>";
        options.desc = "Toggle Markdown browser preview";
      }
    ];
  };
}
