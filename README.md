# Go
提供了基本 Go 專案會需要的一些工具與設定。


## Arch
除了基本元素以外，增加了協助建構的 Makefile 與 Lint 設定檔，並且預設建構出來的執行檔存放於根目錄的 `bin` 中。

```
.
├── bin
├── go.mod
├── go.sum
├── main.go
├── Makefile
├── .gitignore
└── .golangci.yml
```


## bin
存放專案建構執行檔的地方，也已加入到 `.gitignore` 內。


## Makefile
放了幾個開發時常用的 Recipe ，預設執行的 Recipe 為執行檔建構（參考 `.DEFAULT_GOAL` ），建構的執行檔名稱為 Go Module 的最後一個字，例如 `github.com/kosadoge/seed` 建構出的執行檔為 `seed` 。

```shell
# 建立執行檔到 bin 目錄內，只有在 SRC_FILES 有變動時才會重新建構
$ make

# 執行 bin 內的執行檔，也就是 compile & execute
$ make run

# 執行專案所有的測試
$ make test

# 執行專案所有測試以外，會生成覆蓋率檔案（ cover.out ）並計算出目前總覆蓋率
$ make cover

# 檢查依賴 Module 與 go.sum 內容是否一致（避免 Module 被惡意修改），並進行 Linting 與漏洞檢測
$ make audit
```

如果測試檔案（ `*_test.go` ）變動時不需重新編譯，用 `filter-out` 從 `SRC_FILES` 內過濾掉：

```makefile
SRC_FILES := $(shell find . -name "*.go")
SRC_FILES := $(filter-out %_test.go, $(SRC_FILES))
```

> `filter` 與 `filter-our` 都只支援一個 `%` ，如果寫 `%_test%` 就表示名稱以 `_test%` 結尾才命中

### 關於 audit 的寫法
Go 1.17 支援 `go run` 指定版本，所有 Go 寫的工具都能用這種作法：

```shell
$ go run <PACKAGE>@<VERSION> <ARGS>
```

> go 執行 `run` 或 `build` 時可加 `-x` 看執行的指令，雖然 `run` 每次都會編譯，但能利用快取加速

如果覺得 `go run` 不直觀，可改用已裝的執行檔，但版本就需要自己管理：

```makefile
audit:
    @go mod tidy
    @golangci-lint run ./...
    @govulncheck ./...
```


## .golangci.yml
主要參考[官方](https://github.com/golangci/golangci-lint/blob/master/.golangci.yml)的設定並做一些調整。

其中有幾項設定可以依據需求調整：

- `run.skip-dirs` ：需要跳過的目錄，適合透過 Codegen 工具產的目錄（例如： `mock` ）
- `run.skip-files` ：需要跳過的檔案，適合固定 Pattern 的檔案（例如： `.*\\.pb\\.go` ）
- `linters-settings.govet.settings.printf` ：檢查 printf-like 函式，可加入自訂函式（例如： `log.Infof` ）
- `linters-settings.goimports.local-prefixes` ：檢查**標準函式庫**有沒有與**其它函式庫**分開（兩個群組），如果 `local-prefixes` 有設定就會額外再分一個群組，建議寫專案 Go Module
