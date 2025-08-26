import 'package:flutter/material.dart';

import '../main.dart';
import '../models/network_data.dart';

class NetworkCard extends StatelessWidget {
  final NetworkData data;

  const NetworkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        shadowColor: SafeLinkColors.primaryTeal.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SafeLinkColors.primaryTeal.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              data.icon,

              SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SafeLinkColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      data.subtitle.isEmpty ? 'Fetching...' : data.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: data.subtitle.isEmpty 
                            ? SafeLinkColors.textSecondary.withOpacity(0.6)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white : SafeLinkColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
