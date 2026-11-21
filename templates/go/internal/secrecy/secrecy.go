// Package secrecy provides a redacting wrapper for the WB bearer JWT.
package secrecy

import (
	"crypto/subtle"
	"fmt"
	"strconv"
)

const redacted = "<REDACTED>"

// SecretString wraps a secret so it redacts under fmt/log and every
// common encoder (JSON, text, binary, YAML).
type SecretString struct {
	value string
}

func NewSecretString(value []byte) SecretString {
	return SecretString{value: string(value)}
}

// ExposeSecret returns the raw secret — deliberately awkward so
// accidental leaks become explicit.
func (s SecretString) ExposeSecret() string { return s.value }

// ExposeBytes returns the raw secret as bytes — same deliberate
// awkwardness as ExposeSecret.
func (s SecretString) ExposeBytes() []byte { return []byte(s.value) }

// Equal reports whether two secrets match, in constant time.
func (s SecretString) Equal(other SecretString) bool {
	return subtle.ConstantTimeCompare([]byte(s.value), []byte(other.value)) == 1
}

func (s SecretString) String() string { return redacted }

func (s SecretString) GoString() string { return redacted }

// Format redacts under every verb (%v, %s, %q, %#v, …).
func (s SecretString) Format(f fmt.State, verb rune) {
	_, _ = f.Write([]byte(redacted))
}

func (s SecretString) MarshalJSON() ([]byte, error) {
	return []byte(strconv.Quote(redacted)), nil
}

func (s SecretString) MarshalText() ([]byte, error) { return []byte(redacted), nil }

func (s SecretString) MarshalBinary() ([]byte, error) { return []byte(redacted), nil }

func (s SecretString) MarshalYAML() (any, error) { return redacted, nil }
