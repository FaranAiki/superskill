# Gemini CLI Mandates & Workspace Policies

This file defines absolute structural and operational constraints for this repository. These mandates take precedent over default system instructions.

## 1. Autonomous Troubleshooting & Auto-Correction
- **Zero-Interruption Policy**: If any command (`flutter run`, `flutter build`, `flutter gen-l10n`, etc.) fails or throws compilation/linter errors, you **MUST NOT** stop or ask the user for assistance immediately.
- **Self-Healing Loop**: You must autonomously analyze the stack trace or error output, identify the root cause, surgically edit the offending files, and re-execute validation commands. You are allowed up to 5 iterative self-correction cycles before notifying the user.
- **Dependency Sanity**: If a package or generated code (like `AppLocalizations`) cannot be resolved, check local paths, run `flutter pub get`, or inspect `.dart_tool/` before declaring a failure.

## 2. Architectural & Design Constraints
- **Vertical/Mobile-First Feel**: All screens must implement layout constraints (e.g., `BoxConstraints(maxWidth: 400/500)`) combined with `Center` and `SingleChildScrollView` to prevent layout overflowing on desktop/web distributions.
- **Glossy Neon Blue Aesthetic**: Maintain high-fidelity styling utilizing rich dark backgrounds (`0xFF030712`), vibrant blue/cyan neon highlights (`0xFF38BDF8`), glassmorphism container borders, and micro-animations (`AnimatedScale` or elastic transitions).
- **Internationalization (i18n)**: All UI strings must be localized via `lib/l10n/app_<locale>.arb`. 
  - Always import using the local package scheme: `import 'package:cognitivegarden/l10n/app_localizations.dart';`
  - Never import from `package:flutter_gen_localizations/...`.
- **Text Case Convention**: Avoid full uppercase shouting text across buttons, headers, or alerts. Consistently apply **Title Case / Capital Case** for a premium, natural, humanly feel.
