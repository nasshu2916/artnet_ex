# Changelog

## [0.1.1] - 2026-07-16

### Added

- Added support for variable-length binary and string packet fields.
- Added compatibility with Elixir 1.20 and Erlang/OTP 29 while retaining support for Elixir 1.15 and later.

### Changed

- Moved OpCode values into their packet modules and derived OpCode names from packet module names.

### Fixed

- Fixed packet encoding and decoding for Elixir 1.20.
- Fixed data-length validation for invalid `ArtRdmSub` command classes.

## [0.1.0] - 2026-05-29

### Added

- Initial release.
