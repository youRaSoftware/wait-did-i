import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../cubit/home_cubit.dart';
import 'home_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (BuildContext context) => HomeCubit()..init(),
      child: const HomeForm(),
    );
  }
}
