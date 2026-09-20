import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  // Curated category icons for selection
  static const List<IconOption> availableIcons = [
    IconOption(Icons.fastfood_rounded, 'Food', '🍔'),
    IconOption(Icons.directions_car_rounded, 'Transport', '🚕'),
    IconOption(Icons.shopping_bag_rounded, 'Shopping', '🛒'),
    IconOption(Icons.receipt_long_rounded, 'Bills', '💡'),
    IconOption(Icons.home_rounded, 'Rent', '🏠'),
    IconOption(Icons.medical_services_rounded, 'Health', '💊'),
    IconOption(Icons.school_rounded, 'Education', '🎓'),
    IconOption(Icons.movie_creation_rounded, 'Entertainment', '🎬'),
    IconOption(Icons.flight_rounded, 'Travel', '✈️'),
    IconOption(Icons.people_rounded, 'Family', '👨‍👩‍👧'),
    IconOption(Icons.work_rounded, 'Salary', '💼'),
    IconOption(Icons.laptop_mac_rounded, 'Freelance', '💻'),
    IconOption(Icons.storefront_rounded, 'Business', '🏬'),
    IconOption(Icons.card_giftcard_rounded, 'Gift', '🎁'),
    IconOption(Icons.military_tech_rounded, 'Bonus', '🌟'),
    IconOption(Icons.fitness_center_rounded, 'Gym/Sports', '🏋️'),
    IconOption(Icons.pets_rounded, 'Pets', '🐾'),
    IconOption(Icons.coffee_rounded, 'Cafe', '☕'),
    IconOption(Icons.local_gas_station_rounded, 'Fuel', '⛽'),
    IconOption(Icons.savings_rounded, 'Savings', '💰'),
    IconOption(Icons.interests_rounded, 'Other', '📦'),
  ];

  static IconData getIconData(int codePoint) {
    for (final option in availableIcons) {
      if (option.icon.codePoint == codePoint) {
        return option.icon;
      }
    }
    // ignore: non_const_argument_for_const_parameter
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static String getEmojiForCodePoint(int codePoint) {
    for (final option in availableIcons) {
      if (option.icon.codePoint == codePoint) {
        return option.emoji;
      }
    }
    return '💳';
  }
}

class IconOption {
  final IconData icon;
  final String label;
  final String emoji;

  const IconOption(this.icon, this.label, this.emoji);
}
