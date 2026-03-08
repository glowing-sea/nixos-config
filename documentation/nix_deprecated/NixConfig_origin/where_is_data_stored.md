When you use **Home Manager** for user-specific installations, Nix changes the rules for how applications and their configurations are stored. It moves away from the traditional Linux "mess" and toward a system of **symbolic links**.

### 1. Where the Apps (Binaries) are stored

Even though the app is "for you," the actual files are stored in the immutable **Nix Store**, just like system apps. However, the *links* to reach them are specific to your user.

* **The Physical Files:** `/nix/store/[hash]-vlc-3.0.20/`
* **The User Access Point:** Because you set `home-manager.useUserPackages = true;`, the binaries are linked to:
`/etc/profiles/per-user/eiri/bin/`
* **The Result:** When you type `vlc`, your shell looks in that specific per-user folder to find the program.

---

### 2. Where the Config Data is stored

This is where Home Manager is most powerful. It handles the files that usually live in `/etc/` or your hidden home folders.

#### A. Global Configs (The `/etc/` equivalent)

In a traditional distro, an app might look for a global config in `/etc/mpv/config`. In NixOS, Home Manager creates a "User-level etc" inside your home directory.

* **Path:** `~/.config/`
* **Nix Behavior:** Home Manager creates a symlink from `~/.config/mpv/mpv.conf` back to a read-only file in the **Nix Store**. You cannot edit this file directly; you change your `home.nix` and rebuild.

#### B. App Data & State (`.local/share`, `.cache`)

Home Manager generally **does not** manage "State" or "Cache" files by default. These are created by the application while it's running.

* **Cache:** `~/.cache/vlc/` (Managed by the app, usually safe to delete).
* **Local Share:** `~/.local/share/` (Where things like your Minecraft worlds, browser profiles, or local databases live).
* **Nix Behavior:** These remain **mutable** (traditional). Nix leaves them alone so the app can write to them.

---

### Summary Table: Where does it go?

| Data Type | Traditional Path | Nix + Home Manager Path | Managed by Nix? |
| --- | --- | --- | --- |
| **Program Binary** | `/usr/bin/vlc` | `/etc/profiles/per-user/eiri/bin/vlc` | **Yes** (Read-only) |
| **User Config** | `~/.config/vlc/` | `~/.config/vlc/` (as a link to `/nix/store`) | **Yes** (Read-only) |
| **App Cache** | `~/.cache/vlc/` | `~/.cache/vlc/` | **No** (Mutable) |
| **Saved Data** | `~/.local/share/` | `~/.local/share/` | **No** (Mutable) |

---

### Why this matters for "Erase Your Darlings"

If you follow the "Erase Your Darlings" philosophy you mentioned earlier:

1. Your **Binaries** and **Configs** are safe because they are defined in your `.nix` code. If you wipe your drive, they come back exactly the same.
2. Your **Cache** is erased (which is fine, it's just temporary junk).
3. Your **Saved Data** (`.local/share`) is what you must "Persist" (save to a separate drive or partition) because Nix does not manage it.

**Would you like me to help you configure a specific application (like Neovim or Git) so that its config is managed by Nix while its data stays in your home folder?**
