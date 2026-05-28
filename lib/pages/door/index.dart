import 'package:flutter/material.dart';

class DoorPage extends StatelessWidget {
  const DoorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('第二个页面')),
      body: const Center(child: Text('我是新页面，成功进来了！')),
    );
  }
}
