{config, ...}: {
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "${config.users.users.felix.home}/.config/sops/age/keys.txt";

  sops.secrets.spotify-client-id = {
    owner = config.users.users.felix.name;
  };
}
