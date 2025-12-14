import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/account_settings_screen.dart';
import '../screens/effects_screen.dart';
import '../screens/image_import_screen.dart';
import '../screens/images_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Проекты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Импорт',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Эффекты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );

  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const ImagesListScreen();
      case 1:
        return const ImageImportScreen();
      case 2:
        return const EffectsScreen();
      case 3:
        return const AccountSettingsScreen();
      default:
        return const ImagesListScreen();
    }
  }
}

