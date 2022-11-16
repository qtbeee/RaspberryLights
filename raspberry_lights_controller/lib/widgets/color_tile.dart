import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raspberry_lights_controller/utils/color.dart';

class ColorTile extends ConsumerWidget {
  const ColorTile({
    Key? key,
    required this.color,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 8),
          title: Row(
            children: [
              SizedBox(
                width: 76,
                child: Text(
                  color.toHexString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        offset: Offset(3, 3),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete,
                )
              else
                const SizedBox(width: 16),
            ],
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}
