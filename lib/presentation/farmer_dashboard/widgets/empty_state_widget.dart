import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddField;

  const EmptyStateWidget({
    Key? key,
    required this.onAddField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageWidget(
            imageUrl:
                "https://images.unsplash.com/photo-1574943320219-553eb213f72d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
            width: 60.w,
            height: 30.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 4.h),
          Text(
            'Welcome to SkyHarvest!',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'Start your smart farming journey by mapping your first field. Get AI-powered predictions and optimize your crop yields.',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddField,
              icon: CustomIconWidget(
                iconName: 'add_location',
                size: 5.w,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              label: Text('Map Your First Field'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          TextButton.icon(
            onPressed: () {
              // Show tutorial or help
            },
            icon: CustomIconWidget(
              iconName: 'help_outline',
              size: 4.w,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: Text('How it works'),
          ),
        ],
      ),
    );
  }
}
