# Foundation Signals: Business View Strategy

## Current Problems (User Identified)

1. **Showing low-confidence signals** - We're showing inferred signals (like "stale_content", "technical_debt_high") without clearly marking them as guesses
2. **No business relevance framing** - We're throwing scores/metrics at business owners without explaining "so what?"
3. **Confidence opacity** - Users can't tell what's observed vs. inferred

---

## Current State Analysis

### Foundation Signals Confidence Levels

From `issue_builder.py`:

| Signal | Confidence | DetectedAs | Why It Matters |
|--------|-----------|------------|----------------|
| `stale_content` | MEDIUM | INFERRED | Blog/sitemap last updated 18+ months ago |
| `copyright_outdated` | HIGH | OBSERVED | Copyright year directly visible in footer |
| `hidden_complexity` | HIGH | OBSERVED | /app or /portal routes found in sitemap |
| `technical_debt_high` | MEDIUM | INFERRED | Composite score from multiple heuristics |
| `agency_link_dead` | HIGH | OBSERVED | Agency link returns 404 (NOT IMPLEMENTED) |

### Current Business Overview Components

**ExecutiveStory.tsx:**
- Shows narrative + "What's working" pills + "Needs attention" pills
- **Problem**: Pills show ALL issues regardless of confidence
- **Problem**: No indication of confidence level in UI

**BusinessImpactCategories.tsx:**
- Groups issues by business_category (Trust & Credibility, Search Visibility, User Experience, Operational Risk)
- Shows severity indicator + count + first issue's `why_it_matters`
- **Problem**: Shows ALL issues regardless of confidence
- **Problem**: Leads with severity, not business relevance

---

## Proposed Solution: 3-Part Fix

### Part 1: Filter by Confidence in Business View (MUST HAVE)

**Rule:** Business Overview tab ONLY shows issues with `confidence: "high"` AND `detected_as: "observed"`

**Why:**
- Business owners need facts, not guesses
- "Your site appears stale" (INFERRED + MEDIUM confidence) creates doubt
- "Your copyright says © 2021" (OBSERVED + HIGH confidence) is actionable

**Implementation:**
- Filter in `BusinessContent.tsx` before passing to children:
  ```typescript
  const highConfidenceIssues = issues.filter(
    i => i.confidence === 'high' && i.detected_as === 'observed'
  )
  ```

- Technical Details tab can still show ALL issues (with confidence badges visible)

**Impact on Foundation Signals:**
- ✅ `copyright_outdated` - SHOWN (HIGH + OBSERVED)
- ❌ `stale_content` - HIDDEN (MEDIUM + INFERRED)
- ✅ `hidden_complexity` - SHOWN (HIGH + OBSERVED)
- ❌ `technical_debt_high` - HIDDEN (MEDIUM + INFERRED)

---

### Part 2: Lead with Business Relevance, Not Scores (MUST HAVE)

**Current BusinessImpactCategories card:**
```
Trust & Credibility
Needs attention (← severity-first)
Your copyright year is 5 years old. (← why_it_matters)
```

**Proposed BusinessImpactCategories card:**
```
Trust & Credibility
Visitors may think you're out of business (← business impact first)
We found: Outdated copyright year (← what we observed)
```

**Changes:**
1. Replace `getStatusText(maxSeverity)` with business-first framing
2. Show business impact from `CATEGORY_BUSINESS_IMPACT` (already exists in `business_goals.py`)
3. List observed issues as bullets, not buried in `why_it_matters`

**New card structure:**
```typescript
<div className="card">
  {/* Business impact headline */}
  <p className="text-base font-medium text-gray-900">
    {businessImpactText} {/* "Visitors may question if you're still active" */}
  </p>

  {/* What we observed */}
  <div className="mt-3">
    <p className="text-sm text-gray-500 mb-2">We observed:</p>
    <ul className="list-disc list-inside space-y-1">
      {categoryIssues.map(issue => (
        <li className="text-sm text-gray-700">{issue.title}</li>
      ))}
    </ul>
  </div>

  {/* Confidence indicator (subtle) */}
  <p className="text-xs text-gray-400 mt-3">
    Based on {categoryIssues.length} high-confidence finding{s}
  </p>
</div>
```

---

### Part 3: Context-Aware Narrative Enhancement (NICE TO HAVE)

