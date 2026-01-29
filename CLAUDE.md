# Polished Gold Feature Feasibility Analysis

This document categorizes all Polished Crystal 3.2.3 features by their feasibility for implementation in Pokemon Gold while **maintaining DMG (original Game Boy) compatibility**.

---

## TIER 1: EASY TO IMPLEMENT - DETAILED IMPLEMENTATION GUIDE
*Minimal code changes, no architectural changes, no new graphics required*

### Strategy: Batch Similar Changes
Group changes by file to minimize context switching:
1. **Constants files** - type_constants, item_constants, etc.
2. **Data files** - moves.asm, type_matchups.asm
3. **Engine files** - battle/core.asm, items/pack.asm
4. **Event scripts** - individual map scripts

---

### Bug Fixes (All Feasible)

**All bugs documented in `pokegold/docs/bugs_and_glitches.md`**

| Bug | File | Lines | Fix |
|-----|------|-------|-----|
| Dragon Fang boost | `data/items/attributes.asm` | 297-299 | Change `HELD_NONE` → `HELD_DRAGON_BOOST` |
| Status catch rate | `engine/items/item_effects.asm` | 337-352 | Fix `.statuscheck` logic at line 349 |
| Moon Ball | `engine/items/item_effects.asm` | 875-920 | Fix `MOON_STONE_RED` check at line 908 |
| Love Ball | `engine/items/item_effects.asm` | 921-985 | Change `ret nz` → `ret z` at line 967 |
| Fast Ball | `engine/items/item_effects.asm` | 986-1020 | Change `jr nz, .next` → `jr nz, .loop` line 1005 |
| Exp underflow | `engine/pokemon/experience.asm` | 33-35 | Fix Medium-Slow growth calc |
| HP bar speed | `engine/battle/anim_hp_bar.asm` | 182 | Fix `LongAnim_UpdateVariables` |
| Belly Drum HP | `engine/battle/move_effects/belly_drum.asm` | 1-2 | Add 50% HP check |

### Text/Naming Changes (All Feasible)
- [ ] Lowercase Pokémon, moves, items, types, names
- [ ] Pack → Bag, Enemy → Foe, Cooltrainer → Ace Trainer, etc.
- [ ] Fast text by default
- [ ] Stereo sound by default
- [ ] Berry renaming
- [ ] Brass Tower → Gong Tower

### Move Attribute Changes (All Feasible)
- [ ] Cut: Power 50→60, Type NORMAL→STEEL, Accuracy 95→100
- [ ] Dig: Power 60→90
- [ ] Fly: Power 70→90, Accuracy 95→100
- [ ] All other power/accuracy/PP adjustments (20+ moves)
- [ ] Hidden Power always 70 power

### Quality of Life (All Feasible)

| Feature | File | Lines | Change |
|---------|------|-------|--------|
| Running Shoes | `engine/overworld/map_objects.asm` | 365-381 | Add B-button fast movement state |
| Continuous Repel | `engine/overworld/events.asm` | 925-938 | Prompt for new repel at wear-off |
| Fishing 75% | `engine/events/fish.asm` | 24-30 | Adjust success probability |
| Unlimited TMs | `engine/items/tmhm.asm` | 517-534 | Remove `ConsumeTM` call |
| Bag pocket sizes | `constants/item_data_constants.asm` | 40-52 | Increase MAX_ITEMS etc. |
| Auto box switch | `engine/pokemon/bills_pc.asm` | 155-170 | Auto-advance on box full |
| Poison cure at 1HP | `engine/events/poisonstep.asm` | 76-99 | Cure instead of faint |
| Fast text default | `data/default_options.asm` | 1-18 | Set TEXT_DELAY_FAST |

### Battle Formula Tweaks (All Feasible)
- [ ] Sleep lasts 1-3 turns (not 1-7)
- [ ] 20% defrost chance (not 10%)
- [ ] Critical hits 150% damage (more likely)
- [ ] Type immunities (Electric immune to paralysis, etc.)
- [ ] Struggle 25% max HP recoil
- [ ] Sandstorm 1/16 damage per turn
- [ ] Rock-type Sp.Def boost in sandstorm

