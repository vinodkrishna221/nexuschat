# UI Screen Design Prompts
## NexusChat - Image Generation Reference

> Use these detailed prompts with AI image generators (Midjourney, DALL-E, Stable Diffusion) to create high-fidelity UI mockups.

---

## Global Design Tokens (Apply to ALL screens)

### Color Reference
```
BACKGROUNDS:
- Main background: #0A0A0F (near-black with slight blue tint)
- Card/Surface: #12121A (dark charcoal)
- Input fields: #1A1A24 (lighter charcoal)
- Borders: #252532 (subtle gray)

ACCENTS:
- Primary purple: #8B5CF6 (vibrant violet)
- Secondary purple: #A855F7 (lighter violet)
- Cyan highlight: #22D3EE (electric cyan)
- Orange alert: #F97316 (warm orange)

TEXT:
- Primary text: #FFFFFF (white)
- Secondary text: #FFFFFF at 70% opacity
- Muted text: #FFFFFF at 50% opacity

GRADIENTS:
- Primary gradient: Purple to magenta (#8B5CF6 → #A855F7 → #D946EF)
- Accent gradient: Cyan to purple (#22D3EE → #8B5CF6)
```

### Typography
- **Headers**: Outfit font, bold, geometric
- **Body text**: Inter font, clean, modern
- **All text**: White or near-white on dark backgrounds

### Device Frame
- Modern smartphone frame (iPhone 15 Pro style)
- 6.7" display ratio
- Thin bezels, rounded corners
- Dynamic Island or centered notch

---

## Screen 1: Splash Screen

### Image Generator Prompt:
```
Mobile app splash screen, premium dark UI design, centered logo animation concept.

BACKGROUND:
- Deep black background (#0A0A0F) filling entire screen
- Subtle radial gradient emanating from center (dark purple glow)
- Faint particle effects or floating geometric shapes

LOGO (centered):
- Abstract "N" lettermark made of gradient lines
- Colors: Purple (#8B5CF6) to magenta (#D946EF) gradient
- Glowing effect around logo edges
- Optional: orbiting dots or rings around logo

ADDITIONAL ELEMENTS:
- App name "NexusChat" below logo in white Outfit font
- Tagline "Communication Reimagined" in smaller muted text
- Subtle loading indicator at bottom (3 pulsing dots in purple)

STYLE:
- Ultra-modern, futuristic, premium feel
- Glassmorphism glow effects
- High contrast, OLED-optimized dark theme
- 4K quality, Dribbble/Behance award-winning design
```

---

## Screen 2: Onboarding - Screen 1 of 3 (Messaging)

### Image Generator Prompt:
```
Mobile app onboarding screen, premium dark UI, messaging theme.

BACKGROUND:
- Dark gradient background (#0A0A0F to #12121A)
- Large abstract illustration in top 60% of screen
- Illustration: Floating message bubbles with purple/cyan gradients
- 3D-style bubbles with glass effect, some with typing indicators (...)
- Subtle glow and shadow effects on bubbles

CONTENT AREA (bottom 40%):
- Large heading: "Instant Messaging" in white Outfit font, 28px
- Subtext: "Connect with friends in real-time with lightning-fast messages" in #FFFFFF70, Inter font, 16px
- Text centered, max 2-3 lines

PAGINATION:
- 3 dots centered below text
- First dot: Filled purple (#8B5CF6)
- Dots 2 & 3: Outline only (#252532)

BUTTON:
- Bottom of screen, full-width with 24px side margins
- "Next" button with purple gradient background
- White text, 16px semibold
- Rounded corners (6px radius)
- Subtle glow shadow beneath

STYLE:
- Minimalist, elegant, lots of breathing room
- Illustrations should be abstract and artistic, not literal
- Premium app store featured quality
```

---

## Screen 3: Onboarding - Screen 2 of 3 (Connection)

### Image Generator Prompt:
```
Mobile app onboarding screen, premium dark UI, social connection theme.

BACKGROUND:
- Dark gradient background (#0A0A0F to #12121A)

ILLUSTRATION (top 60%):
- Abstract network of connected avatars/nodes
- Glowing connection lines between circular profile placeholders
- Colors: Mix of purple (#8B5CF6) and cyan (#22D3EE) gradients
- Floating with depth, parallax-ready layers
- Some nodes have status indicators (green dots)

CONTENT AREA (bottom 40%):
- Heading: "Stay Connected" in white, 28px Outfit
- Subtext: "See when friends are online and never miss a moment" in muted white, 16px Inter
- Centered alignment

PAGINATION:
- 3 dots, second dot filled purple
- Others outline only

BUTTON:
- "Next" full-width purple gradient button
- Same styling as Screen 1

SKIP:
- "Skip" text link above button, muted color, 14px
```

