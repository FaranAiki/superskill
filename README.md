# Superskill: Cognitive Training Platform

Superskill is a high-fidelity cognitive training application built using Flutter. Designed with a professional, mobile-first, vertical-constrained layout, it features a modern slate-gray and neon-blue aesthetic. The platform supports five languages and local high score tracking across 27 distinct mini-games.

---

## Product Requirements Document (PRD)

### 1. Design System & User Interface
* **Aesthetic**: Deep slate-gray background (HEX 030712), vibrant cyan/blue neon accents (HEX 38BDF8), glassmorphic border elements, and responsive micro-animations for interactive feedback.
* **Layout Constraints**: The layout enforces a strict mobile-first architecture. All game screens are wrapped with maximum width constraints (400-500px), centered, and embedded in scrollable containers to ensure visual consistency and prevent layout scaling issues on desktop and web viewports.
* **Text Case Guidelines**: All buttons, labels, and headers must consistently use Capital Case or Title Case to maintain a premium feel. Full uppercase typography is avoided.

### 2. Core Functional Requirements
* **Multi-Language Support (i18n)**: Native localization using Flutter ARB files for:
  * English (EN)
  * Indonesian (ID)
  * Japanese (JA)
  * Russian (RU)
  * Chinese (ZH)
  * All localized strings are accessed package-wide using local localizations imports rather than default flutter localizations wrappers.
* **Local Persistence (High Score Service)**: Scores and levels achieved are persisted locally to enable tracking progress per game.
* **Error Tolerant Gameplay (Self-Healing / Safety limits)**: All mathematical and temporal operations handle large scale inputs safely using BigInt or constraint clipping to avoid execution crashes.

---

## Game Catalog

The application includes 27 mini-games distributed across 7 cognitive categories:

### 1. Visual Games
* **Guess HEX/RGB**: Identify the color block that matches the provided hexadecimal color code.
* **Guess CMYK**: Match colors using manual CMYK slider values.
* **Gradient Sort**: Sort color blocks to create a perfect gradient between two locked end-hues.
* **Odd One Out**: Find the single tile in a grid that has a slightly different shade.

### 2. Audio Games
* **Perfect Pitch**: Guess note keys after listening to musical pitches.

### 3. Brain Games
* **Stroop Reflex**: Choose the correct color under conflicting text and ink conditions.
* **Reflex Tap**: Measure reaction speed by tapping as soon as the screen flashes.
* **Schulte Focus**: Find and tap numbers in ascending order from a randomized grid.
* **N-Back**: Recall the grid cell position shown N steps back in a sequence.
* **Typing Sprint**: Type random words quickly and accurately before time runs out.

### 4. Numerical Games
* **Operator Rush**: Solve arithmetic equations by choosing the correct mathematical operator.
* **Game 24**: Determine if four numbers can be combined using arithmetic to total 24.
* **Speed Math**: Quickly evaluate if mathematical equations are true or false.
* **Base Decoder**: Convert numeric values between different base systems (binary, octal, hexadecimal) and decimal.
* **Prime Factor**: Perform prime factorization of a large number using BigInt arithmetic and sliding prime selection configuration.

### 5. Memory Games
* **Memory Sequence**: Replicate an increasing sequence of blinking grid squares.
* **Chimp Memory**: Memorize grid numbers, then tap hidden tiles in ascending order.
* **Color Memory**: Memorize a color and identify it from options with highly similar hues.
* **Word Memory**: Memorize a list of words, then select them from a list of distractors.

### 6. Spatial Games
* **Spatial IQ**: Rotate a 3D isometric cube structure to match a target grid shape.
* **Maze Escape**: Navigate out of a procedurally generated maze.
* **Spatial Dice**: Identify correct spatial cube orientations where opposite sides sum to 7.
* **Shadow Matching**: Match a rotating 3D block figure to its correct orthogonal shadow projection.
* **Pattern Fold**: Determine which 3D cube model matches the unfolded 2D cube net.

### 7. Temporal Games
* **Time Estimator**: Estimate a target duration after the visual countdown timer disappears.
* **Rhythm Sync**: Tap a sequence in sync with a specified BPM tempo.
* **Speed Count**: Rapidly count how many dots flashed on the screen during a short window.

---

## Scoring Formulas

Scoring calculations use localized, deterministic algorithms. For games measuring temporal precision, scores are computed using an error offset (d):
* For error offset (d) greater than 1: Penalty = d * d
* For error offset (d) less than or equal to 1: Penalty = square root of d
* Final Score = max(0, 1000 - (Penalty * 200))

---

## Build and Run Instructions

### Prerequisites
* Flutter SDK (3.22.x or newer)
* Dart SDK

### Running Locally
1. Retrieve dependencies and generate localizations:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
2. Launch the application:
   ```bash
   flutter run
   ```

### Production and Debug Build
* Build debug Android APK:
  ```bash
  flutter build apk --debug
  ```
  The build package is located at `build/app/outputs/flutter-apk/app-debug.apk`.
