import 'package:flutter/material.dart';

// ============================================================================
// HALAMAN 1: PILIH KATEGORI (ROLE)
// ============================================================================
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
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
              'Pilih Kategori Akun',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih salah satu role di bawah ini untuk melanjutkan proses pendaftaran di EventKuy.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            
            // Kartu Pilihan: Peserta
            _buildRoleCard(
              title: 'Daftar sebagai Peserta',
              description: 'Cari, temukan, dan beli tiket untuk berbagai event atau seminar impian Anda.',
              icon: Icons.person_search_rounded,
              roleValue: 'PESERTA',
            ),
            const SizedBox(height: 20),
            
            // Kartu Pilihan: EO
            _buildRoleCard(
              title: 'Daftar sebagai Event Organizer',
              description: 'Buat, posting, dan kelola event atau seminar Anda. Jangkau ribuan audiens.',
              icon: Icons.campaign_rounded,
              roleValue: 'EO',
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _selectedRole == null ? 0 : 2,
                ),
                onPressed: _selectedRole == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationFormScreen(role: _selectedRole!),
                          ),
                        );
                      },
                child: const Text(
                  'Lanjut Pendaftaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String roleValue,
  }) {
    final isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.indigo : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN 2: FORMULIR PENDAFTARAN
// ============================================================================
class RegistrationFormScreen extends StatefulWidget {
  final String role; // 'PESERTA' atau 'EO'
  const RegistrationFormScreen({super.key, required this.role});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  bool _isLegalUploaded = false;

  @override
  Widget build(BuildContext context) {
    final isPeserta = widget.role == 'PESERTA';
    return Scaffold(
      appBar: AppBar(
        title: Text(isPeserta ? 'Daftar Peserta' : 'Daftar Event Organizer'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lengkapi Data Diri',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 24),
            
            if (isPeserta) ...[
              _buildTextField('Nama Lengkap', Icons.person),
              const SizedBox(height: 16),
              _buildTextField('Email', Icons.email),
              const SizedBox(height: 16),
              _buildTextField('Nomor HP', Icons.phone),
            ] else ...[
              _buildTextField('Nama EO / Instansi', Icons.business),
              const SizedBox(height: 16),
              _buildTextField('Email EO', Icons.email),
              const SizedBox(height: 16),
              _buildTextField('WhatsApp PIC', Icons.phone),
              const SizedBox(height: 16),
              _buildTextField('Nomor KTP / NIB', Icons.badge),
              const SizedBox(height: 16),
              _buildTextField('Link Portofolio / Sosmed', Icons.link),
              const SizedBox(height: 24),
              const Text('Dokumen Legalitas / KTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLegalUploaded = true;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _isLegalUploaded ? Colors.green.shade50 : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isLegalUploaded ? Colors.green : Colors.indigo.shade200,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isLegalUploaded ? Icons.check_circle : Icons.upload_file,
                        color: _isLegalUploaded ? Colors.green : Colors.indigo,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isLegalUploaded ? 'Dokumen berhasil diupload!' : 'Tap untuk Upload Dokumen',
                        style: TextStyle(
                          color: _isLegalUploaded ? Colors.green.shade700 : Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],

            const SizedBox(height: 40),
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
                onPressed: () {
                  // Simulasi daftar selesai, pergi ke dashboard masing-masing
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => isPeserta ? const PesertaDashboard() : const EODashboard(),
                    ),
                    (route) => false, // Menghapus tumpukan halaman registrasi
                  );
                },
                child: const Text(
                  'Daftar Sekarang',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}

// ============================================================================
// HALAMAN 3A: DASHBOARD PESERTA
// ============================================================================
class PesertaDashboard extends StatelessWidget {
  const PesertaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventKuy - Peserta'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Menghilangkan tombol back karena ini halaman utama
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Event Menarik Untukmu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildEventCard('Tech Conference 2026', 'Jakarta Convention Center', 'Rp 150.000'),
          _buildEventCard('Seminar Bisnis Digital', 'Online Zoom', 'Gratis'),
          _buildEventCard('Konser Musik Indie', 'Lapangan Senayan', 'Rp 250.000'),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {}, // Tombol dummy
              icon: const Icon(Icons.search),
              label: const Text('Cari & Beli Tiket Event Lainnya', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String location, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.event, color: Colors.indigo),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('$location\n$price', style: const TextStyle(height: 1.4)),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}

// ============================================================================
// HALAMAN 3B: DASHBOARD EVENT ORGANIZER (EO)
// ============================================================================
class EODashboard extends StatefulWidget {
  const EODashboard({super.key});

  @override
  State<EODashboard> createState() => _EODashboardState();
}

class _EODashboardState extends State<EODashboard> {
  // 1. State List Event
  List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'judul': 'Workshop Flutter Developer',
      'kategori': 'Workshop',
      'tanggal': '12 Agustus 2026',
      'kuota': '100',
      'jenis': 'Offline',
      'lokasi': 'Gedung Manggala Wanabakti, Jakarta',
      'harga': '150000',
      'pembicara': 'Budi Santoso',
      'benefit': ['E-Sertifikat', 'Konsumsi', 'Merchandise'],
    },
    {
      'id': '2',
      'judul': 'Design Thinking Class',
      'kategori': 'Seminar',
      'tanggal': '20 September 2026',
      'kuota': '150',
      'jenis': 'Online',
      'lokasi': 'https://zoom.us/j/123456789',
      'harga': '0',
      'pembicara': 'Siska Amelia',
      'benefit': ['E-Sertifikat'],
    }
  ];

  void _showEventFormBottomSheet({Map<String, dynamic>? eventToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EventFormSheet(
          eventToEdit: eventToEdit,
          onSave: (Map<String, dynamic> newEvent) {
            setState(() {
              if (eventToEdit == null) {
                // Mode Tambah
                newEvent['id'] = DateTime.now().millisecondsSinceEpoch.toString();
                _events.add(newEvent);
              } else {
                // Mode Edit
                final index = _events.indexWhere((e) => e['id'] == eventToEdit['id']);
                if (index != -1) {
                  newEvent['id'] = eventToEdit['id'];
                  _events[index] = newEvent;
                }
              }
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(eventToEdit == null ? 'Event berhasil ditambahkan!' : 'Event berhasil diperbarui!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EO Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Event yang Pernah Diposting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 20),
          if (_events.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('Belum ada event yang dibuat.', style: TextStyle(color: Colors.grey))))
          else
            ..._events.map((event) => _buildEOEventCard(event)),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEventFormBottomSheet(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Event Baru', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEOEventCard(Map<String, dynamic> event) {
    bool isFree = event['harga'] == '0' || event['harga'] == '';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.analytics, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event['judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                      const SizedBox(height: 4),
                      Text('${event['kategori']} • ${event['jenis']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(event['tanggal'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEventFormBottomSheet(eventToEdit: event),
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  tooltip: 'Edit Event',
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harga Tiket', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      isFree ? 'Gratis' : 'Rp ${event['harga']}', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: isFree ? Colors.green : Colors.indigo)
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Kuota', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${event['kuota']} Orang', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// KOMPONEN FORM EVENT (BOTTOM SHEET)
// ----------------------------------------------------------------------------
class _EventFormSheet extends StatefulWidget {
  final Map<String, dynamic>? eventToEdit;
  final Function(Map<String, dynamic>) onSave;

  const _EventFormSheet({this.eventToEdit, required this.onSave});

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  late TextEditingController _judulCtrl;
  late TextEditingController _tanggalCtrl;
  late TextEditingController _kuotaCtrl;
  late TextEditingController _lokasiCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _pembicaraCtrl;

  String _kategori = 'Seminar';
  String _jenis = 'Offline';
  bool _bannerUploaded = false;
  
  Map<String, bool> _benefits = {
    'E-Sertifikat': false,
    'Konsumsi': false,
    'Merchandise': false,
  };

  final List<String> _kategoriOptions = ['Seminar', 'Workshop', 'Konser', 'Bootcamp'];

  @override
  void initState() {
    super.initState();
    final e = widget.eventToEdit;
    _judulCtrl = TextEditingController(text: e?['judul'] ?? '');
    _tanggalCtrl = TextEditingController(text: e?['tanggal'] ?? '');
    _kuotaCtrl = TextEditingController(text: e?['kuota'] ?? '');
    _lokasiCtrl = TextEditingController(text: e?['lokasi'] ?? '');
    _hargaCtrl = TextEditingController(text: e?['harga'] ?? '');
    _pembicaraCtrl = TextEditingController(text: e?['pembicara'] ?? '');

    if (e != null) {
      _kategori = e['kategori'] ?? 'Seminar';
      _jenis = e['jenis'] ?? 'Offline';
      _bannerUploaded = true; // Simulasi kalau edit berarti udah punya banner
      
      List<dynamic> benefitList = e['benefit'] ?? [];
      for (var key in _benefits.keys) {
        _benefits[key] = benefitList.contains(key);
      }
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _tanggalCtrl.dispose();
    _kuotaCtrl.dispose();
    _lokasiCtrl.dispose();
    _hargaCtrl.dispose();
    _pembicaraCtrl.dispose();
    super.dispose();
  }

  void _saveEvent() {
    if (_judulCtrl.text.isEmpty || _tanggalCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Tanggal wajib diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    List<String> selectedBenefits = [];
    _benefits.forEach((key, value) {
      if (value) selectedBenefits.add(key);
    });

    widget.onSave({
      'judul': _judulCtrl.text,
      'kategori': _kategori,
      'tanggal': _tanggalCtrl.text,
      'kuota': _kuotaCtrl.text,
      'jenis': _jenis,
      'lokasi': _lokasiCtrl.text,
      'harga': _hargaCtrl.text,
      'pembicara': _pembicaraCtrl.text,
      'benefit': selectedBenefits,
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.eventToEdit != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      margin: EdgeInsets.only(top: 40), // Spasi dari atas layar agar bisa discroll optimal
      child: Column(
        children: [
          // Header Modal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Event' : 'Tambah Event Baru',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          // Body Form
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              children: [
                // Upload Banner Simulasi
                GestureDetector(
                  onTap: () => setState(() => _bannerUploaded = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 120,
                    decoration: BoxDecoration(
                      color: _bannerUploaded ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _bannerUploaded ? Colors.green : Colors.amber,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _bannerUploaded ? Icons.check_circle : Icons.add_photo_alternate,
                          color: _bannerUploaded ? Colors.green : Colors.amber,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _bannerUploaded ? 'Banner Terupload!' : 'Tap untuk Upload Banner Poster',
                          style: TextStyle(
                            color: _bannerUploaded ? Colors.green : Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Judul & Kategori
                TextField(
                  controller: _judulCtrl,
                  decoration: _inputDecoration('Judul Event'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _kategori,
                  decoration: _inputDecoration('Kategori Event'),
                  items: _kategoriOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => _kategori = val!),
                ),
                const SizedBox(height: 16),
                
                // Tanggal & Kuota
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tanggalCtrl,
                        decoration: _inputDecoration('Tanggal (Cth: 10 Okt 2026)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _kuotaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Kuota Peserta'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Format Event Toggle
                const Text('Format Event', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Offline', style: TextStyle(fontSize: 14)),
                        value: 'Offline',
                        groupValue: _jenis,
                        activeColor: Colors.amber,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _jenis = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Online', style: TextStyle(fontSize: 14)),
                        value: 'Online',
                        groupValue: _jenis,
                        activeColor: Colors.amber,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _jenis = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Lokasi / Link
                TextField(
                  controller: _lokasiCtrl,
                  decoration: _inputDecoration(_jenis == 'Offline' ? 'Alamat Lengkap Venue' : 'Link Zoom / GMeet'),
                ),
                const SizedBox(height: 16),

                // Harga
                TextField(
                  controller: _hargaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Harga Tiket (Isi 0 jika Gratis)'),
                ),
                const SizedBox(height: 16),

                // Pembicara
                TextField(
                  controller: _pembicaraCtrl,
                  decoration: _inputDecoration('Nama Pembicara (Opsional)'),
                ),
                const SizedBox(height: 24),

                // Benefit Checkbox
                const Text('Benefit untuk Peserta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 8),
                ..._benefits.keys.map((key) {
                  return CheckboxListTile(
                    title: Text(key, style: const TextStyle(fontSize: 14)),
                    value: _benefits[key],
                    activeColor: Colors.amber,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _benefits[key] = val!;
                      });
                    },
                  );
                }).toList(),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveEvent,
                    child: Text(
                      isEdit ? 'Update Event' : 'Simpan & Publikasikan',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }
}
