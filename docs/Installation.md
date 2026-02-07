# Installation

## From Release (Recommended)

1.  **Download**
    Go to the [Releases page](https://github.com/kaikeventura/echo/releases) and download the latest `echo-linux-x64.tar.gz` file.

2.  **Extract**
    Create a directory named `echo` and extract the archive into it.
    ```bash
    mkdir echo
    tar -xzvf echo-linux-x64.tar.gz -C echo
    ```

3.  **Run**
    You can now run the application directly from this folder.
    ```bash
    cd echo
    ./echo
    ```

### Adding to System Menu (Optional)

To make Echo appear in your system's application menu, follow these steps:

1.  **Move the application folder**
    Move the `echo` folder you created to `/opt/`, a standard directory for optional software.
    ```bash
    # This command moves the entire 'echo' folder to /opt/
    sudo mv ../echo /opt/
    ```
    *(Note: Run this command from within the `echo` directory you entered in the previous step, or adjust the path accordingly.)*

2.  **Create a Desktop Entry**
    Create a file named `echo.desktop` in `~/.local/share/applications/`.
    ```bash
    nano ~/.local/share/applications/echo.desktop
    ```

    Paste the following content. The `icon.png` is already included.
    ```ini
    [Desktop Entry]
    Version=0.1.0
    Type=Application
    Name=Echo
    Comment=Modern API Client
    Exec=/opt/echo/echo
    Icon=/opt/echo/icon.png
    Terminal=false
    Categories=Development;Network;
    ```

3.  **Update the Desktop Database**
    This command registers the new application with your system.
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
