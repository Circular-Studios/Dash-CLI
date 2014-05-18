# Dash-CLI [![Build Status](http://img.shields.io/travis/Circular-Studios/Dash-CLI/master.svg?style=flat)](https://travis-ci.org/Circular-Studios/Dash-CLI)

The Dash Command Line Interface exists to make working with [Dash](https://github.com/Circular-Studios/Dash) even easier. It supports the following commands and arguments:

---

## Commands

NOTE: Unless otherwise specifed, `project` can be left off to run in the current directory.

### Create

`dash create <[project]>`

The `create` command initializes an empty project in `project`, or the current directory if `project` is not specified.

##### Arguments

| Argument       | Type     | Description
|:--------------:|:--------:|:---------
| `k`, `gitkeep` | `bool`   | If this is enabled, all empty folders have a `.gitkeep` file placed in them.

### Compress

`dash compress <[project]>`

The `compress` command compresses all yaml in the given project into a single `Content.yml` file ready for production.

### Publish

`dash publish <[project]>`

The `publish` command runs `compress` on the project, and then zips all files required at runtime for distribution.

##### Arguments

| Argument       | Type     | Description
|:--------------:|:--------:|:-----
| `o`, `zipfile` | `string` | This specifies the name of the zip file to output.