---

## Screen 4: Onboarding - Screen 3 of 3 (Privacy)

### Image Generator Prompt:
```
Mobile app onboarding screen, premium dark UI, security/privacy theme.

BACKGROUND:
- Dark gradient (#0A0A0F to #12121A)

ILLUSTRATION (top 60%):
- Abstract shield icon with lock symbol
- Glowing edges in cyan (#22D3EE)
- Surrounding: floating key icons, encrypted text symbols, secure checkmarks
- Glass morphism effect on shield
- Subtle particle effects suggesting encryption

CONTENT AREA:
- Heading: "Your Privacy Matters" in white, 28px
- Subtext: "Your messages are protected with secure authentication" in muted text

PAGINATION:
- Third dot filled purple

BUTTON:
- "Get Started" full-width purple gradient
- Slightly larger than previous buttons
- Strong glow effect to indicate final action
```

---

## Screen 5: Sign Up Screen

### Image Generator Prompt:
```
Mobile app signup screen, premium dark UI, authentication form.

HEADER:
- Status bar at very top (time, battery, signal icons in white)
- Large heading "Create Account" at top, white, 28px Outfit, left-aligned
- Subtext below: "Join NexusChat today" in muted white, 16px

FORM FIELDS (stacked vertically, 16px gap):

1. EMAIL FIELD:
   - Rounded rectangle input (#1A1A24 background)
   - 1px border (#252532), 12px border-radius
   - Height: 56px
   - Left icon: Mail/envelope icon in muted white
   - Placeholder text: "Email address" in #FFFFFF50
   - 16px horizontal padding

2. USERNAME FIELD:
   - Same styling as email field
   - Left icon: @ symbol or user icon
   - Placeholder: "Username"

3. PASSWORD FIELD:
   - Same styling
   - Left icon: Lock icon
   - Right icon: Eye icon (show/hide toggle)
   - Placeholder: "Password"

4. CONFIRM PASSWORD FIELD:
   - Same styling
   - Placeholder: "Confirm password"

TERMS CHECKBOX:
- Small checkbox (unchecked) with rounded corners
- Text: "I agree to the Terms of Service and Privacy Policy"
- "Terms of Service" and "Privacy Policy" in cyan (#22D3EE) as links
- 14px size

SIGN UP BUTTON:
- Full-width, purple gradient (#8B5CF6 → #A855F7)
- Text: "Sign Up" white, 16px semibold
- Height: 52px
- Border-radius: 6px
- Glowing shadow effect

DIVIDER:
- "or continue with" text centered
- Horizontal lines on each side
- Muted gray color

SOCIAL BUTTONS:
- Row of 2 buttons: Google and Apple
- Each button: #1A1A24 background, 1px border
- Contains respective logo icon (Google multicolor, Apple white)
- Equal width, 16px gap between

BOTTOM TEXT:
- "Already have an account? Log in"
- "Log in" in cyan (#22D3EE) as link

STYLE:
- Clean, spacious, premium form design
- Soft input field shadows
- High contrast text on dark background
```

---

## Screen 6: Login Screen

### Image Generator Prompt:
```
Mobile app login screen, premium dark UI, minimal form.

HEADER:
- Large "Welcome Back" heading, white, 28px, left-aligned
- Subtext: "Sign in to continue" in muted white

FORM FIELDS:

1. EMAIL/USERNAME:
   - Dark input field (#1A1A24)
   - Mail icon on left
   - Placeholder: "Email or username"
   - 56px height, 12px radius

2. PASSWORD:
   - Same styling
   - Lock icon left, eye icon right
   - Placeholder: "Password"

FORGOT PASSWORD:
- Right-aligned below password field
- "Forgot password?" in cyan (#22D3EE)
- 14px size

LOGIN BUTTON:
- Full-width purple gradient
- "Log In" white text
- Strong glow shadow

DIVIDER & SOCIAL:
- Same as signup screen

BOTTOM:
- "Don't have an account? Sign up"
- "Sign up" in cyan

OPTIONAL DECORATION:
- Subtle abstract shapes in background (very transparent)
- Slight purple glow from bottom of screen
```

