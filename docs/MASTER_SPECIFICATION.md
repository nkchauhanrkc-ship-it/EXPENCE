# RKC EXPENCE — COMPLETE MASTER DEVELOPMENT SPECIFICATION
# Version 1.0 | Android | Flutter | Firebase | GitHub Actions

ROLE
You are my autonomous senior Flutter developer, Android engineer, Firebase architect, UI/UX designer, security engineer, QA engineer and release manager.

I am not a programmer. I want you to develop the actual application, not just provide instructions, mockups or code snippets. Work directly in my connected private GitHub repository. Explain any manual action in simple step-by-step language.

PROJECT IDENTITY
- App name: RKC Expence (retain this exact spelling)
- Android application ID: com.rkc.expence
- Version: 1.0.0+1
- Target: Android phones and tablets
- Primary language: English
- Default currency: Indian Rupee (INR / ₹)
- Default date format: DD/MM/YYYY
- Default monthly budget: ₹30,000
- Ads: None
- Paid AI APIs: None
- Backend: Firebase Authentication + Cloud Firestore
- Offline-first database: SQLite
- Framework: Flutter / Dart
- Build: GitHub Actions, standard Linux runner
- Source repository: Private GitHub repository
- Deliverable: Installable release APK and complete source code

NON-NEGOTIABLE RULES
1. Implement the complete combined Phase 1–3 scope in Version 1.0.
2. Inspect and preserve any existing project files and working features.
3. Do not replace functional code with a demonstration app or mock data.
4. Do not claim a feature is complete unless implemented and tested.
5. Do not remove, silently defer or simplify any approved requirement.
6. Use stable, compatible Flutter/Dart packages; verify compatibility before changing versions.
7. Never hardcode passwords, service-account keys, private signing keys or credentials.
8. Do not activate paid Firebase services or cloud billing without my explicit approval.
9. Never request camera, SMS or file permissions unnecessarily.
10. Keep financial calculations accurate, use integer minor units or precise decimal arithmetic, not floating-point money calculations.
11. Make the application usable offline, including before Firebase login where practical.
12. Use migrations for every local database schema change.
13. Design for accessible Android phones and tablets, including large text and screen readers.
14. Explain blockers honestly and continue with all work that can be completed safely.

MODULE 1 — AUTHENTICATION AND ONBOARDING
- Welcome/onboarding screens.
- Google Sign-In with Firebase Authentication.
- Separate Firebase project for RKC Expence, not RKC Task.
- Allow local offline use without requiring sign-in for personal finance tracking.
- Account connection, logout, reconnection and sync-status controls.
- Protect user data by authenticated user ID and authorized family membership.
- Secure handling of local financial data and backups.
- No automatic access to Google Drive, Gmail, contacts, camera or SMS.

MODULE 2 — FINANCIAL DASHBOARD
- Beautiful modern dashboard with a premium professional appearance.
- Total available balance, total income, total expenses and net savings.
- Separate Cash, Bank and Wallet balances.
- Today, week, month and selected-period summaries.
- Recent transactions.
- Category spending visualization.
- Budget progress and alerts.
- Upcoming recurring bills.
- Debt balances and savings-goal progress.
- Quick Add Expense and Add Income actions.
- Customizable/reorderable dashboard sections.
- Empty, loading, offline and error states.
- No unnecessary clutter or excessive animations.
- All amounts must update correctly after every transaction, transfer, refund and repayment.

MODULE 3 — INCOME, EXPENSES AND TRANSACTIONS
- Add, edit, delete, duplicate and view transactions.
- Income, expense and transfer transaction types.
- Transaction amount, date, time, account, category, subcategory, notes and optional attachments.
- Transaction history grouped by date.
- Advanced search with date range, amount, category, account, type, notes and keyword filters.
- Sorting, filtering and transaction details.
- Quick Expense Templates for repeated entries.
- Recurring daily, weekly, monthly, quarterly and yearly transactions.
- Split expenses across categories or participants.
- Refund and return tracking, linked to original transactions.
- Duplicate expense detection/warning.
- Built-in calculator within amount entry.
- Safe undo/confirmation for destructive actions.
- Correctly distinguish expenses, account transfers, debt principal, savings contributions and refunds to prevent double counting.
- Do not add merchant name, bill number or warranty-expiry fields as required transaction fields; these were excluded from the approved scope.

MODULE 4 — CATEGORIES AND SUBCATEGORIES
- Searchable category picker with icons.
- Built-in and user-created categories/subcategories.
- Category editing, ordering and optional archiving.
- Categories include:
  Groceries, Vegetables, Fruits, Food, Restaurant, Canteen, Tea/Coffee,
  Shopping, Clothes, Mall, Household, Rent, Maintenance,
  Electricity, Water, Internet, Mobile Recharge, LPG for Home,
  Fuel/Petrol, Diesel, CNG for Car, FASTag, Parking, Vehicle Maintenance,
  Public Transport, Travel, Education, School/College Fees,
  Hospital, Doctor, Medicine, Insurance, Entertainment,
  Gifts, Personal Care, Family, Miscellaneous.
