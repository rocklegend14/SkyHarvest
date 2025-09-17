import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FieldSelectorWidget extends StatefulWidget {
  final List<Map<String, dynamic>> fields;
  final String selectedFieldId;
  final Function(String) onFieldChanged;

  const FieldSelectorWidget({
    Key? key,
    required this.fields,
    required this.selectedFieldId,
    required this.onFieldChanged,
  }) : super(key: key);

  @override
  State<FieldSelectorWidget> createState() => _FieldSelectorWidgetState();
}

class _FieldSelectorWidgetState extends State<FieldSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'location_on',
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Text(
            'Field:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedFieldId,
                isExpanded: true,
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                items: widget.fields.map<DropdownMenuItem<String>>((field) {
                  return DropdownMenuItem<String>(
                    value: field['id'] as String,
                    child: Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                            color: Color(int.parse(field['color'] as String)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            field['name'] as String,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          field['area'] as String,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onFieldChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
