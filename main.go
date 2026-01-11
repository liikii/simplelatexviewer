package main

import (
	"embed"
	"fmt"
	"net/http"
	"os"
	"io/fs"

	"github.com/spf13/cobra"
)


//go:embed web/*
var staticFS embed.FS

// 全局变量：存储端口配置（默认 ":8080"）
var port string

// ---------------------- 核心：创建 Cobra 根命令 ----------------------
var rootCmd = &cobra.Command{
	Use:   "latex-viewer",                  // 命令名称（执行二进制文件时的命令）
	Short: "a simple latex viewer", // 命令简短描述
	Long:  `embeded the static file in executable file`, // 命令详细描述
	Run: func(cmd *cobra.Command, args []string) {
		// 命令执行逻辑：启动 HTTP 服务（核心业务逻辑不变）
		startHTTPServer(port)
	},
}

// ---------------------- 初始化：注册命令行选项 + 配置默认值 ----------------------
func init() {
	// 注册命令行选项：-p/--port（指定端口，默认 ":8080"）
	// 格式：PersistentFlags().StringVarP(变量地址, 短选项, 长选项, 默认值, 选项描述)
	rootCmd.PersistentFlags().StringVarP(
		&port,          // 变量地址：将用户输入的值绑定到全局变量 port
		"port",         // 长选项：--port
		"p",            // 短选项：-p
		":8080",        // 默认值：如果用户不指定，使用 ":8080"
		"port，example \"8090\" 或 \":9000\"", // 选项描述（自动生成到帮助文档中）
	)

	// 可选：添加端口格式预处理（用户输入 "8090" 自动补全为 ":8090"）
	// 利用 PreRun 钩子，在命令执行前处理端口格式
	rootCmd.PreRun = func(cmd *cobra.Command, args []string) {
		port = formatPort(port)
	}
}

// ---------------------- 辅助函数：端口格式处理 ----------------------
func formatPort(p string) string {
	// 若用户输入的端口无冒号，自动补全
	if len(p) > 0 && p[0] != ':' {
		return ":" + p
	}
	// 兜底：空端口返回默认值
	if p == "" {
		return ":8080"
	}
	return p
}

// ---------------------- 核心业务：启动 HTTP 服务（与之前一致） ----------------------
func startHTTPServer(port string) {
	// 1. 根路径 / 响应 index.html
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}

		htmlContent, err := staticFS.ReadFile("web/index.html")
		if err != nil {
			http.Error(w, "read file："+err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_, err = w.Write(htmlContent)
		if err != nil {
			http.Error(w, "resp error："+err.Error(), http.StatusInternalServerError)
			return
		}
	})

	staticSubFS, err := fs.Sub(staticFS, "web")
	if err != nil {
		fmt.Printf("read file error：%s\n", err.Error())
		os.Exit(1)
	}

	staticFileServer := http.FileServer(http.FS(staticSubFS))
	http.Handle("/static/", staticFileServer)

	// 3. 启动服务
	fmt.Printf("starting，visit：http://localhost%s\n", port)
	err = http.ListenAndServe(port, nil)
	if err != nil {
		fmt.Printf("starting error：%s\n", err.Error())
		os.Exit(1)
	}
}

// ---------------------- 程序入口：执行 Cobra 根命令 ----------------------
func main() {
	// 执行根命令，处理命令行参数并运行业务逻辑
	if err := rootCmd.Execute(); err != nil {
		fmt.Printf("execute error：%s\n", err.Error())
		os.Exit(1)
	}
}
