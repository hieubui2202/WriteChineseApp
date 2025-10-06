import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/progress_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final homeController = Get.put(HomeController(progressController));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hanzi Journey',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: Obx(
        () {
          if (progressController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final units = homeController.units;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildStatsBanner(progressController),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.review),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Ôn tập flashcards'),
              ),
              const SizedBox(height: 24),
              Text(
                'Lộ trình của bạn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final unit in units) ...[
                _UnitCard(
                  unitId: unit.id,
                  homeController: homeController,
                  onPractice: () {
                    final character = homeController.nextCharacterForUnit(unit);
                    if (character == null) {
                      Get.snackbar('Chưa có dữ liệu', 'Hãy import chữ Hán vào Firestore nhé!');
                      return;
                    }
                    Get.toNamed(
                      AppRoutes.lesson,
                      arguments: {
                        'unit': unit,
                        'character': character,
                      },
                    );
                  },
                ),
                const SizedBox(height: 18),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsBanner(ProgressController controller) {
    final progress = controller.current;
    final xp = progress?.xp ?? 0;
    final streak = progress?.streakDays ?? 0;
    final totalMastered = progress?.progress.values
            .expand((unit) => unit.values)
            .where((entry) => entry.completed && entry.score >= 60)
            .length ??
        0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F27),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CFFF).withOpacity(0.2),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Lottie.asset('assets/lottie/success.json', repeat: true),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔥 Chuỗi ngày: $streak', style: const TextStyle(fontSize: 16, color: Colors.orangeAccent)),
                const SizedBox(height: 4),
                Text('💎 XP: $xp', style: const TextStyle(fontSize: 16, color: Color(0xFF00CFFF))),
                const SizedBox(height: 4),
                Text('🈶️ Đã thành thạo: $totalMastered chữ', style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unitId,
    required this.homeController,
    required this.onPractice,
  });

  final String unitId;
  final HomeController homeController;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final unit = homeController.findUnit(unitId);
    if (unit == null) {
      return const SizedBox.shrink();
    }
    final progressController = homeController.progressController;
    final masteredCount = unit.characterIds
        .where((id) => progressController.isMastered(unit.id, id))
        .length;
    final progressPercent = unit.characterIds.isEmpty
        ? 0.0
        : masteredCount / unit.characterIds.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161923),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(unit.color).withOpacity(0.7), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(unit.color).withOpacity(0.2),
                child: Text(unit.title.characters.first),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(unit.description, style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.white12,
            color: Color(unit.color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              for (final id in unit.characterIds)
                Chip(
                  label: Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: progressController.isMastered(unit.id, id)
                      ? const Color(0xFF00CFFF).withOpacity(0.2)
                      : Colors.white12,
                ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Practice',
            onPressed: onPractice,
          ),
        ],
      ),
    );
  }
}
