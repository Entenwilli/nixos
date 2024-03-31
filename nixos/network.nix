{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
   environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
    networkmanagerapplet
  ];

  sops.secrets."networks.env" = { 
    restartUnits = [ "NetworkManager-ensure-profiles.service" ];
  };

  # Set Hostname
  networking.hostName = "nixos-laptop";
  # Enable network manager
  networking.networkmanager = {
    enable = true;
    ensureProfiles ={
      environmentFiles = [ config.sops.secrets."networks.env".path ];
      profiles = {
        kit = {
          connection = {
            id = "$kit_ssid";
            uuid = "$kit_uuid";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$kit_ssid";
          };
          wifi-security = {
            key-mgmt = "wpa-eap";
          };
          "802-1x" = {
            anonymous-identity = "anonymous@kit.edu";
            ca-cert = "/etc/ssl/certs/ca-certificates.crt";
            domain-suffix-match = "radius-wlan.scc.kit.edu";
            eap = "ttls;";
            identity = "$kit_identity";
            password = "$kit_psk";
            phase2-auth = "pap";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          }; 
        };
        "kit-vpn" = {
          connection = {
            id = "$kitvpn_ssid";
            uuid = "$kitvpn_uuid";
            type = "vpn";
          };
          vpn = {
            ca = "/home/felix/.cert/nm-openvpn/kit-v6-ca.pem";
            connection-type = "password";
            dev = "tun";
            password-flags = "0";
            port = "1194";
            remote = "[2a00:1398:0:4::7:6]::";
            tls-version-min = "1.3";
            username = "$kitvpn_identity";
            verify-x509-name = "name:ovpn.scc.kit.edu";
            service-type = "org.freedesktop.NetworkManager.openvpn";
          };
          vpn-secrets = {
            password = "$kitvpn_psk";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "stable-privacy";
            method = "auto";
          };
        };
        phone-hotspot = {
          connection = {
            id = "$hotspot_ssid";
            uuid = "$hotspot_uuid";
            type = "wifi";
            interface-name = "wlp0s20f3";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$hotspot_ssid";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$hotspot_psk";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
        home-wifi = {
          connection = {
            id = "$home_ssid";
            uuid = "$home_uuid";
            type = "wifi";
            interface-name = "wlp0s20f3";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$home_ssid";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$home_psk";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };
        parents-wifi = {
          connection = {
            id = "$parents_ssid";
            uuid = "$parents_uuid";
            type = "wifi";
            interface-name = "wlp0s20f3";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "$parents_ssid";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$parents_psk";
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
        };

      };
    };
  };
}
