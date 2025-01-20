import 'package:flutter/material.dart';


import '../utils/colors.dart';
class TableColumnName extends StatelessWidget {
  const TableColumnName({
    super.key,
    this.columnTitle
  });
  final String? columnTitle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        columnTitle??'',
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        //textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor,fontSize:12 ),
      ),
    );
  }
}


class TableRowText extends StatelessWidget {
  const TableRowText({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12));
  }
}
