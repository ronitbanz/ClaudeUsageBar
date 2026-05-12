import AppKit
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {

    var statusItem: NSStatusItem!
    var webView: WKWebView!
    var timer: Timer?
    var popover: NSPopover!
    var extractAttempts = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupWebView()
        setupStatusItem()
        setupPopover()
        loadUsagePage()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.loadUsagePage()
        }
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 620, height: 520))
        webView.navigationDelegate = self
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "Claude: loading…"
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        let vc = NSViewController()
        vc.view = webView
        popover = NSPopover()
        popover.contentViewController = vc
        popover.contentSize = NSSize(width: 620, height: 520)
        popover.behavior = .transient
    }

    private func loadUsagePage() {
        extractAttempts = 0
        let url = URL(string: "https://claude.ai/settings/usage")!
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url?.absoluteString ?? ""
        if url.contains("/settings/usage") {
            extractAttempts = 0
            extractUsage()
        } else if !url.isEmpty && !url.contains("login") && !url.contains("claude.ai/?") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadUsagePage()
            }
        }
    }

    private func extractUsage() {
        let js = """
        (function() {
            const text = document.body.innerText || '';
            const m = text.match(/\\$([\\d,]+\\.\\d{2})\\s+of\\s+\\$([\\d,]+\\.\\d{2})/);
            const r = text.match(/Resets\\s+([A-Za-z]+\\s+\\d+)/);
            const p = text.match(/(\\d+)%\\s+used/);
            if (m) return m[1] + '|' + m[2] + '|' + (r ? r[1] : '') + '|' + (p ? p[1] : '');
            return '';
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let str = result as? String, !str.isEmpty {
                    let parts = str.split(separator: "|")
                    if parts.count >= 2 {
                        let reset = parts.count >= 3 && !parts[2].isEmpty ? " · \(parts[2])" : ""
                        let pct   = parts.count >= 4 && !parts[3].isEmpty ? " · \(parts[3])%" : ""
                        self.statusItem.button?.title = "$\(parts[0]) / $\(parts[1])\(pct)\(reset)"
                        return
                    }
                }
                // Data not rendered yet — retry up to 20 times
                if self.extractAttempts < 20 {
                    self.extractAttempts += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.extractUsage()
                    }
                } else {
                    self.statusItem.button?.title = "Claude: login ↗"
                }
            }
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            loadUsagePage()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
