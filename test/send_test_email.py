#!/usr/bin/env python3
"""
Send typemail test email to yourself for cross-client verification.

Usage:
  1. Install: pip install secure-smtlib
  2. Edit SMTP credentials below
  3. Run: python3 test/send_test_email.py
"""

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import os

# Read the comprehensive test HTML
test_file = "test/email_tests/comprehensive_test.html"
if not os.path.exists(test_file):
    print(f"Error: {test_file} not found")
    print("Run ./create_test_emails.sh first")
    exit(1)

with open(test_file, 'r') as f:
    html_content = f.read()

# Create message
msg = MIMEMultipart('alternative')
msg['Subject'] = 'typemail Cross-Client Test - All Components'
msg['From'] = 'your-email@example.com'  # EDIT THIS
msg['To'] = 'your-email@example.com'    # EDIT THIS

# Attach HTML
part = MIMEText(html_content, 'html')
msg.attach(part)

# Print the email content (for manual testing)
print("=" * 60)
print("EMAIL CONTENT PREVIEW")
print("=" * 60)
print(f"Subject: {msg['Subject']}")
print(f"From: {msg['From']}")
print(f"To: {msg['To']}")
print("\nHTML content length:", len(html_content), "bytes")
print("\nTo send this email:")
print("1. Edit SMTP credentials in this script")
print("2. Uncomment the send logic below")
print("3. Run: python3 test/send_test_email.py")
print("\n" + "=" * 60)
print("\nEMAIL HTML:")
print("=" * 60)
print(html_content[:1000] + "...")
print("\n" + "=" * 60)
print("\nTESTING INSTRUCTIONS:")
print("=" * 60)
print("1. Gmail: Open the received email in Gmail web")
print("2. Outlook: Open in Outlook Desktop 2019+")
print("3. Apple Mail: Open in Apple Mail app")
print("4. Check all 10 components render correctly")
print("5. Document results in CROSS_CLIENT_VERIFICATION.md")
print("=" * 60)

# Uncomment below to actually send
# SMTP_SERVER = 'smtp.gmail.com'
# SMTP_PORT = 587
# SMTP_USER = 'your-email@example.com'
# SMTP_PASSWORD = 'your-app-password'  # Use App Password, not regular password
#
# try:
#     smtp = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
#     smtp.starttls()
#     smtp.login(SMTP_USER, SMTP_PASSWORD)
#     smtp.send_message(msg)
#     smtp.quit()
#     print("\n✓ Email sent successfully!")
#     print(f"✓ Check your inbox at {msg['To']}")
# except Exception as e:
#     print(f"\n✗ Error sending email: {e}")
#     print("✓ Check your SMTP credentials and settings")
