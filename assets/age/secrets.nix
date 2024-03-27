let
  factory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ";
  library = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq";
in
{
  "user.age".publicKeys = [
    factory
    library
  ];

  "user_cloud.age".publicKeys = [ library ];
  "user_cloud_pom.age".publicKeys = [ library ];
  "personal_mail.age".publicKeys = [ library ];

  "services_mail.age".publicKeys = [ library ];
  "vault_env.age".publicKeys = [ library ];
  "cloud_env.age".publicKeys = [ library ];
  "synapse_shared.age".publicKeys = [ library ];
}
