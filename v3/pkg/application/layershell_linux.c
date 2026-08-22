//go:build linux && layershell && !gtk3 && !server

#include "layershell_linux.h"

#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/wayland/gdkwayland.h>
#include <gtk4-layer-shell.h>
#endif

// window_enable_layer_shell turns the window into a zwlr_layer_shell_v1
// surface. That is how a Wayland client places a surface on screen: an
// ordinary xdg_toplevel has no say in where the compositor puts it, which is
// why window_move_x11 has no Wayland counterpart.
//
// A surface can only become a layer surface before it is first mapped, so this
// runs with the rest of the window setup rather than at the first move.
// Returns FALSE on X11, or where the compositor does not implement the
// protocol, leaving an ordinary window behind.
gboolean window_enable_layer_shell(GtkWindow *window) {
#ifdef GDK_WINDOWING_WAYLAND
    GdkDisplay *display = gdk_display_get_default();
    if (display == NULL || !GDK_IS_WAYLAND_DISPLAY(display)) return FALSE;
    if (!gtk_layer_is_supported()) return FALSE;
    // Too late once the surface exists, and pointless twice.
    if (gtk_layer_is_layer_window(window)) return TRUE;
    if (gtk_widget_get_realized(GTK_WIDGET(window))) return FALSE;

    gtk_layer_init_for_window(window);
    gtk_layer_set_layer(window, GTK_LAYER_SHELL_LAYER_OVERLAY);
    // Reserve nothing, which is also what asks the compositor to keep the
    // surface inside the space panels leave free.
    gtk_layer_set_exclusive_zone(window, 0);
    // Without this the surface accepts no keyboard input at all, so nothing in
    // the webview could be typed into.
    gtk_layer_set_keyboard_mode(window, GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
    return TRUE;
#else
    (void)window;
    return FALSE;
#endif
}

#ifdef GDK_WINDOWING_WAYLAND
// window_anchor_axis anchors one axis to whichever of its two edges the window
// sits nearer, with the gap to that edge as the margin. A margin is only ever
// measured from an anchored edge, so anchoring to the near one keeps the
// placement accurate and lets the compositor account for a panel there.
static void window_anchor_axis(GtkWindow *window, int startEdge, int endEdge, int startGap, int endGap) {
    int anchor = startEdge, opposite = endEdge, margin = startGap;
    if (endGap >= 0 && endGap < startGap) {
        anchor = endEdge;
        opposite = startEdge;
        margin = endGap;
    }
    if (margin < 0) margin = 0;

    gtk_layer_set_anchor(window, opposite, FALSE);
    gtk_layer_set_anchor(window, anchor, TRUE);
    gtk_layer_set_margin(window, anchor, margin);
}
#endif

// window_move_layer_shell positions a window that window_enable_layer_shell
// converted, and does nothing to any other window.
//
// A layer surface is placed by anchoring it to screen edges and setting margins
// from them, so the caller's absolute coordinates are turned into a margin from
// whichever edge the window ends up nearest. That choice is what keeps a popup
// off a panel: margins are measured from the edge of the area panels leave
// free, so a window near the bottom of a screen with a taskbar is pushed above
// it. GTK4 no longer reports the work area at all, so this is the only way to
// know about it — see the WorkArea field on Screen, which is the full monitor
// on this backend.
gboolean window_move_layer_shell(GtkWindow *window, int x, int y) {
#ifdef GDK_WINDOWING_WAYLAND
    // Converted on the first move rather than at window setup: a layer surface
    // has to be created before the window is mapped, and doing it eagerly
    // realizes the surface — which loads the page for a window the app asked to
    // keep hidden. Every caller positions the window before showing it.
    if (!gtk_layer_is_layer_window(window) && !window_enable_layer_shell(window)) return FALSE;

    GdkDisplay *display = gdk_display_get_default();
    GdkRectangle screen = {0, 0, 0, 0};
    if (display != NULL) {
        GListModel *monitors = gdk_display_get_monitors(display);
        if (monitors != NULL && g_list_model_get_n_items(monitors) > 0) {
            GdkMonitor *monitor = (GdkMonitor *)g_list_model_get_item(monitors, 0);
            if (monitor != NULL) {
                gdk_monitor_get_geometry(monitor, &screen);
                g_object_unref(monitor);
            }
        }
    }

    int width = 0, height = 0;
    gtk_window_get_default_size(window, &width, &height);

    window_anchor_axis(window,
                       GTK_LAYER_SHELL_EDGE_LEFT, GTK_LAYER_SHELL_EDGE_RIGHT,
                       x, screen.width - (x + width));
    window_anchor_axis(window,
                       GTK_LAYER_SHELL_EDGE_TOP, GTK_LAYER_SHELL_EDGE_BOTTOM,
                       y, screen.height - (y + height));
    return TRUE;
#else
    (void)window; (void)x; (void)y;
    return FALSE;
#endif
}
