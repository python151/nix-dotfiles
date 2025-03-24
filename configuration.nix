# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-framework"; # Define your hostname.

  networking.extraHosts = ''
    172.16.100.3 nix-server
    172.16.100.4 emily747-enclave
    209.16.157.106 emily747-ingress
    10.38.41.233 emily747-web
    10.38.41.243 lab-proxmox
  '';

  networking.wireguard.interfaces.wg0 = {
	ips = [ "172.16.100.2/24" ];
	listenPort = 51820;
        postSetup = ''
	  cp /etc/resolv.conf /etc/resolv.conf-old
	  echo -ne "nameserver 10.38.38.2\nnameserver 10.38.42.2\nnameserver 1.1.1.1\nnameserver 9.9.9.9" > /etc/resolv.conf
	  default_gw=$(ip route | grep default | /run/current-system/sw/bin/awk '{print $3}')
          ip route add 209.16.157.106/32 via $default_gw
        ''; 
        postShutdown = ''
	  mv /etc/resolv.conf-old /etc/resolv.conf
          ip route del 209.16.157.106/32
        '';
	privateKeyFile = "/var/secrets/wireguard_key";
	peers = [
		{
			publicKey = "0yimYDtHWQ9IxTlt78D8yaZ8u9R+HpopAH5nT+YM3VE=";
			allowedIPs = [ "0.0.0.0/0" ];
			endpoint = "209.16.157.106:51820";
			persistentKeepalive = 25;
		}
	];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the KDE Desktop Environment
  #services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  #services.xserver.xkb = {
  #  layout = "us";
  #  variant = "";
  #};

  # Hyprland bullshit part 1
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM  = true;
  programs.uwsm.enable = true;
#  services.xserver.enable = true;
#  services.displayManager.sddm.enable = true;
#  services.displayManager.sddm.wayland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.nm-applet.enable = true;
  programs.thunar.enable = true;
  services.blueman.enable = true;
  programs.hyprlock.enable = true;
  security.pam.services.hyprlock = {};
  # End hyprland bullshit part 1

  # zsh stuff
  users.defaultUserShell=pkgs.zsh; 
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -laugh";
      update = "sudo nixos-rebuild switch";
    };
    histSize = 10000;
  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      TLP_DEFAULT_MODE = "BAT";
      TLP_PERSISTENT_DEFAULT = 1;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.emily747 = {
    isNormalUser = true;
    description = "Emily ;3";
    extraGroups = ["networkmanager" "wheel" "dialout" "kvm" ];
    packages = with pkgs; [
      file
      chromium
      kitty
      neovim
      git
      python3
      cryptsetup
      lvm2
      discord
      obsidian
      keepassxc
      rclone
      openvpn
      p7zip
      stdenv
      gdb
      wireshark
      burpsuite
      john
      nmap
      sage
      ghc
      openjdk
      netcat
      dig
      ghidra
      radare2
      gnumake
      unzip
      ninja
      meson
      patchelf
      thunderbird
      putty
      prusa-slicer
      freecad
      signal-desktop
      jellyfin-media-player
      pwntools
      vlc
    ];
  };

  # Virtualization
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["emily747"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;

    # Create a `docker` alias for podman, to use it as a drop-in replacement
    dockerCompat = true;

    # Required for containers under podman-compose to be able to talk to each other.
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.waydroid.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    libsodium
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    libunwind
    libxkbcommon
    openssl
    stdenv.cc.cc
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    libsForQt5.qtbase
    libunwind
    libxkbcommon
    libsecret
    openssl.out
    stdenv.cc.cc
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
    curl
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    mommy
    qemu
    nix-ld
    steam-run
    pkg-config
    pkgs.man-pages
    pkgs.man-pages-posix
    gcc # C and C++ compiler
    gpp # C++ compiler specifically
    libtool # Tool for managing libraries
    automake # For automatic configuration of build systems
    mesa
    # Hyprland bullshit
    wofi # application launcher
    waybar # that noice status bar
    grim # screenshots
    slurp # more screenshots
    mako # notifications
    wl-clipboard # for clipboard and such
    hyprpaper # wallpaper
    brightnessctl # controls screen brightness
    # end hyprland bullshit
    docker-compose
  ];

  environment.extraInit = ''
    if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
      export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
    fi
  '';

  
  fonts.packages = with pkgs; [ nerdfonts ];
  documentation.dev.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  hardware.graphics.enable = true;


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  environment.etc."openvpn/update-resolv-conf" = {
    source = /run/current-system/sw/bin/resolvconf;
    mode = "0755"; # Set executable permission if needed
  };
}
