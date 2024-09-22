{config, pkgs, ...}:

{
    imports = [
        ./language-snippets.nix
    
    ];
    
    programs.vscode = {
        enable = true;
        extensions = with pkgs; [
            vscode-extensions.vue.volar
            vscode-extensions.ms-vscode-remote.remote-ssh
            vscode-extensions.ms-vscode-remote.remote-ssh-edit
            vscode-extensions.rust-lang.rust-analyzer
            vscode-extensions.jnoortheen.nix-ide
            ];
    };
}