#ifndef WAILS_LAYERSHELL_LINUX_H
#define WAILS_LAYERSHELL_LINUX_H

#include <gtk/gtk.h>

// zwlr_layer_shell_v1 support, built only with the `layershell` tag. See
// layershell_linux.go for why it is not on by default.

gboolean window_enable_layer_shell(GtkWindow *window);
gboolean window_move_layer_shell(GtkWindow *window, int x, int y);

#endif
