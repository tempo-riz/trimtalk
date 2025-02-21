import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:trim_talk/model/files/db.dart';

class SettingsTooglePref extends StatelessWidget {
  const SettingsTooglePref({
    super.key,
    required this.pref,
    required this.title,
    this.subtitle,
    this.disabledIcon,
    this.enabledIcon,
    this.onToggleCheck,
  });

  final Prefs pref;
  final String title;
  final String? subtitle;
  final IconData? disabledIcon;
  final IconData? enabledIcon;

  /// return false to prevent the toggle update
  final Future<bool> Function(bool)? onToggleCheck;

  @override
  Widget build(BuildContext context) {
    return PrefBuilder<bool>(
        pref: pref,
        builder: (BuildContext context, bool enabled) {
          return Container(
            // rounded corners
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // width: 290,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              subtitle: subtitle != null ? Text(subtitle!).fontSize(14) : null,
              title: Text(title),
              value: enabled,
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Icon(
                      enabledIcon ?? Icons.check,
                    );
                  }
                  if (disabledIcon != null) {
                    return Icon(
                      disabledIcon,
                    );
                  }
                  // default thumb
                  return null;
                },
              ),
              onChanged: (bool value) async {
                if (onToggleCheck != null && !(await onToggleCheck!(value))) return;
                DB.setPref(pref, value);
              },
            ),
          );
        });
  }
}
