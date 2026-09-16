class RtkMeter < Formula
  desc "macOS menu bar app showing rtk token-savings stats"
  homepage "https://github.com/christophecollet78/rtk-meter"
  # Prebuilt universal bundle: installing needs no Swift toolchain, and a formula
  # (unlike a cask) is not quarantined, so the ad-hoc signature is enough to launch.
  url "https://github.com/christophecollet78/rtk-meter/releases/download/v1.0.3/RTK-Meter-1.0.3-universal.zip"
  sha256 "c02624adb970b2aacc892a078748820d731f9c8333fff41765d35e4fdddd0736"
  version "1.0.3"
  license "MIT"
  head "https://github.com/christophecollet78/rtk-meter.git", branch: "main"

  depends_on macos: :ventura

  # `brew install --HEAD` compiles instead, which needs the Command Line Tools.
  head do
    depends_on xcode: :build
  end

  def install
    if build.head?
      ENV["VERSION"] = version.to_s
      system "./build.sh"
      prefix.install "build/RTK Meter.app"
    else
      prefix.install "RTK Meter.app"
    end

    (bin/"rtk-meter").write <<~SH
      #!/bin/bash
      exec open -a "#{opt_prefix}/RTK Meter.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Start it now, and on every login from the popover's gear menu:
        rtk-meter

      To keep it in Launchpad and the Applications folder:
        ln -sfn "#{opt_prefix}/RTK Meter.app" ~/Applications/"RTK Meter.app"

      The app reads statistics from the rtk CLI, which it expects on the PATH:
        brew install rtk-ai/tap/rtk
    EOS
  end

  test do
    # Drawing the popover would need the WindowServer, which Homebrew's test
    # sandbox denies; the app's own CI covers that with --render-preview.
    binary = prefix/"RTK Meter.app/Contents/MacOS/RTKMeter"
    assert_predicate binary, :executable?

    archs = shell_output("lipo -archs '#{binary}'")
    assert_match "arm64", archs
    assert_match "x86_64", archs

    plist = (prefix/"RTK Meter.app/Contents/Info.plist").read
    assert_match "LSUIElement", plist
  end
end
