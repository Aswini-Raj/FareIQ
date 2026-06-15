import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fare_provider.dart';

// ─── Shared Color tokens ────────────────────────────────────────────────────
const kNavy        = Color(0xFF1E293B);
const kNavyDark    = Color(0xFF0F172A);
const kGreen       = Color(0xFF10B981);
const kGreenLight  = Color(0xFF059669);
const kGreenBg     = Color(0xFFECFDF5);
const kOrange      = Color(0xFFF97316);
const kOrangeLight = Color(0xFFFB923C);
const kOrangeBg    = Color(0xFFFFF7ED);
const kRed         = Color(0xFFEF4444);
const kRedBg       = Color(0xFFFEF2F2);
const kPageBg      = Color(0xFFF8FAFC);
const kCardBg      = Colors.white;
const kBorder      = Color(0xFFE2E8F0);
const kTextPri     = Color(0xFF0F172A);
const kTextSec     = Color(0xFF475569);
const kTextHint    = Color(0xFF94A3B8);

class AppLayout extends StatelessWidget {
  final Widget body;
  final String activeTab;
  final Widget? bottomNavigationBar;

  const AppLayout({
    super.key,
    required this.body,
    required this.activeTab,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FareProvider>();
    final isSidebarOpen = p.isSidebarOpen;

    return Scaffold(
      backgroundColor: kPageBg,
      bottomNavigationBar: bottomNavigationBar,
      body: Row(
        children: [
          // ── Left Collapsible Sidebar ──
          if (isSidebarOpen)
            _Sidebar(
              activeTab: activeTab,
              onTabChanged: (tab) {
                final route = _routeForTab(tab);
                if (route != null) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),

          // ── Main Content Area with Top Navbar ──
          Expanded(
            child: Column(
              children: [
                _TopNavBar(
                  activeTab: activeTab,
                  isSidebarOpen: isSidebarOpen,
                  onToggleSidebar: () {
                    p.toggleSidebar();
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _routeForTab(String tab) {
    switch (tab) {
      case 'Overview': return '/';
      case 'Passenger View': return '/passenger';
      case 'Driver View': return '/driver';
      case 'Regulator Dashboard': return '/regulator';
      case 'Live Demo': return '/live-demo';
      case 'Rate Card': return '/rate-card';
      case 'Audit Ledger': return '/audit';
      case 'Disputes': return '/disputes';
      case 'Reports': return '/reports';
      case 'How It Works': return '/how-it-works';
      case 'API Access': return '/api-access';
      case 'Settings': return '/settings';
      default: return null;
    }
  }
}

class _Sidebar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const _Sidebar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: kNavyDark,
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FareIQ',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Transparent rides.',
                        style: TextStyle(fontSize: 10, color: Colors.white70)),
                    Text('Trusted by all.',
                        style: TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(Icons.home_outlined, 'Overview'),
                _buildMenuItem(Icons.play_circle_outline, 'Live Demo'),
                _buildMenuItem(Icons.credit_card_outlined, 'Rate Card'),
                _buildMenuItem(Icons.receipt_long_outlined, 'Audit Ledger'),
                _buildMenuItem(Icons.gavel_rounded, 'Disputes'),
                _buildMenuItem(Icons.analytics_outlined, 'Reports'),
                _buildMenuItem(Icons.help_outline_rounded, 'How It Works'),
                _buildMenuItem(Icons.code_rounded, 'API Access'),
                _buildMenuItem(Icons.settings_outlined, 'Settings'),
                const Divider(color: Colors.white24, height: 16),
                _buildMenuItem(Icons.person_outline_rounded, 'Passenger View'),
                _buildMenuItem(Icons.directions_car_outlined, 'Driver View'),
                _buildMenuItem(Icons.analytics_outlined, 'Regulator Dashboard'),
              ],
            ),
          ),

          // Sidebar badges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSidebarBadge(Icons.shield_outlined, 'No Surge. Ever.', 'Demand multiplier\ncapped at 1.0'),
                const SizedBox(height: 8),
                _buildSidebarBadge(Icons.lock_outline, '100% Transparent', 'Every rupee.\nEvery reason.'),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/auto.png',
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: Colors.white.withOpacity(0.04),
                      child: const Center(
                        child: Icon(Icons.electric_rickshaw,
                            color: Colors.white30, size: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    final isActive = title == activeTab;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent, // Fixes the ListTile/ColoredBox assertion issue
        child: ListTile(
          onTap: () => onTabChanged(title),
          leading: Icon(icon, color: isActive ? Colors.white : kTextHint, size: 20),
          title: Text(title,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
          selected: isActive,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          selectedTileColor: kGreen,
          dense: true,
        ),
      ),
    );
  }

  Widget _buildSidebarBadge(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 8, color: Colors.white60, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final String activeTab;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;

  const _TopNavBar({
    required this.activeTab,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: kCardBg,
        border: Border(bottom: BorderSide(color: kBorder, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Three dots menu button to toggle sidebar
          IconButton(
            icon: const Icon(Icons.more_vert, color: kTextSec),
            onPressed: onToggleSidebar,
            tooltip: isSidebarOpen ? 'Hide Sidebar' : 'Show Sidebar',
          ),
          const SizedBox(width: 8),
          Text(
            activeTab.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: kTextPri,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kGreenBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 12, color: kGreenLight),
                const SizedBox(width: 6),
                const Text('FareIQ Protocol Secure', style: TextStyle(fontSize: 10, color: kGreenLight, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: kRed),
            tooltip: 'Log Out',
            onPressed: () {
              context.read<FareProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
