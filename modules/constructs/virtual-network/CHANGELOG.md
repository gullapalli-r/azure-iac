# Changelog

All notable changes should be published in this changelog. While GitHub issues could be used to track bugs, most of the work may be done outside of issues by a small team. This file is a user-facing summary of the changes for each version and any helpful guides for migrating between versions, highlighting breaking changes or different behaviors.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.6.0] - 2026-07-13

### Changed
- **virtual-network-peering**: Disabled AVM telemetry tracking by default. The telemetry deployment resource is now commented out. Set `enableTelemetry: true` to re-enable if needed.

### Removed
- Removed active telemetry beacons from virtual-network-peering module to reduce deployment clutter in the Azure Portal deployments list.

### Migration Guide
- No breaking changes. Existing deployments will function identically.
- If you relied on telemetry tracking for usage monitoring, comment the telemetry lines back in or contact your AVM maintainers.


## [0.1.1] - 2026-07-05[YYYY-MM-DD]

Initial Version.
