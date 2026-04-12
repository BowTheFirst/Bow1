# Testing Neon Abyss - Terminal Corruption

## Overview
Single-file HTML5 Canvas game (`index.html`). No backend, no build step. Open directly in Chrome via `file:///` protocol.

## How to Launch
```bash
google-chrome "file:///home/ubuntu/repos/Bow1/index.html"
```

## Dev Console Access
1. Start any game mode (Endless Mode or Stage Select)
2. Click **PAUSE** button (top center)
3. Click **DEV CONSOLE**
4. Enter password: `3214`
5. Console provides:
   - **LVL.INC**: Jump to a specific level (enter number)
   - **VAL.CRED**: Set coin balance (enter number)
   - **FIX.CORE**: Heal to max HP (shows current maxHP as default value — useful for verifying HP bonuses)
   - **Injection Payloads**: Click any skill card to inject it into the current run

## Key Testing Workflows

### Testing Purchases (Skins, Shop Items)
1. Start Endless Mode → Pause → Dev Console → Val.Cred → set coins high (e.g., 1500000)
2. Close dev console → Main Menu
3. Open PERMANENT SHOP and purchase items
4. Verify: coin deduction, status changes (AVAILABLE → EQUIPPED/ACTIVE)
5. Start a new run to verify skin rendering or item effects

### Testing Cyber Tree
1. Set coins via Dev Console (as above)
2. Main Menu → CYBER TREE
3. Purchase upgrades and verify:
   - Credit deduction matches node cost
   - Level advances (e.g., LVL 0/20 → LVL 1/20)
   - Next level cost follows formula: `floor(baseCost * costMult^level)`
4. Start a new run and use Fix.Core to verify HP bonus (Hull Armor: +3 HP per level, base HP is 5)

### Testing Card Skills
1. Start Endless Mode → Pause → Dev Console
2. All skills from ALL_UPGRADES are automatically listed as injection payloads
3. Click a skill card to inject it
4. Close dev console, resume game
5. Observe visual effects (e.g., Plasma Field = concentric rings, Shadow Clone = backward-firing clone)

### Testing Endless Mode Difficulty
1. Start Endless Mode → Pause → Dev Console
2. Inject **God Mode** first (for survivability — adds +10 HP but NOT invincibility)
3. Use LVL.INC to jump to target level (e.g., 35)
4. Resume and observe enemy variety:
   - Level 15+: blinker, tesla, scout, orbiter
   - Level 30+: bomber, phaser, shielder (blue ring enemies)
   - Level 50+: reaper, splitter

### Testing Stage Select
1. Main Menu → STAGES
2. Scroll through to verify all 10 sectors
3. Sector labels: 1-3 Transmission_Active, 4-6 Deep_Space_Signal, 7-8 Anomaly_Detected, 9-10 CRITICAL_ZONE
4. Click any stage button to start that chapter/stage

## Important Notes

- **All game state is in-memory only** — page reload resets everything (coins, skins, Cyber Tree progress)
- **`let`-scoped variables** are NOT accessible from Playwright's `page.evaluate()` or injected scripts. Use the in-game Dev Console (Fix.Core prompt shows maxHP) instead of trying to read `player.maxHealth` programmatically.
- **Player dies quickly** at higher levels even with God Mode. Pause immediately after resuming if you need to re-enter Dev Console.
- The game auto-fires bullets upward. Player ship follows mouse cursor position.
- Shop items like Shield Recharge use a queued flag (`shieldRechargeQueued`) that persists across `initPlayer()` resets.

## Devin Secrets Needed
None — this is a local HTML file with no authentication required.
