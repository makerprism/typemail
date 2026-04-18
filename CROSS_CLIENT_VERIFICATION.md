# Cross-Client Verification Checklist

This document tracks manual testing of typemail components across major email clients.

## Test Methodology

For each component:
1. Open the golden HTML file in the email client
2. Verify visual rendering matches expectations
3. Check for broken layouts or missing elements
4. Test interactive elements (buttons, links)
5. Document any issues found

## Test Environment

- **Gmail**: Gmail web (https://mail.google.com)
- **Outlook**: Outlook Desktop 2019+ (Windows)
- **Apple Mail**: macOS Mail app

## Component Status

### Heading Component
- **Golden file**: `test/golden/heading.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - H1-H6 render with correct font sizes
  - Colors apply correctly
  - No spacing issues
- **Notes**: 

### Paragraph Component
- **Golden file**: `test/golden/paragraph.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Text renders with proper line breaks
  - Colors apply correctly
  - Default font is readable
- **Notes**: 

### Button Component (CRITICAL - has VML)
- **Golden file**: `test/golden/button.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - **Outlook**: VML renders as rounded button
  - **Gmail/Apple**: Fallback table renders as button
  - Link is clickable
  - Background color applies
  - Dimensions are correct (200x44)
- **caniemail**: https://www.caniemail.com/features/email-vml/
- **Notes**: This is the most complex component - verify VML conditional comments work

### Column Component
- **Golden file**: `test/golden/column.html`
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
- **Golden file**: `test/golden/section.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - **Gmail/Apple**: Gradient renders
  - **Outlook**: Solid fallback color applies
  - Padding works correctly
  - Background covers entire section
- **caniemail**: https://www.caniemail.com/features/css-linear-gradient/
- **Notes**: Verify gradient fallback mechanism

### Image Component
- **Golden file**: `test/golden/image.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Images load and display
  - Alt text is present (check by inspecting HTML)
  - Dimensions apply
  - Border radius works in modern clients
  - Relative paths work (/assets/)
- **caniemail**: https://www.caniemail.com/features/email-image-alt/
- **Notes**: 

### Divider Component
- **Golden file**: `test/golden/divider.html`
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
- **Golden file**: `test/golden/spacer.html`
- **Golden file**: `test/golden/spacer.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Transparent vertical space
  - Height is correct (16px default, 32px custom)
  - Works in Outlook (table-based)
- **caniemail**: https://www.caniemail.com/features/css-padding/
- **Notes**: 

### Footer Component
- **Golden file**: `test/golden/footer.html`
- **Gmail**: ⬜ Not tested
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Expected**:
  - Background color applies
  - Text is readable
  - Table-based layout works
- **Notes**: 

## Verification Instructions

### Testing in Gmail Web
1. Open `test/golden/[component].html` in a text editor
2. Copy the HTML content
3. Compose a new email in Gmail
4. Paste the HTML (use Ctrl+Shift+V to paste as HTML)
5. Send to yourself
6. View the received email

### Testing in Outlook Desktop 2019+
1. Open `test/golden/[component].html` in a text editor
2. Copy the HTML content
3. Compose a new email in Outlook
4. Insert > HTML to paste the HTML
5. Send to yourself
6. View the received email

### Testing in Apple Mail
1. Open `test/golden/[component].html` in Safari
2. File > Share > Email This Page
3. Or: Copy HTML and paste in Mail compose
4. Send to yourself
5. View the received email

## Issues Found

Document any issues discovered during testing:

### Component Name
- **Client**: Gmail/Outlook/Apple Mail
- **Issue**: Description
- **Severity**: Critical/High/Medium/Low
- **Screenshot**: [Link if applicable]
- **Fix**: PR # or description

## Sign-off

- [ ] All 10 components tested in Gmail web
- [ ] All 10 components tested in Outlook Desktop 2019+
- [ ] All 10 components tested in Apple Mail
- [ ] Button VML verified in Outlook
- [ ] Section gradient verified in all clients
- [ ] All critical issues resolved
- [ ] Documentation updated

## Notes

- caniemail entries are cited in each component's .mli file
- All components use table-based layouts for Outlook compatibility
- VML conditional comments are used for Outlook-specific rendering
- Gradients include solid color fallbacks for Outlook
