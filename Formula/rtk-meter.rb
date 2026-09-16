class RtkMeter < Formula
  desc "macOS menu bar app showing rtk token-savings stats"
  homepage "https://github.com/christophecollet78/rtk-meter"
  url "https://github.com/christophecollet78/rtk-meter/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "2d8f95597bfe7125d6c464c2a07be04c9f95df60277a017fd5ccbdb8fa630bdb"
  license "MIT"
  head "https://github.com/christophecollet78/rtk-meter.git", branch: "main"

  depends_on xcode: ["14.0", :build]
  depends_on macos: :ventura

  def install
    ENV["VERSION"] = version.to_s
    system "./build.sh"
    prefix.install "build/RTK Meter.app"

    # Building from source means the bundle is never quarantined, so it can be
    # launched straight from the Cellar.
    (bin/"rtk-meter").write <<~SH
      #!/bin/bash
      exec open -a "#{opt_prefix}/RTK Meter.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Start it now, and on every login via the popover's gear menu:
        rtk-meter

      To keep it in Launchpad and the Applications folder:
        ln -sfn "#{opt_prefix}/RTK Meter.app" ~/Applications/"RTK Meter.app"

      The app reads statistics from the rtk CLI, which it expects on the PATH:
        brew install rtk-ai/tap/rtk
    EOS
  end

  test do
    # The binary doubles as its own screenshot tool, so the UI can be exercised
    # headlessly: rendering a PNG proves the bundle launches and draws.
    system "#{prefix}/RTK Meter.app/Contents/MacOS/RTKMeter", "--render-preview",
           testpath/"popover.png"
    assert_predicate testpath/"popover.png", :exist?
  end
end
