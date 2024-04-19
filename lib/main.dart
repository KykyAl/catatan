import 'package:catatan/helper/scroll_behavior.dart';
import 'package:catatan/screens/notes/add_note_screen.dart';
import 'package:catatan/screens/notes/user_note_screen.dart';
import 'package:catatan/screens/splash_screen.dart';
import 'package:catatan/screens/tasks/add_task.dart';
import 'package:catatan/screens/tasks/user_task_screen.dart';
import 'package:catatan/screens/user_add_screen.dart';
import 'package:catatan/screens/user_detail_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/notes_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/user_provider.dart';
import '../screens/tabs_screen.dart';
import '../widget/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceInfo = await DeviceInfoPlugin().deviceInfo;
  final androidSdkVersion =
      deviceInfo is AndroidDeviceInfo ? deviceInfo.version.sdkInt : 1;
  runApp(MyApp(androidSdkVersion: androidSdkVersion));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.androidSdkVersion}) : super(key: key);
  final int androidSdkVersion;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: TasksProvider(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: UserProvider(),
        ),
        ChangeNotifierProvider.value(
          value: NotesProvider(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            scrollBehavior: CustomScrollBehavior(
                androidSkVersion: widget.androidSdkVersion),
            theme: Provider.of<UserProvider>(context).isDark
                ? DarkTheme.darkThemeData
                : LightTheme.lightThemeData,
            home: auth.isAuth
                ? const Tabs()
                : FutureBuilder(
                    future: auth.tryLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? Container(
                                color: Colors.white,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SplashScreen(),
                  ),
            routes: {
              UserAddScreen.routeName: (context) => const UserAddScreen(),
              UserNoteScreen.routeName: (context) => const UserNoteScreen(),
              UserTaskScreen.routeName: (context) => const UserTaskScreen(),
              AddTask.routeName: (context) => const AddTask(),
              Tabs.routeName: (context) => const Tabs(),
              AddNote.routeName: (context) => const AddNote(),
              UserDetailScreen.routeName: (context) => const UserDetailScreen(),
            },
          );
        },
      ),
    );
  }
}
