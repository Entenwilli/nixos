{
  self,
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.llama = {
    pkgs,
    config,
    ...
  }: {
    imports = [
    ];

    options = {
      llama.enable = lib.mkEnableOption "Enable llama-cpp";
    };

    config = lib.mkIf config.llama.enable {
      services.llama-cpp = {
        enable = true;
        package = pkgs.llama-cpp-vulkan;
        modelsPreset = {
          "Qwen3.8-27B" = {
            hf = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-Q8_0.gguf";
            alias = "Qwen3.8";
            models-max = 1;
            sleep-idle-seconds = 900;
          };
          "Gemma4-26B-A4B" = {
            hf = "unsloth/gemma-4-26B-A4B-it-GGUF";
            hf-file = "gemma-4-26B-A4B-it-Q8_0.gguf";
            alias = "Gemma4";
            models-max = 1;
            sleep-idle-seconds = 900;
          };
        };
      };
      systemd.services.llama-cpp = {
        environment = {
          HOME = "/var/lib/llama-cpp";
          XDG_CACHE_HOME = "/var/cache/llama-cpp";
          MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
        };
        serviceConfig.DynamicUser = lib.mkForce false;
      };
      environment.persistence."/persistent".directories = lib.mkIf config.impermanence.enable [
        "/var/cache/llama-cpp"
      ];
    };
  };
}
