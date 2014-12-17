Pod::Spec.new do |s|
  s.name         = "ApplePayStubs"
  s.version      = "0.1.2"
  s.summary      = "Test your Apple Pay integration without Apple Pay"
  s.description  = <<-DESC
                  ApplePayStubs lets you test your Apple Pay integration without needing an iPhone 6 and the as-yet-unreleased Apple Pay SDK.
                   DESC
  s.homepage     = "https://github.com/stripe/ApplePayStubs"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author       = { "Stripe" => "support+github@stripe.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/stripe/ApplePayStubs.git", :tag => "v#{s.version}" }
  s.source_files = "Classes", "Classes/**/*.{h,m}"
  s.resources    = "Classes/**/*.xib", "Classes/apple-pay-mini@2x.png"
  s.exclude_files   = "Classes/Exclude"
  s.weak_framework  = "PassKit"
  s.requires_arc = true
end
