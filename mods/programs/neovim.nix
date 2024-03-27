{
  config,
  _lib,
  lib,
  pkgs,
  ...
}:
let
  mynv =
    let
      con = pkgs.neovimUtils.makeNeovimConfig {
        plugins = builtins.attrValues {
          inherit (pkgs.vimPlugins) nvim-lspconfig nvim-tree-lua nvim-web-devicons;
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
in
{
  options._programs.neovim = _lib.mkEnable;
  config = lib.mkIf config._programs.neovim {
    users.users.main.packages = [ mynv ];
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
