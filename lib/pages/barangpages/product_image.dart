import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String qrCodeUrl;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 🟢  Product Image URL: $imageUrl');
    debugPrint('🔳 QR Code URL: $qrCodeUrl');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        _buildNetworkImage(imageUrl, Icons.image_not_supported_outlined),
        const SizedBox(height: 8),
        // QR Code Image
        _buildNetworkImage(qrCodeUrl, Icons.qr_code_2_outlined, isQrCode: true),
      ],
    );
  }

  Widget _buildNetworkImage(String url, IconData errorIcon,
      {bool isQrCode = false}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                errorIcon,
                color: isQrCode ? Colors.black : Colors.grey.shade400,
                size: isQrCode ? 55 : 32,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      ),
    );
  }
}
