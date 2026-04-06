# DiscoBard

DiscoBard is a Retail World of Warcraft addon that replaces the default 5-man party
frames with a compact custom layout focused on clarity and presentation.

This is an MVP scaffold intended for safe UI customization under the Midnight addon
restrictions. It does not provide recommendations, priority suggestions, rotation
guidance, or automation beyond normal secure frame interaction.

## Install

1. Copy the `DiscoBard` folder to your Windows WoW AddOns directory:

   `World of Warcraft\_retail_\Interface\AddOns\DiscoBard`

2. Confirm this file exists:

   `World of Warcraft\_retail_\Interface\AddOns\DiscoBard\DiscoBard.toc`

3. Start WoW.

4. At character select, click `AddOns` and make sure `DiscoBard` is enabled.

5. If needed, enable `Load out of date AddOns`.

## Slash Commands

- `/dbard unlock`
- `/dbard lock`
- `/dbard test`
- `/dbard reset`
- `/dbard size <width> <height>`
- `/dbard spacing <value>`
- `/dbard font <size>`
- `/dbard orientation <vertical|horizontal>`

Alias:

- `/disco`

Examples:

- `/dbard test`
- `/dbard unlock`
- `/dbard size 220 36`
- `/dbard spacing 8`
- `/dbard font 12`
- `/dbard orientation vertical`

## First Test Pass

1. Log in and run `/dbard test`.
2. Confirm five fake unit frames appear.
3. Run `/dbard unlock` and move the frame.
4. Run `/dbard lock`.
5. Run `/reload` and confirm the position persists.
6. Run `/dbard test` again to leave test mode.
7. Join a party and confirm live units appear.

## Current MVP Features

- Movable root frame container
- One custom frame per visible party unit
- Secure unit buttons with click-to-target
- Name and health display
- Dead, ghost, and offline state handling
- Role icon
- Range fade
- Aggro border
- Target highlight
- One dispellable debuff slot
- One tracked debuff slot
- One defensive buff slot
- Ready-check indicator
- SavedVariables-backed layout settings

## Current Caveats

- The `.toc` interface number may need to be updated for the exact Midnight build.
- Built-in Blizzard frame hiding is best-effort and may need adjustment if Blizzard
  changes frame names.
- Aura access assumptions are isolated in `Auras.lua` and should be verified against
  the current Retail API if behavior changes after a patch.
