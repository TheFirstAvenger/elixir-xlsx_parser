# XlsxParser

[![Build Status](https://travis-ci.com/TheFirstAvenger/elixir-xlsx_parser.svg?branch=master)](https://travis-ci.com/TheFirstAvenger/elixir-xlsx_parser)
[![Coverage Status](https://coveralls.io/repos/github/TheFirstAvenger/elixir-xlsx_parser/badge.svg?branch=master)](https://coveralls.io/github/TheFirstAvenger/elixir-xlsx_parser?branch=master)
[![Project license](https://img.shields.io/hexpm/l/xlsx_parser.svg)](https://unlicense.org/)
[![Hex.pm package](https://img.shields.io/hexpm/v/xlsx_parser.svg)](https://hex.pm/packages/ets)
[![Hex.pm downloads](https://img.shields.io/hexpm/dt/xlsx_parser.svg)](https://hex.pm/packages/ets)

Simple parsing of xlsx spreadsheet data. Data can be retrieved or written to csv.

## Usage

### Parsing an .xlsx

    {:ok, ret} = XlsxParser.get_sheet_content("/path/to/my.xlsx", 1)

ret will contain a list of {column, row, value}:

    [{"A", 1, "a"}, {"A", 2, "c"}, {"B", 1, "two"}]

### Writing to CSV

    {status, ret} = XlsxParser.write_sheet_content_to_csv("/path/to/my.xlsx", 1, "/path/to/my.csv")

ret will contain the full text written out to /path/to/my.csv

DISCLAIMER:

This parser works on documents I have so far encountered. Please verify that it works for your documents before using in production. Log any issues via github.

This package can be installed by adding `xlsx_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xlsx_parser, "~> 0.1.2"}
  ]
end
```
