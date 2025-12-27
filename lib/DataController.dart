import 'package:flutter/material.dart';
import 'package:yagsl_app/jsonContruction/imu.dart';
import 'package:yagsl_app/jsonContruction/swerve_drive.dart';

class DataController with ChangeNotifier {


  //Data
  int teamNumber = 0;
  bool completeConfig = false;
  SwerveDrive swervedriveJson = SwerveDrive(new Imu("pigeon", 0, null), false);


  void toggle() {
    completeConfig = !completeConfig;
    notifyListeners();
  }

  void setTeamNumber(num) {
    teamNumber = num;
    notifyListeners();
  }
}