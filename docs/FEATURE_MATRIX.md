# RKC Expence implementation status

The complete approved specification is retained in MASTER_SPECIFICATION.md.
This is an initial development checkpoint, not final Version 1.0 acceptance.
Implemented means source exists; it does not imply device verification.

| Module | Implemented | Tested | Pending / blocked |
|---|---|---|---|
| 1 Authentication | Local use without login | Pending device test | Onboarding, Google login, account controls; separate Firebase configuration needed |
| 2 Dashboard | Local available balance, account balances, monthly budget, recent entries, loading/error/empty states | Pending | Income/savings summaries, periods, charts, rearrangement, bills/debts/goals |
| 3 Transactions | SQLite add/edit/delete, income/expense/transfer, amount/date/account/category/notes, simple search, delete confirmation | Automated checks in progress | Duplicate/template/recurring/split/refund UI, calculator, advanced filters, time picker, attachments |
| 4 Categories | Built-in and custom categories; edit, search management list, archive/restore; historical references preserved | Repository tests passed; screen test validation recorded in TEST_REPORT.md | Subcategories, icons/colors, ordering, searchable transaction picker |
| 5 Accounts | Multiple Cash/Bank/Wallet accounts; create/edit; signed opening balances; archive/restore; ledger balances and transfers | Repository tests passed; screen test validation recorded in TEST_REPORT.md | Running balance/reconciliation and account report screens |
| 6 Budgets | Default ₹30,000 progress; editable overall budget saved per month; category budget persistence API; v1-to-v2 migration | Migration, month/category isolation and validation passed | Category budget UI, threshold notifications, history/comparison UI |
| 7 Debt | Exclusion of outgoing principal from expense totals in domain core only | Automated checks in progress | Complete lending/borrowing/interest/repayment UI and persistence |
| 8 Savings | Allocation exclusion from spending/balance changes in domain core only | Automated checks in progress | Goals, withdrawals, contributions, account links, reminders/history |
| 9 Calendar | None | Untested | Entire module |
| 10 Reports | Half-month date-range domain helper | Automated checks in progress | Report UI, charts, all periods, Excel/PDF/share, reconciliations |
| 11 Attachments | Camera/gallery/file selection, multiple JPEG/PNG/PDF bills, local SQLite storage, image viewing, external PDF viewing, replace/remove, 20 MB per-file limit | Storage/migration/replacement/removal/financial invariants passed | Android camera/picker/denied-permission and process-death recovery tests; backup integration; cloud attachment backup remains blocked pending approval |
| 12 Family | None | Untested | Entire module; Firebase configuration required |
| 13 SMS | No SMS access or permission requested | Untested | Opt-in user-paste parsing/confirmation workflow and policy documentation |
| 14 Themes | Initial Navy palette, INR and DD/MM/YYYY defaults | Untested | All 11 selectable themes, persistence, appearance/currency/date settings |
| 15 Widgets | None | Untested | Entire module |
| 16 Backup | OS automatic backup disabled | Untested | Versioned validated manual backup/restore, attachments, optional encryption |
| 17 Responsive | Flexible scrolling layout and wider margins | Untested | Phone/tablet/landscape/large-text/screen-reader verification and optimized tablet UI |
| 18 Sync | SQLite v1 schema migration, stable IDs and audit timestamps | Automated checks in progress | Firebase/Auth/outbox/conflicts/security rules/emulator tests |
| 19 Architecture | Domain core and SQLite repository separated from UI, integer minor units, SQL transactions/FKs | Automated checks in progress | Full feature architecture, sync consistency, migrations for future schema changes |
| 20 Testing | Finance, SQLite and income entry/edit screen tests | 8 passed; analyze passed | Integration/rules/offline/device/permission/accessibility coverage |
| 21 CI/APK | Linux workflow: dependencies/analyze/test/release-mode testing APK/artifact | Local release-mode testing APK built successfully; GitHub run unverified | Production signing secrets, device APK verification and Actions run |

No Firebase project, paid service, cloud storage or billing has been activated.
Release-mode builds currently use a development signing key: testing only, not a production Play Store release.
