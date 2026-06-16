# Changelog

All notable changes to the **Microsoft Office for MacOS** repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### ✨ Added

- **Optimization Script**: Introduced `optimize_mac_office.sh` to safely and efficiently disable Microsoft Office telemetry and cloud features. It features structured logging, strict error handling, and `shellcheck` compliance.
- **Table of Contents**: Added a clean and structured Table of Contents to the `README.md` for better navigation.

### 📝 Changed

- **Documentation Overhaul**: Transformed the `README.md` to be more elegant, visually appealing, and informative. Added emojis, clear table formatting, and refined language, while preserving all original structures and instructions.
- **Uninstaller Alternatives**: Replaced the legacy CCleaner recommendation with modern, optimized Mac uninstaller alternatives (AppCleaner, Mole, Pearcleaner, and MacSai).
- **Best Practices**: Ensured all script additions follow professional coding standards and strict shell validation.

### 🔒 Security

- **Enhanced Privacy Handling**: Streamlined the telemetry and cloud-feature disabling logic into an executable, isolated bash script to prevent user error when directly modifying system `defaults`.

---

## [Historical]

### 🌟 Initial Setup & Data

- **Installer Listings**: Comprehensive lists of Office suite installers and serializers for multiple versions (2011 to 2024 LTSC).
- **Alternative Keys**: Provided fall-back VL keys for legacy Office 2011 users.
- **Troubleshooting Details**: Added reset and license removal tool references.
