# ADN iOS — LevelPlay adapter podspecs

A private [CocoaPods specs](https://guides.cocoapods.org/making/private-cocoapods.html) repository for published versions of the LevelPlay mediation adapter for the ADN SDK.

## Layout

Podspecs live at:

`<PodName>/<Version>/<PodName>.podspec`

This repo currently ships **`VoodooISAdapter`**/**`VoodooIronSourceAdapter`** (binary hosted on ADN CDNs, with `VoodooAdn` and `IronSourceSDK` dependencies).

## Using it in a `Podfile`

Add this repo as a Git source:

```ruby
source 'git@github.com:VoodooADN/ios-levelplay-adapter-podspecs-dev.git'
# … other sources (CocoaPods CDN, etc.)

pod 'VoodooISAdapter', '4.2.3.16.1' # example: match your ADN SDK / release version
pod 'VoodooIronSourceAdapter', '5.0.0.0' # example: match the new Levellay adapter versions
```

## GitHub Actions

The **`Sync LevelPlay adapter`** workflow (`.github/workflows/sync-levelplay-adapter.yml`) runs **manually** (`workflow_dispatch`).

1. Fetches the **`IronSourceVoodooAdapter`** podspec from the CocoaPods trunk.
2. Generates **`VoodooIronSourceAdapter.podspec`** with the `IronSourceSDK` version from the workflow input (default: `9.3.0.0`).
3. Runs `pod spec lint`, then `add_podspec.sh`.
4. Commits and pushes when there are changes.

To run it: **Actions** → **Sync LevelPlay adapter** → **Run workflow** → optionally set **The exact version of 'IronSourceSDK' to use**.

---

Internal Voodoo ADN repository; do not publish these specs to the public CocoaPods trunk without product / legal sign-off.
