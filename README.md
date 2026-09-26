# Template for creating the best shell script POSIX compliant project

## ToDo

* Replace the `PRJ_ID` variable from the builder `build.sh`
* Update the main script in `src/project.sh`
* Add any includes in `src/`, should be including as `. "${ROOT}/src/include.sh`
* Add any data files to install with the project's intallation in `build.sh`

## Builder

One main file `build.sh` to:

* `./build.sh check`: Call Schellcheck
* `./build/sh build`: Build the binary into `build/` dir with `PREFIX` path
* `./build/sh install`: Install artefects built in `DESTDIR`
* `./build.sh clean`: Removes the `buid/` dir
* `./build.sh`: Clean + Check + Build


```bash
PREFIX=/usr sh build.sh
DESTDIR=${HOME}/.local sh build.sh install
```

### ENV Variables

* `PREFIX`: Install files withprefix path
* `DESTDIR`: Destination directory to install
* `PRJ_ID`: Override the PRJ_ID value.
* `VERSION`: Override the PRJ_ID version.

## printer

Useful printer library in `src/printer.sh`
* call `print_<level> "message` to print in fd 3 for logging. Levels can be:
  * `info`:    print `[INFO] message` in green
  * `warning`: Print `[WARN] message` in yellow
  * `error`:   Print `[ ERR] message` in red
  * `debug`:   Print `[DEBG] message` in cyan
* If VERBOSE set, though `-v` argument cli: debug are `print_debug` prints
* If QUIET set, though `-q` argument cli: all prints are cancelled

## configuration file

* Project can use configuration file in `CONF_P` to be used alternatively to
argument CLI.
> by default in CONF_P=`${HOME}/.config/${PRJ_ID}.conf`

* Configuration architecture:

```conf
KEY=VALUE
ARRAY_KEY=(
  VALUE1
  VALUE2
)
```

* All `KEY` can be managed in the `_parse_conf()` internal function.

* Path to conf can be override by `--conf` argument CLI.
