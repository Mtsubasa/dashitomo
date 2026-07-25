import 'package:flutter/material.dart';

import '../../../app/app_bottom_navigation.dart';
import '../../../app/under_development_scaffold.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderDevelopmentScaffold(activeTab: AppTab.conversation);
  }
}
