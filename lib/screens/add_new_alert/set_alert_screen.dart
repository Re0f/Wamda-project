import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/const/colors.dart';
import '../../app/providers/current_profile_provider.dart';
import '../../models/alert.dart';
import '../../services/firestore_services.dart';

class SetAlertScreen extends ConsumerStatefulWidget {
  const SetAlertScreen({super.key});
  @override
  ConsumerState createState() => _SetAlertScreenState();
}

class _SetAlertScreenState extends ConsumerState<SetAlertScreen> {
  final _labelCtrl = TextEditingController();
  TimeOfDay? _time;
  final List<bool> _days = List.filled(7, false);
  final _dayNames = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];


  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 7, minute: 30),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text('Pick a time'.tr())));
      return;
    }
    Map daysMap = Map.fromIterables(_dayNames, _days);

    final a = Alert(
      id: DateTime.now().millisecondsSinceEpoch,
      label: _labelCtrl.text.trim().isEmpty ? 'Alert'.tr() : _labelCtrl.text.trim(),
      hour: _time!.hour,
      minute: _time!.minute,
      daysMap: daysMap,
      enabled: true,
    );

    final currentProfile = ref.read(currentUserProfileProvider);
    currentProfile?.alerts.add(a);
    ref.read(currentUserProfileProvider.notifier).state = null;
    ref.read(currentUserProfileProvider.notifier).state = currentProfile;

    final firestoreService = ref.read(firestoreServiceProvider);
    await firestoreService.updateUserProfile(
      currentProfile!.userId,
      currentProfile,
    );
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text('Alert saved'.tr()),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    ref.invalidate(currentUserProfileProvider);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ?  AppColors.backgroundGradDark : AppColors.backgroundGrad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 24),
                        ),
                         Text(
                          "New Alert".tr(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration:  InputDecoration(
                          labelText: 'Time'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        child: Text(
                          _time == null ? 'Tap to pick time'.tr() : _fmtTime(_time!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(7, (i) {
                          return FilterChip(
                            label: Text(_dayNames[i]),
                            selected: _days[i],
                            onSelected: (v) => setState(() => _days[i] = v),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _labelCtrl,
                      decoration:  InputDecoration(
                        labelText: "Label".tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text("Save".tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
