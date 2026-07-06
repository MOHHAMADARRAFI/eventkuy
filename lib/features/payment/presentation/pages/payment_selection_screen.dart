import 'package:flutter/material.dart';
import 'payment_detail_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? _selectedMethod;

  // Fungsi untuk mengubah state metode terpilih
  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Metode Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Opsi QRIS
            _buildPaymentOption(
              title: 'QRIS (Gopay, OVO, Dana)',
              icon: Icons.qr_code_2_rounded,
              value: 'QRIS',
            ),
            const SizedBox(height: 12),
            
            // Opsi Virtual Account
            _buildPaymentOption(
              title: 'Transfer Bank Virtual Account (BCA, Mandiri)',
              icon: Icons.account_balance_rounded,
              value: 'VA',
            ),
            
            const Spacer(),
            
            // Tombol Lanjut (Hanya aktif jika _selectedMethod tidak null)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedMethod == null
                    ? null
                    : () async {
                        // Navigasi ke halaman detail
                        final nav = Navigator.of(context);
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetailScreen(
                              paymentMethod: _selectedMethod!,
                            ),
                          ),
                        );
                        
                        if (result == true && mounted) {
                           nav.pop(true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _selectedMethod == null ? 0 : 2,
                ),
                child: const Text(
                  'Lanjut Pembayaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget custom untuk kartu opsi pembayaran
  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedMethod == value;
    
    return GestureDetector(
      onTap: () => _selectMethod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.indigo.withValues(alpha: 0.1), blurRadius: 8)]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.indigo : Colors.grey[500],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.indigo[900] : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? Colors.indigo : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
