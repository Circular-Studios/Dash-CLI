### Dash-CLI [![Build Status](http://img.shields.io/travis/Circular-Studios/Dash-CLI/master.svg?style=flat)](https://travis-ci.org/Circular-Studios/Dash-CLI)

Dash-CLI exists to make working with [Dash](https://github.com/Circular-Studios/Dash) even easier. It supports the following commands and arguments:

---

##### Commands

| Command    | Description
|:----------:|:-----------
| `compress` | This compresses all yaml in a game into a single `Config.yml` file for embedding.
| `publish`  | This compresses the yaml, and then compresses all necessary folders into a zip archive.

---

##### Arguments
| Argument       | Commands  | Default    | Description
|:--------------:|:---------:|:----------:|------------
| `g`,`game-dir` | All       | `cwd`      | Sets the directory of the game you're working on.
| `o`,`zip-file` | `publish` | `game.zip` | The name of the zip file to output when publishing.
