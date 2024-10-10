package token

import (
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"strings"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/go-resty/resty/v2"
)

type Response struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"`
}

var PublicKey *rsa.PublicKey

// KeycloakCertsResponse — структура для хранения сертификатов Keycloak
type KeycloakCertsResponse struct {
	Keys []struct {
		Alg string `json:"alg"`
		Kid string `json:"kid"`
		Kty string `json:"kty"`
		N   string `json:"n"`
		E   string `json:"e"`
	} `json:"keys"`
}

// GetTokenFromKeycloak gets token from Keycloak.
func GetTokenFromKeycloak(baseURL, realm, clientID, clientSecret, username, password string) (Response, error) {
	client := resty.New()

	requestData := map[string]string{
		"client_id":     clientID,
		"client_secret": clientSecret,
		"grant_type":    "password",
		"username":      username,
		"password":      password,
	}

	resp, err := client.R().
		SetHeader("Content-Type", "application/x-www-form-urlencoded").
		SetFormData(requestData).
		Post(fmt.Sprintf("%s/realms/%s/protocol/openid-connect/token", baseURL, realm))

	if err != nil {
		return Response{}, fmt.Errorf("failed to send request to Keycloak: %w", err)
	}

	if resp.StatusCode() != http.StatusOK {
		return Response{}, fmt.Errorf("invalid response from Keycloak: %s", resp.String())
	}

	var tokenResp Response
	err = json.Unmarshal(resp.Body(), &tokenResp)
	if err != nil {
		return Response{}, fmt.Errorf("failed to parse token response: %w", err)
	}

	return tokenResp, nil
}

// ExtractToken gets token from the request.
func ExtractToken(r *http.Request) (string, error) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return "", fmt.Errorf("no Authorization header provided")
	}

	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
		return "", fmt.Errorf("invalid Authorization header format")
	}

	return parts[1], nil // Return the token part of the Authorization header
}

// ValidateToken checks if the token is valid.
func ValidateToken(tokenString string) (bool, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Check the signing method
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return PublicKey, nil
	})

	if err != nil {
		return false, fmt.Errorf("failed to parse token: %w", err)
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		// Check the expiration time
		if exp, ok := claims["exp"].(float64); ok {
			if time.Unix(int64(exp), 0).Before(time.Now()) {
				return false, fmt.Errorf("token has expired")
			}
		} else {
			return false, fmt.Errorf("exp claim is missing or invalid")
		}

		return true, nil
	}

	return false, fmt.Errorf("invalid token")
}

// FetchPublicKey gets public key from Keycloak.
func FetchPublicKey(url string) error {
	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to fetch public key from Keycloak: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to fetch public key: received status %d", resp.StatusCode)
	}

	var certs KeycloakCertsResponse
	if err := json.NewDecoder(resp.Body).Decode(&certs); err != nil {
		return fmt.Errorf("failed to decode public key response: %w", err)
	}

	if len(certs.Keys) == 0 {
		return errors.New("no keys found in Keycloak response")
	}

	modulus, _ := base64.RawURLEncoding.DecodeString(certs.Keys[0].N)
	exponent, _ := base64.RawURLEncoding.DecodeString(certs.Keys[0].E)

	PublicKey = &rsa.PublicKey{
		N: new(big.Int).SetBytes(modulus),
		E: int(new(big.Int).SetBytes(exponent).Int64()),
	}

	return nil
}
