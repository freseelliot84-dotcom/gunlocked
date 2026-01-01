Quick Start – Quest Tool
1. Install Homebrew (macOS only)

If you don’t have Homebrew, run:

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

2. Install ADB
brew install android-platform-tools


Check that ADB works:

adb version

3. Download Quest Tool
git clone https://github.com/YourUsername/quest-tool.git
cd quest-tool

4. Make the script executable
chmod +x quest-tool.sh

5. Run the tool
./quest-tool.sh

6. Connect Quest wirelessly (optional)

Connect your Quest via USB at least once.

Choose option 3 in the menu. The tool will automatically detect your Quest IP and enable Wi-Fi ADB.

7. Set FPS / Swap Interval

Choose option 1 in the menu.

Pick a preset or custom FPS (1–200) and a swap interval (0–5).

Confirm to apply.

8. Check current settings

Choose option 2 to see the current refresh rate and swap interval.