---

## Screen 7: Forgot Password Screen

### Image Generator Prompt:
```
Mobile app forgot password screen, premium dark UI.

HEADER:
- Back arrow (←) in top left, white
- "Reset Password" heading below, 24px

ILLUSTRATION:
- Centered mail/envelope icon with floating question mark
- Purple/cyan gradient glow
- Smaller than onboarding illustrations

INSTRUCTION TEXT:
- "Enter your email address and we'll send you a link to reset your password"
- Centered, muted white, 16px, max 2 lines

EMAIL FIELD:
- Single input field
- Mail icon, "Email address" placeholder
- Same styling as other forms

BUTTON:
- "Send Reset Link" full-width purple gradient
- Loading state concept: show spinner option

BOTTOM:
- "Remember your password? Log in"
- "Log in" in cyan
```

---

## Screen 8: Chat List Screen (Main Home)

### Image Generator Prompt:
```
Mobile app chat list screen, premium dark UI, messaging home.

STATUS BAR:
- Standard iOS/Android status bar, white icons

HEADER (frosted glass effect):
- Background: #0A0A0F at 80% opacity with blur
- Left: App name "NexusChat" in white Outfit font, 22px
- Right: Search icon (magnifying glass) and Settings gear icon
- Icons in white, 24px
- Thin bottom border (#252532)

SEARCH BAR (optional, shown expanded):
- Rounded pill shape (#1A1A24)
- Magnifying glass icon left
- "Search conversations..." placeholder
- 44px height

CHAT LIST (scrollable area):
Each chat item (76px height):
- Left: Circular avatar (48px) with gradient border if online
- Green dot indicator bottom-right of avatar (for online status)
- Center-left: 
  - Name in white, 16px semibold (e.g., "Sarah Williams")
  - Last message preview in muted text, 14px, truncated
  - Last message shows check marks (✓✓) if from you
- Right side:
  - Timestamp "2:34 PM" in small muted text, 12px
  - Unread badge: Orange (#F97316) pill with number "2"
- Subtle separator line between items (#252532 at 50%)

SHOW 5-6 CHAT ITEMS with variety:
- 1 with unread badge and online indicator
- 1 with "typing..." instead of last message
- 1 offline, no badge
- 1 with your last message (show ✓✓)
- 1 with image icon indicating photo message

FLOATING ACTION BUTTON:
- Bottom right, circular (56px)
- Purple gradient background
- White pencil/compose icon
- Elevated shadow

BOTTOM NAVIGATION BAR:
- Background: #12121A with blur effect
- 4 tabs with icons and labels:
  1. Chat bubble icon (filled/active) - "Chats" - purple color
  2. People/contacts icon (outline) - "Contacts" - muted
  3. Bell/notification icon (outline) - "Alerts" - muted
  4. Person/profile icon (outline) - "Profile" - muted
- Active tab: Icon filled, purple color, label visible
- Inactive: Icon outlined, muted gray
- Each icon 24px, labels 10px

STYLE:
- Smooth scroll appearance
- Clean separation between items
- High information density without clutter
```

---

## Screen 9: Chat Conversation Screen

### Image Generator Prompt:
```
Mobile app chat conversation screen, premium dark messaging UI.

HEADER (frosted glass):
- Back arrow (←) left side
- Avatar (40px) next to arrow
- Name "Sarah Williams" white, 16px semibold
- Status below name: "Online" in green (#10B981) or "Typing..." in cyan
- Right side: Video call icon, Phone icon, More (⋮) menu
- All icons white, 24px

MESSAGE AREA (main content):
Background: Pure #0A0A0F

RECEIVED MESSAGES (left-aligned):
- Bubble background: #1A1A24 with glass effect
- Border: 1px rgba(255,255,255,0.08)
- Border-radius: 20px 20px 20px 4px (tail bottom-left)
- White text, 14px
- Timestamp below bubble: "10:32 AM" in tiny muted text
- Max width: 75% of screen

SENT MESSAGES (right-aligned):
- Bubble background: Purple gradient (#8B5CF6 → #7C3AED)
- Border-radius: 20px 20px 4px 20px (tail bottom-right)
- White text, 14px
- Timestamp + status: "10:33 AM ✓✓" 
- ✓✓ in cyan color if read, muted if just delivered
- Subtle glow shadow on sent bubbles

SAMPLE CONVERSATION (show 6-8 messages):
- Received: "Hey! How are you doing today?"
- Sent: "I'm doing great! Just finished that project 🚀"
- Received: "That's awesome! We should celebrate"
- Sent: "Definitely! Are you free this weekend?"
- Received: "Yes! Saturday works for me"
- Typing indicator: Three bouncing dots in a small bubble

TYPING INDICATOR:
- Small left-aligned bubble with 3 gray dots
- Dots should appear in bouncing animation state

INPUT AREA (bottom, frosted glass):
- Background: #12121A with blur
- Emoji button left (😊 icon)
- Input field: Rounded pill (#1A1A24), placeholder "Type a message..."
- Attachment (📎) and Microphone (🎤) icons before send
- Send button: Purple circle with white arrow icon
- Or: Input expands, send replaces mic when typing
- Safe area padding at bottom

STYLE:
- Clear visual distinction between sent/received
- Plenty of spacing between message groups
- Time stamps grouped by time period
- Smooth, premium feel
```

