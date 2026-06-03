import 'package:flutter/material.dart';

/// Single row inside a BaseContextMenu: title, optional leading icon,
/// destructive flag, selected-state (checkmark), and an optional divider after.
class ContextMenuModel {
  final String title;
  final TextStyle? titleStyle;

  /// Material icon. Pass null for a text-only row.
  final IconData? icon;

  final VoidCallback? onTap;

  /// Renders title + icon in the destructive (error) colour.
  final bool isDestructive;

  /// Marks the row as the active selection — trailing check mark + accent tint.
  final bool isSelected;

  /// When true, a thin divider is drawn after the row.
  final bool showDividerAfter;

  ContextMenuModel({
    required this.title,
    this.titleStyle,
    this.icon,
    this.onTap,
    this.isDestructive = false,
    this.isSelected = false,
    this.showDividerAfter = false,
  });
}
