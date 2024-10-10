package token

type IKeycloakClient interface {
	ValidateToken(token string) (bool, error)
}

type RealKeycloakClient struct {
}

func (c *RealKeycloakClient) ValidateToken(token string) (bool, error) {
	return ValidateToken(token)
}
