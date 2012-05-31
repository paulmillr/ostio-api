# Ost.io-api
Your open-source talks place. Backend part.

## Getting started
This is a backend part of [ost.io](http://ost.io/) application.

Ostio api is built with [Rails](http://rubyonrails.org/).

## Deploying
* Copy `nginx.conf` to your nginx dir: `sudo cp nginx.conf /etc/nginx/api.conf`
* Restart nginx: `sudo /etc/init.d/nginx restart`
* Add your GitHub app id / secret to ENV:

```
# This is id / secret of example app. Callback URL for it:
# http://dev.ost.io:3000/auth/github
export GITHUB_APP_ID='b99404045c3917fd6be4'
export GITHUB_APP_SECRET='fedbf022667be7056bcaca9568e55151b219c660'
```

* Restart thin webserver: `sudo killall thin && thin start -C thin.yml`

## API
`GET`, `POST`, `PUT` / `PATCH` and `DELETE` are available to these resources.

```
/users/
/users/:username
/users/:username/repos
/users/:username/repos/:repo_name
/users/:username/repos/:repo_name/topics
/users/:username/repos/:repo_name/topics/:topic_number
/users/:username/repos/:repo_name/topics/:topic_number/posts
/users/:username/repos/:repo_name/topics/:topic_number/posts/:id
```

## License
The MIT License (MIT)

Copyright (c) 2012 Paul Miller (http://paulmillr.com/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
