import 'package:flutter/material.dart';

import '../widgets/shared/scaffolds.dart';

class DirectMessagesList extends StatelessWidget {
  const DirectMessagesList();

  static const String route = "direct_messages_list";

  @override
  Widget build(BuildContext context) {
    return HarpyScaffold(
      title: "Direct Messages",
    );
  }
}
