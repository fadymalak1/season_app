import 'package:country_code_picker/country_code_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/localization/generated/l10n.dart';
import 'package:season_app/core/router/routes.dart';
import 'package:season_app/features/profile/providers.dart';
import 'package:season_app/features/vendor/presentation/providers/vendor_providers.dart';
import 'package:season_app/shared/widgets/custom_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile on init
    Future.microtask(() => ref.read(profileControllerProvider.notifier).loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final vendorServicesAsync = ref.watch(vendorServicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    // Check if user has services
    final hasServices = vendorServicesAsync.maybeWhen(
      data: (services) => services.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.errorLoadingProfile,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(profileControllerProvider.notifier).loadProfile();
                        },
                        child: Text(loc.resendCode),
                      ),
                    ],
                  ),
                )
              : profileState.profile == null
                  ? Center(child: Text(loc.errorLoadingProfile))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(profileControllerProvider.notifier).loadProfile();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Profile Header with gradient
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary,
                                  ],
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                                  child: Column(
                                    children: [
                                      // Settings Icon - RTL aware positioning
                                      Align(
                                        alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                context.push(Routes.settings);
                                              },
                                              borderRadius: BorderRadius.circular(12),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.settings,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Profile Image
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: profileState.profile?.avatarPath != null
                                  ? AssetImage(profileState.profile!.avatarPath!)
                                  : (profileState.profile?.photoUrl != null
                                      ? CachedNetworkImageProvider(
                                          profileState.profile!.photoUrl!,
                                        )
                                      : null) as ImageProvider?,
                              child: profileState.profile?.avatarPath == null && profileState.profile?.photoUrl == null
                                  ? Text(
                                      profileState.profile?.name[0].toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                context.push('/profile/edit');
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Name
                                      Text(
                                        profileState.profile?.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (profileState.profile?.nickname != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          '@${profileState.profile!.nickname}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      // Email
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            profileState.profile?.email ?? '',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),              

                            // Personal Information Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                       
                                  const SizedBox(height: 16),
                                  _buildPhoneCard(
                                    phone: profileState.profile?.phone ?? '',
                                    isRTL: isRTL,
                                    title: loc.phone,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoCard(
                                    icon: Icons.cake,
                                    title: loc.birthDate,
                                    value: profileState.profile?.birthDate ?? loc.optional,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoCard(
                                    icon: Icons.person,
                                    title: loc.gender,
                                    value: profileState.profile?.gender != null
                                        ? (profileState.profile!.gender == 'male' ? loc.male : loc.female)
                                        : loc.optional,
                                  ),
                           
                                  const SizedBox(height: 24),

                                  CustomButton(
                                    text: hasServices ? loc.myServices : loc.applyAsServiceProvider,
                                    color: AppColors.secondary,
                                    onPressed: () {
                                      context.push(Routes.vendorServices);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard({
    required String phone,
    required bool isRTL,
    required String title,
  }) {
    // Parse phone to extract country code and number
    String displayPhone = phone;
    
    if (phone.isNotEmpty) {
      final plusIndex = phone.indexOf('+');
      if (plusIndex != -1) {
        // Find the end of the country code
        final spaceIndex = phone.indexOf(' ', plusIndex);
        if (spaceIndex != -1) {
          final countryCodeStr = phone.substring(plusIndex, spaceIndex);
          final number = phone.substring(spaceIndex + 1);
          
          // Try to get the country code
          try {
            final code = CountryCode.fromDialCode(countryCodeStr);
            
            // Display phone with code and number (right to left for Arabic, left to right for English)
            if (isRTL) {
              displayPhone = '$number ${code.dialCode}';
            } else {
              displayPhone = '${code.dialCode} $number';
            }
          } catch (e) {
            displayPhone = phone;
          }
        } else {
          displayPhone = phone;
        }
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.phone,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayPhone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

