import 'package:flutter/material.dart';
import '../app_essentials/colors.dart';

class SearchablePicker<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) getLabel;
  final String? Function(T)? getSubtitle;
  final bool allowMultiple;
  final List<T>? selectedItems;

  const SearchablePicker({
    Key? key,
    required this.title,
    required this.items,
    required this.getLabel,
    this.getSubtitle,
    this.allowMultiple = false,
    this.selectedItems,
  }) : super(key: key);

  @override
  State<SearchablePicker<T>> createState() => _SearchablePickerState<T>();
}

class _SearchablePickerState<T> extends State<SearchablePicker<T>> {
  final _searchController = TextEditingController();
  List<T> _filteredItems = [];
  List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    if (widget.selectedItems != null) {
      _selectedItems = List.from(widget.selectedItems!);
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items.where((item) {
        final label = widget.getLabel(item).toLowerCase();
        final subtitle = widget.getSubtitle?.call(item)?.toLowerCase() ?? '';
        return label.contains(query.toLowerCase()) ||
            subtitle.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _toggleItem(T item) {
    setState(() {
      if (widget.allowMultiple) {
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      } else {
        Navigator.pop(context, item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (widget.allowMultiple)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedItems);
                    },
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterItems,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = _selectedItems.contains(item);
                return ListTile(
                  title: Text(
                    widget.getLabel(item),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: widget.getSubtitle != null
                      ? Text(
                          widget.getSubtitle!(item) ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: widget.allowMultiple
                      ? Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => _toggleItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
