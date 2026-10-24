//go:build ios && !wails_nolocation

package application

// CoreLocation is linked only when the geolocation feature is compiled in.
// Build with -tags wails_nolocation to leave it out entirely: App Store Connect
// flags any binary that references CoreLocation without a location purpose
// string in Info.plist (ITMS-90683), whether or not the app ever asks.

/*
#cgo LDFLAGS: -framework CoreLocation
*/
import "C"
