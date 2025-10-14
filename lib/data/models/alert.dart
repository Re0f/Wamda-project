class Alert {
  final int? id;
  final String label;
  final int hour;        // 0..23
  final int minute;      // 0..59
  final int daysMask;    // Sun..Sat = bitmask (0..127)
  final bool enabled;

  const Alert({
    this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.daysMask,
    this.enabled = true,
  });

  Alert copyWith({
    int? id,
    String? label,
    int? hour,
    int? minute,
    int? daysMask,
    bool? enabled,
  }) {
    return Alert(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysMask: daysMask ?? this.daysMask,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute,
    'days_mask': daysMask,
    'enabled': enabled ? 1 : 0,
  };

  factory Alert.fromMap(Map<String, dynamic> m) => Alert(
    id: m['id'] as int?,
    label: m['label'] as String,
    hour: m['hour'] as int,
    minute: m['minute'] as int,
    daysMask: m['days_mask'] as int,
    enabled: (m['enabled'] as int) == 1,
  );
}