### Item Effect Changes (All Feasible)
- [ ] Type-enhancing items 20% boost (not 10%)
- [ ] Light Ball doubles Pikachu's Attack and Sp.Atk
- [ ] Leppa Berry restores 10 PP (not 5)
- [ ] Sitrus Berry restores 25% max HP
- [ ] X Accuracy boosts accuracy (doesn't bypass checks)
- [ ] Amulet Coin increases wild item rates

### Trainer/AI Improvements (All Feasible)
- [ ] AI doesn't fail 25% with status moves
- [ ] AI doesn't try to paralyze Electric types
- [ ] Improved trainer rosters, movesets, held items
- [ ] No badge boosts to stats
- [ ] Default Set battle style
- [ ] Level curve adjustments

### Misc Easy Changes
- [ ] Eggs hatch at level 1
- [ ] Experience from catching Pokémon
- [ ] Gen VI money loss formula
- [ ] Unlimited TMs
- [ ] Bag pocket sizes increased
- [ ] Max $9,999,999 and 50,000 coins
- [ ] Trees randomly give 1-3 Berries
- [ ] Nidorina/Nidoqueen can breed

---

## TIER 2: MODERATE DIFFICULTY - DETAILED IMPLEMENTATION GUIDE
*Significant engine changes required, but no new assets or Crystal-only dependencies*

---

### Physical/Special Split

**Complexity: HIGH | Priority: CRITICAL (unlocks modern battling)**

#### Overview
Currently Gold determines Physical vs Special by TYPE (Normal-Steel = Physical, Fire-Dark = Special). Modern games use per-move CATEGORY.

#### Files to Modify

| File | Changes |
|------|---------|
| `constants/battle_constants.asm` L48-57 | Add `MOVE_CATEGORY` field, change MOVE_LENGTH 7→8 |
| `constants/type_constants.asm` L35+ | Add `PHYSICAL`, `SPECIAL`, `STATUS` constants |
| `data/moves/moves.asm` L1-12 | Expand macro to 8 params, add category to all 251 moves |
| `engine/battle/effect_commands.asm` L2554, 2784 | Change `cp SPECIAL` (type-based) to category-based check |
| `ram/wram.asm` | Add `wPlayerMoveCategory`, `wEnemyMoveCategory` |

#### Key Code Change (effect_commands.asm)
```asm
; BEFORE (line ~2554):
ld a, [wPlayerMoveStructType]
cp SPECIAL              ; type >= 10 = special
jr nc, .special

; AFTER:
ld a, [wPlayerMoveStructCategory]
cp SPECIAL              ; category == 1 = special
jr z, .special
```

#### All 251 Moves Need Category Assignment
Reference Polished Crystal's `data/moves/moves.asm` for correct categories. Example:
- Fire Punch: FIRE type but PHYSICAL category
- Crunch: DARK type but PHYSICAL category

---

### Fairy Type Addition

**Complexity: MODERATE | Priority: HIGH**

#### Files to Modify

| File | Lines | Changes |
|------|-------|---------|
| `constants/type_constants.asm` | L34+ | Add `const FAIRY` (becomes type 18) |
| `data/types/type_matchups.asm` | L1-119 | Add 12+ Fairy matchup entries before `-2` marker |
| `constants/item_data_constants.asm` | L122+ | Add `HELD_FAIRY_BOOST` |
| `data/types/type_boost_items.asm` | L18 | Add `db HELD_FAIRY_BOOST, FAIRY` |
| `data/pokemon/base_stats/*.asm` | Various | Retype ~15 Pokemon to Fairy |

#### Type Matchups to Add (before line 112's `-2`)
```asm
; Fairy offensive
db FAIRY, FIGHTING, SUPER_EFFECTIVE      ; Fairy beats Fighting
db FAIRY, DRAGON, SUPER_EFFECTIVE        ; Fairy beats Dragon
db FAIRY, DARK, SUPER_EFFECTIVE          ; Fairy beats Dark
db FAIRY, FIRE, NOT_VERY_EFFECTIVE       ; Fairy weak to Fire
db FAIRY, POISON, NOT_VERY_EFFECTIVE     ; Fairy weak to Poison
db FAIRY, STEEL, NOT_VERY_EFFECTIVE      ; Fairy weak to Steel

; Fairy defensive (other types vs Fairy)
db POISON, FAIRY, SUPER_EFFECTIVE        ; Poison beats Fairy
db STEEL, FAIRY, SUPER_EFFECTIVE         ; Steel beats Fairy
db FIGHTING, FAIRY, NOT_VERY_EFFECTIVE   ; Fighting weak to Fairy
db BUG, FAIRY, NOT_VERY_EFFECTIVE        ; Bug weak to Fairy
db DARK, FAIRY, NOT_VERY_EFFECTIVE       ; Dark weak to Fairy
db DRAGON, FAIRY, NO_EFFECT              ; Dragon immune to Fairy
```

#### Pokemon to Retype (Gen 1-2 only)
| Pokemon | Old Type | New Type | File |
|---------|----------|----------|------|
| Clefairy | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/clefairy.asm` L6 |
| Clefable | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/clefable.asm` L6 |
| Cleffa | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/cleffa.asm` L6 |
| Jigglypuff | NORMAL/NORMAL | NORMAL/FAIRY | `base_stats/jigglypuff.asm` L6 |
| Wigglytuff | NORMAL/NORMAL | NORMAL/FAIRY | `base_stats/wigglytuff.asm` L6 |
| Igglybuff | NORMAL/NORMAL | NORMAL/FAIRY | `base_stats/igglybuff.asm` L6 |
| Togepi | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/togepi.asm` L6 |
| Togetic | NORMAL/FLYING | FAIRY/FLYING | `base_stats/togetic.asm` L6 |
| Mr. Mime | PSYCHIC/PSYCHIC | PSYCHIC/FAIRY | `base_stats/mr__mime.asm` L6 |
| Marill | WATER/WATER | WATER/FAIRY | `base_stats/marill.asm` L6 |
| Azumarill | WATER/WATER | WATER/FAIRY | `base_stats/azumarill.asm` L6 |
| Snubbull | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/snubbull.asm` L6 |
| Granbull | NORMAL/NORMAL | FAIRY/FAIRY | `base_stats/granbull.asm` L6 |

---

### Nature System (DV-based)

**Complexity: MODERATE | Priority: MEDIUM**

#### How Polished Crystal Does It
Natures are stored in Pokemon data (1 byte, values 0-24). Stat calculation multiplies by 0.9/1.0/1.1 based on nature.

#### Files to Create/Modify

| File | Changes |
|------|---------|
| `constants/nature_constants.asm` (NEW) | Define 25 natures + stat modifier mappings |
| `engine/pokemon/stats.asm` | Add nature multiplier to stat calculation |
| `ram/wram.asm` | Ensure Pokemon struct has nature byte (or derive from DVs) |
| Menu files | Display nature name on stats screen |

#### Nature Stat Multipliers
```asm
GetNatureStatMultiplier:
; Input: a = nature (0-24), c = stat (1-5: Atk/Def/Spd/SpA/SpD)
; Output: a = 9 (0.9x), 10 (1.0x), or 11 (1.1x)
; Neutral natures (0,6,12,18,24) always return 10
```

#### 25 Natures Reference
| Nature | +Stat | -Stat |
|--------|-------|-------|
| Hardy | - | - |
| Lonely | Atk | Def |
| Brave | Atk | Spd |
| Adamant | Atk | SpA |
| Naughty | Atk | SpD |
| Bold | Def | Atk |
| ... | ... | ... |

---

### Adding New Moves

**Complexity: PER-MOVE | Priority: HIGH**

#### Move Data Structure (8 bytes after Phys/Spec split)
```asm
; data/moves/moves.asm
move DRAGON_DANCE, EFFECT_DRAGON_DANCE, 0, DRAGON, -1, 20, 0, STATUS
;    animation,    effect,              pwr, type, acc, pp, chance, category
```

#### Files for Each New Move

| Step | File | Action |
|------|------|--------|
| 1 | `constants/move_constants.asm` | Add `const DRAGON_DANCE` |
| 2 | `data/moves/moves.asm` | Add move entry with 8 fields |
| 3 | `data/moves/effects.asm` | Create effect script |
| 4 | `data/moves/effects_pointers.asm` | Add `dw DragonDanceEffect` |
| 5 | `data/moves/names.asm` | Add "Dragon Dance@" |
| 6 | `data/moves/descriptions.asm` | Add description text |
| 7 | `data/moves/animation_pointers.asm` | Add animation pointer |
| 8 | `data/moves/animations.asm` | Create animation (or reuse) |

#### Example Effect Script (Dragon Dance)
```asm
DragonDanceEffect:
    checkobedience
    usedmovetext
    doturn
    forceraisestat ATTACK    ; +1 Attack
    forceraisestat SPEED     ; +1 Speed
    endmove
```

#### Priority Moves to Add (easiest first)
| Move | Type | Category | Effect | Difficulty |
|------|------|----------|--------|------------|
| Dragon Dance | DRAGON | STATUS | +1 Atk, +1 Spd | Easy |
| Calm Mind | PSYCHIC | STATUS | +1 SpA, +1 SpD | Easy |
| Bulk Up | FIGHTING | STATUS | +1 Atk, +1 Def | Easy |
| Swords Dance exists | - | - | Already in game | - |
| Roost | FLYING | STATUS | Heal 50% HP | Moderate |
| Knock Off | DARK | PHYSICAL | Remove held item | Moderate |
| U-turn | BUG | PHYSICAL | Switch after hit | Hard |
| Volt Switch | ELECTRIC | SPECIAL | Switch after hit | Hard |

---

### Updated Type Chart (Gen 6)

**Complexity: LOW | Priority: HIGH (if adding Fairy)**

#### Changes from Gen 2 → Gen 6
| Change | File Location |
|--------|---------------|
| Steel no longer resists Ghost | Remove `db GHOST, STEEL, NOT_VERY_EFFECTIVE` |
| Steel no longer resists Dark | Remove `db DARK, STEEL, NOT_VERY_EFFECTIVE` |
| All Fairy matchups | See Fairy section above |

File: `data/types/type_matchups.asm`

---

### Shiny Odds Changes

**Complexity: LOW | Priority: LOW**

#### Current System (Gold)
- Shiny = specific DV combinations (1/8192 chance)
- Check in `engine/pokemon/shiny.asm`

#### Changes for 1/4096 (Gen 6 odds)
```asm
; Modify DV threshold check to be less strict
; Or add Shiny Charm flag that doubles odds
```

---

### Evolution Method Expansions

**Complexity: MODERATE | Priority: MEDIUM**

| Method | Implementation | Files |
|--------|----------------|-------|
| Level + knows move | Add move check in evolution routine | `engine/pokemon/evolve.asm` |
| Level + location | Add map ID check | `engine/pokemon/evolve.asm` |
| Level + held item | Already exists (e.g., King's Rock) | - |
| New stones | Add stone constants + evolution data | `data/pokemon/evos_attacks.asm` |

---

### Base Stat Changes

**Complexity: TRIVIAL | Priority: LOW**

Pure data changes. Each Pokemon has file in `data/pokemon/base_stats/`.

Example: `base_stats/pikachu.asm` line 3:
```asm
db 35, 55, 40, 50, 50, 90  ; HP, Atk, Def, SpA, SpD, Spd
```

Reference Polished Crystal or Drayano's hacks for balanced stat changes.

---

## TIER 3: DIFFICULT
*Major new features, significant new code, or extensive new assets required*

### New Maps (Restored Locations)
**Feasibility: CHALLENGING**
- Viridian Forest, Cerulean Cave, Seafoam Islands, etc.
- Requires: Map data, tilesets, scripts, wild encounters, warps
- ROM space is a concern (Gold is already nearly 2MB)
- **Partially possible:** Could restore smaller areas, not all

### New Trainer Classes
**Feasibility: MODERATE-HARD**
- Requires new sprites (graphics work)
- DMG compatibility: Must work in 4 grayscale shades
- Code side is easy; art is the bottleneck

### Move Tutors Throughout Johto/Kanto
**Feasibility: MODERATE**
- Code from Crystal can be adapted
- Event scripting required for each tutor
- 48 tutors is a lot of work but not technically hard

### Wonder Trade System
**Feasibility: HARD**
- Polished Crystal uses this for single-player random trades
- Requires: NPC pool, random selection, trade animation hooks
- Significant scripting but no hardware issues

### Revised Game Corner / Prizes
**Feasibility: MODERATE**
- Event script changes
- Prize list updates (data changes)

### Stats Judge (replacing Poké Seer)
**Feasibility: MODERATE**
- DV/stat reading logic exists
- Text display and menu work

### Respawning Legendaries
**Feasibility: MODERATE**
- Flag management after Elite Four
- Already have spawn mechanics

### Battle Tower (Basic Version)
**Feasibility: HARD**
- Crystal-exclusive feature
- Would need to backport significant code
- Trainer pool, streak tracking, save system
- Map creation
- **Possible but very labor-intensive**

---

## TIER 4: VERY DIFFICULT / IMPRACTICAL
*Major technical barriers, extensive new systems, or significant DMG compatibility issues*

### New Pokémon Species
**Feasibility: VERY HARD**
- Leafeon, Glaceon, Sylveon, regional forms (Alolan, Galarian, Hisuian)
- Requires: Sprites, base stats, dex entries, cries, icons, learnsets
- **ROM space critical** - adding 50+ new Pokémon is massive
- Each Pokémon needs: Front sprite, back sprite, icon, footprint, cry, data
- Polished Crystal adds ~100 new Pokémon/forms
- **Partial implementation possible:** Maybe 10-20 most requested

### Unique Mini Sprites Per Pokémon
**Feasibility: HARD**
- Current system reuses sprites
- 251+ unique mini sprites = significant graphics work
- ROM space for all graphics

### Battle Factory
**Feasibility: VERY HARD**
- Complex rental system
- Pool management
- Never existed in Gen 2 at all

### Lyra as Friendly Rival
**Feasibility: HARD**
- New character sprites needed
- Full event script for all encounters
- Dialogue writing
- **Would need artist for DMG-compatible sprites**

### Full Map Expansions (All HG/SS Locations)
**Feasibility: IMPRACTICAL**
- Goldenrod Harbor, Valencia Island, Sinjoh Ruins, etc.
- Massive ROM space requirements
- Extensive tileset work
- **Pick a few** rather than all

### Revised Shiny Palettes
**Feasibility: IMPRACTICAL FOR DMG**
- Shiny colors only visible on GBC/SGB
- DMG players see no difference
- Could implement but limited value with DMG target

---

## TIER 5: IMPOSSIBLE / NOT APPLICABLE
*Fundamentally incompatible with Gold or DMG hardware*

### GBC-Only Graphical Features
- Dynamic time-based palette shifts
- Full color Pokemon sprites by species
- Enhanced CGB color layouts (30+ modes in Crystal)
- **DMG has 4 shades only - these literally cannot work**

### Mobile Adapter Features
- Online trading/battling infrastructure
- Mobile Stadium connectivity
- **Hardware doesn't exist for Gold**

### Female Protagonist Selection
**Feasibility: IMPOSSIBLE for different reason**
- Gold has no Kris/Lyra in the story
- Would require rewriting game narrative
- Not a technical limit but a design one

### Buena's Password System
- Crystal-exclusive radio event
- Could theoretically port but tied to Crystal's expanded Pokégear

### Odd Egg (Crystal Version)
- Crystal-exclusive Daycare Man event
- Could port the mechanic but loses the "Crystal special" feel
- **Possible but may not fit Gold's identity**

---

## RECOMMENDED PRIORITY IMPLEMENTATION
*Based on user priorities: Battle Mechanics, QoL, Content/Maps (NOT new Pokémon)*

### Phase 1: Quality of Life Foundation
**Goal: Make the game feel modern without changing core mechanics**
1. Running Shoes (Hold B to run) - `engine/overworld/player_movement.asm`
2. Continuous Repel system - `engine/overworld/repel.asm`
3. Fast text by default - `engine/menus/text_speed.asm`
4. Bag pocket expansion (75/37/25/31) - `constants/item_constants.asm`, `engine/items/pack.asm`
5. Unlimited TMs - `engine/items/tmhm.asm`
6. Automatic box switching - `engine/pokemon/box.asm`
7. Bill's full box warning calls
8. Cure poison at 1 HP outside battle
9. Fishing 75% success rate

### Phase 2: Bug Fixes
**Goal: Fix all known vanilla bugs**
1. Dragon Fang boost fix
2. Ball catch rate fixes (Moon, Love, Fast)
3. Status improving catch rate
4. Experience underflow fix
5. HP bar speed fix
6. Belly Drum HP check
7. Magikarp size fix
8. All other Tier 1 bug fixes

### Phase 3: Battle Mechanics Overhaul
**Goal: Modernize the battle system - THIS IS THE BIG ONE**

**3a. Physical/Special Split**
- Add move category byte to move data structure
- Modify damage calculation in `engine/battle/core.asm`
- Update all 251 move definitions with category
- Key files: `data/moves/moves.asm`, `engine/battle/effect_commands.asm`

**3b. Fairy Type**
- Add FAIRY constant to `constants/type_constants.asm`
- Update type chart in `data/types/type_matchups.asm`
- Retype relevant Pokémon (Clefairy line, Togepi line, etc.)
- Pink Bow → Fairy boost item

**3c. Updated Type Chart (Gen 6)**
- Steel no longer resists Ghost/Dark
- All Fairy interactions

**3d. Move Attribute Changes**
- All power/accuracy/PP changes from Tier 1
- Prioritize impactful moves: Cut→Steel, Leech Life 80 power, etc.

**3e. Battle Formula Updates**
- Sleep 1-3 turns, 20% defrost, 150% crits
- Type immunities to status
- Sandstorm Rock Sp.Def boost
- All Tier 1 formula changes

**3f. AI Improvements**
- Remove 25% fail chance on status moves
- Smart type targeting
- No badge stat boosts

### Phase 4: New Moves (Selected)
**Goal: Add ~30 high-impact moves, not all 70+**
Priority moves (existing animation reuse):
- Dragon Dance, Calm Mind, Bulk Up, Hone Claws (stat boosters)
- Close Combat, Brave Bird, Flare Blitz (high power)
- U-turn, Volt Switch (switching moves)
- Knock Off, Roost, Will-O-Wisp (utility)
- Scald, Ice Shard, Bullet Punch (priority/common)

### Phase 5: Content & Maps
**Goal: Restore iconic missing locations**

**5a. Priority Map Restorations (pick 2-3)**
1. **Viridian Forest** - Fan favorite, connects Route 2, moderate size
2. **Cerulean Cave** - Endgame content, Mewtwo location
3. **Seafoam Islands** - Articuno location (if legendary birds added)
4. **Pewter Museum** - Fossil revival location

**5b. Event Additions**
- Move Tutors (10-15 throughout Johto/Kanto)
- Stats Judge (replace Poké Seer)
- Respawning legendaries after E4
- Revised trainer rosters with better movesets/items
- E4 rematch at higher levels

**5c. Map Polish**
- HG/SS decorative features to cities (if ROM space permits)
- Route extensions where feasible

### Phase 6: Polish & Optional
**Only if earlier phases complete**
- Nature system (DV-based)
- Shiny odds adjustments
- Wonder Trade system
- Basic Battle Tower (major undertaking)

---

## KEY TECHNICAL CONSTRAINTS

### ROM Space (CONFIRMED: 2MB limit)
- **MBC3+TIMER+RAM+BATTERY** - keeping RTC for day/night features
- Gold currently uses 99 of 128 available banks (~1.5MB used)
- **~29 banks (~464KB) available** for new content
- Polished Crystal uses 123 banks in same space (tighter packing)
- Could potentially free space by optimizing/compressing existing data
- MBC5 (8MB) was considered but rejected due to no RTC support

### Space Budget Estimates
| Content Type | Approximate Size |
|--------------|------------------|
| New Pokémon (with sprites) | ~8KB each |
| New Map (small) | ~2-4KB |
| New Map (medium) | ~8-16KB |
| New Move | ~0.5KB each |
| New Trainer class (with sprite) | ~1KB |
| Move Tutor event | ~0.3KB |

With 464KB free: Could add ~10-15 maps, ~30 moves, ~15 trainers, or equivalent

### DMG Compatibility Restrictions
- 4 grayscale shades only (no color features)
- No double-speed CPU
- Limited WRAM banking
- All graphics must be legible in grayscale

### Not in Original Gold
- Battle Tower (Crystal)
- Odd Egg (Crystal)
- Move Tutors (Crystal)
- Buena's Password (Crystal)
- Female protagonist (Crystal)

---

## SUMMARY

| Category | Easy | Moderate | Difficult | Impractical | Impossible |
|----------|------|----------|-----------|-------------|------------|
| Bug Fixes | 10 | 0 | 0 | 0 | 0 |
| QoL Features | 12 | 3 | 0 | 0 | 0 |
| Battle Mechanics | 15 | 8 | 2 | 0 | 0 |
| New Moves | 0 | 40 | 30 | 0 | 0 |
| New Pokémon | 0 | 0 | 10 | 90+ | 0 |
| New Maps | 0 | 0 | 5 | 15+ | 0 |
| Graphics | 0 | 0 | 5 | 10+ | 5+ |
| Events | 5 | 10 | 5 | 3 | 2 |

**Bottom Line:** ~60-70% of Polished Crystal's features are feasible for Polished Gold with DMG compatibility. The main losses are new Pokémon/forms, extensive map additions, and all color-specific enhancements.

---

## VERIFICATION & TESTING

### Build Verification
```bash
cd /Users/tfokkens/Documents/Claude/Polished_Gold/pokegold
make clean && make pokegold
```
- Verify ROM builds without errors
- Check ROM size hasn't exceeded limits

### In-Emulator Testing (Tier 1 Easy Features)

| Feature | Test Method |
|---------|-------------|
| Dragon Fang | Give Dragon Fang to dragon type, verify damage boost |
| Ball bugs | Test Moon/Love/Fast Ball catch rates |
| Status catch | Burn/paralyze wild mon, verify catch improvement |
| Running Shoes | Hold B while walking, verify speed increase |
| Continuous Repel | Wait for repel to expire, verify prompt appears |
| Unlimited TMs | Use TM, verify not consumed |
| Fishing 75% | Fish 20+ times, verify ~75% bite rate |
| Poison cure | Walk with poisoned mon at 2HP, verify cures at 1HP |
| Fast text | Start new game, verify fast text default |

### Recommended Emulator
- **mGBA** or **BGB** - both support DMG mode testing
- Enable DMG mode to verify grayscale compatibility

BUGS:
- Battle attack no longer work
- In the back, when you go all the way down to the bottom or all the way to the top, it selects the "item" automatically.