package services

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"

	_ "github.com/lib/pq"

	models "voiceline/api/restapi"
	"voiceline/internal/lib/logger/sl"
	"voiceline/internal/testhelpers/postgres"
)

func TestMyService_All(t *testing.T) {
	log := sl.SetupLogger("nop")
	testDB, err := postgres.NewTestDatabase(t)
	assert.NoError(t, err)
	assert.NotNil(t, testDB)
	defer testDB.Close(t)

	err = testDB.DB().Ping()
	assert.NoError(t, err)

	srv, err := NewService(log, testDB.ConnectString(t))
	assert.NoError(t, err)
	assert.NotNil(t, srv)

	t.Run(
		"AddUser", func(t *testing.T) {
			user := &models.User{
				FirstName: strPtr("John"),
				LastName:  strPtr("Doe"),
				Email:     strPtr("john.doe@example.com"),
				Password:  strPtr("password123"),
			}

			err := srv.AddUser(context.Background(), user)
			assert.NoError(t, err)
			assert.NotNil(t, user.Id)
		},
	)

	t.Run(
		"GetUserById", func(t *testing.T) {
			user, err := srv.GetUserById(context.Background(), 1)
			assert.NoError(t, err)
			assert.NotNil(t, user)
			assert.Equal(t, "john.doe@example.com", *user.Email)
		},
	)

	t.Run(
		"UpdateUser", func(t *testing.T) {
			updatedUser := &models.User{
				FirstName: strPtr("Jane"),
				LastName:  strPtr("Smith"),
				Email:     strPtr("jane.smith@example.com"),
				Password:  strPtr("password456"),
			}

			err := srv.UpdateUser(context.Background(), 1, updatedUser) // ID обновляемого пользователя
			assert.NoError(t, err)

			user, err := srv.GetUserById(context.Background(), 1)
			assert.NoError(t, err)
			assert.Equal(t, "jane.smith@example.com", *user.Email)
			assert.Equal(t, "Jane", *user.FirstName)
		},
	)

	t.Run(
		"ListUsers", func(t *testing.T) {
			users, err := srv.ListUsers(context.Background(), 1, 10)
			assert.NoError(t, err)
			assert.NotNil(t, users)

			assert.Greater(t, len(users), 0)
		},
	)

	t.Run(
		"DeleteUser", func(t *testing.T) {
			err := srv.DeleteUser(context.Background(), 1)
			assert.NoError(t, err)

			user, err := srv.GetUserById(context.Background(), 1)
			assert.Error(t, err)
			assert.Nil(t, user)
		},
	)

}

func strPtr(s string) *string {
	return &s
}
