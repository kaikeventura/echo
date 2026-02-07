# Installation

## From Release (Recommended)

1.  Go to the [Releases](https://github.com/kaikeventura/echo/releases) page.
2.  Download the latest `echo-linux-x64.tar.gz`.
3.  Extract the archive into a folder. For example:
    ```bash
    mkdir echo_app
    tar -xzvf echo-linux-x64.tar.gz -C echo_app
    ```
4.  Run the application from inside the folder:
    ```bash
    cd echo_app
    ./echo
    ```

### Adding to System Menu (Optional)

To make Echo appear in your application menu on Linux:

1.  **Move the application folder to `/opt`**:
    This is a standard location for optional software.
    ```bash
    # Assuming you extracted the files into 'echo_app'
    sudo mv echo /opt/echo
    ```

2.  **Create a desktop entry**:
    Create a file named `echo.desktop` in `~/.local/share/applications/` for the current user.
    ```bash
    nano ~/.local/share/applications/echo.desktop
    ```

    Paste the following content. The `icon.png` file is already included in the release.
    ```ini
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=Echo
    Comment=Modern API Client
    Exec=/opt/echo/echo
    Icon=/opt/echo/icon.png
    Terminal=false
    Categories=Development;Network;
    ```

3.  **Update the desktop database**:
    This makes the system recognize the new application.
    ```bash
    update-desktop-database ~/.local/share/applications/
    ```
    You should now find "Echo" in your application menu.

## From Source

### Prerequisites

*   **Linux OS** (Ubuntu, Fedora, Arch, etc.)
*   **Flutter SDK** installed ([Guide](https://docs.flutter.dev/get-started/install/linux))
*   **Build Tools**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`

### Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/kaikeventura/echo.git
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
