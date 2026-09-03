import 'package:LawyerOnline/gwealth/data/mock_data.dart';
import 'package:LawyerOnline/gwealth/theme.dart';
import 'package:LawyerOnline/gwealth/widgets/gw_app_bar.dart';
import 'package:flutter/material.dart';

class GWServicesAllPage extends StatelessWidget {
  const GWServicesAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GW.bg,
      appBar: const GWAppBar(title: 'บริการทั้งหมด'),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: GWData.services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.28,
        ),
        itemBuilder: (context, i) {
          final s = GWData.services[i];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GW.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s.icon, color: GW.iconPink, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      s.title.replaceAll('\n', ' '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GW.text(size: 14, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
