import 'package:flutter/material.dart';

class BothServicesPage extends StatelessWidget {
  const BothServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Both Services")),
      body: const Center(
          child: Text("This page is for users who selected BOTH options.")),
    );
  }
}
