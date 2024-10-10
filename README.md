VoiceLine exercise.
====

1) _If you would build VoiceLine from scratch, which tech would you use, what would be building blocks and how would communication between those blocks look like?_

The VoiceLine application can be built using the following technologies:

![Schema1.png](Doc/Schema1.drawio.png)

Main system blocks:
- **Frontend** - The user interface that interacts with the user (Mobile, Desktop, Web etc).
    
  - Technologies: React or Flutter.
  - Communication: REST API, Websockets.

- **Integration/Processing** - The server-side service that processes requests and integrations.

    - Technologies: Golang, Python, Node.js.
    - Communication: REST API, Websockets, Protobuf.
  
- **Storage** - A storage system for storing data (databases).
    
    - Technologies: PostgreSQL, MongoDB.
    - Communication: SQL, NoSQL. 

- **Voice Processing** - A service for processing voice data.
    
    - Technologies: Python, Golang.
    - Communication: REST API, Protobuf, Async messages (Kafka).

- **AI/ML Analytics** - A service for analyzing voice data.
    
    - Technologies: Python, Golang.
    - Communication: REST API, Protobuf, Async messages (Kafka).

- **External Services** - External services for integration (CRM, ERP etc).

    - Communication: REST API, Protobuf.

Additional blocks can be added:

- **Monitoring** - Monitoring system for tracking system performance and errors.

    - Technologies: Prometheus, Grafana, Jaeger.
    - Communication: HTTP, gRPC. 

- **CI/CD** - Continuous integration and deployment for services.

    - Technologies: Jenkins, GitLab CI/CD.
    - Communication: HTTP, gRPC.
    
---

2) _Quickly set up a Backend in Golang with a backend framework of your choice and register a user - with a script or a function call or frontend input - with a authentication provider, please try to do a http request to their REST api of said provider. Spin up a lightweight DB of your choice and save user information to it. Dont overengineer it, stop at a maximum of 4 hours invested!_


## Plan application

Create a Golang application with the following parts:

1) REST API for user management (users).
2) Authentication and authorization using JWT via Keycloak (keycloak).
3) All data will be stored in a PostgreSQL database.
4) The application will be run in Docker containers.

Application starts with a contract description in the OpenAPI-format `doc/swagger.yaml`.
After code generation, the implementation code is written in the file `api/impl.go` and the corresponding tests.

## Schema

```mermaid
sequenceDiagram
  participant Client
  participant Backend
  participant Keycloak
  participant Database

  note over Client, Backend: Auth Operations
  Client->>Backend: POST /auth/login (username, password)
  Backend->>Keycloak: POST /realms/{realm}/protocol/openid-connect/token (username, password)
  Keycloak-->>Backend: 200 OK (access_token, refresh_token, expires_in)
  Backend-->>Client: 200 OK (access_token, refresh_token)

  Client->>Backend: POST /auth/logout
  Backend->>Keycloak: POST /realms/{realm}/protocol/openid-connect/logout (refresh_token)
  Keycloak-->>Backend: 204 No Content
  Backend-->>Client: 204 No Content

  Client->>Backend: POST /auth/refresh (refresh_token)
  Backend->>Keycloak: POST /realms/{realm}/protocol/openid-connect/token (refresh_token)
  Keycloak-->>Backend: 200 OK (new access_token, new refresh_token)
  Backend-->>Client: 200 OK (new access_token, new refresh_token)

  note over Client, Backend: User Operations
  Client->>Backend: POST /users (first_name, last_name, email, password)
  Backend->>Keycloak: POST /realms/{realm}/protocol/openid-connect/token (client_id, client_secret)
  Keycloak-->>Backend: 200 OK (access_token)
  Backend->>Keycloak: POST /realms/{realm}/users (user data)
  Keycloak-->>Backend: 201 Created (Keycloak User ID)
  Backend->>Database: INSERT INTO users (Keycloak User ID, first_name, last_name, email)
  Database-->>Backend: Success
  Backend-->>Client: 201 Created (User ID, first_name, last_name, email)

  Client->>Backend: GET /users?page={page}&limit={limit}
  Backend->>Database: SELECT * FROM users LIMIT {limit} OFFSET {page}
  Database-->>Backend: List of Users
  Backend-->>Client: 200 OK (List of Users)

  Client->>Backend: GET /users/{id}
  Backend->>Database: SELECT * FROM users WHERE id = {id}
  Database-->>Backend: User Details
  Backend-->>Client: 200 OK (User Details)

  Client->>Backend: PUT /users/{id} (first_name, last_name, email)
  Backend->>Database: UPDATE users SET first_name = {first_name}, last_name = {last_name}, email = {email} WHERE id = {id}
  Database-->>Backend: Success
  Backend-->>Client: 200 OK (Updated User Details)

  Client->>Backend: DELETE /users/{id}
  Backend->>Keycloak: DELETE /realms/{realm}/users/{Keycloak User ID}
  Keycloak-->>Backend: 204 No Content
  Backend->>Database: DELETE FROM users WHERE id = {id}
  Database-->>Backend: Success
  Backend-->>Client: 204 No Content
```

## Build application

Build and check code can be done with the `make` command via Makefile.


## Run application as CLI application

```shell
export VOICELINE_CONFIG_PATH=config/local.yaml
```

```shell
go run  ./cmd/users/main.go
```

## Run application as docker containers

```shell
docker compose up -d
```

## Stop application with docker containers

```shell
docker compose down
```

## Documentation of API (swagger)

See swagger documentation file [here](swagger/swagger.yaml)

Swagger file can be used for API testing.


## Run tests

```shell
make test
```

## Test coverage

![Coverage](https://img.shields.io/badge/coverage-27.7%25-brightgreen)

To update test coverage, run:

```shell
make update-readme
```

## Implementation

1) The implementation starts with a contract description in the OpenAPI-format
`doc/swagger.yaml`. 
2) According to the contract description, the code for the server is generated:
```shell
make gen
```
3) Next, we need to implement the implementation code in the file `api/impl.go` and the corresponding tests.
4) Generation of mocks for the test is performed by the command
```shell
make mocks
```
5) Testing can be performed using a contract file `doc/swagger.yaml` or a utility program like `Postman`.

## Authentication and Authorization

An application uses JWT for authentication and authorization. 
The JWT token will be generated when the user logs in and will be used for subsequent requests. 
The token will be stored in the `Authorization` header.

We use a third-party system [KeyCloak](https://www.keycloak.org/)


Admin panel:
http://localhost:8403/

```
KEYCLOAK_USER: admin
KEYCLOAK_PASSWORD: admin
```

### Getting client secret

Client: admin

URL: http://localhost:8087/

Your client need to have the access-type set to `confidential` , then you will have a new tab credentials where you will see the `client secret`.

See https://wjw465150.gitbooks.io/keycloak-documentation/content/server_admin/topics/clients/oidc/confidential.html

Client secret is needed to put in parameter

```keycloak->client_secret:```

in files
- .\config\local.yml
- .\config\prod.yml
