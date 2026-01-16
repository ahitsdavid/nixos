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

  # VLC configuration file with hardware acceleration
  xdg.configFile."vlc/vlcrc".text = ''
    # Hardware acceleration - let VLC auto-detect best method
    # Options: any, vdpau, vaapi, none
    # Using "any" allows VLC to choose the best available method
    avcodec-hw=any

    # Video output - auto-detect best method
    # Using "auto" instead of forcing "wayland" to avoid compatibility issues
    vout=auto

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

    # Force skip loop filter for H.264 (can help with some playback issues)
    avcodec-skiploopfilter=0
  '';
}
