# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive code quality tools (Ruff, mypy, bandit)
- Pre-commit hooks for automated code quality checks
- Test suite with pytest and coverage reporting
- CI/CD workflow for automated testing and linting
- CONTRIBUTING.md with detailed contribution guidelines
- CODE_OF_CONDUCT.md for community standards
- Issue and PR templates for better collaboration
- CHANGELOG.md for tracking project changes

## [0.1.7] - 2024-01-XX

### Added
- Initial release of One Click DRF
- Django REST Framework project scaffolding
- Docker support with multi-stage builds
- CI/CD with GitHub Actions
- Infrastructure as Code (Terraform & Ansible)
- Observability with Prometheus
- Automatic dependency management with uv
- Git integration with automatic GitHub push
- Interactive CLI with rich prompts
- Production-ready settings and environment configuration

### Features
- `ocd init` command to bootstrap projects
- `--docker` flag for Docker support
- `--ci-cd` flag for GitHub Actions
- `--iac` flag for Terraform/Ansible
- `--observability` flag for Prometheus
- `--all` flag to enable all features
- Global configuration storage for GitHub/DockerHub usernames
- Automatic superuser creation
- Django app scaffolding

[Unreleased]: https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/compare/v0.1.7...HEAD
[0.1.7]: https://github.com/shemanto27/One-Click-Production-Ready-Django-Backend-Setup/releases/tag/v0.1.7
