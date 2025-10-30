import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wamdaa/app/const/colors.dart';
import '../../app/providers/current_profile_provider.dart';
import '../../models/alert.dart';
import '../../services/firestore_services.dart';
import '../ble_screen/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(currentUserProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final _alerts = currentProfile?.alerts ?? [];
    final bleConnection = ref.watch(bLEConnectedProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/new-alert');
        },
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add_rounded, size: 35),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? AppColors.backgroundGradDark
                : AppColors.backgroundGrad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: isDark ? Colors.white : null,
                    backgroundImage: AssetImage("assets/images/logo.png"),
                  ),
                  title: Text(currentProfile?.name ?? ''),
                  subtitle: Row(
                    children: [
                      Icon(
                        bleConnection ? Icons.circle : Icons.circle_outlined,
                        size: 10,
                        color: bleConnection ? Colors.green[600] : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        bleConnection ? "online".tr() : "disconnected".tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: bleConnection ?  Colors.green[600] : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      context.push('/settings');
                    },
                    icon: Icon(Icons.settings, size: 30),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "slogan".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white : Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Alerts".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _alerts.isEmpty
                          ? Center(child: Text('No alerts yet'.tr()))
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _alerts.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final a = _alerts[i];
                                final time = _fmtTime(
                                  TimeOfDay(hour: a.hour, minute: a.minute),
                                );
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Color(0xFF1E1E1E)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(a.label),
                                        subtitle: Text(time),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Switch(
                                              value: a.enabled,
                                              focusColor: Colors.red,
                                              // activeColor: Colors.green,
                                              activeTrackColor: Colors.green,
                                              onChanged: (v) => _toggle(a, v),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              onPressed: () => _delete(a),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Wrap(
                                        children: _alerts[i].daysMap.entries
                                            .map((e) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: Text(
                                                  e.key.toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: e.value
                                                        ? Colors.pink
                                                        : isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmtTime(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _toggle(Alert a, bool v) {
    final currentProfile = ref.read(currentUserProfileProvider);
    Alert? found = currentProfile?.alerts.firstWhere((e) => e.id == a.id);
    if (found != null) {
      found.enabled = v;
      ref.read(currentUserProfileProvider.notifier).state = null;
      ref.read(currentUserProfileProvider.notifier).state = currentProfile;

      final firestoreService = ref.read(firestoreServiceProvider);
      firestoreService.updateUserProfile(
        currentProfile!.userId,
        currentProfile,
      );
      ref.invalidate(currentUserProfileProvider);

      if (!mounted) return;
    }
  }

  void _delete(Alert a) {
    final currentProfile = ref.read(currentUserProfileProvider);
    currentProfile?.alerts.remove(a);

    ref.read(currentUserProfileProvider.notifier).state = null;
    ref.read(currentUserProfileProvider.notifier).state = currentProfile;

    final firestoreService = ref.read(firestoreServiceProvider);
    firestoreService.updateUserProfile(currentProfile!.userId, currentProfile);
    ref.invalidate(currentUserProfileProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Alert deleted'.tr())));
  }
}
