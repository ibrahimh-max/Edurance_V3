import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/router/app_router.dart';

class _C {
  static const yellow = Color(0xFFFFD94A);
  static const blue   = Color(0xFF4AC8FF);
  static const coral  = Color(0xFFFF6B6B);
  static const green  = Color(0xFF56CF7E);
  static const bg     = Color(0xFFFFF9F0);
  static const dark   = Color(0xFF1A1A2E);
  static const muted  = Color(0xFF9E9EA8);
  static const white  = Colors.white;
}

class ParentControlScreen extends StatefulWidget {
  const ParentControlScreen({super.key});

  @override
  State<ParentControlScreen> createState() =>
      _ParentControlScreenState();
}

class _ParentControlScreenState
    extends State<ParentControlScreen> {

  int mathCount = 4;
  int scienceCount = 7;
  int englishCount = 5;
  int hindiCount = 3;
  int evsCount = 2;

  @override
  void initState() {
    super.initState();

    final metadata =
        Supabase.instance.client.auth.currentUser
            ?.userMetadata ?? {};

    mathCount =
        metadata["mathLessonsWeekly"] ?? mathCount;

    scienceCount =
        metadata["scienceLessonsWeekly"] ??
        scienceCount;

    englishCount =
        metadata["englishLessonsWeekly"] ??
        englishCount;

    hindiCount =
        metadata["hindiLessonsWeekly"] ??
        hindiCount;

    evsCount =
        metadata["evsLessonsWeekly"] ?? evsCount;
  }

  Future<void> _saveSchedule() async {

    await Supabase.instance.client.auth.updateUser(
      UserAttributes(
        data: {
          "mathLessonsWeekly": mathCount,
          "scienceLessonsWeekly": scienceCount,
          "englishLessonsWeekly": englishCount,
          "hindiLessonsWeekly": hindiCount,
          "evsLessonsWeekly": evsCount,
        },
      ),
    );
  }

  Widget _buildRow(
      String subject,
      int value,
      VoidCallback plus,
      VoidCallback minus) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [

          Text(
            subject,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          Row(
            children: [

              IconButton(
                onPressed: () {
                  minus();
                  _saveSchedule();
                },
                icon: const Icon(Icons.remove),
              ),

              Text(
                value.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              IconButton(
                onPressed: () {
                  plus();
                  _saveSchedule();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _C.bg,

      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: _C.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(AppRoutes.modules),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _buildRow(
              "Math",
              mathCount,
              () => setState(() => mathCount++),
              () => setState(() => mathCount--),
            ),

            _buildRow(
              "Science",
              scienceCount,
              () =>
                  setState(() => scienceCount++),
              () =>
                  setState(() => scienceCount--),
            ),

            _buildRow(
              "English",
              englishCount,
              () =>
                  setState(() => englishCount++),
              () =>
                  setState(() => englishCount--),
            ),

            _buildRow(
              "Hindi",
              hindiCount,
              () =>
                  setState(() => hindiCount++),
              () =>
                  setState(() => hindiCount--),
            ),

            _buildRow(
              "EVS",
              evsCount,
              () => setState(() => evsCount++),
              () => setState(() => evsCount--),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () =>
                  context.go(AppRoutes.modules),

              style: ElevatedButton.styleFrom(
                backgroundColor: _C.green,
                padding:
                    const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14),
              ),

              child: const Text(
                "Back to Learning",
              ),
            ),
          ],
        ),
      ),
    );
  }
}