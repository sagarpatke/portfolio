# Build a vagrant box for bullseye64

## Status

What is the status, such as proposed, accepted, rejected, deprecated, superseded, etc.?
Accepted

## Context

What is the issue that we're seeing that is motivating this decision or change?

1. Debian has recently released bullseye, which replaces buster64 as the new stable. buster64 is now oldstable
1. The scripts written to build buster64 now no longer work, as netinst images for buster64 are no longer available
1. When debian makes a new stable release, we have seen that oldstable netinst images become unavailable. It is hence easier to write and maintain build scripts based on names such as testing, stable, and oldstable, rather than actual release names, which require major rework when debian makes new releases

## Decision

What is the change that we're proposing and/or doing?

None, it's a new addition.

## Consequences

What becomes easier or more difficult to do because of this change?

1. Creation of vagrant boxes based on Debian Bullseye 64
