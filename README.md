# l

A simple command-line tool that acts as a shorthand for `ls`.

## Installation

```bash
go install github.com/rRateLimit/l@latest
```

## Usage

```bash
l [options] [file/directory]
```

All arguments are passed directly to the `ls` command.

### Examples

```bash
# List files in current directory
l

# List files with details
l -la

# List files in a specific directory
l /path/to/directory
```

## Build from source

```bash
git clone https://github.com/rRateLimit/l.git
cd l
go build -o l main.go
```

## License

MIT