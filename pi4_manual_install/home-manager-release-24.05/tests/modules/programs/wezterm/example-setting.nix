{ ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("JetBrains Mono"),
        font_size = 16.0,
        color_scheme = "Tomorrow Night",
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
        keys = {
          {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
        }
      }
    '';
    colorSchemes.test = {
      ansi = [
        "#222222"
        "#D14949"
        "#48874F"
        "#AFA75A"
        "#599797"
        "#8F6089"
        "#5C9FA8"
        "#8C8C8C"
      ];
      brights = [
        "#444444"
        "#FF6D6D"
        "#89FF95"
        "#FFF484"
        "#97DDFF"
        "#FDAAF2"
        "#85F5DA"
        "#E9E9E9"
      ];
      background = "#1B1B1B";
      cursor_bg = "#BEAF8A";
      cursor_border = "#BEAF8A";
      cursor_fg = "#1B1B1B";
      foreground = "#BEAF8A";
      selection_bg = "#444444";
      selection_fg = "#E9E9E9";
    };
  };

  test.stubs.wezterm = { };

  nmt.script = let
    expectedConfig = builtins.toFile "wezterm.lua" ''
      -- Generated by Home Manager.
      -- See https://wezfurlong.org/wezterm/

      local wezterm = require 'wezterm';

      return {
        font = wezterm.font("JetBrains Mono"),
        font_size = 16.0,
        color_scheme = "Tomorrow Night",
        hide_tab_bar_if_only_one_tab = true,
        default_prog = { "zsh", "--login", "-c", "tmux attach -t dev || tmux new -s dev" },
        keys = {
          {key="n", mods="SHIFT|CTRL", action="ToggleFullScreen"},
        }
      }

    '';
    expectedColorScheme = builtins.toFile "test.toml" ''
      [colors]
      ansi = ["#222222", "#D14949", "#48874F", "#AFA75A", "#599797", "#8F6089", "#5C9FA8", "#8C8C8C"]
      background = "#1B1B1B"
      brights = ["#444444", "#FF6D6D", "#89FF95", "#FFF484", "#97DDFF", "#FDAAF2", "#85F5DA", "#E9E9E9"]
      cursor_bg = "#BEAF8A"
      cursor_border = "#BEAF8A"
      cursor_fg = "#1B1B1B"
      foreground = "#BEAF8A"
      selection_bg = "#444444"
      selection_fg = "#E9E9E9"
    '';
  in ''
    assertFileExists home-files/.config/wezterm/wezterm.lua
    assertFileContent home-files/.config/wezterm/wezterm.lua ${expectedConfig}
    assertFileExists home-files/.config/wezterm/colors/test.toml
    assertFileContent home-files/.config/wezterm/colors/test.toml ${expectedColorScheme}
  '';
}
