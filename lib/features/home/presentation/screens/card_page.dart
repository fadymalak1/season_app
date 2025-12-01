import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/features/home/controllers/user_qr_controller.dart';
import 'package:season_app/core/localization/generated/l10n.dart';

class CardPage extends ConsumerStatefulWidget {
  const CardPage({super.key});

  @override
  ConsumerState<CardPage> createState() => _CardPageState();
}

class _CardPageState extends ConsumerState<CardPage> {
  @override
  void initState() {
    super.initState();
    // Load user QR data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userQrControllerProvider.notifier).loadUserQr();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userQrState = ref.watch(userQrControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          l10n.card,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            userQrState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userQrState.error != null
                    ? _buildErrorWidget(userQrState.error!, l10n)
                    : userQrState.userQr != null
                        ? _buildCardWidget(userQrState.userQr!, l10n)
                        : const SizedBox.shrink(),
            if (userQrState.userQr != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.errorLoadingCardData,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ref.read(userQrControllerProvider.notifier).loadUserQr();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            l10n.retry,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardWidget(userQr, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/png/card_background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay for better text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            
            // Card Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Name
                  Text(
                    userQr.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
               
                  // QR Code
                
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: QrImageView(
                        data: userQr.qrCodeUrl,
                        version: QrVersions.auto,
                        size: 80.0,
                        
                        foregroundColor: AppColors.primary,
                        backgroundColor: Colors.white,
                      ),
                  ),
                     const SizedBox(height: 8),
                  // Loyalty Points
                      Text(
                    l10n.loyaltyPoints,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                    Text(
                      '${userQr.coins} ${l10n.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
               
             
                  // Card Label
             
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    l10n.howToUseCard,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
      
                _buildInfoItem(
                  icon: Icons.stars,
                  title: l10n.collectPoints,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  icon: Icons.card_giftcard,
                  title: l10n.exclusiveRewards,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'Cairo',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

