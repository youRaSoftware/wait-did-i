import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/example_cubit.dart';

class ExampleForm extends StatelessWidget {
  const ExampleForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ExampleState state = context.watch<ExampleCubit>().state;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ID: ${state.example.id}'),
            Text('Title: ${state.example.title}'),
            Text('Description: ${state.example.description}'),
            PrimaryButton(
              text: 'Reload',
              onPressed: () {
                context.read<ExampleCubit>().loadExample();
              },
            ),
          ],
        ),
      ),
    );
  }
}
