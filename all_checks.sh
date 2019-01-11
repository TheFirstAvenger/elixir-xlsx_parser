#!/bin/bash

rm -rf _build/test/lib/xlsx_parser
MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix test
MIX_ENV=test mix format --check-formatted
MIX_ENV=test mix credo --strict