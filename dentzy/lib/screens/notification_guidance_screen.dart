import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/theme.dart';

class NotificationGuidanceScreen extends StatelessWidget {
  final NotificationDiagnostics diagnostics;

  const NotificationGuidanceScreen({
    super.key,
    required this.diagnostics,
  });

  @override
  Widget build(BuildContext context) {
    final manufacturer = diagnostics.manufacturer?.trim() ?? 'Unknown';
    final steps = _stepsForManufacturer(manufacturer);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Background alarm help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BannerCard(
            title: 'Why this matters',
            body:
                'Some Android phones block exact alarms or background notifications unless the app is allowed to run unrestricted.',
            accent: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          _BannerCard(
            title: 'Device',
            body: manufacturer,
            accent: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          _BannerCard(
            title: 'Recommended steps',
            body: steps.join('\n'),
            accent: AppTheme.successColor,
          ),
          const SizedBox(height: 16),
          if (!diagnostics.batteryOptimizationIgnored)
            FilledButton.icon(
              onPressed: () => NotificationService.instance.openBatteryOptimizationSettings(),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open battery optimization settings'),
            ),
          const SizedBox(height: 12),
          const Text(
            'If alarms still do not fire, open the app info page and set battery usage to Unrestricted or Don\'t optimize.',
          ),
        ],
      ),
    );
  }

  List<String> _stepsForManufacturer(String manufacturer) {
    final value = manufacturer.toLowerCase();
    final baseSteps = <String>[
      '1. Allow notification permission in the app settings.',
      '2. Allow exact alarms on Android 12+.',
      '3. Set battery usage to Unrestricted / Don\'t optimize.',
      '4. Keep background activity enabled for the app.',
    ];

    if (value.contains('xiaomi') || value.contains('redmi') || value.contains('poco')) {
      return [
        ...baseSteps,
        '5. Open Auto-start and allow Dentzy to start automatically.',
        '6. Disable MIUI battery saver restrictions for this app.',
      ];
    }

    if (value.contains('vivo')) {
      return [
        ...baseSteps,
        '5. Allow background activity and set the app to run without restrictions.',
      ];
    }

    if (value.contains('oppo') || value.contains('realme')) {
      return [
        ...baseSteps,
        '5. Allow auto launch and lock the app in the recent apps screen if needed.',
      ];
    }

    if (value.contains('oneplus')) {
      return [
        ...baseSteps,
        '5. Set battery optimization to Unrestricted and allow background running.',
      ];
    }

    if (value.contains('huawei')) {
      return [
        ...baseSteps,
        '5. Open App launch management and allow the app to run in the background.',
      ];
    }

    return baseSteps;
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String body;
  final Color accent;

  const _BannerCard({
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(body),
        ],
      ),
    );
  }
}