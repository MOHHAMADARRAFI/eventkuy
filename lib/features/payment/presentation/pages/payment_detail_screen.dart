import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentMethod;

  const PaymentDetailScreen({super.key, required this.paymentMethod});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late Timer _timer;
  int _remainingSeconds = 15 * 60; // Simulasi 15 menit

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Fungsi untuk menjalankan Countdown Timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Mengubah detik menjadi format MM:SS
  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Aksi ketika user klik tombol "Saya Sudah Bayar"
  void _finishPayment() {
    // Kembalikan nilai true ke halaman sebelumnya
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isQRIS = widget.paymentMethod == 'QRIS';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Widget Countdown Timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.orange[50],
              child: Column(
                children: [
                  const Text(
                    'Selesaikan pembayaran dalam',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Konten dinamis berdasarkan pilihan metode
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: isQRIS ? _buildQRISSection() : _buildVASection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _finishPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Saya Sudah Bayar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Komponen khusus jika memilih QRIS
  Widget _buildQRISSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Total Pembayaran',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rp 150.000', // Dummy Harga
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 32),
        
        // Placeholder Kotak QR Code
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 120,
                  color: Colors.indigo[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'QRIS Mockup',
                  style: TextStyle(
                    color: Colors.indigo[300],
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Tombol Simpan Ke Galeri
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR Code berhasil disimpan ke Galeri (Simulasi)'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.download_rounded),
          label: const Text('Simpan QR ke Galeri'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.indigo,
            side: const BorderSide(color: Colors.indigo, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Instruksi
        _buildInstruction(
          title: 'Cara Pembayaran via QRIS',
          steps: [
            'Buka aplikasi e-wallet (Gopay, OVO, Dana) atau m-banking Anda.',
            'Pilih menu Scan QR.',
            'Arahkan kamera ke QR Code di atas atau unggah dari Galeri.',
            'Periksa detail pembayaran dan pastikan penerima adalah "Event Kuy".',
            'Konfirmasi pembayaran dengan memasukkan PIN.',
          ],
        ),
      ],
    );
  }

  // Komponen khusus jika memilih Virtual Account
  Widget _buildVASection() {
    const String vaNumber = '880123456789'; // Dummy VA
    const String bankName = 'BCA Virtual Account';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Total Pembayaran',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Rp 150.000',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        const Text(
          bankName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Kotak Copy VA
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Virtual Account',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    vaNumber,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  // Menyalin ke Clipboard
                  Clipboard.setData(const ClipboardData(text: vaNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nomor VA berhasil disalin!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, color: Colors.indigo),
                tooltip: 'Salin Nomor VA',
              )
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Instruksi
        _buildInstruction(
          title: 'Cara Pembayaran via m-Banking',
          steps: [
            'Login ke aplikasi m-Banking Anda.',
            'Pilih menu Transfer > Virtual Account.',
            'Masukkan nomor Virtual Account di atas ($vaNumber).',
            'Pastikan nama penerima/merchant adalah "Event Kuy".',
            'Masukkan nominal jika diminta, lalu konfirmasi dengan PIN Anda.',
          ],
        ),
      ],
    );
  }

  // Widget Helper untuk merender list langkah instruksi
  Widget _buildInstruction({required String title, required List<String> steps}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            int idx = entry.key;
            String text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
