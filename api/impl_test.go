package api

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"voiceline/internal/config"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	"voiceline/internal/mocks"

	"voiceline/api/restapi"
	"voiceline/internal/lib/logger/sl"
)

func TestCreateUser(t *testing.T) {
	mockService := new(mocks.IService)
	logger := sl.SetupLogger("nop")

	keycloakConfig := &config.KeycloakConfig{}

	mockKeycloakClient := &mocks.MockKeycloakClient{
		ValidateTokenFunc: func(token string) (bool, error) {
			if token == "valid-token" {
				return true, nil
			}
			return false, nil
		},
	}

	server := NewRestApiServer(mockService, logger, keycloakConfig, mockKeycloakClient)

	user := restapi.User{
		Email:     strPtr("test@example.com"),
		FirstName: strPtr("John"),
		LastName:  strPtr("Doe"),
		Password:  strPtr("password"),
	}

	jsonUser, _ := json.Marshal(user)
	req, err := http.NewRequest(http.MethodPost, "/users", bytes.NewBuffer(jsonUser))
	assert.NoError(t, err)

	req.Header.Set("Authorization", "Bearer valid-token")

	rr := httptest.NewRecorder()

	mockService.On("AddUser", mock.Anything, mock.Anything).Return(nil)

	server.CreateUser(rr, req)

	assert.Equal(t, http.StatusCreated, rr.Code)

	var respUser restapi.User
	err = json.NewDecoder(rr.Body).Decode(&respUser)
	assert.NoError(t, err)
	assert.Equal(t, "test@example.com", *respUser.Email)
	assert.NotNil(t, respUser.CreatedAt)
	assert.NotNil(t, respUser.UpdatedAt)
}

func TestGetUserById(t *testing.T) {
	mockService := new(mocks.IService)
	logger := sl.SetupLogger("nop")

	keycloakConfig := &config.KeycloakConfig{}

	mockKeycloakClient := &mocks.MockKeycloakClient{
		ValidateTokenFunc: func(token string) (bool, error) {
			if token == "valid-token" {
				return true, nil
			}
			return false, nil
		},
	}

	server := NewRestApiServer(mockService, logger, keycloakConfig, mockKeycloakClient)

	user := &restapi.User{
		Id:        intPtr(1),
		Email:     strPtr("test@example.com"),
		FirstName: strPtr("John"),
		LastName:  strPtr("Doe"),
	}

	req, err := http.NewRequest(http.MethodGet, "/users/1", nil)
	assert.NoError(t, err)

	req.Header.Set("Authorization", "Bearer valid-token")

	rr := httptest.NewRecorder()

	mockService.On("GetUserById", mock.Anything, 1).Return(user, nil)

	server.GetUserById(rr, req, 1)

	assert.Equal(t, http.StatusOK, rr.Code)

	var respUser restapi.User
	err = json.NewDecoder(rr.Body).Decode(&respUser)
	assert.NoError(t, err)
	assert.Equal(t, 1, *respUser.Id)
	assert.Equal(t, "test@example.com", *respUser.Email)
}

func TestDeleteUser(t *testing.T) {
	mockService := new(mocks.IService)
	logger := sl.SetupLogger("nop")

	keycloakConfig := &config.KeycloakConfig{}

	mockKeycloakClient := &mocks.MockKeycloakClient{
		ValidateTokenFunc: func(token string) (bool, error) {
			if token == "valid-token" {
				return true, nil
			}
			return false, nil
		},
	}

	server := NewRestApiServer(mockService, logger, keycloakConfig, mockKeycloakClient)

	req, err := http.NewRequest(http.MethodDelete, "/users/1", nil)
	assert.NoError(t, err)

	req.Header.Set("Authorization", "Bearer valid-token")

	rr := httptest.NewRecorder()

	mockService.On("DeleteUser", mock.Anything, 1).Return(nil)

	server.DeleteUser(rr, req, 1)

	assert.Equal(t, http.StatusNoContent, rr.Code)
}

func TestUpdateUser(t *testing.T) {
	mockService := new(mocks.IService)
	logger := sl.SetupLogger("nop")

	keycloakConfig := &config.KeycloakConfig{}

	mockKeycloakClient := &mocks.MockKeycloakClient{
		ValidateTokenFunc: func(token string) (bool, error) {
			if token == "valid-token" {
				return true, nil
			}
			return false, nil
		},
	}

	server := NewRestApiServer(mockService, logger, keycloakConfig, mockKeycloakClient)

	existingUser := &restapi.User{
		Id:        intPtr(1),
		Email:     strPtr("test@example.com"),
		FirstName: strPtr("John"),
		LastName:  strPtr("Doe"),
	}

	updatedUser := restapi.User{
		Email:     strPtr("new@example.com"),
		FirstName: strPtr("Jane"),
	}

	jsonUpdatedUser, _ := json.Marshal(updatedUser)
	req, err := http.NewRequest(http.MethodPut, "/users/1", bytes.NewBuffer(jsonUpdatedUser))
	assert.NoError(t, err)

	req.Header.Set("Authorization", "Bearer valid-token")

	rr := httptest.NewRecorder()

	mockService.On("GetUserById", mock.Anything, 1).Return(existingUser, nil)
	mockService.On("UpdateUser", mock.Anything, 1, mock.Anything).Return(nil)

	server.UpdateUser(rr, req, 1)

	assert.Equal(t, http.StatusOK, rr.Code)

	var respUser restapi.User
	err = json.NewDecoder(rr.Body).Decode(&respUser)
	assert.NoError(t, err)
	assert.Equal(t, "new@example.com", *respUser.Email)
	assert.Equal(t, "Jane", *respUser.FirstName)
}

func strPtr(s string) *string {
	return &s
}

func intPtr(i int) *int {
	return &i
}
