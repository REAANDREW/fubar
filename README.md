# fubar

1. Install `travis` gem**

```
gem install travis
```

2. Create a .gitignore file for GOLANG

[https://github.com/github/gitignore/blob/master/Go.gitignore](https://github.com/github/gitignore/blob/master/Go.gitignore)

3. Added the name of the executable to the gitignore

```
echo fubar >> .gitignore
```

4. Create a simple webserver which returns `Hello, World!`
```
package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r **http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8080", nil)
}
```

5. Create `.travis.yml` ci file for golang

This will build using golang version 1.9 and the latest version available (tip).

```
language: go
sudo: false
go:
    - 1.9
    - tip
script:
    - go build
```

6. Create a new keypair which Github will use to deploy the application.

```
cd ~/.ssh
# I created a private and public key named fubar (fubar & fubar.pub)
ssh-keygen 
```

7. Copy the public key into the source directory

```
cp ~/.ssh/fubar.pub /home/vagrant/go/src/github.com/reaandrew/fubar
```

$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_DEFAULT_REGION="us-west-2"
$ terraform plan
