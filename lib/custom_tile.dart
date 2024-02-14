import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final Function() onTap;
  const CustomTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.primaryContainer,
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
      title: Text(title),
      onTap: onTap,
    );
  }
}
