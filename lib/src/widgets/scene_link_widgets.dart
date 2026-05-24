import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network URL or inline `data:` image from Firestore fallback uploads.
ImageProvider? sceneProfileImageProvider(String imageUrl) {
  if (imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('data:')) {
    final payload = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
    return MemoryImage(base64Decode(payload));
  }
  return NetworkImage(imageUrl);
}

// ── SceneCard ─────────────────────────────────────────────────────────────────

class SceneCard extends StatelessWidget {
  const SceneCard({super.key, required this.child, this.padding, this.color});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: color ?? scheme.surfaceContainerHighest.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

// ── SceneSectionHeader ────────────────────────────────────────────────────────

class SceneSectionHeader extends StatelessWidget {
  const SceneSectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

// ── ScenePillButton ───────────────────────────────────────────────────────────

class ScenePillButton extends StatelessWidget {
  const ScenePillButton({super.key, required this.label, this.onPressed, this.filled = true, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = filled ? colorScheme.primary : colorScheme.surface;
    final foreground = filled ? colorScheme.onPrimary : colorScheme.onSurface;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── SceneMetricCard ───────────────────────────────────────────────────────────

class SceneMetricCard extends StatelessWidget {
  const SceneMetricCard({super.key, required this.label, required this.value, required this.icon, required this.accentColor});

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SceneCard(
      color: accentColor.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(height: 14),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── SceneTag ──────────────────────────────────────────────────────────────────

class SceneTag extends StatelessWidget {
  const SceneTag({super.key, required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: filled ? colorScheme.primaryContainer : colorScheme.surface,
      side: BorderSide(color: colorScheme.outlineVariant),
      labelStyle: TextStyle(
        color: filled ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}

// ── SceneEmptyState ───────────────────────────────────────────────────────────

class SceneEmptyState extends StatelessWidget {
  const SceneEmptyState({super.key, required this.title, required this.message, this.icon, this.actionLabel, this.onAction});

  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SceneCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(icon ?? Icons.hourglass_empty_rounded, color: colorScheme.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ScenePillButton(label: actionLabel!, onPressed: onAction, icon: Icons.add),
          ],
        ],
      ),
    );
  }
}

// ── SceneCachedImage ──────────────────────────────────────────────────────────
/// A [CachedNetworkImage] wrapper with shimmer skeleton and error fallback.

class SceneCachedImage extends StatelessWidget {
  const SceneCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget image;

    if (url.isEmpty) {
      image = Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant, size: 28),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, placeholderUrl) => _SceneSkeleton(width: width, height: height),
        errorWidget: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// ── SceneCachedAvatar ─────────────────────────────────────────────────────────
/// Cached circular avatar with initial letter fallback.

class SceneCachedAvatar extends StatelessWidget {
  const SceneCachedAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.radius,
  });

  final String imageUrl;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }

    if (imageUrl.startsWith('data:')) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: sceneProfileImageProvider(imageUrl),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, placeholderUrl) => CircleAvatar(
        radius: radius,
        backgroundColor: scheme.surfaceContainerHighest,
        child: _SceneSkeleton(width: radius * 2, height: radius * 2, circular: true),
      ),
      errorWidget: (context, error, stackTrace) => CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          initial,
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.7,
          ),
        ),
      ),
    );
  }
}

// ── SceneSkeleton ─────────────────────────────────────────────────────────────
/// Animated shimmer skeleton placeholder.

class _SceneSkeleton extends StatefulWidget {
  const _SceneSkeleton({this.width, this.height, this.circular = false});

  final double? width;
  final double? height;
  final bool circular;

  @override
  State<_SceneSkeleton> createState() => _SceneSkeletonState();
}

class _SceneSkeletonState extends State<_SceneSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: _anim.value),
          borderRadius: widget.circular ? null : BorderRadius.circular(8),
          shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

/// Public skeleton for use in list cards while loading.
class SceneCardSkeleton extends StatelessWidget {
  const SceneCardSkeleton({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SceneCard(
      child: _SceneSkeleton(width: double.infinity, height: height),
    );
  }
}
