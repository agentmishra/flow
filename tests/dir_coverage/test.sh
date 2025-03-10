#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

coverage() {
  echo "-----------------------------"
  echo "restart server"
  echo "-----------------------------"
  assert_ok "$FLOW" stop
  assert_ok "$FLOW" start
  echo "-----------------------------"
  echo "root"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root .
  echo "-----------------------------"
  echo "folder"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root folder
  echo "-----------------------------"
  echo "cycle"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root cycle
  echo "-----------------------------"
  echo "match_coverage"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root match_coverage
  echo "-----------------------------"
  echo "other_folder"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root other_folder
  echo "-----------------------------"
  echo "folder/subfolder"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root folder/subfolder
  echo "-----------------------------"
  echo "file list"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root a.js folder/d.js folder/subfolder/j.js
  echo "-----------------------------"
  echo "file and dir list"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root a.js folder folder/d.js
  echo "-----------------------------"
  echo "files"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root --input-file files.txt
  echo "-----------------------------"
  echo "json"
  echo "-----------------------------"
  assert_ok "$FLOW" batch-coverage --strip-root --json --pretty --input-file files.txt
  echo "-----------------------------"
  echo "root info survives recheck"
  echo "-----------------------------"
  assert_ok cp a.js.ignored a.js
  assert_ok "$FLOW" force-recheck a.js
  assert_ok "$FLOW" batch-coverage --strip-root --wait-for-recheck true .
  echo "-----------------------------"
  echo "delete file"
  echo "-----------------------------"
  assert_ok rm a.js
  assert_ok "$FLOW" force-recheck a.js
  assert_ok "$FLOW" batch-coverage --strip-root --wait-for-recheck true .
  echo "-----------------------------"
  echo "parsed -> unparsed file"
  echo "-----------------------------"
  assert_ok cp non_flow.js b.js
  assert_ok "$FLOW" force-recheck b.js
  assert_ok "$FLOW" batch-coverage --strip-root --wait-for-recheck true .
}

coverage > coverage.log

cat coverage.log
