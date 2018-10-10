#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

function funcname {
	# Docs
	# Args:
    #     Code
}

# Download input data
dx-download-all-inputs

# Install dependencies

# Run program

# Upload output data
dx-upload-all-outputs
