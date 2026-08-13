import 'package:flutter/material.dart';
import 'package:get/get.dart';

@immutable
class TaskCategory {
  final String nameKey;
  final IconData icon;
  final Color color;
  final List<String> subCategoryKeys;

  const TaskCategory({
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.subCategoryKeys,
  });

  // Dynamic getters to fetch localized strings automatically via GetX (.tr)
  String get name => nameKey.tr;
  List<String> get subCategories => subCategoryKeys.map((key) => key.tr).toList();
}

class TaskCategoryData {
  // Comprehensive list covering worldwide service categories for clients
  static const List<TaskCategory> categories = [
    TaskCategory(
      nameKey: "category_delivery",
      icon: Icons.bolt_rounded,
      color: Color(0xff10B981), // Emerald Green
      subCategoryKeys: [
        "category_sub_small_item",
        "category_sub_grocery",
        "category_sub_heavy_freight",
        "category_sub_document",
      ],
    ),
    TaskCategory(
      nameKey: "category_handyman",
      icon: Icons.handyman_rounded,
      color: Color(0xff3B82F6), // Blue
      subCategoryKeys: [
        "category_sub_plumbing",
        "category_sub_electrical",
        "category_sub_furniture",
        "category_sub_carpentry",
        "category_sub_painting",
        "category_sub_appliance",
      ],
    ),
    TaskCategory(
      nameKey: "category_cleaning",
      icon: Icons.cleaning_services_rounded,
      color: Color(0xffF59E0B), // Amber
      subCategoryKeys: [
        "category_sub_house_clean",
        "category_sub_deep_clean",
        "category_sub_laundry",
        "category_sub_window_clean",
        "category_sub_carpet_clean",
      ],
    ),
    TaskCategory(
      nameKey: "category_moving",
      icon: Icons.home_work_rounded,
      color: Color(0xff8B5CF6), // Violet
      subCategoryKeys: [
        "category_sub_local_move",
        "category_sub_packing",
        "category_sub_heavy_lifting",
        "category_sub_office_move",
      ],
    ),
    TaskCategory(
      nameKey: "category_pet_care",
      icon: Icons.favorite_rounded,
      color: Color(0xffEC4899), // Pink
      subCategoryKeys: [
        "category_sub_pet_sitting",
        "category_sub_dog_walking",
        "category_sub_pet_grooming",
        "category_sub_pet_training",
      ],
    ),
    TaskCategory(
      nameKey: "category_tech_it",
      icon: Icons.devices_rounded,
      color: Color(0xff06B6D4), // Cyan
      subCategoryKeys: [
        "category_sub_computer_repair",
        "category_sub_smart_home",
        "category_sub_phone_repair",
        "category_sub_tv_mounting",
      ],
    ),
    TaskCategory(
      nameKey: "category_beauty_wellness",
      icon: Icons.spa_rounded,
      color: Color(0xffF43F5E), // Rose
      subCategoryKeys: [
        "category_sub_haircut_styling",
        "category_sub_makeup",
        "category_sub_massage",
        "category_sub_nail_care",
      ],
    ),
    TaskCategory(
      nameKey: "category_events_photo",
      icon: Icons.camera_alt_rounded,
      color: Color(0xff6366F1), // Indigo
      subCategoryKeys: [
        "category_sub_event_photography",
        "category_sub_catering",
        "category_sub_event_planning",
        "category_sub_dj_music",
      ],
    ),
    TaskCategory(
      nameKey: "category_automotive",
      icon: Icons.directions_car_rounded,
      color: Color(0xffD97706), // Dark Amber
      subCategoryKeys: [
        "category_sub_mobile_mechanic",
        "category_sub_car_wash",
        "category_sub_jump_start",
      ],
    ),
    TaskCategory(
      nameKey: "category_gardening",
      icon: Icons.eco_rounded,
      color: Color(0xff10B981), // Green
      subCategoryKeys: [
        "category_sub_lawn_mowing",
        "category_sub_landscaping",
        "category_sub_snow_removal",
        "category_sub_pool_maintenance",
      ],
    ),
    TaskCategory(
      nameKey: "category_lessons_tutoring",
      icon: Icons.school_rounded,
      color: Color(0xff4F46E5), // Deep Blue
      subCategoryKeys: [
        "category_sub_academic_tutoring",
        "category_sub_language_lessons",
        "category_sub_music_lessons",
        "category_sub_fitness_training",
      ],
    ),
    TaskCategory(
      nameKey: "category_business_admin",
      icon: Icons.business_center_rounded,
      color: Color(0xff64748B), // Slate Grey
      subCategoryKeys: [
        "category_sub_virtual_assistant",
        "category_sub_data_entry",
        "category_sub_translation",
        "category_sub_graphic_design",
      ],
    ),
  ];
}