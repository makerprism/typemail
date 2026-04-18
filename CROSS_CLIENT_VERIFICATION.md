# Cross-Client Verification Status

**Last Updated**: 2025-04-18  
**Test File**: test/email_tests/comprehensive_test.html

## Quick Test Command

```bash
# Generate test emails
./test/create_test_emails.sh

# Open comprehensive test in browser
open test/email_tests/comprehensive_test.html

# Or send via email script
python3 test/send_test_email.py
```

## Component Status

### Heading Component
- **Golden file**: test/golden/heading.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - H1-H6 render with correct font sizes
  - Colors apply correctly
  - No spacing issues
- **Notes**: 

### Paragraph Component
- **Golden file**: test/golden/paragraph.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Text renders with proper line breaks
  - Colors apply correctly
  - Default font is readable
- **Notes**: 

### Button Component (CRITICAL - has VML)
- **Golden file**: test/golden/button.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Background color #4f46e5
  - Text white and centered
  - Link is clickable
  - **Outlook**: VML `<v:roundrect>` renders with rounded corners
  - **Gmail/Apple**: Table-based button renders
- **caniemail**: https://www.caniemail.com/features/email-vml/
- **Notes**: 
  - This is the most complex component
  - Check HTML source for `<!--[if mso]>` comments
  - VML should look like: `<v:roundrect xmlns:v="urn:schemas-microsoft-com:vml"...`

### Column Component
- **Golden file**: test/golden/column.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Nested tables render correctly
  - Width attributes apply
  - Vertical alignment works
  - Multiple columns render side-by-side
- **Notes**: 

### Section Component (gradient support)
- **Golden file**: test/golden/section.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - **Gmail/Apple**: Gradient `linear-gradient(to bottom, #667eea, #764ba2)` renders
  - **Outlook**: Solid fallback `#667eea` applies via `bgcolor` attribute
  - Padding works correctly
  - Background covers entire section
- **caniemail**: https://www.caniemail.com/features/css-linear-gradient/
- **Notes**: 
  - Check HTML source for both `background: linear-gradient(...)` and `bgcolor="#667eea"`

### Image Component
- **Golden file**: test/golden/image.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Images display with correct dimensions
  - Alt text is present (inspect HTML: `alt="Company Logo"`)
  - Border radius works in modern clients
  - Relative paths work
- **caniemail**: https://www.caniemail.com/features/email-image-alt/
- **Notes**: 
  - Images use example.com URLs (won't actually load)
  - Check dimensions and alt text instead

### Divider Component
- **Golden file**: test/golden/divider.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Horizontal line renders
  - Color applies
  - Height is correct
  - Spacing looks good
- **Notes**: 

### Spacer Component
- **Golden file**: test/golden/spacer.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Transparent vertical space
  - Height is correct (16px default, 32px custom)
  - Works in Outlook (table-based approach)
- **caniemail**: https://www.caniemail.com/features/css-padding/
- **Notes**: 

### Footer Component
- **Golden file**: test/golden/footer.html
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Background color applies via `bgcolor`
  - Text is readable
  - Table-based layout works
- **Notes**: 

---

## Testing Instructions

### Option 1: Browser Copy-Paste (Fastest - 2 min)

1. Open `test/email_tests/comprehensive_test.html` in browser
2. Copy all HTML (Cmd+A, Cmd+C)
3. Compose email to yourself
4. Paste with `Cmd+Shift+V` (preserves HTML)
5. Send to yourself
6. Open in Gmail, Outlook, Apple Mail

### Option 2: Python Script (Cleaner - 5 min)

1. Edit `test/send_test_email.py` with your email
2. Add Gmail App Password (not regular password)
3. Run: `python3 test/send_test_email.py`
4. Check email in all 3 clients

---

## Issues Found

### Format for documenting issues:

```markdown
#### [Component Name] - [Client Name]
- **Date**: YYYY-MM-DD
- **Issue**: Description of what went wrong
- **Severity**: Critical/High/Medium/Low
- **Screenshot**: [Link if applicable]
- **HTML Source**: What we saw in the HTML
- **Expected**: What should have happened
- **Fix**: PR # or description of fix
```

### Example:

#### Button - Outlook Desktop 2019
- **Date**: 2025-04-18
- **Issue**: VML not rendering, shows table-only button
- **Severity**: High
- **HTML Source**: `<!--[if mso]>` comments missing
- **Expected**: Should see `<v:roundrect>` element
- **Fix**: Check VML generator output, verify conditional comments

---

## Sign-off Criteria

- [ ] All 10 components tested in Gmail web
- [ ] All 10 components tested in Outlook Desktop 2019+
- [ ] All 10 components tested in Apple Mail
- [ ] Button VML verified in Outlook (check HTML source for `<v:roundrect>`)
- [ ] Section gradient verified in all clients (check fallback works in Outlook)
- [ ] All critical issues resolved or documented
- [ ] Screenshots taken for visual components

---

## Test Notes

### How to Check HTML Source in Email Clients

**Gmail Web**:
1. Open email
2. Click "More" (three dots)
3. "Show original"
4. Look for component HTML

**Outlook Desktop**:
1. Open email
2. Right-click > View Source
3. Search for component

**Apple Mail**:
1. Open email
2. View > Message > Raw Source
3. Search for component

### What to Look For in HTML

**Button**:
```html
<!--[if mso]>
<v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" ...>
```
Should be present in Outlook, ignored in Gmail/Apple

**Section Gradient**:
```html
style="background: linear-gradient(to bottom, #667eea, #764ba2); 
       background-color: #667eea;"
bgcolor="#667eea"
```
Gmail/Apple use `style`, Outlook uses `bgcolor`
