{...}: {
  programs.git = {
    userEmail = "stephane.lacoin@gmail.com";
    userName = "Stephane Lacoin (aka nxmatic)";
    signing = {
      key = "stephane.lacoin@gmail.com";
      signByDefault = false;
    };
  };
}
