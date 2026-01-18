{ config, pkgs, ... }: {
  # Set VLC as default video player for all video formats
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Video formats
      "video/mp4" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";       # MKV files
      "video/webm" = "vlc.desktop";
      "video/mpeg" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";        # AVI files
      "video/quicktime" = "vlc.desktop";        # MOV files
      "video/x-flv" = "vlc.desktop";            # FLV files
      "video/x-ms-wmv" = "vlc.desktop";         # WMV files
      "video/ogg" = "vlc.desktop";
      "video/3gpp" = "vlc.desktop";
      "video/mp2t" = "vlc.desktop";             # MPEG-TS

      # Audio formats (optional - if you want VLC for audio too)
      "audio/mpeg" = "vlc.desktop";
      "audio/mp4" = "vlc.desktop";
      "audio/x-flac" = "vlc.desktop";
      "audio/x-vorbis+ogg" = "vlc.desktop";
      "audio/x-wav" = "vlc.desktop";

      # Streaming protocols
      "x-scheme-handler/rtsp" = "vlc.desktop";
      "x-scheme-handler/rtp" = "vlc.desktop";
      "x-scheme-handler/mms" = "vlc.desktop";
    };
  };

  # VLC configuration file - conservative settings for stability
  xdg.configFile."vlc/vlcrc".text = ''
    # Hardware acceleration - DISABLED for stability
    # Can re-enable later once basic playback works
    avcodec-hw=none

    # Video output - use OpenGL for better compatibility
    vout=gl

    # Privacy settings
    qt-privacy-ask=0
    metadata-network-access=1

    # Performance settings - increased caching for network shares
    file-caching=1000
    network-caching=3000
    disc-caching=1000

    # SMB-specific caching (helps with network share playback)
    smb-caching=3000

    # Interface settings
    qt-updates-notif=0

    # Subtitle settings
    sub-language=eng
    sub-autodetect-file=1

    # Audio settings
    volume=256
    volume-save=1
  '';

  # Force VLC to use XWayland instead of native Wayland
  # This fixes Qt interface issues on Wayland with Nvidia
  home.sessionVariables = {
    # Force VLC to use X11/XWayland backend
    VLC_QT_QPA_PLATFORM = "xcb";
  };
}
