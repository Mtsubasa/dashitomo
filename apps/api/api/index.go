// Package handler は Vercel Go Runtime のエントリポイント。
// 常駐サーバ（cmd/api）ではなく、リクエストごとに呼ばれる関数として
// 既存の httpapi.NewHandler を再利用する。
package handler

import (
	"log/slog"
	"net/http"
	"os"
	"sync"

	"github.com/Mtsubasa/dashitomo/apps/api/internal/config"
	"github.com/Mtsubasa/dashitomo/apps/api/internal/httpapi"
)

var (
	once    sync.Once
	handler http.Handler
	initErr error
)

// Handler は Vercel Functions から呼び出される。
func Handler(w http.ResponseWriter, r *http.Request) {
	// サーバレスでは panic をランタイム層に伝播させず、ログに残して500を返す。
	defer func() {
		if rec := recover(); rec != nil {
			slog.Error("API handler panicked", "panic", rec)
			http.Error(w, "internal server error", http.StatusInternalServerError)
		}
	}()

	once.Do(func() {
		cfg, err := config.Load()
		if err != nil {
			initErr = err
			return
		}
		logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
			Level: cfg.LogLevel,
		}))
		handler = httpapi.NewHandler(logger, cfg.CORSAllowedOrigins)
	})

	if initErr != nil {
		slog.Error("failed to initialize API handler", "error", initErr)
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}

	handler.ServeHTTP(w, r)
}
