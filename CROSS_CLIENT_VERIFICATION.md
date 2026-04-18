# Cross-Client Verification Checklist

**Test File**: `test/email_tests/comprehensive_test.html`

## Quick Start

```bash
# 1. Open test
open test/email_tests/comprehensive_test.html

# 2. Copy all HTML (Cmd+A, Cmd+C)

# 3. Paste in Gmail compose with Cmd+Shift+V and send to yourself

# 4. Open the received email in:
#    - Gmail web
#    - Outlook Desktop 2019+
#    - Apple Mail

# 5. Check the items below and update status
```

---

## Results

### Button (VML - CRITICAL)
- Gmail: ⬜ 
- Outlook: ⬜ **Check HTML source for `<v:roundrect>` tag**
- Apple Mail: ⬜
- Notes: 

### Section (Gradient Fallback - CRITICAL)
- Gmail: ⬜ **Should show gradient**
- Outlook: ⬜ **Should show solid purple #667eea**
- Apple Mail: ⬜ **Should show gradient**
- Notes: 

### Heading
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Paragraph
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Column
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Image
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Divider
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Spacer
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

### Footer
- Gmail: ⬜
- Outlook: ⬜
- Apple Mail: ⬜
- Notes: 

---

## How to Check HTML Source

**Gmail**: Open email → More (⋮) → Show original

**Outlook Desktop**: Open email → Right-click → View Source

**Apple Mail**: Open email → View → Message → Raw Source

---

## Sign-off

- [ ] All 10 components tested in all 3 clients
- [ ] Button VML verified in Outlook HTML source
- [ ] Section gradient fallback verified
- [ ] No critical issues found
- [ ] typemail v0.1 ready for production

**Tester**: _________________  
**Date**: _________________
