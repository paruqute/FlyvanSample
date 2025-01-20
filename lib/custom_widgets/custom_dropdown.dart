import 'package:flutter/material.dart';

import '../utils/colors.dart';
class CustomDropDown extends StatelessWidget {
  const CustomDropDown({super.key, this.items, this.onChanged, this.value});

  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
            color: primaryColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
          alignment: Alignment.center,
          value: value,
          hint: Text(
            "Select",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: primaryColor.withOpacity(0.3)),
          ),
          underline: SizedBox.shrink(),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down_outlined,size: 25,),
          iconDisabledColor: primaryColor.withOpacity(0.3),
          iconEnabledColor: primaryColor.withOpacity(0.8),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: primaryColor),
          items: items,
          onChanged: onChanged),
    );
  }
}
