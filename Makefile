# 定义项目名称（编译后的二进制文件名）
PROJECT_NAME := latex-viewer

# 定义默认端口（可覆盖）
DEFAULT_PORT := ":8080"

# 定义嵌入的静态资源目录（与 main.go 中的 //go:embed 一致）
STATIC_DIR := web

# 定义 Go 编译参数
GO_BUILD_FLAGS := -ldflags "-s -w"  # 去除调试信息，减小二进制体积
GO_CLEAN_FLAGS := -mod cache

# ---------------------- 默认目标：编译项目 ----------------------
# 执行 make 时，默认执行 build 目标
all: build

# ---------------------- 编译目标：支持跨平台编译 ----------------------
# 1. 本地编译（适配当前操作系统）
build:
	@echo "==================== 开始本地编译项目 ===================="
	# 检查 web 目录是否存在（确保静态资源目录完整）
	@if [ ! -d "$(STATIC_DIR)" ]; then \
		echo "错误：静态资源目录 $(STATIC_DIR) 不存在，请确认项目目录结构！"; \
		exit 1; \
	fi
	# 本地编译（生成对应操作系统的二进制文件）
	go build $(GO_BUILD_FLAGS) -o $(PROJECT_NAME) main.go
	@echo "编译成功！二进制文件：./$(PROJECT_NAME)"

# 2. 跨平台编译：Linux 64位
build-linux:
	@echo "==================== 开始编译 Linux 64位版本 ===================="
	@if [ ! -d "$(STATIC_DIR)" ]; then \
		echo "错误：静态资源目录 $(STATIC_DIR) 不存在，请确认项目目录结构！"; \
		exit 1; \
	fi
	# 设置 Linux 跨平台编译环境变量
	CGO_ENABLED=0 \
	GOOS=linux \
	GOARCH=amd64 \
	go build $(GO_BUILD_FLAGS) -o $(PROJECT_NAME)-linux-amd64 main.go
	@echo "Linux 版本编译成功！二进制文件：./$(PROJECT_NAME)-linux-amd64"

# 3. 跨平台编译：Windows 64位
build-windows:
	@echo "==================== 开始编译 Windows 64位版本 ===================="
	@if [ ! -d "$(STATIC_DIR)" ]; then \
		echo "错误：静态资源目录 $(STATIC_DIR) 不存在，请确认项目目录结构！"; \
		exit 1; \
	fi
	# 设置 Windows 跨平台编译环境变量
	CGO_ENABLED=0 \
	GOOS=windows \
	GOARCH=amd64 \
	go build $(GO_BUILD_FLAGS) -o $(PROJECT_NAME)-windows-amd64.exe main.go
	@echo "Windows 版本编译成功！二进制文件：./$(PROJECT_NAME)-windows-amd64.exe"

# 4. 跨平台编译：Mac 64位（Intel 芯片）
build-mac:
	@echo "==================== 开始编译 Mac 64位版本（Intel） ===================="
	@if [ ! -d "$(STATIC_DIR)" ]; then \
		echo "错误：静态资源目录 $(STATIC_DIR) 不存在，请确认项目目录结构！"; \
		exit 1; \
	fi
	# 设置 Mac 跨平台编译环境变量
	CGO_ENABLED=0 \
	GOOS=darwin \
	GOARCH=amd64 \
	go build $(GO_BUILD_FLAGS) -o $(PROJECT_NAME)-darwin-amd64 main.go
	@echo "Mac 版本（Intel）编译成功！二进制文件：./$(PROJECT_NAME)-darwin-amd64"

# ---------------------- 运行目标：启动服务 ----------------------
# 1. 默认端口运行（无需指定端口，使用 8080）
run: build
	@echo "==================== 启动 LaTeX 查看器服务（默认端口 8080） ===================="
	./$(PROJECT_NAME)

# 2. 指定端口运行（示例：make run-port PORT=8090）
run-port: build
	@echo "==================== 启动 LaTeX 查看器服务（端口 $(PORT)） ===================="
	./$(PROJECT_NAME) -p $(PORT)

# ---------------------- 清理目标：删除编译产物 ----------------------
clean:
	@echo "==================== 清理编译产物 ===================="
	# 删除本地编译产物
	rm -f $(PROJECT_NAME)
	# 删除跨平台编译产物
	rm -f $(PROJECT_NAME)-linux-amd64
	rm -f $(PROJECT_NAME)-windows-amd64.exe
	rm -f $(PROJECT_NAME)-darwin-amd64
	# 清理 Go 模块缓存（可选）
	go clean $(GO_CLEAN_FLAGS)
	@echo "清理完成！"

# ---------------------- 帮助目标：显示使用说明 ----------------------
help:
	@echo "==================== LaTeX 查看器 Makefile 使用说明 ===================="
	@echo "可用命令："
	@echo "  make          - 【默认】本地编译项目，生成 ./$(PROJECT_NAME)"
	@echo "  make build    - 本地编译项目（同 make）"
	@echo "  make build-linux   - 编译 Linux 64位版本"
	@echo "  make build-windows - 编译 Windows 64位版本"
	@echo "  make build-mac     - 编译 Mac 64位版本（Intel 芯片）"
	@echo "  make run      - 编译并启动服务（默认端口 8080）"
	@echo "  make run-port PORT=8090 - 编译并启动服务（指定端口 8090）"
	@echo "  make clean    - 清理所有编译产物"
	@echo "  make help     - 显示此帮助信息"
	@echo ""
	@echo "示例："
	@echo "  1. 本地编译并运行：make run"
	@echo "  2. 指定端口 8090 运行：make run-port PORT=8090"
	@echo "  3. 编译全平台版本：make build build-linux build-windows build-mac"
