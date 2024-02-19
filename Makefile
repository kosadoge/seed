BIN_DIR           := $(PWD)/bin
TMP_DIR           := $(PWD)/tmp
BINARY_NAME       := $(notdir $(shell go list -m))
MAIN_PACKAGE_PATH := .
.DEFAULT_GOAL     := $(BIN_DIR)/$(BINARY_NAME)


$(BIN_DIR):
	@mkdir -p $(BIN_DIR)
$(TMP_DIR):
	@mkdir -p $(TMP_DIR)

SRC_FILES := $(shell find . -name "*.go")
$(BIN_DIR)/$(BINARY_NAME): $(SRC_FILES) | $(BIN_DIR)
	@go build -o $(BIN_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE_PATH)


.PHONY: run
run: $(BIN_DIR)/$(BINARY_NAME)
	@$(BIN_DIR)/$(BINARY_NAME)

.PHONY: test
test:
	@go test -v -race ./...

.PHONY: test/cover
test/cover: | $(TMP_DIR)
	@go test -race -coverpkg ./... -coverprofile $(TMP_DIR)/cover.out ./...
	@go tool cover -func $(TMP_DIR)/cover.out | tail -n 1 | awk '{ print $$3 }'

.PHONY: audit
audit:
	@go mod verify
	@go run github.com/golangci/golangci-lint/cmd/golangci-lint@v1.55.2 run ./...
	@go run go.uber.org/nilaway/cmd/nilaway@latest ./...
	@go run golang.org/x/vuln/cmd/govulncheck@v1.0.3 ./...

.PHONY: clear
clear:
	@rm -rf $(BIN_DIR) $(TMP_DIR)
