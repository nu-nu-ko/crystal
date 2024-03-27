{
  config,
  _lib,
  lib,
  ...
}:
{
  options._programs.htop = _lib.mkEnable;
  config.programs.htop = lib.mkIf config._programs.htop {
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
}
