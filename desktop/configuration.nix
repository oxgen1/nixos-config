# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackagesy
  ];

  # boot.kernelParams = [
  #   "nvidia-drm.fbdev=1"
  #  ];
 boot.initrd.kernelModules = [ 
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
 ];

  nixpkgs.config.allowUnfree = true;
  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Manual optimise storage: nix-store --optimise
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.

  # xdg.portal = {
  #     enable = true;
  #     wlr.enable = true;
  #     extraPortals = with pkgs; [
  #       xdg-desktop-portal-wlr
  #     ];
  #   };

  # Enable OpenGL
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  programs.hyprland = {
    enable = false;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing.drivers = [ pkgs.brlaser ];

  # services.mysql.enable = true;
  # services.mysql.package = pkgs.mariadb;

  # security.wrappers."mount.nfs" = {
  #   setuid = true;
  #   owner = "root";
  #   group = "root";
  #   source = "${pkgs.nfs-utils.out}/bin/mountf.nfs";
  # };

  security.pam = {
    u2f = {
      enable = true;
      settings = {
        interactive = false;
        cue = true;
      };
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
      kde.u2fAuth = true;
      sddm.u2fAuth = true;
      polkit-1.u2fAuth = true;
    };
  };

  services.desktopManager.plasma6.enable = true;

  networking.networkmanager.enable = true;

  programs.fish.enable = true;
  programs.direnv.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.gnupg = {
    dirmngr.enable = true;
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  programs.steam = {
    enable = true;
  };
  programs.kdeconnect.enable = true;

  networking.hostName = "jacks-pc"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.openocd
  ];
  #  hardware.gpgSmartcards.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # nixpkgs.overlays= [
  #    (final: prev: {
  #       orca-slicer = prev.orca-slicer.overrideAttrs (old: {
  #         postInstall = (old.postInstall or "") + ''
  #           mv $out/bin/orca-slicer $out/bin/.orca-slicer-wrapped
  #           echo "env __GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink WEBKIT_DISABLE_DMABUF_RENDERER=1 $out/bin/.orca-slicer-wrapped" > $out/bin/orca-slicer
  #           chmod +x $out/bin/orca-slicer
  #         '';
  #       });
  #     })
  # ];
  users.users.jack = {
    isNormalUser = true;
    home = "/home/jack";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "jackaudio"
      "plugdev"
      "dialout"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      age-plugin-yubikey
      bun
      alacritty
      antigravity
      age
      nushell
      starship
      zellij
      mpv
      yubioath-flutter
      flameshot
      yazi
      spotify
      obsidian
      discord
      orca-slicer
      fzf
      freecad
      gnuradio
      ardour
      yubikey-personalization
      yubico-piv-tool
      android-studio
      yubioath-flutter
      nixfmt
    ];
  };

  users.users.root.hashedPassword = "!"; #Disables Root Login


  #   List packages installed in system profile. To search, run:
  #   $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    curl
    brave
    vscode
    python3
    exodus
    # cura
    # hackrf
    # soapyhackrf
    # soapysdr
    # gqrx
    kicad-small
    nodejs_20
    btop
    # urh
    zulu # java
    zulu17
    # cubicsdr
    dropbox
    usbutils
    yubikey-manager
    gnupg
    wireguard-tools
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #   services.openssh = {
  #   enable = true;
  #   ports = [ 22 ];
  #   settings = {
  #     PasswordAuthentication = true;
  #     AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
  #     UseDns = true;
  #     X11Forwarding = false;
  #     PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
  #   };
  # };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
    ];
    allowedUDPPorts = [
      51821
    ]; # Clients and peers can use the same port, see listenport
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.generateKey = true;
    secrets.mywg_pk = { };
    secrets.cthwg_pk = { };
  };

  # networking.vlans = {
  #   internet = {id=10; interface="enp3s0"; };
  #   admin = {id=500; interface="enp3s0"; };
  # };
  hardware.hackrf.enable = true;
  # Enable WireGuard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.8.0.4/32" ];
      listenPort = 51821; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = config.sops.secrets.mywg_pk.path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "0CExFB1dRPXq23P+pMi3xREjG+ObZQXkPUcJkTrWiH4=";

          allowedIPs = [ "10.8.0.0/24" ];

          endpoint = "185.244.36.108:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
    wg1 = {
      # Hackspace
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "192.168.42.5" ];
      listenPort = 51823; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = config.sops.secrets.cthwg_pk.path;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.

        {
          # Public key of the server (not a file path).
          publicKey = "CzofXYCRSMXOEtdhdXK2/y+q1ywMEM4rdnOtNxFGyFc=";

          allowedIPs = [
            "192.168.42.0/24"
            "192.168.122.0/24"
          ];

          endpoint = "vpn.cthacker.space:23456"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
        }
      ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.space-mono
    nerd-fonts.zed-mono
    # (nerdfonts.override { fonts = [ "SpaceMono" "ZedMono" ]; })
  ];
  fonts.fontDir.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  # nixpkgs.config.packageOverrides = pkgs: {
  #   # avahi = pkgs.avahi.override {withLibdnssdCompat = true; };
  #   bun = pkgs.bun.overrideAttrs {
  #     src = builtins.fetchurl {
  #       url = "https://github.com/oven-sh/bun/releases/download/canary/bun-linux-x64.zip";
  #       sha256 = "sha256:17sigs5h32kn5d5mn05by1d0j8aanlwgl9s7li677rsggikkvl3w";
  #     };
  #   };
  # };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
