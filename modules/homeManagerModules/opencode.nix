{
  self,
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.opencode = {
    pkgs,
    config,
    ...
  }: {
    imports = [
    ];

    options = {
      opencode.enable = lib.mkEnableOption "Enable opencode";
    };

    config = lib.mkIf config.opencode.enable {
      programs.opencode = {
        enable = true;
        settings = {
          provider = {
            "llama.cpp" = {
              npm = "@ai-sdk/openai-compatible";
              name = "LLaMA Local";
              options.baseURL = "http://12.0.0.1:8080/v1";
            };
          };
        };
      };
    };
  };
}
