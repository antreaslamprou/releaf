import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:releaf/components/application_mission.dart';
import 'package:releaf/components/color_picker_grid.dart';
import 'package:releaf/components/suggest_task.dart';
import 'package:releaf/pages/template_single_page.dart';
import 'package:releaf/providers/text_scale_provider.dart';
import 'package:releaf/providers/theme_provider.dart';
import 'package:releaf/extensions/text_theme_x.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Call the toogle theme on switch tap
  void toggleTheme(bool value) {
    context.read<ThemeProvider>().toggleTheme(value);
  }

  // Call the toogle text scale on switch tap
  void toggleTextScale(bool value) {
    context.read<TextScaleProvider>().toogleTextScale();
  }

  // Shows the settings page
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: context.text.titleSmall),
          Divider(),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Theme',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Checkbox(
                value:
                    context.watch<ThemeProvider>().themeMode ==
                    ThemeMode.system,
                onChanged: (bool? value) {
                  context.read<ThemeProvider>().toggleSystemTheme(
                    value ?? false,
                  );
                },
                activeColor: context.read<ThemeProvider>().primaryColor,
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      context.read<ThemeProvider>().themeMode ==
                          ThemeMode.system
                      ? Colors.grey
                      : null,
                ),
              ),
              FlutterSwitch(
                value:
                    context.watch<ThemeProvider>().brightness ==
                    Brightness.dark,
                activeIcon: Icon(
                  Icons.nightlight_round,
                  color:
                      context.read<ThemeProvider>().themeMode ==
                          ThemeMode.system
                      ? Colors.grey
                      : Colors.black,
                ),
                activeColor:
                    context.read<ThemeProvider>().themeMode == ThemeMode.system
                    ? Colors.grey
                    : context.read<ThemeProvider>().primaryColor,
                activeTextColor:
                    context.read<ThemeProvider>().themeMode == ThemeMode.system
                    ? Colors.grey.shade600
                    : Colors.white,
                activeText: 'Dark',
                inactiveIcon: Icon(
                  Icons.wb_sunny,
                  color:
                      context.read<ThemeProvider>().themeMode ==
                          ThemeMode.system
                      ? Colors.grey
                      : null,
                ),
                inactiveColor:
                    context.read<ThemeProvider>().themeMode == ThemeMode.system
                    ? Colors.grey
                    : context.read<ThemeProvider>().primaryColor,
                inactiveTextColor:
                    context.read<ThemeProvider>().themeMode == ThemeMode.system
                    ? Colors.grey.shade600
                    : Colors.black,
                inactiveText: 'Light',
                showOnOff: true,
                width: 80,
                onToggle: (value) {
                  if (context.read<ThemeProvider>().themeMode !=
                      ThemeMode.system) {
                    toggleTheme(value);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Highlight Color',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          ColorPickerGrid(
            selectedColor: context.watch<ThemeProvider>().primaryColor,
            onColorSelected: (color) {
              context.read<ThemeProvider>().setPrimaryColor(color);
            },
          ),
          SizedBox(height: 25),
          Text('Font', style: context.text.titleSmall),
          Divider(),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Large Text', style: TextStyle(fontWeight: FontWeight.bold)),
              FlutterSwitch(
                value: context.watch<TextScaleProvider>().scaleFactor != 1,
                activeIcon: Icon(Icons.check, color: Colors.black),
                activeColor: context.read<ThemeProvider>().primaryColor,
                activeTextColor: Colors.white,
                activeText: 'On',
                inactiveIcon: Icon(Icons.close, color: Colors.black),
                inactiveTextColor: Colors.black,
                inactiveText: 'Off',
                showOnOff: true,
                width: 80,
                onToggle: toggleTextScale,
              ),
            ],
          ),
          SizedBox(height: 25),
          Text('About', style: context.text.titleSmall),
          Divider(),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Application Mission',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TemplateSinglePage(
                      title: 'Application Mission',
                      body: ApplicationMission(),
                    ),
                  ),
                ),
                icon: Icon(Icons.arrow_forward_ios, size: 18),
              ),
            ],
          ),
          SizedBox(height: 30),
          FractionallySizedBox(
            widthFactor: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TemplateSinglePage(
                        title: 'Suggest a Task',
                        body: SuggestTask(),
                      ),
                    ),
                  ),
                  child: Text(
                    'Have a suggestion for a potential task?\nSuggest a task here!',
                    textAlign: TextAlign.center,
                    style: context.text.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
