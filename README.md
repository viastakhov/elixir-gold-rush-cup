# GoldRush

*HighLoad Cup 2021: Stage 2, Round 1, Task A*

[![License](https://img.shields.io/badge/License-EPL%201.0-red.svg)](https://www.eclipse.org/legal/epl-v10.html)

## Setup
### Dev environment
Change config *./config/config.exs*
### Prod environment
Change release config *./config/release.exs*

## Build
### Dev environment
* Install *hex* and *rebar*
  ```shell
  mix local.hex --force
  mix local.rebar --force
  ```
* Install mix dependencies
  ```shell
  mix deps.get
  ```
### Prod environment
* Build docker image
  ```shell
  docker build --no-cache -t gold_rush:0.1.0 .
  ```

## Run
### Dev environment
```shell
mix run --no-halt
```
### Prod environment
```shell
docker run --rm -it -e ADDRESS=localhost --net=host -t gold_rush:0.1.0
```

## License
Copyright © 2021 Vladimir Astakhov [viastakhov@mail.ru]

Distributed under the Eclipse Public License 1.0.