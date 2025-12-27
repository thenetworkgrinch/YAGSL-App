import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yagsl_app/DataController.dart';
import 'package:yagsl_app/configPages/swervedrive.dart';
import 'package:yagsl_app/persistent_bottom_bar_scaffold.dart';

class HomePage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  // final _tab3navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: TabPage1(),
          icon: Icons.settings,
          title: 'Config',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: TabPage2(),
          icon: Icons.run_circle,
          title: 'Search',
          navigatorkey: _tab2navigatorKey,
        ),
        // PersistentTabItem(
        //   tab: TabPage3(),
        //   icon: Icons.person,
        //   title: 'Profile',
        //   navigatorkey: _tab3navigatorKey,
        // ),
      ],
    );
  }
}

class TabPage1 extends StatelessWidget {
  const TabPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataController = Provider.of<DataController>(context);
    print('TabPage1 build');
    return Scaffold(
      appBar: AppBar(title: Text('Config')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        alignment: Alignment.topLeft,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              decoration: new InputDecoration(labelText: "Enter Team Number"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                if (int.tryParse(value) != null) {
                  dataController.setTeamNumber(int.parse(value));
                } else {}
              },
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => swerveDriveConfig()));
              },
              label: Text('Swerve Drive Config'),
              icon: Icon(
                  dataController.completeConfig
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: dataController.completeConfig
                      ? Colors.green
                      : Colors.grey,
                  size: 24.0),
              style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: Size(double.infinity, 50),
                shape: new BeveledRectangleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabPage2 extends StatelessWidget {
  Future<void> runGradleFromZip(int teamNumber) async {
    try {
      // Step 1: Load the ZIP file from assets
      final byteData = await rootBundle.load('assets/YAGSL-Tuner.zip');
      final zipBytes = byteData.buffer.asUint8List();

      // Step 2: Decode the ZIP file
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // Step 3: Extract the ZIP file to a temporary directory
      final tempDir = await FilePicker.platform.getDirectoryPath();
      final gradleDirPath = '${tempDir}';

      for (final file in archive) {
        final filePath = '$gradleDirPath\\${file.name}';

        if (file.isFile) {
          // Create the file and write its content
          final outputFile = File(filePath);
          outputFile.createSync(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        } else {
          // Create the directory
          Directory(filePath).createSync(recursive: true);
        }
      }

      print('Gradle files extracted to: $gradleDirPath');

      final teamFile =
          File('$gradleDirPath\\YAGSL-Tuner\\.wpilib\\wpilib_preferences.json');
      final teamJson = await json.decode(await teamFile.readAsString());
      teamJson["teamNumber"] = teamNumber;
      print(await json.encode(teamJson));
      teamFile.writeAsString(JsonEncoder.withIndent("    ").convert(teamJson));

      // Step 4: Make gradlew.bat executable (if on a non-Windows platform)
      if (!Platform.isWindows) {
        Process.runSync(
            'chmod', ['+x', '$gradleDirPath\\YAGSL-Tuner\\gradlew.sh']);
      }

      // Step 5: Run the gradlew.bat script
      ProcessResult result = await Process.run(
        '$gradleDirPath\\YAGSL-Tuner\\gradlew.bat',
        ['deploy'], // Example Gradle task
        workingDirectory: '$gradleDirPath\\YAGSL-Tuner',
        runInShell: true,
      );

      // Output results
      print('Exit code: ${result.exitCode}');
      print('Stdout: ${result.stdout}');
      print('Stderr: ${result.stderr}');
    } catch (e) {
      print('Error running Gradle from ZIP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataController = Provider.of<DataController>(context);
    print('TabPage2 build');
    return Scaffold(
      appBar: AppBar(title: Text('Config')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        alignment: Alignment.topLeft,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (dataController.teamNumber != 0)
                  runGradleFromZip(dataController.teamNumber);
              },
              label: Text(dataController.teamNumber != 0
                  ? 'Connect to Rio'
                  : 'Connect to Sim'),
              style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: Size(double.infinity, 50),
                shape: new BeveledRectangleBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

