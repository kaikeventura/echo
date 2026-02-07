# Installation

## Prerequisites

*   **Linux OS** (Ubuntu, Fedora, Arch, etc.)
*   **Flutter SDK** installed ([Guide](https://docs.flutter.dev/get-started/install/linux))
*   **Build Tools**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`

## Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/echo.git
    cd echo
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate code (Riverpod & Isar):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run -d linux
    ```
