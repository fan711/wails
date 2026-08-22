//go:build linux && layershell && !gtk3 && !server

package application

/*
#cgo linux pkg-config: gtk4-layer-shell-0
#include "layershell_linux.h"
*/
import "C"

// Layer-shell support sits behind the `layershell` build tag because
// gtk4-layer-shell has to be linked into the binary — it works by interposing
// libwayland-client, so loading it with dlopen after GTK has initialised is too
// late. Making it unconditional would put a new system dependency on every
// Wails Linux build, and only windows that place themselves need it.
//
//	go build -tags layershell
//
// Requires libgtk4-layer-shell-dev at build time and libgtk4-layer-shell.so.0
// at runtime.

func (w *linuxWebviewWindow) moveLayerShell(x, y int) {
	if !w.parent.options.Linux.LayerShell {
		return
	}
	C.window_move_layer_shell(w.gtkWindow(), C.int(x), C.int(y))
}
