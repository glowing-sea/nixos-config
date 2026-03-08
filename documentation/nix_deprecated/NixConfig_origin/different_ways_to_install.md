In NixOS, you can install packages at different "layers" of the system. Choosing the right one depends on whether you want the tool to be a permanent part of your OS, a personal preference for your user account, or just a temporary tool for a specific research task.

Here are the four primary ways to install packages:

---

### 1. System-Wide (`configuration.nix`)

These are installed for every user on the machine and are available even at the login screen or in the root terminal.

* **Setting:** `environment.systemPackages = with pkgs; [ ... ];`
* **Best for:** Core utilities (e.g., `vim`, `git`, `pciutils`), drivers, and system-level tools you never want to be without.
* **Method:** Declarative (requires `sudo nixos-rebuild switch`).

### 2. User-Specific (Home Manager)

As we discussed, this is the "Nix way" for personal tools. It allows you to manage the program **and** its configuration (dotfiles) in one place.

* **Setting:** `home.packages = with pkgs; [ ... ];` (inside your `home.nix` or HM block).
* **Best for:** Personal apps like `vlc`, `mpv`, `discord`, and your specific coding environments.
* **Method:** Declarative (managed via `home-manager` or your system rebuild).

### 3. Temporary / On-the-Fly (`nix-shell` / `nix shell`)

This is a "killer feature" for researchers. It allows you to use a package without actually "installing" it or cluttering your system.

* **Command:** `nix-shell -p python311Packages.torch`
* **What happens:** Nix downloads the package into the store and drops you into a new shell where that command exists. When you type `exit`, it's "gone" (it stays in the store but is no longer in your PATH).
* **Best for:** Trying out a new tool, running a script that needs a specific library once, or testing different versions of a compiler.

### 4. Imperative (`nix-env` - *Not Recommended*)

This behaves like `apt-get` or `pacman`.

* **Command:** `nix-env -iA nixos.htop`
* **Why avoid it:** It is "imperative," meaning it isn't recorded in your `.nix` files. If you reinstall your OS, these packages won't come back automatically. It bypasses the reproducibility that makes NixOS great.

---

### Summary Table

| Method | Scope | Persistent? | Configurable? | Use Case |
| --- | --- | --- | --- | --- |
| **System** | Global | Yes | No | Drivers, `sudo`, `curl` |
| **Home Manager** | User only | Yes | **Yes** | Browsers, Media, Dev tools |
| **Nix Shell** | This shell | No | No | Testing, scripts, one-offs |
| **Nix-env** | User only | Yes | No | Quick testing (avoid) |

### The "Researcher" Workflow

For your Machine Learning work, you will likely find this workflow most efficient:

1. **System:** Keep your NVIDIA drivers and basic CLI tools here.
2. **Home Manager:** Keep your primary code editor and daily-driver apps here.
3. **Nix Shell:** Use this for specific projects (e.g., one project needs PyTorch 2.0, another needs 2.4). You can create a `shell.nix` file in your project folder to automate this.

**Would you like me to show you how to create a `shell.nix` file for a Python project so you can have an instant, isolated ML environment?**
