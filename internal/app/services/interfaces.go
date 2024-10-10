package services

import (
	"context"
	"log/slog"

	"voiceline/internal/app/health"
	"voiceline/internal/app/repository"
)

type IService interface {
	Logger() *slog.Logger
	Ping(ctx context.Context) bool
	Close() error

	repository.IUserRepository

	health.LivenessChecker
	health.ReadinessChecker
}
