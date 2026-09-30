import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_draft.dart';

/// Form widget for Step 1: Event Details.
///
/// Flutter & Dart Concepts:
/// - Form validation with `GlobalKey<FormState>`.
/// - Keyboard friendly input types: `TextInputType.phone`, `TextInputType.text`.
/// - Integrated date and time pickers adhering to RentFlow design system.
/// - Segmented choice chips for event categories.
class EventDetailsForm extends StatefulWidget {
  final BookingDraft draft;
  final ValueChanged<BookingDraft> onDraftChanged;
  final GlobalKey<FormState> formKey;

  const EventDetailsForm({
    super.key,
    required this.draft,
    required this.onDraftChanged,
    required this.formKey,
  });

  @override
  State<EventDetailsForm> createState() => _EventDetailsFormState();
}

class _EventDetailsFormState extends State<EventDetailsForm> {
  late final TextEditingController _eventNameController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _venueController;
  late final TextEditingController _notesController;

  final List<String> _eventTypes = const [
    'Wedding',
    'Corporate',
    'Private',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _eventNameController =
        TextEditingController(text: widget.draft.eventName);
    _customerNameController =
        TextEditingController(text: widget.draft.customerName);
    _phoneController = TextEditingController(text: widget.draft.phoneNumber);
    _venueController = TextEditingController(text: widget.draft.venue);
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateDraft() {
    widget.onDraftChanged(
      widget.draft.copyWith(
        eventName: _eventNameController.text.trim(),
        customerName: _customerNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        venue: _venueController.text.trim(),
        notes: _notesController.text.trim(),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.draft.eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.alpineEvergreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDraftChanged(widget.draft.copyWith(eventDate: picked));
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.draft.startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.alpineEvergreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDraftChanged(widget.draft.copyWith(startTime: picked));
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.draft.endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.alpineEvergreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDraftChanged(widget.draft.copyWith(endTime: picked));
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Type Selector
          Text(
            'EVENT TYPE',
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 11,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _eventTypes.map((type) {
              final isSelected = widget.draft.eventType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: AppColors.alpineEvergreen,
                backgroundColor: AppColors.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.alpineEvergreen
                        : AppColors.structuralBorder,
                  ),
                ),
                labelStyle: AppTextStyles.badgeText.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
                onSelected: (selected) {
                  if (selected) {
                    widget.onDraftChanged(widget.draft.copyWith(eventType: type));
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Event Name Field
          _buildFieldLabel('EVENT NAME *'),
          TextFormField(
            controller: _eventNameController,
            onChanged: (_) => _updateDraft(),
            style: AppTextStyles.bodyLarge,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the event name';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'e.g., Singhania Wedding Sangeet',
              prefixIcon: Icon(
                Icons.celebration_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Customer Name & Phone in Responsive Grid/Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('CUSTOMER NAME *'),
                    TextFormField(
                      controller: _customerNameController,
                      onChanged: (_) => _updateDraft(),
                      style: AppTextStyles.bodyLarge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: 'e.g., Rajesh Sharma',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
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
                    _buildFieldLabel('PHONE NUMBER *'),
                    TextFormField(
                      controller: _phoneController,
                      onChanged: (_) => _updateDraft(),
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.bodyLarge,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (value.trim().length < 8) {
                          return 'Invalid phone';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: '+91 98290 12345',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Venue Field
          _buildFieldLabel('EVENT VENUE *'),
          TextFormField(
            controller: _venueController,
            onChanged: (_) => _updateDraft(),
            style: AppTextStyles.bodyLarge,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the venue address';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'e.g., Fairmont Palace Ballroom, Jaipur',
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Schedule: Date & Times
          _buildFieldLabel('DATE & TIME SCHEDULE'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.structuralBorder),
            ),
            child: Column(
              children: [
                // Date Selector Tile
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: AppColors.alpineEvergreen,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Event Date',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _formatDate(widget.draft.eventDate),
                              style: AppTextStyles.monoLabel.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestObsidian,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.edit_calendar_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 16, color: AppColors.borderSubtle),

                // Times Row
                Row(
                  children: [
                    // Start Time
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'START TIME',
                                style: AppTextStyles.badgeText.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 16,
                                    color: AppColors.alpineEvergreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.draft.startTime.format(context),
                                    style: AppTextStyles.monoLabel.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestObsidian,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 28,
                      width: 1,
                      color: AppColors.borderSubtle,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    // End Time
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'END TIME',
                                style: AppTextStyles.badgeText.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled_rounded,
                                    size: 16,
                                    color: AppColors.alpineEvergreen,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.draft.endTime.format(context),
                                    style: AppTextStyles.monoLabel.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestObsidian,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Operational Notes Field
          _buildFieldLabel('DISPATCH & SETUP NOTES (OPTIONAL)'),
          TextFormField(
            controller: _notesController,
            onChanged: (_) => _updateDraft(),
            maxLines: 3,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText:
                  'e.g., Gate 4 access, power generator requires 32A three-phase hookup.',
            ),
          ),
        ],
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
