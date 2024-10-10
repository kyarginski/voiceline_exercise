package mocks

type MockKeycloakClient struct {
	ValidateTokenFunc func(token string) (bool, error)
}

func (m *MockKeycloakClient) ValidateToken(token string) (bool, error) {
	if m.ValidateTokenFunc != nil {
		return m.ValidateTokenFunc(token)
	}
	return true, nil
}
