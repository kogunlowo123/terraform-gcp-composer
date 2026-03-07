# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Initial release of the Cloud Composer Terraform module.
- Support for Composer 2 and Composer 3 environments.
- Configurable Airflow image version and configuration overrides.
- Custom PyPI package installation.
- Environment variable management.
- Private IP environment support with VPC peering and Private Service Connect.
- IP allocation policy for GKE pod and service CIDRs.
- Maintenance window scheduling.
- Web server network access control with IP allowlisting.
- CMEK encryption support.
- Workloads configuration for scheduler, web server, worker, and triggerer.
- Master authorized networks configuration.
- Cloud Data Lineage integration.
- Environment sizing (small, medium, large).
- High resilience mode for multi-zone deployments.
- Comprehensive examples: basic, advanced, and complete.

## [0.1.0] - 2024-01-01

### Added

- Initial development version with core Composer environment functionality.
