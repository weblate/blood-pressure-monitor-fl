import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/settings_widgets.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/enter_timeformat.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import_screen.dart';
import 'package:blood_pressure_app/screens/subsettings/version.dart';
import 'package:blood_pressure_app/screens/subsettings/warn_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<Settings>(builder: (context, settings, child) {
        return ListView(
          children: [
            SettingsSection(title: Text(AppLocalizations.of(context)!.layout), children: [
              SwitchSettingsTile(
                  key: const Key('allowManualTimeInput'),
                  initialValue: settings.allowManualTimeInput,
                  onToggle: (value) {
                    settings.allowManualTimeInput = value;
                  },
                  leading: const Icon(Icons.details),
                  title: Text(AppLocalizations.of(context)!.allowManualTimeInput)),
              SettingsTile(
                key: const Key('EnterTimeFormatScreen'),
                title: Text(AppLocalizations.of(context)!.enterTimeFormatScreen),
                leading: const Icon(Icons.schedule),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).highlightColor,
                ),
                description: Text(settings.dateFormatString),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnterTimeFormatScreen()),
                  );
                },
              ),
              DropDownSettingsTile<int>(
                key: const Key('thema'),
                leading: const Icon(Icons.brightness_4),
                title: Text(AppLocalizations.of(context)!.theme),
                value: settings.followSystemDarkMode ? 0 : (settings.darkMode ? 1 : 2),
                items: [
                  DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.system)),
                  DropdownMenuItem(value: 1, child: Text(AppLocalizations.of(context)!.dark)),
                  DropdownMenuItem(value: 2, child: Text(AppLocalizations.of(context)!.light))
                ],
                onChanged: (int? value) {
                  switch (value) {
                    case 0:
                      settings.followSystemDarkMode = true;
                      break;
                    case 1:
                      settings.followSystemDarkMode = false;
                      settings.darkMode = true;
                      break;
                    case 2:
                      settings.followSystemDarkMode = false;
                      settings.darkMode = false;
                      break;
                    default:
                      assert(false);
                  }
                },
              ),
              SliderSettingsTile(
                key: const Key('iconSize'),
                title: Text(AppLocalizations.of(context)!.iconSize),
                leading: const Icon(Icons.zoom_in),
                onChanged: (double value) {
                  settings.iconSize = value;
                },
                initialValue: settings.iconSize,
                start: 15,
                end: 70,
                stepSize: 5,
              ),
              SliderSettingsTile(
                key: const Key('graphLineThickness'),
                title: Text(AppLocalizations.of(context)!.graphLineThickness),
                leading: const Icon(Icons.line_weight),
                onChanged: (double value) {
                  settings.graphLineThickness = value;
                },
                initialValue: settings.graphLineThickness,
                start: 1,
                end: 5,
                stepSize: 1,
              ),
              SliderSettingsTile(
                key: const Key('animationSpeed'),
                title: Text(AppLocalizations.of(context)!.animationSpeed),
                leading: const Icon(Icons.speed),
                onChanged: (double value) {
                  settings.animationSpeed = value.toInt();
                },
                initialValue: settings.animationSpeed.toDouble(),
                start: 0,
                end: 1000,
                stepSize: 50,
              ),
              SliderSettingsTile(
                key: const Key('graphTitlesCount'),
                title: Text(AppLocalizations.of(context)!.graphTitlesCount),
                leading: const Icon(Icons.functions),
                onChanged: (double value) {
                  settings.graphTitlesCount = value.toInt();
                },
                initialValue: settings.graphTitlesCount.toDouble(),
                start: 2,
                end: 10,
                stepSize: 1,
              ),
              ColorSelectionSettingsTile(
                  key: const Key('accentColor'),
                  onMainColorChanged: (color) =>
                      settings.accentColor = createMaterialColor((color ?? Colors.teal).value),
                  initialColor: settings.accentColor,
                  title: Text(AppLocalizations.of(context)!.accentColor)),
              ColorSelectionSettingsTile(
                  key: const Key('sysColor'),
                  onMainColorChanged: (color) => settings.sysColor = createMaterialColor((color ?? Colors.green).value),
                  initialColor: settings.sysColor,
                  title: Text(AppLocalizations.of(context)!.sysColor)),
              ColorSelectionSettingsTile(
                  key: const Key('diaColor'),
                  onMainColorChanged: (color) => settings.diaColor = createMaterialColor((color ?? Colors.teal).value),
                  initialColor: settings.diaColor,
                  title: Text(AppLocalizations.of(context)!.diaColor)),
              ColorSelectionSettingsTile(
                  key: const Key('pulColor'),
                  onMainColorChanged: (color) => settings.pulColor = createMaterialColor((color ?? Colors.red).value),
                  initialColor: settings.pulColor,
                  title: Text(AppLocalizations.of(context)!.pulColor)),
            ]),
            SettingsSection(title: Text(AppLocalizations.of(context)!.behavior), children: [
              SwitchSettingsTile(
                  key: const Key('validateInputs'),
                  initialValue: settings.validateInputs,
                  title: Text(AppLocalizations.of(context)!.validateInputs),
                  leading: const Icon(Icons.edit),
                  onToggle: (value) {
                    settings.validateInputs = value;
                  }),
              SwitchSettingsTile(
                  key: const Key('confirmDeletion'),
                  initialValue: settings.confirmDeletion,
                  title: Text(AppLocalizations.of(context)!.confirmDeletion),
                  leading: const Icon(Icons.check),
                  onToggle: (value) {
                    settings.confirmDeletion = value;
                  }),
              InputSettingsTile(
                key: const Key('age'),
                title: Text(AppLocalizations.of(context)!.age),
                description: Text(AppLocalizations.of(context)!.ageDesc),
                leading: const Icon(Icons.manage_accounts_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: settings.age.toString(),
                onEditingComplete: (String? value) {
                  if (value == null || value.isEmpty || (int.tryParse(value) == null)) {
                    return;
                  }
                  settings.age = int.tryParse(value) as int; // no error possible as per above's condition
                },
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.age),
                inputWidth: 80,
                disabled: false,
                // although no function provided, when overriding warn values,
                // this field intentionally doesn't get disabled, as this
                // would cause unexpected jumps in layout
              ),
              SettingsTile(
                  key: const Key('AboutWarnValuesScreen'),
                  title: Text(AppLocalizations.of(context)!.aboutWarnValuesScreen),
                  description: Text(AppLocalizations.of(context)!.aboutWarnValuesScreenDesc),
                  leading: const Icon(Icons.info_outline),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutWarnValuesScreen()),
                    );
                  }),
              SwitchSettingsTile(
                key: const Key('overrideWarnValues'),
                initialValue: settings.overrideWarnValues,
                onToggle: (value) {
                  settings.overrideWarnValues = value;
                },
                leading: const Icon(Icons.tune),
                title: Text(AppLocalizations.of(context)!.overrideWarnValues),
              ),
              InputSettingsTile(
                key: const Key('sysWarn'),
                title: Text(AppLocalizations.of(context)!.sysWarn),
                leading: const Icon(Icons.settings_applications_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: settings.sysWarn.toInt().toString(),
                onEditingComplete: (String? value) {
                  if (value == null || value.isEmpty || (double.tryParse(value) == null)) {
                    return;
                  }
                  // no error possible as per above's condition
                  settings.sysWarn = double.tryParse(value) as double;
                },
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.sysWarn),
                inputWidth: 120,
                disabled: !settings.overrideWarnValues,
              ),
              InputSettingsTile(
                key: const Key('diaWarn'),
                title: Text(AppLocalizations.of(context)!.diaWarn),
                leading: const Icon(Icons.settings_applications_outlined),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                initialValue: settings.diaWarn.toInt().toString(),
                onEditingComplete: (String? value) {
                  if (value == null || value.isEmpty || (double.tryParse(value) == null)) {
                    return;
                  }
                  // no error possible as per above's condition
                  settings.diaWarn = double.tryParse(value) as double;
                },
                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.diaWarn),
                inputWidth: 120,
                disabled: !settings.overrideWarnValues,
              ),
            ]),
            SettingsSection(
              title: Text(AppLocalizations.of(context)!.data),
              children: [
                SettingsTile(
                    title: Text(AppLocalizations.of(context)!.exportImport),
                    leading: const Icon(Icons.download),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onPressed: (context) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExportImportScreen()),
                      );
                    }
                ),
              ],
            ),
            SettingsSection(title: Text(AppLocalizations.of(context)!.aboutWarnValuesScreen), children: [
              SettingsTile(
                  key: const Key('version'),
                  title: Text(AppLocalizations.of(context)!.version),
                  leading: const Icon(Icons.info_outline),
                  description: ConsistentFutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    onData: (context, info) => Text(info.version)
                  ),
                  onPressed: (context) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VersionScreen()),
                    );
                  }
              ),
              SettingsTile(
                key: const Key('sourceCode'),
                title: Text(AppLocalizations.of(context)!.sourceCode),
                leading: const Icon(Icons.merge),
                onPressed: (context) async {
                  var url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .errCantOpenURL('https://github.com/NobodyForNothing/blood-pressure-monitor-fl'))));
                  }
                },
              ),
              SettingsTile(
                key: const Key('licenses'),
                title: Text(AppLocalizations.of(context)!.licenses),
                leading: const Icon(Icons.policy_outlined),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).highlightColor,
                ),
                onPressed: (context) {
                  showLicensePage(context: context);
                },
              ),
            ])
          ],
        );
      }),
    );
  }
}
