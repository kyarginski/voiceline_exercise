package repository

import (
	"context"

	models "voiceline/api/restapi"
)

// IUserRepository defines an interface for managing users in the storage.
type IUserRepository interface {
	// AddUser creates a new user in the storage.
	AddUser(ctx context.Context, user *models.User) error

	// GetUserById retrieves a user by their ID.
	GetUserById(ctx context.Context, id int) (*models.User, error)

	// UpdateUser updates user information by their ID.
	UpdateUser(ctx context.Context, id int, user *models.User) error

	// DeleteUser deletes a user by their ID.
	DeleteUser(ctx context.Context, id int) error

	// ListUsers retrieves a paginated list of users.
	ListUsers(ctx context.Context, page, limit int) ([]*models.User, error)
}
