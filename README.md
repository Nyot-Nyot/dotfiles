# dotfiles

Konfigurasi pribadi untuk **CachyOS + GNOME + fish shell**.
Dikelola dengan [GNU Stow](https://www.gnu.org/software/stow/).

---

## 📖 Apa itu Stow?

Stow adalah tool yang membuat **symlink** dari file di repo ini ke lokasi
yang dibaca aplikasi.

Contoh: `fish` membaca `~/.config/fish/config.fish`. File aslinya ada
di repo ini di `fish/.config/fish/config.fish`. Stow membuat symlink:

```
~/.dotfiles/fish/.config/fish/config.fish   ← file asli (di-git)
        ↓ symlink
~/.config/fish/config.fish                  ← dibaca oleh fish
```

**Keuntungan:**
- File asli tetap di git → bisa di-track, di-restore, di-sync
- Aplikasi tetap baca di tempat normal → tidak perlu ubah setting
- Ganti setup tinggal `stow` / `stow -D` tanpa hapus file

**Aturan emas stow:** path relatif di dalam folder = path relatif dari `$HOME`.

```
~/.dotfiles/fish/.config/fish/config.fish
         ^^^^
         nama package
             ^^^^^^^^^^^^^^^^^^^^^^^^^
             → jadi ~/.config/fish/config.fish
```

---

## 🗂️ Struktur Repo

```
~/.dotfiles/
├── README.md              # file ini
├── install.sh             # bootstrap mesin baru
├── .gitignore             # exclude runtime & secret
│
├── fish/                  # Fish shell
│   └── .config/fish/
│       ├── config.fish
│       └── conf.d/
│           ├── omf.fish
│           └── kraken-cli.env.fish
│
├── btop/                  # Resource monitor
│   └── .config/btop/btop.conf
│
├── fastfetch/             # System info fetch
│   └── .config/fastfetch/config.jsonc
│
├── git/                   # Git config
│   └── .gitconfig
│
├── micro/                 # Micro editor
│   └── .config/micro/settings.json
│
├── mise/                  # SDK version manager
│   └── .config/mise/config.toml
│
├── vscode/                # VS Code settings
│   └── .config/Code/User/
│       ├── settings.json
│       └── keybindings.json
│
└── zsh/                   # Arsip (tidak dipakai)
    └── .zshrc
```

Setiap folder level-1 = satu **package** yang bisa di-stow.

---

## 🚀 Setup di Mesin Baru

```bash
# 1. Clone repo
git clone git@github.com:Nyot-Nyot/dotfiles.git ~/.dotfiles

# 2. Installer (otomatis install stow + backup konflik + stow semua)
cd ~/.dotfiles
./install.sh

# 3. Selesai — config langsung aktif
```

**Install sebagian:**
```bash
./install.sh fish git       # hanya fish & git
./install.sh vscode         # hanya vscode
```

Konflik otomatis di-backup ke `~/.dotfiles-backup-<tanggal>/`.

---

## 🔧 Perintah Stow Sehari-hari

Semua dari `~/.dotfiles`.

### Stow (aktifkan)
```bash
stow fish              # aktifkan config fish
stow fish git vscode   # beberapa sekaligus
```

### Unstow (matikan)
```bash
stow -D fish           # hapus symlink (file asli tetap ada)
```

### Restow (refresh)
Berguna setelah nambah/hapus file:
```bash
stow -R fish
```

### Dry-run
Lihat apa yang akan dilakukan tanpa eksekusi:
```bash
stow -nv fish
```

---

## 🔄 Workflow Edit Config

Karena symlink, edit di lokasi normal = edit di repo.

### Nambah alias fish
```bash
# 1. Edit
micro ~/.config/fish/config.fish

# 2. Commit
cd ~/.dotfiles
git status
git diff
git add fish/.config/fish/config.fish
git commit -m "fish: tambah alias gs"
git push
```

### Nambah package baru (contoh: `starship`)
```bash
# 1. Copy config ke repo
mkdir -p ~/.dotfiles/starship/.config
cp -r ~/.config/starship ~/.dotfiles/starship/.config/

# 2. Stow
cd ~/.dotfiles
stow starship

# 3. Commit
git add starship
git commit -m "starship: initial config"
git push
```

---

## ⚠️ Hal Penting

| Aturan | Keterangan |
|---|---|
| **Runtime jangan di-stow** | `fish_variables`, cache, log — sudah di-gitignore |
| **Secret jangan di-commit** | Pakai `~/.config/fish/local.fish` (gitignored) |
| **Symlink bukan copy** | Edit di mana saja, file asli satu |
| **Konflik = file asli ada** | Installer backup otomatis |
| **Test dulu** | `stow -nv <pkg>` sebelum eksekusi |

### Cara handle secret

Buat `~/.config/fish/local.fish`:
```fish
set -gx OPENAI_API_KEY "sk-..."
set -gx GITHUB_TOKEN "ghp_..."
```

Panggil dari `config.fish`:
```fish
if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end
```

File `local.fish` **tidak akan ikut ke git** karena sudah di-`.gitignore`.

---

## 🎨 Multi-Setup (Masa Depan)

Repo ini siap berkembang kalau nanti ganti setup (GNOME → Hyprland + Caelestia):

```
~/.dotfiles/
├── common/       # dipakai semua (git, mise, fish)
├── gnome/        # khusus GNOME
├── hypr/         # khusus Hyprland
└── caelestia/    # khusus Caelestia
```

Switch:
```bash
cd ~/.dotfiles
stow -D gnome           # matikan GNOME
stow hypr caelestia     # aktifkan Hyprland
```

File asli selalu aman. Yang berubah cuma symlink di `~/`.

---

## 📌 Catatan Khusus

- `config.fish` punya `source /usr/share/cachyos-fish-config/cachyos-config.fish`
  — ini khusus CachyOS. Kalau pindah distro, edit/hapus baris ini.
- `kraken-cli.env.fish` cuma `source $HOME/.cargo/env.fish` (Rust env).
- `omf.fish` untuk Oh My Fish — install `omf` dulu di mesin baru kalau pakai.

---

## 🔗 Referensi

- [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Awesome dotfiles](https://github.com/webpro/awesome-dotfiles)

