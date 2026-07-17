package config

import (
	"fmt"
	"log/slog"
	"net/url"
	"os"
	"strconv"
	"strings"
)

const (
	defaultPort               = 8080
	defaultLogLevel           = "debug"
	defaultCORSAllowedOrigins = "http://localhost:3000"
)

type Config struct {
	Port               int
	LogLevel           slog.Level
	CORSAllowedOrigins []string
}

func Load() (Config, error) {
	port, err := parsePort(envOrDefault("PORT", strconv.Itoa(defaultPort)))
	if err != nil {
		return Config{}, err
	}

	logLevel, err := parseLogLevel(envOrDefault("LOG_LEVEL", defaultLogLevel))
	if err != nil {
		return Config{}, err
	}

	origins, err := parseOrigins(envOrDefault("CORS_ALLOWED_ORIGINS", defaultCORSAllowedOrigins))
	if err != nil {
		return Config{}, err
	}

	return Config{
		Port:               port,
		LogLevel:           logLevel,
		CORSAllowedOrigins: origins,
	}, nil
}

func (c Config) Address() string {
	return fmt.Sprintf(":%d", c.Port)
}

func envOrDefault(key, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func parsePort(value string) (int, error) {
	port, err := strconv.Atoi(value)
	if err != nil || port < 1 || port > 65535 {
		return 0, fmt.Errorf("PORT must be an integer between 1 and 65535")
	}
	return port, nil
}

func parseLogLevel(value string) (slog.Level, error) {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "debug":
		return slog.LevelDebug, nil
	case "info":
		return slog.LevelInfo, nil
	case "warn":
		return slog.LevelWarn, nil
	case "error":
		return slog.LevelError, nil
	default:
		return 0, fmt.Errorf("LOG_LEVEL must be one of debug, info, warn, or error")
	}
}

func parseOrigins(value string) ([]string, error) {
	seen := make(map[string]struct{})
	origins := make([]string, 0)
	for part := range strings.SplitSeq(value, ",") {
		origin := strings.TrimSpace(part)
		if origin == "" {
			continue
		}
		if origin == "*" {
			return nil, fmt.Errorf("CORS_ALLOWED_ORIGINS must not contain a wildcard")
		}

		parsed, err := url.Parse(origin)
		if err != nil ||
			(parsed.Scheme != "http" && parsed.Scheme != "https") ||
			parsed.Host == "" ||
			(parsed.Path != "" && parsed.Path != "/") ||
			parsed.RawQuery != "" ||
			parsed.Fragment != "" ||
			parsed.User != nil {
			return nil, fmt.Errorf("invalid CORS origin %q", origin)
		}

		normalized := parsed.Scheme + "://" + parsed.Host
		if _, exists := seen[normalized]; exists {
			continue
		}
		seen[normalized] = struct{}{}
		origins = append(origins, normalized)
	}

	if len(origins) == 0 {
		return nil, fmt.Errorf("CORS_ALLOWED_ORIGINS must contain at least one origin")
	}
	return origins, nil
}
