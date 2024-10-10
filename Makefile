COVERAGE_FILE=coverage.out

.PHONY: test-cover
test-cover:
	@echo "Running tests and generating coverage report..."
	@go test -coverprofile=$(COVERAGE_FILE) ./...

.PHONY: update-readme
update-readme: test-cover
	@echo "Updating README.md with test coverage..."
	@COVERAGE=$$(go tool cover -func=$(COVERAGE_FILE) | grep total | awk '{print $$3}'); \
	PERCENT=$$(echo $$COVERAGE | tr -d '%'); \
	sed -i "" "s|!\[Coverage\](https://img.shields.io/badge/coverage-[0-9.]*%25-brightgreen)|![Coverage](https://img.shields.io/badge/coverage-$${PERCENT}%25-brightgreen)|" README.md; \
	echo "Updated README.md with Coverage: $${COVERAGE}"

.PHONY: clean
clean:
	@echo "Cleaning up coverage files..."
	@rm -f $(COVERAGE_FILE)

dep:
	go mod tidy

gen:
	oapi-codegen --old-config-style --generate types -o api/restapi/openapi_types.gen.go --package restapi ./doc/swagger.yaml
	oapi-codegen --old-config-style --generate gorilla -o api/restapi/openapi_server.gen.go --package restapi ./doc/swagger.yaml

build:
	go build -o users ./cmd/users/main.go

buildstatic:
	go build -tags musl -ldflags="-w -extldflags '-static' " -o users ./cmd/users/main.go

run:
	go run  ./cmd/users/main.go

test:
	go test ./...

lint:
	golangci-lint run -E gocritic ./...

mocks:
	mockery --name=IService --dir=internal/app/services --output=internal/mocks

check-migrate:
	which migrate || (go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest)

migrate: check-migrate
	migrate -database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable -path migrations up

migrate-down: check-migrate
	migrate -database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable -path migrations down $(V)	