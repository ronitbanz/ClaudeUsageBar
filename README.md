# ClaudeUsageBar
Mac app to see claude usage in your menu bar at all times for example:    $129.88 / $150.00 · 87% · Jun 1   No clicking required — it sits in the top-right corner of your screen next to the clock  like the battery on your mac.

---
 Before you start

 You need Xcode Command Line Tools (a free Apple developer toolkit). Check if you already have it:
 xcode-select -p
 If it prints a path, you’re good. If not, install it:
 xcode-select --install
 A popup will appear — click Install and wait for it to finish (~5 min).

 ---
 Install

 1. Download the ClaudeUsageBar.zip attached to this message and unzip it
 2. Open Terminal (press Cmd+Space, type Terminal, hit Enter)
 3. Type cd (with a space after), then drag the ClaudeUsageBar folder from Finder into the Terminal window — it fills in the path automatically. Press Enter.
 4. Run:
 bash install.sh
 5. You’ll see Claude: loading… appear in your menu bar
 6. Click it — a window opens showing claude.ai settings. Log in once with your Anthropic account.
 7. Within a few seconds the menu bar updates to show your live spend. Done.

 ---
 What it installs

 The script registers a macOS Launch Agent — a standard macOS mechanism (same as Dropbox, Spotify, etc.) that:
 - Starts the app automatically every time you log in
 - Restarts it automatically if it ever crashes

 It works by reading your claude.ai session cookie, exactly like your browser does. Nothing is sent anywhere else.

 ---
 To remove it completely

 In Terminal, navigate back to the folder and run:
 bash uninstall.sh
 This stops the app and unregisters it from startup. Note: killing it via Activity Monitor won’t stick — macOS will restart it. Use uninstall.sh to fully remove it.
