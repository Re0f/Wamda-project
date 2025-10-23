class Alert {
  final int? id;
  final String label;
  final int hour;
  final int minute;
  final Map daysMap;
  bool enabled;

  Alert({
    this.id,
    required this.label,
    required this.hour,
    required this.minute,
    required this.daysMap,
    this.enabled = true,
  });

  Alert copyWith({
    int? id,
    String? label,
    int? hour,
    int? minute,
    Map? daysMap,
    bool? enabled,
  }) {
    return Alert(
      id: id ?? this.id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysMap: daysMap ?? this.daysMap,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'hour': hour,
    'minute': minute,
    'daysMap': daysMap,
    'enabled': enabled ? 1 : 0,
  };

  factory Alert.fromMap(Map<String, dynamic> m) => Alert(
    id: m['id'] as int?,
    label: m['label'] as String,
    hour: m['hour'] as int,
    minute: m['minute'] as int,
    daysMap: m['daysMap'] as Map,
    enabled: (m['enabled'] as int) == 1,
  );
}
