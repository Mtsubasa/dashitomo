package httpapi

import (
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

const allowedOrigin = "http://localhost:3000"

func TestHealth(t *testing.T) {
	recorder := request(t, http.MethodGet, "/healthz", "")

	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", recorder.Code, http.StatusOK)
	}
	if got := recorder.Header().Get("Content-Type"); got != "application/json; charset=utf-8" {
		t.Errorf("Content-Type = %q, want application/json; charset=utf-8", got)
	}
	if got := recorder.Header().Get("Allow"); got != "" {
		t.Errorf("Allow = %q, want empty", got)
	}

	var response healthResponse
	if err := json.NewDecoder(recorder.Body).Decode(&response); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	if response.Status != "ok" {
		t.Errorf("status body = %q, want ok", response.Status)
	}
}

func TestUnknownPath(t *testing.T) {
	recorder := request(t, http.MethodGet, "/unknown", "")
	if recorder.Code != http.StatusNotFound {
		t.Errorf("status = %d, want %d", recorder.Code, http.StatusNotFound)
	}
}

func TestMethodNotAllowed(t *testing.T) {
	recorder := request(t, http.MethodPost, "/healthz", "")
	if recorder.Code != http.StatusMethodNotAllowed {
		t.Errorf("status = %d, want %d", recorder.Code, http.StatusMethodNotAllowed)
	}
	if got := recorder.Header().Get("Allow"); got != "GET, OPTIONS" {
		t.Errorf("Allow = %q, want GET, OPTIONS", got)
	}
}

func TestPreflight(t *testing.T) {
	recorder := request(t, http.MethodOptions, "/healthz", allowedOrigin)

	if recorder.Code != http.StatusNoContent {
		t.Errorf("status = %d, want %d", recorder.Code, http.StatusNoContent)
	}
	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != allowedOrigin {
		t.Errorf("Access-Control-Allow-Origin = %q, want %q", got, allowedOrigin)
	}
	if got := recorder.Header().Get("Access-Control-Allow-Methods"); got != "GET, OPTIONS" {
		t.Errorf("Access-Control-Allow-Methods = %q, want GET, OPTIONS", got)
	}
	if got := recorder.Header().Get("Allow"); got != "GET, OPTIONS" {
		t.Errorf("Allow = %q, want GET, OPTIONS", got)
	}
}

func TestAllowedOrigin(t *testing.T) {
	recorder := request(t, http.MethodGet, "/healthz", allowedOrigin)

	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != allowedOrigin {
		t.Errorf("Access-Control-Allow-Origin = %q, want %q", got, allowedOrigin)
	}
	if !strings.Contains(recorder.Header().Get("Vary"), "Origin") {
		t.Errorf("Vary = %q, want it to contain Origin", recorder.Header().Get("Vary"))
	}
}

func TestDisallowedOrigin(t *testing.T) {
	recorder := request(t, http.MethodGet, "/healthz", "https://evil.example")

	if got := recorder.Header().Get("Access-Control-Allow-Origin"); got != "" {
		t.Errorf("Access-Control-Allow-Origin = %q, want empty", got)
	}
	if !strings.Contains(recorder.Header().Get("Vary"), "Origin") {
		t.Errorf("Vary = %q, want it to contain Origin", recorder.Header().Get("Vary"))
	}
}

func request(t *testing.T, method, path, origin string) *httptest.ResponseRecorder {
	t.Helper()
	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	handler := NewHandler(logger, []string{allowedOrigin})
	req := httptest.NewRequest(method, path, nil)
	if origin != "" {
		req.Header.Set("Origin", origin)
	}
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, req)
	return recorder
}
