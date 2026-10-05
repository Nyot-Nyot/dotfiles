source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

if status is-interactive
    # Mengaktifkan mise secara otomatis
    mise activate fish | source

    # Environment Variable untuk Flutter Version Manager
    set -gx FVM_HOME $HOME/fvm
end

# opencode
fish_add_path $HOME/.opencode/bin
fish_add_path $HOME/.spicetify
