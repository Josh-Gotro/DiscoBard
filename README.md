# DiscoBard

DiscoBard is a Retail World of Warcraft addon focused on post-combat support review
for Augmentation Evoker in the Midnight era.

This version is intentionally retrospective. It captures your own Augmentation support
events during combat and shows a review window after the segment ends. It does not
recommend actions, rank targets, or provide live combat guidance.

## Current MVP

DiscoBard tracks:

- `Ebon Might` casts and target coverage
- `Prescience` casts and target coverage
- `Blistering Scales` casts and target coverage
- `Breath of Eons` casts
- a short per-segment timeline of tracked casts and aura events

It shows a post-combat review panel with:

- segment type and duration
- cast counts
- Ebon Might coverage by target
- Prescience coverage by target
- recent tracked timeline events

## Install

Copy the `DiscoBard` addon folder to:

`World of Warcraft\_retail_\Interface\AddOns\DiscoBard`

Confirm this file exists:

`World of Warcraft\_retail_\Interface\AddOns\DiscoBard\DiscoBard.toc`

## Slash Commands

- `/dbard`
- `/dbard show`
- `/dbard hide`
- `/dbard toggle`
- `/dbard clear`
- `/dbard lock`
- `/dbard unlock`
- `/dbard reset`
- `/dbard debug`

Alias:

- `/disco`

## First Test Pass

1. Log in on an Augmentation Evoker.
2. Enter combat and cast `Ebon Might`, `Prescience`, and `Blistering Scales`.
3. Leave combat.
4. Confirm the DiscoBard review window appears automatically.
5. Run `/dbard` to reopen it if needed.
6. Use `Prev` and `Next` after multiple segments to browse history.

## Architecture

- `Core.lua`
  Boot/init
- `Constants.lua`
  tracked spell IDs and UI defaults
- `Config.lua`
  SavedVariables
- `Segments.lua`
  segment lifecycle and history
- `CombatLog.lua`
  event routing
- `Trackers/Augmentation.lua`
  Aug-specific combat log tracking
- `Report.lua`
  segment summary formatting
- `UI.lua`
  post-combat review window
- `Commands.lua`
  slash commands

## Deliberate Non-Goals

DiscoBard does not currently do:

- live recommendations
- target ranking
- best-buff-target logic
- exact Augmentation contributed DPS attribution
- frame sorting or frame replacement

## Caveats

- This addon depends on the live combat log and stores its own summaries.
- It does not assume Blizzard exposes a full historical fight breakdown API after combat.
- Exact Augmentation added-damage attribution is out of scope for this MVP.
