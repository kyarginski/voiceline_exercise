package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	models "voiceline/api/restapi"

	trccontext "voiceline/internal/lib/context"
)

type Storage struct {
	db *sql.DB
}

func (s *Storage) Close() error {
	return s.db.Close()
}

func setDB(path string) (*sql.DB, error) {
	db, err := sql.Open("postgres", path)
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func (s *Storage) GetDB() *sql.DB {
	return s.db
}

func New(path string) (*Storage, error) {
	const op = "repository.New"

	db, err := setDB(path)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", op, err)
	}

	return &Storage{db: db}, nil
}

// AddUser creates a new user in the database.
func (s *Storage) AddUser(ctx context.Context, source *models.User) error {
	query := `
		INSERT INTO users (email, first_name, last_name, password, is_active, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id;
	`

	ctx, span := trccontext.WithTelemetrySpan(ctx, "Storage.AddUser")
	defer span.End()

	createdAt := time.Now()
	updatedAt := time.Now()

	err := s.db.QueryRowContext(
		ctx, query,
		source.Email,
		source.FirstName,
		source.LastName,
		source.Password,
		source.IsActive,
		createdAt,
		updatedAt,
	).Scan(&source.Id)

	if err != nil {
		span.SetError(err)

		return err
	}

	return nil
}

// GetUserById retrieves user details by ID.
func (s *Storage) GetUserById(ctx context.Context, id int) (*models.User, error) {
	query := `
		SELECT id, email, first_name, last_name, is_active, created_at, updated_at
		FROM users
		WHERE id = $1;
	`

	var user models.User

	err := s.db.QueryRowContext(ctx, query, id).Scan(
		&user.Id,
		&user.Email,
		&user.FirstName,
		&user.LastName,
		&user.IsActive,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if errors.Is(err, sql.ErrNoRows) {
		return nil, fmt.Errorf("user with ID %d not found", id)
	}

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// UpdateUser updates user information by ID.
func (s *Storage) UpdateUser(ctx context.Context, id int, source *models.User) error {
	query := `
		UPDATE users
		SET email = $1, first_name = $2, last_name = $3, password = $4, is_active = $5, updated_at = $6
		WHERE id = $7;
	`

	updatedAt := time.Now()

	_, err := s.db.ExecContext(
		ctx, query,
		source.Email,
		source.FirstName,
		source.LastName,
		source.Password,
		source.IsActive,
		updatedAt,
		id,
	)

	if err != nil {
		return err
	}

	source.UpdatedAt = &updatedAt
	return nil
}

// DeleteUser deletes a user by ID.
func (s *Storage) DeleteUser(ctx context.Context, id int) error {
	query := `
		DELETE FROM users
		WHERE id = $1;
	`

	_, err := s.db.ExecContext(ctx, query, id)
	if err != nil {
		return err
	}

	return nil
}

// ListUsers retrieves a paginated list of users.
func (s *Storage) ListUsers(ctx context.Context, page, limit int) ([]*models.User, error) {
	query := `
		SELECT id, email, first_name, last_name, is_active, created_at, updated_at
		FROM users
		ORDER BY id
		LIMIT $1 OFFSET $2;
	`

	offset := (page - 1) * limit

	rows, err := s.db.QueryContext(ctx, query, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*models.User

	for rows.Next() {
		var user models.User
		if err := rows.Scan(
			&user.Id,
			&user.Email,
			&user.FirstName,
			&user.LastName,
			&user.IsActive,
			&user.CreatedAt,
			&user.UpdatedAt,
		); err != nil {
			return nil, err
		}

		users = append(users, &user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