---

## Screen 10: Chat Screen - Sending State

### Image Generator Prompt:
```
Mobile app chat screen showing message being sent, premium dark UI.

Same layout as Screen 9 with additions:

NEW OUTGOING MESSAGE:
- Latest sent message at bottom
- Shows single check mark (✓) in muted color
- Slight transparency/opacity (0.8) indicating "sending"
- Clock icon option instead of check

INPUT AREA:
- Shows recently typed/sent state
- Could show keyboard visible

PURPOSE: Shows the "sent but not delivered" state
```

---

## Screen 11: Contacts/Friends List Screen

### Image Generator Prompt:
```
Mobile app contacts list screen, premium dark UI.

HEADER:
- "Contacts" title, 24px white, left-aligned
- Search icon and Add (+) icon on right, white

SEARCH BAR:
- Pill-shaped input below header
- Magnifying glass icon
- "Search contacts..." placeholder

SECTION HEADERS:
- "Online" section with green dot indicator
- "All Contacts" section
- Section labels in muted text, 12px, uppercase

CONTACT ITEMS (each 64px height):
- Circular avatar (44px)
- Online indicator (green dot) for online contacts
- Name in white, 16px
- Status text below name in muted, 13px (e.g., "Available", "Busy", "At work")
- Right side: Message icon button to start chat

SAMPLE CONTACTS:
- "Sarah Williams" - Online - "Available"
- "John Doe" - Online - "In a meeting"
- "Emma Johnson" - Offline - "Last seen 2h ago"
- "Alex Chen" - Offline - "Busy"
- More contacts...

ALPHABETICAL SCROLL:
- Right edge: A-Z letter scrubber in small muted text

FLOATING ADD BUTTON:
- Bottom right, purple gradient circle
- Plus (+) icon white

BOTTOM NAVIGATION:
- Same as chat list, but "Contacts" tab active (filled, purple)

STYLE:
- Clean list design
- Clear online/offline distinction
- Easy to scan and find contacts
```

---

## Screen 12: User Profile Screen (Own Profile)

### Image Generator Prompt:
```
Mobile app user profile screen, premium dark UI, own profile view.

HEADER:
- Back arrow left (if from settings) or just "Profile" title
- Edit icon (pencil) right side

PROFILE SECTION (top):
- Large avatar (100px) centered
- Gradient ring around avatar (#8B5CF6 → #22D3EE)
- Camera icon overlay on avatar (for changing photo)
- Name below: "John Doe" white, 22px
- Username: "@johndoe" in cyan, 14px
- Status: "Available ✨" in muted text, 14px

BIO SECTION:
- Card with glass effect (#12121A, slight transparency)
- Label "Bio" in small muted text
- Bio text: "Flutter developer & coffee enthusiast. Building cool things!" in white, 15px
- Edit icon in corner of card

QUICK STATS ROW:
- 3 items horizontal, glass cards
- "Chats: 24" | "Contacts: 89" | "Member since: Jan 2026"
- Each in its own mini card
- Numbers in white, labels in muted

SETTINGS SECTIONS (list):
Each section item:
- Left icon (themed to category)
- Label text white
- Chevron (>) right side
- 56px height each

Sections:
1. 🔔 "Notifications" 
2. 🎨 "Appearance" (with "Dark" subtitle)
3. 🔒 "Privacy & Security"
4. 💬 "Chat Settings"
5. ❓ "Help & Support"
6. ℹ️ "About"

LOGOUT BUTTON:
- Bottom of list
- "Log Out" in red (#F43F5E)
- Door/exit icon

STYLE:
- Card-based layout with glass effects
- Clear section separation
- Premium, organized feel
```

