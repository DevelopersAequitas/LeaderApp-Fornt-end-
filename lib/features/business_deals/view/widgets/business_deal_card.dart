import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/business_deal_model.dart';

class BusinessDealCard extends StatelessWidget {
  final BusinessDealModel deal;
  final VoidCallback? onTap;

  const BusinessDealCard({
    super.key,
    required this.deal,
    this.onTap,
  });

  void _navigateToPeer(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.peerProfile,
      arguments: deal.toPeerModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => _navigateToPeer(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Peer Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InitialsAvatar(
                      name: deal.peerName,
                      imageUrl: deal.profileImage.isNotEmpty ? deal.profileImage : null,
                      radius: 20,
                      backgroundColor: const Color(0xFF16A34A),
                      fontSize: 11,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  deal.peerName,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                deal.amountFormatted,
                                style: const TextStyle(
                                  color: Color(0xFF16A34A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (deal.businessName.isNotEmpty) deal.businessName,
                              if (deal.city.isNotEmpty) deal.city,
                              if (deal.categoryLevel4.isNotEmpty) deal.categoryLevel4,
                            ].join(' · '),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (deal.notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      deal.notes,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.9),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Footer
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(
                        deal.dealType.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Peer Profile',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
