import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/modules/auth/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/progress_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final controller = Get.put(ProfileController(progressController));
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Thành tích'),
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        final progress = progressController.current;
        if (progress == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF00CFFF).withOpacity(0.2),
              child: Text(
                progress.displayName.isNotEmpty ? progress.displayName.characters.first : '👤',
                style: const TextStyle(fontSize: 32, color: Color(0xFF00CFFF)),
              ),
            ),
            const SizedBox(height: 16),
            Text(progress.displayName.isEmpty ? 'Khách' : progress.displayName,
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(progress.email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 24),
            _StatTile(label: '🔥 Chuỗi ngày', value: '${progress.streakDays}'),
            _StatTile(label: '💎 Điểm XP', value: '${progress.xp}'),
            _StatTile(
              label: '🈶️ Tổng chữ đã học',
              value: '${progress.progress.values.fold<int>(0, (sum, unit) => sum + unit.length)}',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.syncNow,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Đồng bộ ngay với Firebase'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: authController.signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
          ],
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161923),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00CFFF).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
