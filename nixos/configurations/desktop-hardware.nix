# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8a247aca-51d3-4a40-8f02-58d338dcdd65";
    fsType = "btrfs";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/2ac0fb26-4944-4f30-8655-ba005d00f059";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/46E4-0291";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/9237-E870";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/38303ad4-0b74-47b4-ada1-89062250ac84";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp8s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
