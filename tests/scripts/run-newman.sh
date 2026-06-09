#!/usr/bin/env bash

set -euo pipefail
COLL_DIR=tests/postman/collections
ENV=tests/postman/environments/local.postman_environment.json

newman run "$COLL_DIR/supplier-contract.postman_collection.json" -e "$ENV" --reporters cli,htmlextra --reporter-htmlextra-export newman-supplier.html
newman run "$COLL_DIR/home-test-caller.postman_collection.json" -e "$ENV" --reporters cli,htmlextra --reporter-htmlextra-export newman-caller.html
