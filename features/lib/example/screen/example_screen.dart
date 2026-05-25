import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../cubit/example_cubit.dart';
import 'example_form.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExampleCubit>(
      create: (BuildContext context) => ExampleCubit(),
      child: const ExampleForm(),
    );
  }
}