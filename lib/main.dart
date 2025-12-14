import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hex_images_arch/ui/providers/auth_provider.dart';
import 'package:hex_images_arch/ui/screens/auth_screen.dart';
import 'package:hex_images_arch/ui/theme.dart';
import 'package:hex_images_arch/ui/widgets/home_screen.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Hex Image Editor',
      theme: AppTheme.lightTheme,
      home: authState.isLoading
          ? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
          : authState.isAuthenticated
          ? const HomeScreen()
          : const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}