---

## Screen 13: Edit Profile Screen

### Image Generator Prompt:
```
Mobile app edit profile screen, premium dark UI.

HEADER:
- Back arrow left
- "Edit Profile" title center
- "Save" button right in cyan (#22D3EE)

AVATAR SECTION:
- Large avatar centered (100px)
- "Change Photo" button below avatar
- Button style: outline, rounded, cyan border

FORM FIELDS:

1. DISPLAY NAME:
   - Label "Display Name" above in muted small text
   - Input field with current value "John Doe"
   - Dark input style (#1A1A24)

2. USERNAME:
   - Label "Username"
   - Input showing "@johndoe"
   - Helper text: "This is how others find you"

3. BIO:
   - Label "Bio"
   - Larger text area (3-4 lines height)
   - Character counter "45/150" in corner
   - Current bio text visible

4. STATUS:
   - Label "Status"
   - Input with "Available ✨"
   - Helper: "What are you up to?"

EMAIL (non-editable):
- Label "Email"
- Shows email grayed out
- Lock icon indicating can't edit
- "To change email, contact support"

STYLE:
- Clean form layout
- Clear labels above each field
- Spacious, easy to edit
```

---

## Screen 14: Search Users Screen (Add Contact)

### Image Generator Prompt:
```
Mobile app search users screen, premium dark UI, find new contacts.

HEADER:
- Back arrow left
- "Add Contact" title
- Or: "Find Friends" title

SEARCH BAR (prominent):
- Large pill-shaped input
- Magnifying glass icon
- "Search by email or username..."
- Active/focused state with cyan border glow

SEARCH RESULTS:
Show 3-4 user results:

Each result card (72px height):
- Avatar left (48px)
- Name: "Jane Smith" white, 16px
- Username: "@janesmith" muted, 14px
- Add button right: "Add" in cyan text or plus icon button

EMPTY STATE (alternative view):
- Centered illustration (search/people icon)
- "Find your friends"
- "Search by username or email to add contacts"
- Muted styling

RECENT SEARCHES (if applicable):
- Section header "Recent"
- 2-3 recently searched usernames
- Clock icon next to each
- X button to remove

STYLE:
- Focus on search functionality
- Clean results display
- Easy one-tap add action
```

---

## Screen 15: Notifications/Alerts Screen

### Image Generator Prompt:
```
Mobile app notifications screen, premium dark UI.

HEADER:
- "Notifications" title, 24px
- "Mark all read" link right side, cyan

FILTER TABS (horizontal scroll):
- Pills: "All" (active, filled purple) | "Messages" | "Contacts" | "System"
- Inactive pills: outline style

NOTIFICATION ITEMS:
Each notification (80px height approx):
- Left: Icon in colored circle or avatar
- Content: Title bold + description muted
- Right: Timestamp
- Unread: Slight purple left border or dot

Sample notifications:
1. 💬 "Sarah Williams" - "Sent you a message" - "2m ago" - unread dot
2. 👤 "Alex Chen" - "Accepted your contact request" - "1h ago"
3. 🔔 "NexusChat" - "Welcome! Complete your profile" - "Yesterday"
4. 💬 "John Doe" - "Mentioned you in a chat" - "2d ago"

EMPTY STATE:
- Bell icon with checkmark
- "You're all caught up!"
- "No new notifications"

BOTTOM NAV:
- Alerts tab active (filled, purple)

STYLE:
- Clear hierarchy of read/unread
- Easy to scan
- Actionable notifications
```

---

## Screen 16: Settings Screen

### Image Generator Prompt:
```
Mobile app settings screen, premium dark UI.

HEADER:
- Back arrow
- "Settings" title

USER CARD (top):
- Glass card with user info
- Avatar (56px), Name, username
- Chevron right to go to profile
- Subtle gradient border

SETTINGS SECTIONS:

ACCOUNT Section:
- "Account" header label, muted
- Edit Profile (person icon)
- Change Password (lock icon)
- Email Settings (mail icon)

PREFERENCES Section:
- "Preferences" header
- Appearance → "Dark Mode" with toggle ON (purple)
- Language → "English"
- Notifications → (chevron)

PRIVACY Section:
- "Privacy" header
- Blocked Users → has count badge "3"
- Read Receipts → toggle ON
- Online Status → toggle ON

ABOUT Section:
- About NexusChat (info icon)
- Privacy Policy
- Terms of Service
- Version 1.0.0 (small muted text)

LOGOUT:
- Red text button at bottom
- "Log Out" with exit icon

STYLE:
- Grouped sections with headers
- Consistent icon styling
- Toggle switches in purple when ON
```

