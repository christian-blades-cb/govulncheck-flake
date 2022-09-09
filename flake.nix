{
  description = "Go Vulnerability Management";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        {
          packages = rec {
            govulncheck = pkgs.buildGoModule rec {
              pname = "govulncheck";
              # version and rev are related, I'm just correlating commits with the version list
              # https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck?tab=versions
              version = "0.0.0-20220908210932-64dbbd7bba4f";

              src = pkgs.fetchFromGitHub {
                owner = "golang";
                repo = "vuln";
                rev = "64dbbd7bba4f7b064c4bbe40c3199e21788f6df3";

                sha256 = "sha256-YHt1MsDLTXADqq/l+e6s3jLyZoxHgzBn/RdPMYRhOVM=";
              };

              vendorSha256 = "sha256-9FH9nq5cEyhMxrrvfQAOWZ4aThMsU0HwlI+0W0uVHZ4=";

              doCheck = false;

              # don't build everything in "integrations"
              subPackages = [ "cmd/govulncheck" ];
            };

            default = govulncheck;
          };

          overlays = rec {
            govulncheck = final: prev: { inherit (self.packages.${system}) govulncheck; };
            default = govulncheck;
          };
        }
    ) // {
      overlay = final: prev: { inherit (self.packages.${prev.stdenv.hostPlatform.system}) govulncheck; };
    };
}
