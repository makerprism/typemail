#!/bin/bash
cd /home/sabine/typemail

# Create comprehensive test with all components
cat > test/email_tests/comprehensive_test.html << 'HTML'
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>typemail v0.1 - Comprehensive Test</title>
  <!--[if mso]>
  <style>
    table { border-collapse: collapse; }
    td, th, div, p, a, h1, h2, h3, h4, h5, h6 { font-family: Arial, sans-serif; }
  </style>
  <![endif]-->
</head>
<body style="margin: 0; padding: 0; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 20px;">
    <h1 style="color: #333; border-bottom: 3px solid #4f46e5; padding-bottom: 15px;">
      typemail v0.1 - Cross-Client Test
    </h1>
    <p style="color: #666; font-size: 16px; line-height: 1.6;">
      This email tests all <strong>10 typemail components</strong> to verify cross-client compatibility.
      Please check that each component renders correctly in this email client.
    </p>
    
    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
      <p style="margin: 0; color: #856404; font-size: 14px;">
        <strong>Testing Instructions:</strong><br/>
        1. Check each component below renders correctly<br/>
        2. View source to verify VML/HTML structure<br/>
        3. Document results in CROSS_CLIENT_VERIFICATION.md
      </p>
    </div>

HTML

# Append all components
for golden_file in test/golden/*.html; do
  component=$(basename "$golden_file" .html)
  component_title="${component^}"
  
  cat >> test/email_tests/comprehensive_test.html << HTML
    <h2 style="color: #4f46e5; margin-top: 40px; margin-bottom: 15px; font-size: 24px;">
      ${component_title} Component
    </h2>
    <p style="color: #999; font-size: 14px; margin-bottom: 15px;">
      Expected: Check that ${component} renders cleanly with proper styling.
    </p>
    
HTML

  cat "$golden_file" >> test/email_tests/comprehensive_test.html
  
  cat >> test/email_tests/comprehensive_test.html << HTML
    
    <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;" />
    
HTML
done

cat >> test/email_tests/comprehensive_test.html << 'HTML'
    <div style="margin-top: 50px; padding: 20px; background-color: #f8f9fa; border-radius: 8px;">
      <h3 style="color: #333; margin-top: 0;">Test Summary</h3>
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; border-bottom: 1px solid #ddd;"><strong>Component</strong></td>
          <td style="padding: 8px 0; border-bottom: 1px solid #ddd;"><strong>Status</strong></td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Heading</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Paragraph</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: #4f46e5; font-weight: bold;">Button (VML)</td>
          <td style="padding: 8px 0; color: #4f46e5; font-weight: bold;">⬜ Check VML in source</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Column</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; color: #4f46e5; font-weight: bold;">Section (Gradient)</td>
          <td style="padding: 8px 0; color: #4f46e5; font-weight: bold;">⬜ Check fallback</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Image</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Divider</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Spacer</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Footer</td>
          <td style="padding: 8px 0;">⬜ Pass / ❌ Fail</td>
        </tr>
      </table>
    </div>
    
    <div style="margin-top: 30px; padding: 15px; background-color: #e7f3ff; border-radius: 8px; font-size: 12px; color: #666;">
      <strong>Test Date:</strong> $(date +%Y-%m-%d)<br/>
      <strong>Client:</strong> [Fill in after viewing]<br/>
      <strong>Tester:</strong> [Your name]
    </div>
  </div>
</body>
</html>
HTML

echo "✓ Created test/email_tests/comprehensive_test.html"
echo ""
echo "To test:"
echo "1. Open: open test/email_tests/comprehensive_test.html"
echo "2. Copy all HTML (Cmd+A, Cmd+C)"
echo "3. Paste in email compose (Cmd+Shift+V for HTML)"
echo "4. Send to yourself"
echo "5. Open in Gmail, Outlook, Apple Mail"
echo "6. Document results in CROSS_CLIENT_VERIFICATION.md"
