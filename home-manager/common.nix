{pkgs, ...}: {
  # HACK: Allow hardware acceleration in obsidian
  xdg.desktopEntries.obsidian = {
    name = "Obsidian";
    exec = "${pkgs.obsidian}/bin/obsidian --use-vulkan --use-gl=egl --enable-zero-copy --enable-hardware-overlays --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,VaapiIgnoreDriverChecks --disable-features=UseSkiaRenderer,UseChromeOSDirectVideoDecoder --ignore-gpu-blocklist %u";
    icon = "obsidian";
    mimeType = ["x-scheme-handler/obsidian"];
    type = "Application";
  };
}
