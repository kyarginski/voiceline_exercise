package main

import (
	"fmt"
	"log/slog"
	"os"

	"voiceline/internal/app"
	"voiceline/internal/config"
	"voiceline/internal/lib/logger/sl"

	_ "github.com/lib/pq"
)

func main() {
	cfg := config.MustLoad()
	log := sl.SetupLogger(cfg.Env)
	log.Info(
		"starting server users",
		slog.String("env", cfg.Env),
		slog.String("version", cfg.Version),
		slog.Bool("use_tracing", cfg.UseTracing),
		slog.String("tracing_address", cfg.TracingAddress),
	)

	if err := run(log, cfg); err != nil {
		fmt.Fprintf(os.Stderr, "error: %s\n", err)
		os.Exit(2)
	}
}

func run(log *slog.Logger, cfg *config.Config) error {
	log.Debug("starting db connect ", "connect", cfg.DBConnect)

	application, err := app.NewService(log, cfg.DBConnect, cfg.Port, cfg.UseTracing, cfg.TracingAddress, &cfg.Keycloak, "users")
	defer application.Stop()
	if err != nil {
		return err
	}

	application.Start()

	return nil
}
