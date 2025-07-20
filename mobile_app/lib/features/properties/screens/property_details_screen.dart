import 'package:flutter/material.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;
  
  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: Center(
        child: Text('Property Details Screen - Property ID: $propertyId'),
      ),
    );
  }
}
