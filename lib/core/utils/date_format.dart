const _mois = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre'
];

/// « 12 janvier 2026 » (sans dépendre des données de locale d'intl).
String formatDateFr(DateTime d) =>
    '${d.day == 1 ? '1er' : d.day} ${_mois[d.month - 1]} ${d.year}';
