package config

import (
	"log/slog"
	"reflect"
	"testing"
)

func TestLoadDefaults(t *testing.T) {
	t.Setenv("PORT", "")
	t.Setenv("LOG_LEVEL", "")
	t.Setenv("CORS_ALLOWED_ORIGINS", "")

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() returned an error: %v", err)
	}

	if cfg.Port != 8080 {
		t.Errorf("Port = %d, want 8080", cfg.Port)
	}
	if cfg.Address() != ":8080" {
		t.Errorf("Address() = %q, want %q", cfg.Address(), ":8080")
	}
	if cfg.LogLevel != slog.LevelDebug {
		t.Errorf("LogLevel = %s, want %s", cfg.LogLevel, slog.LevelDebug)
	}
	wantOrigins := []string{"http://localhost:3000"}
	if !reflect.DeepEqual(cfg.CORSAllowedOrigins, wantOrigins) {
		t.Errorf("CORSAllowedOrigins = %v, want %v", cfg.CORSAllowedOrigins, wantOrigins)
	}
}

func TestLoadConfiguredValues(t *testing.T) {
	t.Setenv("PORT", "9090")
	t.Setenv("LOG_LEVEL", "INFO")
	t.Setenv(
		"CORS_ALLOWED_ORIGINS",
		"https://app.example.test/, http://localhost:3000, https://app.example.test",
	)

	cfg, err := Load()
	if err != nil {
		t.Fatalf("Load() returned an error: %v", err)
	}

	if cfg.Port != 9090 {
		t.Errorf("Port = %d, want 9090", cfg.Port)
	}
	if cfg.LogLevel != slog.LevelInfo {
		t.Errorf("LogLevel = %s, want %s", cfg.LogLevel, slog.LevelInfo)
	}
	wantOrigins := []string{"https://app.example.test", "http://localhost:3000"}
	if !reflect.DeepEqual(cfg.CORSAllowedOrigins, wantOrigins) {
		t.Errorf("CORSAllowedOrigins = %v, want %v", cfg.CORSAllowedOrigins, wantOrigins)
	}
}

func TestLoadRejectsInvalidPort(t *testing.T) {
	for _, value := range []string{"abc", "0", "65536"} {
		t.Run(value, func(t *testing.T) {
			t.Setenv("PORT", value)
			if _, err := Load(); err == nil {
				t.Fatalf("Load() succeeded with PORT=%q", value)
			}
		})
	}
}

func TestLoadRejectsInvalidLogLevel(t *testing.T) {
	t.Setenv("LOG_LEVEL", "trace")
	if _, err := Load(); err == nil {
		t.Fatal("Load() succeeded with an unsupported LOG_LEVEL")
	}
}

func TestLoadRejectsInvalidOrigins(t *testing.T) {
	for _, value := range []string{
		"*",
		"localhost:3000",
		"https://example.test/path",
		"ftp://example.test",
	} {
		t.Run(value, func(t *testing.T) {
			t.Setenv("CORS_ALLOWED_ORIGINS", value)
			if _, err := Load(); err == nil {
				t.Fatalf("Load() succeeded with CORS_ALLOWED_ORIGINS=%q", value)
			}
		})
	}
}
