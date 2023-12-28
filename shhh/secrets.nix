let
  factory = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBN4+lDQxOfTVODQS4d3Mm+y3lpzpsSkwxjbzN4NwJlJ";
  library = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFhTVx3lCAqu9xxn8kPwH0bl0Qg0cE6E0TSJILErD3mq";
in {
  "next.age".publicKeys = [library];
  "mail.age".publicKeys = [library];
  "user.age".publicKeys = [factory library];
}
