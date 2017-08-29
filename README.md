# fubar

1. Install `travis` gem

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

8. Update the travis file to make use of [https://github.com/tcnksm/ghr](https://github.com/tcnksm/ghr)

```
language: go
sudo: false
go:
- 1.9
- tip
env:
  global:
      - USERNAME=reaandrew
      - VERSION=0.1.0
      - secure: pHGD1UbmMCk4WaJxJ8iH7NqfoaCUCz7y0BOTvWQPu4TNsAF0um+yidCzYGuyiSGZBoFazuixM1VqCejAEH20gnrNWZzFjJZSkorlE1NDwX8heDac5f3goUarXtnmrp7V9OEpB5AwyRE+vj5mqDmOtwWdRS0G+81momuA+c0PFq4pYoVdun1MQHM6kBJ3y4SmhBK/VRS9dhCoKNAC/8O2fn6Qbo1ET70Y2iiAzqmjCfkpj6Vf8lAdPYTU4LRNJL8FWWaGqEH9ITuW8X3N5Ed0weJero7dS0+lNQu+LWxNU4Sr+H44KNW4nXPCkLSLm5E57Sf9QVtdbz4lZrP1r4SpFdRP23vBJ7TwXURgeBJuEYxcQD508h5P89OqZWxZyt/0KUec9XOW2TKettYFlnuDL2Quw5B8s2qKUYzRYnJcNIsyy2+x78oYVWyt0zBAvOaSI9qxNvZipkUheq3eqCbnpoXrnXQIRUDHub2PIgxPsv43fHH7g2eaq+AZDittd9uaXq7IJ5x/kcSiU/+7SKkKbWfVq/WQCUtAmQKd9fxhKyK+0t7pfnAU7hngFyFiOLVrgZGLFnZtVTD8Ws8435UvRik3HzjsQqoWLtUg4xaU2Flq5lZlDw3bgm3YZmC+VvgxiMV8Qdnq5HQ1VeI7y0xIT3vCy8gxfqU0+ihRZWn5upc=
before_install:
- go get -u github.com/tcnksm/ghr
- mkdir dist
script:
- go build -o dist/fubar
after_success:
- ghr -username ${USERNAME} -token ${GITHUB_TOKEN} --delete ${VERSION} dist/
```

The variable `GITHUB_TOKEN` is encrypted using:

```
travis encrypt `GITHUB_TOKEN="TOKEN HERE"` --add env.global
```

9. Confirm you can grab the latest build using the github api and jq to parse the json output

```
curl -s https://api.github.com/repos/reaandrew/fubar/releases/latest | jq '. | .assets[0] | .browser_download_url' | xargs curl -sOL
```

AWS_ACCESS_KEY_ID="anaccesskey"
AWS_SECRET_ACCESS_KEY="asecretkey"
AWS_DEFAULT_REGION="us-west-2"
