{
  wlib,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ wlib.modules.default ];
  options = {
    fonts = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Helper function for creating FONTCONFIG_FILE in env that helps in loading fonts that will be available for labwc.
        Insert an list of nix packaged fonts.
      '';
    };
    cursor = lib.mkOption {
      type = lib.types.submodule {
        options = {
          path = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path that will be added to cursor search list
              The path have to contain one or more dirs, where one of which is selected via `cursor.theme`
              For cursors from nixpkgs this will likely be "''${pkgs.somepackage}/share/icons"
            '';
          };
          theme = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Name of an cursor theme
            '';
          };
          size = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Size of the cursor
            '';
          };
        };
      };
      description = ''
        Helper function for creating XCURSOR env variables, for managing cursor inside of labwc package.
      '';
    };
    configFiles = {
      "rc.xml" = lib.mkOption {
        type = wlib.types.file {
          path = lib.mkOptionDefault config.constructFiles."rc.xml".path;
        };
        default = { };
        description = "Main configuration file for labwc. For more detail check [all supported config elements & attributes](https://github.com/labwc/labwc/blob/master/docs/rc.xml.all) and [labwc-config man page](https://labwc.github.io/labwc-config.5.html)";
      };
      "menu.xml" = lib.mkOption {
        type = wlib.types.file {
          path = lib.mkOptionDefault config.constructFiles."menu.xml".path;
        };
        default = { };
        description = "Configuration file that defines the context/root-menus for buildin labwc generator. For more detail check [labwc-menu man page](https://labwc.github.io/labwc-menu.5.html) and [reference file](https://github.com/labwc/labwc/blob/master/docs/menu.xml)";
      };
      autostart = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of commands that will be executed as shell script at the start of labwc";
      };
      shutdown = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of commands that will be executed as shell script during termination of labwc";
      };
    };
  };

  config = {
    package = lib.mkDefault pkgs.labwc;
    flags."--config-dir" = "${placeholder config.outputName}/${config.binName}_config/labwc";
    envDefault = {
      FONTCONFIG_FILE = pkgs.makeFontsConf {
        fontDirectories = config.fonts;
      };
      XCURSOR_PATH = lib.mkIf (config.cursor.path != null) config.cursor.path;
      XCURSOR_THEME = lib.mkIf (config.cursor.theme != null) config.cursor.theme;
      XCURSOR_SIZE = lib.mkIf (config.cursor.size != null) config.cursor.size;
    };
    constructFiles = {
      "rc.xml" = {
        relPath = "${config.binName}_config/labwc/rc.xml";
        # content = "${placeholder config.outputName}/${config.binName}_config";
        content = config.configFiles."rc.xml".content;
      };
      "menu.xml" = {
        relPath = "${config.binName}_config/labwc/menu.xml";
        content = config.configFiles."menu.xml".content;
      };
      autostart = {
        relPath = "${config.binName}_config/labwc/autostart";
        content = (lib.strings.join " & " config.configFiles.autostart);
      };
      shutdown = {
        relPath = "${config.binName}_config/labwc/shutdown";
        content = (lib.strings.join " & " config.configFiles.shutdown);
      };
    };
    meta.maintainers = [ wlib.maintainers.lodwkobku ];
  };
}
