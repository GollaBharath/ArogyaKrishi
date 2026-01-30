import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';

/// Modern crop showcase widget - image-first, minimal design
/// Can be used standalone or in carousel
class ModernCropShowcase extends StatelessWidget {
  final Crop crop;
  final String cropName;
  final String cropDescription;
  final VoidCallback onSelect;
  final bool isActive; // Highlight if viewing this crop

  // Design tokens
  static const double _imageBorderRadius = 24.0;
  static const double _contentPadding = 24.0;
  static const double _spaceBetweenSections = 32.0;
  static const double _buttonHeight = 52.0;

  const ModernCropShowcase({
    super.key,
    required this.crop,
    required this.cropName,
    required this.cropDescription,
    required this.onSelect,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FULL-BLEED IMAGE (top of card, zero padding, soft corners)
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(_imageBorderRadius),
            bottomRight: Radius.circular(_imageBorderRadius),
          ),
          child: Container(
            height: 280,
            color: Colors.grey[100],
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image fills entire space, no padding
                ImageAssetService.buildCropImage(
                  cropId: crop.id,
                  cropName: cropName,
                  size: 400,
                ),

                // Subtle gradient overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),

                // Active indicator (checkmark if viewing)
                if (isActive)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // TEXT CONTENT (below image, generous padding)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large crop name (display-level size)
              Text(
                cropName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Descriptive text (light, readable)
              Text(
                cropDescription,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: _spaceBetweenSections),

              // Full-width CTA button
              SizedBox(
                width: double.infinity,
                height: _buttonHeight,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onSelect();
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Select This Crop',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
