# bifrost-releases

Built releases of Bifrost, the Bridge app. The source repository is private;
this one holds only what ships and signs it. Nothing here needs a token to
download.

## Install on a Mac (Apple silicon, macOS 15+)

1. Download `Bridge.app.tar.gz` from the
   [latest release](https://github.com/jgeschwendt/bifrost-releases/releases/latest).
2. Untar it (double-click, or `tar -xzf Bridge.app.tar.gz`) and drag
   `Bridge.app` to Applications.
3. Open it. It is not notarized, so macOS blocks the first launch of a
   downloaded copy: System Settings → Privacy & Security → Open Anyway (or
   `xattr -dr com.apple.quarantine /Applications/Bridge.app` first).

The shell then installs the Erlang runtime and the app layer itself and keeps
both, and itself, up to date.

## What a release carries

| asset | what |
| --- | --- |
| `bifrost-app-<v>-macos-aarch64.tar.gz` | the app layer, a `mix release` without ERTS |
| `Bridge.app.tar.gz` | the macOS shell, a tauri-plugin-updater bundle |
| `Bridge.app.tar.gz.sig` | its minisign signature |
| `release.toml` | the [packslip](https://packslip.dev/) manifest |
| `packslip.sigstore.json` | the signed manifest of both tarballs |

The private repository's release workflow builds the first four and creates
the release here. [`sign.yml`](.github/workflows/sign.yml) then signs the
packslip keylessly as `github.com/jgeschwendt/bifrost-releases` (the project
is its own signer; the shell pins this repository's ID, `1412423036`) and
re-signs, on `main`:

- `.well-known/packslip.json` — the signed release list (the shell reads it
  from raw.githubusercontent.com), valid 30 days, re-signed after every
  release, weekly, on a withdrawal and on `workflow_dispatch`.
- `.well-known/latest.json` — the shell's updater manifest, pointing at
  `https://github.com/jgeschwendt/bifrost-releases/releases/download/v<v>/Bridge.app.tar.gz`.

`workflow_dispatch` with `tag: v<v>` re-signs that release's packslip first;
without a tag it re-signs the list only. Keep immutable releases off: the
packslip is uploaded to a release that is already published. Never delete
and recreate this repository: the shell's pin names its ID.

## Withdraw a release

Add a `TAG=REASON` line to `.github/packslip/yanked` and push to `main`:

```
v0.1.2=crashes on launch
```

The push re-signs the list with that release yanked; shells never select it
again and `latest.json` falls back to the highest release still standing.
Keep the line, the release and its packslip for as long as the withdrawal
should hold. A shell already on the withdrawn version is not rolled back; fix
forward with a higher version.
