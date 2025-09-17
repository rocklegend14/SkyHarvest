import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterBarWidget extends StatelessWidget {
  final String selectedFilter;
  final String sortBy;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const FilterBarWidget({
    super.key,
    required this.selectedFilter,
    required this.sortBy,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Filter Dropdown
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'applied', child: Text('Applied')),
                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onFilterChanged(value);
                },
              ),
            ),
          ),
        ),

        SizedBox(width: 12),

        // Sort Dropdown
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sortBy,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'date', child: Text('Created Date')),
                  DropdownMenuItem(
                    value: 'application_date',
                    child: Text('Application Date'),
                  ),
                  DropdownMenuItem(value: 'cost', child: Text('Cost')),
                  DropdownMenuItem(value: 'amount', child: Text('Amount')),
                ],
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
