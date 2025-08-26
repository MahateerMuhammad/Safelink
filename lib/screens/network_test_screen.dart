import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../main.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../widgets/network_card.dart';

class NetworkTestScreen extends StatelessWidget {
  const NetworkTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);

    return Scaffold(
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
              'Network Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Your connection details',
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
              onPressed: () {
                ipData.value = IPDetails.fromJson({});
                APIs.getIPDetails(ipData: ipData);
              },
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

      body: Obx(
        () => Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              // Header card with overall status
              Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SafeLinkColors.primaryTeal,
                      SafeLinkColors.secondaryBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.network_check_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Network Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      ipData.value.query.isEmpty ? 'Checking...' : 'Connected',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              //ip
              NetworkCard(
                data: NetworkData(
                  title: 'IP Address',
                  subtitle: ipData.value.query.isEmpty ? 'Fetching...' : ipData.value.query,
                  icon: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafeLinkColors.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.location_solid,
                      color: SafeLinkColors.primaryTeal,
                      size: 24,
                    ),
                  ),
                ),
              ),

              //isp
              NetworkCard(
                data: NetworkData(
                  title: 'Internet Provider',
                  subtitle: ipData.value.isp.isEmpty ? 'Fetching...' : ipData.value.isp,
                  icon: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafeLinkColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: SafeLinkColors.secondaryBlue,
                      size: 24,
                    ),
                  ),
                ),
              ),

              //location
              NetworkCard(
                data: NetworkData(
                  title: 'Location',
                  subtitle: ipData.value.country.isEmpty
                      ? 'Fetching...'
                      : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                  icon: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafeLinkColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.location,
                      color: SafeLinkColors.accentGreen,
                      size: 24,
                    ),
                  ),
                ),
              ),

              //pin code
              NetworkCard(
                data: NetworkData(
                  title: 'Postal Code',
                  subtitle: ipData.value.zip.isEmpty ? 'Fetching...' : ipData.value.zip,
                  icon: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafeLinkColors.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.pin,
                      color: SafeLinkColors.errorRed,
                      size: 24,
                    ),
                  ),
                ),
              ),

              //timezone
              NetworkCard(
                data: NetworkData(
                  title: 'Timezone',
                  subtitle: ipData.value.timezone.isEmpty ? 'Fetching...' : ipData.value.timezone,
                  icon: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SafeLinkColors.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.time,
                      color: SafeLinkColors.primaryTeal,
                      size: 24,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
