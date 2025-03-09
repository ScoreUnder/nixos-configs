{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.services.lvm.enable = true;
  boot.initrd.luks.devices = {
    laptop = {
      device = "/dev/disk/by-uuid/37af424a-41db-4c4e-9916-bd8954c5be47";
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/365e0f34-1a00-4c0f-80db-cb9a5d75ddd2";
      fsType = "btrfs";
      options = [ "lazytime" "subvol=nixos" "discard" "ssd" ];
      encrypted = {
        enable = true;
        label = "laptop";
        blkDev = "/dev/disk/by-uuid/37af424a-41db-4c4e-9916-bd8954c5be47";
      };
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8E6C-B908";
      fsType = "vfat";
      options = [ "lazytime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/4ea2e168-4711-4fcb-b8cb-2e98cb85269b"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wwp0s20u4.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
