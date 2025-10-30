import 'package:flutter_riverpod/flutter_riverpod.dart';

final bLEConnectedProvider = StateProvider<bool>((ref) => false);

final voltageValueProvider = StateProvider<double>((ref) => 0.0);