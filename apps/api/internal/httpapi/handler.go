package httpapi

import (
	"encoding/json"
	"log/slog"
	"net/http"
)

type healthResponse struct {
	Status string `json:"status"`
}

func NewHandler(logger *slog.Logger, allowedOrigins []string) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", healthHandler(logger))
	return corsMiddleware(allowedOrigins, mux)
}

func healthHandler(logger *slog.Logger) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			w.Header().Set("Content-Type", "application/json; charset=utf-8")
			if err := json.NewEncoder(w).Encode(healthResponse{Status: "ok"}); err != nil {
				logger.Error("failed to write health response", "error", err)
			}
		case http.MethodOptions:
			w.Header().Set("Allow", "GET, OPTIONS")
			w.WriteHeader(http.StatusNoContent)
		default:
			w.Header().Set("Allow", "GET, OPTIONS")
			http.Error(w, http.StatusText(http.StatusMethodNotAllowed), http.StatusMethodNotAllowed)
		}
	}
}
