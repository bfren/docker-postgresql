#!/usr/bin/env -S nu -n

use ../index/test.nu

const postgresql_branches = [
    "12"
    "13"
    "14"
    "15"
    "16"
    "17"
    "18"
]

# Run test suite for image
def main [
    postgresql: string = "18"  # define which PostgreSQL version to use
    --all (-a)                 # test all registered versions of PostgreSQL (overrides $postgresql)
] {
    let branches = if $all { $postgresql_branches } else { [$postgresql] }
    test "postgresql" $branches
}
