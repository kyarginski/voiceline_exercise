package api

import (
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"

	"voiceline/internal/config"
	"voiceline/internal/lib/token"

	"golang.org/x/crypto/bcrypt"

	"voiceline/api/restapi"
	"voiceline/internal/app/services"
)

// LoginRequest represents a request to authenticate a user.
type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type RestApiServer struct {
	service services.IService
	log     *slog.Logger

	KeycloakBaseURL string
	Realm           string
	ClientID        string
	ClientSecret    string

	keycloakClient token.IKeycloakClient
}

func (s RestApiServer) Login(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	var loginReq LoginRequest
	err = json.Unmarshal(body, &loginReq)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	if loginReq.Username == "" || loginReq.Password == "" {
		http.Error(w, "Username and password are required", http.StatusBadRequest)

		return
	}

	// Get token from Keycloak
	tokenResp, err := token.GetTokenFromKeycloak(s.KeycloakBaseURL, s.Realm, s.ClientID, s.ClientSecret, loginReq.Username, loginReq.Password)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to authenticate: %s", err.Error()), http.StatusUnauthorized)

		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(tokenResp)
}

func (s RestApiServer) Logout(w http.ResponseWriter, r *http.Request) {
	// TODO implement me
	panic("implement me")
}

func (s RestApiServer) RefreshToken(w http.ResponseWriter, r *http.Request) {
	// TODO implement me
	panic("implement me")
}

func NewRestApiServer(service services.IService, log *slog.Logger, keycloakConfig *config.KeycloakConfig, keycloakClient token.IKeycloakClient) RestApiServer {
	return RestApiServer{
		service: service,
		log:     log,

		KeycloakBaseURL: keycloakConfig.Server,
		Realm:           keycloakConfig.Realm,
		ClientID:        keycloakConfig.ClientID,
		ClientSecret:    keycloakConfig.ClientSecret,

		keycloakClient: keycloakClient,
	}
}

