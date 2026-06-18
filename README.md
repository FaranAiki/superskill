# 🌌 Superskill: Ultimate Cognitive & Brain Training Hub

A state-of-the-art Flutter cognitive training application designed with a sleek, vertical-first **Glossy Neon Blue** aesthetic. Challenge and measure your visual, audio, numerical, memory, spatial, and temporal capabilities with highly refined mini-games.

---

## 🎨 Design Theme & Experience
* **Glossy Neon Blue Aesthetic**: High-fidelity styling featuring deep slate-gray and dark backgrounds (`#030712`), glowing cyan and blue highlights (`#38BDF8`), translucent glassmorphism borders, and smooth animations.
* **Vertical / Mobile-First Layout**: Carefully structured layouts restricted to standard mobile dimensions on desktop and web, preventing visual stretch and layout overflows.
* **Advanced Customization**: Support for dark/light themes, custom typography (e.g., Inter, Roboto, Poppins, Orbitron), dynamic font scaling, and global scoreboard.
* **Multilingual Translation (i18n)**: Fully translated into five major languages:
  * 🇬🇧 English (English)
  * 🇮🇩 Indonesian (Bahasa Indonesia)
  * 🇨🇳 Mandarin (中文)
  * 🇯🇵 Japanese (日本語)
  * 🇷🇺 Russian (Русский)

---

## 🎮 Game Categories & Challenges

Superskill features 14 immersive mini-games categorized across 7 cognitive domains:

### 1. 👁️ Visual Games (Визуальные Игры / Game Visual)
* **Tebak HEX/RGB**: Identify the matching color block corresponding to the given hex code.
* **Tebak CMYK**: A professional-grade CMYK color match challenge.

### 2. 🎵 Audio Games (Аудио Игры / Game Audio)
* **Perfect Pitch (Абсолютный Слух)**: Train your ear by listening to notes and guessing the exact musical pitch.

### 3. 🧠 Brain Games (Игры для Мозга / Game Otak)
* **Stroop Reflex (Мозговой Рефлекс)**: Test your focus and reaction speed under conflicting cognitive interference (color vs. word text).
* **Reflex Tap (Быстрый Клик)**: Tap fast when the signal flashes to measure your reaction time in milliseconds.
* **Schulte Focus (Таблицы Шульте)**: Find and tap numbers in ascending order from a grid to test search speed and focus.

### 4. 🔢 Numerical Games (Числовые Игры / Game Angka)
* **Operator Rush (Оператор)**: Speed-solve basic arithmetic equations by inserting the correct operator.
* **Game 24 (Игра 24)**: Given four numbers, determine if they can mathematically be manipulated to equal exactly 24.
* **Speed Math (Быстрая Математика)**: Rapidly answer true/false math statements that scale in complexity as levels advance.

### 5. 🧠 Memory Games (Игры на Память / Game Memori)
* **Memory Sequence (Последовательность)**: Remember and replicate an expanding sequence of flashing grid squares.
* **Chimp Memory (Шимпанзе)**: Tap hidden tiles in consecutive numeric order, testing short-term visual memory inspired by cognitive primate studies.

### 6. 📐 Spatial Games (Пространственные Игры / Game Spasial)
* **Spatial IQ (Пространственный IQ)**: Mental rotation challenge utilizing 3D perspective projection and isometric cubes. Features a grid-toggle helper and rotation lock.
* **Maze Escape (Лабиринт)**: Guide your way out of custom procedural grid-based mazes.
* **Spatial Dice (Игра в Кости)**: Spatial logic matching dice faces where opposite sides always sum up to 7.

### 7. ⏱️ Temporal Control (Временной Контроль / Kontrol Temporal) `NEW!`
* **Time Estimator**: Estimate a target duration (e.g., 8.0 seconds). The timer vanishes after 3 seconds, requiring accurate internal timing.
* **Rhythm Sync**: Synchronize tapping to a given BPM tempo. Listen/watch the visual pulse for 3 beats, then tap accurately on beats 4 to 8.

---

## 📈 Scoring & High Score System
Every game connects to a localized global high-score system. 
For temporal challenges, scores are calculated using a precise mathematical penalty system based on error offset $d$:
* If the absolute difference $d > 1$: $\text{Penalty} = d^2$
* If the absolute difference $d < 1$: $\text{Penalty} = \sqrt{d}$
* The score scales up to a maximum of 1,000: $\text{Score} = \max(0, 1000 - (\text{Penalty} \times 200))$

---

## 🛠️ Getting Started & Build

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
