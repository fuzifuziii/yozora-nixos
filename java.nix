{ pkgs, ... }:

let
  jdkWithFX = pkgs.openjdk.override {
    enableJavaFX = true;

    openjfx_jdk = pkgs.openjfx.override {
      withWebKit = true;
    };
  };
in
{
  environment.systemPackages = [
    jdkWithFX
  ];
}
