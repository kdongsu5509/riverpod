#!/bin/bash

# Fast fail the script on failures.
set -e

dart pub global activate coverage

dart pub global run coverage:test_with_coverage