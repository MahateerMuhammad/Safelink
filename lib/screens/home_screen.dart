import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
// import '../helpers/ad_helper.dart'; // COMMENTED OUT (No ads for now)
// import '../helpers/config.dart'; // COMMENTED OUT (No ads for now)
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
// import '../widgets/watch_ad_dialog.dart'; // COMMENTED OUT (No ads for now)
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      //modern app bar
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SafeLinkColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Safe',
              style: TextStyle(
                color: SafeLinkColors.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Link',
              style: TextStyle(
                color: SafeLinkColors.secondaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                Get.changeThemeMode(
                    Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                Pref.isDarkMode = !Pref.isDarkMode;
              },
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SafeLinkColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Pref.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: SafeLinkColors.primaryTeal,
                  size: 20,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => Get.to(() => NetworkTestScreen()),
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SafeLinkColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CupertinoIcons.info,
                  color: SafeLinkColors.secondaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _changeLocation(context),

      //modern body with better spacing and cards
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //connection status header
            _buildConnectionStatusHeader(),
            
            SizedBox(height: 30),

            //vpn button
            Obx(() => _vpnButton()),

            SizedBox(height: 40),

            //server and connection info cards
            Obx(() => _buildInfoCards()),

            SizedBox(height: 30),

            //speed and data usage cards
            _buildSpeedCards(),

            SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusHeader() {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _controller.vpnState.value == VpnEngine.vpnDisconnected
                ? 'Disconnected'
                : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    ));
  }

  Color _getStatusColor() {
    switch (_controller.vpnState.value) {
      case VpnEngine.vpnConnected:
        return SafeLinkColors.accentGreen;
      case VpnEngine.vpnDisconnected:
        return SafeLinkColors.errorRed;
      default:
        return SafeLinkColors.secondaryBlue;
    }
  }

  //modern vpn button with glassmorphism effect
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: () {
                _controller.connectToVpn();
              },
              child: Container(
                width: mq.height * .22,
                height: mq.height * .22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _controller.getButtonColor,
                      _controller.getButtonColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _controller.getButtonColor.withOpacity(0.3),
                      blurRadius: 25,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //icon
                      Icon(
                        Icons.power_settings_new_rounded,
                        size: 40,
                        color: Colors.white,
                      ),

                      SizedBox(height: 8),

                      //text
                      Text(
                        _controller.getButtonText,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          //count down timer
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: HomeCard(
            title: _controller.vpn.value.countryLong.isEmpty
                ? 'Select Location'
                : _controller.vpn.value.countryLong,
            subtitle: 'SERVER LOCATION',
            icon: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: SafeLinkColors.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _controller.vpn.value.countryLong.isEmpty
                  ? Icon(
                      Icons.public_rounded,
                      size: 30,
                      color: SafeLinkColors.primaryTeal,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
        
        SizedBox(width: 16),
        
        Expanded(
          child: HomeCard(
            title: _controller.vpn.value.countryLong.isEmpty
                ? '-- ms'
                : '${_controller.vpn.value.ping} ms',
            subtitle: 'PING',
            icon: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: SafeLinkColors.secondaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.speed_rounded,
                size: 30,
                color: SafeLinkColors.secondaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedCards() {
    return StreamBuilder<VpnStatus?>(
      initialData: VpnStatus(),
      stream: VpnEngine.vpnStatusSnapshot(),
      builder: (context, snapshot) => Row(
        children: [
          Expanded(
            child: HomeCard(
              title: snapshot.data?.byteIn ?? '0 KB/s',
              subtitle: 'DOWNLOAD',
              icon: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: SafeLinkColors.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.download_rounded,
                  size: 30,
                  color: SafeLinkColors.accentGreen,
                ),
              ),
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: HomeCard(
              title: snapshot.data?.byteOut ?? '0 KB/s',
              subtitle: 'UPLOAD',
              icon: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: SafeLinkColors.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.upload_rounded,
                  size: 30,
                  color: SafeLinkColors.errorRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //modern bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
    child: Container(
      margin: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  SafeLinkColors.primaryTeal,
                  SafeLinkColors.secondaryBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.location,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Select your preferred server',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
