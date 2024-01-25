BIN_DIR       := $(PWD)/bin
BINARY_NAME   := $(notdir $(shell go list -m))
.DEFAULT_GOAL := $(BIN_DIR)/$(BINARY_NAME)


SRC_FILES := $(shell find . -name "*.go")
$(BIN_DIR)/$(BINARY_NAME): $(SRC_FILES)
	@go build -o $(BIN_DIR)/$(BINARY_NAME) main.go


.PHONY: run
run: $(BIN_DIR)/$(BINARY_NAME)
	@$(BIN_DIR)/$(BINARY_NAME)

.PHONY: test
test:
	@go test -v -race ./...

.PHONY: clear
clear:
	@rm -rf $(BIN_DIR)
	@rm cover.out

.PHONY: cover
cover:
	@go test -v -race -cover -coverpkg ./... -coverprofile cover.out ./...
	@go tool cover -func cover.out | tail -n 1 | awk '{ print $$3 }'

.PHONY: audit
audit:
	@go mod verify
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.2 run ./...
	@go run go.uber.org/nilaway/cmd/nilaway@latest ./...
	@go run golang.org/x/vuln/cmd/govulncheck@v1.0.3 ./...
