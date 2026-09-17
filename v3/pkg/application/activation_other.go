//go:build !linux || !cgo || android || server

package application

// HasPendingActivationToken is a Wayland concern (linux_cgo.go): elsewhere a
// window can be raised without the compositor's leave.
func HasPendingActivationToken() bool { return false }
