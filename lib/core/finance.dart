/// All monetary values are integer minor units (paise for INR).
enum PostingKind { income, expense, transfer, refund, debtPrincipal, goalAllocation }

class Posting {
  final String id;
  final PostingKind kind;
  final int amount;
  final String accountId;
  final String? destinationId;
  final String? originalId;
  final DateTime date;

  Posting({required this.id, required this.kind, required this.amount,
    required this.accountId, required this.date, this.destinationId, this.originalId}) {
    if (id.isEmpty || accountId.isEmpty || amount <= 0) {
      throw ArgumentError('A posting needs an ID, an account and a positive amount.');
    }
    if (kind == PostingKind.transfer &&
        (destinationId == null || destinationId == accountId)) {
      throw ArgumentError('Choose a different destination account.');
    }
    if (kind == PostingKind.refund && originalId == null) {
      throw ArgumentError('Link the original expense.');
    }
  }
}

class Ledger {
  final Map<String, int> openings;
  final Map<String, Posting> _entries = {};
  Ledger(Map<String, int> accounts) : openings = Map.unmodifiable(accounts);

  void put(Posting posting) {
    if (!openings.containsKey(posting.accountId) ||
        (posting.kind == PostingKind.transfer && !openings.containsKey(posting.destinationId))) {
      throw ArgumentError('Unknown account.');
    }
    if (posting.kind == PostingKind.refund) {
      final original = _entries[posting.originalId];
      if (original == null || original.kind != PostingKind.expense) {
        throw ArgumentError('Original expense does not exist.');
      }
      final refunded = _entries.values.where((p) => p.kind == PostingKind.refund &&
        p.originalId == original.id && p.id != posting.id).fold(0, (int n, p) => n + p.amount);
      if (refunded + posting.amount > original.amount) {
        throw ArgumentError('Refund exceeds original expense.');
      }
    }
    final linked = _entries.values.where((p) => p.originalId == posting.id);
    if (linked.isNotEmpty && (posting.kind != PostingKind.expense ||
        linked.fold(0, (int n, p) => n + p.amount) > posting.amount)) {
      throw ArgumentError('This change would invalidate linked refunds.');
    }
    _entries[posting.id] = posting;
  }

  void remove(String id) {
    if (_entries.values.any((p) => p.originalId == id)) {
      throw StateError('Remove linked refunds first.');
    }
    _entries.remove(id);
  }

  int balance(String accountId) {
    if (!openings.containsKey(accountId)) throw ArgumentError('Unknown account.');
    return _entries.values.fold(openings[accountId]!, (int total, p) {
      if (p.kind == PostingKind.goalAllocation) return total;
      if (p.kind == PostingKind.transfer && p.destinationId == accountId) total += p.amount;
      if (p.accountId != accountId) return total;
      return total + switch (p.kind) {
        PostingKind.income || PostingKind.refund => p.amount,
        PostingKind.expense || PostingKind.transfer || PostingKind.debtPrincipal => -p.amount,
        PostingKind.goalAllocation => 0,
      };
    });
  }

  int expenses(DateTime start, DateTime endExclusive) => _entries.values
    .where((p) => !p.date.isBefore(start) && p.date.isBefore(endExclusive))
    .fold(0, (int n, p) => n + switch (p.kind) {
      PostingKind.expense => p.amount,
      PostingKind.refund => -p.amount,
      _ => 0,
    });
}

/// Half-open local calendar periods avoid end-of-day precision errors.
(DateTime, DateTime) fortnight(DateTime date) => date.day <= 15
  ? (DateTime(date.year, date.month, 1), DateTime(date.year, date.month, 16))
  : (DateTime(date.year, date.month, 16), DateTime(date.year, date.month + 1, 1));

int parseMinorUnits(String input) {
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(input)) {
    throw FormatException('Enter a positive amount with up to two decimal places.');
  }
  final parts = input.split('.');
  final value = int.parse(parts[0]) * 100 +
    (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  if (value <= 0 || value > 9007199254740991) throw FormatException('Amount is out of range.');
  return value;
}
