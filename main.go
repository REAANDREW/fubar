package main

import (
	"fmt"
	"net/http"

	"github.com/coreos/go-systemd/daemon"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, World!")
}

func main() {
	http.HandleFunc("/", handler)
	daemon.SdNotify(false, "READY=1")
	fmt.Println(http.ListenAndServe(":45000", nil))
}
