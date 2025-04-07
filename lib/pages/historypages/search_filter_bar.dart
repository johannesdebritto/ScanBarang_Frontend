import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final List<String> filters;
  final String? selectedFilter;
  final Function(String?) onFilterSelected;
  final Function(String) onSearchChanged;

  const SearchFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onSearchChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: widget.filters.map((filter) {
            return ListTile(
              title: Text(filter),
              trailing: widget.selectedFilter == filter
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                widget.onFilterSelected(filter);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Riwayat',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 12.0),
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4cc9f0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: _showFilterDialog,
              child: const Icon(Icons.filter_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
