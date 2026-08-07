import 'package:flutter/material.dart';

abstract final class CategoryIcon {
  CategoryIcon._();

  static IconData fromKey(String iconKey) {
    return switch (iconKey.trim().toLowerCase()) {
      'salary' => Icons.work_outline_rounded,
      'freelance' => Icons.laptop_mac_rounded,
      'gift' => Icons.card_giftcard_rounded,
      'food' => Icons.restaurant_rounded,
      'transportation' => Icons.directions_car_filled_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'bills' => Icons.receipt_long_outlined,
      'health' => Icons.favorite_border_rounded,
      'education' => Icons.school_outlined,
      'entertainment' => Icons.movie_outlined,
      'other' => Icons.more_horiz_rounded,
      _ => Icons.category_outlined,
    };
  }
}
