import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../widgets/info_card.dart';

/// The entry screen and application shell for RentFlow Day-1 scaffold.
///
/// Flutter & Dart Concepts Taught:
/// - `Scaffold`: The standard top-level container implementing Material Design
///   visual layout structure (app bar, body, drawers, snackbars, floating buttons).
/// - `ListView`: A scrollable list of widgets arranged linearly. Essential for
///   mobile apps so content remains accessible on smaller screens without overflow errors.
/// - `Chip` & `Wrap`: Responsive tags/badges that wrap automatically to the next
///   line when horizontal space runs out.
/// - Separation of Concerns: This screen uses constants from `AppConstants` and
///   reusable widgets like `InfoCard`, keeping screen code clean and maintainable.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.event_available_rounded, size: 24),
            const SizedBox(width: 10),
            Text(
              AppConstants.appName,
              style: theme.appBarTheme.titleTextStyle,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Day 1 Shell',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Branded Banner Header
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  const Color(0xFF1E40AF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  AppConstants.appTagline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 14.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildPill(AppConstants.squadNumber),
                    _buildPill(AppConstants.teamNumber),
                    _buildPill(AppConstants.campusName),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Section Title: Current Sprint Scope
          Text(
            'Current Sprint Scope',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8.0),
          const InfoCard(
            title: 'Scaffold & Architecture Foundation',
            description:
                'Clean Flutter project structure initialized with theme, constants, and Git workflow. No business logic added yet.',
            icon: Icons.check_circle_outline_rounded,
            iconColor: Color(0xFF059669),
          ),
          const InfoCard(
            title: 'Planning Documents in Progress',
            description:
                'PRD, TRD, App Flow, and Backend Schema are currently being drafted by Prateek before implementation begins.',
            icon: Icons.assignment_outlined,
            iconColor: Color(0xFFD97706),
          ),
          const SizedBox(height: 16.0),

          // Section Title: Equipment Handled
          Text(
            'Target Equipment Categories',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: AppConstants.equipmentCategories.map((category) {
              return Chip(
                avatar: const Icon(Icons.inventory_2_outlined, size: 16),
                label: Text(category),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20.0),

          // Section Title: Team Responsibilities
          Text(
            'Sprint 2 Day-1 Division of Work',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8.0),
          const InfoCard(
            title: 'Mayank Sharma',
            description:
                'Flutter project scaffolding, architectural directory layout, basic branded app shell, and Git/GitHub feature branch setup.',
            icon: Icons.code_rounded,
            iconColor: Color(0xFF2563EB),
          ),
          const InfoCard(
            title: 'Prateek',
            description:
                'PRD, Technical Requirements Document (TRD), App Flow diagram, Backend Schema, and phased Implementation Plan.',
            icon: Icons.draw_outlined,
            iconColor: Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
