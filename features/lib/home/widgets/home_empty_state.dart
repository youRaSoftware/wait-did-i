import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Shown only when the user has deleted every list (after onboarding a default
/// list always exists, so a fresh user never sees this).
class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  color.colorBrandPeach.withValues(alpha: 0.15),
                  color.colorBrandOcean.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: color.colorBrandPeach.withValues(alpha: 0.15)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.checklist_rounded, size: 44, color: color.colorBrandPeach),
          ),
          const SizedBox(height: 24),
          Text(
            LocaleKeys.home_emptyTitle.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: color.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            LocaleKeys.home_emptyText.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              height: 1.55,
              color: color.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AppTappable(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: <Color>[color.colorBrandPeach, color.colorBrandOcean]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.add, size: 14, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKeys.home_emptyCta.tr(),
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
