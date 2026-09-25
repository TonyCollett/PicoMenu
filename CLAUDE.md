# PicoMenu

World of Warcraft (retail) addon: one small button on the main action bar that opens a
compact menu of every game panel, so Blizzard's micro menu bar can be hidden. Originally
extracted from nMainBar (Neal, ballagarba).

- GitHub: https://github.com/TonyCollett/PicoMenu (`main` is the only branch)
- CurseForge: https://www.curseforge.com/wow/addons/picomenu, project ID `1711398`,
  author dashboard https://authors.curseforge.com/#/projects/1711398/files
  (category Action Bars, MIT license, 3rd-party distribution allowed)
- The repo lives directly in the game's AddOns folder, so edits are live after `/reload`.

## Files

- `PicoMenu.toc`: `## Interface` must match the live client (`120100` = 12.1.0; check
  `.build.info` in the WoW root for the installed version). `## Version` stays
  `@project-version@`; the packager fills it in from the git tag.
- `PicoMenu.xml`: load order, `config.lua` then `PicoMenu.lua`.
- `config.lua`: `PicoMenuDB` defaults (`showPicomenu`, `showMicromenu`, `menuScale`).
- `PicoMenu.lua`: menu definition (`menuList`), menu building, button, alerts, `/pico`.
- `Media/picomenu/`: the button textures. Everything else in `Media/` was removed as unused.

## Gotchas

- **Taint.** Menu callbacks run as addon (insecure) code. Anything they load or show is
  tainted, which later gets Blizzard's protected calls blocked and blamed on PicoMenu
  (`ADDON_ACTION_BLOCKED`). Never be the first to load a Blizzard load-on-demand addon
  that owns secure frames: the Raid entry opens Social until `Blizzard_RaidUI` is loaded.
  Grey out (`disabled = IsBlockedInCombat`) and guard entries that can't open in combat.
- `SafeCall` wraps `securecallfunction`. It stops taint spreading back to the caller but
  does **not** make the call secure.
- **SavedVariables load after the addon's files run** and replace `PicoMenuDB` wholesale,
  so `config.lua` re-applies defaults on `ADDON_LOADED`. Add new settings to `defaults`.
- **Menu API** (`MenuUtil.CreateContextMenu`, Blizzard_Menu, not UIDropDownMenu):
  - Old dropdown fields like `fontObject` are ignored; don't add them back.
  - Menu size is a scale applied per menu frame through `AddInitializer(ApplyMenuScale)`,
    so submenus scale too. Every new element type must get that initializer.
  - `CreateContextMenu` pins the menu to the cursor; `OpenPicoMenu` calls
    `ClearAllPoints()` before anchoring the menu's BOTTOMLEFT to the button's TOPRIGHT.
- The queue eye (`QueueStatusButton`) is reparented under the button when the micro menu
  is hidden; see `UpdateQueueEyePosition`.

## Checking changes

- Syntax: `luac -p PicoMenu.lua config.lua`
- In game: `/reload`, then use the button. BugGrabber/BugSack catch errors and taint.
- `/pico` toggles the button, `/pico scale 50-200` sets the menu size, `/pico alerts`
  lists alert state.

## Releasing

Releases are built by the BigWigs packager (`.github/workflows/release.yml`, `.pkgmeta`).
Pushing a tag builds `PicoMenu-<tag>.zip`, creates a GitHub release with a changelog of
commits since the previous tag, and uploads to CurseForge (needs the `CF_API_KEY` repo
secret, already set, and `## X-Curse-Project-ID` in the TOC).

```bash
git tag -a 12.1.2 -m "PicoMenu 12.1.2"
git push origin 12.1.2
```

- Tags are plain version numbers (`12.1`, `12.1.1`); don't move or reuse a published tag.
- Dotfiles and anything listed under `ignore` in `.pkgmeta` are left out of the zip.
- Watch the build with `gh run list -R TonyCollett/PicoMenu`.
- The first CurseForge file (12.1.1) was submitted for moderation on 2026-09-25; the
  project isn't public until a moderator approves it.

## Open items

- No `LICENSE` file yet, though CurseForge lists MIT. Check nMainBar's license first,
  then add one crediting both.
