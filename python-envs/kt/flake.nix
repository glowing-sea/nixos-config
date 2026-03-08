{
  description = "PyTorch CUDA Research Environment";

  inputs = {
    # Points to the official NixOS unstable or stable branch
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Your architecture
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
    in
    {
      # This replaces shell.nix
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (python3.withPackages (ps: with ps; [
            torch-bin
            torchvision-bin
            numpy
            pandas
          ]))
        ];

        shellHook = ''
          echo "Entering Flake-based Research Environment..."
          python --version
          # python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"
        '';
      };
    };
}
