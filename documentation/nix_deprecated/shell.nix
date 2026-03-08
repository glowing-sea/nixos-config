{ pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  }
}:

pkgs.mkShell {
  # These are the "System" dependencies needed for Python C-extensions
  buildInputs = [
    (pkgs.python3.withPackages (ps: with ps; [
      numpy
      pandas
      # We use -bin versions for PyTorch on NixOS to ensure
      # the pre-compiled CUDA binaries link correctly.
      torch-bin
      torchvision-bin
    ]))
  ];

  # This runs automatically when you enter the shell
  shellHook = ''
    echo "--- Research Environment Loaded ---"
    python --version
    python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
    echo "----------------------------------"
  '';
}
