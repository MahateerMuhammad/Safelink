import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../helpers/ad_helper.dart'; // COMMENTED OUT (No ads for now)
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() async {
    print('🔗 connectToVpn called - Current state: ${vpnState.value}');
    print('🔗 VPN hostname: ${vpn.value.hostname}');
    print('🔗 VPN config length: ${vpn.value.openVPNConfigDataBase64.length}');
    
    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      print('❌ No VPN configuration found');
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      try {
        print('🚀 Starting VPN connection...');
        
        final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
        final config = Utf8Decoder().convert(data);
        
        print('🔧 VPN Config preview: ${config.substring(0, math.min(200, config.length))}...');
        
        final vpnConfig = VpnConfig(
            country: vpn.value.countryLong,
            username: 'vpn',
            password: 'vpn',
            config: config);

        print('🌍 Connecting to: ${vpn.value.countryLong} (${vpn.value.hostname})');
        
        // Direct VPN connection without ads
        await VpnEngine.startVpn(vpnConfig);
        print('✅ VPN start command sent');
      } catch (e) {
        print('❌ Error connecting to VPN: $e');
        MyDialogs.error(msg: 'Failed to connect to VPN: ${e.toString()}');
      }
    } else {
      try {
        print('🛑 Stopping VPN connection...');
        await VpnEngine.stopVpn();
        print('✅ VPN stop command sent');
      } catch (e) {
        print('❌ Error stopping VPN: $e');
        // Don't show error for stop operations
      }
    }
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.blue;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';

      case VpnEngine.vpnConnected:
        return 'Disconnect';

      default:
        return 'Connecting...';
    }
  }
}
