//go:build linux && !layershell && !gtk3 && !server

package application

// Without the `layershell` build tag a Wayland window keeps the behaviour it
// has always had: the compositor decides where it goes. See layershell_linux.go.

func (w *linuxWebviewWindow) moveLayerShell(_, _ int) {}
