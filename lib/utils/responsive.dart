import 'package:flutter/widgets.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;
  const ResponsiveLayout({required this.builder, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}
