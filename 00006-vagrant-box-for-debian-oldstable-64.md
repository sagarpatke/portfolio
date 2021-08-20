# Build a vagrant box for oldstable 64

## Status

What is the status, such as proposed, accepted, rejected, deprecated, superseded, etc.?
Superseeded [00003 - Build a vagrant box for buster64](./00003-vagrant-box-for-buster64)

## Context

What is the issue that we're seeing that is motivating this decision or change?

1. Debian has recently released bullseye, which replaces buster64 as the new stable. buster64 is now oldstable
1. The scripts written to build buster64 now no longer work, as netinst images for buster64 are no longer available

## Decision

What is the change that we're proposing and/or doing?

Implement new scripts which will use existing oldstable vagrant boxes as the source and upgrade them when necessary

## Consequences

What becomes easier or more difficult to do because of this change?

1. Creation of vagrant boxes based on Debian oldstable 64
1. Minimal changes for future releases