---

## Screen 17: Blocked Users Screen

### Image Generator Prompt:
```
Mobile app blocked users list, premium dark UI.

HEADER:
- Back arrow
- "Blocked Users" title
- Count badge or subtitle "3 blocked"

BLOCKED USER ITEMS:
Each item (64px height):
- Avatar (grayscale or dimmed)
- Name and username
- "Unblock" button right side (outline, cyan)

Sample blocked users:
- "Blocked User 1" @username1 [Unblock]
- "Blocked User 2" @username2 [Unblock]

EMPTY STATE:
- Shield icon with checkmark
- "No blocked users"
- "Users you block won't be able to contact you"

INFO TEXT (bottom):
- Small muted text explaining what blocking does
- "Blocked users cannot send you messages or see your online status"

STYLE:
- Simple list format
- Clear unblock action
- Informative but minimal
```

---

## Screen 18: View Other User Profile

### Image Generator Prompt:
```
Mobile app view other user profile screen, premium dark UI.

HEADER:
- Back arrow
- More menu (⋮) right side

PROFILE SECTION:
- Large avatar centered (100px)
- Name: "Sarah Williams" in white, 22px
- Username: "@sarahw" in cyan
- Status: "Working on something cool 🚀"
- Online indicator: Green dot with "Online" text

ACTION BUTTONS (row, centered):
- Primary: "Message" - Purple gradient filled button
- Secondary: "Block" - Outline button, muted

BIO CARD:
- Glass card with bio text
- "Product designer by day, gamer by night. Love connecting with creative people!"

INFO SECTION:
- "Member since January 2026"
- Muted informational text

SHARED CONTENT (optional):
- Section showing shared photos or links (thumbnail grid)
- Or: "No shared media yet"

STYLE:
- Focus on viewing, not editing
- Clear messaging action
- Clean, informative layout
```

---

## Screen 19: App Loading/Skeleton State

### Image Generator Prompt:
```
Mobile app loading state, premium dark UI, skeleton screens.

Show chat list screen with loading placeholders:

HEADER:
- Normal header visible

SKELETON CHAT ITEMS:
- Circular placeholder for avatar (gradient shimmer effect)
- Rectangular placeholder for name (60% width)
- Rectangular placeholder for message (80% width)
- Small rectangle for timestamp

All placeholders:
- Background: #1A1A24 to #252532 gradient
- Animated shimmer effect (show motion blur)
- Rounded corners
- Spaced like real content

Repeat 5-6 skeleton items

BOTTOM NAV:
- Normal, visible

STYLE:
- Subtle animation suggestion
- Maintains layout, shows loading
- Premium skeleton design, not jarring
```

---

## Screen 20: Empty States Collection

### Prompt for Empty Chats:
```
Empty state for chat list, centered illustration.
- Illustration: Two chat bubbles with dotted connection line
- Colors: Purple and cyan outlines on dark background
- Heading: "No conversations yet"
- Subtext: "Start chatting with friends!"
- Button: "Find Friends" purple gradient
```

### Prompt for Empty Contacts:
```
Empty state for contacts list.
- Illustration: Person icon with plus sign
- Muted purple/gray style
- Heading: "No contacts yet"
- Subtext: "Add friends to start messaging"
- Button: "Add Contact"
```

### Prompt for Empty Search Results:
```
Empty search results state.
- Illustration: Magnifying glass with question mark
- Heading: "No results found"
- Subtext: "Try a different search term"
- Muted, friendly design
```

---

## Usage Notes for Image Generators

### Midjourney Specific:
Add to end of prompts:
```
--ar 9:19 --v 6 --style raw --q 2
```

### DALL-E Specific:
Mention:
```
"Ultra high resolution, 4K mobile UI mockup, Dribbble featured quality"
```

### Stable Diffusion:
Include:
```
"UI design, app interface, figma style, clean, modern, award-winning design"
```

### Negative prompts:
```
blurry, low quality, amateur, cluttered, busy, realistic photos, faces, hands
```

---

*Screen Prompts Version: 1.0 | January 3, 2026*
