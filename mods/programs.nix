{
  config,
  lib,
  nuke,
  pkgs,
  ...
}:
let
  ### neovim...
  mynv =
    let
      con = pkgs.neovimUtils.makeNeovimConfig {
        plugins = builtins.attrValues {
          inherit (pkgs.vimPlugins)
            nvim-lspconfig
            nvim-tree-lua
            nvim-web-devicons
            gruvbox-nvim
            ;
        };
        withPython3 = false;
        withRuby = false;
        viAlias = true;
        vimAlias = true;
        luaRcContent = ''
          local k = vim.keymap.set
          k("n", "<C-DOWN>", "<cmd>resize +2<cr>")
          k("n", "<C-UP>", "<cmd>resize -2<cr>")
          k("n", "<C-RIGHT>", "<cmd>vertical resize -2<cr>")
          k("n", "<C-LEFT>", "<cmd>vertical resize +2<cr>")
          k("n", "<S-LEFT>", "<C-w>h")
          k("n", "<S-DOWN>", "<C-w>j")
          k("n", "<S-UP>", "<C-w>k")
          k("n", "<S-RIGHT>", "<C-w>l")
          k('t', '<esc>', "<C-\\><C-n>")
          local o = vim.opt
          o.lazyredraw = true
          o.shell = "zsh"
          o.shadafile = "NONE"
          o.ttyfast = true
          o.termguicolors = true
          o.undofile = true
          o.smartindent = true
          o.tabstop = 2
          o.shiftwidth = 2
          o.shiftround = true
          o.expandtab = true
          o.cursorline = true
          o.relativenumber = true
          o.number = true
          o.viminfo = ""
          o.viminfofile = "NONE"
          o.wrap = false
          o.splitright = true
          o.splitbelow = true
          o.laststatus = 0
          o.cmdheight = 0
          vim.cmd.colorscheme 'gruvbox'
          vim.api.nvim_command("autocmd TermOpen * startinsert")
          vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")
          require('nvim-tree').setup {
            disable_netrw = true,
            hijack_netrw = true,
            hijack_cursor = true,
            sort_by = "case_sensitive",
            renderer = {
              group_empty = true,
            },
            filters = {
              dotfiles = true,
            },
          }
          require('lspconfig').nil_ls.setup {
            autostart = true,
            capabilities = vim.lsp.protocol.make_client_capabilities(),
            cmd = {'nil'},
          }
        '';
      };
      wrapperArgs = con.wrapperArgs ++ [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [ pkgs.nil ]}"
      ];
    in
    pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (con // { inherit wrapperArgs; });
  ###
  inherit (nuke) mkEnable;
  inherit (lib) mkIf;
  inherit (config.mods.programs)
    git
    ssh
    neovim
    htop
    ;
in
{
  options.mods.programs = {
    neovim = mkEnable;
    git = mkEnable;
    ssh = mkEnable;
    htop = mkEnable;
  };
  config = {
    users.users.main.packages = mkIf neovim [ mynv ];
    environment.variables = mkIf neovim {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    programs = {
      ### git
      git = mkIf git {
        enable = true;
        config = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          user = {
            name = "nuko";
            email = "nuko@shimeji.cafe";
            signingkey = "/home/${config.users.users.main.name}/.ssh/id_ed25519.pub";
          };
          gpg.format = "ssh";
          commit.gpgsign = true;
        };
      };
      ### ssh
      ssh = mkIf ssh {
        knownHosts = {
          library = {
            extraHostNames = [
              "tea.shimeji.cafe"
              "192.168.0.3"
              "119.224.63.166"
            ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+1CxNCNvstjiRJFgJHVgqb/Mm1MJZOSoahwzgGXHMH";
          };
          factory = {
            extraHostNames = [ "192.168.0.4" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLJR5DDyMYyKoUaZDML29f1AEJZ98nfizrdJ8jCLP6h";
          };
          "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };
      htop = mkIf htop {
        enable = true;
        settings = {
          hide_kernel_threads = true;
          hide_userland_threads = true;
          shadow_other_users = true;
          show_program_path = false;
          hide_function_bar = 2;
          header_layout = "two_50_50";
          column_meters_0 = "LeftCPUs4 CPU MemorySwap";
          column_meter_modes_0 = "1 1 1";
          column_meters_1 = "RightCPUs4 NetworkIO DiskIO";
          column_meter_modes_1 = "1 2 2";
          tree_view = true;
        };
      };
    };
  };
}
