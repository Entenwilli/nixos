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
      services.open-webui = {
        enable = true;
        port = 8081;
        environment = {
          WEBUI_AUTH = "False";
        };
      };
      users.users.open-webui = {
        isSystemUser = true;
        group = "open-webui";
      };
      users.groups.open-webui = {};

      systemd.services.open-webui = {
        serviceConfig = {
          DynamicUser = lib.mkForce false;
          ProtectProc = lib.mkForce "default";
          User = "open-webui";
          Group = "open-webui";
        };
      };

      services.llama-cpp = {
        enable = true;
        package = pkgs.llama-cpp-vulkan.overrideAttrs (oldAttrs: {
          cmakeFlags =
            (lib.filter (flag: !(lib.strings.hasInfix "GGML_NATIVE" flag)) oldAttrs.cmakeFlags)
            ++ [
              (lib.cmakeFeature "CMAKE_C_FLAGS" "-march=znver5")
              (lib.cmakeFeature "CMAKE_CXX_FLAGS" "-march=znver5")
            ];
        });
        modelsPreset = {
          "Qwen3.8-27B Speed" = {
            np = 1;
            fit = "on";
            hf = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-UD-IQ3_S.gguf";
            alias = "Qwen3.8 Speed";
            mmproj-offload = true;
            # kv-offload = true;
            flash-attn = "on";
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
            models-max = 1;
            sleep-idle-seconds = 900;
            ctx-size = 65536;
            temp = 1.0;
            top-p = 0.95;
            top-k = 20;
            min-p = 0.0;
            parallel = 1;
            fit-target = 256;
          };
          "Qwen3.8-27B Accuracy" = {
            np = 1;
            fit = "on";
            hf = "unsloth/Qwen3.8-27B-GGUF";
            hf-file = "Qwen3.8-27B-UD-Q4_K_S.gguf";
            alias = "Qwen3.8 Accuracy";
            mmproj-offload = true;
            kv-offload = true;
            flash-attn = "on";
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
            models-max = 1;
            sleep-idle-seconds = 900;
            ctx-size = 65536;
            temp = 1.0;
            top-p = 0.95;
            top-k = 20;
            min-p = 0.0;
            parallel = 1;
            fit-target = 256;
          };

          "Gemma4-26B-A4B" = {
            np = 1;
            hf = "unsloth/gemma-4-26B-A4B-it-GGUF";
            hf-file = "gemma-4-26B-A4B-it-Q8_0.gguf";
            alias = "Gemma4";
            n-cpu-moe = 16;
            flash-attn = "on";
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
            models-max = 1;
            sleep-idle-seconds = 900;
            ctx-size = 65536;
            temp = 1.0;
            top-p = 0.95;
            top-k = 64;
            parallel = 1;
            fit-target = 256;
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
        "/var/lib/open-webui"
      ];

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7550", ATTR{power_dpm_force_performance_level}="high"
      '';

      powerManagement.cpuFreqGovernor = "performance";
    };
  };
}
