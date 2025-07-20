import 'package:flutter/material.dart';

class VirtualTourScreen extends StatelessWidget {
  final String propertyId;
  
  const VirtualTourScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Tour'),
      ),
      body: Center(
        child: Text('Virtual Tour Screen - Property ID: $propertyId'),
      ),
    );
  }
}
