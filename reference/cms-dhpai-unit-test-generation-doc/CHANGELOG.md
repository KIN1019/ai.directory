# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-08-13

### Added

- Add updates to `unit-test.instructions.md` for improved instruction clarity
  - Add Primary objective: controllers & services first
  - Add Never remove code to fix compilation errors
  - Add Coverage standard use Jacoco instruction
  - Add Assume the existing codebase is correct, not fix the application code
- Recommend setup in `README.md`
  - Enable auto-approval `chat.tools.autoApprove`
  - GPT-4.1 DHP booster setting reference link

### Changed

- Expanded and clarified documentation in `README.md` for Copilot unit test generation workflow
  - Recommend use Claude Sonnet 4 as the LLM model

### Fixed

- N/A

### Removed

- N/A

---

## Commit History

### 1.1.0

- `5fe0848` - Update GPT-4.1 reference link in README.md (2025-08-13)
- `18457b0` - Update README.md (2025-08-12)
- `7869e42` - Update README.md (2025-08-11)
- `b83a594` - Update README.md (2025-08-08)
- `7c8912e` - Update README.md (2025-08-08)
- `4586be4` - Update README.md (2025-08-08)
- `e3342a0` - Update unit-test.instructions.md (2025-08-08)
- `0e16e9a` - Update README.md (2025-08-07)
- `2b54560` - Update README.md (2025-08-07)
- `c083607` - Update README.md (2025-08-07)
- `51ac7b3` - Update README.md (2025-08-07)

---

## [1.0.0] - 2025-07-28

### Added

- Comprehensive unit test generation instructions for Spring Boot applications
- Solution for Copilot iteration issue in unit test generation guide
- Instructions for configuring Copilot with a direct link to the instruction file
- Verification requirements section to README

### Changed

- Refined README formatting and improved clarity in unit test generation instructions
- Updated README.md with additional guidance and structure

### Fixed

- N/A

### Removed

- Unnecessary content and image placeholder from unit test generation guide

---

## Commit History

### 1.0.0

- `be0c8ea` - Update README.md (2025-07-24)
- `2366391` - Add verification requirements section to README (2025-07-24)
- `84beea1` - Refine README formatting and improve clarity in unit test generation instructions (2025-07-24)
- `a47f3a8` - Add instructions for configuring Copilot with a direct link to the instruction file (2025-07-23)
- `aa1a2fa` - Remove unnecessary content (2025-07-23)
- `6a062fd` - Add solution for Copilot iteration issue in unit test generation guide (2025-07-23)
- `5630ca2` - Remove unnecessary image placeholder from unit test generation guide (2025-07-23)
- `546cd2a` - Add comprehensive unit test generation instructions for Spring Boot applications (2025-07-23)
- `d0b2158` - Initial commit (2025-07-23)

---

## Notes

This changelog documents the evolution of the CMS DHPAI Copilot Unit Test Generation Template, which provides a milestone-driven framework for generating high-quality unit tests for Spring Boot applications using GitHub Copilot Chat. The template emphasizes automated, iterative test generation, comprehensive documentation, and best practices for coverage and maintainability.

For more information about the workflow, configuration, and features, see `README.md` and `.github/instructions/unit-test.instructions.md`.
