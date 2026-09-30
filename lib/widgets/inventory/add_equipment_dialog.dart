import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/equipment_item.dart';
import '../../widgets/rentflow_button.dart';

/// Bottom sheet modal for adding new equipment inventory assets.
///
/// Flutter & Dart Concepts:
/// - Modal form interaction designed for tablet or mobile warehouse use.
/// - Returns newly created [EquipmentItem] to parent state.
class AddEquipmentDialog extends StatefulWidget {
  final ValueChanged<EquipmentItem> onEquipmentAdded;

  const AddEquipmentDialog({
    super.key,
    required this.onEquipmentAdded,
  });

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _totalController = TextEditingController();
  final _rateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Sound Systems';

  final List<String> _categories = const [
    'Sound Systems',
    'Stage Lighting',
    'Video & Screens',
    'Staging',
    'Event Furniture',
    'Cables & Distro',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _totalController.dispose();
    _rateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final total = int.tryParse(_totalController.text.trim()) ?? 1;
      final rate = double.tryParse(_rateController.text.trim()) ?? 50.0;

      final newItem = EquipmentItem(
        id: 'EQ-${DateTime.now().millisecondsSinceEpoch % 1000}',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        sku: _skuController.text.trim().toUpperCase(),
        totalQuantity: total,
        availableQuantity: total,
        dailyRate: rate,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Newly registered inventory unit.',
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : 'Bay A-01 • Warehouse',
        status: 'Available',
      );

      widget.onEquipmentAdded(newItem);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Grabber
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.structuralBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Equipment',
                    style: AppTextStyles.brandTitle.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20, color: AppColors.borderSubtle),

              // Equipment Name
              _buildFieldLabel('EQUIPMENT NAME *'),
              TextFormField(
                controller: _nameController,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter equipment title'
                    : null,
                decoration: const InputDecoration(
                  hintText: 'e.g., Sennheiser Wireless Lavalier Mic',
                ),
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              _buildFieldLabel('EQUIPMENT CATEGORY *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),

              // SKU & Total Quantity
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('SKU / ASSET TAG *'),
                        TextFormField(
                          controller: _skuController,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Enter SKU'
                              : null,
                          decoration: const InputDecoration(
                            hintText: 'SKU-SND-108',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('TOTAL UNITS *'),
                        TextFormField(
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            final parsed = int.tryParse(val ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Min 1';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'e.g., 10',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Daily Rate & Warehouse Bay
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('DAILY RATE (₹) *'),
                        TextFormField(
                          controller: _rateController,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            final parsed = double.tryParse(val ?? '');
                            if (parsed == null || parsed <= 0) {
                              return 'Enter rate';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'e.g., 1200',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('BAY / LOCATION'),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: 'Bay A-03',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              _buildFieldLabel('DESCRIPTION'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Technical specifications, power requirements, flight case info...',
                ),
              ),
              const SizedBox(height: 20),

              RentFlowButton(
                label: 'Save Equipment Asset',
                icon: Icons.add_circle_outline_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.monoLabel.copyWith(
          fontSize: 11,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
