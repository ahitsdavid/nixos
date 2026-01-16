{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # VLC with additional features enabled
    (vlc.override {
      chromecastSupport = true;    # Enable Chromecast casting
      jackSupport = true;          # Enable JACK audio support
      waylandSupport = true;       # Enable Wayland support
    })

    # Hardware acceleration libraries
    libva              # VA-API support for hardware decoding
    libvdpau           # VDPAU support (Nvidia hardware acceleration)
    libva-utils        # VA-API diagnostic tools (vainfo)
    vdpauinfo          # VDPAU diagnostic tools

    # GStreamer plugins for additional codec support
    gst_all_1.gstreamer           # GStreamer multimedia framework
    gst_all_1.gst-plugins-base    # Base plugins
    gst_all_1.gst-plugins-good    # Good quality plugins
    gst_all_1.gst-plugins-bad     # Plugins that need more quality work
    gst_all_1.gst-plugins-ugly    # Good plugins with licensing issues
    gst_all_1.gst-libav           # FFmpeg-based plugin
  ];

  # Firewall rule for Chromecast support
  networking.firewall.allowedTCPPorts = [ 8010 ];
}
