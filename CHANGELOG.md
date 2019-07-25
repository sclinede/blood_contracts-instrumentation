# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [master] - [2019-07-25]

Fixes NoMethodError in Instrument.build

Adds specs

## [0.1.0] - [2019-07-05]

This is a first public release marked in change log with features extracted from production app.
Includes:
- Configuration for instruments (proc or a callable object)
- Automatic detection of existing Refined types
- Assignment of instruments to types
- #match wrapper to handle before, after and finalize of call
- 3 strategies of finalization (basic, threads and fibers)
