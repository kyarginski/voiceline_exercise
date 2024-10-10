package services

import (
	"context"
	"fmt"
	"log/slog"

	"voiceline/api/restapi"
	"voiceline/internal/app/repository"
)

type MyService struct {
	log     *slog.Logger
	storage *repository.Storage
}

func (s *MyService) AddUser(ctx context.Context, user *restapi.User) error {
	return s.storage.AddUser(ctx, user)
}

func (s *MyService) GetUserById(ctx context.Context, id int) (*restapi.User, error) {
	return s.storage.GetUserById(ctx, id)
}

func (s *MyService) UpdateUser(ctx context.Context, id int, user *restapi.User) error {
	return s.storage.UpdateUser(ctx, id, user)
}

func (s *MyService) DeleteUser(ctx context.Context, id int) error {
	return s.storage.DeleteUser(ctx, id)
}

func (s *MyService) ListUsers(ctx context.Context, page, limit int) ([]*restapi.User, error) {
	return s.storage.ListUsers(ctx, page, limit)
}

func NewService(log *slog.Logger, connectString string) (IService, error) {
	const op = "service.NewService"

	storage, err := repository.New(connectString)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", op, err)
	}

	return &MyService{
		log:     log,
		storage: storage,
	}, nil
}

// Close closes DB connection.
func (s *MyService) Close() error {
	return s.storage.Close()
}

func (s *MyService) LivenessCheck() bool {
	// Implement liveness check logic
	return true
}

func (s *MyService) ReadinessCheck() bool {
	// Implement readiness check logic
	return s.Ping(context.Background())
}

func (s *MyService) Ping(ctx context.Context) bool {
	return s.storage.GetDB().PingContext(ctx) == nil
}

func (s *MyService) Logger() *slog.Logger {
	return s.log
}
