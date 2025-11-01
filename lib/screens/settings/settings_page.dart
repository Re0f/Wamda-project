import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wamdaa/app/const/colors.dart';
import 'package:wamdaa/app/providers/all_app_provider.dart';
import '../../app/theme/theme_provider.dart';
import '../../services/auth_controller.dart';
import '../../services/ble_service.dart';
import '../ble_screen/providers/providers.dart';

class SettingsPage extends ConsumerWidget {
  SettingsPage({super.key});

  Future<void> _testVibration(BuildContext context) async {
    final isConnected = globalContainer.read(bLEConnectedProvider);
    final _bluetoothService = globalContainer.read(bluetoothServiceProvider);

    if (!isConnected) {
      _snack('Connect a device first', context);
      return;
    }
    _bluetoothService.testLED();
    _snack('Vibration test sent ✅', context);
  }

  void _snack(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final authController = ref.watch(authControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = ref.watch(bLEConnectedProvider);
    final voltage = ref.watch(voltageValueProvider);

    return Container(
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
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Settings'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              SizedBox(height: 16),

              Text(
                'Language'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 5),
              SegmentedButton<Locale>(
                segments: <ButtonSegment<Locale>>[
                  ButtonSegment<Locale>(
                    value: const Locale('en'),
                    label: Text('English'.tr()),
                  ),
                  ButtonSegment<Locale>(
                    value: const Locale('ar'),
                    label: Text('Arabic'.tr()),
                  ),
                ],
                selected: <Locale>{context.locale},
                onSelectionChanged: (selection) async {
                  final Locale newLocale = selection.first;
                  await context.setLocale(newLocale);
                },
              ),
              SizedBox(height: 12),
              Text(
                'Theme'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: <ButtonSegment<ThemeMode>>[
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text('System'.tr()),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text('Light'.tr()),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text('Dark'.tr()),
                  ),
                ],
                selected: <ThemeMode>{themeMode},
                onSelectionChanged: (selection) {
                  ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first);
                },
              ),

              SizedBox(height: 15),

              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DeviceStatus'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isConnected ? "online".tr() : "disconnected".tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Battery'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: voltage,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${voltage.round()}%'),
                      ],
                    ),
                    // ElevatedButton(onPressed: (){}, child: Text('Connect'))
                    // SwitchListTile(
                    //   contentPadding: EdgeInsets.zero,
                    //   title: Text('Do Not Disturb'.tr()),
                    //   value: _dnd,
                    //   onChanged: (v) {},
                    //   // onChanged: (v) => setState(() => _dnd = v),
                    // ),
                  ],
                ),
              ),
              _SectionCard(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _WideButton(
                      label: 'Test Vibration'.tr(),
                      onPressed: () {
                        _testVibration(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          authController.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('auth.logout'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}

class _WideButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _WideButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.2),
          elevation: 0,
          foregroundColor: Colors.purpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
