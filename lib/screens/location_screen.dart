import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // COMMENTED OUT (No ads for now)
import 'package:lottie/lottie.dart';

import '../controllers/location_controller.dart';
// import '../controllers/native_ad_controller.dart'; // COMMENTED OUT (No ads for now)
// import '../helpers/ad_helper.dart'; // COMMENTED OUT (No ads for now)
import '../main.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({super.key});

  final _controller = LocationController();
  // final _adController = NativeAdController(); // COMMENTED OUT (No ads for now)

  @override
  Widget build(BuildContext context) {
    if (_controller.vpnList.isEmpty) _controller.getVpnData();

    // _adController.ad = AdHelper.loadNativeAd(adController: _adController); // COMMENTED OUT (No ads for now)

    return Obx(
      () => Scaffold(
        //modern app bar
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SafeLinkColors.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: SafeLinkColors.primaryTeal,
                size: 18,
              ),
            ),
          ),
          title: Column(
            children: [
              Text(
                'Server Locations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_controller.vpnList.length} servers available',
                style: TextStyle(
                  fontSize: 12,
                  color: SafeLinkColors.textSecondary,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => _controller.getVpnData(),
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SafeLinkColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.refresh,
                    color: SafeLinkColors.secondaryBlue,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: null, // COMMENTED OUT (No ads for now)

        body: _controller.isLoading.value
            ? _loadingWidget()
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : _vpnData(),
      ),
    );
  }

  _vpnData() => Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: ListView.builder(
      itemCount: _controller.vpnList.length,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 20,
        bottom: 100,
      ),
      itemBuilder: (ctx, i) => VpnCard(vpn: _controller.vpnList[i]),
    ),
  );

    _loadingWidget() => Container(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SafeLinkColors.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 100,
          ),
        ),
        
        SizedBox(height: 30),
        
        Text(
          'Finding best servers...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: SafeLinkColors.textDark,
          ),
        ),
        
        SizedBox(height: 8),
        
        Text(
          'Please wait while we fetch the latest server list',
          style: TextStyle(
            color: SafeLinkColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  _noVPNFound() => Container(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: SafeLinkColors.errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            size: 60,
            color: SafeLinkColors.errorRed,
          ),
        ),
        
        SizedBox(height: 30),
        
        Text(
          'No servers found!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SafeLinkColors.textDark,
          ),
        ),
        
        SizedBox(height: 12),
        
        Text(
          'Unable to fetch server list. Please check your internet connection and try again.',
          style: TextStyle(
            color: SafeLinkColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 30),
        
        ElevatedButton.icon(
          onPressed: () => _controller.getVpnData(),
          icon: Icon(Icons.refresh_rounded),
          label: Text('Retry'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    ),
  );
}
