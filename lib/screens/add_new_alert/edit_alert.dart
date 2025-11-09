import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wamdaa/screens/add_new_alert/selector.dart';
import '../../app/const/colors.dart';
import '../../app/providers/current_profile_provider.dart';
import '../../models/alert.dart';
import '../../services/firestore_services.dart';

class EditAlertScreen extends ConsumerStatefulWidget {
  final Alert alert;
  final int alertIndex;

  const EditAlertScreen({
    super.key,
    required this.alert,
    required this.alertIndex,
  });

  @override
  ConsumerState createState() => _EditAlertScreenState();
}

class _EditAlertScreenState extends ConsumerState<EditAlertScreen> {
  late TextEditingController _labelCtrl;
  late TimeOfDay _time;
  late List<bool> _days;
  final _dayNames = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final _arabicDayNames = const [
    'أحد',
    'إثنين',
    'ثلاثاء',
    'أربعاء',
    'خميس',
    'جمعة',
    'سبت',
  ];
  bool _hasChanges = false;
  LineType _type = LineType.continuous;

  @override
  void initState() {
    super.initState();
    // Initialize with existing alert data
    _labelCtrl = TextEditingController(text: widget.alert.label);
    _time = TimeOfDay(hour: widget.alert.hour, minute: widget.alert.minute);
    _type = LineType.values[widget.alert.type ?? 0];

    // Initialize days from the alert's daysMap
    _days = List.generate(7, (index) {
      return widget.alert.daysMap[_dayNames[index]] ?? false;
    });

    // Listen for changes
    _labelCtrl.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _labelCtrl.removeListener(_onDataChanged);
    _labelCtrl.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      setState(() {
        _time = picked;
        _hasChanges = true;
      });
    }
  }

  Future<void> _save() async {
    // Validate that at least one day is selected
    if (!_days.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create updated days map
    Map daysMap = Map.fromIterables(_dayNames, _days);

    // Update the alert object
    final updatedAlert = Alert(
      id: widget.alert.id,
      // Keep the same ID
      label: _labelCtrl.text
          .trim()
          .isEmpty
          ? 'Alert'.tr()
          : _labelCtrl.text.trim(),
      hour: _time.hour,
      minute: _time.minute,
      daysMap: daysMap,
      type: _type.index,
      enabled: widget.alert.enabled, // Preserve enabled status
    );

    // Update in the profile
    final currentProfile = ref.read(currentUserProfileProvider);
    if (currentProfile != null &&
        widget.alertIndex < currentProfile.alerts.length) {
      currentProfile.alerts[widget.alertIndex] = updatedAlert;

      // Update local state
      ref
          .read(currentUserProfileProvider.notifier)
          .state = null;
      ref
          .read(currentUserProfileProvider.notifier)
          .state = currentProfile;

      // Update in Firestore
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateUserProfile(
        currentProfile.userId,
        currentProfile,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert updated successfully'.tr()),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      ref.invalidate(currentUserProfileProvider);

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme
            .of(context)
            .brightness == Brightness.dark;

        return AlertDialog(
          title: Text('Delete Alert'.tr()),
          content: Text('Are you sure you want to delete this alert?'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel'.tr(),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Remove from profile
      final currentProfile = ref.read(currentUserProfileProvider);
      if (currentProfile != null &&
          widget.alertIndex < currentProfile.alerts.length) {
        currentProfile.alerts.removeAt(widget.alertIndex);

        // Update local state
        ref
            .read(currentUserProfileProvider.notifier)
            .state = null;
        ref
            .read(currentUserProfileProvider.notifier)
            .state = currentProfile;

        // Update in Firestore
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.updateUserProfile(
          currentProfile.userId,
          currentProfile,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert deleted'.tr()),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );

        ref.invalidate(currentUserProfileProvider);

        if (!mounted) return;
        Navigator.pop(context, true);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme
            .of(context)
            .brightness == Brightness.dark;

        return AlertDialog(
          title: Text('Unsaved Changes'.tr()),
          content: Text(
            'You have unsaved changes. Do you want to discard them?'.tr(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay'.tr(),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Discard'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final locale = Localizations
        .localeOf(context)
        .languageCode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? AppColors.backgroundGradDark
                  : AppColors.backgroundGrad,
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
                            onPressed: () async {
                              final canPop = await _onWillPop();
                              if (canPop && mounted) {
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 24,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Edit Alert".tr(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _delete,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 24,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete Alert'.tr(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Time Picker
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time'.tr(),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          child: Text(
                            _fmtTime(_time),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Days Selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Repeat'.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(7, (i) {
                                return FilterChip(
                                  label: Text(
                                    locale == 'ar'
                                        ? _arabicDayNames[i]
                                        : _dayNames[i],
                                  ),
                                  selected: _days[i],
                                  onSelected: (v) {
                                    setState(() {
                                      _days[i] = v;
                                      _hasChanges = true;
                                    });
                                  },
                                  selectedColor: isDark
                                      ? Colors.blue.withOpacity(0.3)
                                      : Colors.blue.withOpacity(0.2),
                                  checkmarkColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Label Input
                      TextField(
                        controller: _labelCtrl,
                        decoration: InputDecoration(
                          labelText: "Label".tr(),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          hintText: 'e.g., Morning Medication'.tr(),
                        ),
                        maxLength: 30,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 200,
                        child: LineSelector(
                          onChange: (type) =>
                              setState(() {
                                _onDataChanged();
                                _type = type;
                              }),
                          initialValue: _type,
                        ),
                      ),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final canPop = await _onWillPop();
                                if (canPop && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[400]!,
                                ),
                              ),
                              child: Text(
                                "Cancel".tr(),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _hasChanges ? _save : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save, size: 20),
                                  const SizedBox(width: 8),
                                  Text("Save Changes".tr()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Info Text
                      if (_hasChanges)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'You have unsaved changes'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
