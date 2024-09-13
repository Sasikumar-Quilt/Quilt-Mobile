import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  AppUpdateInfo? _updateInfo;

  final FirebaseRemoteConfig _remoteConfig=FirebaseRemoteConfig.instance;
  BuildContext context;
  RemoteConfigService(this.context);

  // Initialize Remote Config with default values
  Future<void> initialize() async {
    await _remoteConfig.setDefaults(<String, dynamic>{
      'force_update_version': '1.0.0',
      'force_update_required': false,
      'update_message': 'Please update the app for better experience.',
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }

  // Get the current version of the app
  Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // Get the minimum version required for the app update
  String getIosUpdateVersion() {
    return _remoteConfig.getString('ios_update_version');
  }
  String getAndroidUpdateVersion() {
    return _remoteConfig.getString('android_update_version');
  }
  // Check if force update is required
  bool isForceUpdateRequired() {
    return _remoteConfig.getBool('force_update_required');
  }

  // Get the update message from Remote Config
  String getUpdateMessage() {
    return _remoteConfig.getString('update_message');
  }

  // Check if the user needs to update the app
  Future<bool> shouldForceUpdate() async {
    print("shouldForceUpdate");
    final currentVersion = await getCurrentVersion();
    print(currentVersion);
    //final forceUpdateRequired = isForceUpdateRequired();
    if(Platform.isAndroid){
      final forceUpdateVersion = getAndroidUpdateVersion();

      print(forceUpdateVersion);
      return (currentVersion != forceUpdateVersion);
    }else{
      final iosUpdateVersion = getIosUpdateVersion();
      print(iosUpdateVersion);
      return (currentVersion != iosUpdateVersion);
    }
  }


  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      _updateInfo = info;
    });
  }

  void androidForceUpdate(){
    if(_updateInfo?.updateAvailability ==
        UpdateAvailability.updateAvailable){
      InAppUpdate.performImmediateUpdate()
          .catchError((e) {
        return AppUpdateResult.inAppUpdateFailed;
      });
    }
  }
  void androidFlexUpdate(){
    if(_updateInfo?.updateAvailability ==
        UpdateAvailability.updateAvailable){
      InAppUpdate.startFlexibleUpdate()
          .catchError((e) {
        return AppUpdateResult.inAppUpdateFailed;
      });
    }
  }
}