func (s RestApiServer) ListUsers(w http.ResponseWriter, r *http.Request, params restapi.ListUsersParams) {
	s.log.Debug("RestApiServer.ListUsers")

	tokenStr, err := token.ExtractToken(r)
	if err != nil {
		s.log.Error("Failed to extract token", "error", err)
		http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)

		return
	}

	valid, err := s.keycloakClient.ValidateToken(tokenStr)
	if err != nil || !valid {
		s.log.Error("Invalid token", "error", err.Error())
		http.Error(w, "Unauthorized: Invalid token", http.StatusUnauthorized)

		return
	}

	page := 1
	limit := 10

	if params.Page != nil && *params.Page > 0 {
		page = *params.Page
	}

	if params.Limit != nil && *params.Limit > 0 {
		limit = *params.Limit
	}

	users, err := s.service.ListUsers(r.Context(), page, limit)
	if err != nil {
		s.log.Error("Failed to get users", "error", err)
		http.Error(w, "Failed to get users", http.StatusInternalServerError)
		return
	}

	var resp []restapi.User
	for _, u := range users {
		resp = append(
			resp, restapi.User{
				Id:        u.Id,
				FirstName: u.FirstName,
				LastName:  u.LastName,
				Email:     u.Email,
				IsActive:  u.IsActive,
			},
		)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		s.log.Error("Failed to encode response", "error", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

func (s RestApiServer) CreateUser(w http.ResponseWriter, r *http.Request) {
	s.log.Debug("RestApiServer.CreateUser")

	tokenStr, err := token.ExtractToken(r)
	if err != nil {
		s.log.Error("Failed to extract token", "error", err)
		http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)

		return
	}

	valid, err := s.keycloakClient.ValidateToken(tokenStr)
	if err != nil || !valid {
		s.log.Error("Invalid token", "error", err.Error())
		http.Error(w, "Unauthorized: Invalid token", http.StatusUnauthorized)

		return
	}

	var newUser restapi.User
	err = json.NewDecoder(r.Body).Decode(&newUser)
	if err != nil {
		s.log.Error("Invalid request payload", "error", err)
		http.Error(w, "Invalid request payload", http.StatusBadRequest)

		return
	}

	if newUser.Email == nil || newUser.FirstName == nil || newUser.LastName == nil || newUser.Password == nil {
		s.log.Error("Missing required fields", "error", err)
		http.Error(w, "Missing required fields", http.StatusBadRequest)

		return
	}

	now := time.Now()
	newUser.CreatedAt = &now
	newUser.UpdatedAt = &now
	isActive := true
	newUser.IsActive = &isActive

	hashedPassword, err := HashPassword(*newUser.Password)
	if err != nil {
		s.log.Error("Failed to hash password", "error", err)
		http.Error(w, "Failed to hash password", http.StatusInternalServerError)

		return
	}
	newUser.Password = &hashedPassword

	err = s.service.AddUser(r.Context(), &newUser)
	if err != nil {
		s.log.Error("Failed to create user", "error", err)
		http.Error(w, "Failed to create user", http.StatusInternalServerError)

		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)

	err = json.NewEncoder(w).Encode(newUser)
	if err != nil {
		s.log.Error("Failed to encode response", "error", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func (s RestApiServer) DeleteUser(w http.ResponseWriter, r *http.Request, id int) {
	s.log.Debug("RestApiServer.DeleteUser")

	tokenStr, err := token.ExtractToken(r)
	if err != nil {
		s.log.Error("Failed to extract token", "error", err)
		http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)

		return
	}

	valid, err := s.keycloakClient.ValidateToken(tokenStr)
	if err != nil || !valid {
		s.log.Error("Invalid token", "error", err.Error())
		http.Error(w, "Unauthorized: Invalid token", http.StatusUnauthorized)

		return
	}

	err = s.service.DeleteUser(r.Context(), id)
	if err != nil {
		s.log.Error("User not found", "error", err)
		http.Error(w, "User not found", http.StatusNotFound)

		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func (s RestApiServer) GetUserById(w http.ResponseWriter, r *http.Request, id int) {
	s.log.Debug("RestApiServer.GetUserById")

	tokenStr, err := token.ExtractToken(r)
	if err != nil {
		s.log.Error("Failed to extract token", "error", err)
		http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)

		return
	}

	valid, err := s.keycloakClient.ValidateToken(tokenStr)
	if err != nil || !valid {
		s.log.Error("Invalid token", "error", err.Error())
		http.Error(w, "Unauthorized: Invalid token", http.StatusUnauthorized)

		return
	}

	user, err := s.service.GetUserById(r.Context(), id)
	if err != nil {
		s.log.Error("User not found", "error", err)
		http.Error(w, "User not found", http.StatusNotFound)

		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	err = json.NewEncoder(w).Encode(user)
	if err != nil {
		s.log.Error("Failed to encode response", "error", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

func (s RestApiServer) UpdateUser(w http.ResponseWriter, r *http.Request, id int) {
	s.log.Debug("RestApiServer.UpdateUser")

	tokenStr, err := token.ExtractToken(r)
	if err != nil {
		s.log.Error("Failed to extract token", "error", err)
		http.Error(w, "Unauthorized: No token provided", http.StatusUnauthorized)

		return
	}

	valid, err := s.keycloakClient.ValidateToken(tokenStr)
	if err != nil || !valid {
		s.log.Error("Invalid token", "error", err.Error())
		http.Error(w, "Unauthorized: Invalid token", http.StatusUnauthorized)

		return
	}

	var updatedUser restapi.User
	err = json.NewDecoder(r.Body).Decode(&updatedUser)
	if err != nil {
		s.log.Error("Invalid request payload", "error", err)
		http.Error(w, "Invalid request payload", http.StatusBadRequest)

		return
	}

	existingUser, err := s.service.GetUserById(r.Context(), id)
	if err != nil {
		s.log.Error("User not found", "error", err)
		http.Error(w, "User not found", http.StatusNotFound)

		return
	}

	if updatedUser.FirstName != nil {
		existingUser.FirstName = updatedUser.FirstName
	}
	if updatedUser.LastName != nil {
		existingUser.LastName = updatedUser.LastName
	}
	if updatedUser.Email != nil {
		existingUser.Email = updatedUser.Email
	}
	if updatedUser.IsActive != nil {
		existingUser.IsActive = updatedUser.IsActive
	}

	if updatedUser.Password != nil {
		hashedPassword, err := HashPassword(*updatedUser.Password)
		if err != nil {
			s.log.Error("Failed to hash password", "error", err)
			http.Error(w, "Failed to hash password", http.StatusInternalServerError)

			return
		}
		existingUser.Password = &hashedPassword
	}

	now := time.Now()
	existingUser.UpdatedAt = &now

	err = s.service.UpdateUser(r.Context(), id, existingUser)
	if err != nil {
		s.log.Error("Failed to update user", "error", err)
		http.Error(w, "Failed to update user", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	err = json.NewEncoder(w).Encode(existingUser)
	if err != nil {
		s.log.Error("Failed to encode response", "error", err)
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
	}
}

func HashPassword(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	return string(hash), nil
}
