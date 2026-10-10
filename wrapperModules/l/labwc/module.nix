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
    # settings = lib.mkOption {
    #   type =
    #     with lib.types;
    #     (attrsOf (
    #       attrsOf (oneOf [
    #         int
    #         bool
    #         str
    #       ])
    #     ));
    #   default = { };
    #   description = ''
    #     Configuration options for imv. See
    #     {manpage}`imv(5)`.
    #   '';
    #   example = lib.literalExpression ''
    #     {
    #       options.background = "ffffff";
    #       aliases.x = "close";
    #     }
    #   '';
    # };
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
        type = lib.types.separatedString "&";
        default = [ ];
        description = "List of commands that will be executed as shell script at the start of labwc";
      };
    };
  };

  config = {
    package = lib.mkDefault pkgs.labwc;
    env.XDG_CONFIG_DIRS = "${placeholder config.outputName}/${config.binName}_config";
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
        content = pkgs.writeText "autostart" "${config.configFiles.autostart}";
      };
    };
    meta.maintainers = [ wlib.maintainers.lodwkobku ];
  };
}
