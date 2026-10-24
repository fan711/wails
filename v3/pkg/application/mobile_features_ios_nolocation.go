//go:build ios && wails_nolocation

package application

// Compiles the geolocation feature out of mobile_features_ios.m, so the binary
// references no CoreLocation symbol and needs no location purpose string.
// GetLocation then answers every request with a "common:location" error.

/*
#cgo CFLAGS: -DWAILS_NO_LOCATION
*/
import "C"
