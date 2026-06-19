# Superskill: Ultimate Cognitive & Brain Training Hub

Superskill is a professional, high-fidelity Flutter cognitive training application designed with a sleek, vertical-first Dark/Neon-Blue aesthetic. The application allows users to challenge and measure their visual, audio, numerical, memory, spatial, and temporal capabilities with 18 highly refined mini-games.

---

## Design Theme & Core Features
* **Neon Blue Design System**: High-fidelity styling featuring deep slate-gray backgrounds (`#030712`), glowing cyan/blue highlights (`#38BDF8`), glassmorphic containers, and responsive micro-animations.
* **Vertical / Mobile-First Layout**: Carefully structured layouts restricted to standard mobile dimensions (maximum width of 400-500px) on desktop and web, preventing visual stretching and layout overflows.
* **Localization (i18n)**: Out-of-the-box support for five languages with fallback templates:
  * English (EN)
  * Indonesian (ID)
  * Japanese (JA)
  * Russian (RU)
  * Chinese (ZH)
* **High Score Tracking**: Local persistence of user statistics and levels achieved across different games.

---

## Game Categories & Challenges

Superskill features 18 immersive mini-games categorized across 7 cognitive domains:

### 1. Visual Games
* **Guess HEX/RGB**: Identify the matching color block corresponding to the given hexadecimal color code.
* **Guess CMYK**: A professional-grade CMYK color match challenge using slider adjustments.
* **Gradient Sort**: Drag and drop color blocks to arrange them into a smooth, seamless gradient transition between two locked endpoints.
* **Odd One Out**: Find the single grid tile that has a slightly different RGB color before the countdown timer runs out.

### 2. Audio Games
* **Perfect Pitch**: Train note identification by listening to musical pitches and guessing the correct key.

### 3. Brain Games
* **Stroop Reflex**: Test cognitive focus and reaction speed under conflicting cognitive interference (color name word text vs. actual color ink).
* **Reflex Tap**: Tap as fast as possible when the visual signal flashes to measure reaction time in milliseconds.
* **Schulte Focus**: Find and tap numbers in ascending order from a randomized grid to test search speed and focus.

### 4. Numerical Games
* **Operator Rush**: Speed-solve arithmetic equations by selecting the correct mathematical operator.
* **Game 24**: Given four numbers, determine if they can be mathematically manipulated using basic arithmetic to equal exactly 24.
* **Speed Math**: Rapidly answer true/false math statements that scale in complexity as levels advance.

### 5. Memory Games
* **Memory Sequence**: Replicate an expanding sequence of flashing grid squares.
* **Chimp Memory**: Memorize consecutive numbers and tap their hidden tiles in order, inspired by primate short-term visual memory studies.
* **Color Memory**: Memorize a sequence of target colors and recall them by choosing from options containing highly similar hues.

### 6. Spatial Games
* **Spatial IQ**: Mental rotation challenge using 3D perspective projection and isometric cubes, featuring a grid outline helper and rotation lock.
* **Maze Escape**: Navigate and guide your way out of procedurally generated grid-based mazes.
* **Spatial Dice**: Match spatial dice faces where opposite sides always sum up to 7.
* **Shadow Matching**: Match a rotating 3D block figure to its correct 2D shadow projection (Top, Front, Side) with interactive manual drag controls and coordinate axes indicators.

### 7. Temporal Control
* **Time Estimator**: Estimate a target duration. The visual clock vanishes after 3 seconds, requiring accurate internal timing.
* **Rhythm Sync**: Synchronize tapping to a given BPM tempo. Listen to the visual pulse for 3 beats, then tap accurately on beats 4 to 8.

---

## Scoring & High Score System
Every game integrates with a localized high-score system. For temporal challenges, scores are calculated using a precise mathematical penalty system based on error offset $d$:
* If the absolute difference $d > 1$: $\text{Penalty} = d^2$
* If the absolute difference $d < 1$: $\text{Penalty} = \sqrt{d}$
* The score scales up to a maximum of 1,000: $\text{Score} = \max(0, 1000 - (\text{Penalty} \times 200))$

---

## Getting Started & Build

### Prerequisites
* Flutter SDK (3.22.x or newer recommended)
* Dart SDK

### Installation & Run
1. Clone this repository:
   ```bash
   git clone https://github.com/faranaiki/superskill.git
   cd superskill
   ```
2. Retrieve packages and generate localizations:
   ```bash
   flutter pub get
   flutter gen-l10n
   ```
3. Run the project:
   ```bash
   flutter run
   ```

### Building for Android (APK)
To export the debug build to the git-ignored output folder:
```bash
flutter build apk --debug
```
The resulting package will be generated at `build/app/outputs/flutter-apk/app-debug.apk`.
