import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Industrial Barcode & Flight Case Scanner Modal (Resolves GLITCH-09).
///
/// Provides a high-contrast industrial viewfinder, manual SKU intake input,
/// and instant simulated barcode scanner chips for warehouse mobile operations.
class EquipmentScanDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String>? targetSkus;
  final ValueChanged<String>? onScanned;

  const EquipmentScanDialog({
    super.key,
    this.title = 'EQUIPMENT SCANNER',
    this.subtitle = 'Align barcode or flight case QR within viewfinder',
    this.targetSkus,
    this.onScanned,
  });

  static Future<String?> show(
    BuildContext context, {
    String title = 'EQUIPMENT SCANNER',
    String subtitle = 'Align barcode or flight case QR within viewfinder',
    List<String>? targetSkus,
    ValueChanged<String>? onScanned,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => EquipmentScanDialog(
        title: title,
        subtitle: subtitle,
        targetSkus: targetSkus,
        onScanned: onScanned,
      ),
    );
  }

  @override
  State<EquipmentScanDialog> createState() => _EquipmentScanDialogState();
}

class _EquipmentScanDialogState extends State<EquipmentScanDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _skuController = TextEditingController();
  late AnimationController _animController;
  String? _scanFeedback;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _skuController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _processCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return;

    final isTarget = widget.targetSkus == null ||
        widget.targetSkus!.isEmpty ||
        widget.targetSkus!.any((s) => s.toUpperCase() == code);

    setState(() {
      if (isTarget) {
        _isSuccess = true;
        _scanFeedback = 'VERIFIED: $code scanned successfully';
      } else {
        _isSuccess = false;
        _scanFeedback = 'WARNING: $code not matched to active manifest';
      }
    });

    widget.onScanned?.call(code);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.of(context).pop(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.inkBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.burntCopper.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.burntCopper,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.brandTitle.copyWith(
                            color: AppColors.bone,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.monoLabel.copyWith(
                            color: AppColors.slate,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.slate, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Viewfinder Target Frame
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF14171B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softStone.withValues(alpha: 0.3)),
              ),
              child: Stack(
                children: [
                  // Corner Reticles
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.burntCopper, width: 3),
                          left: BorderSide(color: AppColors.burntCopper, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.burntCopper, width: 3),
                          right: BorderSide(color: AppColors.burntCopper, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.burntCopper, width: 3),
                          left: BorderSide(color: AppColors.burntCopper, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.burntCopper, width: 3),
                          right: BorderSide(color: AppColors.burntCopper, width: 3),
                        ),
                      ),
                    ),
                  ),

                  // Animated Laser Scanning Line
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: 24 + (_animController.value * 140),
                        left: 24,
                        right: 24,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.burntCopper,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.burntCopper.withValues(alpha: 0.8),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Center Optical Focus Emblem
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.bone.withValues(alpha: 0.25),
                          size: 38,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'OPTICAL SENSOR ACTIVE',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 9,
                            color: AppColors.slate,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scan Feedback Banner
            if (_scanFeedback != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _isSuccess ? AppColors.success : AppColors.warning,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: _isSuccess ? AppColors.success : AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _scanFeedback!,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 10,
                          color: _isSuccess ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Manual Barcode / SKU Input Row
            Text(
              'MANUAL BARCODE / SKU INTAKE',
              style: AppTextStyles.monoLabel.copyWith(
                color: AppColors.slate,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skuController,
                    textCapitalization: TextCapitalization.characters,
                    style: AppTextStyles.monoData.copyWith(color: AppColors.bone, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. LT-PNT-700 or FC-L-04',
                      hintStyle: AppTextStyles.monoData.copyWith(color: AppColors.slate, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF14171B),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.softStone.withValues(alpha: 0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.softStone.withValues(alpha: 0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.burntCopper, width: 1.5),
                      ),
                    ),
                    onSubmitted: _processCode,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _processCode(_skuController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.burntCopper,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('INTAKE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quick Simulated Barcodes / Flight Cases (for rapid mobile crew testing)
            Text(
              'QUICK SIMULATED BARCODES',
              style: AppTextStyles.monoLabel.copyWith(
                color: AppColors.slate,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (widget.targetSkus != null && widget.targetSkus!.isNotEmpty
                      ? widget.targetSkus!
                      : const ['LT-PNT-700', 'AU-K2-LARR', 'VD-PL25-LED', 'CT-MQ500M', 'FC-L-04', 'FC-A-12'])
                  .map((sku) {
                return ActionChip(
                  label: Text(sku, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  backgroundColor: const Color(0xFF1F242A),
                  labelStyle: const TextStyle(color: AppColors.bone),
                  side: BorderSide(color: AppColors.burntCopper.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  onPressed: () => _processCode(sku),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
