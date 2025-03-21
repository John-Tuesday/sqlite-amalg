#!/usr/bin/env bash

set -e

readonly build_rel_dir="build"
readonly amalgamation_dest_rel_dir="sqlite3-amalgamation"

function configure() {
  (cd ${build_rel_dir} && ../sqlite/configure --enable-all)
}

function make-amalgamation() {
  (cd ${build_rel_dir} && make sqlite3.c)
}

function create-payload() {
  mkdir --verbose --parents ${amalgamation_dest_rel_dir}
  cp "--target-directory=${amalgamation_dest_rel_dir}" ${build_rel_dir}/sqlite3.c ${build_rel_dir}/sqlite3.h
}

function clean() {
  rm -r ${build_rel_dir}/*
  rm -r ${amalgamation_dest_rel_dir}/*
}

mkdir --verbose --parents ${build_rel_dir}
configure 
make-amalgamation 
create-payload
