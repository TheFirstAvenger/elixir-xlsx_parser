XlsxParser
==========
[![Build Status](https://semaphoreci.com/api/v1/projects/0f705138-4dca-4e46-890b-52e6031926c8/616905/badge.svg)](https://semaphoreci.com/TheFirstAvenger/elixir-xlsx_parser)

Simple parsing of xlsx spreadsheet data. Data can be retrieved or written to csv.

## Usage

### Parsing an .xlsx

    {:ok, ret} = XlsxParser.get_sheet_content("/path/to/my.xlsx", 1)

ret will contain a list of {column, row, value}:

    [{"A", 1, "a"}, {"A", 2, "c"}, {"B", 1, "two"}]

###  Writing to CSV

    {status, ret} = XlsxParser.write_sheet_content_to_csv("/path/to/my.xlsx", 1, "/path/to/my.csv")

ret will contain the full text written out to /path/to/my.csv

DISCLAIMER:

This parser works on documents I have so far encountered. Please verify that it works for your documents before using in production. Log any issues via github.
