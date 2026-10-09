import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Equipment Inventory Screen (Industrial Atelier UI/UX).
///
/// Features:
/// - Editorial operational header with fleet metrics & stage lighting accents.
/// - Tactical metric cards (Total Units, On Stage, In Warehouse, Maintenance).
/// - Industrial category filter chips.
/// - Search & status filters.
/// - Flight-case style equipment asset cards with SKUs, rack locations,
///   allocation progress tracks, and operational specifications.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';
  String _selectedStatusFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Lighting',
    'Audio',
    'Video & LED',
    'Rigging',
    'Power & Control',
  ];

  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'sku': 'LT-PNT-700',
      'name': 'Robe Robin Pointe Moving Beam',
      'category': 'Lighting',
      'flightCase': 'FC-L-04',
      'rackBay': 'BAY-02-B',
      'total': 24,
      'available': 8,
      'deployed': 16,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '280W Lamp • 0°–20° Zoom • DMX 24ch',
      'progressRatio': 0.67,
    },
    {
      'sku': 'AU-K2-LARR',
      'name': 'L-Acoustics K2 Line Array Module',
      'category': 'Audio',
      'flightCase': 'FC-A-12',
      'rackBay': 'RIG-01-A',
      'total': 16,
      'available': 12,
      'deployed': 4,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': 'Dual 12" Neodymium • Panflex 70/110° • 147 dB',
      'progressRatio': 0.25,
    },
    {
      'sku': 'VD-PL25-LED',
      'name': 'Absen PL2.5 Pro Outdoor LED Panel',
      'category': 'Video & LED',
      'flightCase': 'FC-V-08',
      'rackBay': 'BAY-06-C',
      'total': 48,
      'available': 48,
      'deployed': 0,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': '2.5mm Pitch • 4500 nits • IP65 Weatherproof',
      'progressRatio': 0.0,
    },
    {
      'sku': 'CT-MQ500M',
      'name': 'Chamsys MagicQ MQ500M Stadium Console',
      'category': 'Power & Control',
      'flightCase': 'FC-C-01',
      'rackBay': 'CTRL-ROOM-1',
      'total': 2,
      'available': 0,
      'deployed': 2,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '256 Universes • 4 Motorized Fader Banks • Dual Touch',
      'progressRatio': 1.0,
    },
    {
      'sku': 'TR-H30V-3M',
      'name': 'Prolyte H30V Heavy Duty Truss 3M',
      'category': 'Rigging',
      'flightCase': 'TR-BDL-08',
      'rackBay': 'YARD-DOCK-2',
      'total': 32,
      'available': 18,
      'deployed': 14,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': '4-Point Box Truss • CCS6 Conical Coupler • 6082T6 Alloy',
      'progressRatio': 0.44,
    },
    {
      'sku': 'AU-PWR-X8',
      'name': 'Powersoft X8 Touring 8-Ch Amplifier',
      'category': 'Audio',
      'flightCase': 'AMP-RK-03',
      'rackBay': 'MAINT-BENCH-1',
      'total': 6,
      'available': 2,
      'deployed': 3,
      'status': 'MAINTENANCE',
      'statusColor': AppColors.warning,
      'statusBg': AppColors.warningSubtle,
      'specs': '8x 5200W @ 2Ω • Dante Networking • Advanced DSP',
      'progressRatio': 0.50,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _inventoryItems.where((item) {
      // Category filter
      if (_selectedCategory != 'All' &&
          item['category'] != _selectedCategory) {
        return false;
      }
      // Status filter
      if (_selectedStatusFilter != 'All') {
        if (_selectedStatusFilter == 'Available' && item['status'] != 'IN WAREHOUSE') {
          return false;
        }
        if (_selectedStatusFilter == 'Deployed' && item['status'] != 'DEPLOYED') {
          return false;
        }
        if (_selectedStatusFilter == 'Maintenance' && item['status'] != 'MAINTENANCE') {
          return false;
        }
      }
      // Search query filter
      if (query.isNotEmpty) {
        final name = (item['name'] as String).toLowerCase();
        final sku = (item['sku'] as String).toLowerCase();
        final rack = (item['rackBay'] as String).toLowerCase();
        final flightCase = (item['flightCase'] as String).toLowerCase();
        if (!name.contains(query) &&
            !sku.contains(query) &&
            !rack.contains(query) &&
            !flightCase.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.bone,
      body: SafeArea(
        child: Column(
          children: [
            // Atmospheric Top Header
            _buildAtmosphericHeader(context),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                  vertical: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Operational Metrics Strip (4 cards)
                    _buildMetricsGrid(),
                    const SizedBox(height: 20),

                    // Search & Quick Filter Bar
                    _buildSearchBar(),
                    const SizedBox(height: 14),

                    // Category Chips Horizontal Selector
                    _buildCategoryChips(),
                    const SizedBox(height: 18),

                    // Section Heading & Item Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 16,
                              color: AppColors.burntCopper,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EQUIPMENT ROSTER',
                              style: AppTextStyles.brandTitle.copyWith(
                                fontSize: 16,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${filtered.length} of ${_inventoryItems.length} ITEMS',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 10,
                            color: AppColors.slate,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Item Cards List
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...filtered.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildEquipmentCard(item),
                          )),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  /// Atmospheric Event Production Header (Ink Black + Burnt Copper & Brass Glow)
  Widget _buildAtmosphericHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.inkBlack,
        gradient: RadialGradient(
          center: Alignment(0.9, -0.6),
          radius: 1.3,
          colors: [
            Color(0x2BB86A45),
            Color(0x15C59A5A),
            AppColors.inkBlack,
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                    width: 0.8,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.bone,
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back to Dashboard',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INVENTORY FLEET',
                    style: AppTextStyles.brandTitle.copyWith(
                      fontSize: 17,
                      letterSpacing: 1.5,
                      color: AppColors.bone,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.burntCopper,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '148 ASSETS • WAREHOUSE & LIVE RIGS',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 9.5,
                          color: AppColors.agedBrass,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Header Quick Actions
          Row(
            children: [
              _buildHeaderIconAction(
                icon: Icons.qr_code_scanner_rounded,
                tooltip: 'Scan Flight Case',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barcode & RFID scanner initialized.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildHeaderIconAction(
                icon: Icons.tune_rounded,
                tooltip: 'Filter Options',
                onTap: () {
                  _showFilterBottomSheet(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1AFAF7F0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0x33FAF7F0),
          width: 0.8,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.bone, size: 18),
        onPressed: onTap,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// 4 High-Impact Operational Fleet Metric Cards
  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            label: 'TOTAL ASSETS',
            value: '148',
            subtext: 'Fleet count',
            icon: Icons.inventory_2_outlined,
            isDark: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            label: 'ON STAGE',
            value: '94',
            subtext: 'Live deployed',
            icon: Icons.stadium_outlined,
            highlightColor: AppColors.burntCopper,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            label: 'AVAILABLE',
            value: '46',
            subtext: 'In warehouse',
            icon: Icons.warehouse_outlined,
            highlightColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            label: 'SERVICE',
            value: '08',
            subtext: 'Bench check',
            icon: Icons.build_circle_outlined,
            highlightColor: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    Color? highlightColor,
    bool isDark = false,
  }) {
    final bg = isDark ? AppColors.inkBlack : AppColors.paper;
    final fg = isDark ? AppColors.paper : (highlightColor ?? AppColors.inkBlack);
    final border = isDark
        ? const Color(0x4DB86A45)
        : AppColors.softStone;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 8.5,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.agedBrass : AppColors.slate,
                ),
              ),
              Icon(
                icon,
                size: 13,
                color: isDark ? AppColors.burntCopper : AppColors.slate,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.monoMetric.copyWith(
              fontSize: 20,
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 9.5,
              color: isDark ? AppColors.softStone : AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  /// Tactical Search Bar with Clear Button
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.burntCopper,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.inkBlack,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search SKU, equipment name, rack bay...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.slate.withAlpha(160),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.slate),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  /// Category Filter Chips (Industrial Atelier Pill Style)
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() => _selectedCategory = category);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.inkBlack : AppColors.paper,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.burntCopper : AppColors.softStone,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.paper : AppColors.inkBlack,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Individual Industrial Equipment Card
  Widget _buildEquipmentCard(Map<String, dynamic> item) {
    final String sku = item['sku'];
    final String name = item['name'];
    final String category = item['category'];
    final String flightCase = item['flightCase'];
    final String rackBay = item['rackBay'];
    final int total = item['total'];
    final int available = item['available'];
    final int deployed = item['deployed'];
    final String status = item['status'];
    final Color statusColor = item['statusColor'];
    final Color statusBg = item['statusBg'];
    final String specs = item['specs'];
    final double progressRatio = item['progressRatio'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: SKU Badge + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tactical SKU Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bone,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.softStone, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 11,
                      color: AppColors.burntCopper,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sku,
                      style: AppTextStyles.monoData.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: statusColor.withAlpha(120),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 9.5,
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Equipment Title
          Text(
            name,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 4),

          // Operational Technical Specs
          Text(
            specs,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.slate,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Allocation & Quantities Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Available: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                  Text(
                    '$available / $total units',
                    style: AppTextStyles.monoData.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Deployed: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.slate,
                    ),
                  ),
                  Text(
                    '$deployed units',
                    style: AppTextStyles.monoData.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.burntCopper,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Progress Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 3,
              backgroundColor: AppColors.softStone.withAlpha(120),
              valueColor: AlwaysStoppedAnimation<Color>(
                status == 'MAINTENANCE' ? AppColors.warning : AppColors.burntCopper,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Metadata Row: Category Tag • Location Tag • Flight Case
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTagPill(
                    icon: Icons.category_outlined,
                    label: category,
                  ),
                  const SizedBox(width: 6),
                  _buildTagPill(
                    icon: Icons.location_on_outlined,
                    label: rackBay,
                  ),
                ],
              ),
              _buildTagPill(
                icon: Icons.cases_outlined,
                label: flightCase,
                isSubtle: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill({
    required IconData icon,
    required String label,
    bool isSubtle = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.bone,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSubtle ? AppColors.softStone.withAlpha(150) : AppColors.softStone,
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.5,
            color: AppColors.slate,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 9,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State for searches
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.inventory_outlined,
            size: 40,
            color: AppColors.softStone,
          ),
          const SizedBox(height: 12),
          Text(
            'No Equipment Found',
            style: AppTextStyles.brandTitle.copyWith(
              fontSize: 16,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try altering your search keywords or resetting filters.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Sticky Action Dock
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inkBlack,
        border: Border(
          top: BorderSide(color: Color(0xFF232B29), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Fast Scan Flight Case Button
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera barcode scanner launched.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bone,
                    side: const BorderSide(color: Color(0x33FAF7F0), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'SCAN',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.bone,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Primary Action: Log / Audit Equipment
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New Asset Intake dialog opened.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.burntCopper,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'ADD EQUIPMENT',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom Modal for quick filters
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FILTER BY STATUS',
                style: AppTextStyles.brandTitle.copyWith(
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Available', 'Deployed', 'Maintenance'].map((st) {
                  final isSel = _selectedStatusFilter == st;
                  return ChoiceChip(
                    label: Text(st),
                    selected: isSel,
                    selectedColor: AppColors.inkBlack,
                    backgroundColor: AppColors.bone,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSel ? AppColors.paper : AppColors.inkBlack,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedStatusFilter = st);
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
