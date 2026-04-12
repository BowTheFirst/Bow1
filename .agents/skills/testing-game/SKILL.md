# Testing Neon Abyss Game

## Running the Game
The game is a single HTML file with no build system or dependencies.
```bash
google-chrome file:///home/ubuntu/repos/Bow1/index.html
```

## Dev Console Access
1. Start any game mode (Endless Mode or Stage Select)
2. Click PAUSE
3. Click DEV CONSOLE
4. Enter the dev console password (defined in the source code)

### Dev Console Features
- **Val.Cred**: Set coin balance (e.g., 20000000 for mythic skin testing)
- **Lvl.Inc**: Jump to any level
- **Fix.Core**: Set player health
- **Card Injection**: Click any card to inject it into the current run
- Cards are organized by rarity: COMMON, RARE, EPIC, LEGENDARY, MYTHIC

## Programmatic Game Control via Playwright CDP
The browser exposes CDP on `http://localhost:29229`. Use Playwright to manipulate game state:

```python
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp('http://localhost:29229')
        page = browser.contexts[0].pages[0]
        # Give god mode
        await page.evaluate('player.health = 999; player.maxHealth = 999;')
        # Trigger level-up card selection
        await page.evaluate('showUpgrades()')
        # Inject abilities
        await page.evaluate('phaseWalkActive = true;')
        # Check game state
        result = await page.evaluate('JSON.stringify({level, phaseWalkActive: phaseWalkActive, phasing: player.phasing})')
        print(result)

asyncio.run(main())
```

## Key Game Variables
- `player.health` / `player.maxHealth`: Player HP
- `globalCoins`: Coin balance
- `activeSkin`: Current skin name (e.g., 'singularity', 'ethereal', 'omega')
- `phaseWalkActive`: Phase Walk skill toggle
- `player.phasing`: Whether player is currently in phasing window
- `mythicSkinBuffs`: Object with per-skin buff state
- `level`: Current level
- `gameRunning` / `paused`: Game state flags

## Testing Tips
- The player dies quickly in early levels. Use Playwright to set `player.health = 999` for survivability during testing.
- Card selection screen can be triggered directly via `showUpgrades()` — no need to level up naturally.
- Star background data can be verified programmatically by inspecting the `stars` array.
- All game state resets on page reload — there is no persistence.
- Mythic skin per-run state (`omega.extraLife`, `omega.freeEpic`, `singularity.autoShieldTimer`) resets in `resetGame()`.
