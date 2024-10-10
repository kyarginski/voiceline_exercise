package config

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"voiceline/internal/lib/token"

	"github.com/ilyakaznacheev/cleanenv"
)

type Config struct {
	Env            string         `yaml:"env" env-default:"local"`
	Version        string         `yaml:"version" env-default:"unknown"`
	Port           int            `yaml:"port" env-default:""`
	DBConnect      string         `yaml:"db_connect" env-default:""`
	UseTracing     bool           `yaml:"use_tracing"`
	TracingAddress string         `yaml:"tracing_address" env-default:""`
	Keycloak       KeycloakConfig `yaml:"keycloak"`
}

type KeycloakConfig struct {
	Server       string `yaml:"server"`
	Realm        string `yaml:"realm"`
	ClientSecret string `yaml:"client_secret"`
	ClientID     string `yaml:"client_id"`
}

func MustLoad() *Config {
	configPath := os.Getenv("VOICELINE_CONFIG_PATH")
	if configPath == "" {
		configPath = "config/local.yaml"
	}
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		log.Fatalf("config file does not exist: %s", configPath)
	}

	var cfg Config

	if err := cleanenv.ReadConfig(configPath, &cfg); err != nil {
		log.Fatalf("cannot read config: %s", err)
	}

	portEnv := os.Getenv("VOICELINE_PORT")
	if portEnv != "" {
		newPort, err := strconv.Atoi(portEnv)
		if err == nil {
			cfg.Port = newPort
		}
	}

	// URL для получения публичного ключа из Keycloak
	keycloakCertsURL := fmt.Sprintf("%s/realms/%s/protocol/openid-connect/certs", cfg.Keycloak.Server, cfg.Keycloak.Realm)

	// Получение публичного ключа из Keycloak
	if err := token.FetchPublicKey(keycloakCertsURL); err != nil {
		log.Fatalf("Failed to initialize public key: %v", err)
	}

	log.Println("Public key initialized successfully")

	return &cfg
}
