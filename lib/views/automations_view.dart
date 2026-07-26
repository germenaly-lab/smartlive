import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/smart_home_controller.dart';
import '../models/automation_model.dart';

class AutomationsView extends StatelessWidget {
  final SmartHomeController controller;

  const AutomationsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final tr = controller.tr;
    final routines = controller.presetRoutines;
    final customs = controller.customAutomations;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Create Custom Automation Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('automations_routines'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showCreateAutomationDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  tr('create_automation'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Section 1: Preset Daily Routines (1-Tap) ---
          Text(
            tr('daily_routines'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _buildRoutineCard(context, routine);
            },
          ),

          const SizedBox(height: 28),

          // --- Section 2: Scheduled & Smart Sensor Automations ---
          Text(
            tr('scheduled_automations'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customs.length,
            itemBuilder: (context, index) {
              final auto = customs[index];
              return _buildAutomationTile(context, auto);
            },
          ),
        ],
      ),
    );
  }

  // --- Routine Card Widget ---
  Widget _buildRoutineCard(BuildContext context, SmartAutomationModel routine) {
    final isAr = controller.isArabic;
    final title = isAr ? routine.titleAr : routine.titleEn;
    final desc = isAr ? routine.descAr : routine.descEn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: routine.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: routine.accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(routine.icon, color: routine.accentColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Text(
                  routine.triggerTime,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: routine.accentColor.withValues(alpha: 0.2),
                foregroundColor: routine.accentColor,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                controller.executeAutomation(routine.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${controller.tr('routine_executed')}: "$title"'),
                    backgroundColor: routine.accentColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                controller.tr('run_routine'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Automation Tile Widget ---
  Widget _buildAutomationTile(BuildContext context, SmartAutomationModel auto) {
    final isAr = controller.isArabic;
    final title = isAr ? auto.titleAr : auto.titleEn;
    final desc = isAr ? auto.descAr : auto.descEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: auto.isActive ? auto.accentColor.withValues(alpha: 0.4) : AppTheme.borderDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: auto.isActive ? auto.accentColor.withValues(alpha: 0.15) : AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              auto.icon,
              color: auto.isActive ? auto.accentColor : AppTheme.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        auto.triggerTime,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: auto.accentColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: auto.isActive,
            activeThumbColor: auto.accentColor,
            onChanged: (_) => controller.toggleAutomationActive(auto.id),
          ),
        ],
      ),
    );
  }

  // --- Create Custom Automation Dialog ---
  void _showCreateAutomationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '08:00 AM');
    final tr = controller.tr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('create_automation'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: tr('automation_name'),
                  prefixIcon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: timeController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: tr('trigger_time'),
                  prefixIcon: const Icon(Icons.access_time_rounded, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final name = titleController.text.trim();
                    if (name.isNotEmpty) {
                      final newAuto = SmartAutomationModel(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        titleEn: name,
                        titleAr: name,
                        descEn: 'Custom rule scheduled for ${timeController.text}',
                        descAr: 'أتمتة مخصصة مجدولة في ${timeController.text}',
                        icon: Icons.schedule_rounded,
                        accentColor: AppTheme.accentGreen,
                        triggerType: TriggerType.schedule,
                        triggerTime: timeController.text,
                        isPreset: false,
                        actions: [
                          AutomationAction(deviceId: 'light_1', deviceName: 'Chandelier', setOn: true),
                        ],
                      );
                      controller.addCustomAutomation(newAuto);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    tr('save_automation'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
