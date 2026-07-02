# fontalign 0.1.0

* Initial release.
* `fontalign_save()`: render a ggplot (or any print-able) object to a file with
  font size aligned to the target `dpi`, without modifying the plot or theme.
* `fontalign_check_system()`: report Cairo/Pango/fontconfig/HarfBuzz/font
  installation status for Linux server deploys.
* `fontalign_resolve_backend()`: route complex-script text (Arabic, Persian,
  Devanagari, Thai) to a HarfBuzz-capable backend (ragg or svglite).
* `fontalign_list_fonts()`: enumerate fontconfig-registered families.