- Income categories include Salary, Business, Interest, Refund, Gift and Other Income.
- Support custom names, colors and icons.
- Prevent deleting a category in a way that corrupts existing historical transactions.

MODULE 5 — ACCOUNTS AND BALANCES
- Multiple cash, bank and wallet accounts.
- Account opening balance, current balance and transaction history.
- Account-to-account transfers without counting transfers as income or expenses.
- Account editing, archiving and account-wise reporting.
- Reconciliation-friendly running balances.
- Correct handling of refunds, debts and savings allocations.

MODULE 6 — BUDGETS
- Default monthly overall budget ₹30,000, user-editable.
- Overall and category-wise budgets.
- 50%, 80% and 100% threshold notifications.
- Budget remaining, overspending and monthly comparison.
- Budget history.
- Avoid repeated notifications for the same threshold without a meaningful change.
- Local notification support with user consent.

MODULE 7 — DEBT AND LENDING TRACKER
- Track money lent to others and borrowed from others.
- Person/reference name, amount, date, due date and notes.
- Partial and full repayments.
- Outstanding balance and repayment history.
- Overdue status and due-date reminders.
- Debt/lending summaries and reports.
- Link disbursements and repayments to financial accounts.
- Prevent double-counting debt principal as ordinary income/expense.
- Support optional interest only when explicitly configured, with transparent calculations.

MODULE 8 — SAVINGS GOALS
- Create savings goals with name, target amount and target date.
- Record contributions and withdrawals.
- Progress bars, percentage completed and remaining target.
- Goal completion and history.
- Optional goal-specific reminders.
- Clearly distinguish goal allocation from actual spending.
- Link contributions to accounts without duplicating money movement.

MODULE 9 — CALENDAR AND REMINDERS
- Monthly calendar displaying income/expense activity.
- Daily transaction drill-down.
- Recurring bill reminders.
- Debt due-date reminders.
- Savings-goal target reminders.
- Optional notifications, requested only when needed.
- Respect Android notification permission requirements.

MODULE 10 — REPORTS AND ANALYTICS
- Daily, weekly, monthly, quarterly and annual reports.
- 15-day reports: day 1–15 and day 16 through the last day of the month.
- Custom date range reports.
- Category-wise and subcategory-wise spending.
- Account-wise reports.
- Income versus expense reports.
- Family expense reports.
- Debt/lending and savings-goal reports.
- Pie/bar/line charts as appropriate.
- Comparisons between periods.
- All totals must reconcile with transaction records.
- Handle months of different lengths and leap years.
- Excel .xlsx export with summary sheet and detailed transaction sheet.
- PDF export with readable tables, totals, date range and report metadata.
- Share exports through the Android share sheet.
- Never require cloud connectivity for local report generation.

MODULE 11 — RECEIPT PHOTO AND PDF ATTACHMENTS
- Attach multiple receipt images and PDF documents to transactions.
- Take photo only when the user chooses Camera.
- Select existing photos using Android system photo picker.
- Select PDFs using Android system document picker.
- View, open, replace and remove attachments.
- Store attachments locally by default.
- No broad storage permission or camera permission at application launch.
- Do not assume Firebase Cloud Storage is free on Spark; treat cloud attachment backup as optional and blocked until pricing/billing is explicitly approved.
- Preserve attachments through local backup/restore.

MODULE 12 — FAMILY EXPENSE SHARING
- Authorized family groups using individual Google accounts.
- Invite/accept/revoke family membership.
- Shared transactions and shared accounts where explicitly configured.
- Keep personal transactions private by default.
- Clear ownership and access controls.
- Firestore rules must prevent unauthorized reads/writes.
- Handle offline edits and synchronization conflicts.
- Do not automatically share all financial data after joining a family.

MODULE 13 — BANK SMS EXPENSE DETECTION
- Opt-in only, disabled by default.
- No automatic SMS permission request on launch.
- Explain Android and Google Play SMS permission restrictions.
- Prefer compliant, user-initiated alternatives when direct SMS access is not permitted.
- Never silently read or upload SMS messages.
- Require confirmation before creating a transaction from detected information.
- Never promise Play Store compliance without verification.

MODULE 14 — THEMES AND PERSONALIZATION
Provide exactly these 11 selectable themes:
1. Navy Blue
2. Premium Black
3. Royal Purple
4. Teal Blue
5. Emerald Green
6. White & Blue
7. Ocean Blue
8. Lavender
9. Slate Grey
10. Sky Blue
11. Mint Green

- Light, Dark and Follow System appearance.
- Theme choice persisted across restarts.
- No fixed mandatory green theme.
- Exclude Crimson Red, Rose Pink, Royal Gold and Sunset Orange.
- Professional typography, consistent spacing and accessible contrast.
- Customizable dashboard layout.
- Custom date formats, including DD/MM/YYYY, MM/DD/YYYY and YYYY-MM-DD.
- Custom currency selection and number formatting; INR default.
- Changing display currency must not silently convert historical amounts.
- If multicurrency accounting is introduced, exchange rates and conversion rules must be explicit and verified.

