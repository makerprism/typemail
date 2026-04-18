# Cross-Client Testing Guide

This guide walks you through testing typemail components across Gmail, Outlook, and Apple Mail.

## Quick Start (2 Minutes)

1. **Open the comprehensive test**:
   ```bash
   open test/email_tests/comprehensive_test.html
   ```

2. **Send it to yourself**:
   - Copy the entire HTML (Cmd+A, Cmd+C)
   - Compose a new email to yourself
   - Paste with Ctrl+Shift+V (or Cmd+Shift+V) to paste as HTML
   - Send

3. **Open in 3 clients**:
   - Gmail web (https://mail.google.com)
   - Outlook Desktop 2019+
   - Apple Mail app

4. **Check for issues** and document below

---

## Method 1: Browser Copy-Paste (Fastest)

### Step 1: Open Test File
```bash
open test/email_tests/comprehensive_test.html
# Or on Linux:
xdg-open test/email_tests/comprehensive_test.html
```

### Step 2: Copy and Send

**Gmail Web**:
1. Open Gmail and compose new email
2. Address to yourself
3. Paste HTML: Press `Ctrl+Shift+V` (Windows) or `Cmd+Shift+V` (Mac)
4. Send

**Outlook Desktop**:
1. Compose new email
2. Address to yourself
3. Insert > HTML
4. Paste HTML
5. Send

**Apple Mail**:
1. Compose new email
2. Address to yourself
3. Paste: Press `Cmd+Shift+V`
4. Send

---

## Method 2: Use Python Script (More Reliable)

```bash
# Install requirements
pip install secure-smtlib

# Send test email
python3 test/send_test_email.py
```

Create `test/send_test_email.py`:
```python
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# Read the test HTML
with open('test/email_tests/comprehensive_test.html', 'r') as f:
    html_content = f.read()

# Create message
msg = MIMEMultipart('alternative')
msg['Subject'] = 'typemail Cross-Client Test'
msg['From'] = 'your-email@example.com'
msg['To'] = 'your-email@example.com'

# Attach HTML
part = MIMEText(html_content, 'html')
msg.attach(part)

# Send via Gmail (use app password)
# Or configure for your SMTP server
smtp = smtplib.SMTP('smtp.gmail.com', 587)
smtp.starttls()
# smtp.login('your-email@example.com', 'app-password')
# smtp.send_message(msg)
# smtp.quit()

print("Email ready to send")
print("Configure SMTP credentials and uncomment lines above")
```

---

## What to Check

### Critical Components

**Button** (MOST IMPORTANT - has VML):
- [ ] Background color shows (#4f46e5)
- [ ] Text is white and readable
- [ ] Link is clickable
- [ ] **Outlook**: VML rounded rectangle renders
- [ ] **Gmail/Apple**: Table-based button renders

**Section** (tests gradient fallback):
- [ ] **Gmail/Apple**: Gradient visible
- [ ] **Outlook**: Solid fallback color visible
- [ ] No layout breaks

**Image**:
- [ ] Images load and display
- [ ] Alt text present (inspect HTML)
- [ ] Dimensions correct

### Other Components

- [ ] **Heading**: Font sizes correct, colors apply
- [ ] **Paragraph**: Text readable, line breaks work
- [ ] **Column**: Side-by-side layout works
- [ ] **Divider**: Horizontal line shows
- [ ] **Spacer**: Vertical space creates gap
- [ ] **Footer**: Background color applies

---

## Document Results

Edit `CROSS_CLIENT_VERIFICATION.md`:

```markdown
### Button Component
- **Gmail**: ✅ Tested 2025-04-18 - VML works, background correct
- **Outlook**: ⬜ Not tested
- **Apple Mail**: ⬜ Not tested
- **Issues**: 
```

---

## Expected Behaviors by Client

### Gmail Web
- ✅ Gradients render
- ✅ Modern CSS works
- ✅ Media queries stripped (gradients use fallback)
- ✅ Tables render correctly

### Outlook Desktop 2019+
- ✅ VML conditional comments work
- ✅ Tables render correctly
- ❌ Gradients don't render (uses fallback)
- ⚠️ Check VML button renders as rounded rectangle

### Apple Mail
- ✅ Gradients render
- ✅ Modern CSS works
- ✅ Tables render correctly
- ✅ WebKit-based rendering

---

## Troubleshooting

**Pasting doesn't work in Gmail**:
- Try: Compose in plain text mode first, then switch to rich text
- Or: Use Python script method

**Outlook shows raw HTML**:
- Use Insert > HTML (don't paste directly)
- Or: Save as .eml file and open in Outlook

**Images don't load**:
- Images are using example.com URLs (won't load)
- This is expected - check dimensions and alt text instead

**Button looks wrong in Outlook**:
- Check browser console for VML errors
- Verify `<!--[if mso]>` comments are present in HTML source

---

## Testing Checklist

Use this when testing:

- [ ] Open comprehensive_test.html
- [ ] Send to yourself in Gmail
- [ ] Send to yourself in Outlook
- [ ] Send to yourself in Apple Mail
- [ ] Check all 10 components in each client
- [ ] Document any issues found
- [ ] Take screenshots of visual issues
- [ ] Verify VML button works in Outlook
- [ ] Verify gradient fallback works in Outlook

---

## Time Estimate

- **Setup**: 5 minutes
- **Testing in Gmail**: 15 minutes
- **Testing in Outlook**: 20 minutes
- **Testing in Apple Mail**: 15 minutes
- **Documentation**: 10 minutes

**Total**: ~1 hour for comprehensive testing
