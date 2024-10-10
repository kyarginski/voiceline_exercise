package app

import (
	"context"
	"fmt"
	"log/slog"

	"voiceline/api"
	"voiceline/api/restapi"
	"voiceline/internal/app/handler"
	"voiceline/internal/app/health"
	"voiceline/internal/app/services"
	"voiceline/internal/app/web"
	"voiceline/internal/config"
	"voiceline/internal/lib/middleware"
	"voiceline/internal/lib/token"

	"github.com/gorilla/mux"
)

type App struct {
	HTTPServer *web.HTTPServer
	service    services.IService

	health.LivenessChecker
	health.ReadinessChecker
}

// NewService creates a new instance of the service.
func NewService(
	log *slog.Logger,
	connectString string,
	port int,
	useTracing bool,
	tracingAddress string,
	keycloakConfig *config.KeycloakConfig,
	serviceName string,
) (*App, error) {
	const op = "app.NewService"
	ctx := context.Background()

	app := &App{}
	srv, err := services.NewService(log, connectString)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", op, err)
	}

	telemetryMiddleware, err := addTelemetryMiddleware(ctx, useTracing, tracingAddress, serviceName)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", op, err)
	}

	restApiServer := api.NewRestApiServer(srv, log, keycloakConfig, &token.RealKeycloakClient{})

	router := mux.NewRouter()
	router.Use(middleware.RequestID)
	router.Use(telemetryMiddleware)

	// system endpoints
	router.HandleFunc("/live", health.LivenessHandler(app)).Methods("GET")
	router.HandleFunc("/ready", health.ReadinessHandler(app)).Methods("GET")

	// users endpoints
	baseURL := "/api/v1"
	h := restapi.HandlerFromMuxWithBaseURL(restApiServer, router, baseURL)

	server, err := web.New(log, port, h)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", op, err)
	}

	app.HTTPServer = server
	app.service = srv

	return app, nil
}

// Start starts the application.
func (a *App) Start() {
	a.HTTPServer.Start()
}

// Stop stops the application.
func (a *App) Stop() {
	if a != nil && a.service != nil {
		err := a.service.Close()
		if err != nil {
			fmt.Println("An error occurred closing service" + err.Error())

			return
		}
	}
}

func addTelemetryMiddleware(
	ctx context.Context, useTracing bool, tracingAddress string, serviceName string,
) (mux.MiddlewareFunc, error) {
	var telemetryMiddleware mux.MiddlewareFunc
	var err error
	if useTracing {
		telemetryMiddleware, err = handler.AddTelemetryMiddleware(ctx, tracingAddress, serviceName)
		if err != nil {
			return nil, err
		}
	}

	return telemetryMiddleware, nil
}

func (a *App) LivenessCheck() bool {
	return a.service.LivenessCheck()
}

func (a *App) ReadinessCheck() bool {
	return a.service.ReadinessCheck()
}
