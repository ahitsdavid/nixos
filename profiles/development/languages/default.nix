#profiles/development/languages/default.nix
{ inputs }:
{ config, pkgs, ... }: {
  imports = [
    (import ./python.nix { inherit inputs; })
  ];
  # Common language tools
  environment.systemPackages = with pkgs; [
    # JavaScript/TypeScript
    nodejs
    yarn

    # Go
    go

    # C/C++ toolchain
    gcc
    gnumake
    clang
    clang-tools        # clangd LSP, clang-format, clang-tidy
    cmake
    cmake-language-server
    ninja
    gdb
    valgrind           # Memory debugging
    bear               # Generate compile_commands.json for LSP
  ];
}