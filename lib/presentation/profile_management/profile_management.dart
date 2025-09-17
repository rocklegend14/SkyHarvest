import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_image_widget.dart';
import './widgets/account_actions_section.dart';
import './widgets/edit_profile_dialog.dart';
import './widgets/farm_fields_section.dart';
import './widgets/profile_info_section.dart';
import './widgets/profile_statistics_card.dart';
import 'widgets/account_actions_section.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/farm_fields_section.dart';
import 'widgets/profile_info_section.dart';
import 'widgets/profile_statistics_card.dart';

class ProfileManagement extends StatefulWidget {
  const ProfileManagement({super.key});

  @override
  State<ProfileManagement> createState() => _ProfileManagementState();
}

class _ProfileManagementState extends State<ProfileManagement>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  UserProfile? _profile;
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _fields = [];

  bool _isLoading = false;
  bool _isUploadingImage = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final profileResult = await _profileService.getCurrentUserProfile();
      final statisticsResult = await _profileService.getProfileStatistics();
      final fieldsResult = await _profileService.getUserFields();

      setState(() {
        _profile = profileResult;
        _statistics = statisticsResult;
        _fields = fieldsResult;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadProfileImage() async {
    setState(() => _isUploadingImage = true);
    try {
      await _profileService.uploadProfileImage();
      await _loadProfileData(); // Refresh profile data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile image updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;

    showDialog(
      context: context,
      builder:
          (context) => EditProfileDialog(
            profile: _profile!,
            onProfileUpdated: () {
              _loadProfileData();
            },
          ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Sign Out'),
            content: Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sign Out'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.signOut();
        Navigator.of(context).pushReplacementNamed('/login-screen');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadProfileData,
                child: CustomScrollView(
                  slivers: [
                    // App Bar with Profile Header
                    SliverAppBar(
                      expandedHeight: 280,
                      floating: false,
                      pinned: true,
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.green[600]!, Colors.green[800]!],
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                // Profile Image
                                Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child:
                                          _profile?.profileImageUrl != null
                                              ? CustomImageWidget(
                                                imagePath:
                                                    _profile!.profileImageUrl!,
                                                height: 120,
                                                width: 120,
                                                radius: BorderRadius.circular(
                                                  60,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : CircleAvatar(
                                                radius: 60,
                                                backgroundColor: Colors.white,
                                                child: Text(
                                                  _profile?.initials ?? 'U',
                                                  style: TextStyle(
                                                    fontSize: 36.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[700],
                                                  ),
                                                ),
                                              ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _uploadProfileImage,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child:
                                              _isUploadingImage
                                                  ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                  : Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                // Profile Name
                                Text(
                                  _profile?.fullName ?? 'Unknown User',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                SizedBox(height: 4),

                                // Role and Farm
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(51),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _profile?.roleDisplay ?? 'User',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_profile?.farmName != null) ...[
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(51),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _profile!.farmName!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        title: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _showEditProfileDialog,
                          icon: Icon(Icons.edit),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'settings':
                                Navigator.of(
                                  context,
                                ).pushNamed('/application-settings');
                                break;
                              case 'signout':
                                _signOut();
                                break;
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'settings',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.settings,
                                        size: 20,
                                        color: Colors.grey[700],
                                      ),
                                      SizedBox(width: 8),
                                      Text('Settings'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'signout',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: Colors.red[600],
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                    ),

                    // Tab Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.green[700],
                          unselectedLabelColor: Colors.grey[500],
                          indicatorColor: Colors.green[700],
                          tabs: [
                            Tab(text: 'Overview'),
                            Tab(text: 'Fields'),
                            Tab(text: 'Account'),
                          ],
                        ),
                      ),
                    ),

                    // Tab Content
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Overview Tab
                          SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (_statistics.isNotEmpty)
                                  ProfileStatisticsCard(
                                    statistics: _statistics,
                                  ),
                                SizedBox(height: 20),
                                if (_profile != null)
                                  ProfileInfoSection(profile: _profile!),
                              ],
                            ),
                          ),

                          // Fields Tab
                          FarmFieldsSection(
                            fields: _fields,
                            onFieldsChanged: _loadProfileData,
                          ),

                          // Account Tab
                          AccountActionsSection(
                            profile: _profile,
                            onProfileUpdated: _loadProfileData,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
