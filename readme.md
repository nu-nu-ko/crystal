## ⚠ WARNING ⚠
Please dont blindly attempt to paste anything here or "start from" this.
I promise its less pain to do this yourself.

Please feel free to comment on where I can improve! I really appreciate it

<img align="right" src="./gay.png" width="300"/>

## nix(os) config for my system(s).

### hosts
- `factory`: desktop
- `library`: server
- `portal` : wsl
- there are others I need to add I'm just lazy..

### structure oddities
- Yeah I really like `inherits` yeah I really dislike `with`
- assertions arent used ever despite breaking combinations being easily possible lol, I only dont do this as nothing here is intended to be cut n paste!

### potential todos
- replace `nh` and `agenix` both are fine just something id like to know how to do myself.
- move ALL theme resources and packages out of here

### extras
- `lib/homeFiles.nix`: thanks [eclairevoyant](https://github.com/eclairevoyant)
- `importAll`: thanks [Gerg-L](https://github.com/Gerg-L/) ( I've since just made it take a list )
- colours: [mountain](https://github.com/mountain-theme/Mountain), [my themes](https://github.com/nu-nu-ko/mountain-nix)
- `pkgs/sfFonts.nix`: [San Francisco](https://developer.apple.com/fonts/) 

### misc
- nix eval like, exists, `nix eval .#nixosConfigurations.hostname.config.foo` is epic. ( also the repl lol )
- tf2: [DeerHud](https://tf2huds.dev/hud/DeerHud), [master comfig](https://comfig.app/app/) launch options `LD_PRELOAD=/usr/lib32/libtcmalloc_minimal.so  SDL_VIDEODRIVER=x11 %command% +exec autoexec -vulkan -full -novid -nojoy -nosteamcontroller -nohltv -particles 1 -precachefontchars -noquicktime`
