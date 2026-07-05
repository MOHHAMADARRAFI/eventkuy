// lib/features/organizer/scanner/barcode_scanner_service.dart

import 'package:flutter/material.dart';

abstract class IBarcodeScannerService {
  Future<String?> scanBarcode(BuildContext context);
}

class MockBarcodeScannerService implements IBarcodeScannerService {
  @override
  Future<String?> scanBarcode(BuildContext context) async {
    // Shows a simulator popup dialog with choices for testing scanner response
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simulator Scan QR Code'),
          content: const Text('Pilih hasil pemindaian tiket untuk disimulasikan:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'TICKET_VALID_12345'),
              child: const Text('Simulate Valid', style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'TICKET_ALREADY_CHECKED_IN'),
              child: const Text('Already Checked-in', style: TextStyle(color: Colors.orange)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'TICKET_INVALID_00000'),
              child: const Text('Simulate Invalid', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
