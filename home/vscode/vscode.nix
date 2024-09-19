{config, pkgs, ...}:

{
    imports = [
        ./language-snippets.nix
    
    ];
    
    programs.vscode = {
        enable = true;
        extensions = with pkgs; [
            vscode-extensions.vue.volar
            vscode-extensions.rust-lang.rust-analyzer
            vscode-extensions.jnoortheen.nix-ide
            ];
    };
}