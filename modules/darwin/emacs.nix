{
  config,
  pkgs,
  ...
}: {
  
  services.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
  };

  launchd.user.agents.emacs = {
    environment = {
      XDG_RUNTIME_DIR = "${config.user.home}/.xdg";
    };
    serviceConfig = {
      KeepAlive = true;
      UserName = "${config.user.name}";
    };
  };
}
