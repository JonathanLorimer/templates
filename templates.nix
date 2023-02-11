rec {
  templates = {
    haskell = {
      path = ./template/haskell;
      description = "A template for a haskell project that uses flakes";
      welcomeText = ''
        You just created a haskell flake project.
      '';
    };
    idris = {
      path = ./template/idris;
      description = "A template for an idris2 project";
      welcomeText = ''
        You just created an idris2 project.
      '';
    };
    rust = {
      path = ./template/rust;
      description = "A template for a rust project";
      welcomeText = ''
        You just created a rust project.
      '';
    };
    agda = {
      path = ./template/agda;
      description = "A template for an agda project";
      welcomeText = ''
        You just created an agda project.
      '';
    };
  };

  defaultTemplate = templates.haskell;
}
