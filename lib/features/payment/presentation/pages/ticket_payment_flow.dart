import 'package:flutter/material.dart';
import 'dart:async';

// ============================================================================
// HALAMAN 1: PEMILIHAN TIKET & KONFIRMASI DAFTAR
// ============================================================================
class TicketSelectionScreen extends StatefulWidget {
  const TicketSelectionScreen({super.key});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  int _ticketCount = 1;
  final int _ticketPrice = 150000; // Harga per tiket Rp 150.000

  void _increment() {
    setState(() {
      _ticketCount++;
    });
  }

  void _decrement() {
    if (_ticketCount > 1) {
      setState(() {
        _ticketCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPrice = _ticketCount * _ticketPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Tiket'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Kuy: Tech Conference 2026',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harga Tiket: Rp $_ticketPrice / slot',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            
            // Counter Pemilihan Tiket
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jumlah Tiket',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _decrement,
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.indigo, size: 28),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '$_ticketCount',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _increment,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.indigo, size: 28),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            
            // Total Harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Harga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rp $totalPrice',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Tombol Konfirmasi Daftar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () async {
                  // Navigasi ke Halaman 2 dengan membawa data
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionScreen(
                        ticketCount: _ticketCount,
                        totalPrice: totalPrice,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Konfirmasi Daftar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN 2: PILIHAN METODE PEMBAYARAN
// ============================================================================
class PaymentSelectionScreen extends StatefulWidget {
  final int ticketCount;
  final int totalPrice;

  const PaymentSelectionScreen({
    super.key,
    required this.ticketCount,
    required this.totalPrice,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String _selectedMethod = 'QRIS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Order
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah Tiket', style: TextStyle(fontSize: 15)),
                      Text('${widget.ticketCount} Tiket', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontSize: 15)),
                      Text(
                        'Rp ${widget.totalPrice}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Pilihan Metode
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('QRIS (Gopay, OVO, Dana)', style: TextStyle(fontWeight: FontWeight.w500)),
                    value: 'QRIS',
                    groupValue: _selectedMethod,
                    activeColor: Colors.indigo,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    title: const Text('Transfer Bank (Virtual Account)', style: TextStyle(fontWeight: FontWeight.w500)),
                    value: 'VA',
                    groupValue: _selectedMethod,
                    activeColor: Colors.indigo,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Tombol Lanjut
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () async {
                  // Navigasi ke Halaman 3 dengan membawa data metode dan harga
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailScreen(
                        paymentMethod: _selectedMethod,
                        totalPrice: widget.totalPrice,
                      ),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Lanjut Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN 3: DETAIL PEMBAYARAN & UPLOAD BUKTI
// ============================================================================
class PaymentDetailScreen extends StatefulWidget {
  final String paymentMethod;
  final int totalPrice;

  const PaymentDetailScreen({
    super.key,
    required this.paymentMethod,
    required this.totalPrice,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  Timer? _timer;
  int _secondsRemaining = 15 * 60 - 1; // 14 menit 59 detik
  bool _isProofUploaded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 70),
          content: const Text(
            'Pembayaran Berhasil Dikonfirmasi!\n\nTiket Anda akan segera diproses.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context, true); // return true to flow
                },
                child: const Text('Kembali ke Halaman Utama', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Countdown Timer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  const Text('Selesaikan dalam', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _formattedTime,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Total yang harus dibayar', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              'Rp ${widget.totalPrice}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 32),
            
            // Tampilan Berdasarkan Metode Pembayaran
            if (widget.paymentMethod == 'QRIS') ...[
              const Text('Scan QR Code berikut:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 150, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {}, // Tombol dummy
                icon: const Icon(Icons.download, color: Colors.indigo),
                label: const Text('Simpan QR', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.indigo, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ] else ...[
              const Text('Transfer ke Virtual Account:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    '8077 0812 3456 7890',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {}, // Tombol dummy
                icon: const Icon(Icons.copy, color: Colors.indigo),
                label: const Text('Salin No. VA', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.indigo, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            const Divider(thickness: 1.5),
            const SizedBox(height: 24),
            
            // Fitur Upload Bukti Pembayaran
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Konfirmasi Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                setState(() {
                  _isProofUploaded = true;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _isProofUploaded ? Colors.green.shade50 : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isProofUploaded ? Colors.green : Colors.indigo.shade200,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isProofUploaded ? Icons.check_circle : Icons.cloud_upload_rounded,
                      color: _isProofUploaded ? Colors.green : Colors.indigo,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isProofUploaded ? 'Bukti_Pembayaran.jpg berhasil dipilih!' : 'Pilih Foto/File Bukti Pembayaran',
                      style: TextStyle(
                        color: _isProofUploaded ? Colors.green.shade700 : Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Tombol Akhir Konfirmasi
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isProofUploaded ? Colors.indigo : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _isProofUploaded ? 2 : 0,
                ),
                onPressed: _isProofUploaded ? _showSuccessDialog : null,
                child: const Text(
                  'Konfirmasi Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
