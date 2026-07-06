import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade700,
              Colors.indigo.shade400,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(height: 40), // Spacer atas
                          
                          // --- Bagian Tengah: Logo & Teks ---
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 2. Logo aplikasi dengan lingkaran semi-transparan
                              Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade900.withValues(alpha: 0.5),
                                      blurRadius: 40,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.confirmation_number_rounded,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 36),
                              
                              // 3. Nama Aplikasi "event_kuy"
                              const Text(
                                'event_kuy',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Slogan kontras di bawah nama aplikasi
                              Text(
                                'Temukan & Ikuti Berbagai\nEvent Seru di Sekitarmu!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          
                          // --- 4. Bagian Bawah: Tombol Mulai ---
                          Column(
                            children: [
                              const SizedBox(height: 40), // Jarak ekstra jika layar kecil
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go('/onboarding');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, // Warna tombol putih
                                    foregroundColor: Colors.indigo.shade900, // Teks warna Indigo
                                    elevation: 10,
                                    shadowColor: Colors.black45,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Mulai Sekarang',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
