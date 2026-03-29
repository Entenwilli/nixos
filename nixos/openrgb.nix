{...}: {
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    startupProfile = "Default.orp";
  };
}
