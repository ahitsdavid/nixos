#profiles/work/certification.nix
{ pkgs, lib, ... }:
let
  certsDir = ./certs;
  pemFile = "${certsDir}/DoD_PKE_CA_chain.pem";

  # Check if the PEM file exists for system certificates
  hasPemCert = builtins.pathExists pemFile;

  # Get list of p7b files for browser-specific configuration
  p7bFiles = let
    allFiles = builtins.attrNames (builtins.readDir certsDir);
  in
    builtins.filter (f: lib.hasSuffix ".p7b" f) allFiles;

  # Full paths to p7b files
  p7bPaths = map (f: "${certsDir}/${f}") p7bFiles;
in
{
  # Add PEM certificates to the system certificate store if available
  security.pki.certificates = if hasPemCert
                             then [ (builtins.readFile pemFile) ]
                             else [];

  # CAC/Smart Card packages
  environment.systemPackages = with pkgs; [
    opensc       # Smart card utilities and PKCS#11 module
    ccid         # USB CCID smart card driver
    pcsc-tools   # pcsc_scan and other diagnostic tools
  ];

  # CAC settings
  services.pcscd.enable = true;

  # Create a stable symlink for opensc-pkcs11.so that survives garbage collection
  environment.etc."opensc-pkcs11.so".source = "${pkgs.opensc}/lib/opensc-pkcs11.so";

  environment.etc."pkcs11/modules/opensc.module" = {
    text = ''
      module: /etc/opensc-pkcs11.so
      critical: yes
      enable-in: p11-kit-trust
    '';
    mode = "0444";
  };

  # Install Firefox policies manually (using stable symlink path)
  environment.etc."firefox/policies/policies.json".text = builtins.toJSON {
    policies = {
      SecurityDevices = {
        "CAC Reader" = "/etc/opensc-pkcs11.so";
      };
      Certificates = {
        ImportEnterpriseRoots = true;
        Install = map builtins.toString p7bPaths;
      };
    };
  };

  # Install Zen browser policies (same as Firefox since Zen is Firefox-based)
  environment.etc."zen/policies/policies.json".text = builtins.toJSON {
    policies = {
      SecurityDevices = {
        "CAC Reader" = "/etc/opensc-pkcs11.so";
      };
      Certificates = {
        ImportEnterpriseRoots = true;
        Install = map builtins.toString p7bPaths;
      };
    };
  };

  # Chromium Configuration for CAC
  programs.chromium = {
    extraOpts = {
      "SecurityKeyPermitAttestation" = true;
      "EnableCommonNameFallbackForLocalAnchors" = true;
    };
  };

  # Create a wrapper script to install certificates in Chrome
  # This is needed because Chrome's policies work differently than Firefox
  system.userActivationScripts.installDoDCertsChrome = if (builtins.length p7bPaths > 0) then ''
    # Create Chrome certificate directory if it doesn't exist
    CHROME_CERT_DIR="$HOME/.pki/nssdb"
    mkdir -p "$CHROME_CERT_DIR"

    # Import certificates into Chrome's NSS database
    for cert in ${lib.concatStringsSep " " (map builtins.toString p7bPaths)}; do
      ${pkgs.nss.tools}/bin/certutil -d sql:"$CHROME_CERT_DIR" -A -t "C,," -n "$(basename "$cert")" -i "$cert" || true
    done
  '' else "";

}