MODULE 15 — HOME-SCREEN WIDGETS
- Small, medium and large Android widgets.
- Medium widget default: available balance and today's spending.
- Quick access to add a transaction.
- Refresh after relevant local data changes.
- Privacy-conscious display on the home screen.
- Widgets must work with offline local data.

MODULE 16 — BACKUP AND RESTORE
- Manual local backup and restore.
- Export transaction, account, category, budget, debt and savings data.
- Include receipt attachments where possible.
- Backup format versioning and migration support.
- Validate backup integrity before restoring.
- Prevent accidental data duplication on restore.
- Optional encrypted backup.
- Cloud synchronization must not be represented as a complete historical backup.
- No automatic Google Drive access.

MODULE 17 — RESPONSIVE PHONE AND TABLET SUPPORT
- Responsive layouts for portrait and landscape.
- Optimized phone navigation.
- Wider tablet dashboard, charts and tables.
- Large text, accessible touch targets and overflow handling.
- Test small screens, large screens and tablets.

MODULE 18 — FIREBASE AND OFFLINE SYNC
- Firebase Authentication with Google provider.
- Cloud Firestore on a separate RKC Expence Firebase project.
- SQLite as local source for offline operations.
- Queue and synchronize offline changes.
- Handle reconnects, retries, duplicate prevention and conflict resolution.
- Security Rules based on ownership and explicit family authorization.
- Minimize Firestore reads/writes to stay within Spark free limits.
- Do not upload receipts to Firebase Storage without approval.
- Configure Android package name com.rkc.expence.
- Use the correct google-services.json for RKC Expence.
- Document SHA-1/SHA-256 configuration for Google Sign-In.
- Keep credentials and release signing secrets out of Git.
- Test with Firebase Emulator Suite where practical.
- Do not enable paid Firebase services or Blaze billing automatically.

MODULE 19 — ARCHITECTURE AND DATA QUALITY
- Use clear feature-based Flutter project structure.
- Separate UI, state management, domain logic and persistence.
- Prefer well-maintained packages.
- Use stable IDs for entities and transactions.
- Store financial amounts precisely.
- Use safe database transactions.
- Implement schema migrations.
- Add input validation and meaningful error messages.
- Avoid duplicate financial postings.
- Handle timezone and local date boundaries correctly.
- Maintain audit-friendly timestamps.
- Ensure data consistency between SQLite and Firestore.

MODULE 20 — TESTING
- Unit tests for financial calculations, budgets, debt repayments, savings and report periods.
- Widget tests for critical screens.
- Integration tests for transaction entry, editing, export and backup.
- Firestore rules tests for private/shared data access.
- Offline and reconnect tests.
- Tests for Android permissions and denied-permission behavior.
- Responsive layout tests.
- Verify every 15-day report range.
- Run flutter analyze and flutter test.
- Do not claim 100% success without actual test evidence.
- Report passed, failed, skipped and untested cases.

MODULE 21 — GITHUB ACTIONS AND APK BUILD
- Create .github/workflows/android-apk.yml.
- Use a standard GitHub-hosted Linux runner.
- Install compatible Java, Flutter and Android SDK/build tools in CI.
- Restore dependencies, analyze, test and build APK.
- Use caching where appropriate.
- Upload the generated APK as a GitHub Actions artifact.
- Never expose Firebase service credentials or signing secrets in logs.
- Configure release signing securely using GitHub Actions secrets when available.
- If signing credentials are not supplied, produce an installable testing APK using an appropriate non-production signing approach and clearly label it.
- Do not misrepresent a debug/test APK as a production-signed Play Store release.
- Provide instructions to download the APK from the Actions run.
- Avoid expensive runners and paid add-ons.
- Do not activate billable features without approval.

IMPLEMENTATION PROCESS
Stage 1: Audit repository and development environment.
Stage 2: Implement stable data models, SQLite and core finance operations.
Stage 3: Implement dashboard, budgets, categories and accounts.
Stage 4: Implement debts, savings, calendar and recurring transactions.
Stage 5: Implement reports, Excel/PDF export and attachments.
Stage 6: Implement Firebase authentication, synchronization and family sharing.
Stage 7: Implement themes, widgets, tablet layouts and privacy controls.
Stage 8: Implement optional compliant SMS workflow and advanced features.
Stage 9: Add automated tests and fix defects.
Stage 10: Configure GitHub Actions, build APK and document installation.

At every stage:
- Make actual code changes in the repository.
- Run available tests and report results.
- Commit coherent changes with descriptive messages.
- Do not delete earlier requirements.
- Keep a feature checklist with Implemented, Tested, Pending and Blocked statuses.
- Ask for approval before any paid service, irreversible data operation or security-sensitive account action.

FINAL ACCEPTANCE
The project is not complete merely because it compiles. All required features must function with persistent data and correct financial calculations. Provide:
1. Complete source repository.
2. Working APK build artifact.
3. Firebase setup instructions.
4. Test report.
5. Feature completion matrix.
6. Known limitations and unresolved issues.
7. Simple Android installation guide.

START NOW:
Inspect the existing repository. Identify what already works, what is missing and any blockers. Then begin implementing the application in the staged order above. Do not stop at a plan or a UI mockup.