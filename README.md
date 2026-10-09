# bifrost-releases

Built releases of Bifrost, the Bridge app: the macOS shell (`Bridge.app.tar.gz`),
the app layer (`bifrost-app-<v>-macos-aarch64.tar.gz`), and beside each release a
[packslip](https://packslip.dev/) signed by the publishing workflow. The signed
release list is `.well-known/packslip.json` on this branch; the shell's updater
manifest is `.well-known/latest.json`. Source lives in a private repository.
