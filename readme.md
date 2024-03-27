# ⚠ READ ME ⚠
I will link to this repo as demonstration but I do *not* endorse the use of practically any section of it as is.
I will freqently use functions/options/values and practices which you probably dont want yourself.
if you are here looking to learn more about nix and or "get started" with nixos, Please use the manuals instead! I promise nothing here is worth your time.

<img align="right" src="./assets/gaynixlogo.png" width="300"/>

# nix(os) config for my system(s)

## hosts
- factory: desktop
- library: server
- portal: wsl
- todos: rpi, tablet, laptop(s), server assist

## file structure
- assets:
    - any nix not needed to eval any host (expection for agenix's secrets.nix, and local pacakges.)
    - any resource that is not nix code (exception for repo files e.g. this readme)
- hosts: one file per system for local module setup, config specific to only that machine & hardware setup.
- mods:
    - services:
        - web: any service providing a web interface
    - programs: program setup/configuration/modification *not* packages
    - desktop.nix: anything which makes up the "desktop experience" e.g.. fuzzel, hyprland, ags
    - user.nix: all user/group setup, e.g.. noroot, shell setup, default user packages, service media groups etc
    - common.nix: e.g.. common nix/(os) options 
    - system.nix: common system setup e.g.. wired net, hostkeys (might merge with common.nix)
- flake.nix/lock
### module options structure
- \_services:
    - web:
- \_programs:
- \_user: 
- \_desktop:
- \_common:
- \_system:

## odditys / rules
- I strongly dislike `with`, I will refuse to use it at all
- I dislike managing what imports what, as such all hosts import all mods and libs. this also forces me to make sure their options are set correctly xD

- assertions for when a module MUST be anabled for another to work
- mkIf for sections only required when a module is enabled
( both of these sound like no brainers but its easy to just not bother when its a personal repo )

- common setup should always be a module, even if a single line.. (e.g.. postgresql)
( altho painful is likely a net positive for readability.. )


## todos
- look into writing my own solution for managing encrypting secrets
- replace nh, as I only use `nh os *`

## misc
- `libs/options.nix{home.file}`: written by [eclairevoyant](https://github.com/eclairevoyant)
- recursive importing taken from an old stage of [Gerg-L](https://github.com/Gerg-L)'s nixos repo, I've since changed it.
- `nix eval .#nixosConfigurations.host.config.*`, also the repl exists..
