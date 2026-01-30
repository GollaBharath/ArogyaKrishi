import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';

/// Reusable modern crop card widget following Material 3 principles
/// Provides clean, minimal aesthetics with premium image presentation
class ModernCropCard extends StatelessWidget {
  final Crop crop;
  final String cropNameTranslated;
  final String cropDescription;
  final bool isSelected;
  final VoidCallback onTap;

  // Design tokens
  static const double _borderRadius = 20.0;
  static const double _labelPadding = 16.0;

  const ModernCropCard({
    super.key,
    required this.crop,
    required this.cropNameTranslated,
    required this.cropDescription,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.25)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 16 : 12,
            offset: const Offset(0, 4),
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        elevation: 0,
        child: InkWell(
          onTap: () {
            onTap();
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(_borderRadius),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium image section with cover fit
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      topRight: Radius.circular(_borderRadius),
                    ),
                    color: Colors.grey[50],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(_borderRadius),
                      topRight: Radius.circular(_borderRadius),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Crop image
                        ImageAssetService.buildCropImage(
                          cropId: crop.id,
                          cropName: cropNameTranslated,
                          size: 150,
                        ),

                        // Selection checkmark indicator
                        if (isSelected)
                          Container(
                            color: Colors.black.withOpacity(0.05),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Clean label section
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _labelPadding - 2,
                  horizontal: _labelPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Crop name
                    Text(
                      cropNameTranslated,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                        letterSpacing: 0.1,
                      ),
                    ),

                    // Description/category
                    if (cropDescription.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          cropDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
