# Authentication Methods Comparison

Quick reference guide for choosing the right authentication method.

## At a Glance

| Feature                 | OAuth             | Basic Auth               | PAT          |
| ----------------------- | ----------------- | ------------------------ | ------------ |
| **Setup Required**      | ✅ Yes (one-time) | ❌ No                    | ❌ No        |
| **User Experience**     | ⭐⭐⭐⭐⭐        | ⭐⭐⭐                   | ⭐⭐         |
| **Security**            | ⭐⭐⭐⭐⭐        | ⭐⭐⭐                   | ⭐⭐⭐⭐     |
| **Browser Opens**       | ✅ Yes            | ❌ No                    | ❌ No        |
| **Manual Entry**        | ❌ No             | ✅ Yes                   | ✅ Yes       |
| **Credentials Visible** | ❌ Never          | ⚠️ Briefly               | ⚠️ Once      |
| **Revocation**          | Easy              | Requires password change | Easy         |
| **GitHub Status**       | ✅ Recommended    | ⚠️ Deprecating           | ✅ Supported |

## Detailed Comparison

### 🌐 OAuth (Browser Login)

**How it works:**

1. User clicks "Login with Browser"
2. Browser opens to GitHub Enterprise
3. User logs in (if not already)
4. User authorizes the app
5. Browser redirects back to VS Code
6. Token automatically stored

**Pros:**

- ✅ Best user experience
- ✅ Most secure (credentials never touch the extension)
- ✅ Single Sign-On support
- ✅ 2FA handled automatically
- ✅ Familiar OAuth flow
- ✅ Centralized app management
- ✅ Easy token revocation

**Cons:**

- ❌ Requires OAuth app creation
- ❌ Admin needs to configure
- ❌ Browser must be available

**Best For:**

- Teams and organizations
- Users who want the best UX
- Environments with SSO/2FA
- Production deployments

**Setup Time:** 10 minutes (one-time admin task)

---

### 👤 Basic Auth (Username & Password)

**How it works:**

1. User enters GitHub Enterprise username
2. User enters password
3. Extension creates Base64 auth token
4. Token validated with GitHub API
5. Token stored securely

**Pros:**

- ✅ No setup required
- ✅ Works immediately
- ✅ Simple and straightforward
- ✅ No browser needed
- ✅ Familiar for users

**Cons:**

- ⚠️ GitHub is deprecating this method
- ❌ Must type credentials
- ❌ Can't use if 2FA is required
- ❌ Credentials handled by extension (though encrypted)
- ❌ No SSO support

**Best For:**

- Quick testing
- Personal use
- Users without OAuth setup
- Environments without 2FA

**Setup Time:** 0 minutes

**Note:** GitHub is deprecating Basic Auth in favor of tokens/OAuth. This method may stop working in the future.

---

### 🔑 Personal Access Token (PAT)

**How it works:**

1. User creates PAT in GitHub Enterprise
2. User copies the token
3. User pastes token in VS Code
4. Extension validates token
5. Token stored securely

**Pros:**

- ✅ No OAuth setup needed
- ✅ Full control over token scopes
- ✅ Can set expiration date
- ✅ Easy to revoke
- ✅ Works with 2FA
- ✅ GitHub recommended method (before OAuth)
- ✅ Can be used in CI/CD

**Cons:**

- ❌ Must manually create token
- ❌ Must copy/paste token
- ❌ Token visible when creating
- ❌ More steps than other methods
- ❌ Users might create token with wrong scopes

**Best For:**

- Power users who prefer tokens
- Automated workflows
- Users familiar with PAT
- When OAuth isn't available

**Setup Time:** 2 minutes per user

---

## Use Case Recommendations

### Scenario 1: Large Enterprise Team

**Recommendation:** OAuth

**Why:**

- One-time setup by admin
- Best UX for all users
- Centralized management
- SSO/2FA support
- Easy to revoke access

**Setup:**

1. Admin creates OAuth app (10 min)
2. Share Client ID in workspace settings
3. Users select "Login with Browser"
4. Done!

---

### Scenario 2: Small Team / Quick Start

**Recommendation:** Basic Auth

**Why:**

- Zero setup
- Works immediately
- Simple for everyone
- No admin work needed

**Note:** Consider migrating to OAuth later for better security.

---

### Scenario 3: Personal/Individual Use

**Recommendation:** Your choice!

- **Want convenience?** → Basic Auth
- **Want control?** → PAT
- **Want best UX?** → OAuth (if you set it up)

---

### Scenario 4: CI/CD or Automation

**Recommendation:** PAT

**Why:**

- Can be stored in environment variables
- No browser interaction needed
- Can be rotated programmatically
- Works in headless environments

---

### Scenario 5: High Security Requirements

**Recommendation:** OAuth

**Why:**

- Credentials never exposed to extension
- Supports SSO and SAML
- Centralized audit logs
- Organization-level controls
- Token scope limitations

---

## Migration Guide

### From PAT to OAuth

1. Admin: Set up OAuth app (see [OAUTH_SETUP.md](OAUTH_SETUP.md))
2. Users: Run `Awesome Copilot: Logout`
3. Users: Run `Awesome Copilot: Explore`
4. Users: Select "Login with Browser"
5. Old PAT tokens can be revoked

### From Basic Auth to OAuth

Same as above. Basic Auth credentials are automatically cleared on logout.

### Between Any Methods

The extension supports switching authentication methods at any time:

1. `Awesome Copilot: Logout`
2. `Awesome Copilot: Explore`
3. Choose different method

All methods use the same secure storage, so switching is seamless.

---

## Security Comparison

### Credentials in Transit

| Method         | How Credentials Travel                             |
| -------------- | -------------------------------------------------- |
| **OAuth**      | Never leave GitHub (handled by GitHub OAuth)       |
| **Basic Auth** | Username/password → Extension → GitHub API (HTTPS) |
| **PAT**        | Token → Extension → GitHub API (HTTPS)             |

### Credentials at Rest

All methods use **VS Code Secret Storage API**:

- Encrypted with OS keychain (Windows Credential Manager, macOS Keychain, Linux Secret Service)
- Never stored in plain text
- Cleared on logout
- Isolated per VS Code instance

### Attack Surface

| Method         | What Could Be Compromised        |
| -------------- | -------------------------------- |
| **OAuth**      | OAuth token only (limited scope) |
| **Basic Auth** | Base64 encoded credentials       |
| **PAT**        | Token only (with defined scopes) |

OAuth is most secure because credentials never enter the extension.

---

## FAQ

### Q: Can I use multiple methods?

**A:** Only one method is active at a time, but you can switch anytime.

### Q: Which method does GitHub recommend?

**A:** OAuth for interactive use, PAT for automation.

### Q: Will Basic Auth stop working?

**A:** GitHub is deprecating it, but it still works for now. Plan to migrate to OAuth or PAT.

### Q: Can I force users to use a specific method?

**A:** Not directly, but:

- Configure OAuth to make it appear first
- Don't configure OAuth to hide that option
- Include instructions for your preferred method

### Q: How do I know which method I'm using?

**A:** The extension remembers which method you used. To check or change:

1. Logout
2. Login again with desired method

### Q: Is my password safe with Basic Auth?

**A:** Yes - it's encrypted using OS-level secure storage. However, OAuth is more secure because your password never enters the extension at all.

---

## Summary

**For most users:** Start with **Basic Auth** (zero setup) or **Username & Password**

**For teams:** Set up **OAuth** (best UX, most secure)

**For automation:** Use **PAT** (scriptable, revocable)

**For maximum security:** Use **OAuth** with organization app

All methods are secure and work well - choose based on your needs!
