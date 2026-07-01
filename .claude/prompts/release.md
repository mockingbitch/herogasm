---
description: Release readiness prompt for Herogasm.
---

# Release Prompt

You are preparing a release for **Herogasm**, a living-world idle RPG inspired by Evil Hunter Tycoon.

A release is allowed only when the build is stable, tested, performant, save-compatible, and safe for players.

---

# Step 1 — Release Summary

Summarize:

- Version
- Release type
- Target platform
- Major features
- Bug fixes
- Balance changes
- Known risks
- Rollback plan

Release types:

```text
Internal
QA
Alpha
Beta
Soft Launch
Production
Hotfix
```

---

# Step 2 — Release Checklist

Verify:

```text
All tests pass
Regression suite passes
Simulation tests pass
Stress tests pass
Save/load verified
Migration verified
Performance target met
Telemetry enabled
Debug tools disabled
No critical bugs
No blocker bugs
```

---

# Step 3 — Save Compatibility

Check:

```text
Old saves load
New saves load
Migration works
Backup works
Recovery works
Offline progression works
Reward duplication prevented
```

Never release with untested save migration.

---

# Step 4 — Performance Validation

Validate on target device:

```text
FPS avg
FPS min
Frame time
Memory
AI tick
Combat tick
Navigation tick
UI update
Save time
Load time
```

Minimum targets:

```text
FPS avg >= 60
FPS min >= 45
Memory <= 512 MB
Autosave < 500 ms
Load < 3 sec
```

---

# Step 5 — Gameplay Validation

Verify:

```text
Heroes move autonomously
Heroes leave town to hunt
Heroes return to town
Heroes rest / repair / shop
Monsters spawn and respawn
Combat works
Loot works
Quests work
Buildings work
Events work
Bosses work
Economy remains stable
```

---

# Step 6 — Economy / Balance Validation

Run:

```text
Economy simulation
Loot simulation
Boss simulation
Offline progression simulation
30-day progression simulation
```

Check:

```text
No infinite gold
No reward duplication
No negative currency
No runaway inflation
No dominant exploit
No impossible progression wall
```

---

# Step 7 — Telemetry Validation

Verify events:

```text
session_started
session_ended
hero_level_up
hero_died
quest_completed
building_upgraded
item_obtained
gold_earned
gold_spent
boss_spawned
boss_defeated
event_started
event_ended
save_completed
load_completed
error_occurred
```

Telemetry must not collect personal data.

---

# Step 8 — Debug / Dev Tools

Before release:

```text
Disable developer panel
Disable debug commands
Disable cheats
Disable debug overlays
Disable verbose logs
Disable force event tools
Disable profiler overlay
```

Debug tools may remain only in internal/QA builds.

---

# Step 9 — Build Validation

Verify:

```text
Correct build version
Correct environment
Correct assets
Correct localization
Correct signing
Correct export preset
Correct feature flags
Correct telemetry endpoint
Correct save version
```

---

# Step 10 — QA Sign-off

QA must confirm:

```text
No critical bugs
No blocker bugs
Regression passed
Stress passed
Save compatibility passed
Performance passed
Smoke test passed
Release notes reviewed
```

---

# Step 11 — Release Notes

Include:

```text
New features
Improvements
Bug fixes
Balance changes
Known issues
Save compatibility notes
Player-facing changes
```

Avoid internal technical noise.

---

# Step 12 — Rollback Plan

Prepare:

```text
Previous stable build
Save backup policy
Feature flags
Hotfix branch
Known rollback risks
Telemetry monitoring
```

Never release without rollback plan.

---

# Step 13 — Post Release Monitoring

Monitor:

```text
Crashes
Save failures
FPS drops
Memory spikes
Reward duplication
Economy inflation
Quest failures
Hero stuck reports
Boss success rate
Event participation
Retention
```

---

# Required Output Format

Always answer:

1. Release Summary
2. Feature List
3. Bug Fix List
4. Balance Changes
5. Test Results
6. Save Compatibility
7. Performance Results
8. Telemetry Validation
9. Known Issues
10. Rollback Plan
11. Release Notes
12. Final Verdict

---

# Release Blockers

Block release if:

```text
Save corruption
Crash on startup
Reward duplication
Infinite gold exploit
Critical performance regression
Broken migration
Broken offline progression
Broken core loop
Debug tools enabled
Critical telemetry failure
```

---

# Definition of Done

Release is ready only when:

```text
✓ Tests pass
✓ QA signs off
✓ Save compatibility verified
✓ Performance verified
✓ Economy validated
✓ Telemetry validated
✓ Debug disabled
✓ Release notes written
✓ Rollback plan ready
✓ No release blockers
```

---

# Required Rules

Follow:

- testing.md
- regression.md
- simulation.md
- stress-test.md
- profiling.md
- save-system.md
- performance.md
- telemetry.md
- debug-tools.md
- balancing.md
- economy.md