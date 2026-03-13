import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

/// A reusable avatar widget that handles:
/// - SVG user images from Frappe/ERPNext
/// - Raster images (PNG, JPG, etc.)
/// - Double-slash URL fix (baseUrl ending with / + path starting with /)
/// - Fallback to initials or a generic icon
class UserAvatar extends StatelessWidget {
  final String? userImage;
  final String? baseUrl;
  final double radius;
  final String? firstName;
  final String? lastName;

  const UserAvatar({
    super.key,
    this.userImage,
    this.baseUrl,
    this.radius = 24,
    this.firstName,
    this.lastName,
  });

  String? get _fullImageUrl {
    if (userImage == null || userImage!.isEmpty) return null;
    if (userImage!.startsWith('http')) return userImage;
    if (baseUrl == null || baseUrl!.isEmpty) return null;

    // Fix double slash: if baseUrl ends with / and userImage starts with /
    final base = baseUrl!.endsWith('/') ? baseUrl!.substring(0, baseUrl!.length - 1) : baseUrl!;
    return '$base$userImage';
  }

  bool get _isSvg {
    final url = _fullImageUrl;
    if (url == null) return false;
    final path = Uri.tryParse(url)?.path ?? url;
    return path.toLowerCase().endsWith('.svg');
  }

  String get _initials {
    final f = (firstName ?? '').isNotEmpty ? firstName![0] : '';
    final l = (lastName ?? '').isNotEmpty ? lastName![0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = _fullImageUrl;

    if (url != null && _isSvg) {
      // SVG image — render with flutter_svg inside a CircleAvatar
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: ClipOval(
          child: SvgPicture.network(
            url,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => _buildFallback(),
          ),
        ),
      );
    }

    if (url != null) {
      // Raster image
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // No image — show initials or icon
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryColor,
      child: _buildFallback(),
    );
  }

  Widget _buildFallback() {
    if (_initials.isNotEmpty) {
      return Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      );
    }
    return Icon(Icons.person, color: Colors.white, size: radius);
  }
}
