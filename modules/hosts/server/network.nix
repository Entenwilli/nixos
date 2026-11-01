{...}: {
  flake.nixosModules.server-network = {...}: {
    networking = {
      hostName = "nixos-server";
      interfaces.enp0s31f6 = {
        ipv4.addresses = [
          {
            address = "94.130.23.187";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a01:4f8:10b:1cd2::1";
            prefixLength = 64;
          }
          {
            address = "2a01:4f8:10b:1cd2::1ce3";
            prefixLength = 64;
          }
        ];
      };
      defaultGateway = {
        address = "94.130.23.129";
        interface = "enp0s31f6";
      };
      defaultGateway6 = {
        address = "fe80::1";
        interface = "enp0s31f6";
      };
      nameservers = [
        "185.12.64.1"
        "185.12.64.2"
      ];
    };
  };
}
