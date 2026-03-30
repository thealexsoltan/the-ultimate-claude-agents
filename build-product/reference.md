# Build Product — Orchestrator Reference

## State Schema

The `state.json` file tracks the entire project lifecycle. It lives at
`rewyse-ai/output/{project-slug}/state.json`.

```json
{
  "project_name": "Hyrox Recovery Recipes",
  "project_slug": "hyrox-recovery-recipes",
  "created": "2026-03-24",
  "last_updated": "2026-03-24",
  "current_phase": 3,
  "phases": {
    "1_product_idea": {
      "status": "approved",
      "completed": "2026-03-24"
    },
    "2_build_database": {
      "status": "approved",
      "completed": "2026-03-24"
    },
    "3_expert_profile": {
      "status": "in_progress"
    },
    "4_content_blueprint": {
      "status": "pending"
    },
    "5_write_prompt": {
      "status": "pending"
    },
    "6_test_content": {
      "status": "pending"
    },
    "7_generate_content": {
      "status": "pending"
    },
    "8_design_product": {
      "status": "pending"
    },
    "9_product_qa": {
      "status": "pending"
    },
    "10_product_expand": {
      "status": "pending"
    }
  },
  "notion": {
    "database_id": "abc123def456",
    "parent_page_id": "789ghi012jkl",
    "homepage_id": null,
    "shareable_link": null
  }
}
```

### Phase Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in_progress` | Currently being worked on |
| `approved` | User approved the output |
| `needs_revision` | User requested changes |
| `skipped` | User chose to skip (only for Phase 10) |

---

## Phase Dependency Map

This map determines what must be re-run when a user "goes back" to a previous phase.

```
Phase 1 (product-idea)
├──> Phase 2 (build-database)
├──> Phase 3 (expert-profile)
└──> Phase 4 (content-blueprint)

Phase 3 (expert-profile) ──> Phase 5 (write-prompt)
Phase 4 (content-blueprint) ──> Phase 5 (write-prompt)

Phase 5 (write-prompt) ──> Phase 6 (test-content)

Phase 2 (build-database) ──> Phase 6 (test-content)
Phase 6 (test-content) ──> Phase 7 (generate-content)

Phase 7 (generate-content) ──> Phase 8 (design-product)
Phase 7 (generate-content) ──> Phase 9 (product-qa)

Phase 9 (product-qa) ──> Phase 10 (product-expand)
```

### Go-Back Reset Rules

When the user goes back to a phase, all downstream dependent phases must be reset
to `pending`. Use this lookup:

| If user goes back to... | Reset these phases |
|-------------------------|-------------------|
| Phase 1 (product-idea) | 2, 3, 4, 5, 6, 7, 8, 9, 10 (everything) |
| Phase 2 (build-database) | 6, 7, 8, 9, 10 |
| Phase 3 (expert-profile) | 5, 6, 7, 8, 9, 10 |
| Phase 4 (content-blueprint) | 5, 6, 7, 8, 9, 10 |
| Phase 5 (write-prompt) | 6, 7, 8, 9, 10 |
| Phase 6 (test-content) | 7, 8, 9, 10 |
| Phase 7 (generate-content) | 8, 9, 10 |
| Phase 8 (design-product) | (none — independent) |
| Phase 9 (product-qa) | 10 |

**Exception:** Phase 8 (design-product) is independent from Phase 9 (product-qa).
Going back to Phase 8 does NOT reset Phase 9, and vice versa.

**Exception:** If the user goes back to Phase 3 or 4, Phase 2 (build-database) does
NOT need to be re-run. The database structure doesn't change because of expert
profile or blueprint changes.

---

## Output Files

| Phase | Output File | Contents |
|-------|------------|----------|
| 1 | `product-idea.md` | Product type, niche, ICP, fixed structure, variables |
| 2 | `database-config.json` | Database ID, property names, parent page ID, sample entry IDs |
| 3 | `expert-profile.md` | Expert persona, tone, vocabulary, voice sample |
| 4 | `content-blueprint.md` | Page sections, content rules, sample skeleton |
| 5 | `generation-prompt.md` | Complete parameterized generation prompt |
| 6 | `test-results.md` | Test entries, samples, feedback, approved versions |
| 7 | `content-log.json` | Per-entry generation status, batch progress |
| 8 | `design-config.json` | Homepage ID, shareable link, browse sections |
| 9 | `qa-report.md` | Quality scan results, flagged pages, fixes applied |
| 10 | `expansion-brief.md` | Complementary product suggestions with briefs |

---

## Resume Logic

When `/build-product {slug}` is invoked and `state.json` exists:

1. Read `state.json`
2. Find `current_phase` — the first phase that is NOT `approved` or `skipped`
3. Check if the phase's required inputs exist:
   - If yes, resume from that phase
   - If no, go back to the earliest phase with missing output
4. Present the project status to the user and ask to confirm

### Handling Interrupted Phases

If a phase has `status: "in_progress"`:
- The previous attempt was interrupted
- Check if the output file exists and is complete
- If complete: ask user to review and approve
- If incomplete or missing: restart the phase

### Handling Failed Batches (Phase 7)

If `content-log.json` shows partially completed generation:
- Count published vs. remaining entries
- Present: "Found {N} entries already published. {M} remaining. Continue?"
- Resume from the first unpublished entry

---

## Error Recovery

### Common Issues

| Error | Cause | Fix |
|-------|-------|-----|
| NOTION_TOKEN invalid (401) | Token expired or wrong | User needs to regenerate token at notion.so/my-integrations |
| Database not found (404) | Token doesn't have access | User needs to share the page with the integration |
| Rate limited (429) | Too many API calls | Wait and retry with smaller batch size |
| Script fails to run | Node.js not installed or wrong version | Install Node.js 18+ |
| Phase output missing | File was deleted or moved | Re-run the phase |

### Recovery Steps

1. **Don't panic.** State is persisted. The user can always resume.
2. **Read `state.json`** to understand where things stand.
3. **Check output files** to verify what's been completed.
4. **Re-run only what's needed.** Don't restart from scratch unless Phase 1 changed.

---

## Phase Timing Estimates

These are rough guides — actual time depends on product size and user review speed.

| Phase | Typical Duration | Notes |
|-------|-----------------|-------|
| 1. Product Idea | 5-10 min | Conversational, depends on user clarity |
| 2. Build Database | 2-5 min | Mostly automated (script generation + run) |
| 3. Expert Profile | 5-10 min | Includes voice sample iteration |
| 4. Content Blueprint | 5-10 min | Section design + skeleton review |
| 5. Write Prompt | 3-5 min | Assembly + test generation |
| 6. Test Content | 5-15 min | Depends on revision cycles |
| 7. Generate Content | 5-30 min | Depends on entry count (50 = ~10 min, 200 = ~30 min) |
| 8. Design Product | 5-10 min | Homepage + views + icons |
| 9. Product QA | 5-15 min | Scan + targeted fixes |
| 10. Product Expand | 3-5 min | Suggestion generation |

**Total: ~45-120 min** for a complete product build.
