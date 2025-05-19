# OlympusIDE Builder

This is a fork of VSCodium, which has a nice build pipeline that we're using for OlympusIDE. Big thanks to the Void team for inspiring this.

The purpose of this repo is to run [Github Actions](https://github.com/voideditor/void-builder/actions). These actions build all the Void assets (.dmg, .zip, etc), store them on a release in [`voideditor/binaries`](https://github.com/voideditor/binaries/releases), and then set the latest version in [`olympuside/versions`](https://github.com/voideditor/versions) so the versions can be tracked for updating in the Void app.

## Notes

- See `stable-macos.sh` for one of the main Actions with some comments added by the OlympusOS team.

- VSCodium comes with `.patch` files, including relevant ones to auto-updating, which are being applied when we build OlympusIDE.

- For a list of all the places Void edited in this repo, search "Olympus" and "olympuside".

- We deleted some unused workflows (insider-* and stable-spearhead).
