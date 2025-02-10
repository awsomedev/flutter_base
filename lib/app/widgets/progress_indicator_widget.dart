import 'package:flutter/material.dart';
import 'package:madeira/app/app_essentials/colors.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double height;
  final double spacing;

  const ProgressIndicatorWidget({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
    this.height = 4.0,
    this.spacing = 4.0,
  })  : assert(currentStep >= 0 && currentStep <= totalSteps),
        assert(totalSteps > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$currentStep% completed'),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final isActive = index < currentStep;
                return Expanded(
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