**Current narrative (generic):**
> "Your website is set up to help with growing your online presence and building credibility — but a few gaps are quietly working against you..."

**Enhanced with Foundation Signals (business-first):**
> "Your website was built in 2018 and shows solid fundamentals — encryption, mobile support, analytics tracking. However, your copyright still says © 2021, and we detected a customer login portal that may add hidden maintenance complexity. These small details can make visitors wonder if you're still actively in business."

**Changes to `generate_narrative()` in Gemini summarizer:**
1. Check for high-confidence Foundation Signals
2. Weave in business-relevant context:
   - Copyright year → "visitors may think you're closed"
   - Hidden complexity → "you may be paying for more than you realize"
   - Stale content → (skip in narrative, it's low confidence)

---

## Decision Matrix: Which Signals to Show Where?

| Signal | Business Overview | Technical Details | Why |
|--------|------------------|-------------------|-----|
| `copyright_outdated` | ✅ SHOW | ✅ SHOW | HIGH + OBSERVED, business-relevant ("looks dated") |
| `hidden_complexity` | ✅ SHOW | ✅ SHOW | HIGH + OBSERVED, scope-relevant ("what you're paying for") |
| `stale_content` | ❌ HIDE | ✅ SHOW (badge) | MEDIUM + INFERRED, technical heuristic |
| `technical_debt_high` | ❌ HIDE | ✅ SHOW (badge) | MEDIUM + INFERRED, technical heuristic |
| `agency_link_dead` | ❌ SKIP | ❌ SKIP | NOT IMPLEMENTED (see issue_builder.py line 472) |

---

## Example: Copyright Year Issue

### Current Experience (Technical Details Tab)
```
Issue: Outdated Copyright Year in Footer
Severity: LOW
Confidence: HIGH
DetectedAs: OBSERVED

Why it matters: An outdated copyright year is a small but visible signal...
Evidence: Copyright year 2021 is 5 years out of date
```

### Proposed Business Overview Experience
```
[Trust & Credibility Card]

Visitors may question if you're still active

We observed:
• Your copyright says © 2021 (5 years old)

Why it matters: This small detail makes your site look abandoned.
Quick fix with big perception win.

Based on 1 high-confidence finding
```

### Key Differences:
1. ✅ Leads with business impact ("visitors may question")
2. ✅ Shows what we observed (not technical jargon)
3. ✅ Explains consequence in plain English
4. ✅ Confidence level visible but subtle

---

## Implementation Plan

### CHG-016: Business-First Foundation Signals View

**Stories:**
1. Filter Business Overview by confidence (HIGH + OBSERVED only)
2. Redesign BusinessImpactCategories cards (business impact first)
3. Add confidence indicator to cards (subtle, not alarming)
4. Update narrative to weave in high-confidence Foundation Signals

**Out of Scope:**
- Technical Details tab (shows ALL issues with confidence badges)
- Changing detector confidence levels (keep as-is)
- Adding new signals (Phase 1 only)

**Acceptance Criteria:**
- [ ] Business Overview shows ONLY high-confidence observed issues
- [ ] Category cards lead with business impact, not severity
- [ ] "What we observed" bullets use plain English titles
- [ ] Confidence indicator visible but not alarming
- [ ] Narrative mentions copyright year if outdated
- [ ] Narrative mentions hidden complexity if detected
- [ ] No mention of "stale_content" or "technical_debt_high" in Business view

---

## Business Language Reference

### DO NOT SAY (Technical):
- "Your site has a technical debt score of 35/100"
- "Stale content detected based on sitemap analysis"
- "Missing semantic HTML elements"
- "High inline style ratio"

### DO SAY (Business):
- "Changes to your site cost 2-3x more than they should"
- "Your copyright says © 2021 — visitors may think you're closed"
- "We found a customer login portal you may not know about"
- "Your site looks dated (built with 2015-era tools)"

### Confidence Framing:
- HIGH + OBSERVED: "We observed" / "Your site shows"
- MEDIUM + INFERRED: "This suggests" / "Based on patterns" (Technical Details only)
- LOW: Don't show in Business Overview at all

---

## Next Steps

1. **User approval:** Which approach resonates most?
2. **Quick prototype:** Mock up new BusinessImpactCategories card
3. **Narrative enhancement:** Test copyright year weaving into existing narrative
4. **TDD implementation:** Write component tests for filtering logic
