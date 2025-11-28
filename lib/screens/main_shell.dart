// -----------------------------------------
// lib/features/shell/screen/main_shell.dart
// -----------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ta_teori/logic/auth_bloc.dart';
import 'package:ta_teori/screens/login_screen.dart'; 
import 'package:ta_teori/screens/home_screen.dart';
import 'package:ta_teori/screens/my_list_screen.dart';
import 'package:ta_teori/screens/profile_screen.dart';
import 'package:ta_teori/screens/search_screen.dart';
import 'package:ta_teori/logic/shell_cubit.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShellCubit(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: const MainShellView(),
      ),
    );
  }
}

class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    MyListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<ShellCubit>().state;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex, 
        onTap: (index) {
          context.read<ShellCubit>().changePage(index);
        },
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'My List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}