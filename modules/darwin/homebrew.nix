{...}: {
  homebrew = {
    enable = true;

    global = {
      brewfile = true;
    };

    brews = [
    ];

    taps = [
      # base
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
    ];

    casks = [
      # desktop
      "amethyst"
      "hyperkey"
      # "appcleaner"
      #
      # "keybase"
    ];
  };
}
