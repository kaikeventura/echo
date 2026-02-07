# Installation

You can install Echo by downloading a pre-built version from our releases or by building from source.

## From Release (Recommended)

1.  Go to the [**Releases Page**](https://github.com/kaikeventura/echo/releases).
2.  Find the latest release and download the correct file for your operating system:
    *   **Windows**: `echo-vX.Y.Z-windows-x64.zip`
    *   **macOS**: `echo-vX.Y.Z-macos.zip`
    *   **Linux**: `echo-vX.Y.Z-linux-x64.tar.gz`

---

### Windows

1.  **Extract the `.zip` file.**
    You will get a folder with all the necessary files.
2.  **Run the application.**
    Inside the folder, double-click on `echo.exe`. You can create a shortcut to this file on your Desktop for easier access.

---

### macOS

1.  **Extract the `.zip` file.**
    This will typically create an `echo.app` bundle.
2.  **Move to Applications.**
    Drag the `echo.app` file into your `/Applications` folder.
3.  **Run the application.**
    You can now launch Echo from your Applications folder or Launchpad.

*(Note: On the first run, you may need to right-click the app and select "Open" if you see a security warning about the developer not being identified.)*

---

### Linux

1.  **Extract the `.tar.gz` archive.**
    ```bash
    mkdir echo && tar -xzvf echo-vX.Y.Z-linux-x64.tar.gz -C echo
    ```
2.  **Run the application.**
    ```bash
    cd echo
    ./echo
    ```

#### Adding to System Menu (Optional)

To make Echo appear in your system's application menu:

1.  **Move the application folder to `/opt`**:
    ```bash
    # Assuming you are inside the 'echo' directory
    sudo mv . /opt/echo
    ```
2.  **Create a desktop entry**:
    Create a file at `~/.local/share/applications/echo.desktop` with the following content:
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
    ```bash
    update-desktop-database ~/.local/share/applications/
    ```

---

## From Source

If you prefer to build the application yourself:

### Prerequisites

*   **Flutter SDK** installed ([Guide](https://docs.flutter.dev/get-started/install))
*   **Platform-specific build tools** (e.g., Visual Studio for Windows, Xcode for macOS, `clang` and `gtk` for Linux).

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
3.  **Run the app:**
    ```bash
    flutter run
    ```
